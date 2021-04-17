Class {
	#name : #RBUnfinishedStatementErrorNode,
	#superclass : #RBEnglobingErrorNode,
	#category : #'AST-Core-Nodes - ErrorNodes'
}

{ #category : #'as yet unclassified' }
RBUnfinishedStatementErrorNode >> isUnfinishedStatement [
	
	^ true
]

{ #category : #'as yet unclassified' }
RBUnfinishedStatementErrorNode >> statement [
	
	^ content first
]
