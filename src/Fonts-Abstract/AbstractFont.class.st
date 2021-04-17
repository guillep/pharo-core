"
The abstract class AbstractFont defines the generic interface that all fonts need to implement.
"
Class {
	#name : #AbstractFont,
	#superclass : #Object,
	#category : #'Fonts-Abstract-Base'
}

{ #category : #emphasis }
AbstractFont class >> emphasisStringFor: emphasisCode [
	"Answer a translated string that represents the attributes given in emphasisCode."

	| emphases |
	emphasisCode = 0 ifTrue: [ ^'Normal' translated ].

	emphases := (IdentityDictionary new)
						at: 1 put: 'Bold' translated;
						at: 2 put: 'Italic' translated;
						at: 4 put: 'Underlined' translated;
						at: 8 put: 'Narrow' translated;
						at: 16 put: 'StruckOut' translated;
						yourself.

	^String streamContents: [ :s | | bit |
		bit := 1.
		[ bit < 32 ] whileTrue: [ | code |
			code := emphasisCode bitAnd: bit.
			code isZero ifFalse: [ s nextPutAll: (emphases at: code); space ].
			bit := bit bitShift: 1 ].
		s position isZero ifFalse: [ s skip: -1 ]]
]

{ #category : #'class initialization' }
AbstractFont class >> initialize [

	TextStyle addDependent: self
]

{ #category : #testing }
AbstractFont class >> isAbstract [ 

	^self == AbstractFont
]

{ #category : #updating }
AbstractFont class >> update: anAspect [

	anAspect == #textDPIChanged ifTrue: [
		AbstractFont allSubInstancesDo: [ :font | font pixelsPerInchChanged ]].
]

{ #category : #measuring }
AbstractFont >> approxWidthOfText: aText [ 
	"Return the width of aText -- quickly, and a little bit dirty. Used by lists morphs containing Text objects to get a quick, fairly accurate measure of the width of a list item."
	| w |
	(aText isNil or: [ aText size = 0 ]) ifTrue: [ ^ 0 ].
	w := self widthOfString: aText asString.

	"If the text has no emphasis, just return the string size.  If it is empasized, 
    just approximate the width by adding about 20% to the width"
	((aText runLengthFor: 1) = aText size and: [ (aText emphasisAt: 1) = 0 ]) 
		ifTrue: [ ^ w ]
		ifFalse: [ ^ w * 6 // 5 ]
]

{ #category : #accessing }
AbstractFont >> ascent [

	self subclassResponsibility.

]

{ #category : #accessing }
AbstractFont >> ascentOf: aCharacter [

	^ self ascent.

]

{ #category : #accessing }
AbstractFont >> baseKern [
	^0
]

{ #category : #accessing }
AbstractFont >> basicAscentOf: aCharacter [

	^ self ascent.

]

{ #category : #accessing }
AbstractFont >> basicDescentOf: aCharacter [

	^ self descent.

]

{ #category : #'glyph lookup' }
AbstractFont >> characterFormAt: aCharacter [
	^ nil
]

{ #category : #'glyph lookup' }
AbstractFont >> characterRenderingOptimizedFormAt: aCharacter [
	"This method returns a version of the character form which is optimized for rendering
	through an accelerated alpha blending equation in the style of the OpenGL glBlendFuncSeparate."

	^ (self characterFormAt: aCharacter) 
			ifNotNil: [:form | form invertedAndAlphaMultiplied]
]

{ #category : #accessing }
AbstractFont >> characterToGlyphMap [
	"Return the character to glyph mapping table. If the table is not provided the character scanner will query the font directly for the width of each individual character."
	
	^nil
]

{ #category : #accessing }
AbstractFont >> derivativeFonts [
	^#()
]

{ #category : #accessing }
AbstractFont >> descent [

	self subclassResponsibility

]

{ #category : #accessing }
AbstractFont >> descentOf: aCharacter [

	^ self descent

]

{ #category : #displaying }
AbstractFont >> displayString: aString on: aDisplayContext from: startIndex to: stopIndex at: aPoint kern: kernDelta [
	"Draw the given string from startIndex to stopIndex 
	at aPoint on the (already prepared) display context."
	^self subclassResponsibility
]

{ #category : #displaying }
AbstractFont >> displayString: aString on: aDisplayContext from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: baselineY [
	"Draw the given string from startIndex to stopIndex at aPoint on the (already prepared) display context."
	
	^self subclassResponsibility
]

{ #category : #accessing }
AbstractFont >> familyName [
	"Answer the name to be used as a key in the TextConstants dictionary."
	
	^self subclassResponsibility
]

{ #category : #testing }
AbstractFont >> hasSubPixelAntiAliasing [

	^ false
]

{ #category : #accessing }
AbstractFont >> height [
	"Answer the height of the receiver, total of maximum extents of 
	characters above and below the baseline."

	^self subclassResponsibility
]

{ #category : #displaying }
AbstractFont >> installOn: aDisplayContext foregroundColor: foregroundColor backgroundColor: backgroundColor [
	"Install the receiver on the given DisplayContext (either BitBlt or Canvas) for further drawing operations."

	^ self subclassResponsibility
]

{ #category : #testing }
AbstractFont >> isFontSet [

	^ false

]

{ #category : #accessing }
AbstractFont >> isRegular [

	^ false
]

{ #category : #testing }
AbstractFont >> isTTCFont [

	^ false
]

{ #category : #accessing }
AbstractFont >> lineGrid [
	"Answer the relative space between lines"

	^self subclassResponsibility
]

{ #category : #accessing }
AbstractFont >> pixelSize [
	"Make sure that we don't return a Fraction"
	^ TextStyle pointsToPixels: self pointSize
]

{ #category : #notifications }
AbstractFont >> pixelsPerInchChanged [
	"The definition of TextStyle class>>pixelsPerInch has changed. Do whatever is necessary."
]

{ #category : #accessing }
AbstractFont >> pointSize [
	self subclassResponsibility
]

{ #category : #caching }
AbstractFont >> releaseCachedState [
	
]

{ #category : #metrics }
AbstractFont >> strikeoutThickness [
	^ 0
]

{ #category : #metrics }
AbstractFont >> strikeoutTop [
	^ 0
]

{ #category : #accessing }
AbstractFont >> textStyle [
	^ TextStyle actualTextStyles detect:
		[:aStyle | aStyle fontArray includes: self] ifNone: [ TextStyle fontArray: { self } ]
]

{ #category : #accessing }
AbstractFont >> textStyleName [
	"Answer the name to be used as a key in the TextConstants dictionary."
	^self familyName
]

{ #category : #metrics }
AbstractFont >> underlineThickness [
	^ 0
]

{ #category : #metrics }
AbstractFont >> underlineTop [
	^ 0
]

{ #category : #'development support' }
AbstractFont >> validate [
	"Concrete classes should override this to provide validation"
]

{ #category : #measuring }
AbstractFont >> widthOf: aCharacter [
	"Return the width of the given character"
	^self subclassResponsibility
]

{ #category : #measuring }
AbstractFont >> widthOfString: aString [
	"
		TextStyle default defaultFont widthOfString: 'zort' 21
	"
	aString ifNil: [^0].
	^self widthOfString: aString from: 1 to: aString size.

]

{ #category : #measuring }
AbstractFont >> widthOfString: aString from: firstIndex to: lastIndex [ 
	"Measure the length of the given string between start and stop index"
	| resultX |
	resultX := 0.
	firstIndex 
		to: lastIndex
		do: [ :i | resultX := resultX + (self widthOf: (aString at: i)) ].
	^ resultX
]

{ #category : #measuring }
AbstractFont >> widthOfStringOrText: aStringOrText [

    aStringOrText ifNil: [ ^0 ].
    ^aStringOrText isText
        ifTrue:[ self approxWidthOfText: aStringOrText ]
        ifFalse:[ self widthOfString: aStringOrText ] 
]

{ #category : #accessing }
AbstractFont >> xTable [
	"Return the xTable for the font. The xTable defines the left x-value for each individual glyph in the receiver. If such a table is not provided, the character scanner will ask the font directly for the appropriate width of each individual character."
	
	^nil
]
