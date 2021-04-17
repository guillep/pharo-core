"
I am a base class for commands which modify signature of given message.

My subclasse should implement two methods: 

- createRefactoring 
It should return refactoring instance which will perform actual change.

- resultMessageSelector 
it should return target selector of the message after modification.

Internal Representation and Key Implementation Points.

    Instance Variables
	originalMessage:		<ClyMessageDescription>
"
Class {
	#name : #SycChangeMessageSignatureCommand,
	#superclass : #CmdCommand,
	#traits : 'TRefactoringCommandSupport',
	#classTraits : 'TRefactoringCommandSupport classTrait',
	#instVars : [
		'originalMessage'
	],
	#category : #'SystemCommands-MessageCommands'
}

{ #category : #testing }
SycChangeMessageSignatureCommand class >> canBeExecutedInContext: aToolContext [
	^aToolContext isMessageSelected | aToolContext isMethodSelected
]

{ #category : #testing }
SycChangeMessageSignatureCommand class >> isAbstract [
	^self = SycChangeMessageSignatureCommand 
]

{ #category : #execution }
SycChangeMessageSignatureCommand >> applyResultInContext: aToolContext [
	super applyResultInContext: aToolContext.

	aToolContext showMessage: originalMessage renamedTo: self resultMessageSelector asSymbol
]

{ #category : #execution }
SycChangeMessageSignatureCommand >> asRefactorings [
	^{self createRefactoring}
]

{ #category : #execution }
SycChangeMessageSignatureCommand >> createRefactoring [
	self subclassResponsibility
]

{ #category : #execution }
SycChangeMessageSignatureCommand >> execute [
	
	self executeRefactorings
]

{ #category : #testing }
SycChangeMessageSignatureCommand >> isComplexRefactoring [
	^true
]

{ #category : #accessing }
SycChangeMessageSignatureCommand >> originalMessage [
	^ originalMessage
]

{ #category : #accessing }
SycChangeMessageSignatureCommand >> originalMessage: anObject [
	originalMessage := anObject
]

{ #category : #execution }
SycChangeMessageSignatureCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	self setUpModelFromContext: aToolContext.
	originalMessage := aToolContext lastSelectedMessage
]

{ #category : #execution }
SycChangeMessageSignatureCommand >> resultMessageSelector [
	self subclassResponsibility 
]
