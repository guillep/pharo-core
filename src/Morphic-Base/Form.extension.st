Extension { #name : #Form }

{ #category : #'*Morphic-Base' }
Form >> asAlphaImageMorph [

	^ AlphaImageMorph new image: self
]

{ #category : #'*Morphic-Base' }
Form >> asMorph [
	^ImageMorph new form: self
]

{ #category : #'*Morphic-Base' }
Form >> floodFillTolerance [
	^ self class floodFillTolerance
]

{ #category : #'*Morphic-Base' }
Form class >> floodFillTolerance [
	^ FloodFillTolerance ifNil: [FloodFillTolerance := 0.0]
]

{ #category : #'*Morphic-Base' }
Form >> iconOrThumbnailOfSize: aNumberOrPoint [ 
	"Answer an appropiate form to represent the receiver"
	^ self scaledIntoFormOfSize: aNumberOrPoint
]

{ #category : #'*Morphic-Base' }
Form >> scaledByDisplayScaleFactor [
	
	^ self scaledToSize: self extent * self currentWorld displayScaleFactor.

]

{ #category : #'*Morphic-Base' }
Form >> scaledIntoFormOfSize: aNumberOrPoint [ 
	"Scale and center the receiver into a form of a given size"

	| extent scale scaledForm result |

	extent := aNumberOrPoint asPoint.
	extent = self extent ifTrue: [^ self].

	(self height isZero or: [self width isZero])
		ifTrue: [^ Form extent: extent depth: self depth].

	scale := extent y / self height min: extent x / self width.
	scaledForm := self
				magnify: self boundingBox
				by: scale
				smoothing: 8.

	result := Form extent: extent depth: 32.
	result getCanvas
		translucentImage: scaledForm
		at: extent - scaledForm extent // 2.

	^ result

]

{ #category : #'*Morphic-Base-Support' }
Form >> stencil [
	"return a 1-bit deep, black-and-white stencil of myself"

	| canvas |
	canvas := FormCanvas extent: self extent depth: 1.
	canvas fillColor: (Color white).

	canvas stencil: self at: 0@0  
				sourceRect: (Rectangle origin: 0@0 corner: self extent) color: Color black.

	^ canvas form

]
