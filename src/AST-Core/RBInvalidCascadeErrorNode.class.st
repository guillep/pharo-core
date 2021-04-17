Class {
	#name : #RBInvalidCascadeErrorNode,
	#superclass : #RBEnglobingErrorNode,
	#category : #'AST-Core-Nodes - ErrorNodes'
}

{ #category : #'as yet unclassified' }
RBInvalidCascadeErrorNode >> cascade [
	
	^ content first
]
