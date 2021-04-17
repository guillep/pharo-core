"
Deprecated. The design to change the class of RBVariableNode during name analysis was not a good one.

 We now instead annotate all RBVariableNode instances with a Variable object (see the inheritance Hierarchy of Variable).

 The visitor dispatches through the variable object, calling the visit methods that are specialised for the kind of Variable
"
Class {
	#name : #RBTemporaryNode,
	#superclass : #RBVariableNode,
	#category : #'Deprecated90-AST'
}

{ #category : #visiting }
RBTemporaryNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitTemporaryNode: self
]

{ #category : #generated }
RBTemporaryNode >> isTemp [

	self
		deprecated: 'Use #isTempVariable instead'
		transformWith: '`@rec isTemp' -> '`@rec isTempVariable'.
	^ self isTempVariable
]
