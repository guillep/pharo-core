"
A scroll pane that handles its contents accurately.
"
Class {
	#name : #GeneralScrollPaneMorph,
	#superclass : #Morph,
	#instVars : [
		'scroller',
		'hScrollbar',
		'vScrollbar'
	],
	#category : #'Morphic-Widgets-Scrolling'
}

{ #category : #accessing }
GeneralScrollPaneMorph >> adoptPaneColor: paneColor [
	"Adopt the given pane color."
	
	super adoptPaneColor: paneColor.
	self hScrollbar adoptPaneColor: paneColor.
	self vScrollbar adoptPaneColor: paneColor
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> changeScrollerTableLayout [
	"Change the scroller's layout policy to a table layout."

	self scroller changeTableLayout
]

{ #category : #initialize }
GeneralScrollPaneMorph >> defaultColor [
	"Answer the default color/fill style for the receiver."
	
	^ Color transparent
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> defaultScrollTarget [
	"Answer a new default scroll target."

	^ Morph new
		extent: 200@150
]

{ #category : #layout }
GeneralScrollPaneMorph >> doLayoutIn: layoutBounds [ 
	"Compute a new layout based on the given layout bounds."

	|scrollbarChange|
	super doLayoutIn: layoutBounds.
	scrollbarChange := (self vScrollbarShowing = self vScrollbarNeeded) not.
	scrollbarChange := scrollbarChange or: [(self hScrollbarShowing = self hScrollbarNeeded) not].
	self	updateScrollbars.
	scrollbarChange ifFalse: [self resizeScroller]. "if there is a scrollbar change then done already"
	super doLayoutIn: layoutBounds

]

{ #category : #geometry }
GeneralScrollPaneMorph >> extent: newExtent [
	"Update the receiver's extent. Hide/show the scrollbars and resize the scroller
	as neccessary."
	
	|scrollbarChange|
	bounds extent = newExtent ifTrue: [^ self].
	super extent: newExtent.
	scrollbarChange := (self vScrollbarShowing = self vScrollbarNeeded) not.
	scrollbarChange := scrollbarChange or: [(self hScrollbarShowing = self hScrollbarNeeded) not].
	self	updateScrollbars.
	scrollbarChange ifFalse: [self resizeScroller] "if there is a scrollbar change then done already"
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> fitScrollTarget [
	"If the scroller is bigger than the scroll target then
	resize the scroll target to fill the scroller."
	
	|extra|
	extra := 0.
	self scroller width > self scrollTarget width
		ifTrue: [self scrollTarget width: self scroller width]
		ifFalse: [extra := self scrollBarThickness].
	self scroller height - extra > self scrollTarget height
		ifTrue: [self scrollTarget height: self scroller height + extra]
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hHideScrollbar [
	"Hide the horizontal scrollbar."
	
	self hScrollbarShowing ifFalse: [^self].
	self removeMorph: self hScrollbar.
	self vResizeScrollbar.
	self resizeScroller
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hPageDelta [
	"Answer the horizontal page delta."
	
	|pd tw sw|
	tw := self scrollTarget width.
	sw := self scrollBounds width.
	pd := tw - sw  max: 0.
	pd = 0 ifFalse: [pd := sw / pd].
	^pd
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hResizeScrollbar [
	"Resize the horizontal scrollbar to fit the receiver."
	
	|b|
	b := self innerBounds.
	b := b top: b bottom - self scrollBarThickness.
	self vScrollbarShowing ifTrue: [
		b := b right: b right - self scrollBarThickness].
	self hScrollbar bounds: b
]

{ #category : #accessing }
GeneralScrollPaneMorph >> hScrollbar [
	"Answer the value of hScrollbar"

	^ hScrollbar
]

{ #category : #accessing }
GeneralScrollPaneMorph >> hScrollbar: anObject [
	"Set the value of hScrollbar"

	hScrollbar := anObject
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hScrollbarInterval [
	"Answer the computed size of the thumb of the horizontal scrollbar."
	
	^self scrollBounds width asFloat / self scrollTarget width min: 1.0.
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hScrollbarNeeded [
	"Return whether the horizontal scrollbar is needed."
	
	self hScrollbar showsAlways ifTrue: [^true].
	self hScrollbar showsNever ifTrue: [^false].
	^self scrollTarget width +
		(self scrollTarget height > self innerBounds height
			 ifTrue: [self scrollBarThickness] ifFalse: [0]) >
		self innerBounds width
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hScrollbarShowAlways [
	"Set the horizontal scrollbar to always show."
	
	self hScrollbar showAlways.
	self updateScrollbars
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hScrollbarShowNever [
	"Set the horizontal scrollbar to never show."
	
	self hScrollbar showNever.
	self updateScrollbars
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hScrollbarShowWhenNeeded [
	"Set the horizontal scrollbar to show if needed."
	
	self hScrollbar showWhenNeeded.
	self updateScrollbars
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hScrollbarShowing [
	"Answer whether the horizontal scrollbar is showing."
	
	^self hScrollbar owner notNil
	
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hScrollbarValue [
	"Answer the computed horizontal scrollbar value."
	
	|tw sw v|
	tw := self scrollTarget width.
	sw := self scrollBounds width.
	v := tw - sw  max: 0.
	v = 0 ifFalse: [v :=  self scroller offset x asFloat / v min: 1.0].
	^v
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hScrollbarValue: scrollValue [
	"Set the offset of the scroller to match the 0.0-1.0 scroll value."
	
	|r|
	r := self scrollTarget width - self scrollBounds width max: 0.
	self scroller
		offset: (r * scrollValue) rounded @ self scroller offset y
]

{ #category : #geometry }
GeneralScrollPaneMorph >> hSetScrollDelta [
	"Set the horizontal scrollbar delta, value and interval, based on the current scroll bounds and offset."
	
	|pd|
	pd := self hPageDelta.
	self hScrollbar
		scrollDelta: pd / 10 
		pageDelta: pd;
		interval: self hScrollbarInterval;
		setValue: self hScrollbarValue
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hShowScrollbar [
	"Show the horizontal scrollbar."
	
	self hResizeScrollbar.
	self hScrollbarShowing ifTrue: [^self].
	self privateAddMorph: self hScrollbar atIndex: 1.
	self vResizeScrollbar.
	self resizeScroller
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> hUpdateScrollbar [
	"Update the visibility and dimensions of the horizontal scrollbar as needed."
	
	self hScrollbarNeeded
		ifTrue: [self
					hShowScrollbar;
					hResizeScrollbar]
		ifFalse: [self hHideScrollbar]
]

{ #category : #'event handling' }
GeneralScrollPaneMorph >> handlesKeyboard: evt [
	"Yes for page up/down."
	
	^true
]

{ #category : #'events-processing' }
GeneralScrollPaneMorph >> handlesMouseWheel: evt [
	"Do I want to receive mouseWheel events?." 

	^true
]

{ #category : #initialization }
GeneralScrollPaneMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		scroller: self newScroller;
		hScrollbar: self newHScrollbar;
		vScrollbar: self newVScrollbar;
		scrollTarget: self defaultScrollTarget.
	self
		addMorph: self scroller;
		resizeScroller
]

{ #category : #'event handling' }
GeneralScrollPaneMorph >> keyStroke: evt [
	"If pane is not empty, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"

	(self scrollByKeyboard: evt) ifTrue: [^self].
	self scrollTarget keyStroke: evt
]

{ #category : #layout }
GeneralScrollPaneMorph >> minHeight [
	"Fit the width of the scroll target if vResizing is shrinkWrap."
	
	^self vResizing = #shrinkWrap
		ifTrue: [self scrollTarget minExtent y + self scrollbarThickness + 5]
		ifFalse: [super minHeight]
]

{ #category : #layout }
GeneralScrollPaneMorph >> minWidth [
	"Fit the width of the scroll target if hResizing is shrinkWrap."
	
	^self hResizing = #shrinkWrap
		ifTrue: [self scrollTarget minExtent x + self scrollbarThickness + 5]
		ifFalse: [super minWidth]
]

{ #category : #'event handling' }
GeneralScrollPaneMorph >> mouseWheel: event [ 
	"Handle a mouseWheel event."
	
	(self scrollTarget handlesMouseWheel: event)
		ifTrue: [^self scrollTarget mouseWheel: event]. "pass on"
	
	event isUp ifTrue: [ ^ vScrollbar scrollUp: 3 ].
	event isDown ifTrue: [ ^ vScrollbar scrollDown: 3 ].
	event isLeft  ifTrue: [ ^ hScrollbar scrollLeft: 3 ].
	event isRight  ifTrue: [ ^ hScrollbar scrollRight: 3 ].
]

{ #category : #'instance creation' }
GeneralScrollPaneMorph >> newHScrollbar [
	"Answer a new horizontal scrollbar."

	^GeneralScrollBarMorph new
		model: self;
		setValueSelector: #hScrollbarValue:
]

{ #category : #'instance creation' }
GeneralScrollPaneMorph >> newScroller [
	"Answer a new scroller."

	^TransformWithLayoutMorph new
		color: Color transparent
]

{ #category : #'instance creation' }
GeneralScrollPaneMorph >> newVScrollbar [
	"Answer a new vertical scrollbar."

	^GeneralScrollBarMorph new
		model: self;
		setValueSelector: #vScrollbarValue:
]

{ #category : #geometry }
GeneralScrollPaneMorph >> resizeScroller [
	"Resize the scroller to fit the scroll bounds."
	
	self scroller bounds: self scrollBounds
]

{ #category : #accessing }
GeneralScrollPaneMorph >> scrollBarThickness [
	"Answer the width or height of a scrollbar as appropriate to
	its orientation."
	
	^self theme scrollbarThickness
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> scrollBounds [
	"Return the visible scroll area taking into account whether
	the scrollbars need to be shown."
	
	|b|
	b := self innerBounds.
	self vScrollbarNeeded ifTrue: [b := b right: (b right - self scrollBarThickness)].
	self hScrollbarNeeded ifTrue: [b := b bottom: (b bottom - self scrollBarThickness)].
	^b
]

{ #category : #'event handling' }
GeneralScrollPaneMorph >> scrollByKeyboard: event [ 
	"If event is ctrl+up/down then scroll and answer true."
	
	|sb|
	sb := event commandKeyPressed
		ifTrue: [self hScrollbar]
		ifFalse: [self vScrollbar].
	(event keyValue = 30 or: [event keyValue = 11]) ifTrue: [
		sb scrollUp: 3.
		^true].
	(event keyValue = 31 or: [event keyValue = 12])ifTrue: [
		sb scrollDown: 3.
		^true].
	^false
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> scrollTarget [
	"Answer the morph that is scrolled."
	
	^self scroller submorphs first
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> scrollTarget: aMorph [
	"Set the morph that is scrolled."
	
	self scroller
		removeAllMorphs;
		addMorph: aMorph.
	self updateScrollbars
]

{ #category : #'client list accessing' }
GeneralScrollPaneMorph >> scrollToShow: aRectangle [
	"Scroll to include as much of aRectangle as possible, where aRectangle is in the scroller's local space."
	
	|offset|
	offset := self scroller offset.
	((aRectangle top - offset y) >= 0 and: [
		(aRectangle bottom - offset y) <= self innerBounds height])
		ifFalse: [offset := offset x @ (
					(aRectangle top min: self scrollTarget height - self innerBounds height))].
	((aRectangle left - offset x) >= 0 and: [
		(aRectangle right - offset x) <= self innerBounds width])
		ifFalse: [offset := (aRectangle left min: self scrollTarget width - self innerBounds width) @ offset y].
	offset = self scroller offset ifFalse: [
		self scroller offset: offset.
		self setScrollDeltas]
]

{ #category : #defaults }
GeneralScrollPaneMorph >> scrollbarThickness [
	"Answer the width or height of a scrollbar as appropriate to
	its orientation."
	
	^ self theme scrollbarThickness
]

{ #category : #accessing }
GeneralScrollPaneMorph >> scroller [
	"Answer the value of scroller"

	^ scroller
]

{ #category : #accessing }
GeneralScrollPaneMorph >> scroller: anObject [
	"Set the value of scroller"

	scroller := anObject
]

{ #category : #geometry }
GeneralScrollPaneMorph >> setScrollDeltas [
	"Set the ScrollBar deltas, value and interval, based on the current scroll pane size, offset and range."
	
	self
		hSetScrollDelta;
		vSetScrollDelta
]

{ #category : #updating }
GeneralScrollPaneMorph >> updateScrollbars [
	"Update the visibility, dimensions and values of the scrollbars as needed."
	
	self
		vUpdateScrollbar;
		hUpdateScrollbar;
		setScrollDeltas
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vHideScrollbar [
	"Hide the vertical scrollbar."
	
	self vScrollbarShowing ifFalse: [^self].
	self removeMorph: self vScrollbar.
	self hResizeScrollbar.
	self resizeScroller
]

{ #category : #geometry }
GeneralScrollPaneMorph >> vLeftoverScrollRange [
	"Return the entire scrolling range minus the currently viewed area."
	
	^self scrollTarget height - self scrollBounds height max: 0

]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vPageDelta [
	"Answer the vertical page delta."
	
	|pd tw sw|
	tw := self scrollTarget height.
	sw := self scrollBounds height.
	pd := tw - sw  max: 0.
	pd = 0 ifFalse: [pd := sw / pd].
	^pd
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vResizeScrollbar [
	"Resize the vertical scrollbar to fit the receiver."
	
	|b|
	b := self innerBounds.
	b := b left: b right - self scrollBarThickness.
	self hScrollbarShowing ifTrue: [
		b := b bottom: b bottom - self scrollBarThickness].
	self vScrollbar bounds: b
]

{ #category : #accessing }
GeneralScrollPaneMorph >> vScrollbar [
	"Answer the value of vScrollbar"

	^ vScrollbar
]

{ #category : #accessing }
GeneralScrollPaneMorph >> vScrollbar: anObject [
	"Set the value of vScrollbar"

	vScrollbar := anObject
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vScrollbarInterval [
	"Answer the computed size of the thumb of the vertical scrollbar."
	
	^self scrollBounds height asFloat / self scrollTarget height min: 1.0.
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vScrollbarNeeded [
	"Return whether the vertical scrollbar is needed."
	
	self vScrollbar showsAlways ifTrue: [^true].
	self vScrollbar showsNever ifTrue: [^false].
	^self scrollTarget height +
		(self scrollTarget width > self innerBounds width
			 ifTrue: [self scrollBarThickness] ifFalse: [0]) >
		self innerBounds height
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vScrollbarShowAlways [
	"Set the vertical scrollbar to always show."
	
	self vScrollbar showAlways.
	self updateScrollbars
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vScrollbarShowNever [
	"Set the vertical scrollbar to never show."
	
	self vScrollbar showNever.
	self updateScrollbars
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vScrollbarShowWhenNeeded [
	"Set the vertical scrollbar to show if needed."
	
	self vScrollbar showWhenNeeded.
	self updateScrollbars
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vScrollbarShowing [
	"Answer whether the vertical scrollbar is showing."
	
	^self vScrollbar owner notNil
	
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vScrollbarValue [
	"Answer the computed vertical scrollbar value."
	
	|tw sw v|
	tw := self scrollTarget height.
	sw := self scrollBounds height.
	v := tw - sw  max: 0.
	v = 0 ifFalse: [v := self scroller offset y asFloat / v min: 1.0].
	^v
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vScrollbarValue: scrollValue [
	"Set the offset of the scroller to match the 0.0-1.0 scroll value."
	
	|r|
	r := self scrollTarget height - self scrollBounds height max: 0.
	self scroller
		offset: self scroller offset x @ (r * scrollValue) rounded
]

{ #category : #geometry }
GeneralScrollPaneMorph >> vSetScrollDelta [
	"Set the vertical scrollbar delta, value and interval, based on the current scroll bounds and offset."
	
	|pd|
	pd := self vPageDelta.
	self vScrollbar
		scrollDelta: pd / 10 
		pageDelta: pd;
		interval: self vScrollbarInterval;
		setValue: self vScrollbarValue
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vShowScrollbar [
	"Show the vertical scrollbar."
	
	self vResizeScrollbar.
	self vScrollbarShowing ifTrue: [^self].
	self privateAddMorph: self vScrollbar atIndex: 1.
	self hResizeScrollbar.
	self resizeScroller
]

{ #category : #scrollbars }
GeneralScrollPaneMorph >> vUpdateScrollbar [
	"Update the visibility and dimensions of the vertical scrollbar as needed."
	
	self vScrollbarNeeded
		ifTrue: [self
				vShowScrollbar;
				vResizeScrollbar]
		ifFalse: [self vHideScrollbar]
]
