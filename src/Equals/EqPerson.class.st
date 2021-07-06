Class {
	#name : #EqPerson,
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
EqPerson class >> instVarNamesForEqualityComparison [
	^#(age)
]

{ #category : #'instance-creation' }
EqPerson class >> name: aString age: positiveInt [
	^self new
		name: aString;
		age: positiveInt;
		yourself
]

{ #category : #comparing }
EqPerson >> = anObject [ 
	self species = anObject species ifFalse: [^false].
	^self valuesToCompareForEquality = anObject valuesToCompareForEquality
]

{ #category : #accessing }
EqPerson >> age [
	^ age
]

{ #category : #accessing }
EqPerson >> age: anObject [
	age := anObject
]

{ #category : #comparing }
EqPerson >> hash [
	^self valuesToCompareForEquality inject: self species hash into: [:hash :comparisonValue|
		(hash bitXor: comparisonValue hash) hashMultiply]

]

{ #category : #accessing }
EqPerson >> name [
	^ name
]

{ #category : #accessing }
EqPerson >> name: anObject [
	name := anObject
]
