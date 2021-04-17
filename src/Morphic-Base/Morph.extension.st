Extension { #name : #Morph }

{ #category : #'*Morphic-Base' }
Morph >> addHalo: evt [
	| halo |
	
	self halosEnabled
		ifFalse: [ ^ self ].
		
	halo := (Smalltalk globals at: self haloClass ifAbsent: [ HaloMorph ]) new.
	halo bounds: (halo worldBoundsForMorph: self).
	halo popUpFor: self event: evt.
	^ halo
]

{ #category : #'*Morphic-Base' }
Morph >> addHandlesTo: aHaloMorph box: box [
	"Add halo handles to the halo.  Apply the halo filter if appropriate"

	
	aHaloMorph haloBox: box.
	HaloMorph  currentHaloSpecifications do:
		[:aSpec | | wantsIt aSelector | 
			aSelector := aSpec addHandleSelector.
			(wantsIt := self wantsHaloHandleWithSelector: aSelector inHalo: aHaloMorph)
				ifTrue: [(#(addDupHandle:) includes: aSelector) 
					ifTrue: [wantsIt := self preferredDuplicationHandleSelector = aSelector]].
			wantsIt 
				ifTrue: [aHaloMorph perform: aSelector with: aSpec]].
	aHaloMorph innerTarget addOptionalHandlesTo: aHaloMorph box: box
]

{ #category : #'*Morphic-Base' }
Morph >> addWorldHandlesTo: aHaloMorph box: box [
	aHaloMorph haloBox: box.
	HaloMorph haloSpecificationsForWorld 
		do: [:aSpec | aHaloMorph perform: aSpec addHandleSelector with: aSpec].
	aHaloMorph innerTarget addOptionalHandlesTo: aHaloMorph box: box
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> allowsKeymapping [

	^ self valueOfProperty: #allowsKeymapping ifAbsent: [ true]
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> allowsKeymapping: aBoolean [

	^ self setProperty: #allowsKeymapping toValue: aBoolean
]

{ #category : #'*Morphic-Base' }
Morph >> asText [

	| anchor embedMorphSignal |
    anchor := TextAnchor new anchoredMorph: self.
    embedMorphSignal := (Character value: 1) asString. "required by the scanner"
    ^ Text string: embedMorphSignal attribute: anchor.
]

{ #category : #'*Morphic-Base' }
Morph >> assureLayoutProperties [
	| props |
	props := self layoutProperties.
	props == self ifTrue:[props := nil].
	props ifNil:[
		props := LayoutProperties new initializeFrom: self.
		self layoutProperties: props].
	^props
]

{ #category : #'*Morphic-Base' }
Morph >> assureTableProperties [
	| props |
	props := self layoutProperties.
	props == self ifTrue:[props := nil].
	props ifNil:[
		props := TableLayoutProperties new initializeFrom: self.
		self layoutProperties: props].
	props includesTableProperties 
		ifFalse:[self layoutProperties: (props := props asTableLayoutProperties)].
	^props
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> attachKeymapCategory: aCategory [
	self kmDispatcher attachCategory: aCategory.
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> attachKeymapCategory: aCategoryName onProperty: aProperty [
	self kmDispatcher attachCategory: aCategoryName onProperty: aProperty
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> attachKeymapCategory: aCategoryName targetting: anObject [
	self kmDispatcher attachCategory: aCategoryName targetting: anObject
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> bindKeyCombination: aShortcut toAction: anAction [
	self kmDispatcher bindKeyCombination: aShortcut asKeyCombination toAction: anAction
]

{ #category : #'*Morphic-Base' }
Morph >> borderColor: aColorOrSymbolOrNil [ 
	"Unfortunately, the argument to borderColor could be more than 	just a color. 
	It could also be a symbol, in which case it is to be interpreted as a style identifier.
	But I might not be able to draw that kind of border, so it may have to be ignored.
	Or it could be nil, in which case I should revert to the default border."

	| style newStyle |
	style := self borderStyle.
	style baseColor = aColorOrSymbolOrNil
		ifTrue: [^ self].

	aColorOrSymbolOrNil isColor
		ifTrue: [style style = #none "default border?"
				ifTrue: [self borderStyle: (SimpleBorderStyle width: 0 color: aColorOrSymbolOrNil)]
				ifFalse: [style baseColor: aColorOrSymbolOrNil.
					self changed].
			^ self].

	self
		borderStyle: ( ({ nil. #none } includes: aColorOrSymbolOrNil)
				ifTrue: [BorderStyle default]
				ifFalse: [ "a symbol"
					self doesBevels ifFalse: [ ^self ].
					newStyle := (BorderStyle perform: aColorOrSymbolOrNil)
								color: style color;
								width: style width;
								yourself.
					(self canDrawBorder: newStyle)
						ifTrue: [newStyle]
						ifFalse: [style]])
]

{ #category : #'*Morphic-Base' }
Morph >> borderWidth: aNumber [
	| style |
	style := self borderStyle.
	style width = aNumber ifTrue: [ ^self ].

	style style = #none
		ifTrue: [ self borderStyle: (SimpleBorderStyle width: aNumber color: Color transparent) ]
		ifFalse: [ style width: aNumber. self changed ].

]

{ #category : #'*Morphic-Base' }
Morph >> changeCellInset: evt [
	| handle |
	handle := HandleMorph new forEachPointDo:[:newPoint |
		self cellInset: (newPoint - evt cursorPoint) asIntegerPoint // 5].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #'*Morphic-Base' }
Morph >> changeLayoutInset: evt [
	| handle |
	handle := HandleMorph new forEachPointDo:[:newPoint |
		self layoutInset: (newPoint - evt cursorPoint) asIntegerPoint // 5].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #'*Morphic-Base' }
Morph >> changeMaxCellSize: evt [
	| handle |
	handle := HandleMorph new forEachPointDo:[:newPoint |
		self maxCellSize: (newPoint - evt cursorPoint) asIntegerPoint].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #'*Morphic-Base' }
Morph >> changeMinCellSize: evt [
	| handle |
	handle := HandleMorph new forEachPointDo:[:newPoint |
		self minCellSize: (newPoint - evt cursorPoint) asIntegerPoint].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #'*Morphic-Base' }
Morph >> changeProportionalLayout [
	| layout |
	((layout := self layoutPolicy) notNil and:[layout isProportionalLayout])
		ifTrue:[^self]. "already proportional layout"
	self layoutPolicy: ProportionalLayout new.
	self layoutChanged.
]

{ #category : #'*Morphic-Base' }
Morph >> changeTableLayout [
	| layout |
	((layout := self layoutPolicy) notNil and:[layout isTableLayout])
		ifTrue:[^self]. "already table layout"
	self layoutPolicy: TableLayout new.
	self layoutChanged.
]

{ #category : #'*Morphic-Base' }
Morph >> defaultBalloonColor [
	^ Display depth <= 2
		ifTrue: [Color white]
		ifFalse: [BalloonMorph balloonColor]
]

{ #category : #'*Morphic-Base' }
Morph >> defaultBalloonFont [
	^ BalloonMorph balloonFont
]

{ #category : #'*Morphic-Base' }
Morph >> defaultBitmapFillForm [
	^ImageMorph defaultForm.

]

{ #category : #'*Morphic-Base' }
Morph >> defaultLabel [
	"Answer the default label to be used"
	^ self printString truncateTo: 40
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> detachAllKeymapCategories [

	self kmDispatcher detachAllKeymapCategories
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> detachKeymapCategory: aCategoryName [

	self kmDispatcher detachKeymapCategory: aCategoryName.
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> detachKeymapCategory: aCategoryName targetting: anObject [

	self kmDispatcher detachKeymapCategory: aCategoryName targetting: anObject
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> dispatchKeystrokeForEvent: evt [ 
	self kmDispatcher dispatchKeystroke: evt 

]

{ #category : #'*Morphic-Base' }
Morph >> exportAs: anExtension using: aWriter [
	
	| reference |
	reference := UIManager default
		chooseForSaveFileReference: 'Save Morph as ', anExtension asUppercase
		extensions: { anExtension }
		path: (self externalName, '.' , anExtension).
	reference ifNotNil: [ aWriter putForm: self imageForm onFileNamed: reference ]
	
]

{ #category : #'*Morphic-Base' }
Morph >> exportAsBMP [
	
	self exportAs: 'bmp' using: BMPReadWriter 
]

{ #category : #'*Morphic-Base' }
Morph >> exportAsGIF [
	
	self exportAs: 'gif' using: GIFReadWriter. 
]

{ #category : #'*Morphic-Base' }
Morph >> exportAsJPEG [
	"Export the receiver's image as a JPEG"
	
	self exportAs: 'jpeg' using: PluginBasedJPEGReadWriter

]

{ #category : #'*Morphic-Base' }
Morph >> exportAsPNG [

	self exportAs: 'png' using: PNGReadWriter
	
]

{ #category : #'*Morphic-Base' }
Morph >> fillWithRamp: rampSpecsOrColor oriented: aRatio [ 
	rampSpecsOrColor isColor
		ifTrue: [self color: rampSpecsOrColor".
			self borderColor: rampSpecsOrColor muchDarker"]
		ifFalse: [| fill | 
			fill := GradientFillStyle ramp: rampSpecsOrColor.
			fill origin: self bounds topLeft.
			fill direction: (self bounds extent * aRatio) truncated.
			fill radial: false.
			self fillStyle: fill.
			self borderColor: (rampSpecsOrColor first value mixed: 0.5 with: rampSpecsOrColor last value) muchDarker]
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> handleKeystrokeWithKeymappings: aKeystrokeEvent [

	self allowsKeymapping ifTrue: [
		self dispatchKeystrokeForEvent: aKeystrokeEvent.
	].
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> hasKeymapCategoryNamed: aString [

	^ self kmDispatcher targets anySatisfy: [ :e | e category name = aString ].
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> initializeShortcuts: aKMDispatcher [
	"Where we may attach keymaps or even on:do: local shortcuts if needed."

	aKMDispatcher attachCategory: #MorphFocusCtrlNavigation
]

{ #category : #'*Morphic-Base' }
Morph >> isMenuItemMorph [
	^false
]

{ #category : #'*Morphic-Base' }
Morph >> isMenuLineMorph [
	^false
]

{ #category : #'*Morphic-Base' }
Morph >> isMenuMorph [
	^false
]

{ #category : #'*Morphic-Base' }
Morph >> justDroppedInto: aMorph event: anEvent [
	"This message is sent to a dropped morph after it has been dropped on -- and been accepted by -- a drop-sensitive morph"

	| aWindow |
	(self formerOwner notNil and: [self formerOwner ~~ aMorph])
		ifTrue: [self removeHalo].
	self formerOwner: nil.
	self formerPosition: nil.
	(aWindow := aMorph ownerThatIsA: SystemWindow) 
		ifNotNil: [aWindow isActive 
			ifFalse: [aWindow activate]].

	"An object launched by certain parts-launcher mechanisms should end up fully visible..."
	(self hasProperty: #beFullyVisibleAfterDrop) 
		ifTrue: [aMorph == self world 
			ifTrue: [self goHome].
			self removeProperty: #beFullyVisibleAfterDrop].


]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> kmDispatcher [
	"When creating the KMDispatcher instance, load default shortcuts."

	^ self
		valueOfProperty: #kmDispatcher
		ifAbsentPut: [ 
			| kmd |
			kmd := KMDispatcher target: self.
			self initializeShortcuts: kmd.
			kmd ]
]

{ #category : #'*Morphic-Base' }
Morph >> newTransformationMorph [
	^TransformationMorph new
]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> on: aShortcut do: anAction [
	
	^ self bindKeyCombination: aShortcut toAction: anAction 
]

{ #category : #'*Morphic-Base' }
Morph >> on: eventName send: selector to: recipient [
	self eventHandler ifNil: [self eventHandler: MorphicEventHandler new].
	self eventHandler on: eventName send: selector to: recipient
]

{ #category : #'*Morphic-Base' }
Morph >> on: eventName send: selector to: recipient withValue: value [
	"NOTE: selector must take 3 arguments, of which value will be the *** FIRST ***"

	self eventHandler ifNil: [self eventHandler: MorphicEventHandler new].
	self eventHandler on: eventName send: selector to: recipient withValue: value

]

{ #category : #'*Morphic-Base-keymapping' }
Morph >> removeKeyCombination: aShortcut [

	self kmDispatcher removeKeyCombination: aShortcut
]

{ #category : #'*Morphic-Base' }
Morph >> resizeMorph: evt [
	| handle |
	handle := HandleMorph new forEachPointDo: [ :newPoint | self extent: newPoint - self bounds topLeft ].
	evt hand attachMorph: handle.
	handle startStepping
]

{ #category : #'*Morphic-Base' }
Morph >> rowMorphForNode: aNode inColumn: aColumn [
	| rm |
	rm := Morph new color: Color transparent;
			layoutPolicy: RowLayout new;
			hResizing: #shrinkWrap;
			vResizing: #shrinkWrap;
			layoutInset: aColumn container columnInset @ aColumn container rowInset;
			listDirection: #leftToRight;
			cellPositioning: #leftCenter;
			cellInset: 4@0;
			yourself.
			
	rm addMorph: self.
	
	aColumn isFirstColumn 
		ifTrue: [ | icon |
			icon := aColumn container iconBlock value: aNode.
			icon ifNotNil: [ rm addMorph: icon asMorph ].
			"for first column we don't use horizontal inset"
			rm  layoutInset: 0 @ aColumn container rowInset.
		].

	^ rm

]

{ #category : #'*Morphic-Base' }
Morph >> setArrowheads [
	"Let the user edit the size of arrowheads for this object"

	| aParameter result  |
	aParameter := self renderedMorph valueOfProperty:  #arrowSpec ifAbsent: [PolygonMorph defaultArrowSpec].
	result := Morph obtainArrowheadFor: 'Head size for arrowheads: ' translated defaultValue: aParameter asString.
	result ifNotNil:
			[self renderedMorph  setProperty: #arrowSpec toValue: result]
		ifNil:
			[ self inform: 'Invalid input']
]

{ #category : #'*Morphic-Base' }
Morph >> setShadowOffset: evt [
	| handle |
	handle := HandleMorph new forEachPointDo:
		[:newPoint | self shadowPoint: newPoint].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #'*Morphic-Base' }
Morph >> useBitmapFill [
	"Make receiver use a solid fill style (e.g., a simple color)"
	| fill |
	self fillStyle isBitmapFill ifTrue:[^self]. "Already done"
	fill := BitmapFillStyle fromForm: self defaultBitmapFillForm.
	"Note: Must fix the origin due to global coordinates"
	fill origin: self bounds origin.
	self fillStyle: fill.
]

{ #category : #'*Morphic-Base' }
Morph >> useGradientFill [
	"Make receiver use a solid fill style (e.g., a simple color)"
	| fill color1 color2 |
	self fillStyle isGradientFill ifTrue:[^self]. "Already done"
	color1 := self color asColor.
	color2 := color1 negated.
	fill := GradientFillStyle ramp: {0.0 -> color1. 1.0 -> color2}.
	fill origin: self topLeft.
	fill direction: 0 @ self bounds extent y.
	fill normal: self bounds extent x @ 0.
	fill radial: false.
	self fillStyle: fill
]
