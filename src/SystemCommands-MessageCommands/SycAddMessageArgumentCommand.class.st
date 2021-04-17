"
I am a command to add new argument into the message.

Internal Representation and Key Implementation Points.

    Instance Variables
	argumentDefaultValue:		<Object>
	newSelector:		<Symbol>
"
Class {
	#name : #SycAddMessageArgumentCommand,
	#superclass : #SycChangeMessageSignatureCommand,
	#instVars : [
		'newSelector',
		'argumentDefaultValue'
	],
	#category : #'SystemCommands-MessageCommands'
}

{ #category : #activation }
SycAddMessageArgumentCommand class >> methodContextMenuActivation [
	<classAnnotation>
	
	^ SycMethodMenuActivation
		byRootGroupItemOrder: 30 for: ClyMethod asCalypsoItemContext
]

{ #category : #accessing }
SycAddMessageArgumentCommand >> argumentDefaultValue [
	^ argumentDefaultValue
]

{ #category : #accessing }
SycAddMessageArgumentCommand >> argumentDefaultValue: anObject [
	argumentDefaultValue := anObject
]

{ #category : #execution }
SycAddMessageArgumentCommand >> createRefactoring [
	| permutation |
	permutation := newSelector argumentNames collect: [ :e |
		originalMessage argumentNames indexOf: e ifAbsent: [ 0 ]
	].
	^RBAddParameterRefactoring
		model: model
		addParameterToMethod: originalMessage selector
		in: (SycMessageOriginHack of: originalMessage) "look at SycMessageOriginHack comment"
		newSelector: newSelector selector
		permutation: permutation
		initializer: argumentDefaultValue
]

{ #category : #execution }
SycAddMessageArgumentCommand >> createValidNameArgument [
	|method newString baseString i|
	method := originalMessage methodClass >> originalMessage selector.
	newString := baseString := 'anObject'.
	i := 0.
	
	[(method tempNames includes: newString) 
		or: [originalMessage methodClass allInstVarNames includes: newString]] 
			whileTrue: 
				[i := i + 1.
				newString := baseString , i printString].
	^ {newString asSymbol}
]

{ #category : #accessing }
SycAddMessageArgumentCommand >> defaultMenuIconName [
	^#smallAdd

]

{ #category : #accessing }
SycAddMessageArgumentCommand >> defaultMenuItemName [
	^'Add argument'
]

{ #category : #accessing }
SycAddMessageArgumentCommand >> newSelector [
	^ newSelector
]

{ #category : #accessing }
SycAddMessageArgumentCommand >> newSelector: anObject [
	newSelector := anObject
]

{ #category : #execution }
SycAddMessageArgumentCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	
	newSelector := self requestMessageIn: aToolContext.
	
	argumentDefaultValue := UIManager default
		request: 'Enter default value for argument' initialAnswer: 'nil'.
	argumentDefaultValue isEmptyOrNil ifTrue:  [ CmdCommandAborted signal ]
]

{ #category : #execution }
SycAddMessageArgumentCommand >> requestMessageIn: aToolContext [
	| methodName dialog |
	methodName := RBMethodName selector: originalMessage selector, 'arg:' arguments: originalMessage argumentNames, self createValidNameArgument.
	dialog := SycMethodNameEditorPresenter openOn: methodName.
	dialog cancelled ifTrue: [  CmdCommandAborted signal ].
	
	originalMessage selector = methodName selector & (originalMessage argumentNames = methodName arguments)
		ifTrue: [ CmdCommandAborted signal].		
				
	^(SycMessageDescription fromContextOf: aToolContext)
		selector: methodName selector;
		argumentNames: methodName arguments
]

{ #category : #execution }
SycAddMessageArgumentCommand >> resultMessageSelector [
	^newSelector
]
