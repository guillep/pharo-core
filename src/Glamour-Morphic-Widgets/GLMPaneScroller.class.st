Class {
	#name : #GLMPaneScroller,
	#superclass : #BorderedMorph,
	#instVars : [
		'sizing',
		'transform',
		'scrollBar',
		'paneCount',
		'maxPanes'
	],
	#category : #'Glamour-Morphic-Widgets'
}

{ #category : #layout }
GLMPaneScroller >> adjustPaneHeight [
	"This gets called after the scrollbar has been shown or hidden, to move the bottom
	of the panes to the right place."
	
	transform bounds: self innerBounds.
	transform submorphsDo: [:m | m bounds: (m bounds withHeight: self paneHeight)]
]

{ #category : #scrolling }
GLMPaneScroller >> adoptPaneColor: aColor [
	super adoptPaneColor: aColor.
	scrollBar adoptPaneColor: aColor
]

{ #category : #private }
GLMPaneScroller >> basicUpdateSizing [
	sizing := (self paneCount min: self maxPanes) max: 1
]

{ #category : #layout }
GLMPaneScroller >> bounds: aRectangle [
	super bounds: aRectangle.
	self layoutWidgets.
	self layoutPanes.
	self setScrollDeltas.

]

{ #category : #layout }
GLMPaneScroller >> computeMorphWidths [
	| paneWidths widths |
	paneWidths := self paneWidthsToFit: self totalPaneWidth.
	widths := OrderedCollection new.
	paneWidths do: [:w | widths add: w] separatedBy: [widths add: self separatorWidth].
	^ widths asArray

]

{ #category : #scrolling }
GLMPaneScroller >> hideOrShowScrollBar [
	self isScrollable ifTrue: [self showScrollBar] ifFalse: [self hideScrollBar]
]

{ #category : #scrolling }
GLMPaneScroller >> hideScrollBar [
	self removeMorph: scrollBar.
	self adjustPaneHeight.
]

{ #category : #initialization }
GLMPaneScroller >> initialize [
	super initialize.
	self 
		color: Color transparent;
		borderWidth: 0;
		vResizing: #spaceFill;
		hResizing: #spaceFill.
	self 
		initializeTransform;
		initializeScrollbar.
	paneCount := 0.
	maxPanes := 2.
]

{ #category : #initialization }
GLMPaneScroller >> initializeScrollbar [
	scrollBar := ScrollBarMorph new 
		model: self;
		setValueSelector: #scrollBarValue:;
		yourself.
	scrollBar 
		borderWidth: 0;
		borderColor: #inset;
		height: self scrollBarHeight.
	self resizeScrollBar.

]

{ #category : #initialization }
GLMPaneScroller >> initializeTransform [
	transform := TransformMorph new.
	transform
		color: Color transparent;
		borderWidth: 0;
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		disableTableLayout;
		bounds: super innerBounds.
	self addMorphBack: transform.

]

{ #category : #layout }
GLMPaneScroller >> innerBounds [
	| rect |
	rect := super innerBounds.
	^ self scrollBarIsVisible
		ifTrue: [rect withHeight: rect height - self scrollBarHeight - 1]
		ifFalse: [rect]
]

{ #category : #scrolling }
GLMPaneScroller >> isScrollable [
	^ self leftoverScrollRange > 0
]

{ #category : #layout }
GLMPaneScroller >> layoutPanes [
	| widths rect |
	widths := self computeMorphWidths.
	rect := 0@0 extent: (0 @ self paneHeight).
	transform submorphs 
					with: widths 
					do: [:m :w | 
						rect := rect withWidth: w.
						m bounds: rect.
						rect := rect translateBy: (w@0)]
						

]

{ #category : #layout }
GLMPaneScroller >> layoutWidgets [
	| inner outer |
	outer := super innerBounds.
	inner := self innerBounds.
	transform bounds: inner.
	scrollBar bounds: ((inner left @ inner bottom)
						corner: outer bottomRight)
]

{ #category : #scrolling }
GLMPaneScroller >> leftoverScrollRange [
	^ (self totalScrollRange - self innerBounds width roundTo: self scrollDeltaWidth) max: 0

]

{ #category : #configuration }
GLMPaneScroller >> maxPanes [
	^ maxPanes
]

{ #category : #configuration }
GLMPaneScroller >> maxPanes: anInteger [
	maxPanes := anInteger
]

{ #category : #layout }
GLMPaneScroller >> paneCount [
	^ paneCount
]

{ #category : #layout }
GLMPaneScroller >> paneHeight [
	^ transform bounds height
]

{ #category : #layout }
GLMPaneScroller >> paneWidthsToFit: limit [
	| padded |
	padded := Array new: self paneCount.
	padded atAllPut: (limit / self sizing) floor.
	(1 to: limit - padded sum) do: [:i | padded at: i put: (padded at: i) + 1].
	^ padded
	
	
]

{ #category : #panes }
GLMPaneScroller >> popAndReplacePane: aMorph [	
	transform removeMorph: transform lastSubmorph. "one for the separator"
	transform submorphs isEmpty
		ifFalse: [ transform removeMorph: transform lastSubmorph ].
	paneCount := paneCount - 1.	
	
	aMorph 
		borderWidth: 0;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		layoutInset: 0.
	transform hasSubmorphs 
		ifTrue: [ transform addMorphBack: self separator ].
	transform addMorphBack: (aMorph adoptPaneColor: self paneColor).
	paneCount := paneCount + 1.
	self updatePanes
]

{ #category : #panes }
GLMPaneScroller >> popPane [
	transform removeMorph: transform lastSubmorph. "one for the separator"
	transform submorphs isEmpty
		ifFalse: [ transform removeMorph: transform lastSubmorph ].
	paneCount := paneCount - 1.
	self updatePanes.
]

{ #category : #panes }
GLMPaneScroller >> pushPane: aMorph [	
	aMorph 
		borderWidth: 0;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		layoutInset: 0.
	transform hasSubmorphs 
		ifTrue: [ transform addMorphBack: self separator ].
	transform addMorphBack: (aMorph adoptPaneColor: self paneColor).
	paneCount := paneCount + 1.
	self updatePanes
]

{ #category : #layout }
GLMPaneScroller >> resizeScrollBar [
	| inner outer |
	outer := super innerBounds.
	inner := outer withHeight: outer height - self scrollBarHeight.
	scrollBar bounds: ((inner left @ inner bottom) corner: outer bottomRight)
]

{ #category : #layout }
GLMPaneScroller >> scrollBarHeight [
	^ self theme scrollbarThickness
]

{ #category : #scrolling }
GLMPaneScroller >> scrollBarIsVisible [
	^ submorphs includes: scrollBar
]

{ #category : #'input events' }
GLMPaneScroller >> scrollBarMenuButtonPressed: anObject [
]

{ #category : #updating }
GLMPaneScroller >> scrollBarValue: value [
	transform hasSubmorphs ifFalse: [^ self].
	transform offset: (self leftoverScrollRange * value) rounded @ 0.
]

{ #category : #scrolling }
GLMPaneScroller >> scrollDeltaWidth [
	^ 1
]

{ #category : #scrolling }
GLMPaneScroller >> scrollToRight [
"	(transform submorphs size + 1) / 2 > paneCount ifTrue: [ 
"		scrollBar glmAnimateValue: 1.0 duration: 200 "]"
]

{ #category : #panes }
GLMPaneScroller >> separator [
	^ "BorderedSubpaneDividerMorph new 
		vertical;
		adoptPaneColor: self paneColor;
		yourself"
		
	GLMMorphic emptyMorph
]

{ #category : #layout }
GLMPaneScroller >> separatorWidth [
	^ 20
]

{ #category : #scrolling }
GLMPaneScroller >> setScrollDeltas [
	| range interval value |
	transform hasSubmorphs ifFalse: [scrollBar interval: 1.0. ^ self].
	range := self leftoverScrollRange.
	range = 0 ifTrue: [^ scrollBar interval: 1.0; setValue: 0].
	interval := ((self innerBounds width) / self totalScrollRange) asFloat.
	value := (transform offset x / range min: 1.0) asFloat.
	scrollBar interval: interval.
	scrollBar setValue: value.
]

{ #category : #scrolling }
GLMPaneScroller >> showScrollBar [
	self scrollBarIsVisible ifTrue: [^ self].
	self resizeScrollBar.
	self addMorphFront: scrollBar.
	self adjustPaneHeight.
	
]

{ #category : #accessing }
GLMPaneScroller >> sizing [
	^ sizing ifNil: [self updateSizing]
]

{ #category : #layout }
GLMPaneScroller >> totalPaneWidth [
	^ self innerBounds width - ((self sizing - 1) * self separatorWidth)
]

{ #category : #scrolling }
GLMPaneScroller >> totalScrollRange [
	| submorphBounds |
	submorphBounds := transform localSubmorphBounds ifNil: [^ 0].
	^ submorphBounds width

]

{ #category : #updating }
GLMPaneScroller >> updatePanes [
	self basicUpdateSizing.
	self layoutPanes.
	self hideOrShowScrollBar.
	self setScrollDeltas.
	self scrollToRight
]

{ #category : #updating }
GLMPaneScroller >> updateSizing [
	| old |
	old := sizing.
	self basicUpdateSizing.
	sizing = old ifFalse: [self layoutPanes].
	^sizing
]
