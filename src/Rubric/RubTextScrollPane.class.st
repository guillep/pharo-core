"
I am a text morph with a scrollbar 
"
Class {
	#name : #RubTextScrollPane,
	#superclass : #GeneralScrollPaneMorph,
	#instVars : [
		'drawFocusBorder'
	],
	#category : #'Rubric-Editing-Widgets'
}

{ #category : #'dropping/grabbing' }
RubTextScrollPane >> aboutToBeGrabbedBy: aHand [
	^ nil
]

{ #category : #accessing }
RubTextScrollPane >> adoptPaneColor: paneColor [
	"Adopt the given pane color."
	
	super adoptPaneColor: paneColor.
	self hScrollbar adoptPaneColor: paneColor darker.
	self vScrollbar adoptPaneColor: paneColor darker
]

{ #category : #'text area protocol' }
RubTextScrollPane >> appendText: stringOrText [
	"Accept new text contents with line breaks only as in the text.
	Fit my width and height to the result."
	self textArea appendText: stringOrText.
	self scrollSelectionIntoView.

]

{ #category : #'text area protocol' }
RubTextScrollPane >> beNotWrapped [
	self handleWrappingPolicyChange: [ self textArea beNotWrapped ]
]

{ #category : #'text area protocol' }
RubTextScrollPane >> beWrapped [
	self handleWrappingPolicyChange: [ self textArea beWrapped ]
]

{ #category : #geometry }
RubTextScrollPane >> currentHScrollBarThickness [
	^ self hScrollbarNeeded
		ifTrue: [ self scrollBarThickness ]
		ifFalse: [ 0 ]
]

{ #category : #geometry }
RubTextScrollPane >> currentVScrollBarThickness [
	^ self vScrollbarNeeded
		ifTrue: [ self scrollBarThickness ]
		ifFalse: [ 0 ]
]

{ #category : #initialization }
RubTextScrollPane >> defaultScrollTarget [
	^ RubEditingArea new
]

{ #category : #accessing }
RubTextScrollPane >> drawFocusBorder [
	^ drawFocusBorder ifNil: [ drawFocusBorder := true ]
]

{ #category : #accessing }
RubTextScrollPane >> drawFocusBorder: aBoolean [
	drawFocusBorder := aBoolean.
	self changed
]

{ #category : #drawing }
RubTextScrollPane >> drawSubmorphsOn: aCanvas [ 
	"Draw the focus here since we are using inset bounds
	for the focus rectangle."

	super drawSubmorphsOn: aCanvas.
	self textArea readOnly ifTrue: [ ^self ].
	self drawFocusBorder ifFalse: [ ^ self ].
	(self hasKeyboardFocus or: [ self textArea hasFindReplaceFocus ]) 
		ifTrue: [self drawKeyboardFocusOn: aCanvas].

]

{ #category : #drawing }
RubTextScrollPane >> drawSubmorphsOnAthensCanvas: anAthensCanvas [
	"Draw the focus here since we are using inset bounds
	for the focus rectangle."

	super drawSubmorphsOnAthensCanvas: anAthensCanvas.
	self textArea readOnly ifTrue: [ ^self ].
	self drawFocusBorder ifFalse: [ ^self ].
	(self hasKeyboardFocus or: [ self textArea hasFindReplaceFocus ]) 
		ifTrue: [self drawKeyboardFocusOnAthensCanvas: anAthensCanvas].

]

{ #category : #geometry }
RubTextScrollPane >> extent: newExtent [
	"Update the receiver's extent. Hide/show the scrollbars and resize the scroller
	as necessary."

	"we need to compare against 1 pixel, otherwise may end up in an infinite loop.
	If newExtent, current extent and current position represent a float number
	inner scrollpane rounding gives difference around 0.5 pixel disallowing us
	to use Point>>#closeTo:. It is quite dirty fix, general one would require enormous
	amount of work to improve how morphic works with floats. This issue successfully
	addressed in Bloc"
	(bounds extent - newExtent) abs < (1@1)
		ifTrue: [ ^ self ].
	super extent: newExtent.
	self owner ifNotNil: [ :o | o scrollerExtentChanged ].
	self wrapped
		ifTrue: [ self updateScrollbars ]
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> fitScrollTarget [
	"if the scroller extent is different that the textArea 
	extent, then, if the textArea is wrapped, then resize 
	the textArea width accordingly
	If the textArea is not wrapped, then do nothing
	"
	
	self wrapped
		ifFalse: [ ^ self ].
	self fitScrollTargetWidth 
]

{ #category : #geometry }
RubTextScrollPane >> fitScrollTargetWidth [
	"if the scroller extent is different that the textArea 
	extent, then, if the textArea is wrapped, then resize 
	the textArea width accordingly
	If the textArea is not wrapped, then do nothing
	"
	self scroller width = self textArea width
		ifFalse: [ self textArea width: self scrollBounds width ]
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> hLeftoverScrollRange [
	"Return the entire scrolling range minus the currently viewed area."
	^self textArea width  - self scrollBounds width max: 0
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> hScrollbarNeeded [
	"Return whether the horizontal scrollbar is needed."
	self wrapped ifTrue: [  ^ false ].
	^ super hScrollbarNeeded
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> hScrollbarValue: scrollValue [
	self announcer announce: (RubHorizontalScrolled scrollValue: scrollValue).
	self handleScrollerOffsetChange: [ super hScrollbarValue: scrollValue ]
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> hScrollbarValueWithoutAnnouncement: scrollValue [
	self handleScrollerOffsetChange: [ super hScrollbarValue: scrollValue ]
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> handleScrollerOffsetChange: aBlock [
	| prevOffset ret |
	prevOffset := self offset.
	ret := aBlock value.
	(self offset ~= prevOffset and: [ self owner notNil ])
		ifTrue: [ self owner scrollerOffsetChanged ].
	^ ret
]

{ #category : #'text area protocol' }
RubTextScrollPane >> handleWrappingPolicyChange: aBlock [
	aBlock value.
	self wrapped
		ifTrue: [ 
			self fitScrollTargetWidth.
			self updateScrollbars ]
]

{ #category : #accessing }
RubTextScrollPane >> hasKeyboardFocus [
	"Answer whether the receiver has keyboard focus."

	^ super hasKeyboardFocus or: [(self textArea ifNil: [^false]) hasKeyboardFocus]
]

{ #category : #'text area protocol' }
RubTextScrollPane >> hasTextArea [
	^ self scroller submorphs notEmpty
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> hideOrShowScrollBar [ 
	self updateScrollbars
]

{ #category : #initialization }
RubTextScrollPane >> initialize [
	super initialize.
	self scroller extent: self textArea extent.
	self wrapped ifTrue: [ self fitScrollTarget  ].
	drawFocusBorder := true
]

{ #category : #classification }
RubTextScrollPane >> isRenderer [
	^ false
]

{ #category : #'event handling' }
RubTextScrollPane >> mouseDown: anEvent [ 
	scroller hasSubmorphs 
		ifTrue: [ self textArea mouseDown: (anEvent transformedBy: (scroller transformFrom: self)) ].
	self eventHandler
		ifNotNil: [ self eventHandler mouseDown: anEvent fromMorph: self ]
]

{ #category : #'event handling' }
RubTextScrollPane >> mouseMove: anEvent [ 

	scroller hasSubmorphs 
		ifTrue: [ self textArea mouseMove: (anEvent transformedBy: (scroller transformFrom: self)) ].
	self eventHandler
		ifNotNil: [ self eventHandler mouseMove: anEvent fromMorph: self ]
]

{ #category : #accessing }
RubTextScrollPane >> newHScrollbar [
	"Answer a new horizontal scrollbar."

	^RubScrollBar new
		model: self;
		setValueSelector: #hScrollbarValue:
]

{ #category : #accessing }
RubTextScrollPane >> newVScrollbar [
	"Answer a new vertical scrollbar."

	^RubScrollBar new
		model: self;
		setValueSelector: #vScrollbarValue:
]

{ #category : #private }
RubTextScrollPane >> offset [
	^ scroller offset
]

{ #category : #accessing }
RubTextScrollPane >> paragraph [
	^ self textArea paragraph 
]

{ #category : #geometry }
RubTextScrollPane >> position: aPoint [
	"Update the receiver's extent. Hide/show the scrollbars and resize the scroller
	as neccessary."
	| previousBounds |
	previousBounds := self bounds copy.
	previousBounds topLeft = aPoint
		ifTrue: [ ^ self ].
	super position: aPoint
]

{ #category : #initialization }
RubTextScrollPane >> registerTextArea [
	self hasTextArea
		ifTrue: [
			self textArea scrollPane: self.
			self updateScrollbars ]
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> scrollBy: delta [
	self
		handleScrollerOffsetChange: [ 
			| newYoffset newXoffset |
			"Move the contents in the direction delta."
			newYoffset := scroller offset y - delta y max: 0.
			newXoffset := scroller offset x - delta x max: 0.	"Set the offset on the scroller"
			scroller offset: newXoffset @ newYoffset.
			self updateScrollbars ]
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> scrollByKeyboard: event [
	"If event is ctrl+up/down then scroll and answer true"

	| ret sb |
	(event controlKeyPressed or: [ event commandKeyPressed ])
		ifFalse: [ ^ false ].
	sb := event commandKeyPressed
		ifTrue: [ self hScrollbar ]
		ifFalse: [ self vScrollbar ].
	self
		handleScrollerOffsetChange: [ 
			ret := false.
			event key = KeyboardKey up
				ifTrue: [ 
					sb scrollUp: 3.
					ret := true ].
			event key = KeyboardKey down
				ifTrue: [ 
					sb scrollDown: 3.
					ret := true ] ].
	^ ret
]

{ #category : #'text area protocol' }
RubTextScrollPane >> scrollSelectionIntoView [
	"Scroll my text into view if necessary and return true, else return false"
	self scrollSelectionIntoView: nil.

]

{ #category : #'text area protocol' }
RubTextScrollPane >> scrollSelectionIntoView: event [
	"Scroll my text into view if necessary and return true, else return false"

	| selRects delta selRect rectToTest transform cpHere editor bnds |
	editor := self textArea editor.
	selRects := self textArea selectionRects.
	selRects isEmpty
		ifTrue: [ ^ false ].
	rectToTest := selRects first merge: selRects last.
	transform := scroller transformFrom: self.
	(event notNil and: [ event isMouse and: [ event anyButtonPressed ] ])
		ifTrue: [ 
			"Check for autoscroll"
			cpHere := transform localPointToGlobal: event cursorPoint.
			(cpHere y <= self top or: [ cpHere x <= self left ])
				ifTrue: [ rectToTest := selRects first topLeft extent: 2 @ 2 ]
				ifFalse: [ 
					(cpHere y >= self bottom or: [ cpHere x >= self right  ] )
						ifTrue: [ rectToTest := selRects last bottomRight extent: 2 @ 2 ]
						ifFalse: [ ^ false ] ] ].
	selRect := transform localBoundsToGlobal: rectToTest.
	bnds := self scrollBounds insetBy: self textArea margins.
	selRect height > bounds height
		ifTrue: [ 
			editor pointIndex - editor markIndex < 0
				ifTrue: [ self scrollBy: 0 @ (bnds top - selRect top) ]
				ifFalse: [ self scrollBy: 0 @ (bnds bottom - selRect bottom) ].
			^ true ].
	(delta := selRect amountToTranslateWithin: bnds) ~= (0 @ 0)
		ifTrue: [ 
			delta x > 0
				ifTrue: [ 
					scroller offset x - delta x < self scrollBounds width
						ifTrue: [ delta := scroller offset x @ delta y ] ].
			self scrollBy: delta truncated.
			^ true ].
	^ false
]

{ #category : #accessing }
RubTextScrollPane >> scrollTarget: aTextArea [
	self unregisterTextArea.
	super scrollTarget: aTextArea.
	self registerTextArea 
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> scrollToBeginningOfLine [
	self hScrollbarValue: 0;
	updateScrollbars
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> scrollToBeginningOfText [
	self vScrollbarValue: 0;
	updateScrollbars
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> scrollToEndOfLine [
	self hScrollbarValue: 1;
	updateScrollbars
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> scrollToEndOfText [
	self vScrollbarValue: 1;
	updateScrollbars
]

{ #category : #'text area protocol' }
RubTextScrollPane >> scrollWhenMouseMove: anEvent pivotPoint: aPivot [
	| worldTransform viewBounds gap |
	worldTransform := self transformFrom: self world.
	(self scrollSelectionIntoView: anEvent)
		ifTrue: [ ^ self ].
	self textArea selectionRects
		ifNotEmpty: [ :selRects |
			viewBounds := worldTransform localBoundsToGlobal: self bounds.
			(viewBounds containsPoint: anEvent hand position)
				ifFalse: [ 
					gap := selRects last height.
					aPivot y < anEvent hand position y
						ifTrue: [ 
							gap := gap + (anEvent hand position y - viewBounds bottom).
							anEvent setPosition: anEvent position + (0 @ gap) ]
						ifFalse: [ 
							gap := gap + (viewBounds top - anEvent hand position y).
							anEvent setPosition: anEvent position - (0 @ gap) ].
					self textArea mouseMove: anEvent ] ]
]

{ #category : #'event handling' }
RubTextScrollPane >> selectionChanged [
	self owner ifNotNil: [ :o | o selectionChanged ]
]

{ #category : #'text area protocol' }
RubTextScrollPane >> setTextWith: stringOrText [
	"Set the initial text contents with line breaks only as in the text.
	Fit my width and height to the result."
	self textArea width: self scroller width.
	self textArea setTextWith: stringOrText.
	self updateScrollbars 

]

{ #category : #accessing }
RubTextScrollPane >> textArea [
	^ self scrollTarget
]

{ #category : #'event handling' }
RubTextScrollPane >> textAreaExtentChanged [
	self fitScrollTarget.
	self owner ifNotNil: [ :o | o textAreaExtentChanged ]

]

{ #category : #'event handling' }
RubTextScrollPane >> textChanged [

	self owner ifNotNil: [ :o | o textChanged ]
]

{ #category : #structure }
RubTextScrollPane >> topRendererOrSelf [
	^ owner ifNil: [ super topRendererOrSelf ]
]

{ #category : #private }
RubTextScrollPane >> unplug [
	self hasTextArea
		ifTrue: [ self textArea unplug ].
	super unplug
]

{ #category : #initialization }
RubTextScrollPane >> unregisterTextArea [
	self hasTextArea
		ifTrue: [ 
			self textArea scrollPane: nil.
			self textArea announcer unsubscribe: self.
			self textArea unplug ]
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> updateScrollbars [
	super updateScrollbars.
	self wrapped
		ifTrue: [ self fitScrollTargetWidth ]
]

{ #category : #'text area protocol' }
RubTextScrollPane >> updateTextWith: stringOrText [
	"Accept new text contents with line breaks only as in the text.
	Fit my width and height to the result."
	self textArea width: self scroller width.
	self textArea updateTextWith: stringOrText.
	self updateScrollbars 

]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> vScrollbarValue: scrollValue [
	self announcer announce: (RubVerticalScrolled scrollValue: scrollValue).
	self handleScrollerOffsetChange: [ super vScrollbarValue: scrollValue ]
]

{ #category : #'scrollbar managing' }
RubTextScrollPane >> vScrollbarValueWithoutAnnouncement: scrollValue [
	self handleScrollerOffsetChange: [ super vScrollbarValue: scrollValue ]
]

{ #category : #'text area protocol' }
RubTextScrollPane >> wrapped [
	^ self textArea wrapped
]

{ #category : #'text area protocol' }
RubTextScrollPane >> wrapped: aBoolean [
	self handleWrappingPolicyChange: [ self textArea wrapped: aBoolean ]
]
