Class {
	#name : #StGeneratorIteratorTest,
	#superclass : #TestCase,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StGeneratorIteratorTest >> testCollectionWithSingleElementReturnsIt [
	| gen |
	
	gen := StCollectionIterator on: #(1).
	self assert: gen next equals: 1
]

{ #category : #tests }
StGeneratorIteratorTest >> testCollectionWithSingleManyElementsReturnsTheRequested [
	| gen |
	
	gen := StCollectionIterator on: #(1 2 3 4 5 6 7 8 9 10).
	
	self assert: gen next equals: 1.
	self assert: gen next equals: 2.
	self assert: gen next equals: 3.
]

{ #category : #tests }
StGeneratorIteratorTest >> testCollectionWithSingleManyElementsReturnsTheRequestedInCollection [
	| gen |
	
	gen := StCollectionIterator on: #(1 2 3 4 5 6 7 8 9 10).
	self assertCollection: (gen next:3) hasSameElements: #(1 2 3).

]

{ #category : #tests }
StGeneratorIteratorTest >> testCollectionWithSingleWithALotOfElementsReturnsTheRequestedInCollection [
	| gen |
	
	gen := StCollectionIterator on: (1 to: 10**99).
	self assertCollection: (gen next:3) hasSameElements: #(1 2 3).

]

{ #category : #tests }
StGeneratorIteratorTest >> testEmptyCollectionIsAtEnd [
	| gen |
	
	gen := StCollectionIterator on: #().
	self assert: gen atEnd
]

{ #category : #tests }
StGeneratorIteratorTest >> testResetRestartsIterationOnTheCollection [
	| gen |
	
	gen := StCollectionIterator on: #(1 2 3 4 5 6 7 8 9 10).
	
	self assertCollection: (gen next:3) hasSameElements: #(1 2 3).
	gen reset.
	self assertCollection: (gen next:3) hasSameElements: #(1 2 3).
	
]
