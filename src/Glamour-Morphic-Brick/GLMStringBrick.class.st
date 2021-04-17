"
A GLMStringBrick is low level String Brick. Text can't be drawn outside of Brick's bounds, which makes it very usefull for smart text shrinking.

Instance Variables
	familyName:		<Object>
	font:		<Object>
	fontSize:		<Object>
	text:		<Object>
	textColor:		<Object>
	textPosition:		<Object>
	textSize:		<Object>

familyName
	- xxxxx

font
	- xxxxx

fontSize
	- xxxxx

text
	- xxxxx

textColor
	- xxxxx

textPosition
	- xxxxx

textSize
	- xxxxx

"
Class {
	#name : #GLMStringBrick,
	#superclass : #GLMInteractableBrick,
	#instVars : [
		'font',
		'familyName',
		'fontSize',
		'textSize',
		'text',
		'textPosition',
		'highlightedString'
	],
	#category : #'Glamour-Morphic-Brick-Widgets-Core'
}

{ #category : #examples }
GLMStringBrick class >> example [

	| brick brick1 brick2 brick3|
	brick := GLMBrick new
		color: Color blue;
		width: 400;
		height: 300.
		
	brick1 := self new
		color: Color red;
		hSpaceFill: 75;
		vSpaceFill: 25;
		textPosition: #center;
		text: 'Brick 1'.
	
	brick2 := self new
		color: Color green;
		hSpaceFill: 25;
		vSpaceFill: 75;
		textPosition: #center;
		text: 'Brick 2'.
	
	brick3 := self new
		color: Color yellow;
		width: 50;
		height: 50;
		textPosition: #center;
		text: 'Brick 3'.
	
	brick
		addBrickBack: brick1;
		addBrickBack: brick2;
		addBrickBack: brick3.
		
	brick asBrickedMorph
		color: Color white;
		openInWindow
]

{ #category : #geometry }
GLMStringBrick >> approximateHeight [

	^ self font height + self vMargin + self vPadding
]

{ #category : #geometry }
GLMStringBrick >> approximateWidth [

	^ self textSize x + self hMargin + self hPadding
]

{ #category : #accessing }
GLMStringBrick >> beBold [

	self font forceBold
]

{ #category : #accessing }
GLMStringBrick >> beRegular [

	self font
		forceNotBold;
		forceNotItalic
]

{ #category : #accessing }
GLMStringBrick >> calculateHighlightingBounds [
	|textBounds highlightBounds last|
	
	highlightBounds := OrderedCollection new.
	
	textBounds := (self calculateTextPosition extent: self textSize) translateBy: (0@0)negated.
	
	last := self text asLowercase findString: self highlightedText asLowercase startingAt: 1.
	last = 0 ifTrue: [^ highlightBounds].
	[last > 0] whileTrue: [ |beforeHighlightTextSize highlightSize matchingString|		
		matchingString := self text copyFrom: last to: last + self highlightedText size - 1.
		highlightSize := self sizeOf: matchingString.
		beforeHighlightTextSize := self sizeOf: (self text first: (last - 1)).
		highlightBounds add: ((textBounds translateBy: ((beforeHighlightTextSize x)@0)) withWidth: highlightSize x).
		last := self text asLowercase findString: self highlightedText asLowercase startingAt: last + 1 ].
	
	^ highlightBounds
]

{ #category : #accessing }
GLMStringBrick >> calculateTextPosition [

	self textPosition = #leftCenter ifTrue: [ 
		^ (self brickBounds origin + self textPositionVerticalCenter) truncated
	].

	self textPosition = #center ifTrue: [ 
		^ (self brickBounds origin + self textPositionVerticalCenter + self textPositionHorizontalCenter)floor
	].

	self textPosition = #leftTop ifTrue: [
		^ self brickBounds origin
	].

	self textPosition = #rightCenter ifTrue: [
		^ ((self brickBounds topRight + self textPositionVerticalCenter - (self textSize x@0)) max: self brickBounds origin) floor
	].

	^ self brickBounds origin
]

{ #category : #private }
GLMStringBrick >> customFont [

	font := LogicalFont new
				familyName: self familyName; 
				fallbackFamilyNames: nil;
				pointSize: self fontSize; 
				weightValue: 400;
				stretchValue: 5;
				slantValue: 0;
				yourself
]

{ #category : #accessing }
GLMStringBrick >> familyName [
	^ familyName
]

{ #category : #accessing }
GLMStringBrick >> familyName: aString [
	familyName := aString.
	self updateFont.
]

{ #category : #accessing }
GLMStringBrick >> font [

	^ font
]

{ #category : #accessing }
GLMStringBrick >> font: aFont [

	font := aFont.
	
	aFont ifNil: [ self updateFont ].
	
	familyName := font familyName.
	fontSize := font pointSize.
]

{ #category : #accessing }
GLMStringBrick >> fontSize [
	^ fontSize
]

{ #category : #accessing }
GLMStringBrick >> fontSize: aNumber [
	fontSize := aNumber.
	self updateFont.
]

{ #category : #'brick-layout-properties' }
GLMStringBrick >> hShrinkWrap [
	
	self hResizing: #rigid.
	self width: #approximateWidth
]

{ #category : #public }
GLMStringBrick >> highlight: aString [

	highlightedString := aString.
	self changed
]

{ #category : #accessing }
GLMStringBrick >> highlightedText [
	
	^ highlightedString ifNil: [ highlightedString := '' ]
]

{ #category : #accessing }
GLMStringBrick >> highlightingLogic [
	"[ :aCanvas :aRectangle ]"
	
	^ self valueOfProperty: #brickHighlightingLogic ifAbsentPut: [
		[ :aCanvas :aRectangle | |rectangle|
			"because font calculates text width wrong"
			rectangle := aRectangle translateBy: ((3@1) negated + self brickBounds origin).
			aCanvas line: rectangle bottomLeft to: rectangle bottomRight width: 1 color: self textColor ] ] 
]

{ #category : #accessing }
GLMStringBrick >> highlightingLogic: aBlockWithTwoParameters [
	"[ :aCanvas :aRectangle ]"
	
	self setProperty: #brickHighlightingLogic toValue: aBlockWithTwoParameters
]

{ #category : #initialization }
GLMStringBrick >> initialize [
	super initialize.
	
	fontSize := self themer textFontSize.
	familyName := self themer textFamilyName.
	text := ''.
	
	textPosition := #leftCenter.
	
	self
		hShrinkWrap;
		vShrinkWrap.
	self updateFont.
	
]

{ #category : #testing }
GLMStringBrick >> isFitsInParent [

	^ self owner
		ifNil: [ self brickBounds containsRect: (self outerBounds origin extent: self textSize) ]
		ifNotNil: [ self owner brickBounds width >= self textSize x ]
]

{ #category : #drawing }
GLMStringBrick >> onDraw: aCanvas [

	super onDraw: aCanvas.
	
	self highlightedText isEmpty ifFalse: [
		self calculateHighlightingBounds do: [ :each |
			self highlightingLogic
				ifNil: [ aCanvas line: each bottomLeft to: each bottomRight width: 1 color: self textColor ]
				ifNotNil: [ self highlightingLogic cull: aCanvas cull: each ] ] ].
	
	aCanvas
		drawString: self text
		at: self calculateTextPosition
		font: self font
		color: self textColor
]

{ #category : #drawing }
GLMStringBrick >> onDrawAthensCanvas: aCanvas [
	|wrappedCanvas|
	
	super onDrawAthensCanvas: aCanvas.
	wrappedCanvas := AthensCanvasWrapper on: aCanvas.
	
	self highlightedText isEmpty ifFalse: [
		self calculateHighlightingBounds do: [ :each |
			self highlightingLogic
				ifNil: [ wrappedCanvas line: each bottomLeft to: each bottomRight width: 1 color: self textColor ]
				ifNotNil: [ self highlightingLogic cull: wrappedCanvas cull: each ] ] ].
		
	aCanvas pathTransform restoreAfter:[ 
			aCanvas pathTransform translateBy: (self calculateTextPosition - self brickBounds origin).
			aCanvas pathTransform translateX: 0 Y: font getPreciseAscent.
			"scaled, so that FT-Plugin and Athens don't mix cached faces"
			aCanvas pathTransform scaleBy: 1.0000001 @ 1.0000001.
			aCanvas setPaint: self textColor.
			aCanvas setFont: self font.
			aCanvas drawString: self text from: 1 to: self text size ].
		
	wrappedCanvas
		drawString: self text
		at: (self calculateTextPosition - self brickBounds origin)
		font: self font
		color: self textColor
]

{ #category : #private }
GLMStringBrick >> privateSetText: aString [

	text := aString asString.
	textSize := nil.
]

{ #category : #public }
GLMStringBrick >> sizeOf: aString [

	^ (self font widthOfString: aString) @ self font height
]

{ #category : #accessing }
GLMStringBrick >> text [

	^ text
]

{ #category : #accessing }
GLMStringBrick >> text: aString [

	self privateSetText: aString.
	self wrappedBounds markWidthDirty.
]

{ #category : #'brick-properties' }
GLMStringBrick >> textColor [

	^ self valueOfProperty: #brickTextColor ifAbsent: [ self themer textColor ]
]

{ #category : #'brick-properties' }
GLMStringBrick >> textColor: aColor [

	self setProperty: #brickTextColor toValue: aColor.
	self updateFont.
]

{ #category : #accessing }
GLMStringBrick >> textPosition [

	^ textPosition
]

{ #category : #accessing }
GLMStringBrick >> textPosition: aSymbol [
	"supported:
	#leftCenter
	#center
	#leftTop
	"
	textPosition := aSymbol.
]

{ #category : #geometry }
GLMStringBrick >> textPositionHorizontalCenter [

	^ (((self brickBounds width - self textSize x) max: 0) /2)@0
]

{ #category : #geometry }
GLMStringBrick >> textPositionVerticalCenter [

		^ (0@(self brickBounds height / 2.0)) - (0@(self font height/2.0)) truncated
	
]

{ #category : #accessing }
GLMStringBrick >> textSize [

	^ textSize ifNil: [ textSize := self sizeOf: self text ]
]

{ #category : #private }
GLMStringBrick >> updateFont [
	font := LogicalFont familyName: self familyName pointSize: self fontSize
]

{ #category : #'brick-layout-properties' }
GLMStringBrick >> vShrinkWrap [
	
	self vResizing: #rigid.
	self height: #approximateHeight
]
