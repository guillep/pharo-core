"
Border supporting multiple ""sub-borders"".
"
Class {
	#name : #CompositeBorderStyle,
	#superclass : #SimpleBorderStyle,
	#instVars : [
		'borders'
	],
	#category : #'Morphic-Base-Borders'
}

{ #category : #comparing }
CompositeBorderStyle >> = aBorderStyle [
	"Check the sub-borders too"
	
	^super = aBorderStyle and: [
		self borders = aBorderStyle borders]
]

{ #category : #accessing }
CompositeBorderStyle >> borders [
	"Answer the value of borders"

	^ borders
]

{ #category : #accessing }
CompositeBorderStyle >> borders: anObject [
	"Set the value of borders"

	borders := anObject
]

{ #category : #accessing }
CompositeBorderStyle >> colorsAtCorners [
	"Return the colors of the first border."
	
	^self borders first colorsAtCorners
]

{ #category : #drawing }
CompositeBorderStyle >> frameRectangle: aRectangle on: aCanvas [
	"Draw each border in turn."
	
	|r|
	r := aRectangle.
	self borders do: [:b |
		b frameRectangle: r on: aCanvas.
		r := r insetBy: b width]
]

{ #category : #comparing }
CompositeBorderStyle >> hash [
	"Since #= is overridden."
	
	^super hash bitXor: self borders hash
]

{ #category : #testing }
CompositeBorderStyle >> isComposite [
	"Answer true."

	^true
]
