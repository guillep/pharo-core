"
The scroller (a transform) of a scrollPane is driven by the scrollBar.  The scroll values vary from 0.0, meaning zero offset to 1.0 meaning sufficient offset such that the bottom of the scrollable material appears 3/4 of the way down the pane.  The total distance to achieve this range is called the totalScrollRange.

Basic clue about utilization of the ScrollPane class is given in:
	ScrollPane example1.
	ScrollPane example2.
"
Class {
	#name : #ScrollPane,
	#superclass : #ModelMorphic,
	#instVars : [
		'scrollBar',
		'scroller',
		'getMenuSelector',
		'getMenuTitleSelector',
		'hasFocus',
		'hScrollBar'
	],
	#category : #'Morphic-Widgets-Scrolling'
}

{ #category : #settings }
ScrollPane class >> alwaysHideHScrollbar [
	^ false
]

{ #category : #settings }
ScrollPane class >> alwaysShowHScrollbar [
	^ false
]

{ #category : #settings }
ScrollPane class >> alwaysShowVScrollbar [
	^ false
]

{ #category : #shortcuts }
ScrollPane class >> buildScrollPaneShortcuts: aBuilder [
	"Note: the ctrl up and down don't work because they are transformed at the very beginning as mousewheel ctrl up and ctrl down. But why and how ? TG 15/09/2012."

	<keymap>
	(aBuilder shortcut: #scrollUp)
		category: #ScrollPane
		default: Character arrowUp meta
		do: [ :target | target scrollBar scrollUp: 3 ].
	(aBuilder shortcut: #scrollDown)
		category: #ScrollPane
		default: Character arrowDown meta
		do: [ :target | target scrollBar scrollDown: 3 ].
]

{ #category : #examples }
ScrollPane class >> example1 [
	| window scrollPane pasteUpMorph |
	window := SystemWindow new.
	scrollPane := ScrollPane new.
	pasteUpMorph := PasteUpMorph new.
	pasteUpMorph extent: 1000@1000.
	scrollPane scroller addMorph: pasteUpMorph.
	window addMorph: scrollPane frame: (0@0 corner: 1@1).
	window openInWorld.
]

{ #category : #examples }
ScrollPane class >> example2 [
	| window scrollPane pasteUpMorph point textMorph |
	window := SystemWindow new.
	scrollPane := ScrollPane new.
	pasteUpMorph := PasteUpMorph new.
	pasteUpMorph extent: 1000@1000.
	scrollPane scroller addMorph: pasteUpMorph.
	window addMorph: scrollPane frame: (0@0 corner: 1@1).
	0 to: 1000 by: 100 do: 
		[:x | 0 to: 1000 by: 100 do:
			[:y |
				point :=  x@y.
				textMorph := TextMorph new contents: point asString.
				textMorph position: point.
				pasteUpMorph addMorph: textMorph
			]
		].
	window openInWorld.
]

{ #category : #settings }
ScrollPane >> alwaysHideHScrollbar [
	^ self class alwaysHideHScrollbar
]

{ #category : #'accessing - options' }
ScrollPane >> alwaysShowHScrollBar: bool [
	self setProperty: #hScrollBarAlways toValue: bool.
	self hHideOrShowScrollBar.

]

{ #category : #settings }
ScrollPane >> alwaysShowHScrollbar [
	^ self class alwaysShowHScrollbar
]

{ #category : #'accessing - options' }
ScrollPane >> alwaysShowScrollBars: bool [
	"Get rid of scroll bar for short panes that don't want it shown."

	self 
		alwaysShowHScrollBar: bool;
		alwaysShowVScrollBar: bool.

]

{ #category : #'accessing - options' }
ScrollPane >> alwaysShowVScrollBar: bool [

	self setProperty: #vScrollBarAlways toValue: bool.
	self vHideOrShowScrollBar.

]

{ #category : #settings }
ScrollPane >> alwaysShowVScrollbar [
	^ self class alwaysShowVScrollbar
]

{ #category : #accessing }
ScrollPane >> borderWidth: aNumber [ 
	super borderWidth: aNumber.
	self setScrollDeltas
]

{ #category : #initialization }
ScrollPane >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ self theme darkBaseColor
]

{ #category : #initialization }
ScrollPane >> defaultExtent [
	^150@120

]

{ #category : #drawing }
ScrollPane >> drawSubmorphsOn: aCanvas [ 
	"Draw the focus here since we are using inset bounds
	for the focus rectangle."

	super drawSubmorphsOn: aCanvas.
	self hasKeyboardFocus ifTrue: [self drawKeyboardFocusOn: aCanvas].

]

{ #category : #geometry }
ScrollPane >> extent: newExtent [
	
	| oldW oldH wasHShowing wasVShowing noVPlease noHPlease minH minW |
	
	oldW := self width.
	oldH := self height.
	wasHShowing := self hIsScrollbarShowing.
	wasVShowing := self vIsScrollbarShowing.

	"Figure out the minimum width and height for this pane so that scrollbars will appear"
	noVPlease := self valueOfProperty: #noVScrollBarPlease ifAbsent: [false]. 
	noHPlease := self valueOfProperty: #noHScrollBarPlease ifAbsent: [false]. 
	minH := self scrollBarThickness + 16.
	minW := self scrollBarThickness + 20.
	noVPlease ifTrue:[ 
		noHPlease
			ifTrue:[minH := 1. minW := 1 ]
			ifFalse:[minH := self scrollBarThickness ].
	] ifFalse:[
		noHPlease
			ifTrue:[minH := self scrollBarThickness + 5].
	].
	super extent: (newExtent max: (minW@minH)).

	"Now reset widget sizes"
	self resizeScrollBars; resizeScroller; hideOrShowScrollBars.
	
	"Now resetScrollDeltas where appropriate, first the vScrollBar..."
	((self height ~~ oldH) or: [ wasHShowing ~~ self hIsScrollbarShowing]) ifTrue:
		[self vIsScrollbarShowing ifTrue: [ self vSetScrollDelta ]].
			
	"...then the hScrollBar"
	((self width ~~ oldW) or: [wasVShowing ~~ self vIsScrollbarShowing]) ifTrue:
		[self hIsScrollbarShowing ifTrue: [ self hSetScrollDelta ]].


]

{ #category : #geometry }
ScrollPane >> extraScrollRange [
	"Return the amount of extra blank space to include below the bottom of the scroll content."
	"The classic behavior would be ^bounds height - (bounds height * 3 // 4)"
	^ self scrollDeltaHeight
]

{ #category : #'event handling' }
ScrollPane >> findSubmorphFor: ptY [
	^ scroller
		findSubmorphBinary: [ :item | 
			(ptY between: item top and: item bottom)
				ifTrue: [ 0 ]
				ifFalse: [ 
					| itemCenter |
					itemCenter := (item top + item bottom) // 2.
					ptY < itemCenter
						ifTrue: [ -1 ]
						ifFalse: [ 1 ]	"found" ] ]
]

{ #category : #menu }
ScrollPane >> getMenu: shiftKeyState [
	"Answer the menu for this text view, supplying an empty menu to be filled in. If the menu selector takes an extra argument, pass in the current state of the shift key."
	| menu aMenu aTitle |
	self getMenuSelector == nil ifTrue: [^ nil].
	menu := UIManager default newMenuIn: self for: self model.
	aTitle := getMenuTitleSelector ifNotNil: [self model perform: getMenuTitleSelector].
	self getMenuSelector numArgs = 1 ifTrue:
		[aMenu := self model perform: self getMenuSelector with: menu.
		aTitle ifNotNil:  [aMenu addTitle: aTitle].
		^ aMenu].
	self getMenuSelector numArgs = 2 ifTrue:
		[aMenu := self model perform: self getMenuSelector with: menu with: shiftKeyState.
		aTitle ifNotNil:  [aMenu addTitle: aTitle].
		^ aMenu].
	^ self error: 'The getMenuSelector must be a 1- or 2-keyword symbol'
]

{ #category : #geometry }
ScrollPane >> hExtraScrollRange [
	"Return the amount of extra blank space to include below the bottom of the scroll content."
	^ self scrollDeltaWidth

]

{ #category : #scrolling }
ScrollPane >> hHideOrShowScrollBar [
	"Hide or show the scrollbar depending on if the pane is scrolled/scrollable."

	self hIsScrollbarNeeded
		ifTrue:[ self hShowScrollBar ]
		ifFalse: [ self hHideScrollBar ].

]

{ #category : #scrolling }
ScrollPane >> hHideScrollBar [
	self hIsScrollbarShowing ifFalse: [^scroller offset: (self hMargin negated@scroller offset y)].
	self removeMorph: hScrollBar.
	scroller offset: (self hMargin negated@scroller offset y).
	self resetExtent.


]

{ #category : #'geometry testing' }
ScrollPane >> hIsScrollable [

	"If the contents of the pane are too small to scroll, return false."
	^ self hLeftoverScrollRange > 0
	

]

{ #category : #scrolling }
ScrollPane >> hIsScrollbarNeeded [
"Return whether the horz scrollbar is needed"

	"Don't show it if we were told not to."
	(self valueOfProperty: #noHScrollBarPlease ifAbsent: [false]) ifTrue: [^false].

	"Always show it if we were told to"
	(self valueOfProperty: #hScrollBarAlways ifAbsent: [false]) ifTrue: [^true].

	^self hIsScrollable

]

{ #category : #'geometry testing' }
ScrollPane >> hIsScrollbarShowing [
	"Return true if a horz scroll bar is currently showing"

	^submorphs includes: hScrollBar

]

{ #category : #'geometry testing' }
ScrollPane >> hIsScrolled [
	"If the scroller is not set to x = 0, then the pane has been h-scrolled."
	^scroller offset x > 0

]

{ #category : #geometry }
ScrollPane >> hLeftoverScrollRange [
	"Return the entire scrolling range minus the currently viewed area."
	| w |
	scroller hasSubmorphs ifFalse: [^0].
	w :=  bounds width.
	self vIsScrollbarShowing ifTrue:[ w := w - self scrollBarThickness ].
	^ (self hTotalScrollRange - w roundTo: self scrollDeltaHeight) max: 0

]

{ #category : #accessing }
ScrollPane >> hMargin [
"pixels of whitespace at to the left of the scroller when the hScrollBar offset is 0"
	^3

]

{ #category : #geometry }
ScrollPane >> hResizeScrollBar [

	| topLeft h |

	(self valueOfProperty: #noHScrollBarPlease ifAbsent: [false]) ifTrue: [^self].
	bounds ifNil: [ self fullBounds ].
	
	h := self scrollBarThickness.
	topLeft := bounds bottomLeft + (borderWidth @ (h + borderWidth) negated).
	hScrollBar bounds: (topLeft extent: self hScrollBarWidth@ h)

]

{ #category : #'scroll bar events' }
ScrollPane >> hScrollBarMenuButtonPressed: event [
	^ self scrollBarMenuButtonPressed: event

]

{ #category : #scrolling }
ScrollPane >> hScrollBarValue: scrollValue [
	| x systemWindow |
	
	self hIsScrollbarShowing ifFalse: 
		[ ^ scroller offset: (0 - self hMargin)@scroller offset y ].
	((x := self hLeftoverScrollRange * scrollValue) <= 0)
		ifTrue:[ x := 0 - self hMargin ].
	scroller offset: (x@scroller offset y).

	owner ifNil: [ ^ self ].
	
	systemWindow := self window.
	systemWindow ifNotNil:
		[ systemWindow 
			announce: (WindowScrolling new step: scrollValue@0; window: systemWindow) ].
		
	self announcer announce: (PaneScrolling new 
		step: scrollValue@0;
		scrollPane: self;
		yourself)
]

{ #category : #geometry }
ScrollPane >> hScrollBarWidth [
"Return the width of the horizontal scrollbar"


	| w |
	
	w := bounds width - (2 * borderWidth).
	
	self vIsScrollbarNeeded
		ifTrue: [w := w - self scrollBarThickness ].
		
	^w 

]

{ #category : #geometry }
ScrollPane >> hSetScrollDelta [
	"Set the ScrollBar deltas, value and interval, based on the current scroll pane size, offset and range."
	| range delta |

	scroller hasSubmorphs ifFalse:[scrollBar interval: 1.0. ^self].
	
	delta := self scrollDeltaWidth.
	range := self hLeftoverScrollRange.
	range = 0 ifTrue: [ hScrollBar scrollDelta: 0.02 pageDelta: 0.2; interval: 1.0; setValue: 0. ^self].

	"Set up for one line (for arrow scrolling), or a full pane less one line (for paging)."

	hScrollBar 
			scrollDelta: (delta / range) asFloat 
			pageDelta: ((self innerBounds width - delta) / range) asFloat.
	hScrollBar interval: ((self innerBounds width) / self hTotalScrollRange) asFloat.
	hScrollBar setValue: ((scroller offset x / range) min: 1.0) asFloat.

]

{ #category : #scrolling }
ScrollPane >> hShowScrollBar [

	self hIsScrollbarShowing ifTrue: [^self].
	self hResizeScrollBar.
	self privateAddMorph: hScrollBar atIndex: 1.
	self resetExtent.

]

{ #category : #geometry }
ScrollPane >> hTotalScrollRange [
	"Return the entire scrolling range."
	^ self hUnadjustedScrollRange + self hExtraScrollRange + self hMargin

]

{ #category : #geometry }
ScrollPane >> hUnadjustedScrollRange [
	"Return the width extent of the receiver's submorphs."

	| submorphBounds |
	submorphBounds := scroller localSubmorphBounds ifNil: [^ 0].
	^ submorphBounds right

]

{ #category : #'event handling' }
ScrollPane >> handlesMouseDown: evt [
	^ true

]

{ #category : #'event handling' }
ScrollPane >> handlesMouseOver: evt [
	"Could just ^ true, but this ensures that scroll bars won't flop out
	if you mouse-over appendages such as connecting pins."
	"self flag: #arNote." "I have no idea how the code below could've ever worked. If the receiver does not handle mouse over events then it should not receive any #mouseLeave if the mouse leaves the receiver for real. This is because 'evt cursorPoint' describes the *end* point of the movement and considering that the code would return false if the move ends outside the receiver the scroll bars should never pop back in again. Which is exactly what happens with the new event logic if you don't just ^true. I'm leaving the code in for reference - perhaps somebody can make sense from it; I sure cannot."
	^true
"
	| cp |
	cp := evt cursorPoint.
	(bounds containsPoint: cp)
		ifTrue: [^ true]			
		ifFalse: [self submorphsDo:
					[:m | (m containsPoint: cp) ifTrue:
							[m == scrollBar
								ifTrue: [^ true]
								ifFalse: [^ false]]].
				^ false]
"
]

{ #category : #accessing }
ScrollPane >> hasFocus [
	"hasFocus is currently set by mouse enter/leave events.
	This inst var should probably be moved up to a higher superclass."

	^ hasFocus ifNil: [false]
]

{ #category : #'accessing - options' }
ScrollPane >> hideHScrollBarIndefinitely: bool [
	"Get rid of scroll bar for short panes that don't want it shown."

	self setProperty: #noHScrollBarPlease toValue: bool.
	self hHideOrShowScrollBar.

]

{ #category : #scrolling }
ScrollPane >> hideOrShowScrollBars [

	| wasHShowing wasVShowing |

	wasVShowing := self vIsScrollbarShowing.
	wasHShowing := self hIsScrollbarShowing.

	self 
		vHideOrShowScrollBar; 
		hHideOrShowScrollBar; 
		resizeScrollBars.

	(wasVShowing and: [self vIsScrollbarShowing not]) ifTrue:
		["Make sure the delta is 0"
		(scroller offset y = 0) 
				ifFalse:[ scroller offset: (scroller offset x@0) ]].
			
	(wasHShowing and: [self hIsScrollbarShowing not]) ifTrue:
		[(scroller offset x <= 0)
				ifFalse:[ scroller offset: (self hMargin negated@scroller offset y)]].

]

{ #category : #scrolling }
ScrollPane >> hideScrollBars [
	self
		vHideScrollBar;
		hHideScrollBar

]

{ #category : #'accessing - options' }
ScrollPane >> hideScrollBarsIndefinitely [
	self hideScrollBarsIndefinitely: true

]

{ #category : #'accessing - options' }
ScrollPane >> hideScrollBarsIndefinitely: bool [
	"Get rid of scroll bar for short panes that don't want it shown."

	self hideVScrollBarIndefinitely: bool.
	self hideHScrollBarIndefinitely: bool.

]

{ #category : #'accessing - options' }
ScrollPane >> hideVScrollBarIndefinitely: bool [
	"Get rid of scroll bar for short panes that don't want it shown."

	self setProperty: #noVScrollBarPlease toValue: bool.
	self vHideOrShowScrollBar.

]

{ #category : #initialization }
ScrollPane >> initialize [
	
	"initialize the state of the receiver"
	super initialize.
	hasFocus := false.
	self initializeScrollBars.
	self extent: self defaultExtent.
	self hideOrShowScrollBars.



]

{ #category : #initialization }
ScrollPane >> initializeScrollBars [
	"initialize the receiver's scrollBar"

	(scrollBar := ScrollBarMorph new model: self; setValueSelector: #vScrollBarValue:)
		borderWidth: 1;
		borderColor: Color black.
	(hScrollBar := ScrollBarMorph new model: self; setValueSelector: #hScrollBarValue:)
		borderWidth: 1;
		borderColor: Color black.
	self initializeScroller.
	self addMorph: scrollBar.
	self addMorph: hScrollBar.
	self alwaysShowVScrollbar
		ifTrue: [ self alwaysShowVScrollBar: true ].
	self alwaysHideHScrollbar
		ifTrue: [ self hideHScrollBarIndefinitely: true ]
		ifFalse: [ 
			self alwaysShowHScrollbar
				ifTrue: [ self alwaysShowHScrollBar: true ] ]
]

{ #category : #initialization }
ScrollPane >> initializeScroller [
	scroller := self newTransformMorph color: Color transparent.
	scroller offset: (self hMargin negated) @ 0.
	self addMorph: scroller
]

{ #category : #initialization }
ScrollPane >> initializeShortcuts: aKMDispatcher [
	super initializeShortcuts: aKMDispatcher.
	aKMDispatcher attachCategory: #ScrollPane
]

{ #category : #geometry }
ScrollPane >> innerBounds [
	| inner |
	inner := super innerBounds.
	(submorphs includes: scrollBar) ifTrue: [ inner := inner topLeft corner: (inner right - scrollBar width) @ inner bottom ].
	^ self hIsScrollbarShowing
		ifFalse: [ inner ]
		ifTrue: [ inner topLeft extent: inner extent - (0 @ self scrollBarThickness) ]
]

{ #category : #testing }
ScrollPane >> isAutoFit [
	^false
]

{ #category : #'geometry testing' }
ScrollPane >> isScrolledFromTop [
	"Have the contents of the pane been scrolled, so that the top of the contents are not visible?"
	^scroller offset y > 0

]

{ #category : #'event handling' }
ScrollPane >> itemFromPoint: aPoint [
	"Return the list element (morph) at the given point or nil if outside"

	| ptY |
	scroller hasSubmorphs ifFalse: [ ^ nil ].
	(scroller fullBounds containsPoint: aPoint) ifFalse: [ ^ nil ].
	ptY := (scroller firstSubmorph point: aPoint from: self) y.
	"note: following assumes that submorphs are vertical, non-overlapping, and ordered"
	scroller firstSubmorph top > ptY ifTrue: [ ^ nil ].
	scroller lastSubmorph bottom < ptY ifTrue: [ ^ nil ].
	"now use binary search"
	^ self findSubmorphFor: ptY.
]

{ #category : #'event handling' }
ScrollPane >> keyDown: evt [
	"If pane is not empty, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"

	(self scrollByKeyboard: evt) ifTrue: [^self].
	scroller submorphs last keyDown: evt
]

{ #category : #'event handling' }
ScrollPane >> keyStroke: evt [
	"If pane is not empty, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"

	scroller submorphs last keyStroke: evt
]

{ #category : #layout }
ScrollPane >> layoutProportionallyIn: newBounds [
	"Layout specific. Apply the given bounds to the receiver."
	self layoutFrame ifNil:[^self].
	"before applying the proportional values make sure the receiver's layout is computed"
	self isAutoFit ifTrue: [self fullBounds].
	^super layoutProportionallyIn: newBounds 
]

{ #category : #menu }
ScrollPane >> menuTitleSelector: aSelector [
	getMenuTitleSelector := aSelector
]

{ #category : #'event handling' }
ScrollPane >> mouseDown: evt [
	self flag: #todo. "This is a quick fix for ensure cmd+click works. 
	see: http://code.google.com/p/pharo/issues/detail?id=7403
	probably a better fix is just remove it, but I want to prevent any possible side effects and 
	there is no time for study the issue as it would be required"
	(evt yellowButtonPressed and: [ evt commandKeyPressed not ]) "First check for option (menu) click"
		ifTrue: [ (self yellowButtonActivity: evt shiftPressed) 
			ifTrue: [ ^ super mouseDown: evt. ]].
	
	"If pane is not empty, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"
	scroller hasSubmorphs 
		ifTrue: [ scroller submorphs last mouseDown: (evt transformedBy: (scroller transformFrom: self)) ].
	
	self eventHandler
		ifNotNil: [ self eventHandler mouseDown: evt fromMorph: self ]
]

{ #category : #'event handling' }
ScrollPane >> mouseEnter: event [
	hasFocus := true.

]

{ #category : #'event handling' }
ScrollPane >> mouseLeave: event [
	hasFocus := false.
]

{ #category : #'event handling' }
ScrollPane >> mouseMove: evt [
	"If pane is not empty, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)."
	scroller hasSubmorphs ifTrue:
		[scroller submorphs last mouseMove: (evt transformedBy: (scroller transformFrom: self))]
]

{ #category : #'event handling' }
ScrollPane >> mouseUp: evt [
	"If pane is not empty, pass the event to the last submorph,
	assuming it is the most appropriate recipient (!)"
	scroller hasSubmorphs ifTrue:
		[scroller submorphs last mouseUp: (evt transformedBy: (scroller transformFrom: self))]
]

{ #category : #initialization }
ScrollPane >> newTransformMorph [
	^TransformMorph new 

]

{ #category : #accessing }
ScrollPane >> numSelectionsInView [
	"Answer the scroller's height based on the average number of submorphs."
	
	^scroller numberOfItemsPotentiallyInView
]

{ #category : #geometry }
ScrollPane >> resetExtent [
	"Reset the extent. (may be overridden by subclasses which need to do more than this)"
	self resizeScroller
]

{ #category : #geometry }
ScrollPane >> resizeScrollBars [
	self vResizeScrollBar; hResizeScrollBar

]

{ #category : #geometry }
ScrollPane >> resizeScroller [

	scroller bounds: self innerBounds
]

{ #category : #accessing }
ScrollPane >> scrollBar [
	^scrollBar
]

{ #category : #'scroll bar events' }
ScrollPane >> scrollBarMenuButtonPressed: event [
	^ self yellowButtonActivity: event shiftPressed
]

{ #category : #scrolling }
ScrollPane >> scrollBy: delta [
	"Move the contents in the direction delta."

	| newYoffset r newXoffset |
	
	"Set the offset on the scroller"
	newYoffset := scroller offset y - delta y max: 0.
	newXoffset := scroller offset x - delta x max: (self hMargin negated).
	
	scroller offset: newXoffset@ newYoffset.

	"Update the scrollBars"
	(r := self vLeftoverScrollRange) = 0
		ifTrue: [scrollBar value: 0.0]
		ifFalse: [scrollBar value: newYoffset asFloat / r].
	(r := self hLeftoverScrollRange) = 0
		ifTrue: [hScrollBar value: 0.0]
		ifFalse: [hScrollBar value: newXoffset asFloat / r]

]

{ #category : #'event handling' }
ScrollPane >> scrollByKeyboard: event [ 
	"If event is ctrl+up/down then scroll and answer true"
	(event controlKeyPressed or:[event commandKeyPressed]) ifFalse: [^ false].
	event keyValue = 30
		ifTrue: 
			[scrollBar scrollUp: 3.
			^ true].
	event keyValue = 31
		ifTrue: 
			[scrollBar scrollDown: 3.
			^ true].
	^ false
]

{ #category : #geometry }
ScrollPane >> scrollDeltaHeight [
	"Return the increment in pixels which this pane should be scrolled (normally a subclass responsibility)."
	^ 10

]

{ #category : #geometry }
ScrollPane >> scrollDeltaWidth [
	"Return the increment in pixels which this pane should be scrolled (normally a subclass responsibility)."
	
	^10

]

{ #category : #scrolling }
ScrollPane >> scrollToShow: aRectangle [
	"scroll to include as much of aRectangle as possible, where aRectangle is in the scroller's local space"
	| visibleRect dx dy |
	visibleRect := Rectangle origin: scroller offset extent: self innerBounds extent.
	dx := (aRectangle width < visibleRect width)
		ifTrue: [ (visibleRect right - aRectangle right) min: 0 max: (visibleRect left - aRectangle left) ]
		ifFalse: [ (visibleRect left - aRectangle left) min: 0 max: (visibleRect right - aRectangle right) ].
	dy := (aRectangle height < visibleRect height)
		ifTrue: [ (visibleRect bottom - aRectangle bottom) min: 0 max: (visibleRect top - aRectangle top) ]
		ifFalse: [ (visibleRect top - aRectangle top) min: 0 max: (visibleRect bottom - aRectangle bottom) ].
	self scrollBy: dx@dy.
]

{ #category : #accessing }
ScrollPane >> scroller [
	^ scroller
]

{ #category : #accessing }
ScrollPane >> scroller: aTransformMorph [
	scroller ifNotNil:[scroller delete].
	scroller := aTransformMorph.
	self addMorph: scroller.
	self resizeScroller.
]

{ #category : #geometry }
ScrollPane >> setScrollDeltas [
	"Set the ScrollBar deltas, value and interval, based on the current scroll pane size, offset and range."

	scroller hasSubmorphs ifFalse: 
		[scrollBar interval: 1.0. 
		hScrollBar interval: 1.0. 
		^ self].
	
"NOTE: fullbounds commented out now -- trying to find a case where this expensive step is necessary -- perhaps there is a less expensive way to handle that case."
	"scroller fullBounds." "force recompute so that leftoverScrollRange will be up-to-date"
	self hideOrShowScrollBars.
	
	self vIsScrollbarShowing ifTrue:[ self vSetScrollDelta ].
	self hIsScrollbarShowing ifTrue:[ self hSetScrollDelta ].

]

{ #category : #'scroll bar events' }
ScrollPane >> shiftedTextPaneMenuRequest [
	"The more... button was hit from the text-pane menu"

	^ self yellowButtonActivity: true
]

{ #category : #'scroll bar events' }
ScrollPane >> shiftedYellowButtonActivity [
	^ self yellowButtonActivity: true
]

{ #category : #'accessing - options' }
ScrollPane >> showHScrollBarOnlyWhenNeeded: bool [
	"Get rid of scroll bar for short panes that don't want it shown."

	self setProperty: #noHScrollBarPlease toValue: bool.
	self setProperty: #hScrollBarAlways toValue: bool.
	
	self hHideOrShowScrollBar.

]

{ #category : #scrolling }
ScrollPane >> showScrollBars [
	self  vShowScrollBar; hShowScrollBar

]

{ #category : #'accessing - options' }
ScrollPane >> showScrollBarsOnlyWhenNeeded: bool [

	self showHScrollBarOnlyWhenNeeded: bool.
	self showVScrollBarOnlyWhenNeeded: bool.

]

{ #category : #'accessing - options' }
ScrollPane >> showVScrollBarOnlyWhenNeeded: bool [
	"Get rid of scroll bar for short panes that don't want it shown."

	self setProperty: #noVScrollBarPlease toValue: bool.
	self setProperty: #vScrollBarAlways toValue: bool.
	self vHideOrShowScrollBar.

]

{ #category : #'scroll bar events' }
ScrollPane >> unshiftedYellowButtonActivity [
	^ self yellowButtonActivity: false
]

{ #category : #geometry }
ScrollPane >> vExtraScrollRange [
	"Return the amount of extra blank space to include below the bottom of the scroll content."
	"The classic behavior would be ^bounds height - (bounds height * 3 // 4)"
	^ self scrollDeltaHeight

]

{ #category : #scrolling }
ScrollPane >> vHideOrShowScrollBar [

	self vIsScrollbarNeeded
		ifTrue:[ self vShowScrollBar ]
		ifFalse:[ self vHideScrollBar ].

]

{ #category : #scrolling }
ScrollPane >> vHideScrollBar [
	self vIsScrollbarShowing ifFalse: [^self].
	self removeMorph: scrollBar.
	self resetExtent
	

]

{ #category : #'geometry testing' }
ScrollPane >> vIsScrollable [
"Return whether the verticle scrollbar is scrollable"

	"If the contents of the pane are too small to scroll, return false."
	^ self vLeftoverScrollRange > 0
		"treat a single line as non-scrollable"
		and: [self vTotalScrollRange > (self scrollDeltaHeight * 3/2)]

]

{ #category : #scrolling }
ScrollPane >> vIsScrollbarNeeded [
"Return whether the verticle scrollbar is needed"
	
	"Don't show it if we were told not to."
	(self valueOfProperty: #noVScrollBarPlease ifAbsent: [false]) ifTrue: [^false].

	"Always show it if we were told to"
	(self valueOfProperty: #vScrollBarAlways ifAbsent: [false]) ifTrue: [^true].
	
	^self vIsScrollable

]

{ #category : #'geometry testing' }
ScrollPane >> vIsScrollbarShowing [
	"Return true if a retractable scroll bar is currently showing"

	^submorphs includes: scrollBar

]

{ #category : #'geometry testing' }
ScrollPane >> vIsScrolled [
	"If the scroller is not set to y = 0, then the pane has been scrolled."
	^scroller offset y > 0

]

{ #category : #geometry }
ScrollPane >> vLeftoverScrollRange [
	"Return the entire scrolling range minus the currently viewed area."
	scroller hasSubmorphs ifFalse:[^0].
	^ (self vTotalScrollRange -  self vScrollBarHeight roundTo: self scrollDeltaHeight) max: 0

]

{ #category : #geometry }
ScrollPane >> vResizeScrollBar [
	| w topLeft  |
	w := self scrollBarThickness.
	topLeft := bounds topRight - ((w + borderWidth - 0) @ (0 - borderWidth)).
	scrollBar bounds: (topLeft extent: w @ self vScrollBarHeight)
]

{ #category : #geometry }
ScrollPane >> vScrollBarHeight [
	| h |

	h := bounds height - (2 * borderWidth).
	self hIsScrollbarNeeded
		ifTrue:[ h := h - self scrollBarThickness. ].
	^h

]

{ #category : #'scroll bar events' }
ScrollPane >> vScrollBarMenuButtonPressed: event [
	^ self scrollBarMenuButtonPressed: event

]

{ #category : #scrolling }
ScrollPane >> vScrollBarValue: scrollValue [
	| systemWindow |
	scroller hasSubmorphs ifFalse: [^ self].
	scroller offset: (scroller offset x @ (self vLeftoverScrollRange * scrollValue) rounded).

	owner ifNil: [ ^ self ].
	systemWindow := self window.
		
	systemWindow ifNotNil:
		[ systemWindow 
			announce: (WindowScrolling new step: 0@scrollValue; window: systemWindow) ].
		
	self announcer announce: (PaneScrolling new 
		step: 0@scrollValue;
		scrollPane: self;
		yourself)


]

{ #category : #geometry }
ScrollPane >> vSetScrollDelta [
	"Set the ScrollBar deltas, value and interval, based on the current scroll pane size, offset and range."
	| range delta |

	scroller hasSubmorphs ifFalse:[scrollBar interval: 1.0. ^self].
	
	delta := self scrollDeltaHeight.
	range := self vLeftoverScrollRange.
	range = 0 ifTrue: [^ scrollBar scrollDelta: 0.02 pageDelta: 0.2; interval: 1.0; setValue: 0].

	"Set up for one line (for arrow scrolling), or a full pane less one line (for paging)."
	scrollBar scrollDelta: (delta / range) asFloat 
			pageDelta: ((self innerBounds height - delta) / range) asFloat.
	scrollBar interval: ((self innerBounds height) / self vTotalScrollRange) asFloat.
	scrollBar setValue: (scroller offset y / range min: 1.0) asFloat.

]

{ #category : #scrolling }
ScrollPane >> vShowScrollBar [

	self vIsScrollbarShowing ifTrue: [^ self].
	self vResizeScrollBar.
	self privateAddMorph: scrollBar atIndex: 1.
	self resetExtent

]

{ #category : #geometry }
ScrollPane >> vTotalScrollRange [
	"Return the entire scrolling range."
	^ self vUnadjustedScrollRange + self vExtraScrollRange

]

{ #category : #geometry }
ScrollPane >> vUnadjustedScrollRange [
	"Return the height extent of the receiver's submorphs."
	| submorphBounds |
	submorphBounds := scroller localSubmorphBounds ifNil: [^ 0].
	^ submorphBounds bottom

]

{ #category : #menu }
ScrollPane >> wantsYellowButtonMenu [
	"Answer true if the receiver wants a yellow button menu"
	^ self getMenuSelector notNil
]

{ #category : #'scroll bar events' }
ScrollPane >> yellowButtonActivity: shiftKeyState [
	
	(self getMenu: shiftKeyState) 
		ifNotNil: [ :menu|
			menu setInvokingView: self.
			menu popUpEvent: self activeHand lastEvent in: self world.
			^ true].
	^ false
]
