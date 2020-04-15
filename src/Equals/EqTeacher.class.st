Class {
	#name : #EqTeacher,
	#superclass : #EqPerson,
	#instVars : [
		'experience'
	],
	#category : #'Equals-Examples'
}

{ #category : #comparing }
EqTeacher class >> instVarNamesForEqualityComparison [
	^super instVarNamesForEqualityComparison copyWith: #experience
]

{ #category : #accessing }
EqTeacher >> experience [
	^ experience
]

{ #category : #accessing }
EqTeacher >> experience: anObject [
	experience := anObject
]

{ #category : #initialize }
EqTeacher >> initialize [
	super initialize.
	self experience: 0
]
