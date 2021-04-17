Class {
	#name : #GTSpotterStreamMock,
	#superclass : #Object,
	#instVars : [
		'objects'
	],
	#category : #'GT-Tests-Spotter'
}

{ #category : #adding }
GTSpotterStreamMock >> addObject: anObject inProcessor: aProcessor [
	objects add: anObject
]

{ #category : #initialization }
GTSpotterStreamMock >> initialize [
	super initialize.
	objects := OrderedCollection new.
]

{ #category : #accessing }
GTSpotterStreamMock >> objects [
	^ objects
]
