"
BorderStyle supporting general (potentially composite) fillstyles. 
"
Class {
	#name : #FillBorderStyle,
	#superclass : #SimpleBorderStyle,
	#instVars : [
		'fillStyle'
	],
	#category : #'Morphic-Base-Borders'
}

{ #category : #geometry }
FillBorderStyle >> borderRectsFor: aRectangle [
	"Answer a collection of rectangles to fill.
	Just four here for a rectangular border."

	|rTop rBottom rLeft rRight w|
	w := self width.
	rTop := aRectangle topLeft corner: aRectangle right @ (aRectangle top + w).
	rBottom := aRectangle left @ (aRectangle bottom - w) corner: aRectangle bottomRight.
	rLeft := aRectangle left @ (aRectangle top + w) corner: aRectangle left + w @ (aRectangle bottom - w).
	rRight := aRectangle right - w @ (aRectangle top + w) corner: aRectangle right @ (aRectangle bottom - w).
	^{rTop. rBottom. rLeft. rRight}
]

{ #category : #accessing }
FillBorderStyle >> fillStyle [
	"Answer the value of fillStyle"

	^fillStyle ifNil: [self color]
]

{ #category : #accessing }
FillBorderStyle >> fillStyle: anObject [
	"Set the value of fillStyle"

	fillStyle := anObject.
	anObject ifNotNil: [self baseColor: anObject asColor]
]

{ #category : #drawing }
FillBorderStyle >> frameRectangle: aRectangle on: aCanvas [
	"Fill the border areas with the fill style, clipping for each segment."
	
	(self borderRectsFor: aRectangle) do: [:r |
		aCanvas
			fillRectangle: r
			fillStyle: self fillStyle]
]

{ #category : #testing }
FillBorderStyle >> hasFillStyle [
	"Answer true."

	^true
]
