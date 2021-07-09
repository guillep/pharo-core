"
Standard dialog for selecting a colour by HSVA colour selector, picking from the screen or editing of values.
"
Class {
	#name : #ColorSelectorDialogWindow,
	#superclass : #DialogWindowMorph,
	#instVars : [
		'selectedColor',
		'hsvaMorph'
	],
	#category : #'Morphic-Widgets-ColorPicker'
}

{ #category : #accessing }
ColorSelectorDialogWindow >> alpha [
	"Answer the alpha value of the selected color."

	^(self selectedColor alpha * 255) asInteger
]

{ #category : #accessing }
ColorSelectorDialogWindow >> alpha: anInteger [
	"Set the alpha value of the selected color."

	|c|
	c := self selectedColor.
	self selectedColor: (c alpha: anInteger / 255)
]

{ #category : #accessing }
ColorSelectorDialogWindow >> basicSelectedColor: anObject [
	"Set the value of selectedColor"

	selectedColor := anObject.
	
	self
		changed: #selectedColor;
		changed: #red;
		changed: #green;
		changed: #blue;
		changed: #hue;
		changed: #saturation;
		changed: #brightness;
		changed: #alpha.
		
	self announcer announce: (ColorChanged to: selectedColor).
]

{ #category : #constants }
ColorSelectorDialogWindow >> blue [
	"Answer the blue value of the selected color."

	^(self selectedColor blue * 255) asInteger
]

{ #category : #coloring }
ColorSelectorDialogWindow >> blue: anInteger [
	"Set the blue value of the selected color."

	|c|
	c := self selectedColor.
	self selectedColor: ((Color r: c red * 255 g: c green * 255 b: anInteger range: 255) alpha: c alpha)
]

{ #category : #accessing }
ColorSelectorDialogWindow >> brightness [
	"Answer the brightness value of the selected color."

	^(self selectedColor brightness * 255) asInteger
]

{ #category : #accessing }
ColorSelectorDialogWindow >> brightness: anInteger [
	"Set the brightness value of the selected color."

	|c|
	c := self selectedColor.
	self selectedColor: ((Color h: c hue s: c saturation v: anInteger / 255) alpha: c alpha)
]

{ #category : #accessing }
ColorSelectorDialogWindow >> colorSelected: aColor [
	"A color has been selected.."

	self basicSelectedColor: aColor
]

{ #category : #actions }
ColorSelectorDialogWindow >> defaultLabel [
	"Answer the default label for the receiver."

	^'Color Selector' translated
]

{ #category : #constants }
ColorSelectorDialogWindow >> green [
	"Answer the green value of the selected color."

	^(self selectedColor green * 255) asInteger
]

{ #category : #coloring }
ColorSelectorDialogWindow >> green: anInteger [
	"Set the green value of the selected color."

	|c|
	c := self selectedColor.
	self selectedColor: ((Color r: c red * 255 g: anInteger b: c blue * 255 range: 255) alpha: c alpha)
]

{ #category : #accessing }
ColorSelectorDialogWindow >> hsvaMorph [
	"Answer the value of hsvaMorph"

	^ hsvaMorph
]

{ #category : #accessing }
ColorSelectorDialogWindow >> hsvaMorph: anObject [
	"Set the value of hsvaMorph"

	hsvaMorph := anObject
]

{ #category : #accessing }
ColorSelectorDialogWindow >> hue [
	"Answer the hue value of the selected color."

	^(self selectedColor hue / 359 * 255) asInteger
]

{ #category : #accessing }
ColorSelectorDialogWindow >> hue: anInteger [
	"Set the hue value of the selected color."

	|c|
	c := self selectedColor.
	self selectedColor: ((Color h: (anInteger / 255 * 359) rounded s: c saturation v: c brightness) alpha: c alpha)
]

{ #category : #initialization }
ColorSelectorDialogWindow >> initialize [
	"Initialize the receiver."

	self
		basicSelectedColor: Color blue.
	super initialize.
	self selectedColor: self selectedColor
]

{ #category : #actions }
ColorSelectorDialogWindow >> newColorComponentFieldMorph: aspect [
	"Answer a text entry for the specified aspect of the color."

	^(self
		newTextEntryFor: self
		get: aspect
		set: (aspect, ':') asSymbol
		class: Integer
		getEnabled: nil
		help: nil)
		minWidth: 40
]

{ #category : #actions }
ColorSelectorDialogWindow >> newColorPickerButtonMorph [
	"Answer a button to enable picking of colour."

	^ self
		newButtonFor: self
		getState: nil
		action: #pickColor
		arguments: nil
		getEnabled: nil
		labelForm:
			((self iconNamed: #eyedropperIcon)
				scaledIntoFormOfSize: 16)
		help: 'Pick a color from the screen' translated
]

{ #category : #actions }
ColorSelectorDialogWindow >> newColorPresenterMorph [
	"Answer a color presenter."

	^self
		newColorPresenterFor: self
		getColor: #selectedColor 
		help: 'Shows the selected color' translated
]

{ #category : #actions }
ColorSelectorDialogWindow >> newContentMorph [
	"Answer a new content morph."

	self hsvaMorph: self newHSVAColorSelectorMorph.
	^self newRow: {
		self newGroupbox: 'Color' translated forAll: {
			self hsvaMorph.
			(self newRow: {
				(self newLabelGroup: {
					'Selected color' translated -> self newColorPresenterMorph})
					vResizing: #shrinkWrap.
				self newColorPickerButtonMorph})
				cellPositioning: #leftCenter}.
		(self newGroupbox: 'Values' translated for: 
			(self newLabelGroup: {
				'Red' translated -> (self newColorComponentFieldMorph: #red).
				'Green' translated -> (self newColorComponentFieldMorph: #green).
				'Blue' translated -> (self newColorComponentFieldMorph: #blue).
				'Hue' translated -> (self newColorComponentFieldMorph: #hue).
				'Saturation' translated -> (self newColorComponentFieldMorph: #saturation).
				'Brightness' translated -> (self newColorComponentFieldMorph: #brightness).
				'Alpha' translated -> (self newColorComponentFieldMorph: #alpha)}))
			hResizing: #shrinkWrap}
]

{ #category : #actions }
ColorSelectorDialogWindow >> newHSVAColorSelectorMorph [
	"Answer a hsva color selector."

	^HSVAColorSelectorMorph new
		extent: (40@28) + 152;
		when: #selectedColor send: #colorSelected: to: self
]

{ #category : #actions }
ColorSelectorDialogWindow >> pickColor [
	"Pick a colour from the screen."

	| p c h |
	h := self activeHand.
	h
		showTemporaryCursor: (self iconNamed: #eyedropperIcon)
		hotSpotOffset: 6 @ 31.
	h
		captureEventsUntil: [ :evt | 
			evt isMove
				ifTrue: [ p := evt position.
					(self hsvaMorph containsPoint: p)
						ifFalse:
							[ "deal with the fact that 32 bit displays may have garbage in the alpha bits"
							c := Display depth = 32
								ifTrue: [ Color
										colorFromPixelValue: ((Display pixelValueAt: p) bitOr: 16rFF000000)
										depth: 32 ]
								ifFalse: [ Display colorAt: p ] ].
					h position: p.
					self selectedColor ~= c
						ifTrue: [ self selectedColor: c ] ].
			"			self world displayWorldSafely. "
			h anyButtonPressed ].
	h showTemporaryCursor: nil
]

{ #category : #constants }
ColorSelectorDialogWindow >> red [
	"Answer the red value of the selected color."

	^(self selectedColor red * 255) asInteger
]

{ #category : #coloring }
ColorSelectorDialogWindow >> red: anInteger [
	"Set the red value of the selected color."

	|c|
	c := self selectedColor.
	self selectedColor: ((Color r: anInteger g: c green * 255 b: c blue * 255 range: 255) alpha: c alpha)
]

{ #category : #accessing }
ColorSelectorDialogWindow >> saturation [
	"Answer the saturation value of the selected color."

	^(self selectedColor saturation * 255) asInteger
]

{ #category : #accessing }
ColorSelectorDialogWindow >> saturation: anInteger [
	"Set the saturation value of the selected color."

	|c|
	c := self selectedColor.
	self selectedColor: ((Color h: c hue s: anInteger / 255 v: c brightness) alpha: c alpha)
]

{ #category : #accessing }
ColorSelectorDialogWindow >> selectedColor [
	"Answer the value of selectedColor"

	^ selectedColor
]

{ #category : #accessing }
ColorSelectorDialogWindow >> selectedColor: aColor [
	"Set the value of selectedColor. Update the color selectors."

	self basicSelectedColor: aColor.
	self hsvaMorph selectedColor: aColor
]
