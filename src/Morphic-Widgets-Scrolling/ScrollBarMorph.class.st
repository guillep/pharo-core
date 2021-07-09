"
Inspired by an oiginal design of Hans-Martin Mosner, this ScrollBar is intended to exercise the handling of input events in Morphic.  With sufficient flexibility in this area, all particular behavior can be concentrated in this single class with no need to specialize any other morphs to achieve button, slider and menu-button behavior.

Once we have this working, put in logic for horizontal operation as well.

CachedImages was added to reduce the number of forms created and thrown away. This will be helpful for Nebraska and others as well.
"
Class {
	#name : #ScrollBarMorph,
	#superclass : #SliderMorph,
	#instVars : [
		'upButton',
		'downButton',
		'pagingArea',
		'scrollDelta',
		'pageDelta',
		'interval',
		'timeOfMouseDown',
		'timeOfLastScroll',
		'nextPageDirection',
		'currentScrollDelay',
		'lastPaneColor'
	],
	#classVars : [
		'ArrowImagesCache',
		'BoxesImagesCache'
	],
	#category : #'Morphic-Widgets-Scrolling'
}

{ #category : #images }
ScrollBarMorph class >> arrowOfDirection: aSymbol size: finalSizeInteger color: aColor [ 
	"answer a form with an arrow based on the parameters"
	^ ArrowImagesCache at: {aSymbol. finalSizeInteger. aColor}
]

{ #category : #'images - samples' }
ScrollBarMorph class >> arrowSamples [
	"create a set of arrow with different sizes, colors and directions"
	" 
	ScrollBar arrowSamples.  
	"
	| column |
	column := AlignmentMorph newColumn vResizing: #shrinkWrap;
				 hResizing: #shrinkWrap;
				 layoutInset: 1;
				 borderColor: Color black;
				 borderWidth: 0;
				 wrapCentering: #center;
				 cellPositioning: #center;
				 color: Color white;
				 yourself.
	
	self sampleSizes
		do: [:size | 
			| row | 
			row := AlignmentMorph newRow color: Color transparent;
						 vResizing: #shrinkWrap;
						 cellInset: 2 @ 0 yourself.
			
			self sampleColors
				do: [:color | 
					#(#top #right #bottom #left )
						do: [:direction | 
							row addMorphBack: (ScrollBarMorph
									arrowOfDirection: direction
									size: size
									color: color) asMorph]].
			
			column addMorphBack: row].
	
	column openInHand
]

{ #category : #images }
ScrollBarMorph class >> boxOfSize: finalSizeInteger color: aColor [ 
	"answer a form with an box based on the parameters"
	^ BoxesImagesCache at: {finalSizeInteger. aColor}
]

{ #category : #'images - samples' }
ScrollBarMorph class >> boxSamples [
	"create a set of box with different sizes and colors"
	" 
	ScrollBar boxSamples.  
	"
	| column |
	column := AlignmentMorph newColumn vResizing: #shrinkWrap;
				 hResizing: #shrinkWrap;
				 layoutInset: 1;
				 borderColor: Color black;
				 borderWidth: 0;
				 wrapCentering: #center;
				 cellPositioning: #center;
				 color: Color white;
				 yourself.
	""
	self sampleSizes
		do: [:size | 
			| row | 
			row := AlignmentMorph newRow color: Color transparent;
						 vResizing: #shrinkWrap;
						 cellInset: 2 @ 0 yourself.
			""
			self sampleColors
				do: [:color | 
					row addMorphBack: (ScrollBarMorph boxOfSize: size color: color) asMorph].
			""
			column addMorphBack: row].
	""
	""
	column openInHand
]

{ #category : #cleanup }
ScrollBarMorph class >> cleanUp [
	"Re-initialize the image cache"

	self initializeImagesCache
]

{ #category : #initialization }
ScrollBarMorph class >> initialize [
	"ScrollBar initialize"

	self initializeImagesCache
]

{ #category : #initialization }
ScrollBarMorph class >> initializeImagesCache [
	"initialize the receiver's ImagesCache. 
	 
	normally this method is not evaluated more than in the class 
	initializazion. "

	" 
	ScrollBar initializeImagesCache.
	"

	ArrowImagesCache := self theme createArrowImagesCache.
	BoxesImagesCache := self theme createBoxImagesCache
]

{ #category : #'images - samples' }
ScrollBarMorph class >> sampleColors [
	"private"
	^ (Color lightCyan wheel: 5)
]

{ #category : #'images - samples' }
ScrollBarMorph class >> sampleSizes [
	
"private"
	^ #(10 12 14 16 18 32 64 )
]

{ #category : #update }
ScrollBarMorph >> adoptGradientColor: aColor [
	"Adopt the given pane color."

	|c fs bfs bs bbs|
	aColor ifNil:[^self].
	c := aColor.
	fs := self normalThumbFillStyle.
	bfs := self normalButtonFillStyle.
	bs := self normalThumbBorderStyle.
	bbs := self normalButtonBorderStyle.
	sliderColor := c.
	downButton
		fillStyle: bfs;
		borderStyle: bbs.
	upButton
		fillStyle: bfs shallowCopy;
		borderStyle: bbs.
	slider
		fillStyle: fs;
		borderStyle: bs.
	self updateUpButtonImage.
	self updateDownButtonImage
]

{ #category : #'private - accessing' }
ScrollBarMorph >> adoptPaneColor: aColor [
	"Adopt the given pane color"
	aColor ifNil:[^self].
	self sliderColor: aColor.
]

{ #category : #geometry }
ScrollBarMorph >> buttonExtent [
	| size |
	size := self theme scrollbarThickness.
	
	^ bounds isWide
		ifTrue: [ upButton 
			ifNil: [  size@size ] 
			ifNotNil: [ upButton extent ] ]
		ifFalse: [ downButton 
			ifNil: [ size@size ] 
			ifNotNil: [ downButton extent ] ]
]

{ #category : #'private - accessing' }
ScrollBarMorph >> buttonImageColor [
	"Answer the color to use for the arrow image of a button."

	^self theme scrollbarImageColorFor: self
]

{ #category : #scrolling }
ScrollBarMorph >> doScrollByPage [
	"Scroll automatically while mouse is down"
	(self waitForDelay1: 300 delay2: 100) ifFalse: [^ self].
	nextPageDirection
		ifTrue: [self setValue: (value + pageDelta min: 1.0)]
		ifFalse: [self setValue: (value - pageDelta max: 0.0)]

]

{ #category : #scrolling }
ScrollBarMorph >> doScrollDown [
	"Scroll automatically while mouse is down"
	(self waitForDelay1: 200 delay2: 40) ifFalse: [^ self].
	self setValue: (value + scrollDelta + 0.000001 min: 1.0)
]

{ #category : #scrolling }
ScrollBarMorph >> doScrollUp [
	"Scroll automatically while mouse is down"
	(self waitForDelay1: 200 delay2: 40) ifFalse: [^ self].
	self setValue: (value - scrollDelta - 0.000001 max: 0.0)
]

{ #category : #initialize }
ScrollBarMorph >> downImage [
	"answer a form to be used in the down button"
	^ self class
		arrowOfDirection: (bounds isWide
				ifTrue: [#right]
				ifFalse: [#bottom])
		size: (self buttonExtent x min: self buttonExtent y)
		color: self buttonImageColor
]

{ #category : #geometry }
ScrollBarMorph >> expandSlider [
	"Compute the new size of the slider (use the old sliderThickness as a minimum)."
	| r |
	r := self totalSliderArea.
	slider extent: (bounds isWide
		ifTrue: [((r width * interval) asInteger max: self sliderThickness) @ slider height]
		ifFalse: [slider width @ ((r height * interval) asInteger max: self sliderThickness)])
]

{ #category : #geometry }
ScrollBarMorph >> extent: p [ 
	p x > p y
		ifTrue: [super
				extent: (p max: (42 @ 8) scaledByDisplayScaleFactor)]
		ifFalse: [super
				extent: (p max: (8 @ 42) scaledByDisplayScaleFactor)].
	
]

{ #category : #'private - accessing' }
ScrollBarMorph >> finishedScrolling [
	"Scrolling has finished (button or paging area)."
	
	|bcu bcd|
	bcu := upButton borderStyle baseColor.
	bcd := downButton borderStyle baseColor.
	self stopStepping.
	self scrollBarAction: nil.
	upButton borderRaised.
	upButton borderStyle baseColor: bcu.
	downButton borderRaised.
	downButton borderStyle baseColor: bcd.
	pagingArea
		fillStyle: self normalFillStyle;
		borderStyle: self normalBorderStyle
]

{ #category : #'private - accessing' }
ScrollBarMorph >> finishedScrolling: event [
	"Scrolling has finished for a button."
	
	self finishedScrolling.
	(self containsPoint: event position)
		ifTrue: [pagingArea
				fillStyle: self mouseOverFillStyle;
				borderStyle: self mouseOverBorderStyle]
		ifFalse: [pagingArea
				fillStyle: self normalFillStyle;
				borderStyle: self normalBorderStyle].
	(upButton containsPoint: event position)
		ifTrue: [upButton
					fillStyle: self mouseOverButtonFillStyle;
					borderStyle: self mouseOverButtonBorderStyle]
		ifFalse: [(self containsPoint: event position)
					ifTrue: [upButton
							fillStyle: self mouseOverPagingAreaButtonFillStyle;
							borderStyle: self mouseOverPagingAreaButtonBorderStyle]
					ifFalse: [upButton
							fillStyle: self normalButtonFillStyle;
							borderStyle: self normalButtonBorderStyle]].
	(downButton containsPoint: event position)
		ifTrue: [downButton
					fillStyle: self mouseOverButtonFillStyle;
					borderStyle: self mouseOverButtonBorderStyle]
		ifFalse: [(self containsPoint: event position)
					ifTrue: [downButton
							fillStyle: self mouseOverPagingAreaButtonFillStyle;
							borderStyle: self mouseOverPagingAreaButtonBorderStyle]
					ifFalse: [downButton
							fillStyle: self normalButtonFillStyle;
							borderStyle: self normalButtonBorderStyle]]
]

{ #category : #initialization }
ScrollBarMorph >> initialize [
	super initialize.
	scrollDelta := 0.02.
	pageDelta := 0.2.

]

{ #category : #initialization }
ScrollBarMorph >> initializeDownButton [
	"initialize the receiver's downButton"

	downButton := self theme newScrollBarDownButtonFor: self.
	
	downButton color: self thumbColor.
	downButton 
		on: #mouseDown
		send: #scrollDownInit
		to: self.
	downButton 
		on: #mouseUp
		send: #finishedScrolling
		to: self.
	self updateDownButtonImage.
	downButton 
		borderWidth: 1;
		borderColor: Color lightGray.
		
	downButton cornerStyle: (self theme scrollbarButtonCornerStyleIn: self window).
	downButton on: #mouseUp send: #finishedScrolling: to: self.
	downButton on: #mouseEnter send: #mouseEnterDownButton: to: self.
	downButton on: #mouseLeave send: #mouseLeaveDownButton: to: self.
	self addMorph: downButton
]

{ #category : #initialization }
ScrollBarMorph >> initializePagingArea [
	"Initialize the receiver's pagingArea."
	
	pagingArea := Morph
				newBounds: self totalSliderArea
				color: (Color
						r: 0.6
						g: 0.6
						b: 0.8).
	pagingArea
		on: #mouseDown
		send: #scrollPageInit:
		to: self.
	pagingArea
		on: #mouseUp
		send: #finishedScrolling
		to: self.
	self addMorph: pagingArea.
	pagingArea cornerStyle: (self theme scrollbarPagingAreaCornerStyleIn: self window).
	pagingArea on: #mouseUp send: #finishedScrolling: to: self.
	self on: #mouseEnter send: #mouseEnterPagingArea: to: self.
	self on: #mouseLeave send: #mouseLeavePagingArea: to: self
]

{ #category : #initialization }
ScrollBarMorph >> initializeSlider [
	"Initialize the receiver's slider."
	
	self initializeUpButton; initializeDownButton; initializePagingArea.
	super initializeSlider.
	self sliderColor: self sliderColor.
	self slider
		width: self theme scrollbarThickness;
		height: self theme scrollbarThickness.
	slider cornerStyle: (self theme scrollbarThumbCornerStyleIn: self window).
	slider on: #mouseEnter send: #mouseEnterThumb: to: self.
	slider on: #mouseLeave send: #mouseLeaveThumb: to: self
]

{ #category : #initialization }
ScrollBarMorph >> initializeUpButton [
	"initialize the receiver's upButton"
	upButton := self theme newScrollBarUpButtonFor: self.
	upButton color: self thumbColor.
	upButton
		on: #mouseDown
		send: #scrollUpInit
		to: self.
	upButton
		on: #mouseUp
		send: #finishedScrolling
		to: self.
	self updateUpButtonImage.
	upButton 
		borderWidth: 1;
		borderColor: Color lightGray.
		
	upButton cornerStyle: (self theme scrollbarButtonCornerStyleIn: self window).
	upButton on: #mouseUp send: #finishedScrolling: to: self.
	upButton on: #mouseEnter send: #mouseEnterUpButton: to: self.
	upButton on: #mouseLeave send: #mouseLeaveUpButton: to: self.
	self addMorph: upButton
]

{ #category : #'private - accessing' }
ScrollBarMorph >> interval: d [
	"Supply an optional floating fraction so slider can expand to indicate range.
	Update the fill style for the tumb (may have extent-based elements)."
	
	|oldExtent|
	oldExtent := slider extent.
	interval := d min: 1.0.
	self expandSlider.
	self computeSlider.
	slider extent = oldExtent
		ifFalse: [slider fillStyle: self normalThumbFillStyle]
]

{ #category : #accessing }
ScrollBarMorph >> lastPaneColor [
	^ lastPaneColor
]

{ #category : #accessing }
ScrollBarMorph >> lastPaneColor: anObject [
	lastPaneColor := anObject
]

{ #category : #initialize }
ScrollBarMorph >> menuImage [
	"answer a form to be used in the menu button"
	^ self class
		boxOfSize: (self buttonExtent x min: self buttonExtent y)
		color: self thumbColor
]

{ #category : #'other events' }
ScrollBarMorph >> mouseDownInSlider: event [
	"The mouse has been pressed in the slider area."

	"If its already dragging, there's nothing to do"
	self dragging
		ifTrue: [ ^ self ].
		
	interval = 1
		ifTrue:
			[ "make the entire scrollable area visible if a full scrollbar is clicked on"
			self setValue: 0.
			self model hideOrShowScrollBar ].
	event redButtonPressed
		ifFalse: [ ^ self ].
	slider fillStyle: self pressedThumbFillStyle.
	slider borderStyle: self pressedThumbBorderStyle.
	self theme useScrollbarThumbShadow
		ifTrue: [ sliderShadow
				color: self sliderShadowColor;
				cornerStyle: slider cornerStyle;
				bounds: slider bounds;
				show ].
	"Set dragging to true."
	self dragging: true
]

{ #category : #mouse }
ScrollBarMorph >> mouseEnterDownButton: event [
	"The mouse has entered the down button."
	
	downButton
		fillStyle: self mouseOverButtonFillStyle;
		borderStyle: self mouseOverButtonBorderStyle;
		changed
]

{ #category : #mouse }
ScrollBarMorph >> mouseEnterPagingArea: event [
	"The mouse has entered the paging area."
	
	pagingArea
		fillStyle: self mouseOverFillStyle;
		borderStyle: self mouseOverBorderStyle;
		changed.
	slider
		fillStyle: self mouseOverPagingAreaThumbFillStyle;
		borderStyle: self mouseOverPagingAreaThumbBorderStyle;
		changed.
	upButton
		fillStyle: self mouseOverPagingAreaButtonFillStyle;
		borderStyle: self mouseOverPagingAreaButtonBorderStyle;
		changed.
	downButton
		fillStyle: self mouseOverPagingAreaButtonFillStyle;
		borderStyle: self mouseOverPagingAreaButtonBorderStyle;
		changed
]

{ #category : #mouse }
ScrollBarMorph >> mouseEnterThumb: event [
	"The mouse has entered the thumb."
	
	slider
		fillStyle: self mouseOverThumbFillStyle;
		borderStyle: self mouseOverThumbBorderStyle;
		changed.
	upButton
		fillStyle: self mouseOverThumbButtonFillStyle;
		borderStyle: self mouseOverThumbButtonBorderStyle;
		changed.
	downButton
		fillStyle: self mouseOverThumbButtonFillStyle;
		borderStyle: self mouseOverThumbButtonBorderStyle;
		changed
]

{ #category : #mouse }
ScrollBarMorph >> mouseEnterUpButton: event [
	"The mouse has entered the up button."
	
	upButton
		fillStyle: self mouseOverButtonFillStyle;
		borderStyle: self mouseOverButtonBorderStyle;
		changed
]

{ #category : #mouse }
ScrollBarMorph >> mouseLeaveDownButton: event [
	"The mouse has left the down button."

	event redButtonPressed
		ifFalse: [ 
			downButton
				fillStyle: self normalButtonFillStyle;
				borderStyle: self normalButtonBorderStyle;
				changed ]
]

{ #category : #mouse }
ScrollBarMorph >> mouseLeavePagingArea: event [
	"The mouse has left the paging area."
	
	pagingArea
		fillStyle: self normalFillStyle;
		borderStyle: self normalBorderStyle;
		changed.
	slider
		fillStyle: self normalThumbFillStyle;
		borderStyle: self normalThumbBorderStyle;
		changed.
	upButton
		fillStyle: self normalButtonFillStyle;
		borderStyle: self normalButtonBorderStyle;
		changed.
	downButton
		fillStyle: self normalButtonFillStyle;
		borderStyle: self normalButtonBorderStyle;
		changed
]

{ #category : #mouse }
ScrollBarMorph >> mouseLeaveThumb: event [
	"The mouse has left the thumb."

	| buttonFillStyle buttonBorderStyle |
	event redButtonPressed
		ifFalse: [ slider
				fillStyle: self normalThumbFillStyle;
				borderStyle: self normalThumbBorderStyle;
				changed ].

	"Update buttons"
	buttonBorderStyle := (self containsPoint: event position)
		ifTrue: [ buttonFillStyle := self mouseOverPagingAreaButtonFillStyle.
			self mouseOverPagingAreaButtonBorderStyle ]
		ifFalse: [ buttonFillStyle := self normalButtonFillStyle.
			self normalButtonBorderStyle ].
	upButton
		fillStyle: buttonFillStyle;
		borderStyle: buttonBorderStyle.
	downButton
		fillStyle: buttonFillStyle;
		borderStyle: buttonBorderStyle
]

{ #category : #mouse }
ScrollBarMorph >> mouseLeaveUpButton: event [
	"The mouse has left the up button."

	event redButtonPressed
		ifFalse: [ 
			upButton
				fillStyle: self normalButtonFillStyle;
				borderStyle: self normalButtonBorderStyle;
				changed ]
]

{ #category : #style }
ScrollBarMorph >> mouseOverBorderStyle [
	"Return the mouse over borderStyle for the receiver."
	
	^self theme scrollbarMouseOverBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> mouseOverButtonBorderStyle [
	"Return the mouse over button borderStyle for the receiver."
	
	^self theme scrollbarMouseOverButtonBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> mouseOverButtonFillStyle [
	"Return the mouse over button fillStyle for the receiver."
	
	^self theme scrollbarMouseOverButtonFillStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> mouseOverFillStyle [
	"Return the mouse over fillStyle for the receiver."
	
	^self theme scrollbarMouseOverFillStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> mouseOverPagingAreaButtonBorderStyle [
	"Return the button borderStyle for the receiver when the mouse
	is over the paging area."
	
	^self theme scrollbarMouseOverBarButtonBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> mouseOverPagingAreaButtonFillStyle [
	"Return the button fillStyle for the receiver when the mouse
	is over the paging area."
	
	^self theme scrollbarMouseOverBarButtonFillStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> mouseOverPagingAreaThumbBorderStyle [
	"Return the thumb borderStyle for the receiver when the mouse
	is over the paging area."
	
	^self theme scrollbarMouseOverBarThumbBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> mouseOverPagingAreaThumbFillStyle [
	"Return the thumb fillStyle for the receiver when the mouse
	is over the paging area."
	
	^self theme scrollbarMouseOverBarThumbFillStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> mouseOverThumbBorderStyle [
	"Return the mouse over thumb borderStyle for the receiver."
	
	^self theme scrollbarMouseOverThumbBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> mouseOverThumbButtonBorderStyle [
	"Return the button borderStyle for the receiver when the mouse
	is over the thumb."
	
	^self theme scrollbarMouseOverThumbButtonBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> mouseOverThumbButtonFillStyle [
	"Return the mouse over thumb fillStyle for the receiver."
	
	^self theme scrollbarMouseOverThumbButtonFillStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> mouseOverThumbFillStyle [
	"Return the mouse over thumb fillStyle for the receiver."
	
	^self theme scrollbarMouseOverThumbFillStyleFor: self
]

{ #category : #mouse }
ScrollBarMorph >> mouseUpInSlider: event [
	"The mouse button has been released."
	
	"If it was not dragging, thre's nothing to do."
	self dragging ifFalse:[^self].
	
	sliderShadow hide.
	(slider containsPoint: event position)
		ifTrue: [slider
					fillStyle: self mouseOverThumbFillStyle;
					borderStyle: self mouseOverThumbBorderStyle]
		ifFalse: [self mouseLeaveThumb: event].
	slider changed.
	
	"Not dragging anymore."
	self dragging:false.
]

{ #category : #style }
ScrollBarMorph >> normalBorderStyle [
	"Return the normal borderStyle for the receiver."
	
	^self theme scrollbarNormalBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> normalButtonBorderStyle [
	"Return the normal button borderStyle for the receiver."
	
	^self theme scrollbarNormalButtonBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> normalButtonFillStyle [
	"Return the normal button fillStyle for the receiver."
	
	^self theme scrollbarNormalButtonFillStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> normalFillStyle [
	"Return the normal fillStyle for the receiver."
	
	^self theme scrollbarNormalFillStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> normalThumbBorderStyle [
	"Return the normal thumb borderStyle for the receiver."
	
	^self theme scrollbarNormalThumbBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> normalThumbFillStyle [
	"Return the normal thumb fillStyle for the receiver."
	
	^self theme scrollbarNormalThumbFillStyleFor: self
]

{ #category : #'private - accessing' }
ScrollBarMorph >> pagingArea [
	^pagingArea
]

{ #category : #style }
ScrollBarMorph >> pressedBorderStyle [
	"Return the pressed borderStyle for the receiver."
	
	^self theme scrollbarPressedBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> pressedButtonBorderStyle [
	"Return the pressed button borderStyle for the receiver."
	
	^self theme scrollbarPressedButtonBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> pressedButtonFillStyle [
	"Return the pressed button fillStyle for the receiver."
	
	^self theme scrollbarPressedButtonFillStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> pressedFillStyle [
	"Return the pressed fillStyle for the receiver."
	
	^self theme scrollbarPressedFillStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> pressedThumbBorderStyle [
	"Return the pressed thumb borderStyle for the receiver."
	
	^self theme scrollbarPressedThumbBorderStyleFor: self
]

{ #category : #style }
ScrollBarMorph >> pressedThumbFillStyle [
	"Return the pressed thumb fillStyle for the receiver."
	
	^self theme scrollbarPressedThumbFillStyleFor: self
]

{ #category : #'scroll timing' }
ScrollBarMorph >> resetTimer [
	timeOfMouseDown := Time millisecondClockValue.
	timeOfLastScroll := timeOfMouseDown - 1000 max: 0.
	nextPageDirection := nil.
	currentScrollDelay := nil
]

{ #category : #scrolling }
ScrollBarMorph >> scrollBarAction [
	^self valueOfProperty: #scrollBarAction
]

{ #category : #scrolling }
ScrollBarMorph >> scrollBarAction: aSymbol [
	self setProperty: #scrollBarAction toValue: aSymbol
]

{ #category : #'private - accessing' }
ScrollBarMorph >> scrollDelta [
	^ scrollDelta
]

{ #category : #'private - accessing' }
ScrollBarMorph >> scrollDelta: d1 pageDelta: d2 [
	"Supply optional increments for better scrolling of, eg, text"
	scrollDelta := d1.
	pageDelta := d2.
]

{ #category : #scrolling }
ScrollBarMorph >> scrollDown: count [
	self setValue: (value + (scrollDelta * count) + 0.000001 min: 1.0)
]

{ #category : #'private - accessing' }
ScrollBarMorph >> scrollDownInit [
	"Initialize a scroll down (from button) operation.
	Fixed to perform immediately with deferred 
	stepping for subsequent hold of button."

	|bc|
	bc := downButton borderStyle baseColor.
	downButton borderInset.
	downButton borderStyle baseColor: bc.
	self resetTimer.
	self scrollBarAction: #doScrollDown.
	self doScrollDown.
	self
		startStepping: #stepAt:
		at: Time millisecondClockValue + self stepTime
		arguments: nil stepTime: nil.
	downButton fillStyle: self pressedButtonFillStyle.
	downButton borderStyle: self pressedButtonBorderStyle
]

{ #category : #scrolling }
ScrollBarMorph >> scrollLeft: count [
	self scrollUp: count
]

{ #category : #'private - accessing' }
ScrollBarMorph >> scrollPageInit: evt [
	"Scroll initiated by the paging area."
	
	self resetTimer.
	self setNextDirectionFromEvent: evt.
	self scrollBarAction: #doScrollByPage.
	self doScrollByPage. "do the first one now since morph stepping is rather variable in its timing
		and the user may release before actually actioned...."
	pagingArea
		fillStyle: self pressedFillStyle;
		borderStyle: self pressedBorderStyle.
	self startStepping: #stepAt: at: Time millisecondClockValue + self stepTime arguments: nil stepTime: nil
]

{ #category : #scrolling }
ScrollBarMorph >> scrollRight: count [
	self scrollDown: count
]

{ #category : #scrolling }
ScrollBarMorph >> scrollUp: count [
	self setValue: (value - (scrollDelta * count) - 0.000001 max: 0.0)
]

{ #category : #'private - accessing' }
ScrollBarMorph >> scrollUpInit [
	"Initialize a scroll up (from button) operation.
	Fixed to perform immediately with deferred 
	stepping for subsequent hold of button."

	|bc|
	bc := upButton borderStyle baseColor.
	upButton borderInset.
	upButton borderStyle baseColor: bc.
	self resetTimer.
	self scrollBarAction: #doScrollUp.
	self doScrollUp.
	self
		startStepping: #stepAt:
		at: Time millisecondClockValue + self stepTime
		arguments: nil stepTime: nil.
	upButton fillStyle: self pressedButtonFillStyle.
	upButton borderStyle: self pressedButtonBorderStyle
]

{ #category : #scrolling }
ScrollBarMorph >> setNextDirectionFromEvent: event [

	nextPageDirection := bounds isWide ifTrue: [
		event cursorPoint x >= slider center x
	]
	ifFalse: [
		event cursorPoint y >= slider center y
	]


]

{ #category : #'model access' }
ScrollBarMorph >> setValue: newValue [
	"Using roundTo: instead of truncateTo: ensures that scrollUp will scroll the same distance as scrollDown.
	Fix for >= 1.0 since, when close the roundTo may round down and not allow the value to reach
	the full range."
	
	newValue >= 1.0
		ifTrue: [^super setValue: 1.0].
	^ super setValue: (newValue roundTo: scrollDelta)
]

{ #category : #'private - accessing' }
ScrollBarMorph >> slider [
	"Answer the slider."

	^slider
]

{ #category : #'private - accessing' }
ScrollBarMorph >> sliderColor: aColor [ 
	"Change the color of the scrollbar to go with aColor."
	| buttonColor |
	super sliderColor: aColor.
	self lastPaneColor: aColor.
	buttonColor := self thumbColor.
	upButton color: buttonColor.
	downButton color: buttonColor.
	slider color: buttonColor slightlyLighter.	
	pagingArea
		fillStyle: self normalFillStyle;
		borderStyle: self normalBorderStyle.
	(self theme scrollbarPagingAreaCornerStyleIn: self window) = #rounded
		ifTrue: [self fillStyle: self normalButtonFillStyle]
		ifFalse: [self fillStyle: self normalFillStyle].
	self borderWidth: 0.
	^self adoptGradientColor: aColor
]

{ #category : #geometry }
ScrollBarMorph >> sliderExtent [
	"The sliderExtent is now stored in the slider itself, not hardcoded as it is in the superclass."
	^slider extent
]

{ #category : #geometry }
ScrollBarMorph >> sliderThickness [
	"Answer the minimum width/height of the scrollbar thumb. Refer to the theme."
	
	^self theme scrollbarMinimumThumbThickness
]

{ #category : #stepping }
ScrollBarMorph >> step [
	| action |
	action := self scrollBarAction.
	action ifNotNil:[self perform: action].
]

{ #category : #stepping }
ScrollBarMorph >> stepTime [
	^ currentScrollDelay ifNil: [300]
]

{ #category : #update }
ScrollBarMorph >> themeChanged [
	"Update the buttons, slider and paging area."

	self
		removeAllMorphs;
		initializeSlider.
	super themeChanged
]

{ #category : #'private - accessing' }
ScrollBarMorph >> thumbColor [
	"Problem: Part of the ScrollBar/Slider code uses 'slider' to mean the entire scrollbar/slider widget, and part of it uses 'slider' to mean only the draggable 'thumb'.  This should be cleaned up so that 'thumb' is used instead of 'slider' where appropriate.  For now, the meaning of thumbColor is clear, at least."

	^self class imageColorFor: self
]

{ #category : #geometry }
ScrollBarMorph >> totalSliderArea [
	| upperBoundsButton |
	upperBoundsButton := upButton.
	^ bounds isWide
		ifTrue: [ upButton right > upperBoundsButton right ifTrue: [ upperBoundsButton := upButton ].
			upperBoundsButton bounds topRight corner: downButton bounds bottomLeft ]
		ifFalse: [ upButton bottom > upperBoundsButton bottom ifTrue: [ upperBoundsButton := upButton ].
			upperBoundsButton bounds bottomLeft corner: downButton bounds topRight ]
]

{ #category : #initialize }
ScrollBarMorph >> upImage [
	"answer a form to be used in the up button"
	^ self class
		arrowOfDirection: (bounds isWide
				ifTrue: [#left]
				ifFalse: [#top])
		size: (self buttonExtent x min: self buttonExtent y)
		color: self buttonImageColor
]

{ #category : #update }
ScrollBarMorph >> updateDownButtonBounds [
	"update the receiver's downButton bounds"
	
	downButton bounds: (self theme scrollBarDownButtonBoundsFor: self)
]

{ #category : #initialize }
ScrollBarMorph >> updateDownButtonImage [
	"update the receiver's downButton.  put a new image inside"
	downButton removeAllMorphs.
	downButton
		addMorphCentered: (ImageMorph new form: self downImage)
]

{ #category : #update }
ScrollBarMorph >> updatePagingAreaBounds [
	"Initialize the receiver's pagingArea."
	
	pagingArea bounds: self totalSliderArea
]

{ #category : #update }
ScrollBarMorph >> updateSliderBounds [
	"Initialize the receiver's slider."
	
	self 
		updateUpButtonBounds;
		updateDownButtonBounds;
		updatePagingAreaBounds.
	super updateSliderBounds.
	
]

{ #category : #update }
ScrollBarMorph >> updateUpButtonBounds [
	"update the receiver's upButton bounds"

	upButton bounds: (self theme scrollBarUpButtonBoundsFor: self)
]

{ #category : #initialize }
ScrollBarMorph >> updateUpButtonImage [
"update the receiver's upButton. put a new image inside"
	upButton removeAllMorphs.
	upButton
		addMorphCentered: (ImageMorph new form: self upImage)
]

{ #category : #'scroll timing' }
ScrollBarMorph >> waitForDelay1: delay1 delay2: delay2 [ 
	"Return true if an appropriate delay has passed since the last scroll operation.
	The delay decreases exponentially from delay1 to delay2."

	| now scrollDelay |
	timeOfLastScroll ifNil: [self resetTimer].	"Only needed for old instances"
	now := Time millisecondClockValue.
	(scrollDelay := currentScrollDelay) ifNil: [scrollDelay := delay1	"initial delay"].
	currentScrollDelay := scrollDelay * 9 // 10 max: delay2.	"decrease the delay"
	timeOfLastScroll := now.
	^true
]

{ #category : #stepping }
ScrollBarMorph >> wantsSteps [
	^self scrollBarAction notNil
]
