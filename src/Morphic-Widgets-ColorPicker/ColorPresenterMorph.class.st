"
Displays a colour with alpha against a white, hatched and black background.
"
Class {
	#name : #ColorPresenterMorph,
	#superclass : #ModelMorphic,
	#instVars : [
		'contentMorph',
		'labelMorph',
		'solidLabelMorph',
		'getColorSelector'
	],
	#classVars : [
		'HatchForm'
	],
	#category : #'Morphic-Widgets-ColorPicker'
}

{ #category : #examples }
ColorPresenterMorph class >> example [
	<sampleInstance>

	^ (ColorPresenterMorph on: (BorderedMorph new) color: #color) openInWorld
]

{ #category : #'graphics constants' }
ColorPresenterMorph class >> hatchForm [
	"Answer a form showing a grid hatch pattern."

	^HatchForm ifNil: [HatchForm := self newHatchForm]
]

{ #category : #'graphics constants' }
ColorPresenterMorph class >> newHatchForm [
	"Answer a new hatch form."
	
	^(Form
	extent: 8@8
	depth: 1
	fromArray: #( 4026531840 4026531840 4026531840 4026531840 251658240 251658240 251658240 251658240)
	offset: 0@0)
]

{ #category : #'instance creation' }
ColorPresenterMorph class >> on: anObject color: getSel [
	"Answer a new instance of the receiver on the given model using
	the given selectors as the interface."
	
	"(ColorPresenterMorph on: (BorderedMorph new) color: #color) openInWorld"
	
	^self new
		on: anObject 
		color: getSel
]

{ #category : #accessing }
ColorPresenterMorph >> contentMorph [
	"Answer the value of contentMorph"

	^ contentMorph
]

{ #category : #accessing }
ColorPresenterMorph >> contentMorph: anObject [
	"Set the value of contentMorph"

	contentMorph := anObject
]

{ #category : #accessing }
ColorPresenterMorph >> getColorSelector [
	"Answer the value of getColorSelector"

	^ getColorSelector
]

{ #category : #accessing }
ColorPresenterMorph >> getColorSelector: anObject [
	"Set the value of getColorSelector"

	getColorSelector := anObject
]

{ #category : #private }
ColorPresenterMorph >> hatchForm [
	"Answer a form showing a grid hatch pattern."

	^self class hatchForm
]

{ #category : #initialization }
ColorPresenterMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		borderWidth: 0;
		changeTableLayout;
		labelMorph: self newLabelMorph;
		solidLabelMorph: self newLabelMorph;
		contentMorph: self newContentMorph;
		addMorphBack: self contentMorph
]

{ #category : #accessing }
ColorPresenterMorph >> labelMorph [
	"Answer the value of labelMorph"

	^ labelMorph
]

{ #category : #accessing }
ColorPresenterMorph >> labelMorph: anObject [
	"Set the value of labelMorph"

	labelMorph := anObject
]

{ #category : #'instance creation' }
ColorPresenterMorph >> newContentMorph [
	"Answer a new content morph"

	^Morph new
		color: Color transparent;
		changeTableLayout;
		borderStyle: (BorderStyle inset width: 1);
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		addMorph: self newHatchMorph;
		yourself
]

{ #category : #'instance creation' }
ColorPresenterMorph >> newHatchMorph [
	"Answer a new morph showing a grid hatch pattern."

	^Morph new
		color: Color transparent;
		changeProportionalLayout;
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		minWidth: 48;
		minHeight: 12;
		addMorph: (Morph new color: Color white)
		fullFrame: (0@0 corner: 0.3@1) asLayoutFrame ;
		addMorph: (Morph new fillStyle: (InfiniteForm with: self hatchForm))
		fullFrame: (0.3@0 corner: 0.7@1) asLayoutFrame;
		addMorph: self solidLabelMorph
		fullFrame: (0.7@0 corner: 1@1) asLayoutFrame;
		addMorph: self labelMorph
		fullFrame: (0@0 corner: 1@1) asLayoutFrame 
]

{ #category : #'instance creation' }
ColorPresenterMorph >> newLabelMorph [
	"Answer a new label morph"

	^Morph new
]

{ #category : #'instance creation' }
ColorPresenterMorph >> on: anObject color: getColSel [
	"Set the receiver to the given model parameterized by the given message selectors."

	self
		model: anObject;
		getColorSelector: getColSel;
		updateColor
]

{ #category : #accessing }
ColorPresenterMorph >> setColor: aColor [
	"Update the colour of the labels."

	self labelMorph color: aColor.
	self solidLabelMorph color: aColor beOpaque
]

{ #category : #accessing }
ColorPresenterMorph >> solidLabelMorph [
	"Answer the value of solidLabelMorph"

	^ solidLabelMorph
]

{ #category : #accessing }
ColorPresenterMorph >> solidLabelMorph: anObject [
	"Set the value of solidLabelMorph"

	solidLabelMorph := anObject
]

{ #category : #updating }
ColorPresenterMorph >> update: aSymbol [ 
	"Refer to the comment in View|update:."

	aSymbol == self getColorSelector ifTrue: 
		[self updateColor.
		^ self]
]

{ #category : #'private - layout' }
ColorPresenterMorph >> updateColor [
	"Update the color state."

	|col|
	self getColorSelector ifNotNil: [
		col := (self model perform: self getColorSelector) ifNil: [Color transparent].
		self setColor: col]
]
