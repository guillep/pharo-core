Class {
	#name : #SliderMorph,
	#superclass : #ModelMorphic,
	#instVars : [
		'slider',
		'value',
		'setValueSelector',
		'sliderShadow',
		'sliderColor',
		'descending',
		'dragging'
	],
	#category : #'Morphic-Widgets-Scrolling'
}

{ #category : #geometry }
SliderMorph >> computeSlider [
	| r |
	r := self roomToMove.
	self descending
		ifFalse:
			[slider position: (bounds isWide
				ifTrue: [r topLeft + ((r width * value) asInteger @ 0)]
				ifFalse: [r topLeft + (0 @ (r height * value)  asInteger)])]
		ifTrue:
			[slider position: (bounds isWide
				ifTrue:	[r bottomRight - ((r width * value) asInteger @ 0)]
				ifFalse:	[r bottomRight - ((0 @ (r height * value) asInteger))])].
	slider extent: self sliderExtent
]

{ #category : #initialization }
SliderMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ #inset
]

{ #category : #initialization }
SliderMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
SliderMorph >> defaultBounds [
"answer the default bounds for the receiver"
	^ 0 @ 0 corner: 16 @ 100
]

{ #category : #initialization }
SliderMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightGray
]

{ #category : #accessing }
SliderMorph >> descending [
	"It may happen that an instance variable is nil, for example, if an instance is in the image when the instance is introduced. This test should probably be removed."
	^ descending == true
]

{ #category : #accessing }
SliderMorph >> descending: aBoolean [
	descending := aBoolean.
	self value: value
]

{ #category : #accessing }
SliderMorph >> dragging [
	^ dragging.
]

{ #category : #accessing }
SliderMorph >> dragging: aBoolean [
	dragging := aBoolean.
]

{ #category : #geometry }
SliderMorph >> extent: newExtent [
	newExtent = bounds extent ifTrue: [^ self].
	bounds isWide
		ifTrue: [super extent: (newExtent x max: self sliderThickness * 2) @ newExtent y]
		ifFalse: [super extent: newExtent x @ (newExtent y max: self sliderThickness * 2)].
	self removeAllMorphs; initializeSlider
]

{ #category : #initialization }
SliderMorph >> initialize [
	"initialize the state of the receiver"
	
	super initialize.
	value := 0.0.
	descending := false.
	dragging := false.
	self initializeSlider
]

{ #category : #initialization }
SliderMorph >> initializeSlider [
	slider := BorderedMorph newBounds: self totalSliderArea color: self theme baseColor.
	sliderShadow := BorderedMorph newBounds: self totalSliderArea
						color: self pagingArea color.
	slider on: #mouseMove send: #scrollAbsolute: to: self.
	slider on: #mouseDown send: #mouseDownInSlider: to: self.
	slider on: #mouseUp send: #mouseUpInSlider: to: self.
	slider 
		borderWidth: 1;
		borderColor: self theme baseColor.

	sliderShadow 
		borderWidth: 1;
		borderColor: #inset.
	"(the shadow must have the pagingArea as its owner to highlight properly)"
	self pagingArea addMorph: sliderShadow.
	sliderShadow hide.
	self addMorph: slider.
	self computeSlider.

]

{ #category : #'other events' }
SliderMorph >> mouseDownInSlider: event [
	"When mouse down I start dragging, and change the border colors and show a shadow
	on the original position."
	
	"If already dragging don't update."
	"Be aware that this situation is difficult to reproduce, but you can if start dragging
	and the use a key combination to change the selected OS Windows (not morphic) without
	releasing the mouse and finally make a mousedown in the slider again."
	dragging ifTrue:[^self].
	
	slider borderColor: #inset.
	
	sliderShadow color: self sliderShadowColor.
	sliderShadow cornerStyle: slider cornerStyle.
	sliderShadow bounds: slider bounds.
	sliderShadow show.
	
	self dragging: true
]

{ #category : #'other events' }
SliderMorph >> mouseUpInSlider: event [
	"When mouse up, the dragging ends and the color is reseted to it's orignal
	value and the shadow of original position is hidden."
	
	"If it's not dragging, there's nothing to do."
	"To reproduce this, press mouse down outside the slider, then move to
	the slider and release the mouse."
	
	dragging ifFalse:[^self].

	slider borderColor: #raised.
				
	sliderShadow hide.
	
	self dragging: false.
]

{ #category : #accessing }
SliderMorph >> pagingArea [
	^self
]

{ #category : #geometry }
SliderMorph >> roomToMove [
	^ self totalSliderArea insetBy: (0@0 extent: self sliderExtent)
]

{ #category : #scrolling }
SliderMorph >> scrollAbsolute: event [
	| r p |
	"If I'm not dragging I will do nothing."
	self dragging ifFalse: [ ^ self ].

	r := self roomToMove.
	bounds isWide
		ifTrue: [ r width = 0
				ifTrue: [ ^ self ] ]
		ifFalse: [ r height = 0
				ifTrue: [ ^ self ] ].
	p := event targetPoint adhereTo: r.
	self descending
		ifFalse: [ self
				setValue:
					(bounds isWide
						ifTrue: [ (p x - r left) asFloat / r width ]
						ifFalse: [ (p y - r top) asFloat / r height ]) ]
		ifTrue: [ self
				setValue:
					(bounds isWide
						ifTrue: [ (r right - p x) asFloat / r width ]
						ifFalse: [ (r bottom - p y) asFloat / r height ]) ]
]

{ #category : #initialization }
SliderMorph >> setSlider: aMorph withShadow: anotherMorph [
	

	slider ifNotNil: [ self removeMorph: slider ].
	sliderShadow ifNotNil: [ self pagingArea removeMorph: sliderShadow ].

	slider := aMorph.
	sliderShadow := anotherMorph.
	slider on: #mouseMove send: #scrollAbsolute: to: self.
	slider on: #mouseDown send: #mouseDownInSlider: to: self.
	slider on: #mouseUp send: #mouseUpInSlider: to: self.

	"(the shadow must have the pagingArea as its owner to highlight properly)"
	self pagingArea addMorph: sliderShadow.
	sliderShadow hide.
	self addMorph: slider.
	self computeSlider.
]

{ #category : #'model access' }
SliderMorph >> setValue: newValue [
	"Called internally for propagation to model"
	self value: newValue.
	setValueSelector ifNotNil: [
		^model perform: setValueSelector with: value
		].
]

{ #category : #accessing }
SliderMorph >> setValueSelector: aSymbol [
	"Directly set the selector to make more flexible."
	
	setValueSelector := aSymbol
]

{ #category : #'event testing' }
SliderMorph >> simulateScrollAbsolute: aPointStart to: aPointEnd [
	"Simulates a mouse moving from a given point to a destinationpoint"
	| event |
	event := MouseMoveEvent  new 
		setType: #mouseMove  
		startPoint: aPointStart 
		endPoint: aPointEnd 
		trail: nil
		buttons: 0
		hand: self currentHand
		stamp: 0.
	self scrollAbsolute:  event
]

{ #category : #'event testing' }
SliderMorph >> simulateSliderMiddleMouseDown [
	"Simulate mouse button down with the left button (red button for left, blue for middle, yellow for right) into the Slider"

	slider simulateMouseDownWith: MouseEvent blueButton
]

{ #category : #'event testing' }
SliderMorph >> simulateSliderMiddleMouseUp [
	"Simulate mouse button up with the left button (red button for left, blue for middle, yellow for right) into the Slider"

	slider simulateMouseUpWith: MouseEvent blueButton
]

{ #category : #'event testing' }
SliderMorph >> simulateSliderMouseDown [
	"Simulate mouse button down with the left button (red button for left, blue for middle, yellow for right) into the Slider"

	slider simulateMouseDownWith: MouseEvent redButton
]

{ #category : #'event testing' }
SliderMorph >> simulateSliderMouseUp [
	"Simulate mouse button up with the left button (red button for left, blue for middle, yellow for right) into the Slider"

	slider simulateMouseUpWith: MouseEvent redButton
]

{ #category : #'event testing' }
SliderMorph >> simulateSliderRightMouseDown [
	"Simulate mouse button down with the left button (red button for left, blue for middle, yellow for right) into the Slider"

	slider simulateMouseDownWith: MouseEvent yellowButton
]

{ #category : #'event testing' }
SliderMorph >> simulateSliderRightMouseUp [
	"Simulate mouse button up with the left button (red button for left, blue for middle, yellow for right) into the Slider"

	slider simulateMouseUpWith: MouseEvent yellowButton
]

{ #category : #accessing }
SliderMorph >> sliderColor [
	"color scheme for the whole slider widget"
	sliderColor ifNil: [^ (color alphaMixed: 0.7 with: Color white) slightlyLighter].
	^ sliderColor
]

{ #category : #accessing }
SliderMorph >> sliderColor: newColor [

	sliderColor := newColor.
	slider ifNotNil: [slider color: sliderColor]
]

{ #category : #geometry }
SliderMorph >> sliderExtent [
	^ bounds isWide
		ifTrue: [self sliderThickness @ self innerBounds height]
		ifFalse: [self innerBounds width @ self sliderThickness]
]

{ #category : #accessing }
SliderMorph >> sliderShadowColor [
	^ self sliderColor alphaMixed: 0.2 with: self pagingArea color
]

{ #category : #geometry }
SliderMorph >> sliderThickness [
	^ 7
]

{ #category : #accessing }
SliderMorph >> thumbColor [
	"Color of the draggable 'thumb'"
	^ self sliderColor
]

{ #category : #geometry }
SliderMorph >> totalSliderArea [
	^ self innerBounds
]

{ #category : #update }
SliderMorph >> updateSliderBounds [
	slider bounds: self totalSliderArea.
	sliderShadow bounds: self totalSliderArea.
	
	self computeSlider.

]

{ #category : #accessing }
SliderMorph >> value [
	^ value
]

{ #category : #'model access' }
SliderMorph >> value: newValue [
	"Drive the slider position externally..."
	value := newValue min: 1.0 max: 0.0.
	self computeSlider
]
