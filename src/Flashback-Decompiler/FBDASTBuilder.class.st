"
I am used to create AST nodes. This class is reserved for the RBAST. 

methodClass <Behavior> behavior where the compiled method is installed.
"
Class {
	#name : #FBDASTBuilder,
	#superclass : #Object,
	#instVars : [
		'methodClass'
	],
	#category : #'Flashback-Decompiler-Utilities'
}

{ #category : #'instance creation' }
FBDASTBuilder class >> newFor: class [
	^ self new
		methodClass: class;
		yourself
]

{ #category : #constructor }
FBDASTBuilder >> codeAnyLitInd: anAssociation [
	| varName |
	"class binding on the class side has nil as key"
	varName := anAssociation key ifNil: [ 'class binding' ] ifNotNil: [ anAssociation key ].
	^ (RBVariableNode named: varName)
		binding: anAssociation;
		yourself
]

{ #category : #building }
FBDASTBuilder >> codeArgument: tempName [
	^ RBVariableNode named: tempName
]

{ #category : #building }
FBDASTBuilder >> codeArray: array [
	^ RBArrayNode statements: array
]

{ #category : #building }
FBDASTBuilder >> codeAssignment: value to: variable [
	^ RBAssignmentNode variable: variable value: value 
]

{ #category : #building }
FBDASTBuilder >> codeBlock: body [
	^ self codeBlock: body arguments: #()
]

{ #category : #building }
FBDASTBuilder >> codeBlock: body arguments: args [
	^ RBBlockNode arguments: args body: body 
]

{ #category : #building }
FBDASTBuilder >> codeBlockFromStatements: statements [
	^ self codeBlock: ((self codeSequence: #()) statements: statements; yourself)
]

{ #category : #building }
FBDASTBuilder >> codeCascade: messages [
	^ RBCascadeNode messages: messages 
]

{ #category : #building }
FBDASTBuilder >> codeConditionalNode: expr trueSequence: seq1 falseSequence: seq2 [
	^ (self
		codeMessage: #ifTrue:ifFalse:
		receiver: expr
		arguments:
			{self codeBlock: seq1.
			self codeBlock: seq2})
		propertyAt: #reconstructed put: true;
		yourself
]

{ #category : #building }
FBDASTBuilder >> codeEmptyBlock [
	^ RBBlockNode body: (self codeSequence: #()) 
]

{ #category : #building }
FBDASTBuilder >> codeEmptySequence [
	^ self codeSequence: #()
]

{ #category : #building }
FBDASTBuilder >> codeInstanceVariable: offset [
	^ RBVariableNode named: (methodClass allInstVarNames at: offset)
]

{ #category : #building }
FBDASTBuilder >> codeLiteral: lit [
	^ RBLiteralNode value: lit 
]

{ #category : #building }
FBDASTBuilder >> codeLiteralValue: lit [
	^ RBLiteralValueNode value: lit 
]

{ #category : #building }
FBDASTBuilder >> codeLoopNode: bool condition: seq1 body: seq2 [
	^ (self
		codeMessage: (#while , bool class name , ':') asSymbol
		receiver: (self codeBlock: seq1)
		arguments: {self codeBlock: seq2})
		propertyAt: #reconstructed put: true;
		yourself
]

{ #category : #building }
FBDASTBuilder >> codeMessage: selector receiver: rcvr arguments:args [
	^ RBMessageNode receiver: rcvr selector: selector arguments: args
]

{ #category : #building }
FBDASTBuilder >> codeMethod: selector arguments: args body: body pragmas: pragmas class: class [
	^ ((RBMethodNode selector: selector arguments: args body: body)
		pragmas: pragmas;
		methodClass: class;
		yourself) doSemanticAnalysis
]

{ #category : #building }
FBDASTBuilder >> codeReceiver [
	^ RBVariableNode selfNode
]

{ #category : #building }
FBDASTBuilder >> codeRepeatNode: body [
	^ (self
		codeMessage: #repeat
		receiver: (self codeBlock: body)
		arguments: #() ) 
			propertyAt: #reconstructed put: true;
			yourself
]

{ #category : #building }
FBDASTBuilder >> codeReturn: value [
	^ RBReturnNode value: value
]

{ #category : #building }
FBDASTBuilder >> codeSelf [
	^ RBVariableNode selfNode
]

{ #category : #building }
FBDASTBuilder >> codeSequence: temps [
	^ RBSequenceNode temporaries: temps statements: OrderedCollection new
]

{ #category : #building }
FBDASTBuilder >> codeSuper [
	^ RBVariableNode superNode
]

{ #category : #building }
FBDASTBuilder >> codeTemp: tempName [
	^ RBVariableNode named: tempName
]

{ #category : #building }
FBDASTBuilder >> codeThisContext [
	^ RBVariableNode thisContextNode
]

{ #category : #building }
FBDASTBuilder >> codeVariable: variable [
	^ RBVariableNode named: variable
]

{ #category : #accessing }
FBDASTBuilder >> methodClass [
	^ methodClass
]

{ #category : #accessing }
FBDASTBuilder >> methodClass: anObject [
	methodClass := anObject
]
