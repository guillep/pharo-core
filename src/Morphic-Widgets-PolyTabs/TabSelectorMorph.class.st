"
Row of tabs for a TabGroupMorph.
"
Class {
	#name : #TabSelectorMorph,
	#superclass : #ModelMorphic,
	#instVars : [
		'selectedIndex',
		'visibleTabRange',
		'font',
		'tabs',
		'controls',
		'wrapScrolling'
	],
	#category : #'Morphic-Widgets-PolyTabs'
}

{ #category : #operations }
TabSelectorMorph >> activate [
	"Update the non visible tabs too."

	super activate.
	self nonVisibleTabs do: [:t | t activate]
]

{ #category : #adding }
TabSelectorMorph >> addTab: aStringOrMorph [
	"Add a new tab with the given text."
	
	self tabs add: (self newLabelMorph: aStringOrMorph).
	self updateTabs
]

{ #category : #adding }
TabSelectorMorph >> addTab: aStringOrMorph beforeIndex: index [

	self tabs add: (self newLabelMorph: aStringOrMorph) beforeIndex: index.
	selectedIndex >= index ifTrue: [ 
		"there is now new tab before selected tab"
		self selectedIndex: selectedIndex + 1 ]. 
	self updateTabs
]

{ #category : #adding }
TabSelectorMorph >> addTab: aStringOrMorph selected: selectedStringOrMorph [
	"Add a new tab with the given text or morph and alternate for when selected."
	
	self tabs add: (self newLabelMorph: aStringOrMorph selected: selectedStringOrMorph).
	self updateTabs
]

{ #category : #geometry }
TabSelectorMorph >> basicMinExtent [
	"Answer the unadjusted min extent."

	|minTabExtent controlExtent controlsExtent|
	controlsExtent := 0@0.
	self controls do: [:control |
		controlExtent := control minExtent.
		controlsExtent := controlsExtent x + controlExtent x @ (controlsExtent y max: controlExtent y)].
	self tabs ifEmpty: [^controlsExtent].
	minTabExtent := 0@0.
	self tabs do: [:tab | minTabExtent := minTabExtent max: tab minExtent].
	^minTabExtent x + controlsExtent x @ (minTabExtent y max: controlsExtent y)
]

{ #category : #tabs }
TabSelectorMorph >> calculateVisibleTabs [
	"Answer the tabs that should be visible given the space."

	| widths answer availableWidth accumulatedWidth tabStr widthStr width |
	widths := self tabs collect: [ :t | t minExtent x ].
	availableWidth := self layoutBounds width.
	self cornerStyle = #rounded ifTrue: [ availableWidth := availableWidth - 6 ].
	widths sum <= availableWidth ifTrue: [ ^ self tabs ].
	availableWidth := availableWidth - self controlsExtent x.
	answer := OrderedCollection new.
	accumulatedWidth := 0.
	^ self visibleTabRange last = 0
		ifTrue: [ tabStr := (self tabs copyFrom: self visibleTabRange first to: self tabs size) readStream.
			widthStr := (widths copyFrom: self visibleTabRange first to: widths size) readStream.
			[ accumulatedWidth <= availableWidth and: [ tabStr atEnd not ] ]
				whileTrue: [ answer add: tabStr next.
					accumulatedWidth := accumulatedWidth + widthStr next ].
			accumulatedWidth > availableWidth ifTrue: [ answer removeLast ].
			answer ]
		ifFalse: [ tabStr := (self tabs copyFrom: 1 to: (self visibleTabRange last min: self tabs size)) reversed readStream.
			widthStr := (widths copyFrom: 1 to: (self visibleTabRange last min: self tabs size)) reversed readStream.
			[ accumulatedWidth <= availableWidth and: [ tabStr atEnd not ] ]
				whileTrue: [ answer addFirst: tabStr next.
					accumulatedWidth := accumulatedWidth + (width := widthStr next) ].
			accumulatedWidth > availableWidth
				ifTrue: [ answer removeFirst.
					accumulatedWidth := accumulatedWidth - width ].
			tabStr := (self tabs copyFrom: self visibleTabRange last + 1 to: self tabs size) readStream.
			widthStr := (widths copyFrom: self visibleTabRange last + 1 to: widths size) readStream.
			[ accumulatedWidth <= availableWidth and: [ tabStr atEnd not ] ]
				whileTrue: [ answer add: tabStr next.
					accumulatedWidth := accumulatedWidth + widthStr next ].
			accumulatedWidth > availableWidth ifTrue: [ answer removeLast ].
			answer ]
]

{ #category : #operations }
TabSelectorMorph >> controlButtonWidth [
	"Answer the width for a scroll button."

	^self theme scrollbarThickness + (3 * self displayScaleFactor)
]

{ #category : #accessing }
TabSelectorMorph >> controls [

	^ controls
]

{ #category : #accessing }
TabSelectorMorph >> controls: anObject [

	controls := anObject
]

{ #category : #operations }
TabSelectorMorph >> controlsExtent [
	"Answer the min extent of the controls."

	^self controls first minExtent + (self controls last minExtent x @ 0)
]

{ #category : #rounding }
TabSelectorMorph >> cornerStyle: aSymbol [
	"Pass to tabs also."

	super cornerStyle: aSymbol.
	self tabs do: [:t | t cornerStyle: aSymbol]
]

{ #category : #drawing }
TabSelectorMorph >> drawSubmorphsOn: aCanvas [ 
	"Display submorphs back to front.
	Draw the focus here since we are using inset bounds
	for the focus rectangle."

	|tab|
	super drawSubmorphsOn: aCanvas.
	(self hasKeyboardFocus and: [(tab := self selectedTab) notNil
			and: [tab owner notNil]])
		ifTrue: [self clipSubmorphs 
				ifTrue: [aCanvas
							clipBy: (aCanvas clipRect intersect: self clippingBounds ifNone:["done here" ^ self ])
							during: [:c | tab drawKeyboardFocusOn: c]]
				ifFalse: [tab drawKeyboardFocusOn: aCanvas]]
]

{ #category : #operations }
TabSelectorMorph >> ensureSelectedTabIsVisible [
	"Update the tabs if the seleted tab is not in the visible range."

	(self selectedIndex > 0 and: [(self visibleTabRange includes: self selectedIndex) not])
		ifTrue: [self visibleTabRange: (self selectedIndex to: 0).
				self updateTabs]
]

{ #category : #geometry }
TabSelectorMorph >> extent: aPoint [
	"Set the extent of the receiver.
	Update the tabs."

	self extent = aPoint ifTrue: [^self].
	super extent: aPoint.
	self
		updateTabs;
		ensureSelectedTabIsVisible
]

{ #category : #accessing }
TabSelectorMorph >> focusBounds [
	"Answer the bounds for drawing the focus indication."

	^self selectedTab
		ifNil: [super focusBounds]
		ifNotNil: [:tab | tab focusBounds]
]

{ #category : #accessing }
TabSelectorMorph >> font [
	"Answer the label font"

	^font
]

{ #category : #accessing }
TabSelectorMorph >> font: aFont [
	"Set the label font"

	font == aFont ifTrue: [^self].
	font := aFont.
	self updateFont
]

{ #category : #'event handling' }
TabSelectorMorph >> handlesKeyboard: evt [
	"Yes, we do it here."
	
	^true
]

{ #category : #initialization }
TabSelectorMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	selectedIndex := 0.
	self
		tabs: OrderedCollection new;
		wrapScrolling: false;
		visibleTabRange: (1 to: 0);
		controls: self newControls;
		roundedCorners: #(1 4);
		borderWidth: 0;
		changeTableLayout;
		listDirection: #leftToRight;
		cellInset: (self theme tabSelectorCellInsetFor: self)
]

{ #category : #keymapping }
TabSelectorMorph >> initializeShortcuts: aKMDispatcher [
	super initializeShortcuts: aKMDispatcher.
	aKMDispatcher attachCategory: #MorphFocusNavigation.
	aKMDispatcher attachCategory: #TabMorphsNavigation.
]

{ #category : #'event handling' }
TabSelectorMorph >> keyDown: event [ 
	"Process keys navigation and space to toggle."

	(self navigationKey: event) ifTrue: [^self].
	event keyCharacter = Character arrowLeft
		ifTrue: [self selectPreviousTab].
	event keyCharacter = Character arrowRight
		ifTrue: [self selectNextTab]
]

{ #category : #'event handling' }
TabSelectorMorph >> keyboardFocusChange: aBoolean [
	"The message is sent to a morph when its keyboard focus changes.
	Update for focus feedback."
	super keyboardFocusChange: aBoolean.
	self focusChanged
]

{ #category : #operations }
TabSelectorMorph >> leftButtonEnabled [
	"Answer whether the button for scrolling left should be enabled."

	^self wrapScrolling or: [self visibleTabRange first > 1]
]

{ #category : #operations }
TabSelectorMorph >> leftButtonLabel [
	"Answer the label for a button for scrolling left."

	^AlphaImageMorph new image: (
		ScrollBarMorph
			arrowOfDirection: #left
			size: self controlButtonWidth - (3* self displayScaleFactor)
			color: self paneColor darker)
]

{ #category : #geometry }
TabSelectorMorph >> minExtent [
	"Add a bit for the round corner of the group."

	^self theme tabSelectorMorphMinExtentFor: self
]

{ #category : #operations }
TabSelectorMorph >> newControls [
	"Answer the scrolling controls."
	
	^{self newLeftButton. self newRightButton}
]

{ #category : #operations }
TabSelectorMorph >> newEndSpacer [
	"Answer a spacer to pad when rounded."

	^Morph new
		borderWidth: 0;
		color: Color transparent;
		extent: 6@0
]

{ #category : #operations }
TabSelectorMorph >> newLabelMorph: aStringOrMorph [
	"Answer a new label morph with the given label text."

	^TabLabelMorph new
		roundedCorners: #(1 4);
		cornerStyle: self cornerStyle;
		changeTableLayout;
		listDirection: #leftToRight;
		listCentering: #center;
		layoutInset: (self theme tabLabelInsetFor: self);
		hResizing: #shrinkWrap;
		vResizing: #spaceFill;
		label: aStringOrMorph;
		font: self font;
		on: #mouseDown send: #tabClicked:with: to: self;
		tabSelector: self
]

{ #category : #operations }
TabSelectorMorph >> newLabelMorph: aStringOrMorph selected: selectedStringOrMorph [
	"Answer a new label morph with the given label text or morph and
	alternate when selected."

	^TabLabelMorph new
		roundedCorners: #(1 4);
		cornerStyle: self cornerStyle;
		changeTableLayout;
		listDirection: #leftToRight;
		listCentering: #center;
		layoutInset: (self theme tabLabelInsetFor: self);
		hResizing: #shrinkWrap;
		vResizing: #spaceFill;
		label: aStringOrMorph selected: selectedStringOrMorph;
		font: self font;
		on: #mouseDown send: #tabClicked:with: to: self;
		tabSelector: self
]

{ #category : #operations }
TabSelectorMorph >> newLeftButton [
	"Answer a new button for scrolling left."

	^(ControlButtonMorph
			on: self
			getState: nil
			action: #scrollTabsLeft
			label: #leftButtonLabel)
		getEnabledSelector: #leftButtonEnabled;
		hResizing: #rigid;
		vResizing: #spaceFill;
		cornerStyle: #square;
		extent: self controlButtonWidth asPoint
]

{ #category : #operations }
TabSelectorMorph >> newRightButton [
	"Answer a new button for scrolling right."

	^(ControlButtonMorph
			on: self
			getState: nil
			action: #scrollTabsRight
			label: #rightButtonLabel)
		getEnabledSelector: #rightButtonEnabled;
		hResizing: #rigid;
		vResizing: #spaceFill;
		cornerStyle: #square;
		extent: self controlButtonWidth asPoint
]

{ #category : #operations }
TabSelectorMorph >> newSpacer [
	"Answer a spacer to place the controls to the right."

	^Morph new
		borderWidth: 0;
		color: Color transparent;
		extent: 0@0;
		minWidth: 0;
		hResizing: #spaceFill
]

{ #category : #tabs }
TabSelectorMorph >> nonVisibleTabs [
	"Answer the tabs that are not currently visible."

	^self tabs select: [:t | t owner isNil]
]

{ #category : #operations }
TabSelectorMorph >> passivate [
	"Update the non visible tabs too."

	super passivate.
	self nonVisibleTabs do: [:t | t passivate]
]

{ #category : #tabs }
TabSelectorMorph >> relabelTab: aTab with: aStringOrMorph [
	"Relabel the tab update tab layout."

	aTab label: aStringOrMorph.
	aTab owner ifNotNil: [
		self updateTabs.
		(aTab isSelected and: [aTab isVisible not])
			ifTrue: [self ensureSelectedTabIsVisible]]
]

{ #category : #operations }
TabSelectorMorph >> removeTabIndex: anInteger [
	"Remove the tab at the given index and
	adjust any selected (next or first if was last)."
	
	self tabs removeAt: anInteger.
	self selectedIndex: 0.
	self tabs ifNotEmpty: [
		self selectedIndex: self selectedIndex - 1 \\ self tabs size + 1]
		
]

{ #category : #operations }
TabSelectorMorph >> rightButtonEnabled [
	"Answer whether the button for scrolling right should be enabled."

	^self wrapScrolling or: [self visibleTabRange last < self tabs size]
]

{ #category : #operations }
TabSelectorMorph >> rightButtonLabel [
	"Answer the label for a button for scrolling right."

	^AlphaImageMorph new image: (
		ScrollBarMorph
			arrowOfDirection: #right
			size: self controlButtonWidth - (3 * self displayScaleFactor)
			color: self paneColor darker)
]

{ #category : #operations }
TabSelectorMorph >> scrollTabsLeft [
	"Scroll left through the tabs."
	
	self visibleTabRange: (self visibleTabRange first < 2
		ifTrue: [0 to: self tabs size]
		ifFalse: [0 to: self visibleTabRange first - 1]).
	self updateTabs
]

{ #category : #operations }
TabSelectorMorph >> scrollTabsRight [
	"Scroll right through the tabs."
	
	self visibleTabRange: (self visibleTabRange last \\ self tabs size + 1 to: 0).
	self updateTabs
]

{ #category : #operations }
TabSelectorMorph >> selectNextTab [
	"Select the next tab, or the first if none selected."
	
	self selectedIndex: self selectedIndex \\ self tabs size + 1
]

{ #category : #tabs }
TabSelectorMorph >> selectPreviousTab [
	"Select the previous tab, or the last if none selected."
	
	self selectedIndex: (self selectedIndex < 2
		ifTrue: [self tabs size]
		ifFalse: [self selectedIndex - 1])
]

{ #category : #accessing }
TabSelectorMorph >> selectedIndex [
	"Answer the value of selectedIndex"

	^ selectedIndex
]

{ #category : #accessing }
TabSelectorMorph >> selectedIndex: index [
	"Set the value of selectedIndex"

	|oldIndex|
	selectedIndex == index ifTrue: [^self].
	oldIndex := selectedIndex.
	selectedIndex := (index min: self tabs size).
	self visibleTabRange first > index
		ifTrue: [self visibleTabRange: ((index max: 1) to: 0)]
		ifFalse: [self visibleTabRange last < index
				ifTrue: [self visibleTabRange: (0 to: index)]].
	self updateTabs.
	self changed: #selectedIndex with: oldIndex
]

{ #category : #tabs }
TabSelectorMorph >> selectedTab [
	"Answer the selected tab."
	
	^self selectedIndex = 0
		ifFalse: [self tabs at: self selectedIndex ifAbsent: [nil]]
]

{ #category : #operations }
TabSelectorMorph >> tabClicked: evt with: aMorph [ 
	"A tab has been clicked."
	
	self selectedIndex: (self tabs indexOf: aMorph)
]

{ #category : #accessing }
TabSelectorMorph >> tabs [

	^ tabs
]

{ #category : #accessing }
TabSelectorMorph >> tabs: anObject [

	tabs := anObject
]

{ #category : #tabs }
TabSelectorMorph >> tabsAndControls [
	"Answer the tabs and scrolling controls that should be visible given the space."

	|visibleTabs firstIndex|
	self tabs ifEmpty: [
		self visibleTabRange: (1 to: 0).
		^#()].
	visibleTabs := self calculateVisibleTabs.
	visibleTabs ifEmpty: [
		self visibleTabRange: (1 to: 0).
		^#()].
	firstIndex := self tabs indexOf: visibleTabs first.
	self visibleTabRange: (firstIndex to: firstIndex + visibleTabs size - 1).
	visibleTabs size = self tabs size ifFalse: [
		visibleTabs
			add: self newSpacer;
			addAll: self controls.
		self cornerStyle = #rounded
			ifTrue: [visibleTabs add: self newEndSpacer]].
	^visibleTabs
]

{ #category : #operations }
TabSelectorMorph >> takesKeyboardFocus [
	"Answer whether the receiver can normally take keyboard focus."

	^true
]

{ #category : #operations }
TabSelectorMorph >> updateFont [
	"Update the label font."

	self tabs do: [:t | t font: self font].
	self updateTabs
]

{ #category : #tabs }
TabSelectorMorph >> updateTabs [
	"Update the submorphs based on visible tabs."

	|tabsAndControls selectedTab|
	tabsAndControls := self tabsAndControls.
	self removeAllMorphs.
	tabsAndControls ifEmpty: [^self].
	selectedTab := self selectedTab.
	self tabs do: [:t |
		t selected: (t == selectedTab)].
	self
		addAllMorphs: self tabsAndControls;
		adoptPaneColor
]

{ #category : #accessing }
TabSelectorMorph >> visibleTabRange [

	^ visibleTabRange
]

{ #category : #accessing }
TabSelectorMorph >> visibleTabRange: anInterval [
	"Record the range of tabs that are visible.
	Also used when scrolling to determine starting index."
	
	visibleTabRange := anInterval.
	self
		changed: #leftButtonEnabled;
		changed: #rightButtonEnabled
]

{ #category : #tabs }
TabSelectorMorph >> visibleTabs [
	"Answer the tabs that are currently visible."

	^self tabs select: [:t | t owner notNil]
]

{ #category : #accessing }
TabSelectorMorph >> wrapScrolling [

	^ wrapScrolling
]

{ #category : #accessing }
TabSelectorMorph >> wrapScrolling: aBoolean [
	"Set whether tab scrolling wraps around at each end."

	wrapScrolling := aBoolean.
	self
		changed: #leftButtonEnabled;
		changed: #rightButtonEnabled
]
