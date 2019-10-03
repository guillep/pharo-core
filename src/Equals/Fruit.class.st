Class {
	#name : #Fruit,
	#superclass : #Object,
	#traits : 'TEquality',
	#classTraits : 'TEquality classTrait',
	#instVars : [
		'stage'
	],
	#category : #'Equals-Examples'
}

{ #category : #comparing }
Fruit >> = anObject [ 
	self species = anObject species ifFalse: [^false].
	^self valuesToCompareForEquality = anObject valuesToCompareForEquality
]

{ #category : #staging }
Fruit >> beRipe [
	stage := #ripe
]

{ #category : #staging }
Fruit >> beRotten [
	stage := #rotten
]

{ #category : #staging }
Fruit >> beUnripe [
	stage := #unripe
]

{ #category : #accessing }
Fruit >> color [
	^self subclassResponsibility
]

{ #category : #comparing }
Fruit >> hash [
	^self valuesToCompareForEquality inject: self species hash into: [:hash :comparisonValue|
		(hash bitXor: comparisonValue hash) hashMultiply]

]

{ #category : #'initialize - release' }
Fruit >> initialize [
	super initialize.
	self beUnripe
]
