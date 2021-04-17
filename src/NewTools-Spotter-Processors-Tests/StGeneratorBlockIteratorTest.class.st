Class {
	#name : #StGeneratorBlockIteratorTest,
	#superclass : #TestCase,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StGeneratorBlockIteratorTest >> testIteratorOnACalculatedCollectionReturnsOnlyFirst [

	| it m |
	 
	it := StGeneratorBlockIterator on: [ :aBlock | 
		SystemNavigation default allBehaviorsDo: [ :e | e methodsDo: aBlock ] ].	
	
	m := it next.
	
	self assert: m isNotNil.
	self assert: m isCompiledMethod.	
]

{ #category : #tests }
StGeneratorBlockIteratorTest >> testIteratorWithEmptyBlockIsAtEnd [
	| it |
	
	it := StGeneratorBlockIterator on: [ :aBlock |  ].
	self assert: it atEnd.
]

{ #category : #tests }
StGeneratorBlockIteratorTest >> testIteratorWithInfiniteBlockNotCallIfNotUsed [
	| it count |
	
	count := 0. 
	it := StGeneratorBlockIterator on: [ :aBlock | [aBlock value: count. count := count + 1] repeat ].	
	self assert: count equals: 0.
]

{ #category : #tests }
StGeneratorBlockIteratorTest >> testIteratorWithInfiniteBlockOnlyCallFirstTimes [
	| it count |
	
	count := 1. 
	it := StGeneratorBlockIterator on: [ :aBlock | [aBlock value: count. count := count + 1] repeat ].
	it next: 4.
	self assert: count equals: 5.
]

{ #category : #tests }
StGeneratorBlockIteratorTest >> testIteratorWithSingleElementIsAtEndAfterNext [
	| it |
	 
	it := StGeneratorBlockIterator on: [ :aBlock | aBlock value: 1 ].	
	it next.
	self assert: it atEnd.
]
