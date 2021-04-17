"
Gradient fill style that uses proper alpha-aware interpolation.
"
Class {
	#name : #InterpolatedGradientFillStyle,
	#superclass : #GradientFillStyle,
	#category : #'Graphics-Canvas-Fills'
}

{ #category : #private }
InterpolatedGradientFillStyle >> computePixelRampOfSize: length [
	"Compute the pixel ramp in the receiver."
	
	| bits ramp lastColor lastIndex lastWord |
	ramp := colorRamp asSortedCollection:[:a1 :a2| a1 key < a2 key].
	bits := Bitmap new: length.
	lastColor := ramp first value.
	lastWord := self pixelWord32Of: lastColor .
	lastIndex := 0.
	ramp do:[:assoc| | distance nextColor theta nextWord nextIndex step |
		nextIndex := (assoc key * length) rounded.
		nextColor := assoc value.
		nextWord := nextColor pixelWord32.
		distance := nextIndex - lastIndex.
		distance = 0 ifTrue: [distance := 1].
		step := 1.0 / distance.
		theta := 0.0.
		lastIndex+1 to: nextIndex do: [:i|
			theta := theta + step.
			bits at: i put: (self interpolatedAlphaMix: theta of: lastWord and: nextWord)].
		lastIndex := nextIndex.
		lastColor := nextColor.
		lastWord := nextWord].
	lastIndex+1 to: length do: [:i| bits at: i put: lastWord].
	^bits
]

{ #category : #private }
InterpolatedGradientFillStyle >> interpolatedAlphaMix: ratio of: rgba1 and: rgba2 [
	"Answer a proper interpolated value between two RGBA color words.
	Theta is 0..1.."

	| a1 a2 ra ira rgb1 rgb2 alpha br1 br2 bg1 bg2 bb1 bb2 result |
	a1 := rgba1 bitShift: -24. a2 := rgba2 bitShift: -24.
	alpha := ratio * (a2 - a1) + a1.
	ra := ratio * alpha.
	ira := (1.0 - ratio) * alpha.
	rgb1 := rgba1 bitAnd: 16rFFFFFF. rgb2 := rgba2 bitAnd: 16rFFFFFF.
	br1 := (rgb1 bitAnd: 255). br2 := (rgb2 bitAnd: 255).
	bg1 := ((rgb1 bitShift:  -8) bitAnd: 255). bg2 := ((rgb2 bitShift: -8) bitAnd: 255).
	bb1 := ((rgb1 bitShift: -16) bitAnd: 255). bb2 := ((rgb2 bitShift: -16) bitAnd: 255).
	result :=  (ra * br2 + (ira * br1)) rounded // 255.
	result :=  result bitOr: ((ra * bg2 + (ira * bg1)) rounded // 255 bitShift: 8).
	result :=  result bitOr: ((ra * bb2 + (ira * bb1)) rounded // 255 bitShift: 16).
	^result bitOr: (alpha rounded bitShift: 24)
]

{ #category : #private }
InterpolatedGradientFillStyle >> pixelWord32Of: aColor [ 
	"Returns an integer representing the bits that appear in a single pixel of this color in a Form of depth 32.
	Transparency: The pixel value zero is reserved for transparent. For depths greater than 8, black maps to the darkest possible blue.
	Just a little quicker if we are dealing with RGBA colors at 32 bit depth."
	| val rgb |
	rgb := aColor privateRGB .
	"eight bits per component; top 8 bits set to all ones (opaque alpha)"
	val := LargePositiveInteger new: 4.
	val at: 3 put: ((rgb bitShift: -22) bitAnd: 16rFF).
	val at: 2 put: ((rgb bitShift: -12) bitAnd: 16rFF).
	val at: 1 put: ((rgb bitShift: -2) bitAnd: 16rFF).
	val = 0 ifTrue: [val at: 1 put: 1].  "closest non-transparent black"
	val at: 4 put: self alpha.  "opaque alpha"
	^val

]
