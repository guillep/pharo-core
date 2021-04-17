"
I am a TestCase created from a comment.
To create a new instance you can call one of my factory methods, if you want to understand it better you can look at the example in my class side.

"
Class {
	#name : #CommentTestCase,
	#superclass : #TestCase,
	#instVars : [
		'currentValue',
		'expectedValue',
		'expression',
		'docCommentNode'
	],
	#category : #'DrTests-CommentsToTests-Model'
}

{ #category : #'instance creation' }
CommentTestCase class >> for: aDocComment [

	^self new docCommentNode: aDocComment
]

{ #category : #accessing }
CommentTestCase class >> testSelectors [
	"we remove the selectors to add back later one of them, depending if is is error or not"
	^ super testSelectors \ { #testError. #testIt }
]

{ #category : #accessing }
CommentTestCase >> classExample [ 
	^  docCommentNode sourceNode methodNode methodClass
]

{ #category : #accessing }
CommentTestCase >> cleanUpInstanceVariables [
	self class allInstVarNames
		do: [ :name | 
			(#('testSelector' 'currentValue' 'expression' 'classExample' 'selectorExample')
				includes: name)
				ifFalse: [ self instVarNamed: name put: nil ] ]
]

{ #category : #accessing }
CommentTestCase >> currentValue [
	^ currentValue
]

{ #category : #accessing }
CommentTestCase >> currentValue: anObject [
	currentValue := anObject
]

{ #category : #accessing }
CommentTestCase >> docCommentNode [

	^ docCommentNode
]

{ #category : #accessing }
CommentTestCase >> docCommentNode: aDocComment [

	| result |
	docCommentNode := aDocComment.
	self expression: aDocComment sourceNode contents.

	result := [ Smalltalk compiler evaluate: expression ]
		          on: Exception
		          do: [ ^ self setTestSelector: #testError ].

	(result isKindOf: Association)
		ifFalse: [ self setTestSelector: #testError ]
		ifTrue: [ 
			self
				expectedValue: result key;
				currentValue: result value;
				setTestSelector: #testIt ]
]

{ #category : #accessing }
CommentTestCase >> drTestsBrowse [
	self flag: #todo.
	"this should be done via the presenter application and not using a global variable."
	Smalltalk tools browser openOnClass: self classExample  selector: self selectorExample
]

{ #category : #accessing }
CommentTestCase >> drTestsName [
	^ self asString
]

{ #category : #accessing }
CommentTestCase >> expectedValue [
	^ expectedValue
]

{ #category : #accessing }
CommentTestCase >> expectedValue: anObject [
	expectedValue := anObject
]

{ #category : #accessing }
CommentTestCase >> expression [
	^ expression
]

{ #category : #accessing }
CommentTestCase >> expression: anObject [
	expression := anObject
]

{ #category : #tests }
CommentTestCase >> hasError [
	^ testSelector == #testError
]

{ #category : #printing }
CommentTestCase >> printString [
	^ expression
]

{ #category : #accessing }
CommentTestCase >> selectorExample [
	^docCommentNode sourceNode methodNode methodClass
]

{ #category : #tests }
CommentTestCase >> testError [
	self error: 'syntax error on the comment'
]

{ #category : #tests }
CommentTestCase >> testIt [
	self assert: expectedValue equals: currentValue
]
