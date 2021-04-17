"
Simple fillstyle that draws a (potentially translucent) form at the specified origin. Direction and normal are unused.
"
Class {
	#name : #ImageFillStyle,
	#superclass : #OrientedFillStyle,
	#instVars : [
		'form',
		'extent',
		'offset'
	],
	#category : #'Graphics-Canvas-Fills'
}

{ #category : #'instance creation' }
ImageFillStyle class >> form: aForm [
	"Answer a new instance of the receiver with the given form."

	^self new form: aForm
]

{ #category : #comparing }
ImageFillStyle >> = anOrientedFillStyle [
	"Answer whether equal."

	^super = anOrientedFillStyle
		and: [(self form = anOrientedFillStyle form) and: [ offset = anOrientedFillStyle offset]]
]

{ #category : #converting }
ImageFillStyle >> asColor [
	"Answer transparent, no other reasonable interpretation."
	
	^Color transparent
]

{ #category : #accessing }
ImageFillStyle >> extent [
	"Answer the value of extent"

	^ extent
]

{ #category : #accessing }
ImageFillStyle >> extent: anObject [
	"Set the value of extent"

	extent := anObject
]

{ #category : #accessing }
ImageFillStyle >> form [
	"Answer the value of form"

	^ form
]

{ #category : #accessing }
ImageFillStyle >> form: aForm [
	"Set the value of form"

	form := aForm.
	self direction: aForm extent
]

{ #category : #comparing }
ImageFillStyle >> hash [
	"Hash is implemented because #= is implemented."
	
	^super hash bitXor: self form hash
]

{ #category : #initialization }
ImageFillStyle >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		origin: 0@0;
		offset: 0@0
]

{ #category : #accessing }
ImageFillStyle >> offset [
	"Answer the value of offset"

	^ offset
]

{ #category : #accessing }
ImageFillStyle >> offset: anObject [
	"Set the value of offset"

	offset := anObject
]
