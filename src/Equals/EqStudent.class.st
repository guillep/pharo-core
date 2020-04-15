Class {
	#name : #EqStudent,
	#superclass : #EqPerson,
	#instVars : [
		'level'
	],
	#category : #'Equals-Examples'
}

{ #category : #comparing }
EqStudent class >> instVarNamesForEqualityComparison [
	^super instVarNamesForEqualityComparison copyWith: #level
]

{ #category : #'initialize - release' }
EqStudent >> initialize [
	super initialize.
	self level: 1
]

{ #category : #accessing }
EqStudent >> level [
	^ level
]

{ #category : #accessing }
EqStudent >> level: anObject [
	level := anObject
]
