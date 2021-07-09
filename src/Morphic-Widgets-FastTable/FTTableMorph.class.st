"
I'm an implementation of a table, in a not-naive way. 

I assume I can have many rows, then I do not try to show all of them at once. Instead, I keep a datasource and I demand rows when needed (datasource implements a flyweight to fill the visible rows).

I should not be subclasse. An extension of FastTable should happen on a data source an not here. Extend me ONLY if it is impossible to do what you want on the data source.

Examples: 
-------------
FTTableMorph new
	extent: 200@400;
	dataSource: (FTSimpleDataSource elements: (1 to: 10000));
	openInWindow
	
You can check better examples in FTExamples

A FastTable have the possibility to be searchable, this is activate by default. 
You can disable this with the method #disableSearch.
But you also have the possibility to make your FastTable filterable with the method #enableFilter. But search and filter cannot be use in the same time.

I manage different kind of selections through a strategy design pattern. For example I have a strategy to manage simple or multiple selection and I have a strategy to manage cell or row selection.

Horizontal scrolling being a new feature is not enabled by default. Use #newWithHorizontalScrollBar or set horizontalScrollBar var to anything at early initialization stage (before #initializeScrollBars where it is being checked)



"
Class {
	#name : #FTTableMorph,
	#superclass : #Morph,
	#instVars : [
		'container',
		'verticalScrollBar',
		'horizontalScrollBar',
		'selectionColor',
		'selectedIndexes',
		'highlightedIndexes',
		'showIndex',
		'dataSource',
		'intercellSpacing',
		'rowHeight',
		'selectionStrategy',
		'columns',
		'secondarySelectionColor',
		'headerColor',
		'showColumnHeaders',
		'allowsDeselection',
		'needToggleAtMouseUp',
		'function',
		'resizable',
		'selectionModeStrategy'
	],
	#category : #'Morphic-Widgets-FastTable-Base'
}

{ #category : #accessing }
FTTableMorph class >> defaultAllowsDeselection [
	^ false
]

{ #category : #accessing }
FTTableMorph class >> defaultBackgroundColor [
	^ self theme listBackgroundColor
]

{ #category : #accessing }
FTTableMorph class >> defaultColumn [	
	^ FTColumn new
]

{ #category : #accessing }
FTTableMorph class >> defaultHeaderColor [
	self flag: #pharoFixMe.	"I think we should deprecate all this headerColor stuff. This is 
	responsibility of data source, after all.
	
	Cyril: I added a deprecation on #headerColor: explaining how to update the users of this method. In Pharo 9 we can remove all this."
	^ self theme fastTableHeaderColor
]

{ #category : #accessing }
FTTableMorph class >> defaultIntercellSpacing [
	^ 0@0
]

{ #category : #accessing }
FTTableMorph class >> defaultRowHeight [
	^ StandardFonts defaultFont pixelSize + 7
]

{ #category : #accessing }
FTTableMorph class >> defaultSecondarySelectionColor [
	^ self theme secondarySelectionColor
]

{ #category : #accessing }
FTTableMorph class >> defaultSelectionColor [
	^ self theme selectionColor
]

{ #category : #temporary }
FTTableMorph class >> newWithHorizontalScrollBar [
	"This method is temporary to introduce horisontal scrolling gradually"
	"See GTExamples class >> exampleTableHorizontalScroll"
	^self basicNew initializeWithHorizontalScrollBar
]

{ #category : #'drag and drop' }
FTTableMorph >> acceptDroppingMorph: aMorph event: event [
	self dataSource dropElements: aMorph passenger index: ((self container rowIndexContainingPoint: event position) ifNil: [ 0 ]).
	self basicHighlightIndexes: #().
	self refresh
]

{ #category : #accessing }
FTTableMorph >> addColumn: aColumn [
	columns := columns copyWith: aColumn
]

{ #category : #accessing }
FTTableMorph >> allowDeselection [
	self allowsDeselection: true
]

{ #category : #testing }
FTTableMorph >> allowsDeselection [
	^ allowsDeselection ifNil: [ self class defaultAllowsDeselection ]
]

{ #category : #accessing }
FTTableMorph >> allowsDeselection: aBoolean [
	allowsDeselection := aBoolean
]

{ #category : #private }
FTTableMorph >> announceScrollChangedFrom: oldIndex to: newIndex [
	"If the index did not change, do nothing"
	oldIndex = newIndex ifTrue: [ ^ self ].
	self
		doAnnounce:
			((FTScrollingChanged from: oldIndex to: newIndex)
				fastTable: self;
				yourself)
]

{ #category : #updating }
FTTableMorph >> autoScrollHeightLimit [

	^20
]

{ #category : #private }
FTTableMorph >> basicHighlightIndexes: anArray [
	highlightedIndexes := anArray asArray
]

{ #category : #private }
FTTableMorph >> basicHighlightRowIndexes: anArray [
	self deprecated: 'Use #basicHighlightIndexes: instead' transformWith: '`@receiver basicHighlightRowIndexes: `@statements' -> '`@receiver basicHighlightIndexes: `@statements'.
	^ self basicHighlightIndexes: anArray
]

{ #category : #private }
FTTableMorph >> basicMoveShowIndexTo: aNumber [

	showIndex := aNumber
]

{ #category : #private }
FTTableMorph >> basicSelectIndexes: anArray [
	selectedIndexes := anArray asArray
]

{ #category : #private }
FTTableMorph >> basicSelectRowIndexes: anArray [
	self deprecated: 'Use #basicSelectIndexes: instead' transformWith: '`@receiver basicSelectRowIndexes: `@statements' -> '`@receiver basicSelectIndexes: `@statements'.
	self basicSelectIndexes: anArray
]

{ #category : #accessing }
FTTableMorph >> beCellSelection [
	self selectionModeStrategy: (FTCellSelectionModeStrategy table: self)
]

{ #category : #accessing }
FTTableMorph >> beMultipleSelection [
	selectionStrategy := FTMultipleSelectionStrategy table: self
]

{ #category : #accessing }
FTTableMorph >> beNotResizable [
	resizable := false
]

{ #category : #accessing }
FTTableMorph >> beResizable [
	resizable := true
]

{ #category : #accessing }
FTTableMorph >> beRowNotHomogeneous [
	"by default, tables have homogeneous row heigths, taken from rowHeight variable. 
	 We can switch to variable size by sending this message. 
	 The resulting table will be less effcicient than the first, but probably not in a way users 
	 can notice"
	| oldContainer |

	oldContainer := container.
	container := FTTableContainerRowNotHomogeneousMorph new.
	self replaceSubmorph: oldContainer by: container.
	self resizeAllSubviews
]

{ #category : #accessing }
FTTableMorph >> beRowSelection [
	self selectionModeStrategy: (FTRowSelectionModeStrategy table: self)
]

{ #category : #accessing }
FTTableMorph >> beSingleSelection [
	selectionStrategy := FTSimpleSelectionStrategy table: self
]

{ #category : #'event handling' }
FTTableMorph >> click: event [
	"check for right click (menu)"

	(self isYellowButtonReallyPressed: event)
		ifTrue: [ self showMenuForPosition: event cursorPoint ]
]

{ #category : #'accessing - colors' }
FTTableMorph >> colorForSelection: primarySelection [
	
	^primarySelection 
		ifTrue: [ self selectionColor ]
		ifFalse: [ self secondarySelectionColor ]
]

{ #category : #accessing }
FTTableMorph >> columns [
	^ columns
]

{ #category : #accessing }
FTTableMorph >> columns: aCollection [ 
	columns := aCollection asArray
]

{ #category : #private }
FTTableMorph >> container [ 
	^ container
]

{ #category : #accessing }
FTTableMorph >> dataSource [
	"Answers a dataSource: the component responsible of providing data to the table. 
	 Check FTDataSource and subclasses as reference."
	^ dataSource
]

{ #category : #accessing }
FTTableMorph >> dataSource: anObject [
	dataSource := anObject.
	dataSource table: self.
	dataSource readyToBeDisplayed.
	self resetPosition.
	self refresh
]

{ #category : #initialization }
FTTableMorph >> defaultColor [

	^self class defaultBackgroundColor
]

{ #category : #accessing }
FTTableMorph >> defaultContainer [
	^ FTTableContainerMorph new
]

{ #category : #accessing }
FTTableMorph >> denyDeselection [
	self allowsDeselection: false
]

{ #category : #'accessing - selection' }
FTTableMorph >> deselectAll [ 
	self selectIndexes: #()
]

{ #category : #accessing }
FTTableMorph >> disableFunction [
	"Disabling it just sets the funtion to nil, so I can safely skip it in #keyStrokeSearch:"

	function isExplicit
		ifTrue: [ function disable.
			self resizeAllSubviews	"This is call because now the container will take all the available space." ].
	function := FTNilFunction table: self
]

{ #category : #'event handling' }
FTTableMorph >> doubleClick: event [
	(self selectionModeStrategy selectableIndexContainingPoint: event cursorPoint) ifNotNil: [ :index | self doAnnounce: (FTStrongSelectionChanged index: index event: event) ]
]

{ #category : #drawing }
FTTableMorph >> drawSubmorphsOn: aCanvas [ 
	"Draw the focus here since we are using inset bounds
	for the focus rectangle."
	"1haltOnce."
	super drawSubmorphsOn: aCanvas.
	self hasKeyboardFocus ifTrue: [ self drawKeyboardFocusOn: aCanvas ]

]

{ #category : #accessing }
FTTableMorph >> enableFilter [
	"Enables filtering. Not compatible with the search."

	function := FTFilterFunction table: self
]

{ #category : #accessing }
FTTableMorph >> enableFilter: aFTFilterClass [
	"Enables filtering. Not compatible with the search."

	self enableFilter.
	function filterClass: aFTFilterClass
]

{ #category : #accessing }
FTTableMorph >> enableFilterWithAction: aBlock [
	"Enables filtering and add an Action button. Not compatible with the search."

	self enableFilterWithAction: aBlock named: 'Validate.'
]

{ #category : #accessing }
FTTableMorph >> enableFilterWithAction: aBlock named: aString [
	"Enables filtering and add an Action button. Not compatible with the search. If I am use, the function must be explicit."

	function := FTWithActionFilterFunction table: self action: aBlock named: aString.
	self explicitFunction
]

{ #category : #accessing }
FTTableMorph >> enableSearch [
	"Enables search (this is the default option). Not compatible with the filter function.	"

	function := FTSearchFunction table: self
]

{ #category : #private }
FTTableMorph >> ensureAtLeastOneColumn [
	self columns ifNotEmpty: [ ^ self ].
	self addColumn: self class defaultColumn
]

{ #category : #private }
FTTableMorph >> ensureVisibleFirstSelection [
	| rowIndex |
	(self hasSelection not or: [ self container isRowIndexFullyVisible: (rowIndex := self selectionModeStrategy selectedRowIndex) ]) ifTrue: [ ^ self ].

	rowIndex < self showIndex
		ifTrue: [ self moveShowIndexTo: self selectedIndex ]
		ifFalse: [ self moveShowIndexTo: (self selectionModeStrategy indexForRow: rowIndex - self container calculateMinVisibleRows + 1) ]
]

{ #category : #accessing }
FTTableMorph >> explicitFunction [
	function showWidget
]

{ #category : #geometry }
FTTableMorph >> extent: aPoint [
	super extent: aPoint.
	container extent: aPoint.
	self resizeAllSubviews
]

{ #category : #accessing }
FTTableMorph >> firstVisibleRowIndex [
	
	^ self container firstVisibleRowIndex
]

{ #category : #'event handling' }
FTTableMorph >> handleMouseMove: anEvent [
	"Reimplemented because we really want #mouseMove when a morph is dragged around"
	anEvent wasHandled ifTrue:[^self]. "not interested"
	(anEvent anyButtonPressed) ifFalse:[^self].
	anEvent wasHandled: true.
	self mouseMove: anEvent

]

{ #category : #'event testing' }
FTTableMorph >> handlesKeyboard: event [
	^ true
]

{ #category : #'event testing' }
FTTableMorph >> handlesMouseDown: event [
	^ true

]

{ #category : #'event testing' }
FTTableMorph >> handlesMouseOverDragging: event [
	"Yes, for mouse down highlight."
	^true
]

{ #category : #'event testing' }
FTTableMorph >> handlesMouseWheel: event [
	^self isVerticalScrollBarVisible and: [ self hasDataSource ]
]

{ #category : #testing }
FTTableMorph >> hasDataSource [
	^ self dataSource notNil
]

{ #category : #testing }
FTTableMorph >> hasHighlighted [
	^ self highlightedIndexes notEmpty
]

{ #category : #testing }
FTTableMorph >> hasSelection [
	^ self selectedIndexes isNotEmpty
]

{ #category : #'accessing - colors' }
FTTableMorph >> headerColor [
	^ headerColor ifNil: [ self class defaultHeaderColor ]
]

{ #category : #accessing }
FTTableMorph >> hideColumnHeaders [
	showColumnHeaders ifFalse: [ ^ self ].
	showColumnHeaders := false.
	self refresh
]

{ #category : #'accessing - selection' }
FTTableMorph >> highlightIndex: aNumber [
	self highlightIndexes: { aNumber }
]

{ #category : #'accessing - selection' }
FTTableMorph >> highlightIndexes: anArray [
	anArray = self highlightedIndexes ifTrue: [ ^ self ].

	self basicHighlightIndexes: anArray.

	(self hasHighlighted and: [ (self isIndexVisible: self highlightedIndex) not ])
		ifTrue: [ self moveShowIndexTo: self highlightedIndexes first.
			^ self ].

	(self hasSelection and: [ (self isIndexVisible: self selectedIndex) not ])
		ifTrue: [ self moveShowIndexTo: self selectedIndex.
			^ self ].

	self refresh
]

{ #category : #'accessing - selection' }
FTTableMorph >> highlightRowIndex: aNumber [
	self deprecated: 'Use #highlightIndex: instead' transformWith: '`@receiver highlightRowIndex: `@statements1' -> '`@receiver highlightIndex: `@statements1'.
	self highlightIndex: aNumber
]

{ #category : #'accessing - selection' }
FTTableMorph >> highlightRowIndexes: anArray [
	self deprecated: 'Use #highlightIndexes: instead' transformWith: '`@receiver highlightRowIndexes: `@statements1' -> '`@receiver highlightIndexes: `@statements1'.
	self highlightIndexes: anArray
]

{ #category : #'accessing - selection' }
FTTableMorph >> highlightedIndex [
	^ self highlightedIndexes ifNotEmpty: #first ifEmpty: [ 0 ]
]

{ #category : #'accessing - selection' }
FTTableMorph >> highlightedIndexes [
	^ highlightedIndexes
]

{ #category : #'accessing - selection' }
FTTableMorph >> highlightedRowIndex [
	self deprecated: 'Use #highlightedIndex instead' transformWith: '`@receiver highlightedRowIndex' -> '`@receiver highlightedIndex'.
	^ self highlightedIndex
]

{ #category : #'accessing - selection' }
FTTableMorph >> highlightedRowIndexes [
	self deprecated: 'Use #highlightedIndexes instead' transformWith: '`@receiver highlightedRowIndexes' -> '`@receiver highlightedIndexes'.
	^ self highlightedIndexes
]

{ #category : #private }
FTTableMorph >> horizontalScrollBar [
	^ horizontalScrollBar
]

{ #category : #private }
FTTableMorph >> horizontalScrollBarHeight [
	^horizontalScrollBar 
		ifNil: [ 0 ] 
		ifNotNil: [ 
			self isHorizontalScrollBarVisible ifFalse: [ ^ 0 ].
			self scrollBarThickness
			] 
]

{ #category : #private }
FTTableMorph >> horizontalScrollBarValue: aNumber [
	horizontalScrollBar ifNotNil: [ 
	self container adjustToHorizontalScrollBarValue: aNumber.
	].
]

{ #category : #initialization }
FTTableMorph >> initialize [
	super initialize.
	showIndex := 0.
	showColumnHeaders := true.
	columns := #().
	needToggleAtMouseUp := false.
	self beRowSelection.
	self beNotResizable.
	self beSingleSelection.
	self enableSearch.
	self initializeScrollBars.
	self initializeContainer.
	self initializeKeyBindings.

	self resizeAllSubviews
]

{ #category : #initialization }
FTTableMorph >> initializeContainer [
	container := self defaultContainer.
	self addMorph: container
]

{ #category : #initialization }
FTTableMorph >> initializeKeyBindings [
	"add keybindings used by table"

	self 
		bindKeyCombination: Character arrowUp shift | Character arrowUp asKeyCombination
		toAction: [ :target :morph :event | self keyStrokeArrowUp: event ].
	self 
		bindKeyCombination: Character arrowDown shift | Character arrowDown asKeyCombination
		toAction: [ :target :morph :event | self keyStrokeArrowDown: event ].
	self 
		bindKeyCombination: Character arrowLeft shift | Character arrowLeft asKeyCombination
		toAction: [ :target :morph :event | self keyStrokeArrowLeft: event ].
	self 
		bindKeyCombination: Character arrowRight shift | Character arrowRight asKeyCombination
		toAction: [ :target :morph :event | self keyStrokeArrowRight: event ].
	self 
		bindKeyCombination: Character home asKeyCombination
		toAction: [ self selectFirst ].
	self 
		bindKeyCombination: Character end asKeyCombination
		toAction: [ self selectLast ].
	self 
		bindKeyCombination: self shortcutProvider selectAllShortcut
		toAction: [ self selectAll ]
]

{ #category : #initialization }
FTTableMorph >> initializeScrollBars [
	verticalScrollBar := ScrollBarMorph new 
		model: self; 
		setValueSelector: #verticalScrollBarValue:;
		yourself.
	self addMorph: verticalScrollBar.

	"introducing horizontal scrolling gradually: 
	enable the feature only when the var is set during initialization"
	horizontalScrollBar ifNotNil: [ 	
		horizontalScrollBar := ScrollBarMorph new 
			model: self; 
			setValueSelector: #horizontalScrollBarValue:;
			yourself.
		self addMorph: horizontalScrollBar
		].
]

{ #category : #initialization }
FTTableMorph >> initializeSelectedIndexes [
	selectedIndexes := #().
	highlightedIndexes := #()
]

{ #category : #initialization }
FTTableMorph >> initializeWithHorizontalScrollBar [
	horizontalScrollBar := true.
	self initialize.
]

{ #category : #accessing }
FTTableMorph >> intercellSpacing [ 
	^ intercellSpacing ifNil: [ self class defaultIntercellSpacing ]
]

{ #category : #accessing }
FTTableMorph >> intercellSpacing: aNumberOrPoint [
	"Determines cell spacing 
		x: space between cells 
		y: space between rows"
	intercellSpacing := aNumberOrPoint asPoint 
]

{ #category : #private }
FTTableMorph >> isHorizontalScrollBarVisible [
	^horizontalScrollBar 
		ifNil: [ false ] 
		ifNotNil: [ 
			self horizontalScrollBar owner isNotNil.
			]
]

{ #category : #testing }
FTTableMorph >> isIndexSelected: rowIndex [
	^ self selectedIndexes includes: rowIndex
]

{ #category : #testing }
FTTableMorph >> isIndexVisible: anIndex [
	^ self container isRowIndexVisible: anIndex
]

{ #category : #testing }
FTTableMorph >> isMultipleSelection [
	^ self selectionStrategy isMultiple
]

{ #category : #testing }
FTTableMorph >> isResizable [
	^ resizable
]

{ #category : #testing }
FTTableMorph >> isRowIndexSelected: anIndex [
	self deprecated: 'Use #isIndexSelected: instead' transformWith: '`@receiver isRowIndexSelected: `@statements1' -> '`@receiver isIndexSelected: `@statements1'.
	^ self isIndexSelected: anIndex
]

{ #category : #testing }
FTTableMorph >> isRowIndexVisible: rowIndex [
	self deprecated: 'Use #isIndexVisible: instead' transformWith: '`@receiver isRowIndexVisible: `@statements1' -> '`@receiver isIndexVisible: `@statements1'.
	^ self isIndexVisible: rowIndex
]

{ #category : #testing }
FTTableMorph >> isShowColumnHeaders [
	^ showColumnHeaders
]

{ #category : #private }
FTTableMorph >> isVerticalScrollBarVisible [
	^ self verticalScrollBar owner isNotNil
]

{ #category : #private }
FTTableMorph >> isYellowButtonReallyPressed: anEvent [
	anEvent yellowButtonPressed ifFalse: [ ^false ].
	"this is shitty fix for VM bug. 
	Now if you will press left mouse button together with pressed cmd (on Mac)
	then you will got right mouse button event.
	Interesting that it is not a problem in case of external SDL2 window.
	Try check it from OSWindowWorldMorph new open"
	^ (Smalltalk os isMacOS) 
		ifTrue: [ anEvent commandKeyPressed not]
		ifFalse: [ anEvent controlKeyPressed not]
]

{ #category : #'event handling' }
FTTableMorph >> keyDown: event [
	self flag: #pharoTodo. "If the function is explicit this should be redirect to the function widget."
	((super keyDown: event) or: [ self navigationKey: event ])
		ifTrue: [ ^ true ].
		
	^ self keyDownSearch: event
]

{ #category : #'event handling' }
FTTableMorph >> keyDownSearch: event [
	^ function keyDown: event
]

{ #category : #'event handling' }
FTTableMorph >> keyStroke: event [
	self flag: #pharoTodo. "If the function is explicit this should be redirect to the function widget."
	((super keyStroke: event) or: [ self navigationKey: event ])
		ifTrue: [ ^ true ].
		
	^ self keyStrokeSearch: event
]

{ #category : #'event handling' }
FTTableMorph >> keyStrokeArrowDown: event [
	(self selectionModeStrategy is: self selectedIndex aboveRow: self numberOfRows) ifFalse: [ ^ self ].
	self resetFunction.
	self selectIndex: (self selectionModeStrategy selectableIndexBellow: self selectedIndex) event: event
]

{ #category : #'event handling' }
FTTableMorph >> keyStrokeArrowLeft: event [
	(self selectionModeStrategy is: self selectedIndex afterColumn: 1) ifFalse: [ ^ self ].
	self resetFunction.
	self selectIndex: (self selectionModeStrategy selectableIndexBefore: self selectedIndex) event: event
]

{ #category : #'event handling' }
FTTableMorph >> keyStrokeArrowRight: event [
	(self selectionModeStrategy is: self selectedIndex beforeColumn: self numberOfColumns) ifFalse: [ ^ self ].
	self resetFunction.
	self selectIndex: (self selectionModeStrategy selectableIndexAfter: self selectedIndex) event: event
]

{ #category : #'event handling' }
FTTableMorph >> keyStrokeArrowUp: event [
	(self selectionModeStrategy is: self selectedIndex bellowRow: 1) ifFalse: [ ^ self ].
	self resetFunction.
	self selectIndex: (self selectionModeStrategy selectableIndexAbove: self selectedIndex) event: event
]

{ #category : #'event handling' }
FTTableMorph >> keyStrokeSearch: event [
	^ function keyStroke: event
]

{ #category : #'event handling' }
FTTableMorph >> keyboardFocusChange: aBoolean [
	"The message is sent to a morph when its keyboard focus changes.
	Update for focus feedback."
	super keyboardFocusChange: aBoolean.
	self focusChanged
]

{ #category : #accessing }
FTTableMorph >> lastVisibleRowIndex [

	^ self container lastVisibleRowIndex
]

{ #category : #layout }
FTTableMorph >> minHeight [ 
	"Ceiling is required because there is strange behavior when this method return float.
	In that case table stop respond to any events like clicks"
	
	^ self 
		valueOfProperty: #minHeight
		ifAbsent:[ self class defaultRowHeight ceiling ]
]

{ #category : #layout }
FTTableMorph >> minWidth [

	^ 100
]

{ #category : #'event handling' }
FTTableMorph >> mouseDown: event [
	"perform the click"

	needToggleAtMouseUp ifTrue: [ ^ self ].

	(self selectionModeStrategy selectableIndexContainingPoint: event cursorPoint)
		ifNotNil: [ :index | 
			(self selectedIndexes includes: index)
				ifFalse: [ self selectIndex: index event: event ]
				ifTrue: [ needToggleAtMouseUp := true ] "If the cell is selected we let the mouse up toggle to avoid any problem with the drag and drop" ]
		ifNil: [ ^ self ].

	self wantsKeyboardFocus ifTrue: [ self takeKeyboardFocus ].
	event hand waitForClicksOrDrag: self event: event
]

{ #category : #'event handling' }
FTTableMorph >> mouseEnterDragging: event [
	self enabled ifFalse: [ ^ self ].
	(event hand hasSubmorphs and: [ self dropEnabled ]) 
		ifFalse: [ "no d&d" ^ super mouseEnterDragging: event ].	
]

{ #category : #'event handling' }
FTTableMorph >> mouseLeaveDragging: event [
	"The mouse has left with a button down."

	(self dropEnabled and: [ event hand hasSubmorphs ]) ifFalse: [ "no d&d" ^ super mouseLeaveDragging: event ].

	self basicHighlightIndexes: #().
	self refresh
]

{ #category : #'event handling' }
FTTableMorph >> mouseMove: event [
	event isDraggingEvent ifFalse: [ ^ self ].
	event hand hasSubmorphs ifFalse: [ ^ self ].

	(self wantsDroppedMorph: event hand submorphs first event: event) ifFalse: [ ^ self ].

	(self container rowIndexContainingPoint: event position)
		ifNotNil: [ :rowIndex | 
			self basicHighlightIndexes: {rowIndex}.
			self refresh ].

	(self container bounds containsPoint: event position) ifFalse: [ ^ self ].

	event position y <= (self container top + self autoScrollHeightLimit) ifTrue: [ ^ self verticalScrollBar scrollUp: 1 ].
	event position y >= (self container bottom - self autoScrollHeightLimit) ifTrue: [ ^ self verticalScrollBar scrollDown: 1 ]
]

{ #category : #'event handling' }
FTTableMorph >> mouseUp: event [
	needToggleAtMouseUp ifFalse: [ ^ self ].

	"perform the click if the mouse down didn't do it."
	(self selectionModeStrategy selectableIndexContainingPoint: event cursorPoint) ifNotNil: [ :index | self selectIndex: index event: event ].

	needToggleAtMouseUp := false
]

{ #category : #'event handling' }
FTTableMorph >> mouseWheel: event [

	"I tried scrolling up/down with a calculated value (check #scrollUpByPageDelta implementor)
	 but the scrollbar proved been more intelligent than me... looks like hardcoded values 
	 work better :/"
	event isUp ifTrue: [ 
		self verticalScrollBar scrollRestrictedUp: 3.
		^ self
	].
	event isDown ifTrue: [ 
		self verticalScrollBar scrollRestrictedDown: 3.
		^ self
	].
	
	super mouseWheel: event
]

{ #category : #private }
FTTableMorph >> moveShowIndexTo: arg [
	"I move the showing index to a specific row, and perform a refresh of subviews. 
	 I should not be used directly, and most methods that need to move the 
	 showing pointer should do it directly. 
	 Use me just in case you need to force a refresh after settign the index"

	| index oldIndex |
	index := self selectionModeStrategy rowIndexFrom: arg.
	oldIndex := showIndex.
	self basicMoveShowIndexTo: index.
	self verticalScrollBar value: (self rowIndexToVerticalScrollBarValue: index).
	self refresh.
	
	self announceScrollChangedFrom: oldIndex to: index.
]

{ #category : #accessing }
FTTableMorph >> numberOfColumns [ 
	^ columns size
]

{ #category : #accessing }
FTTableMorph >> numberOfRows [
	self hasDataSource ifFalse: [ ^ 0 ]. 
	^ self dataSource numberOfRows
]

{ #category : #private }
FTTableMorph >> recalculateVerticalScrollBar [
	| interval delta pageDelta visibleRows numberOfRows |
	
	self hasDataSource ifFalse: [ ^ self ].

	self recalculateVerticalScrollBarVisibilityIfHidden: [ ^ self ].
	 
	visibleRows := self container calculateExactVisibleRows.	
	numberOfRows := self dataSource numberOfRows.
	numberOfRows = 0 ifTrue: [ ^self ].
	interval := (visibleRows / numberOfRows) asFloat.
	delta := 1/numberOfRows.
	pageDelta := ((visibleRows-1) floor)*delta.
	self verticalScrollBar 
		scrollDelta: delta pageDelta: pageDelta;
		interval: interval
]

{ #category : #private }
FTTableMorph >> recalculateVerticalScrollBarVisibilityIfHidden: aBlock [
	self container calculateExactVisibleRows >= self dataSource numberOfRows
		ifTrue: [ 
			(self isVerticalScrollBarVisible)
				ifTrue: [ self removeMorph: self verticalScrollBar ].
			self resizeContainer. "it changed... I need to resize it immediately because 
			otherwise it does not work fine with first show... this can cause two sends to 
			#resizeContainer but the case is minimal and not expensive, so we can ignore it"
			aBlock value ]
		ifFalse: [ 
			(self isVerticalScrollBarVisible)
				ifFalse: [ 
					self resizeVerticalScrollBar.
					self addMorph: self verticalScrollBar ] ]

]

{ #category : #updating }
FTTableMorph >> refresh [
	"Refreshes all internal values (forces an invalidate of all subviews)"
	self ensureAtLeastOneColumn.
	self recalculateVerticalScrollBar.
	self verticalScrollBar changed.
	horizontalScrollBar ifNotNil: [ self horizontalScrollBar changed ].
	self container changed
	
]

{ #category : #accessing }
FTTableMorph >> resetFunction [
	function reset
]

{ #category : #private }
FTTableMorph >> resetPosition [
	"Resets all values to original value"
	showIndex := 0.
	self verticalScrollBar value: 0.
	horizontalScrollBar ifNotNil: [	self horizontalScrollBar value: 0 ].
	self container setNeedsRefreshExposedRows.
	self container updateExposedRows.
]

{ #category : #private }
FTTableMorph >> resizeAllSubviews [
	self resizeVerticalScrollBar.
	horizontalScrollBar ifNotNil: [ self resizeHorizontalScrollBar ].
	"if we resized scrollbar, we need to recalculate it because values change (and now visibility 
	 can be toggled, shown items can change, etc.)"
	self recalculateVerticalScrollBar.
	self resizeContainer.
	self container setNeedsRefreshExposedRows.
	self container updateExposedRows.
	self verticalScrollBar value: (self rowIndexToVerticalScrollBarValue: showIndex).
	function isExplicit
		ifTrue: [ function resizeWidget ]
]

{ #category : #private }
FTTableMorph >> resizeContainer [ 
	| topLeft bottomRight |
	topLeft := (self bounds left - self borderWidth) @ self bounds top - self borderWidth.
	bottomRight := (self bounds right  - self verticalScrollBarWidth    - self borderWidth) 
					 @ (self bounds bottom - self horizontalScrollBarHeight - self borderWidth).
	self container
		bounds:
			(function isExplicit
				ifTrue: [ function resizeContainerFrom: topLeft to: bottomRight ]
				ifFalse: [ topLeft corner: bottomRight ])
]

{ #category : #private }
FTTableMorph >> resizeHorizontalScrollBar [
	| width height corner |
	horizontalScrollBar ifNotNil: [ 
		width := self bounds width - (self borderWidth * 2) - self verticalScrollBarWidth.
		height := self scrollBarThickness.
		corner := self bounds bottomLeft - ((width + self borderWidth)@(0 - self borderWidth)).
		corner := self bounds bottomLeft - ((0 - self borderWidth)@(height+self borderWidth)).
		self horizontalScrollBar bounds: (corner extent: width@height).
		]
]

{ #category : #private }
FTTableMorph >> resizeVerticalScrollBar [
	| width height corner |
	width := self scrollBarThickness.
	height := self bounds height - (self borderWidth * 2) - self horizontalScrollBarHeight.
	corner := self bounds topRight - ((width + self borderWidth)@(0 - self borderWidth)).
	self verticalScrollBar bounds: (corner extent: width@height)
]

{ #category : #accessing }
FTTableMorph >> rowHeight [
	"This is the row height your rows will have. Cells answered in dataSource will be forced to have
	 this height number... We force it instead allowing lists to have any height because the logic to 
	 calculate rows becomes complicated. Possible, but complicated :)"
	^ rowHeight ifNil: [ rowHeight := self class defaultRowHeight ]
]

{ #category : #accessing }
FTTableMorph >> rowHeight: aNumber [
	rowHeight := aNumber
]

{ #category : #private }
FTTableMorph >> rowIndexToVerticalScrollBarValue: aNumber [
	| numberOfRows |
	numberOfRows := self numberOfRows - self container calculateMinVisibleRows.
	^ (numberOfRows = 0 or: [ aNumber <= 1 ])
		ifTrue: [ 0.0 ]
		ifFalse: [ ((aNumber / numberOfRows) asFloat max: 0.0) min: 1.0 ]
]

{ #category : #private }
FTTableMorph >> scrollBarThickness [
	^ self theme scrollbarThickness
]

{ #category : #private }
FTTableMorph >> scrollToIndex: anIndex [
	(self container isRowIndexFullyVisible: anIndex) ifTrue: [ ^ self ].

	anIndex <= self showIndex
		ifTrue: [ self moveShowIndexTo: anIndex ]
		ifFalse: [ self moveShowIndexTo: (self selectionModeStrategy indexForRow: anIndex - self container calculateMinVisibleRows + 1) ]
]

{ #category : #'accessing - colors' }
FTTableMorph >> secondarySelectionColor [ 
	^ secondarySelectionColor ifNil: [ self class defaultSecondarySelectionColor ]
]

{ #category : #'accessing - colors' }
FTTableMorph >> secondarySelectionColor: aColor [
	secondarySelectionColor := aColor
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectAll [
	self isMultipleSelection ifFalse: [ ^ self ].

	self selectionModeStrategy selectAll
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectAllRowIndexes [
	self deprecated: 'Use #selectAll instead' transformWith: '`@receiver selectAllRowIndexes' -> '`@receiver selectAll'.
	^ self selectAll
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectFirst [
	self selectionModeStrategy selectFirst
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectIndex: anArray [
	self selectIndexes: {anArray}
]

{ #category : #private }
FTTableMorph >> selectIndex: index event: event [
	index
		ifNotNil: [ self selectionStrategy selectIndex: index event: event ]
		ifNil: [ self deselectAll ]
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectIndexes: anArray [
	self selectIndexes: anArray andMakeVisibleIf: true
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectIndexes: anArray andMakeVisibleIf: shouldEnsureVisibleSelection [
	| oldSelectedIndexes |
	anArray = self selectedIndexes ifTrue: [ ^ self ].
	oldSelectedIndexes := self selectedIndexes.
	self basicSelectIndexes: anArray.
	shouldEnsureVisibleSelection ifTrue: [ self ensureVisibleFirstSelection ].
	self refresh.
	self
		doAnnounce:
			((FTSelectionChanged from: oldSelectedIndexes to: self selectedIndexes)
				fastTable: self;
				yourself)
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectLast [
	self selectionModeStrategy selectLast
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectRowIndex: aNumber [
	self deprecated: 'Use #selectIndex: instead' transformWith: '`@receiver selectRowIndex: `@statements1' -> '`@receiver selectIndex: `@statements1'.
	self selectIndex: aNumber
]

{ #category : #private }
FTTableMorph >> selectRowIndex: rowIndex event: event [
	self deprecated: 'Use #selectIndex:event: instead' transformWith: '`@receiver selectRowIndex: `@statements1 event: `@statements2' -> '`@receiver selectIndex: `@statements1 event: `@statements2'.
	self selectIndex: rowIndex event: event
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectRowIndexes: anArray [
	self deprecated: 'Use #selectIndexes: instead' transformWith: '`@receiver selectRowIndexes: `@statements1' -> '`@receiver selectIndexes: `@statements1'.
	self selectIndexes: anArray
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectRowIndexes: anArray andMakeVisibleIf: shouldEnsureVisibleSelection [
	self
		deprecated: 'Use #selectIndexes:andMakeVisibleIf: instead'
		transformWith: '`@receiver selectRowIndexes: `@statements1 andMakeVisibleIf: `@statements2' -> '`@receiver selectIndexes: `@statements1 andMakeVisibleIf: `@statements2'.
	self selectIndexes: anArray andMakeVisibleIf: shouldEnsureVisibleSelection
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectedIndex [
	^ self selectedIndexes ifNotEmpty: #first ifEmpty: [ self selectionModeStrategy nullIndex ]
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectedIndexes [
	^ selectedIndexes
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectedRowIndex [
	self deprecated: 'Use #selectedIndex instead' transformWith: '`@receiver selectedRowIndex' -> '`@receiver selectedIndex'.
	^ self selectedIndex
]

{ #category : #'accessing - selection' }
FTTableMorph >> selectedRowIndexes [
	self deprecated: 'Use #selectedIndexes instead' transformWith: '`@receiver selectedRowIndexes' -> '`@receiver selectedIndexes'.
	^ self selectedIndexes
]

{ #category : #'accessing - colors' }
FTTableMorph >> selectionColor [
	^ selectionColor ifNil: [ self class defaultSelectionColor ]
]

{ #category : #'accessing - colors' }
FTTableMorph >> selectionColor: aColor [
	selectionColor := aColor
]

{ #category : #accessing }
FTTableMorph >> selectionModeStrategy [
	^ selectionModeStrategy
]

{ #category : #accessing }
FTTableMorph >> selectionModeStrategy: aStrategy [
	(selectionModeStrategy = aStrategy) ifTrue: [ ^ self ].

	selectionModeStrategy := aStrategy.
	self initializeSelectedIndexes
]

{ #category : #private }
FTTableMorph >> selectionStrategy [
	^ selectionStrategy
]

{ #category : #accessing }
FTTableMorph >> setMultipleSelection: aBoolean [

	aBoolean
		ifTrue: [ self beMultipleSelection ]
		ifFalse: [ self beSingleSelection ]
]

{ #category : #accessing }
FTTableMorph >> shortcutProvider [
	^ PharoShortcuts current
]

{ #category : #accessing }
FTTableMorph >> showColumnHeaders [
	"Indicates table will show column headers. 
	 See #hideColumnHeaders"
	showColumnHeaders ifTrue: [ ^ self ].
	showColumnHeaders := true.
	self refresh
]

{ #category : #accessing }
FTTableMorph >> showFirstRowSelection [
	self deprecated: 'Use #showFirstSelection instead' transformWith: '`@receiver showFirstRowSelection' -> '`@receiver showFirstSelection'.
	^ self showFirstSelection
]

{ #category : #accessing }
FTTableMorph >> showFirstSelection [
	self hasSelection ifFalse: [ ^ self ].
	self moveShowIndexTo: self selectedIndex
]

{ #category : #private }
FTTableMorph >> showIndex [ 
	^ showIndex
]

{ #category : #menu }
FTTableMorph >> showMenuForIndex: aTuple [
	| menu rowIndex columnIndex |
	
	rowIndex := aTuple first.
	columnIndex := aTuple second.

	(rowIndex notNil and: [ (self isIndexSelected: rowIndex) not ]) ifTrue: [ 
		self selectIndex: (self selectionModeStrategy indexFromPosition: aTuple) ].

	menu := self dataSource 
		menuColumn: (columnIndex ifNotNil: [self columns at: columnIndex])
		row: (rowIndex ifNil: [0]).
		
	(menu isNil or: [ menu isInWorld ]) ifTrue: [ ^ self ].
	
	menu popUpInWorld: self currentWorld

	
]

{ #category : #menu }
FTTableMorph >> showMenuForPosition: aPoint [
	| tuple |
	tuple := self container rowAndColumnIndexContainingPoint: aPoint.
	self showMenuForIndex: tuple
]

{ #category : #'drag and drop' }
FTTableMorph >> startDrag: event [

	| passengers transferMorph |

	event hand hasSubmorphs ifTrue: [^ self]. 
	self dragEnabled ifFalse: [^ self].
	"Here I ensure at least one element is selected "
	event hand anyButtonPressed ifFalse: [ ^self ].
	self hasSelection ifFalse: [ ^ self ].
			
	passengers := self selectedIndexes collect: [ :each | self dataSource passengerAt: each ].
	transferMorph := self dataSource transferFor: passengers from: self.
	transferMorph align: transferMorph draggedMorph topLeft with: event position.
	transferMorph dragTransferType: self dataSource dragTransferType.
	
	event hand grabMorph: transferMorph 
]

{ #category : #'event testing' }
FTTableMorph >> takesKeyboardFocus [
	^ self enabled
]

{ #category : #updating }
FTTableMorph >> themeChanged [
	self color: self defaultColor.
	super themeChanged.
	self refresh
]

{ #category : #updating }
FTTableMorph >> update: symbol [
	symbol == #refresh ifTrue: [ ^ self refresh ].
	^ super update: symbol
	
]

{ #category : #private }
FTTableMorph >> verticalScrollBar [
	^ verticalScrollBar
]

{ #category : #private }
FTTableMorph >> verticalScrollBarValue: aNumber [

	self hasDataSource ifFalse: [ ^ self ].
	
	showIndex := self verticalScrollBarValueToRowIndex: aNumber.
	
	self container changed
]

{ #category : #private }
FTTableMorph >> verticalScrollBarValueToRowIndex: aNumber [
	| startingIndex |
	startingIndex := self dataSource numberOfRows - self container calculateMinVisibleRows + 1.
	^ (startingIndex * aNumber) asInteger
]

{ #category : #private }
FTTableMorph >> verticalScrollBarWidth [
	self isVerticalScrollBarVisible ifFalse: [  ^ 0 ].
	^ self scrollBarThickness
]

{ #category : #accessing }
FTTableMorph >> visibleRowMorphAtIndex: index [
	^ container visibleRowMorphAtIndex: index
]

{ #category : #'drag and drop' }
FTTableMorph >> wantsDroppedMorph: aMorph event: event [
	aMorph isTransferable ifFalse: [ ^false ].
	^ self dataSource 
		wantsDropElements: aMorph passenger
		type: aMorph dragTransferType
		index: ((self container rowIndexContainingPoint: event position) ifNil: [ 0 ])
]
