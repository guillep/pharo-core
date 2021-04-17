"
A rectangular array of pixels, used for holding images.  All pictures, including character images are Forms.  The depth of a Form is how many bits are used to specify the color at each pixel.  The actual bits are held in a Bitmap, whose internal structure is different at each depth.  Class Color allows you to deal with colors without knowing how they are actually encoded inside a Bitmap.
	  The supported depths (in bits) are 1, 2, 4, 8, 16, and 32.  The number of actual colors at these depths are: 2, 4, 16, 256, 32768, and 16 million.
	Forms are indexed starting at 0 instead of 1; thus, the top-left pixel of a Form has coordinates 0@0.
	Forms are combined using BitBlt.  See the comment in class BitBlt.  Forms that repeat many times to fill a large destination are InfiniteForms.

	colorAt: x@y		Returns the abstract Color at this location
	displayAt: x@y		shows this form on the screen
	displayOn: aMedium at: x@y	shows this form in a Window, a Form, or other DisplayMedium
	fillColor: aColor		Set all the pixels to the color.
	edit		launch an editor to change the bits of this form.
	pixelValueAt: x@y	The encoded color.  The encoding depends on the depth.

"
Class {
	#name : #Form,
	#superclass : #DisplayMedium,
	#instVars : [
		'bits',
		'width',
		'height',
		'depth',
		'offset'
	],
	#classVars : [
		'FloodFillTolerance'
	],
	#category : #'Graphics-Display Objects-Forms'
}

{ #category : #'mode constants' }
Form class >> and [
	"Answer the integer denoting the logical 'and' combination rule."

	^1
]

{ #category : #'mode constants' }
Form class >> blend [
	"Answer the integer denoting BitBlt's alpha blend combination rule."
	^24
]

{ #category : #'mode constants' }
Form class >> blendAlpha [
	"Answer the integer denoting BitBlt's blend-with-constant-alpha rule."

	^ 30
]

{ #category : #'instance creation' }
Form class >> dotOfSize: diameter [
	"Create a form which contains a round black dot."
	| radius form bb rect centerX centerY centerYBias centerXBias radiusSquared xOverY maxy dx |
	radius := diameter//2.
	form := self extent: diameter@diameter offset: (0@0) - (radius@radius).	
	bb := (BitBlt toForm: form)
		sourceX: 0; sourceY: 0;
		combinationRule: Form over;
		fillColor: Color black.
	rect := form boundingBox.
	centerX := rect center x.
	centerY := rect center y.
	centerYBias := rect height odd ifTrue: [0] ifFalse: [1].
	centerXBias := rect width odd ifTrue: [0] ifFalse: [1].
	radiusSquared := (rect height asFloat / 2.0) squared - 0.01.
	xOverY := rect width asFloat / rect height asFloat.
	maxy := rect height - 1 // 2.

	"First do the inner fill, and collect x values"
	0 to: maxy do:
		[:dy |
		dx := ((radiusSquared - (dy * dy) asFloat) sqrt * xOverY) truncated.
		bb	destX: centerX - centerXBias - dx
			destY: centerY - centerYBias - dy
			width: dx + dx + centerXBias + 1
			height: 1;
			copyBits.
		bb	destY: centerY + dy;
			copyBits].
	^ form
"
Time millisecondsToRun:
	[1 to: 20 do: [:i | (Form dotOfSize: i) displayAt: (i*20)@(i*20)]]
"
]

{ #category : #'mode constants' }
Form class >> erase [
	"Answer the integer denoting mode erase."

	^4
]

{ #category : #'mode constants' }
Form class >> erase1bitShape [
	"Answer the integer denoting mode erase."

	^ 26
]

{ #category : #'instance creation' }
Form class >> extent: extentPoint [
	"Answer an instance of me with a blank bitmap of depth 1."

	^ self extent: extentPoint depth: 1

]

{ #category : #'instance creation' }
Form class >> extent: extentPoint depth: bitsPerPixel [
	"Answer an instance of me with blank bitmap of the given dimensions and depth."

	^ self basicNew setExtent: extentPoint depth: bitsPerPixel

]

{ #category : #'instance creation' }
Form class >> extent: extentPoint depth: bitsPerPixel bits: aBitmap [
	"Answer an instance of me with blank bitmap of the given dimensions and depth."

	^ self basicNew setExtent: extentPoint depth: bitsPerPixel bits: aBitmap
]

{ #category : #'instance creation' }
Form class >> extent: extentPoint depth: bitsPerPixel fromArray: anArray offset: offsetPoint [ 
	"Answer an instance of me with a pixmap of the given depth initialized from anArray."

	^ (self extent: extentPoint depth: bitsPerPixel)
		offset: offsetPoint;
		initFromArray: anArray

]

{ #category : #'instance creation' }
Form class >> extent: extentPoint fromArray: anArray offset: offsetPoint [ 
	"Answer an instance of me of depth 1 with bitmap initialized from anArray."

	^ (self extent: extentPoint depth: 1)
		offset: offsetPoint;
		initFromArray: anArray

]

{ #category : #'instance creation' }
Form class >> extent: extentPoint fromStipple: fourNibbles [
	"Answer an instance of me with bitmap initialized from
	a repeating 4x4 bit stipple encoded in a 16-bit constant."
	
	^ (self extent: extentPoint depth: 1)
		initFromArray: ((1 to: 4) collect:
				[:i | | nibble | nibble := (fourNibbles bitShift: -4*(4-i)) bitAnd: 16rF.
				16r11111111 * nibble])  "fill 32 bits with each 4-bit nibble"

]

{ #category : #'instance creation' }
Form class >> extent: extentPoint offset: offsetPoint [ 
	"Answer an instance of me with a blank bitmap of depth 1."

	^ (self extent: extentPoint depth: 1) offset: offsetPoint

]

{ #category : #settings }
Form class >> floodFillTolerance: aFloat [
	(aFloat >= 0.0 and: [aFloat < 0.3])
		ifTrue: [FloodFillTolerance := aFloat]
		ifFalse: [FloodFillTolerance := 0.0]
]

{ #category : #'instance creation' }
Form class >> fromDisplay: aRectangle [ 
	"Answer an instance of me with bitmap initialized from the area of the 
	display screen defined by aRectangle."

	^ (self extent: aRectangle extent depth: Display depth)
		fromDisplay: aRectangle
]

{ #category : #'instance creation' }
Form class >> fromDisplay: aRectangle using: oldForm [
	"Like fromDisplay: only if oldForm is the right size, copy into it and answer it instead."

	^ (oldForm ~~ nil and: [ oldForm extent = aRectangle extent ])
		ifTrue: [ oldForm fromDisplay: aRectangle.
			oldForm ]
		ifFalse: [ self fromDisplay: aRectangle ]
]

{ #category : #'instance creation' }
Form class >> fromUser [
	"Answer an instance of me with bitmap initialized from the area of the 
	display screen designated by the user. The grid for selecting an area is 
	1@1."
	"self fromUser asMorph openInWorld"
	
	^self fromUser: 1 @ 1
]

{ #category : #'instance creation' }
Form class >> fromUser: gridPoint [
	"Answer an instance of me with bitmap initialized from the area of the 
	display screen designated by the user. The grid for selecting an area is 
	aPoint. Ensures that the returned form has positive extent."
	| rect |
	rect := Rectangle fromUser: gridPoint.
	^ self fromDisplay: (rect origin extent: (rect extent max: gridPoint))
]

{ #category : #'initialize-release' }
Form class >> initialize [
	SessionManager default registerGuiClassNamed: self name
]

{ #category : #'mode constants' }
Form class >> oldErase1bitShape [
	"Answer the integer denoting mode erase."

	^ 17
]

{ #category : #'mode constants' }
Form class >> oldPaint [
	"Answer the integer denoting the 'paint' combination rule."

	^16
]

{ #category : #'mode constants' }
Form class >> over [
	"Answer the integer denoting mode over."

	^3
]

{ #category : #'mode constants' }
Form class >> paint [
	"Answer the integer denoting the 'paint' combination rule."

	^25
]

{ #category : #'mode constants' }
Form class >> paintAlpha [
	"Answer the integer denoting BitBlt's paint-with-constant-alpha rule."

	^ 31
]

{ #category : #'mode constants' }
Form class >> reverse [
	"Answer the integer denoting mode reverse."

	^6
]

{ #category : #'system startup' }
Form class >> shutDown [  "Form shutDown"
	"Compress all instances in the system.  Will decompress on demand..."
	Form allInstancesDo: [:f | f hibernate].
	ColorForm allInstancesDo: [:f | f hibernate].
]

{ #category : #'mode constants' }
Form class >> under [
	"Answer the integer denoting mode under."

	^7
]

{ #category : #initialization }
Form >> allocateForm: extentPoint [
	"Allocate a new form which is similar to the receiver and can be used for accelerated blts"
	^Form extent: extentPoint depth: self nativeDepth
]

{ #category : #converting }
Form >> alphaMultiplied [
	^ (self asFormOfDepth: 32) collectColors: [ :c |
		| a |
		a := c alpha.
		Color r: c red * a g: c green * a b: c blue * a alpha: a
	]
]

{ #category : #converting }
Form >> as8BitColorForm [
	"Simple conversion of zero pixels to transparent.  Force it to 8 bits."

	| f map |
	f := ColorForm extent: self extent depth: 8.
	self displayOn: f at: self offset negated.
	map := Color indexedColors copy.
	map at: 1 put: Color transparent.
	f colors: map.
	f offset: self offset.
	^ f

]

{ #category : #converting }
Form >> asCursorForm [

	^ Form newFrom: self
]

{ #category : #converting }
Form >> asFormOfDepth: d [
	| newForm |
	d = self depth ifTrue:[^self].
	newForm := Form extent: self extent depth: d.
	(BitBlt toForm: newForm)
		colorMap: (self colormapIfNeededFor: newForm);
		copy: (self boundingBox)
		from: 0@0 in: self
		fillColor: nil rule: Form over.
	"Special case: For a 16 -> 32 bit conversion fill the alpha channel because it gets lost in translation."
	(self depth = 16 and:[d= 32]) ifTrue:[newForm fillAlpha: 255].
	^newForm
]

{ #category : #converting }
Form >> asGrayScale [
	"Assume the receiver is a grayscale image. Return a grayscale ColorForm computed by extracting the brightness levels of one color component. This technique allows a 32-bit Form to be converted to an 8-bit ColorForm to save space while retaining a full 255 levels of gray. (The usual colormapping technique quantizes to 8, 16, or 32 levels, which loses information.)"
	| f32 srcForm result map bb grays |
	self depth = 32 ifFalse: [
		f32 := Form extent: width@height depth: 32.
		self displayOn: f32.
		^ f32 asGrayScale].
	self unhibernate.
	srcForm := Form extent: (width * 4)@height depth: 8.
	srcForm bits: bits.
	result := ColorForm extent: width@height depth: 8.
	map := Bitmap new: 256.
	2 to: 256 do: [:i | map at: i put: i - 1].
	map at: 1 put: 1.  "map zero pixel values to near-black"
	bb := (BitBlt toForm: result)
		sourceForm: srcForm;
		combinationRule: Form over;
		colorMap: map.
	0 to: width - 1 do: [:dstX |
		bb  sourceRect: (((dstX * 4) + 2)@0 extent: 1@height);
			destOrigin: dstX@0;
			copyBits].

	"final BitBlt to zero-out pixels that were truely transparent in the original"
	map := Bitmap new: 512.
	map at: 1 put: 16rFF.
	(BitBlt toForm: result)
		sourceForm: self;
		sourceRect: self boundingBox;
		destOrigin: 0@0;
		combinationRule: Form erase;
		colorMap: map;
		copyBits.
	
	grays := (0 to: 255) collect: [:brightness | Color gray: brightness asFloat / 255.0].
	grays at: 1 put: Color transparent.
	result colors: grays.
	^ result

]

{ #category : #converting }
Form >> asGrayScaleWithAlpha [
	"Unlike asGrayScale, this method fully preserves the alpha channel and only desaturates the form(makes grayscale)."
	^ (self asFormOfDepth: 32) collectColors: [ :c |  |l|
		l := c luminance.
		Color r:l g: l b: l alpha: c alpha ]
]

{ #category : #converting }
Form >> asSourceForm [
	^self
]

{ #category : #'color mapping' }
Form >> balancedPatternFor: aColor [
	"Return the pixel word for representing the given color on the receiver"

	^ self hasNonStandardPalette
		ifTrue: [ self bitPatternFor: aColor ]
		ifFalse: [ self balancedPatternFor: aColor depth: self depth ]
]

{ #category : #'color mapping' }
Form >> balancedPatternFor: aColor depth: aDepth [ 
	 
	"A generalization of bitPatternForDepth: as it exists.  Generates a 2x2 stipple of color.
	The topLeft and bottomRight pixel are closest approx to this color"
	| pv1 pv2 mask1 mask2 pv3 c |
	
	aColor isTransparent ifTrue:[  ^ Bitmap with: 0 ].

	(depth 
		between: 4
		and: 16) ifFalse: [ ^ aColor bitPatternForDepth: depth ].
	
	pv1 := aColor pixelValueForDepth: depth.
	"
	Subtract error due to pv1 to get pv2.
	pv2 := (self - (err1 := (Color colorFromPixelValue: pv1 depth: depth) - self))
						pixelValueForDepth: depth.
	Subtract error due to 2 pv1's and pv2 to get pv3.
	pv3 := (self - err1 - err1 - ((Color colorFromPixelValue: pv2 depth: depth) - self))
						pixelValueForDepth: depth.
"
	"Above two statements computed faster by the following..."
	pv2 := (c := aColor - ((Color 
			colorFromPixelValue: pv1
			depth: depth) - aColor)) pixelValueForDepth: depth.
	pv3 := c + (c - (Color 
				colorFromPixelValue: pv2
				depth: depth)) pixelValueForDepth: depth.

	"Return to a 2-word bitmap that encodes a 2x2 stipple of the given pixelValues."
	mask1 := #(
		#-
		#-
		#-
		16843009
		#-
		#-
		#-
		65537
		#-
		#-
		#-
		#-
		#-
		#-
		#-
		1
	) at: depth.	"replicates every other 4 bits"	"replicates every other 8 bits"	"replicates every other 16 bits"
	mask2 := #(
		#-
		#-
		#-
		269488144
		#-
		#-
		#-
		16777472
		#-
		#-
		#-
		#-
		#-
		#-
		#-
		65536
	) at: depth.	"replicates the other 4 bits"	"replicates the other 8 bits"	"replicates the other 16 bits"
	^  Bitmap 
		with: mask1 * pv1 + (mask2 * pv2)
		with: mask1 * pv3 + (mask2 * pv1).
	
]

{ #category : #'color mapping' }
Form >> bitPatternFor: aColor [
	"Return the pixel word for representing the given color on the receiver"

	aColor isColor ifFalse: [ ^ aColor bitPatternForDepth: self depth ].
	^ self hasNonStandardPalette
		ifTrue: [ Bitmap with: (self pixelWordFor: aColor) ]
		ifFalse: [ aColor bitPatternForDepth: self depth ]
]

{ #category : #filling }
Form >> bitPatternForDepth: suspectedDepth [
	"Only called when a Form is being used as a fillColor.  Use a Pattern or InfiniteForm instead for this purpose.
	Interpret me as an array of (32/depth) Color pixelValues.  BitBlt aligns the first element of this array with the top scanline of the destinationForm, the second with the second, and so on, cycling through the color array as necessary."

	^ self
]

{ #category : #accessing }
Form >> bits [
	"Answer the receiver's Bitmap containing its bits."

	^ bits
]

{ #category : #accessing }
Form >> bits: aBitmap [ 
	"Reset the Bitmap containing the receiver's bits."

	bits := aBitmap
]

{ #category : #accessing }
Form >> bitsSize [
	| pixPerWord |
	depth ifNil: [ depth := 1 ].
	pixPerWord := 32 // self depth.
	^ width + pixPerWord - 1 // pixPerWord * height
]

{ #category : #copying }
Form >> blankCopyOf: aRectangle scaledBy: scale [

        ^ self class extent: (aRectangle extent * scale) truncated depth: depth
]

{ #category : #bordering }
Form >> border: rect width: borderWidth rule: rule fillColor: fillColor [
        "Paint a border whose rectangular area is defined by rect. The
width of the border of each side is borderWidth. Uses fillColor for drawing
the border."
        | blt |
        blt := (BitBlt toForm: self) combinationRule: rule; fillColor: fillColor.
        blt sourceOrigin: 0@0.
        blt destOrigin: rect origin.
        blt width: rect width; height: borderWidth; copyBits.
        blt destY: rect corner y - borderWidth; copyBits.
        blt destY: rect origin y + borderWidth.
        blt height: rect height - borderWidth - borderWidth; width:
borderWidth; copyBits.
        blt destX: rect corner x - borderWidth; copyBits
]

{ #category : #bordering }
Form >> borderWidth: anInteger color: aMask [
	"Set the width of the border for the receiver to be anInteger and paint it 
	using aMask as the border color."

	self border: self boundingBox width: anInteger fillColor: aMask
]

{ #category : #bordering }
Form >> borderWidth: anInteger fillColor: aMask [
	"Set the width of the border for the receiver to be anInteger and paint it 
	using aMask as the border color."

	self border: self boundingBox width: anInteger fillColor: aMask
]

{ #category : #'display box access' }
Form >> boundingBox [
	^ Rectangle origin: 0 @ 0
			corner: width @ height
]

{ #category : #accessing }
Form >> center [
	"Note that offset is ignored here.  Are we really going to embrace offset?  "
	^ (width @ height) // 2
]

{ #category : #converting }
Form >> collectColors: aBlock [
	"Create a new copy of the receiver with all the colors transformed by aBlock"
	^self collectPixels:[:pv|
		(aBlock value: (Color colorFromPixelValue: pv depth: self depth)) 
			pixelValueForDepth: self depth.
	].
]

{ #category : #converting }
Form >> collectPixels: aBlock [
	"Create a new copy of the receiver with all the pixels transformed by aBlock"
	self depth = 32 ifFalse:[
		"Perform the operation in 32bpp"
		^((self asFormOfDepth: 32) collectPixels: aBlock) asFormOfDepth: self depth].
	self unhibernate. "ensure unhibernated before touching bits"
	^Form 
		extent: self extent 
		depth: self depth
		bits: (self bits collect: aBlock)
]

{ #category : #'pixel access' }
Form >> colorAt: aPoint [
	"Return the color in the pixel at the given point.  "

	^ Color 
		colorFromPixelValue: (self pixelValueAt: aPoint)
		depth: self depth

]

{ #category : #'pixel access' }
Form >> colorAt: aPoint put: aColor [
	"Store a Color into the pixel at coordinate aPoint.  "

	self pixelValueAt: aPoint put: (self pixelValueFor: aColor).

"[Sensor anyButtonPressed] whileFalse:
	[Display colorAt: Sensor cursorPoint put: Color red]"

]

{ #category : #converting }
Form >> colorReduced [
	"Return a color-reduced ColorForm version of the receiver, if possible, or the receiver itself if not."

	| tally tallyDepth colorCount newForm cm oldPixelValues newFormColors nextColorIndex c |
	tally := self tallyPixelValues asArray.
	tallyDepth := (tally size log: 2) asInteger.
	colorCount := 0.
	tally do: [:n | n > 0 ifTrue: [colorCount := colorCount + 1]].
	(tally at: 1) = 0 ifTrue: [colorCount := colorCount + 1].  "include transparent"
	colorCount > 256 ifTrue: [^ self].  "cannot reduce"
	newForm := self formForColorCount: colorCount.

	"build an array of just the colors used, and a color map to translate
	 old pixel values to their indices into this color array"
	cm := Bitmap new: tally size.
	oldPixelValues := self colormapIfNeededForDepth: 32.
	newFormColors := Array new: colorCount.
	newFormColors at: 1 put: Color transparent.
	nextColorIndex := 2.
	2 to: cm size do: [:i |
		(tally at: i) > 0 ifTrue: [
			oldPixelValues 
				ifNil: [c := Color colorFromPixelValue: i - 1 depth: tallyDepth]
				ifNotNil: [c := Color colorFromPixelValue: (oldPixelValues at: i) depth: 32].
			newFormColors at: nextColorIndex put: c.
			cm at: i put: nextColorIndex - 1.  "pixel values are zero-based indices"
			nextColorIndex := nextColorIndex + 1]].

	"copy pixels into new ColorForm, mapping to new pixel values"
	newForm copyBits: self boundingBox
		from: self
		at: 0@0
		clippingBox: self boundingBox
		rule: Form over
		fillColor: nil
		map: cm.
	newForm colors: newFormColors.
	newForm offset: offset.
	^ newForm

]

{ #category : #'color mapping' }
Form >> colormapFromARGB [
	"Return a ColorMap mapping from canonical ARGB space into the receiver.
	Note: This version is optimized for image forms."
	
	| map nBits |
	self hasNonStandardPalette 
		ifTrue:[^ColorMap mappingFromARGB: self rgbaBitMasks].
	self depth <= 8 ifTrue:[
		map := Color colorMapIfNeededFrom: 32 to: self depth.
		map size = 512 ifTrue:[nBits := 3].
		map size = 4096 ifTrue:[nBits := 4].
		map size = 32768 ifTrue:[nBits := 5].
		^ColorMap
			shifts: (Array 
						with: 3 * nBits - 24
						with: 2 * nBits - 16
						with: 1 * nBits - 8
						with: 0)
			masks: (Array
						with: (1 << nBits) - 1 << (24 - nBits)
						with: (1 << nBits) - 1 << (16 - nBits)
						with: (1 << nBits) - 1 << (8 - nBits)
						with: 0)
			colors: map].
	self depth = 16 ifTrue:[
		^ColorMap
			shifts: #(-9 -6 -3 0)
			masks: #(16rF80000 16rF800 16rF8 0)].
	self depth = 32 ifTrue:[
		^ColorMap
			shifts: #(0 0 0 0)
			masks: #(16rFF0000 16rFF00 16rFF 16rFF000000)].
	self error:'Bad depth'
]

{ #category : #'color mapping' }
Form >> colormapIfNeededFor: destForm [
	"Return a ColorMap mapping from the receiver to destForm."

	^ (self hasNonStandardPalette or: [ destForm hasNonStandardPalette ])
		ifTrue: [ self colormapFromARGB mappingTo: destForm colormapFromARGB ]
		ifFalse: [ self colormapIfNeededForDepth: destForm depth ]
]

{ #category : #'color mapping' }
Form >> colormapIfNeededForDepth: destDepth [
	"Return a colormap for displaying the receiver at the given depth, or nil if no colormap is needed."

	self depth = destDepth ifTrue: [^ nil].  "not needed if depths are the same"
	^ Color colorMapIfNeededFrom: self depth to: destDepth

]

{ #category : #'color mapping' }
Form >> colormapToARGB [
	"Return a ColorMap mapping from the receiver into canonical ARGB space."
	self hasNonStandardPalette 
		ifTrue:[^self colormapFromARGB inverseMap].
	self depth <= 8 ifTrue:[
		^ColorMap
			shifts: #(0 0 0 0)
			masks: #(16rFF0000 16rFF00 16rFF 16rFF000000)
			colors: (Color colorMapIfNeededFrom: self depth to: 32)].
	self depth = 16 ifTrue:[
		^ColorMap 
			shifts: #( 9 6 3 0) 
			masks: #(16r7C00 16r3E0 16r1F 0)].
	self depth = 32 ifTrue:[
		^ColorMap
			shifts: #(0 0 0 0) 
			masks: #(16rFF0000 16rFF00 16rFF 16rFF000000)].
	self error:'Bad depth'
]

{ #category : #analyzing }
Form >> colorsUsed [
	"Return a list of the Colors this form uses."

	| tallies tallyDepth usedColors |
	tallies := self tallyPixelValues.
	tallyDepth := (tallies size log: 2) asInteger.
	usedColors := OrderedCollection new.
	tallies doWithIndex: [:count :i |
		count > 0 ifTrue: [
			usedColors add: (Color colorFromPixelValue: i - 1 depth: tallyDepth)]].
	^ usedColors asArray

]

{ #category : #'display box access' }
Form >> computeBoundingBox [
	^ Rectangle origin: 0 @ 0
			corner: width @ height
]

{ #category : #copying }
Form >> contentsOfArea: aRect [
 	"Return a new form which derives from the portion of the original form delineated by aRect."
	^self contentsOfArea: aRect 
		into: (self class extent: aRect extent depth: depth).
]

{ #category : #copying }
Form >> contentsOfArea: aRect into: newForm [
 	"Return a new form which derives from the portion of the original form delineated by aRect."
	^ newForm copyBits: aRect from: self at: 0@0
		clippingBox: newForm boundingBox rule: Form over fillColor: nil
]

{ #category : #filling }
Form >> convexShapeFill: aMask [ 
	"Fill the interior of the outtermost outlined region in the receiver.  The outlined region must not be concave by more than 90 degrees.  Typically aMask is Color black, to produce a solid fill. then the resulting form is used with fillShape: to paint a solid color.  See also anyShapeFill"
	| destForm tempForm |
	destForm := Form extent: self extent.  destForm fillBlack.
	tempForm := Form extent: self extent.
	(0@0) fourNeighbors do:
		[:dir |  "Smear self in all 4 directions, and AND the result"
		self displayOn: tempForm at: (0@0) - self offset.
		tempForm smear: dir distance: (dir dotProduct: tempForm extent) abs.
		tempForm displayOn: destForm at: 0@0
			clippingBox: destForm boundingBox
			rule: Form and fillColor: nil].
	destForm displayOn: self at: 0@0
		clippingBox: self boundingBox
		rule: Form over fillColor: aMask
]

{ #category : #copying }
Form >> copy: aRect [
 	"Return a new form which derives from the portion of the original form delineated by aRect."
	| newForm |
	newForm := self class extent: aRect extent depth: depth.
	^ newForm copyBits: aRect from: self at: 0@0
		clippingBox: newForm boundingBox rule: Form over fillColor: nil
]

{ #category : #copying }
Form >> copy: destRectangle from: sourcePt in: sourceForm rule: rule [ 
	"Make up a BitBlt table and copy the bits."
	(BitBlt toForm: self)
		copy: destRectangle
		from: sourcePt in: sourceForm
		fillColor: nil rule: rule
]

{ #category : #copying }
Form >> copy: sourceRectangle from: sourceForm to: destPt rule: rule [
	^ self copy: (destPt extent: sourceRectangle extent)
		from: sourceRectangle topLeft in: sourceForm rule: rule
]

{ #category : #copying }
Form >> copyBits: sourceForm at: destOrigin translucent: factor [
	"Make up a BitBlt table and copy the bits with the given colorMap."
	(BitBlt  
		destForm: self
		sourceForm: sourceForm
		halftoneForm: nil
		combinationRule: 30
		destOrigin: destOrigin
		sourceOrigin: 0@0
		extent: sourceForm extent
		clipRect: self boundingBox)
		copyBitsTranslucent: ((0 max: (factor*255.0) asInteger) min: 255)
"
 | f f2 f3 | f := Form fromUser. f2 := Form fromDisplay: (0@0 extent: f extent). f3 := f2 deepCopy.
0.0 to: 1.0 by: 1.0/32 do:
	[:t | f3 := f2 deepCopy. f3 copyBits: f at: 0@0 translucent: t.
	f3 displayAt: 0@0. (Delay forMilliseconds: 100) wait].
"
]

{ #category : #copying }
Form >> copyBits: sourceRect from: sourceForm at: destOrigin clippingBox: clipRect rule: rule fillColor: aForm [ 
	"Make up a BitBlt table and copy the bits."

	(BitBlt  
		destForm: self
		sourceForm: sourceForm
		fillColor: aForm
		combinationRule: rule
		destOrigin: destOrigin
		sourceOrigin: sourceRect origin
		extent: sourceRect extent
		clipRect: clipRect) copyBits
]

{ #category : #copying }
Form >> copyBits: sourceRect from: sourceForm at: destOrigin clippingBox: clipRect rule: rule fillColor: aForm map: map [
	"Make up a BitBlt table and copy the bits.  Use a colorMap."

	((BitBlt  
		destForm: self
		sourceForm: sourceForm
		fillColor: aForm
		combinationRule: rule
		destOrigin: destOrigin
		sourceOrigin: sourceRect origin
		extent: sourceRect extent
		clipRect: clipRect) colorMap: map) copyBits
]

{ #category : #copying }
Form >> copyBits: sourceRect from: sourceForm at: destOrigin colorMap: map [ 
	"Make up a BitBlt table and copy the bits with the given colorMap."
	((BitBlt  
		destForm: self
		sourceForm: sourceForm
		halftoneForm: nil
		combinationRule: Form over
		destOrigin: destOrigin
		sourceOrigin: sourceRect origin
		extent: sourceRect extent
		clipRect: self boundingBox) colorMap: map) copyBits
]

{ #category : #converting }
Form >> copyWithColorsReducedTo: nColors [
	"Note: this has not been engineered.
	There are better solutions in the literature."
	| palette colorMap |
	palette := self reducedPaletteOfSize: nColors.
	colorMap := (1 to: (1 bitShift: depth)) collect:
		[:i | | pc closest | pc := Color colorFromPixelValue: i-1 depth: depth.
		closest := palette detectMin: [:c | c diff: pc].
		closest pixelValueForDepth: depth].
	^ self deepCopy copyBits: self boundingBox from: self at: 0@0 colorMap: (colorMap as: Bitmap)
		
]

{ #category : #converting }
Form >> darker [
	"Answer a darker variant of this form."
	
	^ self darker: 0.16
]

{ #category : #converting }
Form >> darker: aFactor [
	"Answer a darker variant of this form. aFactor is a float between 0 and 1 representing the strength of 
	the darkening."
	"(Form fromUser darker: 0.08) asMorph openInWorld"
	"(Form fromUser darker: 0.16) asMorph openInWorld"
	
	^ self collectColors: [ :color |
				color adjustBrightness: aFactor negated]
]

{ #category : #copying }
Form >> deepCopy [

	^ self shallowCopy
		bits: bits copy;
		offset: offset copy

]

{ #category : #accessing }
Form >> depth [
	^ depth < 0 ifTrue:[0-depth] ifFalse:[depth]
]

{ #category : #accessing }
Form >> depth: bitsPerPixel [
	(bitsPerPixel > 32 or:
		[(bitsPerPixel bitAnd: bitsPerPixel-1) ~= 0])
		ifTrue: [self error: 'bitsPerPixel must be 1, 2, 4, 8, 16 or 32'].
	depth := bitsPerPixel
]

{ #category : #converting }
Form >> dimmed [
	"Answer a dimmed variant of this form."
	"Form fromUser dimmed asMorph openInWorld"
	^ self dimmed: 0.5
]

{ #category : #converting }
Form >> dimmed: factor [
	"Answer a dimmed variant of this form. factor in a float between 0 and 1"
	"(Form fromUser dimmed: 0.6) asMorph openInWorld"
	^ self collectColors: [ :color |
			color alpha: (color alpha min: factor)]
]

{ #category : #displaying }
Form >> displayOn: aDisplayMedium at: aDisplayPoint clippingBox: clipRectangle rule: rule fillColor: aForm [

	aDisplayMedium copyBits: self boundingBox
		from: self
		at: aDisplayPoint + self offset
		clippingBox: clipRectangle
		rule: rule
		fillColor: aForm
		map: (self colormapIfNeededFor: aDisplayMedium).

]

{ #category : #displaying }
Form >> displayOnPort: port at: location [
	port copyForm: self to: location rule: Form over
]

{ #category : #displaying }
Form >> displayResourceFormOn: aForm [
	"a special display method for blowing up resource thumbnails"
	
	self extent = aForm extent
		ifTrue: [ ^ self displayOn: aForm ].

	"We've got no bilinear interpolation. Use WarpBlt instead"
	(WarpBlt toForm: aForm)
		sourceForm: self destRect: aForm boundingBox;
		combinationRule: 3;
		cellSize: 2;
		warpBits.

]

{ #category : #displaying }
Form >> displayScaledOn: aForm [
	"Display the receiver on aForm, scaling if necessary.
		Form fromUser displayScaledOn: Display.
	"
	self extent = aForm extent ifTrue:[^self displayOn: aForm].
	(WarpBlt toForm: aForm)
		sourceForm: self destRect: aForm boundingBox;
		combinationRule: Form paint;
		cellSize: 2;
		warpBits.
]

{ #category : #accessing }
Form >> displayScreen [
	"Return the display screen the receiver is allocated on. 
	Forms in general are internal and not allocated on any particular display."
	^ nil
]

{ #category : #analyzing }
Form >> dominantColor [
	| tally max maxi |
	self depth > 16 ifTrue:
		[^(self asFormOfDepth: 16) dominantColor].
	tally := self tallyPixelValues.
	max := maxi := 0.
	tally withIndexDo: [:n :i | n > max ifTrue: [max := n. maxi := i]].
	^ Color colorFromPixelValue: maxi - 1 depth: self depth
]

{ #category : #displaying }
Form >> drawLine: sourceForm from: beginPoint to: endPoint clippingBox: clipRect rule: anInteger fillColor: aForm [ 
	"Refer to the comment in 
	DisplayMedium|drawLine:from:to:clippingBox:rule:mask:." 
	
	| dotSetter |
	"set up an instance of BitBlt for display"
	dotSetter := BitBlt 
		destForm: self
		sourceForm: sourceForm
		fillColor: aForm
		combinationRule: anInteger
		destOrigin: beginPoint
		sourceOrigin: 0 @ 0
		extent: sourceForm extent
		clipRect: clipRect.
	dotSetter drawFrom: beginPoint to: endPoint
]

{ #category : #filling }
Form >> eraseShape: bwForm [
	"use bwForm as a mask to clear all pixels where bwForm has 1's"
	((BitBlt  destForm: self sourceForm: bwForm 
		fillColor: nil
		combinationRule: Form erase1bitShape	"Cut a hole in the picture with my mask"
		destOrigin: bwForm offset 
		sourceOrigin: 0@0
		extent: self extent clipRect: self boundingBox)
		colorMap: (Bitmap with: 0 with: 16rFFFFFFFF))
		copyBits.

]

{ #category : #accessing }
Form >> extent [
	^ width @ height
]

{ #category : #transitions }
Form >> fadeImage: otherImage at: topLeft
	indexAndMaskDo: indexAndMaskBlock [
	
	"This fade uses halftones as a blending hack.
	Zeros in the halftone produce the original image (self), and 
	ones in the halftone produce the 'otherImage'.
	IndexAndMaskBlock gets evaluated prior to each cycle,
	and the resulting boolean determines whether to continue cycling."
	| index imageRect maskForm resultForm |
	imageRect := otherImage boundingBox.
	resultForm := self copy: (topLeft extent: imageRect extent).
	maskForm := Form extent: 32@32.
	index := 0.

	[indexAndMaskBlock value: (index := index+1) value: maskForm]
	whileTrue:
		[maskForm reverse.
		resultForm copyBits: imageRect from: resultForm at: 0@0
			clippingBox: imageRect rule: Form over fillColor: maskForm.
		maskForm reverse.
		resultForm copyBits: imageRect from: otherImage at: 0@0
			clippingBox: imageRect rule: Form under fillColor: maskForm.
		self copyBits: imageRect from: resultForm at: topLeft
				clippingBox: self boundingBox rule: Form over fillColor: nil.
		Display forceDisplayUpdate]
]

{ #category : #transitions }
Form >> fadeImageCoarse: otherImage at: topLeft [
	"Display fadeImageCoarse: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40"
	| d pix|
	d := self depth.
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask | | j |
		i=1 ifTrue: [pix := (1 bitShift: d) - 1.
					1 to: 8//d-1 do: [:q | pix := pix bitOr: (pix bitShift: d*4)]]			.
		i <= 16 ifTrue:[
		j := i-1//4+1.
		(0 to: 28 by: 4) do: [:k |
			mask bits at: j+k
				put: (pix bitOr: (mask bits at: j+k))].
		true]
		ifFalse: [false]]
]

{ #category : #transitions }
Form >> fadeImageFine: otherImage at: topLeft [
	"Display fadeImageFine: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40"
	| d pix|
	d := self depth.
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask | | j ii  |
		i=1 ifTrue: [pix := (1 bitShift: d) - 1.
					1 to: 8//d-1 do:
						[:q | pix := pix bitOr: (pix bitShift: d*4)]].
		i <= 16 ifTrue:
		[ii := #(0 10 2 8 7 13 5 15 1 11 3 9 6 12 4 14) at: i.
		j := ii//4+1.
		(0 to: 28 by: 4) do:
			[:k | mask bits at: j+k put:
				((mask bits at: j+k) bitOr: (pix))].
		true]
		ifFalse: [false]]
]

{ #category : #transitions }
Form >> fadeImageHor: otherImage at: topLeft [
	"Display fadeImageHor: (Form fromDisplay: (10@10 extent: 300@300)) reverse at: 10@10"
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask |
		mask fill: (0@(mask height//2-i) extent: mask width@(i*2)) fillColor: Color black.
		(i*2) <= mask width]
]

{ #category : #transitions }
Form >> fadeImageHorFine: otherImage at: topLeft [
	"Display fadeImageHorFine: (Form fromDisplay: (10@10 extent: 300@300)) reverse at: 10@10"
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask |
		mask fill: (0@(i-1) extent: mask width@1) fillColor: Color black.
		mask fill: (0@(i-1+16) extent: mask width@1) fillColor: Color black.
		(i*2) <= mask width]
]

{ #category : #transitions }
Form >> fadeImageSquares: otherImage at: topLeft [ 
	"Display fadeImageSquares: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40"
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask |
		mask fill: ((16-i) asPoint extent: (i*2) asPoint) fillColor: Color black.
		i <= 16]
]

{ #category : #transitions }
Form >> fadeImageVert: otherImage at: topLeft [
	"Display fadeImageVert: (Form fromDisplay: (10@10 extent: 300@300)) reverse at: 10@10"
	| d |
	d := self depth.
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask |
		mask fill: ((mask width//2//d-i*d)@0 extent: i*2*d@mask height) fillColor: Color black.
		i <= (mask width//d)]
]

{ #category : #filling }
Form >> fill: aRectangle rule: anInteger fillColor: aForm [ 
	"Replace a rectangular area of the receiver with the pattern described by aForm 
	according to the rule anInteger."
	(BitBlt toForm: self)
		copy: aRectangle
		from: 0@0 in: nil
		fillColor: aForm rule: anInteger
]

{ #category : #other }
Form >> fillAlpha: alphaValue [
	"Fill a 32bit form with a constant alpha value"
	| bb |
	self depth = 32 ifFalse:[^self error: 'Only valid for 32 bit forms'].
	bb := BitBlt toForm: self.
	bb combinationRule: 7. "bitOr:with:"
	bb fillColor: (Bitmap with: alphaValue << 24).
	bb copyBits.

]

{ #category : #filling }
Form >> fillFromXColorBlock: colorBlock [
	"Horizontal Gradient Fill.
	Supply relative x in [0.0 ... 1.0] to colorBlock,
	and paint each pixel with the color that comes back"
	| xRel |
	0 to: width-1 do:
		[:x |  xRel := x asFloat / (width-1) asFloat.
		self fill: (x@0 extent: 1@height) 
			fillColor: (colorBlock value: xRel)]
"
((Form extent: 100@100 depth: Display depth)
	fillFromXColorBlock: [:x | Color r: x g: 0.0 b: 0.5]) display
"
]

{ #category : #filling }
Form >> fillFromXYColorBlock: colorBlock [
	"General Gradient Fill.
	Supply relative x and y in [0.0 ... 1.0] to colorBlock,
	and paint each pixel with the color that comes back"
	| poker yRel xRel |
	poker := BitBlt bitPokerToForm: self.
	0 to: height-1 do:
		[:y | yRel := y asFloat / (height-1) asFloat.
		0 to: width-1 do:
			[:x |  xRel := x asFloat / (width-1) asFloat.
			poker pixelAt: x@y
				put: ((colorBlock value: xRel value: yRel) pixelWordForDepth: self depth)]]
"
 | d |
((Form extent: 100@20 depth: Display depth)
	fillFromXYColorBlock:
	[:x :y | d := 1.0 - (x - 0.5) abs - (y - 0.5) abs.
	Color r: d g: 0 b: 1.0-d]) display
"
]

{ #category : #filling }
Form >> fillFromYColorBlock: colorBlock [
	"Vertical Gradient Fill.
	Supply relative y in [0.0 ... 1.0] to colorBlock,
	and paint each pixel with the color that comes back"
	| yRel |
	0 to: height-1 do:
		[:y |  yRel := y asFloat / (height-1) asFloat.
		self fill: (0@y extent: width@1) 
			fillColor: (colorBlock value: yRel)]
"
((Form extent: 100@100 depth: Display depth)
	fillFromYColorBlock: [:y | Color r: y g: 0.0 b: 0.5]) display
"
]

{ #category : #filling }
Form >> findShapeAroundSeedBlock: seedBlock [
	"Build a shape that is black in any region marked by seedBlock. 
	SeedBlock will be supplied a form, in which to blacken various
	pixels as 'seeds'.  Then the seeds are smeared until 
	there is no change in the smear when it fills the region, ie,
	when smearing hits a black border and thus goes no further."
	| smearForm previousSmear all count smearPort |
	self assert: [self depth > 1]. "Only meaningful for B/W forms."
	all := self boundingBox.
	smearForm := Form extent: self extent.
	smearPort := BitBlt toForm: smearForm.
	seedBlock value: smearForm.		"Blacken seeds to be smeared"
	smearPort copyForm: self to: 0 @ 0 rule: Form erase.  "Clear any in black"
	previousSmear := smearForm deepCopy.
	count := 1.
	[count = 10 and:   "check for no change every 10 smears"
		[count := 1.
		previousSmear copy: all from: 0 @ 0 in: smearForm rule: Form reverse.
		previousSmear isAllWhite]]
		whileFalse: 
			[smearPort copyForm: smearForm to: 1 @ 0 rule: Form under.
			smearPort copyForm: smearForm to: -1 @ 0 rule: Form under.
			"After horiz smear, trim around the region border"
			smearPort copyForm: self to: 0 @ 0 rule: Form erase.
			smearPort copyForm: smearForm to: 0 @ 1 rule: Form under.
			smearPort copyForm: smearForm to: 0 @ -1 rule: Form under.
			"After vert smear, trim around the region border"
			smearPort copyForm: self to: 0 @ 0 rule: Form erase.
			count := count+1.
			count = 9 ifTrue: "Save penultimate smear for comparison"
				[previousSmear copy: all from: 0 @ 0 in: smearForm rule: Form over]].
	"Now paint the filled region in me with aHalftone"
	^ smearForm
]

{ #category : #initialization }
Form >> finish [
	"If there are any pending operations on the receiver complete them. Do not return before all modifications have taken effect."
]

{ #category : #other }
Form >> fixAlpha [
	"Fix the alpha channel if the receiver is 32bit"
	| bb |
	self depth = 32 ifFalse:[^self].
	bb := BitBlt toForm: self.
	bb combinationRule: 40 "fixAlpha:with:".
	bb copyBits.
]

{ #category : #'scaling, rotation' }
Form >> flipBy: direction centerAt: aPoint [
	"Return a copy of the receiver flipped either #vertical or #horizontal."
	| newForm quad |
	newForm := self class extent: self extent depth: depth.
	quad := self boundingBox innerCorners.
	quad := (direction = #vertical ifTrue: [#(2 1 4 3)] ifFalse: [#(4 3 2 1)])
		collect: [:i | quad at: i].
	(WarpBlt toForm: newForm)
		sourceForm: self;
		colorMap: (self colormapIfNeededFor: newForm);
		combinationRule: 3;
		copyQuad: quad toRect: newForm boundingBox.
	newForm offset: (self offset flipBy: direction centerAt: aPoint).
	^ newForm
"
[Sensor anyButtonPressed] whileFalse:
	[((Form fromDisplay: (Sensor cursorPoint extent: 130@66))
			flipBy: #vertical centerAt: 0@0) display]
"
"Consistency test...
 | f f2 p | [Sensor anyButtonPressed] whileFalse:
	[f := Form fromDisplay: ((p := Sensor cursorPoint) extent: 31@41).
	Display fillBlack: (p extent: 31@41).
	f2 := f flipBy: #vertical centerAt: 0@0.
	(f2 flipBy: #vertical centerAt: 0@0) displayAt: p]
"

]

{ #category : #'scaling, rotation' }
Form >> flipHorizontally [
	"Flip the image around the x axis. Flip the form upside/down"
	| rowLen row topIndex botIndex |
	self unhibernate.
	rowLen := bits size // height.
	row := Bitmap new: rowLen.
	topIndex := 1.
	botIndex := bits size - rowLen + 1.
	1 to: height // 2 do: [ :i |
		[topIndex+rowLen <= botIndex] assert.
		row replaceFrom: 1 to: rowLen with: bits startingAt: topIndex.
		bits replaceFrom: topIndex to: topIndex+rowLen-1 with: bits startingAt: botIndex.
		bits replaceFrom: botIndex to: botIndex+rowLen-1 with: row startingAt: 1.
		topIndex := topIndex + rowLen.
		 botIndex := botIndex - rowLen ].
]

{ #category : #initialization }
Form >> flush [
	"If there are any pending operations on the receiver start doing them. In time, they will show up on the receiver but not necessarily immediately after this method returns."
]

{ #category : #accessing }
Form >> form [
	"Answer the receiver's form.  For vanilla Forms, this degenerates to self.  Makes several methods that operate on both Forms and MaskedForms much more straightforward."

	^ self
]

{ #category : #other }
Form >> formForColorCount: colorCount [
	"Return a ColorForm of sufficient depth to represent the given number of colors. The maximum number of colors is 256."

	colorCount > 256 ifTrue: [^ self error: 'too many colors'].

	colorCount > 16 ifTrue: [^ ColorForm extent: self extent depth: 8].
	colorCount > 4 ifTrue: [^ ColorForm extent: self extent depth: 4].
	colorCount > 2 ifTrue: [^ ColorForm extent: self extent depth: 2].
	^ ColorForm extent: self extent depth: 1

]

{ #category : #initialization }
Form >> fromDisplay: aRectangle [ 
	"Create a virtual bit map from a user specified rectangular area on the 
	display screen. Reallocates bitmap only if aRectangle ~= the receiver's 
	extent."

	(width = aRectangle width and: [height = aRectangle height])
		ifFalse: [self setExtent: aRectangle extent depth: depth].
	self
		copyBits: (aRectangle origin extent: self extent)
		from: Display
		at: 0 @ 0
		clippingBox: self boundingBox
		rule: Form over
		fillColor: nil
]

{ #category : #private }
Form >> hackBits: bitThing [
	"This method provides an initialization so that BitBlt may be used, eg, to 
	copy ByteArrays and other non-pointer objects efficiently.
	The resulting form looks 4 wide, 8 deep, and bitThing-size-in-words high."
	width := 4.
	depth := 8.
	bitThing class isBits ifFalse: [self error: 'bitThing must be a non-pointer object'].
	bitThing class isBytes
		ifTrue: [height := bitThing basicSize // 4]
		ifFalse: [height := bitThing basicSize].
	bits := bitThing
]

{ #category : #accessing }
Form >> hasBeenModified [
	"Return true if something *might* have been drawn into the receiver"
	^(bits == nil or:[bits class == ByteArray]) not
	"Read the above as: If the receiver has forgotten its contents (bits == nil) 
	or is still hibernated it can't be modified."
]

{ #category : #accessing }
Form >> hasBeenModified: aBool [
	"Change the receiver to reflect the modification state"
	aBool ifTrue:[^self unhibernate].
	self shouldPreserveContents
		ifTrue:[self hibernate]
		ifFalse:[bits := nil]
]

{ #category : #testing }
Form >> hasNonStandardPalette [
	"Return true if the receiver has a non-standard palette.
	Non-standard means that RGBA components may be located
	at positions differing from the standard Pharo RGBA layout
	at the receiver's depth."
	^false
]

{ #category : #accessing }
Form >> height [
	^ height
]

{ #category : #'file in/out' }
Form >> hibernate [
	"Replace my bitmap with a compactly encoded representation (a ByteArray).  It is vital that BitBlt and any other access to the bitmap (such as writing to a file) not be used when in this state.  Since BitBlt will fail if the bitmap size is wrong (not = bitsSize), we do not allow replacement by a byteArray of the same (or larger) size."

	"NOTE: This method copies code from Bitmap compressToByteArray so that it can
	nil out the old bits during the copy, thus avoiding 2x need for extra storage."
	| compactBits lastByte |
	(bits isMemberOf: Bitmap) ifFalse: [^ self  "already hibernated or weird state"].
	compactBits := ByteArray new: (bits size*4) + 7 + (bits size//1984*3).
	lastByte := bits compress: bits toByteArray: compactBits.
	lastByte < (bits size*4) ifTrue:
		[bits := nil.  "Let GC reclaim the old bits before the copy if necessary"
		bits := compactBits copyFrom: 1 to: lastByte]
]

{ #category : #private }
Form >> initFromArray: array [
	"Fill the bitmap from array.  If the array is shorter,
	then cycle around in its contents until the bitmap is filled."
	| ax aSize array32 i j word16 |
	ax := 0.
	aSize := array size.
	aSize > bits size ifTrue:
		["backward compatibility with old 16-bit bitmaps and their forms"
		array32 := Array new: height * (width + 31 // 32).
		i := j := 0.
		1 to: height do:
			[:y | 1 to: width+15//16 do:
				[:x16 | word16 := array at: (i := i + 1).
				x16 odd ifTrue: [array32 at: (j := j+1) put: (word16 bitShift: 16)]
						ifFalse: [array32 at: j put: ((array32 at: j) bitOr: word16)]]].
		^ self initFromArray: array32].
	1 to: bits size do:
		[:index |
		(ax := ax + 1) > aSize ifTrue: [ax := 1].
		bits at: index put: (array at: ax)]
]

{ #category : #analyzing }
Form >> innerPixelRectFor: pv orNot: not [
	"Return a rectangle describing the smallest part of me that includes 
	all pixels of value pv.
	Note:  If orNot is true, then produce a copy that includes all pixels
	that are DIFFERENT from the supplied (background) value"

	| xTally yTally |
	xTally := self xTallyPixelValue: pv orNot: not.
	yTally := self yTallyPixelValue: pv orNot: not.
	^ ((xTally findFirst: [:t | t>0]) - 1) @ ((yTally findFirst: [:t | t>0]) - 1)
		corner:
			(xTally findLast: [:t | t>0])@(yTally findLast: [:t | t>0])
]

{ #category : #converting }
Form >> invertedAndAlphaMultiplied [
	^ (self asFormOfDepth: 32) collectColors: [ :c |
		| a |
		a := c alpha.
		Color r: (1.0 - c red) * a g: (1.0 - c green) * a b: (1.0 - c blue) * a alpha: a
	]
]

{ #category : #testing }
Form >> isAllWhite [
	"Answer whether all bits in the receiver are white"
	| word |
	self unhibernate.
	word := Color white pixelWordForDepth: self depth.
	1 to: bits size do: [:i | (bits at: i) = word ifFalse: [^ false]].
	^ true
]

{ #category : #testing }
Form >> isBigEndian [
	"Return true if the receiver contains big endian pixels, meaning the left-most pixel is stored in the most significant bits of a word."
	^depth > 0
]

{ #category : #testing }
Form >> isBltAccelerated: ruleInteger for: sourceForm [
	"Return true if the receiver can perform accelerated blts operations by itself"
	^false
]

{ #category : #testing }
Form >> isDisplayScreen [
	^false
]

{ #category : #testing }
Form >> isExternalForm [
	^false
]

{ #category : #testing }
Form >> isFillAccelerated: ruleInteger for: aColor [
	"Return true if the receiver can perform accelerated fill operations by itself"
	^false
]

{ #category : #testing }
Form >> isForm [
	^true
]

{ #category : #testing }
Form >> isLittleEndian [
	"Return true if the receiver contains little endian pixels, meaning the left-most pixel is stored in the least significant bits of a word."
	^depth < 0
]

{ #category : #testing }
Form >> isStatic [

	^false
]

{ #category : #testing }
Form >> isTranslucent [
	"Answer whether this form may be translucent"
	^self depth = 32
]

{ #category : #'pixel access' }
Form >> isTransparentAt: aPoint [ 
	"Return true if the receiver is transparent at the given point."

	self depth = 1 ifTrue: [^ false].  "no transparency at depth 1"
	^ (self pixelValueAt: aPoint) = (self pixelValueFor: Color transparent)

]

{ #category : #converting }
Form >> lighter [
	"Answer a lighter variant of this form"

	^ self lighter: 0.16
]

{ #category : #converting }
Form >> lighter: aFactor [
	"Answer a lighter variant of this form. aFactor is a float from 0 to 1 representing the strength of 
	the lightening."
	"(Form fromUser lighter: 0.16) asMorph openInWorld"
	"(Form fromUser lighter: 0.30) asMorph openInWorld"
	^self collectColors: [:color | 
			color adjustSaturation: -0.03 brightness: aFactor]
]

{ #category : #'scaling, rotation' }
Form >> magnify: aRectangle by: scale [ 
	"Answer a Form created as a scaling of the receiver.
	Scale may be a Float, and may be greater or less than 1.0."
	^ self magnify: aRectangle by: scale smoothing: 1

"Dynamic test...
[Sensor anyButtonPressed] whileFalse:
	[(Display magnify: (Sensor cursorPoint extent: 31@41) by: 5@3) display]
"
"Scaling test...
| f cp | f := Form fromDisplay: (Rectangle originFromUser: 100@100).
Display restoreAfter: [Sensor waitNoButton.
[Sensor anyButtonPressed] whileFalse:
	[cp := Sensor cursorPoint.
	(f magnify: f boundingBox by: (cp x asFloat@cp y asFloat)/f extent) display]]
"
"Consistency test...
 | f f2 p | [Sensor anyButtonPressed] whileFalse:
	[f := Form fromDisplay: ((p := Sensor cursorPoint) extent: 31@41).
	Display fillBlack: (p extent: 31@41).
	f2 := f magnify: f boundingBox by: 5@3.
	(f2 shrink: f2 boundingBox by: 5@3) displayAt: p]
"

]

{ #category : #'scaling, rotation' }
Form >> magnify: aRectangle by: scale smoothing: cellSize [
	"Answer a Form created as a scaling of the receiver.
        Scale may be a Float or even a Point, and may be greater or less than 1.0."

	| newForm |
	newForm := self blankCopyOf: aRectangle scaledBy: scale.
	(WarpBlt toForm: newForm)
		sourceForm: self;
		colorMap: (self colormapIfNeededFor: newForm);
		cellSize: cellSize;
		"installs a new colormap if cellSize > 1"
			combinationRule: 3;
		copyQuad: aRectangle innerCorners toRect: newForm boundingBox.
	^ newForm

	"Dynamic test...
[Sensor anyButtonPressed] whileFalse:
        [(Display magnify: (Sensor cursorPoint extent: 131@81) by: 0.5 smoothing: 2) display]
"
	"Scaling test...
| f cp | f := Form fromDisplay: (Rectangle originFromUser: 100@100).
Display restoreAfter: [Sensor waitNoButton.
[Sensor anyButtonPressed] whileFalse:
        [cp := Sensor cursorPoint.
        (f magnify: f boundingBox by: (cp x asFloat@cp y asFloat)/f extent smoothing: 2) display]]
"
]

{ #category : #'scaling, rotation' }
Form >> magnifyBy: scale [ 
	"Answer a Form created as a scaling of the receiver.
	Scale may be a Float, and may be greater or less than 1.0."

	^ self magnify: self boundingBox by: scale
			smoothing: (scale < 1 ifTrue: [2] ifFalse: [1])
]

{ #category : #'color mapping' }
Form >> makeBWForm: foregroundColor [
	"Map this form into a B/W form with 1's in the foreground regions."
	| bwForm map |
	bwForm := Form extent: self extent.
	map := self newColorMap.  "All non-foreground go to 0's"
	map at: (foregroundColor indexInMap: map) put: 1.
	bwForm copyBits: self boundingBox from: self at: 0@0 colorMap: map.
	^ bwForm
]

{ #category : #'color mapping' }
Form >> mapColor: oldColor to: newColor [
	"Make all pixels of the given color in this Form to the given new color."
	"Warnings: This method modifies the receiver. It may lose some color accuracy on 32-bit Forms, since the transformation uses a color map with only 15-bit resolution."

	| map |
	map := (Color cachedColormapFrom: self depth to: self depth) copy.
	map at: (oldColor indexInMap: map) put: (newColor pixelWordForDepth: self depth).
	(BitBlt toForm: self)
		sourceForm: self;
		sourceOrigin: 0@0;
		combinationRule: Form over;
		destX: 0 destY: 0 width: width height: height;
		colorMap: map;
		copyBits.

]

{ #category : #'color mapping' }
Form >> mapColors: oldColorBitsCollection to: newColorBits [
	"Make all pixels of the given color in this Form to the given new color."
	"Warnings: This method modifies the receiver. It may lose some color accuracy on 32-bit Forms, since the transformation uses a color map with only 15-bit resolution."

	| map |
	self depth < 16
		ifTrue: [map := (Color cachedColormapFrom: self depth to: self depth) copy]
		ifFalse: [
			"use maximum resolution color map"
			"source is 16-bit or 32-bit RGB; use colormap with 5 bits per color component"
			map := Color computeRGBColormapFor: self depth bitsPerColor: 5].
	oldColorBitsCollection do:[ :oldColor | map at: oldColor put: newColorBits].

	(BitBlt toForm: self)
		sourceForm: self;
		sourceOrigin: 0@0;
		combinationRule: Form over;
		destX: 0 destY: 0 width: width height: height;
		colorMap: map;
		copyBits.

]

{ #category : #'color mapping' }
Form >> maskingMap [
	"Return a color map that maps all colors except transparent to words of all ones. Used to create a mask for a Form whose transparent pixel value is zero."
	^Color maskingMap: self depth
]

{ #category : #testing }
Form >> mightBeTranslucent [
	"Answer whether this form may be translucent"
	^self depth = 32
]

{ #category : #accessing }
Form >> nativeDepth [
	"Return the 'native' depth of the receiver, e.g., including the endianess"
	^depth
]

{ #category : #'color mapping' }
Form >> newColorMap [ 
	"Return an uninitialized color map array appropriate to this Form's depth."

	^ Bitmap new: (1 bitShift: (self depth min: 15))

]

{ #category : #accessing }
Form >> offset [
	^offset ifNil:[0@0]
]

{ #category : #accessing }
Form >> offset: aPoint [

	offset := aPoint
]

{ #category : #converting }
Form >> orderedDither32To16 [
	"Do an ordered dithering for converting from 32 to 16 bit depth."
	| ditherMatrix ii out inBits outBits index pv dmv r di dmi dmo g b pvOut outIndex |
	self depth = 32 ifFalse:[^self error:'Must be 32bit for this'].
	ditherMatrix := #(	0	8	2	10
						12	4	14	6
						3	11	1	9
						15	7	13	5).
	ii := (0 to: 31) collect:[:i| i].
	out := Form extent: self extent depth: 16.
	inBits := self bits.
	outBits := out bits.
	index := outIndex := 0.
	pvOut := 0.
	0 to: self height-1 do:[:y|
		0 to: self width-1 do:[:x|
			pv := inBits at: (index := index + 1).
			dmv := ditherMatrix at: (y bitAnd: 3) * 4 + (x bitAnd: 3) + 1.
			r := pv bitAnd: 255.	di := r * 496 bitShift: -8.
			dmi := di bitAnd: 15.	dmo := di bitShift: -4.
			r := dmv < dmi ifTrue:[ii at: 2+dmo] ifFalse:[ii at: 1+dmo].
			g := (pv bitShift: -8) bitAnd: 255.	di := g * 496 bitShift: -8.
			dmi := di bitAnd: 15.	dmo := di bitShift: -4.
			g := dmv < dmi ifTrue:[ii at: 2+dmo] ifFalse:[ii at: 1+dmo].
			b := (pv bitShift: -16) bitAnd: 255.	di := b * 496 bitShift: -8.
			dmi := di bitAnd: 15.	dmo := di bitShift: -4.
			b := dmv < dmi ifTrue:[ii at: 2+dmo] ifFalse:[ii at: 1+dmo].
			pvOut := (pvOut bitShift: 16) + 
						(b bitShift: 10) + (g bitShift: 5) + r.
			(x bitAnd: 1) = 1 ifTrue:[
				outBits at: (outIndex := outIndex+1) put: pvOut.
				pvOut := 0].
		].
		(self width bitAnd: 1) = 1 ifTrue:[
			outBits at: (outIndex := outIndex+1) put: (pvOut bitShift: -16).
			pvOut := 0].
	].
	^out
]

{ #category : #transitions }
Form >> pageWarp: otherImage at: topLeft forward: forward [
	"Produce a page-turning illusion that gradually reveals otherImage
	located at topLeft in this form.
	forward == true means turn pages toward you, else away. [ignored for now]"
	| pageRect oldPage nSteps buffer p leafRect sourceQuad warp oldBottom d |
	pageRect := otherImage boundingBox.
	oldPage := self copy: (pageRect translateBy: topLeft).
	(forward ifTrue: [oldPage] ifFalse: [otherImage])
		border: pageRect
		widthRectangle: (Rectangle
				left: 0
				right: 2
				top: 1
				bottom: 1)
		rule: Form over
		fillColor: Color black.
	oldBottom := self copy: ((pageRect bottomLeft + topLeft) extent: (pageRect width@(pageRect height//4))).
	nSteps := 8.
	buffer := Form extent: otherImage extent + (0@(pageRect height//4)) depth: self depth.
	d := pageRect topLeft + (0@(pageRect height//4)) - pageRect topRight.
	1 to: nSteps-1 do:
		[:i | forward
			ifTrue: [buffer copy: pageRect from: otherImage to: 0@0 rule: Form over.
					p := pageRect topRight + (d * i // nSteps)]
			ifFalse: [buffer copy: pageRect from: oldPage to: 0@0 rule: Form over.
					p := pageRect topRight + (d * (nSteps-i) // nSteps)].
		buffer copy: oldBottom boundingBox from: oldBottom to: pageRect bottomLeft rule: Form over.
		leafRect := pageRect topLeft corner: p x @ (pageRect bottom + p y).
		sourceQuad := Array with: pageRect topLeft
			with: pageRect bottomLeft + (0@p y)
			with: pageRect bottomRight
			with: pageRect topRight - (0@p y).
		warp := (WarpBlt toForm: buffer)
				clipRect: leafRect;
				sourceForm: (forward ifTrue: [oldPage] ifFalse: [otherImage]);
				combinationRule: Form paint.
		warp copyQuad: sourceQuad toRect: leafRect.
		self copy: buffer boundingBox from: buffer to: topLeft rule: Form over.
		Display forceDisplayUpdate].

	buffer copy: pageRect from: otherImage to: 0@0 rule: Form over.
	buffer copy: oldBottom boundingBox from: oldBottom to: pageRect bottomLeft rule: Form over.
	self copy: buffer boundingBox from: buffer to: topLeft rule: Form over.
	Display forceDisplayUpdate.
"
1 to: 4 do: [:corner | Display pageWarp:
				(Form fromDisplay: (10@10 extent: 200@300)) reverse
			at: 10@10 forward: false]
"

]

{ #category : #displaying }
Form >> paintBits: sourceForm at: destOrigin translucent: factor [
	"Make up a BitBlt table and copy the bits with the given colorMap."
	(BitBlt destForm: self
		sourceForm: sourceForm
		halftoneForm: nil
		combinationRule: 31
		destOrigin: destOrigin
		sourceOrigin: 0@0
		extent: sourceForm extent
		clipRect: self boundingBox)
		copyBitsTranslucent: ((0 max: (factor*255.0) asInteger) min: 255)
"
 | f f2 f3 | f := Form fromUser. f replaceColor: f peripheralColor withColor: Color transparent.
f2 := Form fromDisplay: (0@0 extent: f extent). f3 := f2 deepCopy.
0.0 to: 1.0 by: 1.0/32 do:
	[:t | f3 := f2 deepCopy. f3 paintBits: f at: 0@0 translucent: t.
	f3 displayAt: 0@0. (Delay forMilliseconds: 100) wait].
"
]

{ #category : #analyzing }
Form >> pixelCompare: aRect with: otherForm at: otherLoc [
	"Compare the selected bits of this form (those within aRect) against
	those in a similar rectangle of otherFrom.  Return the sum of the
	absolute value of the differences of the color values of every pixel.
	Obviously, this is most useful for rgb (16- or 32-bit) pixels but,
	in the case of 8-bits or less, this will return the sum of the differing
	bits of the corresponding pixel values (somewhat less useful)"
	| pixPerWord temp |
	pixPerWord := 32//self depth.
	(aRect left\\pixPerWord = 0 and: [aRect right\\pixPerWord = 0]) ifTrue:
		["If word-aligned, use on-the-fly difference"
		^ (BitBlt toForm: self) copy: aRect from: otherLoc in: otherForm
				fillColor: nil rule: 32].
	"Otherwise, combine in a word-sized form and then compute difference"
	temp := self copy: aRect.
	temp copy: aRect from: otherLoc in: otherForm rule: 21.
	^ (BitBlt toForm: temp) copy: aRect from: otherLoc in: nil
				fillColor: (Bitmap with: 0) rule: 32
"  Dumb example prints zero only when you move over the original rectangle...
 | f diff | f := Form fromUser.
[Sensor anyButtonPressed] whileFalse:
	[diff := f pixelCompare: f boundingBox
		with: Display at: Sensor cursorPoint.
	diff printString , '        ' displayAt: 0@0]
"
]

{ #category : #'pixel access' }
Form >> pixelValueAt: aPoint [ 
	"Return the raw pixel value at the given point. This pixel value depends on the receiver's depth. Typical clients use colorAt: to get a Color.  "

	^ (BitBlt bitPeekerFromForm: self) pixelAt: aPoint

]

{ #category : #'pixel access' }
Form >> pixelValueAt: aPoint put: pixelValue [
	"Store the given raw pixel value at the given point. Typical clients use colorAt:put: to store a color. "

	(BitBlt bitPokerToForm: self) pixelAt: aPoint put: pixelValue.

]

{ #category : #'color mapping' }
Form >> pixelValueFor: aColor [
	"Return the pixel word for representing the given color on the receiver"

	^ self hasNonStandardPalette
		ifTrue: [ self colormapFromARGB mapPixel: (aColor pixelValueForDepth: 32) ]
		ifFalse: [ aColor pixelValueForDepth: self depth ]
]

{ #category : #'color mapping' }
Form >> pixelWordFor: aColor [
	"Return the pixel word for representing the given color on the receiver"

	| basicPattern |
	self hasNonStandardPalette ifFalse: [ ^ aColor pixelWordForDepth: self depth ].
	basicPattern := self pixelValueFor: aColor.
	^ self depth = 32
		ifTrue: [ basicPattern ]
		ifFalse: [ aColor pixelWordFor: self depth filledWith: basicPattern ]
]

{ #category : #other }
Form >> preMultiplyAlpha [
	"Pre-multiply each pixel by its alpha, for proper alpha compositing (BitBlt rule 34).
	E.g., half-transparent green 16r7F00FF00 becomes 16r7F007F00"

	depth = 32 ifFalse: [^self].
	1 to: bits size do: [:i |
		| v a r g b |
		v := bits at: i.
		a := v bitShift: -24.
		r := ((v bitShift: -16) bitAnd: 255) * a // 255.
		g := ((v bitShift: -8) bitAnd: 255) * a // 255.
		b := (v bitAnd: 255) * a // 255.
		bits at: i put: (a bitShift: 24) + (r bitShift: 16) + (g bitShift: 8) + b].
]

{ #category : #analyzing }
Form >> primCountBits [
	"Count the non-zero pixels of this form."
	self depth > 8 ifTrue:
		[^(self asFormOfDepth: 8) primCountBits].
	^ (BitBlt toForm: self)
		fillColor: (Bitmap with: 0);
		destRect: (0@0 extent: width@height);
		combinationRule: 32;
		copyBits
]

{ #category : #other }
Form >> primPrintHScale: hScale vScale: vScale landscape: aBoolean [
	"On platforms that support it, this primitive prints the receiver, assumed to be a Form, to the default printer."
	"(Form extent: 10@10) primPrintHScale: 1.0 vScale: 1.0 landscape: true"

	<primitive: 232>
	self primitiveFailed

]

{ #category : #printing }
Form >> printOn: aStream [
    aStream
        nextPutAll: self class name;
        nextPut: $(; print: width;
        nextPut: $x; print: height;
        nextPut: $x; print: depth;
        nextPut: $).

]

{ #category : #private }
Form >> privateFloodFillValue: aColor [
	"Private. Compute the pixel value in the receiver's depth but take into account implicit color conversions by BitBlt."
	| f1 f2 bb |
	f1 := Form extent: 1@1 depth: depth.
	f2 := Form extent: 1@1 depth: 32.
	bb := BitBlt toForm: f1.
	bb fillColor: aColor; 
		destRect: (0@0 corner: 1@1); 
		combinationRule: 3; 
		copyBits.
	bb := BitBlt toForm: f2.
	bb sourceForm: f1; 
		sourceOrigin: 0@0;
		destRect: (0@0 corner: 1@1);
		combinationRule: 3;
		copyBits.
	^f2 pixelValueAt: 0@0.
]

{ #category : #'file in/out' }
Form >> readAttributesFrom: aBinaryStream [
	| offsetX offsetY |
	depth := aBinaryStream next.
	(self depth isPowerOfTwo and: [self depth between: 1 and: 32])
		ifFalse: [self error: 'invalid depth; bad Form file?'].
	width := aBinaryStream nextWord.
	height := aBinaryStream nextWord.
	offsetX  := aBinaryStream nextWord.
	offsetY := aBinaryStream nextWord.
	offsetX > 32767 ifTrue: [offsetX := offsetX - 65536].
	offsetY > 32767 ifTrue: [offsetY := offsetY - 65536].
	offset := Point x: offsetX y: offsetY.
	

]

{ #category : #'file in/out' }
Form >> readBitsFrom: aBinaryStream [
	
	bits := Bitmap newFromStream: aBinaryStream.
	bits size = self bitsSize ifFalse: [self error: 'wrong bitmap size; bad Form file?'].
	^ self

]

{ #category : #'file in/out' }
Form >> readFrom: aBinaryStream [
	"Reads the receiver from the given binary stream with the format:
		depth, extent, offset, bits."
	self readAttributesFrom: aBinaryStream.
	self readBitsFrom: aBinaryStream
]

{ #category : #analyzing }
Form >> rectangleEnclosingPixelsNotOfColor: aColor [
	"Answer the smallest rectangle enclosing all the pixels of me that are different from the given color. Useful for extracting a foreground graphic from its background."

	| cm slice copyBlt countBlt top bottom newH left right |
	"map the specified color to 1 and all others to 0"
	cm := Bitmap new: (1 bitShift: (self depth min: 15)).
	cm primFill: 1.
	cm at: (aColor indexInMap: cm) put: 0.

	"build a 1-pixel high horizontal slice and BitBlts for counting pixels of interest"
	slice := Form extent: width @ 1 depth: 1.
	copyBlt := (BitBlt toForm: slice)
		sourceForm: self;
		combinationRule: Form over;
		destX: 0
			destY: 0
			width: width
			height: 1;
		colorMap: cm.
	countBlt := (BitBlt toForm: slice)
		fillColor: (Bitmap with: 0);
		destRect: (0 @ 0 extent: slice extent);
		combinationRule: 32.

	"scan in from top and bottom"
	top := (0 to: height)
		detect: [ :y | 
			copyBlt
				sourceOrigin: 0 @ y;
				copyBits.
			countBlt copyBits > 0 ]
		ifNone: [ ^ 0 @ 0 extent: 0 @ 0 ].
	bottom := (height - 1 to: top by: -1)
		detect: [ :y | 
			copyBlt
				sourceOrigin: 0 @ y;
				copyBits.
			countBlt copyBits > 0 ].

	"build a 1-pixel wide vertical slice and BitBlts for counting pixels of interest"
	newH := bottom - top + 1.
	slice := Form extent: 1 @ newH depth: 1.
	copyBlt := (BitBlt toForm: slice)
		sourceForm: self;
		combinationRule: Form over;
		destX: 0
			destY: 0
			width: 1
			height: newH;
		colorMap: cm.
	countBlt := (BitBlt toForm: slice)
		fillColor: (Bitmap with: 0);
		destRect: (0 @ 0 extent: slice extent);
		combinationRule: 32.

	"scan in from left and right"
	left := (0 to: width)
		detect: [ :x | 
			copyBlt
				sourceOrigin: x @ top;
				copyBits.
			countBlt copyBits > 0 ].
	right := (width - 1 to: left by: -1)
		detect: [ :x | 
			copyBlt
				sourceOrigin: x @ top;
				copyBits.
			countBlt copyBits > 0 ].
	^ left @ top corner: (right + 1) @ (bottom + 1)
]

{ #category : #'color mapping' }
Form >> reducedPaletteOfSize: nColors [
	"Return an array of colors of size nColors, such that those colors
	represent well the pixel values actually found in this form."
	| threshold tallies colorTallies dist delta palette cts top cluster |
	tallies := self tallyPixelValues.  "An array of tallies for each pixel value"
	threshold := width * height // 500.

	"Make an array of (color -> tally) for all tallies over threshold"
	colorTallies := Array streamContents:
		[:s | tallies withIndexDo:
			[:v :i | v >= threshold ifTrue:
				[s nextPut: (Color colorFromPixelValue: i-1 depth: depth) -> v]]].

	"Extract a set of clusters by picking the top tally, and then removing all others
	whose color is within dist of it.  Iterate the process, adjusting dist until we get nColors."
	dist := 0.2.  delta := dist / 2.
		[cts := colorTallies copy.
		palette := Array streamContents: [:s |
			[cts isEmpty] whileFalse:
				[top := cts detectMax: [:a | a value].
				cluster := cts select: [:a | (a key diff: top key) < dist].
				s nextPut: top key -> (cluster sum: [:a | a value]).
				cts := cts copyWithoutAll: cluster]].
		palette size = nColors or: [delta < 0.001]]
		whileFalse:
			[dist := palette size > nColors
				ifTrue: [dist + delta]
				ifFalse: [dist - delta].
			delta := delta / 2].
	^ palette collect: [:a | a key]

]

{ #category : #other }
Form >> relativeTextAnchorPosition [

	^nil		"so forms can be in TextAnchors"
]

{ #category : #'file in/out' }
Form >> replaceByResource: aForm [
	"Replace the receiver by some resource that just got loaded"
	(self extent = aForm extent and:[self depth = aForm depth]) ifTrue:[
		bits := aForm bits.
	].
]

{ #category : #'image manipulation' }
Form >> replaceColor: oldColor withColor: newColor [
	"Replace one color with another everywhere is this form"

	| cm newInd target ff |
	self depth = 32
		ifTrue: [cm := (Color  cachedColormapFrom: 16 to: 32) copy]
		ifFalse: [cm := Bitmap new: (1 bitShift: (self depth min: 15)).
				1 to: cm size do: [:i | cm at: i put: i - 1]].
	newInd := newColor pixelValueForDepth: self depth.
	cm at: (oldColor pixelValueForDepth: (self depth min: 16))+1 put: newInd.
	target := newColor isTransparent 
		ifTrue: [ff := Form extent: self extent depth: depth.
			ff fillWithColor: newColor.  ff]
		ifFalse: [self].
	(BitBlt toForm: target)
		sourceForm: self;
		sourceOrigin: 0@0;
		combinationRule: Form paint;
		destX: 0 destY: 0 width: width height: height;
		colorMap: cm;
		copyBits.
	newColor = Color transparent 
		ifTrue: [target displayOn: self].
]

{ #category : #'color mapping' }
Form >> rgbaBitMasks [
	"Return the masks for specifying the R,G,B, and A components in the receiver"
	self depth <= 8
		ifTrue:[^#(16rFF0000 16rFF00 16rFF 16rFF000000)].
	self depth = 16
		ifTrue:[^#(16r7C00 16r3E0 16r1F 16r0)].
	self depth = 32
		ifTrue:[^#(16rFF0000 16rFF00 16rFF 16rFF000000)].
	self error:'Bad depth for form'
]

{ #category : #'scaling, rotation' }
Form >> rotateBy: deg [
	"Rotate the receiver by the indicated number of degrees."
	"rot is the destination form, bit enough for any angle."

	^ self rotateBy: deg smoothing: 1
"
 | a f |  f := Form fromDisplay: (0@0 extent: 200@200).  a := 0.
[Sensor anyButtonPressed] whileFalse:
	[((Form fromDisplay: (Sensor cursorPoint extent: 130@66))
		rotateBy: (a := a+5)) display].
f display
"
]

{ #category : #'scaling, rotation' }
Form >> rotateBy: direction centerAt: aPoint [
	"Return a rotated copy of the receiver. 
	direction = #none, #right, #left, or #pi"
	| newForm quad rot scale |
	direction == #none ifTrue: [^ self].
	scale :=  (direction = #pi ifTrue: [width@height] ifFalse: [height@width]) / self extent .
	newForm := self blankCopyOf: self boundingBox scaledBy: scale.
	quad := self boundingBox innerCorners.
	rot := #(right pi left) indexOf: direction.
	(WarpBlt toForm: newForm)
		sourceForm: self;
		colorMap: (self colormapIfNeededFor: newForm);
		combinationRule: 3;
		copyQuad: ((1+rot to: 4+rot) collect: [:i | quad atWrap: i])
			 toRect: newForm boundingBox.
	newForm offset: (self offset rotateBy: direction centerAt: aPoint).
	^ newForm
"
[Sensor anyButtonPressed] whileFalse:
	[((Form fromDisplay: (Sensor cursorPoint extent: 130@66))
		rotateBy: #left centerAt: 0@0) display]
"
"Consistency test...
 | f f2 p | [Sensor anyButtonPressed] whileFalse:
	[f := Form fromDisplay: ((p := Sensor cursorPoint) extent: 31@41).
	Display fillBlack: (p extent: 31@41).
	f2 := f rotateBy: #left centerAt: 0@0.
	(f2 rotateBy: #right centerAt: 0@0) displayAt: p]
"

]

{ #category : #'scaling, rotation' }
Form >> rotateBy: deg magnify: scale smoothing: cellSize [
	"Rotate the receiver by the indicated number of degrees and magnify. scale can be a Point to make for interesting 3D effects "
	"rot is the destination form, big enough for any angle."

	| side rot warp r1 pts bigSide |
	side := 1 + self extent r asInteger.
	bigSide := (side asPoint * scale) rounded.
	rot := self blankCopyOf: self boundingBox scaledBy: ( bigSide / self extent ).
	warp := (WarpBlt toForm: rot)
		sourceForm: self;
		colorMap: (self colormapIfNeededFor: rot);
		cellSize: cellSize;  "installs a new colormap if cellSize > 1"
		combinationRule: Form paint.
	r1 := (0@0 extent: side@side) align: (side@side)//2 with: self boundingBox center.

	"Rotate the corners of the source rectangle." 
	pts := r1 innerCorners collect:
		[:pt | | p | p := pt - r1 center.
		(r1 center x asFloat + (p x asFloat*deg degreeCos) + (p y asFloat*deg degreeSin)) @
		(r1 center y asFloat - (p x asFloat*deg degreeSin) + (p y asFloat*deg degreeCos))].
	warp copyQuad: pts toRect: rot boundingBox.
	^ rot
"
 | a f |  f := Form fromDisplay: (0@0 extent: 200@200).  a := 0.
[Sensor anyButtonPressed] whileFalse:
	[((Form fromDisplay: (Sensor cursorPoint extent: 130@66))
		rotateBy: (a := a+5) magnify: 0.75@2 smoothing: 2) display].
f display
"
]

{ #category : #'scaling, rotation' }
Form >> rotateBy: deg smoothing: cellSize [
	"Rotate the receiver by the indicated number of degrees."
	^self rotateBy: deg magnify: 1 smoothing: cellSize
"
 | a f |  f := Form fromDisplay: (0@0 extent: 200@200).  a := 0.
[Sensor anyButtonPressed] whileFalse:
	[((Form fromDisplay: (Sensor cursorPoint extent: 130@66))
		rotateBy: (a := a+5) smoothing: 2) display].
f display
"
]

{ #category : #'scaling, rotation' }
Form >> scaledToSize: newExtent [

	| scale |

	newExtent = self extent ifTrue: [^self].
	scale := newExtent x / self width min: newExtent y / self height.
	^self magnify: self boundingBox by: scale smoothing: 2.

]

{ #category : #private }
Form >> setExtent: extent depth: bitsPerPixel [
	"Create a virtual bit map with the given extent and bitsPerPixel."

	width := extent x asInteger.
	width < 0 ifTrue: [width := 0].
	height := extent y asInteger.
	height < 0 ifTrue: [height := 0].
	depth := bitsPerPixel.
	bits := Bitmap new: self bitsSize
]

{ #category : #private }
Form >> setExtent: extent depth: bitsPerPixel bits: bitmap [
	"Create a virtual bit map with the given extent and bitsPerPixel."

	width := extent x asInteger.
	width < 0 ifTrue: [width := 0].
	height := extent y asInteger.
	height < 0 ifTrue: [height := 0].
	depth := bitsPerPixel.
	(bits isNil or:[self bitsSize = bitmap size]) ifFalse:[^self error:'Bad dimensions'].
	bits := bitmap
]

{ #category : #private }
Form >> setResourceBits: aForm [
	"Private. Really. Used for setting the 'resource bits' when externalizing some form"
	bits := aForm.
]

{ #category : #testing }
Form >> shouldPreserveContents [
	"Return true if the receiver should preserve it's contents when flagged to be clean. Most forms can not be trivially restored by some drawing operation but some may."
	^true
]

{ #category : #'scaling, rotation' }
Form >> shrink: aRectangle by: scale [ 
	| scalePt |
	scalePt := scale asPoint.
	^ self magnify: aRectangle by: (1.0 / scalePt x asFloat) @ (1.0 / scalePt y asFloat)
]

{ #category : #initialization }
Form >> shutDown [
	"The system is going down. Try to preserve some space"
	self hibernate
]

{ #category : #transitions }
Form >> slideImage: otherImage at: topLeft delta: delta [
	"Display slideImage: (Form fromDisplay: (40@40 extent: 300@300)) reverse
		at: 40@40 delta: 3@-4"
	| bb nSteps clipRect |
	bb := otherImage boundingBox.
	clipRect := topLeft extent: otherImage extent.
	nSteps := 1.
	delta x = 0 ifFalse: [nSteps := nSteps max: (bb width//delta x abs) + 1].
	delta y = 0 ifFalse: [nSteps := nSteps max: (bb height//delta y abs) + 1].
	1 to: nSteps do:
			[:i | self copyBits: bb from: otherImage
				at: delta*(i-nSteps) + topLeft
				clippingBox: clipRect rule: Form paint fillColor: nil.
			Display forceDisplayUpdate]
]

{ #category : #'image manipulation' }
Form >> smear: dir distance: dist [
	"Smear any black pixels in this form in the direction dir in Log N steps"
	| skew bb |
	bb := BitBlt destForm: self sourceForm: self fillColor: nil
		combinationRule: Form under destOrigin: 0@0 sourceOrigin: 0@0
		extent: self extent clipRect: self boundingBox.
	skew := 1.
	[skew < dist] whileTrue:
		[bb destOrigin: dir*skew; copyBits.
		skew := skew+skew]
]

{ #category : #'file in/out' }
Form >> store15To24HexBitsOn:aStream [

	| buf lineWidth |

	"write data for 16-bit form, optimized for encoders writing directly to files to do one single file write rather than 12. I'm not sure I understand the significance of the shifting pattern, but I think I faithfully translated it from the original"

	lineWidth := 0.
	buf := String new: 12.
	bits do: [:word | | i | 
		i := 0.
		"upper pixel"
		buf at: (i := i + 1) put: ((word bitShift: -27) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -32) bitAnd: 8) asHexDigit.

		buf at: (i := i + 1) put: ((word bitShift: -22) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -27) bitAnd: 8) asHexDigit.

		buf at: (i := i + 1) put: ((word bitShift: -17) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -22) bitAnd: 8) asHexDigit.

		"lower pixel"

		buf at: (i := i + 1) put: ((word bitShift: -11) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -16) bitAnd: 8) asHexDigit.

		buf at: (i := i + 1) put: ((word bitShift: -6) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -11) bitAnd: 8) asHexDigit.

		buf at: (i := i + 1) put: ((word bitShift: -1) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -6) bitAnd: 8) asHexDigit.
		aStream nextPutAll: buf.
		lineWidth := lineWidth + 12.
		lineWidth > 100 ifTrue: [ aStream cr. lineWidth := 0 ].
		"#( 31 26 21 15 10 5 )  do:[:startBit | ]"
	].
]

{ #category : #'file in/out' }
Form >> store32To24HexBitsOn:aStream [
	^self storeBits:20 to:0 on:aStream.
]

{ #category : #'file in/out' }
Form >> storeBits:startBit to:stopBit on:aStream [
	bits storeBits:startBit to:stopBit on:aStream.
]

{ #category : #'file in/out' }
Form >> storeBitsOn:aStream base:anInteger [
	bits do: [:word | 
		anInteger = 10
			ifTrue: [aStream space]
			ifFalse: [aStream crtab: 2].
		word storeOn: aStream base: anInteger].

]

{ #category : #'file in/out' }
Form >> storeHexBitsOn:aStream [
	^self storeBits:28 to:0 on:aStream.
]

{ #category : #'file in/out' }
Form >> storeOn: aStream [

	self storeOn: aStream base: 10
]

{ #category : #'file in/out' }
Form >> storeOn: aStream base: anInteger [ 
	"Store the receiver out as an expression that can be evaluated to recreate a Form with the same contents as the original."

	self unhibernate.
	aStream nextPut: $(.
	aStream nextPutAll: self species name.
	aStream crtab: 1.
	aStream nextPutAll: 'extent: '.
	self extent printOn: aStream.
	aStream crtab: 1.
	aStream nextPutAll: 'depth: '.
	self depth printOn: aStream.
	aStream crtab: 1.
	aStream nextPutAll: 'fromArray: #('.
	self storeBitsOn:aStream base:anInteger.
	aStream nextPut: $).
	aStream crtab: 1.
	aStream nextPutAll: 'offset: '.
	self offset printOn: aStream.
	aStream nextPut: $).

]

{ #category : #initialization }
Form >> swapEndianness [
	"Swap from big to little endian pixels and vice versa"
	depth := 0 - depth.
]

{ #category : #analyzing }
Form >> tallyPixelValues [
	"Answer a Bitmap whose elements contain the number of pixels in this Form with the pixel value corresponding to their index. Note that the pixels of multiple Forms can be tallied together using tallyPixelValuesInRect:into:."

	^ self tallyPixelValuesInRect: self boundingBox
		into: (Bitmap new: (1 bitShift: (self depth min: 15)))
"
Move a little rectangle around the screen and print its tallies...
 | r tallies nonZero |
Cursor blank showWhile: [
[Sensor anyButtonPressed] whileFalse:
	[r := Sensor cursorPoint extent: 10@10.
	Display border: (r expandBy: 2) width: 2 rule: Form reverse fillColor: nil.
	tallies := (Display copy: r) tallyPixelValues.
	nonZero := (1 to: tallies size) select: [:i | (tallies at: i) > 0]
			thenCollect: [:i | (tallies at: i) -> (i-1)].
	nonZero printString , '          ' displayAt: 0@0.
	Display border: (r expandBy: 2) width: 2 rule: Form reverse fillColor: nil]]
"

]

{ #category : #analyzing }
Form >> tallyPixelValuesInRect: destRect into: valueTable [
	"Tally the selected pixels of this Form into valueTable, a Bitmap of depth 2^depth similar to a color map. Answer valueTable."

	(BitBlt toForm: self)
		sourceForm: self;  "src must be given for color map ops"
		sourceOrigin: 0@0;
		tallyMap: valueTable;
		combinationRule: 33;
		destRect: destRect;
		copyBits.
	^ valueTable

"
Move a little rectangle around the screen and print its tallies...
 | r tallies nonZero |
Cursor blank showWhile: [
[Sensor anyButtonPressed] whileFalse:
	[r := Sensor cursorPoint extent: 10@10.
	Display border: (r expandBy: 2) width: 2 rule: Form reverse fillColor: nil.
	tallies := (Display copy: r) tallyPixelValues.
	nonZero := (1 to: tallies size) select: [:i | (tallies at: i) > 0]
			thenCollect: [:i | (tallies at: i) -> (i-1)].
	nonZero printString , '          ' displayAt: 0@0.
	Display border: (r expandBy: 2) width: 2 rule: Form reverse fillColor: nil]]
"
]

{ #category : #'image manipulation' }
Form >> trimBordersOfColor: aColor [
	"Answer a copy of this Form with each edge trimmed in to the first pixel that is not of the given color. (That is, border strips of the given color are removed)."

	| r |
	r := self rectangleEnclosingPixelsNotOfColor: aColor.
	^ self copy: r

]

{ #category : #'file in/out' }
Form >> unhibernate [
	"If my bitmap has been compressed into a ByteArray,
	then expand it now, and return true."
	| resBits |
	bits isForm ifTrue:[
		resBits := bits.
		bits := Bitmap new: self bitsSize.
		resBits displayResourceFormOn: self.
		^true].
	bits == nil ifTrue:[bits := Bitmap new: self bitsSize. ^true].
	(bits isMemberOf: ByteArray)
		ifTrue: [bits := Bitmap decompressFromByteArray: bits. ^ true].
	^ false
]

{ #category : #copying }
Form >> veryDeepCopyWith: deepCopier [
	"Return self.  I am immutable in the Morphic world.  Do not record me."
	^ self
]

{ #category : #accessing }
Form >> width [
	^ width
]

{ #category : #transitions }
Form >> wipeImage: otherImage at: topLeft clippingBox: clipBox rectForIndex: rectForIndexBlock [

	| i clipRect t rectOrList waitTime |
	i := 0.
	clipRect := topLeft extent: otherImage extent.
	clipBox ifNotNil: [clipRect := clipRect intersect: clipBox ifNone: [ ^ self ]].
	[rectOrList := rectForIndexBlock value: (i := i + 1).
	 rectOrList == nil]
		whileFalse: [
			t := Time millisecondClockValue.
			rectOrList asOrderedCollection do: [:r |
				self copyBits: r from: otherImage at: topLeft + r topLeft
					clippingBox: clipRect rule: Form over fillColor: nil].
			Display forceDisplayUpdate.
			waitTime := 3 - (Time millisecondClockValue - t).
			waitTime > 0 ifTrue:
				["(Delay forMilliseconds: waitTime) wait"]].

]

{ #category : #transitions }
Form >> wipeImage: otherImage at: topLeft delta: delta [
	"Display wipeImage: (Form fromDisplay: (40@40 extent: 300@300)) reverse
		at: 40@40 delta: 0@-2"

	self wipeImage: otherImage at: topLeft delta: delta clippingBox: nil.

]

{ #category : #transitions }
Form >> wipeImage: otherImage at: topLeft delta: delta clippingBox: clipBox [

	| wipeRect bb nSteps |
	bb := otherImage boundingBox.
	wipeRect := delta x = 0
		ifTrue:
		[delta y = 0 ifTrue: [nSteps := 1. bb "allow 0@0"] ifFalse: [
		nSteps := bb height//delta y abs + 1.  "Vertical movement"
		delta y > 0
			ifTrue: [bb topLeft extent: bb width@delta y]
			ifFalse: [bb bottomLeft+delta extent: bb width@delta y negated]]]
		ifFalse:
		[nSteps := bb width//delta x abs + 1.  "Horizontal movement"
		delta x > 0
			ifTrue: [bb topLeft extent: delta x@bb height]
			ifFalse: [bb topRight+delta extent: delta x negated@bb height]].
	^ self wipeImage: otherImage at: topLeft clippingBox: clipBox rectForIndex:
		[:i | i <= nSteps
			ifTrue: [wipeRect translateBy: (delta* (i-1))]
			ifFalse: [nil]]
]

{ #category : #converting }
Form >> withAlphaExtractedFromSubpixelRendering [
	^ (self asFormOfDepth: 32) collectColors: [ :c |
		| r g b a|
		r := c red.
		g := c green.
		b := c blue.
		a := c alpha.
		a := ((r max: g) max: b) * a.
		
		Color r: r g: g b: b alpha: a
	]
]

{ #category : #'file in/out' }
Form >> writeAttributesOn: file [
	self unhibernate.
	file nextPut: depth.
	file nextWordPut: width.
	file nextWordPut: height.
	file nextWordPut: ((self offset x) >=0
					ifTrue: [self offset x]
					ifFalse: [self offset x + 65536]).
	file nextWordPut: ((self offset y) >=0
					ifTrue: [self offset y]
					ifFalse: [self offset y + 65536]).
	
]

{ #category : #'file in/out' }
Form >> writeBitsOn: file [
	bits writeOn: file
]

{ #category : #'file in/out' }
Form >> writeOn: file [
	"Write the receiver on the file in the format
		depth, extent, offset, bits."
	self writeAttributesOn: file.
	self writeBitsOn: file
]

{ #category : #'file in/out' }
Form >> writeUncompressedOn: file [
	"Write the receiver on the file in the format depth, extent, offset, bits.  Warning:  Caller must put header info on file!  Use writeUncompressedOnFileNamed: instead."
	self unhibernate.
	file binary.
	file nextPut: depth.
	file nextWordPut: width.
	file nextWordPut: height.
	file nextWordPut: ((self offset x) >=0
					ifTrue: [self offset x]
					ifFalse: [self offset x + 65536]).
	file nextWordPut: ((self offset y) >=0
					ifTrue: [self offset y]
					ifFalse: [self offset y + 65536]).
	bits writeUncompressedOn: file
]

{ #category : #analyzing }
Form >> xTallyPixelValue: pv orNot: not [
	"Return an array of the number of pixels with value pv by x-value.
	Note that if not is true, then this will tally those different from pv."
	| cm slice countBlt copyBlt |
	cm := self newColorMap.		"Map all colors but pv to zero"
	not ifTrue: [cm atAllPut: 1].		"... or all but pv to one"
	cm at: pv+1 put: 1 - (cm at: pv+1).
	slice := Form extent: 1@height.
	copyBlt := (BitBlt destForm: slice sourceForm: self
				halftoneForm: nil combinationRule: Form over
				destOrigin: 0@0 sourceOrigin: 0@0 extent: 1 @ slice height
				clipRect: slice boundingBox) colorMap: cm.
	countBlt := (BitBlt toForm: slice)
				fillColor: (Bitmap with: 0);
				destRect: (0@0 extent: slice extent);
				combinationRule: 32.
	^ (0 to: width-1) collect:
		[:x |
		copyBlt sourceOrigin: x@0; copyBits.
		countBlt copyBits]
]

{ #category : #analyzing }
Form >> yTallyPixelValue: pv orNot: not [
	"Return an array of the number of pixels with value pv by y-value.
	Note that if not is true, then this will tally those different from pv."
	| cm slice copyBlt countBlt |
	cm := self newColorMap.		"Map all colors but pv to zero"
	not ifTrue: [cm atAllPut: 1].		"... or all but pv to one"
	cm at: pv+1 put: 1 - (cm at: pv+1).
	slice := Form extent: width@1.
	copyBlt := (BitBlt destForm: slice sourceForm: self
				halftoneForm: nil combinationRule: Form over
				destOrigin: 0@0 sourceOrigin: 0@0 extent: slice width @ 1
				clipRect: slice boundingBox) colorMap: cm.
	countBlt := (BitBlt toForm: slice)
				fillColor: (Bitmap with: 0);
				destRect: (0@0 extent: slice extent);
				combinationRule: 32.
	^ (0 to: height-1) collect:
		[:y |
		copyBlt sourceOrigin: 0@y; copyBits.
		countBlt copyBits]
]

{ #category : #transitions }
Form >> zoomIn: goingIn orOutTo: otherImage at: topLeft vanishingPoint: vp [ 
	"Display zoomInTo: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40.
	Display zoomOutTo: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40."
	| nSteps minTime startTime |
	nSteps := 16.
	minTime := 500.  "milliseconds"
	startTime := Time millisecondClockValue.
	^ self wipeImage: otherImage at: topLeft clippingBox: nil rectForIndex:
		[:i | | bigR j lilR lead | "i runs from 1 to nsteps"
		i > nSteps
			ifTrue: [nil "indicates all done"]
			ifFalse:
			["If we are going too fast, delay for a bit"
			lead := startTime + (i-1*minTime//nSteps) - Time millisecondClockValue.
			lead > 10 ifTrue: [(Delay forMilliseconds: lead) wait].

			"Return an array with the difference rectangles for this step."
			j := goingIn ifTrue: [i] ifFalse: [nSteps+1-i].
			bigR := vp - (vp*(j)//nSteps) corner:
				vp + (otherImage extent-vp*(j)//nSteps).
			lilR := vp - (vp*(j-1)//nSteps) corner:
				vp + (otherImage extent-vp*(j-1)//nSteps).
			bigR areasOutside: lilR]]
]

{ #category : #transitions }
Form >> zoomInTo: otherImage at: topLeft [
	"Display zoomInTo: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40"
	^ self zoomIn: true orOutTo: otherImage at: topLeft
		vanishingPoint: otherImage extent//2+topLeft
]

{ #category : #transitions }
Form >> zoomOutTo: otherImage at: topLeft [
	"Display zoomOutTo: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40"
	^ self zoomIn: false orOutTo: otherImage at: topLeft
		vanishingPoint: otherImage extent//2+topLeft
]
