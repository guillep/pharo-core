"
Border with customisable inner margin.
"
Class {
	#name : #MarginBorderStyle,
	#superclass : #SimpleBorderStyle,
	#instVars : [
		'margin'
	],
	#category : #'Morphic-Base-Borders'
}

{ #category : #accessing }
MarginBorderStyle >> drawLineFrom: startPoint to: stopPoint on: aCanvas [
	"Reduce the width by the margin."
	
	| lineColor |
	lineColor := (stopPoint truncated quadrantOf: startPoint truncated) > 2 
				ifTrue: [self topLeftColor]
				ifFalse: [self bottomRightColor].
	aCanvas 
		line: startPoint
		to: stopPoint 
		width: (self width - self margin max: 0)
		color: lineColor
]

{ #category : #accessing }
MarginBorderStyle >> frameRectangle: aRectangle on: aCanvas [
	"Reduce width by the margin."
	
	aCanvas frameAndFillRectangle: aRectangle
		fillColor: Color transparent
		borderWidth: (self width - self margin max: 0)
		topLeftColor: self topLeftColor
		bottomRightColor: self bottomRightColor.
]

{ #category : #initialization }
MarginBorderStyle >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		margin: 0
]

{ #category : #accessing }
MarginBorderStyle >> margin [
	"Answer the value of margin"

	^ margin
]

{ #category : #accessing }
MarginBorderStyle >> margin: anObject [
	"Set the value of margin"

	margin := anObject
]
