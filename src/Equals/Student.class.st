Class {
	#name : #Student,
	#superclass : #Person,
	#instVars : [
		'level'
	],
	#category : #'Equals-Examples'
}

{ #category : #'initialize - release' }
Student >> initialize [
	super initialize.
	self level: 1
]

{ #category : #accessing }
Student >> level [
	^ level
]

{ #category : #accessing }
Student >> level: anObject [
	level := anObject
]
