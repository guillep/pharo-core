"
I implement a series of heuristics to extract selectors from source code.

I have two main entry points:

 - `extractSelectorFromSelectedText: aText` receives some text and looks at it in isolation, regarless of the context around it, and tries to find a selector in it
 - `extractSelectorFromAST: anASTNode atPosition: aPositionInTheAST` gets the best node matching the position and extracts a selector from it.

## Heuristics - position

When extracting from a particular position, if the previous character is not a separator, we move the selection one position before.
This heuristic is for the cases where the caret (|) is:
   |self foo  => the caret is before self, do not move
   self foo|  => the caret is before foo, interpret is as if we are in foo.
	self foo | => the caret is before a space, interpret is as if we are in foo.

This heuristic introduces although an ambiguity when code is not nicely formatted:
   self foo:|#bar => Here a user may want foo: or bar.
For now we decided to favor foo: to motivate people to indent code correctly

## Heuristics - cascades

When the best matching node is a message, a strange case may arrive with cascades.
Cascade nodes contain messages and each message contains (duplicated) the receiver.
So we need to deambiguate here: was the selection on the receiver? or on the message itself?
		
For example:
	aVariable
	cascade1;
	cascade2.
			
Selecting both `aVariable` or the message `cascade2` will yield a message node `aVariable cascade2`.
However, in the first case, the cursor is closer to `cascade1`, so we want cascade1 while in the latter case we want cascade2.
"
Class {
	#name : #CNSelectorExtractor,
	#superclass : #Object,
	#category : #'Tools-CodeNavigation'
}

{ #category : #private }
CNSelectorExtractor >> extractSelectorFromAST: ast atPosition: aPosition [

	| bestNodeAtPosition |
	bestNodeAtPosition := ast bestNodeForPosition: aPosition.
	^ self extractSelectorFromNode: bestNodeAtPosition
]

{ #category : #private }
CNSelectorExtractor >> extractSelectorFromNode: aNode [

	| node originalNode |
	aNode ifNil: [ ^ nil ].
	originalNode := node := aNode.
	node isReturn ifTrue: [ node := node value ].

	node isCascade ifTrue: [ ^ node messages first selector ].

	node isMethod ifFalse: [ 
		(node isValue and: [ node value isSymbol ]) ifTrue: [ ^ node value ].

		[ node isMessage or: [ node isMethod ] ] whileFalse: [ 
			(node := node parent) ifNil: [ ^ nil ] ].

		"This is a strange case with cascades.
		Cascade nodes contain messages.
		And each message contains (duplicated) the receiver.
		So we need to deambiguate here:
		  was the selection on the receiver? or on the message itself?
		
		For example:
		  aVariable
			cascade1;
			cascade2.
			
		Selecting both the receiver or the cascade2 will yield a message node `aVariable cascade2`.
		However, in the first case we want cascade1 and in the latter we want cascade2.
		
		"
		(node ~= originalNode and: [ 
			 node parent notNil and: [ node parent isCascade ] ]) ifTrue: [ 
			node := node parent messages first ] ].

	^ node selector
]

{ #category : #'public - extraction' }
CNSelectorExtractor >> extractSelectorFromSelection: aString [ 

	"Extract a selector from the given string in isolation, regarless of the context around it"
	
	| node |
	node := RBParser parseFaultyExpression: aString.
	node
		nodesDo: [ :n |
			n isMessage
				ifTrue: [ ^ n selector ].
			n isVariable
				ifTrue: [ ^ n name ].
			n isLiteralNode
				ifTrue: [ ^ n value ] ].

	"fall back"
	^ aString asSymbol
]

{ #category : #'public - extraction' }
CNSelectorExtractor >> extractSelectorFromSource: aString atPosition: aPosition [

	"Receives a string with the source code, and a number which indicates the position (of the caret) where the selectors will be extracted."

	aString ifNil: [ ^ nil ].
	aString ifEmpty: [ ^ nil ].
	((aPosition < 0) or: (aPosition > aString size)) ifTrue: [ ^nil ].
	^ self
		  extractSelectorFromAST: (RBParser parseFaultyExpression: aString)
		  atPosition: aPosition
]
