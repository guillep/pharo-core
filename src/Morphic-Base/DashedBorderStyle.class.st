"
Border style supporting dashed lines of configurable patterns and colours.
"
Class {
	#name : #DashedBorderStyle,
	#superclass : #SimpleBorderStyle,
	#instVars : [
		'dashColors',
		'dashLengths'
	],
	#category : #'Morphic-Base-Borders'
}

{ #category : #'instance creation' }
DashedBorderStyle class >> width: width dashColors: cols dashLengths: lens [
	"Answer a new instance of the receiver with the given
	width, colours and lengths."
	
	^self new
		width: width;
		dashColors: cols dashLengths: lens
]

{ #category : #accessing }
DashedBorderStyle >> dashColors [
	"Answer the value of dashColors"

	^ dashColors
]

{ #category : #accessing }
DashedBorderStyle >> dashColors: anObject [
	"Set the value of dashColors"

	dashColors := anObject
]

{ #category : #accessing }
DashedBorderStyle >> dashColors: cols dashLengths: lens [
	"Set the colours and lengths."

	cols size = lens size ifFalse: [self error: 'Colors and Lengths must have the same size'].
	self
		dashColors: cols;
		dashLengths: lens
]

{ #category : #accessing }
DashedBorderStyle >> dashLengths [
	"Answer the value of dashLengths"

	^ dashLengths
]

{ #category : #accessing }
DashedBorderStyle >> dashLengths: anObject [
	"Set the value of dashLengths"

	dashLengths := anObject
]

{ #category : #drawing }
DashedBorderStyle >> frameRectangle: aRectangle on: aCanvas [
	"Frame the given rectangle on aCanvas"
	
	(aRectangle width < self width or: [aRectangle height < self width])
		ifTrue: [^self]." don't do if too small"
	aCanvas
		frameRectangle: aRectangle
		width: self width
		colors: self dashColors
		dashes: self dashLengths
]

{ #category : #initialization }
DashedBorderStyle >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		dashColors: {Color black. Color white};
		dashLengths: #(1 1)
]

{ #category : #accessing }
DashedBorderStyle >> style [
	"Answer #dashed."
	
	^#dashed
]
