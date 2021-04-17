"
I am the adapter used to realise a SpTreeTablePresenter.
I will create a tree table (using FTTableMorph), using the columns TableColumn* as definitions.

Is important notice here that most of the row/cell creation happens on SpMorphicTreeTableDataSource. Check there for some implementation details.
"
Class {
	#name : #SpMorphicTreeTableAdapter,
	#superclass : #SpAbstractMorphicAdapter,
	#category : #'Spec2-Adapters-Morphic-Table'
}

{ #category : #accessing }
SpMorphicTreeTableAdapter class >> intercellSpacing [

	^ 2@0
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> acceptDroppingMorph: aTransferMorph event: anEvent [ 
	
	self presenter acceptDrop cull: (self 
		transferFrom: aTransferMorph 
		event: anEvent)
]

{ #category : #initialization }
SpMorphicTreeTableAdapter >> addActivationKeyBindings: aWidget [

	self 
		bindKeyCombination: Character cr asKeyCombination
		toAction: [ self triggerActivationAction ]
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> addColumnsFromPresenterTo: tableMorph [

	"I need to ensure first column will have the size required and this is tricky on 
	 fixed width of column: I need to enlarge that width with the width of the expander."
	self columns withIndexDo: [ :each :index | | column |
		column := self newColumnFrom: each.
		(index = 1 and: [ column width notNil ]) ifTrue: [ 
			column width: column width + SpMorphicTreeTableDataSource emptyMorph width ]. 
		tableMorph addColumn: column ].
			
]

{ #category : #initialization }
SpMorphicTreeTableAdapter >> addFocusRotationKeyBindings [
	
	^ super addFocusRotationKeyBindings
]

{ #category : #initialization }
SpMorphicTreeTableAdapter >> addKeyBindingsTo: aWidget [

	super addKeyBindingsTo: aWidget.
	self addContextMenuKeyBindings: aWidget.
	self addActivationKeyBindings: aWidget
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> addModelTo: tableMorph [

	self addColumnsFromPresenterTo: tableMorph.
	self ensureAtLeastOneColumnIn: tableMorph.

	self presenter selection isMultipleSelection ifTrue: [  
		tableMorph beMultipleSelection ].

	self isShowingColumnHeaders 
		ifTrue: [ tableMorph showColumnHeaders ] 
		ifFalse: [ tableMorph hideColumnHeaders ].

	self isResizable 
		ifTrue: [ tableMorph beResizable ] 
		ifFalse: [ tableMorph beNotResizable ].
		
	self isSearchEnabled
		ifTrue: [ tableMorph enableSearch ]
		ifFalse: [ tableMorph disableFunction ].

	tableMorph setBalloonText: self model help.
	
	tableMorph dataSource: self newDataSource.
	
	self presenter selection isEmpty 
		ifFalse: [ self updateSelectionOf: tableMorph ].
	
	self presenter whenSelectionChangedDo: [ 
		self updateSelectionOf: tableMorph ].
	
	self presenter whenRootsChangedDo: [ 
		tableMorph selectIndexes: #().
		tableMorph dataSource: self newDataSource ].
	
	self presenter whenShowColumnHeadersChangedDo: [ 	
		self isShowingColumnHeaders 
			ifTrue: [ tableMorph showColumnHeaders ] 
			ifFalse: [ tableMorph hideColumnHeaders ] ].
		
	self registerColumnsChangedEventTo: tableMorph.
	
	tableMorph
		onAnnouncement: FTSelectionChanged
			send: #selectionChanged:
			to: self;
		onAnnouncement: FTStrongSelectionChanged
			send: #strongSelectionChanged:
			to: self
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> basicSelectionChanged: ann [
	| selection |
	
	selection := self presenter selection.
	ann newSelectedIndexes ifEmpty: [ ^ selection unselectAll ].
	(ann newSelectedIndexes difference: ann oldSelectedIndexes) ifEmpty: [ ^ self ].
	
	selection selectPaths: (ann newSelectedIndexes
		collect: [ :index | self widget dataSource pathFromIndex: index ]).
		
	self presenter activatesOnSingleClick ifTrue: [ 
		self presenter doActivateAtPath: selection selectedPath ]
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> buildWidget [
	| tableMorph |

	tableMorph := SpFTTableMorph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		intercellSpacing: self class intercellSpacing;
		dragEnabled: self dragEnabled;
		dropEnabled: self dropEnabled;
		yourself.

	self addModelTo: tableMorph.
	widget := tableMorph.
	self configureScrolling.

	^ tableMorph
]

{ #category : #testing }
SpMorphicTreeTableAdapter >> columnCount [
	
	^ self widget columns size
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> columns [
	
	^ self presenter columns
]

{ #category : #scrolling }
SpMorphicTreeTableAdapter >> configureScrolling [
	self presenter verticalAlignment
		whenChangedDo: [ widget
				scrollToIndex: self presenter verticalAlignment desiredVisibleRow ].
			
	self presenter
		whenDisplayDo: [ widget
				scrollToIndex: self presenter verticalAlignment desiredVisibleRow.
			self scrollingChanged ].
		
	widget
		onAnnouncement: FTScrollingChanged
		send: #scrollingChanged
		to: self.
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> defaultColumn [

	^ SpStringTableColumn new evaluated: [ :each | each yourself ]
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> ensureAtLeastOneColumnIn: tableMorph [
	self model columns ifNotEmpty: [ ^ self ].
	tableMorph addColumn: (self newColumnFrom: self defaultColumn)
]

{ #category : #accessing }
SpMorphicTreeTableAdapter >> expandAll [

	widget dataSource expandAll
]

{ #category : #accessing }
SpMorphicTreeTableAdapter >> expandPath: anArray [  

	widget dataSource expandPath: anArray
]

{ #category : #accessing }
SpMorphicTreeTableAdapter >> expandRoots [

	widget dataSource expandRoots
]

{ #category : #testing }
SpMorphicTreeTableAdapter >> isExpanded: anItem [
	| path |
	
	path := widget dataSource 
		pathOfItem: anItem 
		root: widget dataSource rootItem.
	^ (widget dataSource itemAtPath: path) isExpanded
]

{ #category : #testing }
SpMorphicTreeTableAdapter >> isNonEditableRow: aRow column: aColumn [

	^ (self widget dataSource
		cellColumn: (self widget columns at: aColumn)
		row: aRow) submorphs 
		allSatisfy: [ :e | e asReadOnlyMorph == e ]
]

{ #category : #testing }
SpMorphicTreeTableAdapter >> isResizable [

	^ self presenter isResizable
]

{ #category : #testing }
SpMorphicTreeTableAdapter >> isSearchEnabled [

	^ self presenter isSearchEnabled
]

{ #category : #testing }
SpMorphicTreeTableAdapter >> isShowingColumnHeaders [

	^ self presenter isShowingColumnHeaders
]

{ #category : #accessing }
SpMorphicTreeTableAdapter >> itemAtPath: anArray [

	self widgetDo: [ :w | 
		^ (w dataSource itemAtPath: anArray) ifNotNil: [ :item | item data ] ].
	^ nil
]

{ #category : #'private factory' }
SpMorphicTreeTableAdapter >> newColumnFrom: aTableColumn [

	^ (SpMorphicTableColumn on: aTableColumn)
		width: aTableColumn width;
		yourself
]

{ #category : #'private factory' }
SpMorphicTreeTableAdapter >> newDataSource [ 

	^ SpMorphicTreeTableDataSource new
		model: self model; 
		rootItem: (self rootForItems: self model roots);
		childrenBlock: [ :data :item | self model childrenFor: data ];
		yourself
]

{ #category : #updating }
SpMorphicTreeTableAdapter >> refreshTree [

	self widget refresh
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> registerColumnsChangedEventTo: tableMorph [
	
	self presenter whenColumnsChangedDo: [
		tableMorph columns: #(). 
		self presenter columns do: [ :each | tableMorph addColumn: (self newColumnFrom: each) ].
		tableMorph dataSource: self newDataSource ].

]

{ #category : #private }
SpMorphicTreeTableAdapter >> rootForItems: aCollection [

	^ FTRootItem new
		data: aCollection;
		yourself
]

{ #category : #accessing }
SpMorphicTreeTableAdapter >> scrollToSelection [
	widget ensureVisibleFirstSelection.
]

{ #category : #scrolling }
SpMorphicTreeTableAdapter >> scrollingChanged [
	widget container updateAllRows.
	self presenter verticalAlignment
		firstVisibleRowIndex: widget firstVisibleRowIndex;
		lastVisibleRowIndex: widget lastVisibleRowIndex
]

{ #category : #selecting }
SpMorphicTreeTableAdapter >> selectInto: aFTTableMorph paths: aCollectionOfPaths [ 
	
	| indexes items |
	
	items := aCollectionOfPaths collect: [ :aPath | | item |
		item := aFTTableMorph dataSource itemAtPath: aPath expanding: true.
		item 
			ifNil: [ aFTTableMorph selectIndex: 0. ^ self ].
		item ].

	aFTTableMorph refresh.
	indexes := items collect: [:item | aFTTableMorph dataSource indexOfItem: item].

	aFTTableMorph selectIndexes: indexes andMakeVisibleIf: false.
]

{ #category : #accessing }
SpMorphicTreeTableAdapter >> selectPath: anArray [
	| index |
	
	((anArray isEmpty or: [ anArray first = 0 ]) 
		and: [ widget selectedIndexes isEmpty ]) 
		ifTrue: [ ^ self ].
	index := anArray 
		ifNotEmpty: [ widget dataSource indexFromPath: anArray ]
		ifEmpty: [ 0 ].  
	(widget selectedIndexes includes: index) ifTrue: [ ^ self ].
	widget selectIndex: index
]

{ #category : #accessing }
SpMorphicTreeTableAdapter >> selectedItem [
	
	| selectedIndex |
	selectedIndex := self widget selectedIndex.
	
	selectedIndex = 0 ifTrue: [ ^ nil ].
	
	^ (self widget dataSource elementAt: selectedIndex) data
]

{ #category : #accessing }
SpMorphicTreeTableAdapter >> selectedPath [
	
	^ self selectedPaths first 
]

{ #category : #accessing }
SpMorphicTreeTableAdapter >> selectedPaths [
	
	^ self widget selectedIndexes collect: [ :e | self widget dataSource pathFromIndex: e  ] 
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> selectionChanged: ann [

	self suspendSelectionEventsDuring: [ 
		self basicSelectionChanged: ann ]
]

{ #category : #emulating }
SpMorphicTreeTableAdapter >> sendRightClickEvent [
	| evt |

	evt := MouseButtonEvent new 
		setType: nil 
		position: widget center 
		which: MouseButtonEvent yellowButton 
		buttons: MouseButtonEvent yellowButton 
		hand: nil 
		stamp: nil.
	
	self widget click: evt
]

{ #category : #private }
SpMorphicTreeTableAdapter >> showContextMenu [

	self widgetDo: [ :w |
		w showMenuForIndex: { self presenter selection selectedIndex. 1 } ]
]

{ #category : #accessing }
SpMorphicTreeTableAdapter >> sortByColumn: aColumn [ 
	
	self widgetDo: [ :w | 
		w dataSource sortByColumn: (w columns 
			detect: [ :each | each model = aColumn ]) ]
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> strongSelectionChanged: aFTStrongSelectionChanged [
	self presenter activatesOnDoubleClick
		ifFalse: [ ^ self ].
	self presenter doubleClickAtPath: self selectedPath
]

{ #category : #factory }
SpMorphicTreeTableAdapter >> suspendSelectionEventsDuring: aBlock [
	| registry subscriptions |

	registry := self widget announcer subscriptions.
	subscriptions := Set new.
	registry 
		subscriptionsOf: self 
		do: [ :each | 
			({ FTSelectionChanged. FTStrongSelectionChanged } includes: each announcementClass) 
				ifTrue: [ subscriptions add: each ] ]. 
			
	subscriptions do: [ :each | registry remove: each ].
	aBlock ensure: [ 
		 subscriptions do: [ :each | registry add: each ] ]
]

{ #category : #updating }
SpMorphicTreeTableAdapter >> transferFrom: aTransferMorph event: anEvent [
	| rowAndColumn aTarget |

	rowAndColumn := self widget container rowAndColumnIndexContainingPoint: anEvent position.
	
	aTarget := rowAndColumn first 
		ifNil: [ nil ]
		ifNotNil: [ :anIndex | (self widget dataSource itemAtIndex: anIndex) data ].
		
	^ SpDragAndDropTransferToTree new
		passenger: aTransferMorph passenger;
		row: (rowAndColumn first ifNil: [ 0 ]);
		column: (rowAndColumn second ifNil: [ 0 ]);
		target: aTarget;
		yourself
]

{ #category : #private }
SpMorphicTreeTableAdapter >> triggerActivationAction [

	self presenter doActivateAtPath: self presenter selection selectedPath
]

{ #category : #updating }
SpMorphicTreeTableAdapter >> updateMenu [
	"there is no need to updateMenu here because it will be resolved at the dataSource"
]

{ #category : #updating }
SpMorphicTreeTableAdapter >> updateSelectionOf: tableMorph [
	
	self 
		selectInto: tableMorph 
		paths: self model selection selectedPaths
]

{ #category : #updating }
SpMorphicTreeTableAdapter >> wantsDroppedMorph: aTransferMorph event: anEvent [ 
	
	^ self presenter wantsDrop cull: (self 
		transferFrom: aTransferMorph 
		event: anEvent)
]
