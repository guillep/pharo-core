"
I am the adapter used to realise a SpTablePresenter.
I will create a tree table (using FTTableMorph), using the columns TableColumn* as definitions.

Is important notice here that most of the row/cell creation happens on SpMorphicTableDataSource. Check there for some implementation details.
"
Class {
	#name : #SpMorphicTableAdapter,
	#superclass : #SpAbstractMorphicListAdapter,
	#category : #'Spec2-Adapters-Morphic-Table'
}

{ #category : #accessing }
SpMorphicTableAdapter class >> intercellSpacing [

	^ 2@0
]

{ #category : #initialization }
SpMorphicTableAdapter >> addKeyBindingsTo: aWidget [

	super addKeyBindingsTo: aWidget.
	self addContextMenuKeyBindings: aWidget
]

{ #category : #factory }
SpMorphicTableAdapter >> addModelTo: tableMorph [

	self model columns do: [ :each |
		tableMorph addColumn: (self newColumnFrom: each) ].
	self ensureAtLeastOneColumnIn: tableMorph.

	self isResizable 
		ifTrue: [ tableMorph beResizable ] 
		ifFalse: [ tableMorph beNotResizable ].
	
	tableMorph setMultipleSelection: self model isMultipleSelection.

	self refreshShowColumnHeaders.
	self refreshWidgetSelection.
	
	self presenter whenShowColumnHeadersChangedDo: [ :showColumns |
		self refreshShowColumnHeaders ].

	self presenter whenModelChangedDo: [ self refreshModel ].
	self presenter whenColumnsChangedDo: [ self refreshColumnsInWidget ].
	
	tableMorph setBalloonText: self help.

	self configureScrolling.

	tableMorph
		onAnnouncement: FTSelectionChanged
			send: #selectionChanged:
			to: self;
		onAnnouncement: FTStrongSelectionChanged
			send: #strongSelectionChanged:
			to: self.

	tableMorph dataSource: self newDataSource.
	
	self presenter whenItemFilterBlockChangedDo: [ :block | 
		self updateItemFilterBlockWith: block ].
	self presenter whenSearchEnabledChangedDo: [ 
		self updateSearch ].
	self updateItemFilterBlockWith: self itemFilter
]

{ #category : #factory }
SpMorphicTableAdapter >> buildWidget [

	widget := SpFTTableMorph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		intercellSpacing: self class intercellSpacing;
		yourself.

	self addModelTo: widget.

	^ widget
]

{ #category : #emulating }
SpMorphicTableAdapter >> clickOnColumnHeaderAt: anIndex [
	self widgetDo: [ :tableWidget | tableWidget clickOnColumnHeaderAt: anIndex ]
]

{ #category : #testing }
SpMorphicTableAdapter >> columns [
	^ widget columns
]

{ #category : #factory }
SpMorphicTableAdapter >> defaultColumn [

	^ SpStringTableColumn new evaluated: #yourself
]

{ #category : #factory }
SpMorphicTableAdapter >> ensureAtLeastOneColumnIn: tableMorph [
	self model columns ifNotEmpty: [ ^ self ].
	tableMorph addColumn: (self newColumnFrom: self defaultColumn)
]

{ #category : #private }
SpMorphicTableAdapter >> ifSorted: sortedBlock ifNotSorted: notSortedBlock [ 
	widget columns 
		do: [ :column | | state | 
			column isSorted
				ifTrue: [ 
					state := column sortingStrategy state.
					state isSorted
						ifTrue: [ ^ sortedBlock cull: state ] ] ].
	^ notSortedBlock value
]

{ #category : #testing }
SpMorphicTableAdapter >> isNonEditableRow: aRow column: aColumn [

	^ (self widget dataSource
		cellColumn: (self widget columns at: aColumn)
		row: aRow) submorphs allSatisfy: [ :e | e asReadOnlyMorph == e ]
]

{ #category : #testing }
SpMorphicTableAdapter >> isResizable [
	^ self model isResizable
]

{ #category : #testing }
SpMorphicTableAdapter >> isShowColumnHeaders [

	^ widget isShowColumnHeaders 	
]

{ #category : #testing }
SpMorphicTableAdapter >> isShowingColumnHeaders [
	^ self model isShowingColumnHeaders
]

{ #category : #'private factory' }
SpMorphicTableAdapter >> newColumnFrom: aTableColumn [

	^ (SpMorphicTableColumn on: aTableColumn)
		width: aTableColumn width;
		yourself
]

{ #category : #'private factory' }
SpMorphicTableAdapter >> newDataSource [ 

	^ SpMorphicTableDataSource new
		model: self model;
		yourself

]

{ #category : #factory }
SpMorphicTableAdapter >> refreshColumnsInWidget [

	widget columns: (self model columns collect: [ :each | self newColumnFrom: each ]).
	self ensureAtLeastOneColumnIn: widget.
]

{ #category : #refreshing }
SpMorphicTableAdapter >> refreshList [

	^ self widget refresh
]

{ #category : #refreshing }
SpMorphicTableAdapter >> refreshModel [

	widget dataSource resetElements.
	self
		ifSorted: [ :sortingStrategyState | sortingStrategyState executeSortingOn: widget dataSource ]
		ifNotSorted: [ self refreshList ]
]

{ #category : #factory }
SpMorphicTableAdapter >> refreshShowColumnHeaders [
	
	self presenter isShowingColumnHeaders 
		ifTrue: [ 
			self widget
				showColumnHeaders;
				refresh ]
		ifFalse: [ 
			self widget
				hideColumnHeaders;
				refresh ]
]

{ #category : #refreshing }
SpMorphicTableAdapter >> refreshWidgetSelection [
	| rowIndexes |
	rowIndexes := self presenter selection selectedIndexes.
	rowIndexes = self widget selectedIndexes
		ifTrue: [ ^ self ].
	rowIndexes isEmpty
		ifTrue: [ self widget basicSelectIndexes: #() ]
		ifFalse: [ self widget basicSelectIndexes: rowIndexes ].
	^ self refreshList
]

{ #category : #selection }
SpMorphicTableAdapter >> selectIndex: anInteger [ 

	(anInteger = 0 and: [ widget selectedIndexes isEmpty ]) ifTrue: [ ^ self ].	
	(widget selectedIndexes includes: anInteger) ifTrue: [^self].
	widget selectIndex: anInteger
]

{ #category : #testing }
SpMorphicTableAdapter >> selectedIndexes [
	
	^ widget selectedIndexes 
]

{ #category : #factory }
SpMorphicTableAdapter >> selectionChanged: ann [
	| diff selection |

	selection := self presenter selection.
	selection selectIndexes: (selection isMultipleSelection
		ifTrue: [ 
			 (ann newSelectedIndexes reject: [ :e | e = 0 ]) ]
		ifFalse: [ 
			{ ann newSelectedIndexes
				ifNotEmpty: [ :indexes | indexes first ]
				ifEmpty: [ 0 ] } ]).

	diff := ann newSelectedIndexes difference: ann oldSelectedIndexes.
	(diff notEmpty and: [ self presenter activatesOnSingleClick ])
		ifTrue: [ self presenter doActivateAtIndex: diff last ].
		
	ann newSelectedIndexes ifEmpty: [ selection unselectAll ]
]

{ #category : #emulating }
SpMorphicTableAdapter >> sendRightClickEvent [
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

{ #category : #factory }
SpMorphicTableAdapter >> strongSelectionChanged: aFTStrongSelectionChanged [

	self presenter activatesOnDoubleClick ifFalse: [ ^ self ].	
	self presenter doubleClickAtIndex: aFTStrongSelectionChanged selectedIndex
]

{ #category : #'drag and drop' }
SpMorphicTableAdapter >> transferFrom: aTransferMorph event: anEvent [
	| rowAndColumn |

	rowAndColumn := self widget container rowAndColumnIndexContainingPoint: anEvent position.
	^ SpDragAndDropTransferToTable new
		passenger: aTransferMorph passenger;
		row: (rowAndColumn first ifNil: [ 0 ]);
		column: (rowAndColumn second ifNil: [ 0 ]);
		yourself
]

{ #category : #updating }
SpMorphicTableAdapter >> updateMenu [
	
	"there is no need to updateMenu here because it will be resolved at the dataSource"
]
