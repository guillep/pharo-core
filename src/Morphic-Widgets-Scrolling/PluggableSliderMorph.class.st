"
A pluggable slider (rather than one that auto-generates access selectors). Needs to be themed...
"
Class {
	#name : #PluggableSliderMorph,
	#superclass : #SliderMorph,
	#instVars : [
		'getValueSelector',
		'getEnabledSelector',
		'enabled',
		'min',
		'max',
		'quantum',
		'getLabelSelector',
		'label'
	],
	#category : #'Morphic-Widgets-Scrolling'
}

{ #category : #'instance creation' }
PluggableSliderMorph class >> on: anObject getValue: getSel setValue: setSel [
	"Answer a new instance of the receiver with
	the given selectors as the interface."

	^self new
		on: anObject
		getValue: getSel
		setValue: setSel
]

{ #category : #'instance creation' }
PluggableSliderMorph class >> on: anObject getValue: getSel setValue: setSel min: min max: max quantum: quantum [
	"Answer a new instance of the receiver with
	the given selectors as the interface."

	^self new
		min: min;
		max: max;
		quantum: quantum;
		on: anObject
		getValue: getSel
		setValue: setSel
]

{ #category : #accessing }
PluggableSliderMorph >> adoptPaneColor: paneColor [
	"Pass on to the border too."
	
	super adoptPaneColor: paneColor.
	paneColor ifNil: [^self].
	self
		fillStyle: self fillStyleToUse;
		borderStyle: self borderStyleToUse;
		sliderColor: (self enabled
			ifTrue: [paneColor twiceDarker]
			ifFalse: [self paneColor twiceDarker paler])
]

{ #category : #protocol }
PluggableSliderMorph >> borderStyleToUse [
	"Answer the borderStyle that should be used for the receiver."
	
	^self enabled
		ifTrue: [self theme sliderNormalBorderStyleFor: self]
		ifFalse: [self theme sliderDisabledBorderStyleFor: self]
]

{ #category : #initialization }
PluggableSliderMorph >> defaultColor [
	"Answer the default color/fill style for the receiver."
	
	^Color white
]

{ #category : #protocol }
PluggableSliderMorph >> disable [
	"Disable the receiver."
	
	self enabled: false
]

{ #category : #drawing }
PluggableSliderMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	aCanvas 
		drawString: self label
		in: self labelBounds
		font: self font
		color: self fontColor.
		
	

]

{ #category : #protocol }
PluggableSliderMorph >> enable [
	"Enable the receiver."
	
	self enabled: true
]

{ #category : #accessing }
PluggableSliderMorph >> enabled [
	"Answer the value of enabled"

	^ enabled
]

{ #category : #accessing }
PluggableSliderMorph >> enabled: anObject [
	"Set the value of enabled"

	enabled = anObject ifTrue: [^self].
	enabled := anObject.
	self changed: #enabled.
	self
		adoptPaneColor: self paneColor;
		changed
]

{ #category : #accessing }
PluggableSliderMorph >> fillStyleToUse [
	"Answer the fillStyle that should be used for the receiver."
	
	^self enabled
		ifTrue: [self theme sliderNormalFillStyleFor: self]
		ifFalse: [self theme sliderDisabledFillStyleFor: self]
]

{ #category : #drawing }
PluggableSliderMorph >> font [

	^ StandardFonts defaultFont
]

{ #category : #drawing }
PluggableSliderMorph >> fontColor [

	^ self theme textColor
]

{ #category : #accessing }
PluggableSliderMorph >> getEnabledSelector [
	"Answer the value of getEnabledSelector"

	^ getEnabledSelector
]

{ #category : #accessing }
PluggableSliderMorph >> getEnabledSelector: aSymbol [
	"Set the value of getEnabledSelector"

	getEnabledSelector := aSymbol.
	self updateEnabled
]

{ #category : #accessing }
PluggableSliderMorph >> getLabelSelector [

	^ getLabelSelector
]

{ #category : #accessing }
PluggableSliderMorph >> getLabelSelector: aSymbol [

	getLabelSelector := aSymbol.
	self updateLabel
]

{ #category : #accessing }
PluggableSliderMorph >> getValueSelector [
	"Answer the value of getValueSelector"

	^ getValueSelector
]

{ #category : #accessing }
PluggableSliderMorph >> getValueSelector: anObject [
	"Set the value of getValueSelector"

	getValueSelector := anObject
]

{ #category : #'event handling' }
PluggableSliderMorph >> handlesMouseDown: evt [
	"Answer true." 

	^true
]

{ #category : #initialization }
PluggableSliderMorph >> initialize [
	"Initialize the receiver."

	min := 0.
	max := 1.
	label := ''.
	super initialize.
	self enabled: true
]

{ #category : #initialization }
PluggableSliderMorph >> initializeSlider [
	"Make the slider raised."
	
	super initializeSlider.
	slider borderStyle: (BorderStyle raised baseColor: slider color; width: 1)
]

{ #category : #accessing }
PluggableSliderMorph >> label [

	^ label
]

{ #category : #accessing }
PluggableSliderMorph >> label: aLabel [

	label := aLabel.
	self changed.
]

{ #category : #drawing }
PluggableSliderMorph >> labelBounds [
	| deltaY deltaX labelWidth treshold bnd |
	bnd := self innerBounds.
	labelWidth := self font widthOfStringOrText: self label.
	deltaY := (self height - self font height) / 2.
	treshold := bnd left + self labelGap + labelWidth.
	deltaX := (slider left < treshold or: [ sliderShadow visible and: [ sliderShadow left < treshold ] ])
		ifTrue: [ bnd width - self labelGap - labelWidth ]
		ifFalse: [ self labelGap ].
	^ bnd translateBy: deltaX @ deltaY
]

{ #category : #drawing }
PluggableSliderMorph >> labelGap [
	
	^ 2
]

{ #category : #layout }
PluggableSliderMorph >> layoutBounds: aRectangle [
	"Set the bounds for laying out children of the receiver.
	Note: written so that #layoutBounds can be changed without touching this method"
	
	super layoutBounds: aRectangle.
	self computeSlider
]

{ #category : #accessing }
PluggableSliderMorph >> max [
	"Answer the value of max"

	^ max
]

{ #category : #accessing }
PluggableSliderMorph >> max: anObject [
	"Set the value of max"

	max := anObject.
	self setValue: self value
]

{ #category : #accessing }
PluggableSliderMorph >> min [
	"Answer the value of min"

	^ min
]

{ #category : #accessing }
PluggableSliderMorph >> min: anObject [
	"Set the value of min"

	min := anObject.
	self setValue: self value
]

{ #category : #layout }
PluggableSliderMorph >> minHeight [
	"Answer the receiver's minimum height.
	Give it a bit of a chance..."
	
	^8 max: super minHeight
]

{ #category : #'event handling' }
PluggableSliderMorph >> mouseDown: anEvent [
	"Set the value directly."
	
	self enabled ifTrue: [
		self
			scrollPoint: anEvent;
			computeSlider].
	super mouseDown: anEvent.
	self enabled ifFalse: [^self].
	anEvent hand newMouseFocus: slider event: anEvent.
	slider
		mouseEnter: anEvent copy;
		mouseDown: anEvent copy

]

{ #category : #'other events' }
PluggableSliderMorph >> mouseDownInSlider: event [
	"Ignore if disabled."
	
	self enabled ifFalse: [^self].
	^super mouseDownInSlider: event
]

{ #category : #'other events' }
PluggableSliderMorph >> mouseUpInSlider: event [ 

	super mouseUpInSlider: event.
	"label or label position may change"
	self updateLabel.
]

{ #category : #'instance creation' }
PluggableSliderMorph >> on: anObject getValue: getSel setValue: setSel [
	"Use the given selectors as the interface."

	self
		model: anObject;
		getValueSelector: getSel;
		setValueSelector: setSel;
		updateValue
]

{ #category : #accessing }
PluggableSliderMorph >> quantum [
	"Answer the value of quantum"

	^ quantum
]

{ #category : #accessing }
PluggableSliderMorph >> quantum: anObject [
	"Set the value of quantum"

	quantum := anObject.
	self setValue: self value
]

{ #category : #accessing }
PluggableSliderMorph >> scaledValue [
	"Answer the scaled value."

	|val|
	val := self value * (self max - self min) + self min.
	self quantum ifNotNil: [:q |
		val := val roundTo: q].
	^(val max: self min) min: self max
]

{ #category : #accessing }
PluggableSliderMorph >> scaledValue: newValue [
	"Set the scaled value."

	|val|
	val := newValue.
	self quantum ifNotNil: [:q |
		val := val roundTo: q].
	self value: (self max <= self min
		ifTrue: [0]
		ifFalse: [val - self min / (self max - self min)])
]

{ #category : #scrolling }
PluggableSliderMorph >> scrollAbsolute: event [
	"Ignore if disabled."
	
	self enabled ifFalse: [^self].
	super scrollAbsolute: event.
	"label or label position may change"
	self updateLabel.
]

{ #category : #'event handling' }
PluggableSliderMorph >> scrollPoint: event [
	"Scroll to the event position."
	
	| r p |
	r := self roomToMove.
	bounds isWide
		ifTrue: [r width = 0 ifTrue: [^ self]]
		ifFalse: [r height = 0 ifTrue: [^ self]].
	p := event position - (self sliderThickness // 2) adhereTo: r.
	self descending
		ifFalse:
			[self setValue: (bounds isWide 
				ifTrue: [(p x - r left) asFloat / r width]
				ifFalse: [(p y - r top) asFloat / r height])]
		ifTrue:
			[self setValue: (bounds isWide
				ifTrue: [(r right - p x) asFloat / r width]
				ifFalse:	[(r bottom - p y) asFloat / r height])]
]

{ #category : #'model access' }
PluggableSliderMorph >> setValue: newValue [
	"Called internally for propagation to model."

	|scaled|
	"First, set the value"
	value := newValue.
	"Second, scaledValue gets the scaled-value based on the value"
	scaled := self scaledValue.
	"Third, setting the scaled value, sets the value based on quantum steps (if needed)"
	self scaledValue: scaled.
	"Propagate throught the model"
	self model ifNotNil: [
		self setValueSelector ifNotNil: [:sel |
			self model perform: sel with: scaled ]]
]

{ #category : #accessing }
PluggableSliderMorph >> setValueSelector [
	"Answer the set selector."
	
	^setValueSelector
]

{ #category : #accessing }
PluggableSliderMorph >> sliderColor: newColor [
	"Set the slider colour."
	
	super sliderColor: newColor.
	slider ifNotNil: [slider borderStyle baseColor: newColor]
]

{ #category : #protocol }
PluggableSliderMorph >> update: aParameter [

	aParameter = getEnabledSelector 		ifTrue: [ ^ self updateEnabled ].
	aParameter = getValueSelector 		ifTrue: [ ^ self updateValue ].
	aParameter = getLabelSelector 		ifTrue: [ ^ self updateLabel ].
			
	aParameter isArray ifFalse: [ ^ self ].
	aParameter size == 2 ifFalse: [ ^ self ].
	
	aParameter first = #max: ifTrue: [ self max: aParameter second ].
	aParameter first = #min: ifTrue: [ self min: aParameter second ].
	aParameter first = #quantum: ifTrue: [ self quantum: aParameter second ].
	aParameter first = #scaledValue: ifTrue: [ self scaledValue: aParameter second ].
	aParameter first = #value: ifTrue: [ self value: aParameter second ].
]

{ #category : #protocol }
PluggableSliderMorph >> updateEnabled [
	"Update the enablement state."

	self model ifNotNil: [:m | 
		self getEnabledSelector ifNotNil: [:s |
			self enabled: (m perform: s)]]
]

{ #category : #protocol }
PluggableSliderMorph >> updateLabel [
	"Update the label."
	
	self model ifNotNil: [:m |
		self getLabelSelector ifNotNil: [:selector | 
			self label: (m perform: selector) ]]
]

{ #category : #protocol }
PluggableSliderMorph >> updateValue [
	"Update the value."
	
	self model ifNotNil: [:m |
		self getValueSelector ifNotNil: [:s |
			self scaledValue: (m perform: s)]]
]
