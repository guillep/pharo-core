Class {
	#name : #Person,
	#superclass : #Object,
	#traits : 'TEquality',
	#classTraits : 'TEquality classTrait',
	#instVars : [
		'name',
		'age'
	],
	#category : #'Equals-Examples'
}

{ #category : #comparing }
Person class >> instVarNamesForEqualityComparison [
	^#(age)
]

{ #category : #'instance-creation' }
Person class >> name: aString age: positiveInt [
	^self new
		name: aString;
		age: positiveInt;
		yourself
]

{ #category : #comparing }
Person >> = anObject [ 
	self species = anObject species ifFalse: [^false].
	^self valuesToCompareForEquality = anObject valuesToCompareForEquality
]

{ #category : #accessing }
Person >> age [
	^ age
]

{ #category : #accessing }
Person >> age: anObject [
	age := anObject
]

{ #category : #comparing }
Person >> hash [
	^self valuesToCompareForEquality inject: self species hash into: [:hash :comparisonValue|
		(hash bitXor: comparisonValue hash) hashMultiply]

]

{ #category : #accessing }
Person >> name [
	^ name
]

{ #category : #accessing }
Person >> name: anObject [
	name := anObject
]
