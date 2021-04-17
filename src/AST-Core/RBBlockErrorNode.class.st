"
This is a particular englobing node that is a Block.
Exemple : [ block node ]
Can be created by forgetting 
either the opening : block node ]
or the closure : [ block node .

"
Class {
	#name : #RBBlockErrorNode,
	#superclass : #RBEnglobingErrorNode,
	#category : #'AST-Core-Nodes - ErrorNodes'
}

{ #category : #construction }
RBBlockErrorNode class >> error: aToken withNodes: aCollection [
	"Analyses the token to identify if it's an opening or a closure."
	| message |
	message := ('[' = aToken value asString) ifTrue: [ ''']'' expected' ] 
										  				 ifFalse: [ '''['' expected' ].
	"If the collection is empty, there is only the token in the error."
	aCollection isEmpty
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aToken stop; errorMessage: message ].
	"If the collection is not empty, we have to sort where the node begins and where it ends."
	^message = ''']'' expected'
		ifTrue: [ self new content: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: message ]
		ifFalse: [ self new content: aCollection; start: aCollection first start; stop: aToken stop; errorMessage: message ]
]

{ #category : #testing }
RBBlockErrorNode >> isBlockError [
	^true
]

{ #category : #testing }
RBBlockErrorNode >> repairCollectionFromStart [
	" The repair process goes through goes through the statements that are compatible with an array.
	  Begins with all statements included in the array and gets one of every time.
	  The removed statements are to be added in the sequence node."
	| collection result removedStatements |
	collection := self content statements.
	result := OrderedCollection new.
	removedStatements := OrderedCollection new.
	[ collection isNotNil ] 
		whileTrue: [ | statements node | 
						 statements := OrderedCollection new.
						 node :=  RBArrayNode statements: collection.
						 node start: self start.
					 	 statements add: node .
						 result add: statements, removedStatements.
						 removedStatements addFirst: collection last.
						 collection removeLast. ].
	result add: removedStatements.
	^collection.
	
]
