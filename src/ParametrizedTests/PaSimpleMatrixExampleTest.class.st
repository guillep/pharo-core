"
This test executes 81 different cases. 
All the combinations in the matrix for the `item1`, `item2` and `collectionClass` parameters.

```
PaSimpleMatrixExampleTest class >> testParameters

	^ ParametrizedTestMatrix new
		forSelector: #item1 addOptions: { 1. 'a'. $c };
		forSelector: #item2 addOptions: { 2. 'b'. $d };
		forSelector: #collectionClass addOptions: 	{ Set. Bag. OrderedCollection }
```			

"
Class {
	#name : #PaSimpleMatrixExampleTest,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'collectionClass',
		'item1',
		'item2'
	],
	#category : #'ParametrizedTests-Examples'
}

{ #category : #'building suites' }
PaSimpleMatrixExampleTest class >> testParameters [

	^ ParametrizedTestMatrix new
		forSelector: #item1 addOptions: { 1. 'a'. $c };
		forSelector: #item2 addOptions: { 2. 'b'. $d };
		forSelector: #collectionClass addOptions: 	{ Set. Bag. OrderedCollection }
]

{ #category : #accessing }
PaSimpleMatrixExampleTest >> collectionClass [
	^ collectionClass
]

{ #category : #accessing }
PaSimpleMatrixExampleTest >> collectionClass: anObject [
	collectionClass := anObject
]

{ #category : #accessing }
PaSimpleMatrixExampleTest >> item1 [
	^ item1
]

{ #category : #accessing }
PaSimpleMatrixExampleTest >> item1: anObject [
	item1 := anObject
]

{ #category : #accessing }
PaSimpleMatrixExampleTest >> item2 [
	^ item2
]

{ #category : #accessing }
PaSimpleMatrixExampleTest >> item2: anObject [
	item2 := anObject
]

{ #category : #accessing }
PaSimpleMatrixExampleTest >> testAdd [
	
	| aCollection |
	aCollection := collectionClass new.
	aCollection add: item1.
	
	self assert: (aCollection includes: item1).
	self assert: aCollection size equals: 1.

	
]

{ #category : #accessing }
PaSimpleMatrixExampleTest >> testAddAndRemove [
	
	| aCollection |
	aCollection := collectionClass new.
	aCollection add: item1.
	aCollection add: item2.
	
	self assert: (aCollection includes: item1).
	self assert: aCollection size equals: 2.

	aCollection remove: item1.
	
	self deny: (aCollection includes: item1).
	self assert: aCollection size equals: 1.

]

{ #category : #accessing }
PaSimpleMatrixExampleTest >> testIncludes [
	
	| aCollection |
	aCollection := collectionClass new.
	aCollection add: item1.
	aCollection add: item2.
	
	self assert: (aCollection includes: item1).
	self assert: (aCollection includes: item2).
]
