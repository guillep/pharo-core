"
FillStyle is an abstract base class for fills in the BalloonEngine.
"
Class {
	#name : #FillStyle,
	#superclass : #Object,
	#category : #'Graphics-Canvas-Fills'
}

{ #category : #converting }
FillStyle >> asColor [
	^self subclassResponsibility 
]

{ #category : #operating }
FillStyle >> fillRectangle: aRectangle on: aCanvas [
	"Fill the given rectangle on the given canvas with the receiver."
	
	aCanvas fillRectangle: aRectangle basicFillStyle: self
]

{ #category : #testing }
FillStyle >> isBitmapFill [
	^false
]

{ #category : #testing }
FillStyle >> isCompositeFill [
	"Answer whether the receiver is a composite fill.
	False by default."

	^false
]

{ #category : #testing }
FillStyle >> isGradientFill [
	^false
]

{ #category : #testing }
FillStyle >> isOrientedFill [
	"Return true if the receiver keeps an orientation (e.g., origin, direction, and normal)"
	^false
]

{ #category : #testing }
FillStyle >> isSolidFill [
	^false
]

{ #category : #testing }
FillStyle >> isTranslucent [
	^true "Since we don't know better"
]

{ #category : #testing }
FillStyle >> isTransparent [
	^false
]

{ #category : #converting }
FillStyle >> mixed: fraction with: aColor [
	^self asColor mixed: fraction with: aColor
]

{ #category : #accessing }
FillStyle >> scaledPixelValue32 [
	"Return a pixel value of depth 32 for the primary color in the fill style"
	^self asColor scaledPixelValue32
]
