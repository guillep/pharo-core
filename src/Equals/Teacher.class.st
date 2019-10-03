Class {
	#name : #Teacher,
	#superclass : #Person,
	#instVars : [
		'experience'
	],
	#category : #'Equals-Examples'
}

{ #category : #accessing }
Teacher >> experience [
	^ experience
]

{ #category : #accessing }
Teacher >> experience: anObject [
	experience := anObject
]

{ #category : #initialize }
Teacher >> initialize [
	super initialize.
	self experience: 0
]
