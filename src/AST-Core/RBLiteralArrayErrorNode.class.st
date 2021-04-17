"
This is a particular englobing node that is a literal array.
Exemple : #( literal array node )
Can be created by forgetting 
the closure : #( array node .
Forgetting the opening will be assumed to be a parentheses node.
"
Class {
	#name : #RBLiteralArrayErrorNode,
	#superclass : #RBEnglobingErrorNode,
	#category : #'AST-Core-Nodes - ErrorNodes'
}

{ #category : #construction }
RBLiteralArrayErrorNode class >> error: aToken withNodes: aCollection [
	"A RBLiteralArrayErrorNode can only be created from the opening token by choice.
	 Since the closure is a parentheses, the default assumption is to create a RBParenthesesErrorNode.
	 This could be change by an analysis of prior nodes."
	"If the collection is empty, there is only the token in the error."
	^aCollection isEmpty
		ifTrue: [ self new content: aCollection; start: aToken start; stop: aToken stop; errorMessage: ''')'' expected' ]
		ifFalse: [ self new content: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: ''')'' expected' ]
]

{ #category : #testing }
RBLiteralArrayErrorNode >> isLiteralArrayError [
	^true
]
