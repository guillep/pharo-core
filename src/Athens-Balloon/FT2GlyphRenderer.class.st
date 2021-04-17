"
i am used to render freetype glyphs using balloon primitives.
"
Class {
	#name : #FT2GlyphRenderer,
	#superclass : #GlyphRenderer,
	#instVars : [
		'pixelSize',
		'form',
		'blt',
		'matrix',
		'translation',
		'penX',
		'penY',
		'slot',
		'surface',
		'colorMap',
		'bitmapX',
		'bitmapY',
		'descend',
		'origin',
		'currentColor',
		'font'
	],
	#pools : [
		'FT2Constants'
	],
	#category : #'Athens-Balloon-Text'
}

{ #category : #'instance creation' }
FT2GlyphRenderer class >> forFont: aFont surface: aSurface [
	^ self new initForFont: aFont surface: aSurface
]

{ #category : #private }
FT2GlyphRenderer >> clearBitmap [
	
	form bits atAllPut: 0.

]

{ #category : #accessing }
FT2GlyphRenderer >> form [
	^ form
]

{ #category : #accessing }
FT2GlyphRenderer >> getAdvance [
	"aPoint is a text origin in user's coordinate system,
	and anvance is accumulated advance came from another renderer instance, expressed in surface's coordinate system"

	| pt |
	pt := (penX/64.0) @ (penY/64.0) - origin.

	^ pt
]

{ #category : #initialization }
FT2GlyphRenderer >> initForFont: aFont surface: aSurface [

	self assert: (aFont class == FreeTypeFont).
	
	surface := aSurface.
	font := aFont.
	slot := SimpleTextGlyphInfo new.
	
	pixelSize := font pixelSize rounded.

	blt := BitBlt toForm: surface form.

	self loadSurfaceTransform.

	colorMap := Bitmap new: 256.
	
	blt 
		sourceForm: form;
		sourceX: 0;
		sourceY: 0;
		destOrigin: 0@0;
		sourceOrigin: 0@0;
		halftoneForm: nil;
		combinationRule: 24;
		width: form width;
		height: form height;
		colorMap: colorMap;
		clipRect: surface clipRect.
	
	translation := IntegerArray new: 2.

]

{ #category : #private }
FT2GlyphRenderer >> loadSlotInfo [
	slot loadFrom: font face.
]

{ #category : #private }
FT2GlyphRenderer >> loadSurfaceTransform [
	| m org xaxis yaxis sum xmin xmax ymin ymax formW formH fix face bbox |
	
	face := font face.

	face 
		setPixelWidth: pixelSize height: pixelSize.
	
	bbox := face bbox.
	m := surface pathTransform copy transposed.

	org := m transform: 0@0.
	xaxis := (m transform: bbox right - bbox left * pixelSize / face unitsPerEm @ 0) - org.
	yaxis := (m transform: 0 @ (bbox bottom - bbox top * pixelSize / face unitsPerEm)) - org.
	sum := xaxis + yaxis.
	
	xmin := 0 min: ((xaxis x min: yaxis x) min: sum x).
	ymin := 0 min: ((xaxis y min: yaxis y) min: sum y).
	xmax := 0 max: ((xaxis x max: yaxis x) max: sum x).
	ymax := 0 max: ((xaxis y max: yaxis y) max: sum y).

	formW := (xmax - xmin) ceiling + 1.
	formH := (ymax - ymin) ceiling  + 1.

" freetype 'zero' points to bottom-left point on form" 

	"calculate bitmap translation relative to top-left corner of glyph"
	bitmapX := (yaxis x negated + xmin * 64.0) rounded.
	bitmapY := (xaxis y negated + ymin * 64.0) rounded.

	descend := 0 @  ((face bbox height -  face bbox bottom  * pixelSize / face unitsPerEm) +1).
	descend := (m transform: descend) - org.
	descend := descend + (xmin negated@(ymin negated)).
	descend := (descend * 64 ) rounded.

	form := Form extent: formW @ formH depth: 8.

	blt 
		sourceForm: form;
		width: form width;
		height: form height.

	"prepare transformation matrix for freetype"
	
	matrix := IntegerArray new: 4.

	"values in matrix are 16.16 fixed point floating values" 
	fix := 65536. "(2 raisedTo: 16)."
	
	matrix 
		at: 1 put: (m sx * fix) rounded;
		at: 2 put: (m shx * fix) rounded;
		at: 3 put: (m shy * fix) rounded;
		at: 4 put: (m sy * fix) rounded.


]

{ #category : #private }
FT2GlyphRenderer >> loadUnicode: unicode [

	| flags face |
	
	face := font face.

"	hintingFlags := FreeTypeSettings current hintingFlags."
	flags :=  LoadNoBitmap bitOr: 2 "hintingFlags".
"	bitOr:( LoadIgnoreTransform  bitOr: 2 ). "
	face primLoadCharacter: unicode flags: flags.

	self loadSlotInfo.

]

{ #category : #private }
FT2GlyphRenderer >> pixelValue32Of: aColor [ 
	^ aColor pixelWordForDepth: 32
]

{ #category : #rendering }
FT2GlyphRenderer >> renderGlyphsIn: text from: start to: stop [
	| face |
	face := font face.
"	face
		setPixelWidth: pixelSize height: pixelSize.
"
	start to: stop do: [:i | | bx by |
		
		bx := penX + bitmapX.
		by := penY + bitmapY.

		"add a small shift, to incorporate subpixel position"
		
		translation at: 1 put: descend x + (bx bitAnd: 2r111111).
		translation at: 2 put: descend y - (by bitAnd: 2r111111). 

		face primSetTransform: matrix delta: translation.

		self loadUnicode: (text at: i) asUnicode.
	
		self clearBitmap.
		face renderGlyphIntoForm: form.

		blt
			destX: bx >> 6;
			destY: by >> 6;
			copyBits.

	"increment x by horizontal advance"
		penX := penX + slot advanceX.
		penY := penY - slot advanceY.

	].


]

{ #category : #accessing }
FT2GlyphRenderer >> setColor: color [
	"Set the color which will be used to render glyphs."
	
	| clr rgb alpha |
	currentColor = color ifTrue: [ ^ self ].
	currentColor := color.
	clr := self pixelValue32Of: color. 
	rgb := clr bitAnd: 16rFFFFFF.
	alpha := clr >> 24.
	
 	0 to: 255 do:[:i | | a |
		a :=  (i+1) * alpha bitAnd: 16rFF00.
		colorMap at: i+1 put: ( (a<<16) + rgb ).
	].

"	colorMap at: 1 put: (Color red  alpha: 0.1) pixelValue32."

]

{ #category : #private }
FT2GlyphRenderer >> setPosition: aPoint advance: advancePt baseline: baselineOffset [
	"aPoint is a text origin in user's coordinate system,
	and andvance is accumulated advance came from another renderer instance, expressed in surface's coordinate system"

	| pt offset |
	
	offset :=  baselineOffset - font getPreciseAscent "(font face ascender  * pixelSize / font face unitsPerEm)".

	pt := aPoint + (0@offset).
	pt := surface pathTransform transform: pt.
	origin := pt.
	pt := pt + advancePt.
	
	"remember the origin, so on #getAdvance , we will answer the current advance for renderer in surface coordinate system"
	
"	2 raisedTo: 6 "
	penX := (pt x * 64) rounded.
	penY := (pt y * 64) rounded.


]
