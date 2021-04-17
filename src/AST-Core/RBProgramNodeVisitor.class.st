"
RBProgramNodeVisitor is an abstract visitor for the RBProgramNodes.


"
Class {
	#name : #RBProgramNodeVisitor,
	#superclass : #Object,
	#category : #'AST-Core-Visitors'
}

{ #category : #testing }
RBProgramNodeVisitor class >> isAbstract [

	^ self == RBProgramNodeVisitor
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitArgumentNode: anArgumentNode [
	"Sent *each time* an argument node is found"

	^ self visitVariableNode: anArgumentNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitArgumentNodes: aNodeCollection [
	"Sent *once* when visiting method and block nodes"

	^ aNodeCollection do: [ :each | self visitArgumentNode: each ]
]

{ #category : #'visiting - variables' }
RBProgramNodeVisitor >> visitArgumentVariableNode: anArgumentNode [

	^ self visitLocalVariableNode: anArgumentNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitArrayNode: anArrayNode [
	anArrayNode children do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitAssignmentNode: anAssignmentNode [
	self visitNode: anAssignmentNode variable.
	self visitNode: anAssignmentNode value
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitBlockNode: aBlockNode [
	self visitArgumentNodes: aBlockNode arguments.
	self visitNode: aBlockNode body
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitCascadeNode: aCascadeNode [
	aCascadeNode messages do: [ :each | self visitNode: each ]
]

{ #category : #'visiting - variables' }
RBProgramNodeVisitor >> visitClassVariableNode: aNode [

	^ self visitLiteralVariableNode: aNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitEnglobingErrorNode: anEnglobingErrorNode [
	anEnglobingErrorNode content do: [ :each | self visitNode: each ].
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitGlobalNode: aSelfNode [
	^ self visitVariableNode: aSelfNode
]

{ #category : #'visiting - variables' }
RBProgramNodeVisitor >> visitGlobalVariableNode: aNode [

	^ self visitLiteralVariableNode: aNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitInstanceVariableNode: aSelfNode [
	^ self visitVariableNode: aSelfNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitLiteralArrayNode: aRBLiteralArrayNode [
	aRBLiteralArrayNode contents do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitLiteralNode: aLiteralNode [
	
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitLiteralValueNode: aRBLiteralValueNode [
	"Redirect the message by default to #visitLiteralNode: for retrocompatibility (pharo 8)"

	^ self visitLiteralNode: aRBLiteralValueNode
]

{ #category : #'visiting - variables' }
RBProgramNodeVisitor >> visitLiteralVariableNode: aNode [
	"to be backward compatible, we visit for Gloabls here (there used to be no difference)"

	^ self visitGlobalNode: aNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitLocalVariableNode: aNode [
	"call visitTemporaryNode: for backward compatibility"
	^ self visitTemporaryNode: aNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitMessageNode: aMessageNode [
	(aMessageNode isCascaded not or: [ aMessageNode isFirstCascaded ])
		ifTrue: [ self visitNode: aMessageNode receiver ].
	self visitNode: aMessageNode selectorNode.
	aMessageNode arguments do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitMethodNode: aMethodNode [
	self visitArgumentNodes: aMethodNode arguments.
	aMethodNode pragmas do: [ :each | self visitNode: each ].
	self visitNode: aMethodNode body
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitNode: aNode [
	^ aNode acceptVisitor: self
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitParseErrorNode: anErrorNode [
	
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitPatternBlockNode: aRBPatternBlockNode [
	self visitArgumentNodes: aRBPatternBlockNode arguments.
	self visitNode: aRBPatternBlockNode body
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitPatternWrapperBlockNode: aRBPatternWrapperBlockNode [
	self visitNode: aRBPatternWrapperBlockNode wrappedNode.
	self visitArgumentNodes: aRBPatternWrapperBlockNode arguments.
	self visitNode: aRBPatternWrapperBlockNode body
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitPragmaNode: aPragmaNode [
	aPragmaNode arguments do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitReturnNode: aReturnNode [
	^ self visitNode: aReturnNode value
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitSelectorNode: aSelectorNode [
	
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitSelfNode: aSelfNode [
	^ self visitVariableNode: aSelfNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitSequenceNode: aSequenceNode [
	self visitTemporaryNodes: aSequenceNode temporaries.
	aSequenceNode statements do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitSuperNode: aSuperNode [
	^ self visitVariableNode: aSuperNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitTemporaryDeclarationNode: aTemporaryDeclarationNode [
	"| temp |
	temp is a temporary node as we can find in the body of methods, but it can't be visited the same way.
	Redirect the message on argumentNodeVisitor as a way to keep retrocompatibility"

	^ self visitArgumentNode: aTemporaryDeclarationNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitTemporaryNode: aNode [
	"Sent *each time* a temporary node is found"

	^ self visitVariableNode: aNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitTemporaryNodes: aNodeCollection [
	"This is triggered when defining the temporaries between the pipes"

	^ aNodeCollection
		do: [ :each | self visitTemporaryDeclarationNode: each ]
]

{ #category : #'visiting - variables' }
RBProgramNodeVisitor >> visitTemporaryVariableNode: aNode [

	^ self visitLocalVariableNode: aNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitThisContextNode: aThisContextNode [
	^ self visitVariableNode: aThisContextNode
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitUnreachableStatement: anUnreachableStatement [
	
	^ self visitEnglobingErrorNode: anUnreachableStatement
]

{ #category : #visiting }
RBProgramNodeVisitor >> visitVariableNode: aVariableNode [
	^ aVariableNode
]
