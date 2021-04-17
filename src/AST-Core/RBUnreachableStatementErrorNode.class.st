Class {
	#name : #RBUnreachableStatementErrorNode,
	#superclass : #RBEnglobingErrorNode,
	#category : #'AST-Core-Nodes - ErrorNodes'
}

{ #category : #visiting }
RBUnreachableStatementErrorNode >> acceptVisitor: aVisitor [

	^ aVisitor visitUnreachableStatement: self
]
