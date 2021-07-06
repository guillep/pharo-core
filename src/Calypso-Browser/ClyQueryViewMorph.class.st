"
I represent query result using fast table.
I should be created for browser:

	ClyQueryView for: aBrowser

or using helper browser method:

	aBrowser newNavigationView.

By default I initialize table with single column, the instance of ClyMainTableColumn. You can ask it to set up specific column properties

	aQueryView mainColumn 
		width: 100;
		displayItemPropertyBy: [:rowItem | rowItem name, 'special name suffix for test' ].

Or you can set up display block using:

	aQueryView displayMainColumnBy: [ :cell :item | 
		cell nameMorph contents: item name.
		cell nameMorph color: Color green].

To create more columns use #addColumn: method:

	(aQueryView addColumn: #package) 
		width: 50;
		displayItemPropertyBy: [:methodItem | self packageNameOf: methodItem]

To show items user should pass query instance into me:

	aQueryView showQuery: aQuery

When user selects any item in table I trigger navigation request which ask browser for desired action. To set up navigation selector use:

	aQueryView requestNavigationBy: #showMethodsForSelectedClasses

I maintain several selection objects to always show correct table selection after any tree expansion, items addition of removal.

Main selection is what user selects on table. I manage it in #selection variable, instance of ClyDataSourceSeleciton.

Next is desiredSelection, instance of ClyDesiredSelection. Every time user passes me new query I am trying to restore desired selection on new items. Idea is to show previously selected items on new data source. I try to find same items and if they not exists I lookup similar items by name.
I set new desiredSelection instance only when user manually modifies table selection.

And last type of selection is highlighting, instance of ClyHighlightingSelection. User can set it by:

	aQueryView highlightItemsWhich: predicateBlock.

All type of selections maintain correct state to be in sync with actual table seletion indexes after any data source changes. This logic implemented in method #updateSelectedItemsOf:.

By default user can type characters on table to search required items. But also explicit filter with extra field can be added: 

- enableFilter
It adds simple ClyItemNameFilter.

- enableFilter: anItemStringFilterClass

I use Commander library to implement:

- context menu using CmdContextMenuCommandActivator:

	- menuColumn: column row: rowIndex

- shortcuts using CmdShortcutCommandActivator 

	- kmDispatcher

-  drag and drop using CmdDragAndDropCommandActivator 

	- createDragPassengerFor: aSelection

To use Commander I ask browser for command context of given selection.
The context is also used to decorate table cells with appropriate decorators:

	- decorateMainTableCell: anItemCellMorph of: aDataSourceItem
	- decorateTableCell: anItemCellMorph of: aDataSourceItem

There is special decorator which also based on Commander: ClyTableIconCommandActivation. It adds iconic button to table cells for all interested commands.
It brings behaviour of Nautilus method widget where table icons are extended by AbstractMethodIconAction. Here commands should be marked with ClyTableIconCommandActivation.

I provide extra suitable events which in future should be also based on commands:
- whenDoubleClickDo: 
- whenEnterKeyPressedDo: 
- whenEscapeKeyPressedDo: 
ClyBrowserSearchDialog uses them to provide user friendly behaviour.

Other suitable methods:
- ignoreNavigationDuring: aBlock. It allows to modify my selection without triggering navigation  request to browser.
- findItemsSameAsFilter. It allows to use full filter string to search my data source for item with exacly same name. It is used by ClyBrowserSearchDialog.
- allowsDeselection: aBoolean.

Internal Representation and Key Implementation Points.

    Instance Variables
	table:		<FTTableMorph>
	browser:		<ClyBrowser>
	navigationSelector:		<aSymbol>
	selection:		<ClyDataSourceSelection>
	desiredSelection:		<ClyDesiredSelection>
	highlighting:		<ClyHighlightingSelection>	
	changesWasInitiatedByUser:		<Boolean>
	shouldRestoreSelection: <Boolean>
	treeStructure: <Array of<Association>>
"
Class {
	#name : #ClyQueryViewMorph,
	#superclass : #Morph,
	#instVars : [
		'table',
		'browser',
		'treeStructure',
		'selection',
		'desiredSelection',
		'shouldRestoreSelection',
		'highlighting',
		'changesWasInitiatedByUser',
		'navigationSelector',
		'dataSourceClass',
		'expandedItemByDrag'
	],
	#category : #'Calypso-Browser-Table'
}

{ #category : #'instance creation' }
ClyQueryViewMorph class >> for: aBrowser [
	^self new 
		browser: aBrowser
]

{ #category : #controlling }
ClyQueryViewMorph >> activateFilterWith: patternString [
	
	self initiateUIChangeBy: [ 
		table activateFilterWith: patternString.
		"Following update forces new selection instance which will be based on filtered data source.
		Selection always should be bound to actual data source of table"
		self updateSelection ]
]

{ #category : #accessing }
ClyQueryViewMorph >> addColumn: columnId [

	| newColumn |
	newColumn := ClyTableColumn id: columnId.
	table addColumn: newColumn.
	^newColumn
]

{ #category : #controlling }
ClyQueryViewMorph >> adoptForDialog [
	(self areItemsLoaded and: [self itemCount < 10])
		ifTrue: [ self height: 100 ]
		ifFalse: [ self height: 300; enableFilterUsing: ClyRegexPattern new]
]

{ #category : #controlling }
ClyQueryViewMorph >> allowsDeselection: aBool [
	table allowsDeselection: aBool
]

{ #category : #testing }
ClyQueryViewMorph >> areItemsLoaded [
	^(self dataSource hasMetaProperty: ClyBackgroundProcessingTag) not
]

{ #category : #accessing }
ClyQueryViewMorph >> browser [
	^ browser
]

{ #category : #accessing }
ClyQueryViewMorph >> browser: anObject [
	browser := anObject
]

{ #category : #controlling }
ClyQueryViewMorph >> changeStateBy: aBlock [
	browser changeStateOf: self by: aBlock
]

{ #category : #accessing }
ClyQueryViewMorph >> changesWasInitiatedByUser [
	^changesWasInitiatedByUser
]

{ #category : #controlling }
ClyQueryViewMorph >> closeDataSource [
	 
	table initialDataSource ifNil: [ ^self dataSource close ].	
	
	"In filter mode initial data source is the main original data source. 
	It manages filtered data source by itself.
	So we do not need to close it manually"	
	table cleanupFilter.
	table initialDataSource close.		
	"We could not reset to nil because some filter process of table can be spawned.
	And it will fail if initialDataSource is nil.
	Normally process should be terminated if table is closed 
	but it is not done in fast table"
]

{ #category : #context }
ClyQueryViewMorph >> createCommandContext [
	^self createSelectionContext
]

{ #category : #'drag and drop support' }
ClyQueryViewMorph >> createDragPassengerFor: aSelection [
	| context |
	context := self createSelectionContextOf: aSelection. 
	
	^CmdDragAndDropActivation createDragPassengerInContext: context
]

{ #category : #context }
ClyQueryViewMorph >> createSelectionContext [
	^self createSelectionContextOf: self selection
]

{ #category : #context }
ClyQueryViewMorph >> createSelectionContextOf: aSelection [

	^ClyContextSelectionStrategyAnnotation selectContextOf: aSelection for: browser
]

{ #category : #accessing }
ClyQueryViewMorph >> dataSource [
	^table dataSource
]

{ #category : #accessing }
ClyQueryViewMorph >> dataSource: aDataSource [

	self changeStateBy: [ 
		self closeDataSource.	
		self setUpDataSource: aDataSource.	
		self refreshTable
	]
]

{ #category : #accessing }
ClyQueryViewMorph >> dataSourceClass [
	^ dataSourceClass ifNil: [ ClyCollapsedDataSource ]
]

{ #category : #accessing }
ClyQueryViewMorph >> dataSourceClass: aClass [
	dataSourceClass := aClass
]

{ #category : #controlling }
ClyQueryViewMorph >> decorateMainTableCell: anItemCellMorph of: aDataSourceItem [
	| context |
	context := ClyContextSelectionStrategyAnnotation selectContextOfSingleItem: aDataSourceItem for: browser.
	
	ClyTableDecorationStrategyAnnotation activeInstancesInContext: context do: [ :strategy | 
		strategy decorateMainTableCell: anItemCellMorph inContext: context]
]

{ #category : #controlling }
ClyQueryViewMorph >> decorateTableCell: anItemCellMorph of: aDataSourceItem [
	| context |
	context := ClyContextSelectionStrategyAnnotation selectContextOfSingleItem: aDataSourceItem for: browser.
	
	ClyTableDecorationStrategyAnnotation activeInstancesInContext: context do: [ :strategy | 
		strategy decorateTableCell: anItemCellMorph inContext: context]
]

{ #category : #initialization }
ClyQueryViewMorph >> defaultColor [
	^Color transparent
]

{ #category : #testing }
ClyQueryViewMorph >> definesTree [
	^treeStructure notEmpty 
]

{ #category : #accessing }
ClyQueryViewMorph >> displayMainColumnBy: cellAndItemBlock [

	self mainColumn displayBlock: cellAndItemBlock 
]

{ #category : #'drag and drop support' }
ClyQueryViewMorph >> dropPassenger: aPassanger at: aDataSourceItem [
	| context |
	context := self createSelectionContextOf: aDataSourceItem asSelection.
	
	^aPassanger dropInContext: context
]

{ #category : #controlling }
ClyQueryViewMorph >> enableCollapsingOfPreexpandedItems [
	dataSourceClass := ClyExpandedDataSource.
]

{ #category : #controlling }
ClyQueryViewMorph >> enableFilter [

	self enableFilter: ClyItemNameFilter
]

{ #category : #controlling }
ClyQueryViewMorph >> enableFilter: anItemStringFilterClass [

	self enableFilterWithFactory: (ClyTableFilterFactory of: anItemStringFilterClass)
]

{ #category : #controlling }
ClyQueryViewMorph >> enableFilter: anItemStringFilterClass using: aStringPattern [

	self enableFilterWithFactory: (ClyTableFilterFactory of: anItemStringFilterClass using: aStringPattern)
]

{ #category : #controlling }
ClyQueryViewMorph >> enableFilterUsing: aStringPattern [

	self enableFilter: ClyItemNameFilter using: aStringPattern
]

{ #category : #controlling }
ClyQueryViewMorph >> enableFilterWithFactory: aTableFilterFactory [

	table 
		enableFilter: aTableFilterFactory; 
		explicitFunction
]

{ #category : #controlling }
ClyQueryViewMorph >> ensureSelectedItem [

	| selectionIndex |
	self selection isEmpty ifFalse: [ ^self ].
	self dataSource isEmpty ifTrue: [ ^self ]. 
	
	selectionIndex := 1.
	(desiredSelection notNil and: [desiredSelection isEmpty not]) ifTrue: [ 
		selectionIndex := desiredSelection lastSelectedItem globalPosition
									min: self dataSource numberOfRows ].
	self selection selectItems: {self dataSource elementAt: selectionIndex}.
	self ensureVisibleSelection
]

{ #category : #controlling }
ClyQueryViewMorph >> ensureSelectedItemIfNeeded [

	table allowsDeselection ifFalse: [ self ensureSelectedItem ].
	self ensureVisibleSelection
]

{ #category : #controlling }
ClyQueryViewMorph >> ensureVisibleSelection [

	self selection isEmpty ifFalse: [ ^self ].

	"following sentence is required to make first item selected in cases
	where browser is just opened and automatic item visibility 
	can be wrongly computed"
	UIManager default defer: [self selection ensureVisibleLastItem]
]

{ #category : #drag }
ClyQueryViewMorph >> expandForDrag: dropTargetItem [
	(expandedItemByDrag isNotNil 
		and: [ expandedItemByDrag ~= dropTargetItem
		and: [ expandedItemByDrag hasChildren 
		and: [ expandedItemByDrag isExpanded ]]])
			ifTrue: [ expandedItemByDrag collapse ].
	^ expandedItemByDrag := dropTargetItem hasChildren 
		ifFalse: [ nil ]
		ifTrue: [
			dropTargetItem expand.
			dropTargetItem.
			]
]

{ #category : #accessing }
ClyQueryViewMorph >> filterField [
	^ table filterField
]

{ #category : #queries }
ClyQueryViewMorph >> findAllItemsBy: aBlockWithDataSource [
	self 
		findAllItemsBy: aBlockWithDataSource 
		stopLookupWhen: [:result | false "by default we always look into both data source if exists"]
]

{ #category : #queries }
ClyQueryViewMorph >> findAllItemsBy: aBlockWithDataSource stopLookupWhen: stopCondition [
	| result fullResult |
	result := aBlockWithDataSource value: self dataSource.
	self isFilterActive ifFalse: [^result].	
	(stopCondition value: result) ifTrue: [ ^result ].
	"In case if view is in filter mode we should try to find items in full original data source.
	If it will be different result then we should reset filter. 
	Idea that if view is able to find items then they should be accessible/visible in table.
	And view must find items in original data source in case if filter do not include them"
	fullResult := aBlockWithDataSource value: table initialDataSource.
	result size = fullResult size ifTrue: [ 
		"if full lookup produces same result as filtered data source
		then no need for full mode switch"
		^result ].
	self setUpDataSource: table initialDataSource.
	^fullResult
]

{ #category : #queries }
ClyQueryViewMorph >> findItemsSameAsFilter [

	| filterString |
	filterString := table filterString asLowercase.
	^self dataSource findItemsWhere:  [:each | each name asLowercase = filterString ]
]

{ #category : #queries }
ClyQueryViewMorph >> findItemsWhere: conditionBlock [

	^self findAllItemsBy: [ :ds | ds findItemsWhere: conditionBlock]
]

{ #category : #queries }
ClyQueryViewMorph >> findItemsWith: actualObjects [

	^self 
		findAllItemsBy: [:ds | ds findItemsWith: actualObjects] 
		stopLookupWhen: [:result | result size = actualObjects size]
]

{ #category : #accessing }
ClyQueryViewMorph >> grabSelectionAt: rowIndex [
	| selectedItems |
	(table isIndexSelected: rowIndex)
		ifTrue: [ ^ self selection ].
	selectedItems := rowIndex = 0
		ifTrue: [ #() ]
		ifFalse: [ {(self itemAt: rowIndex)} ].
	^ self newSelectionWith: selectedItems
]

{ #category : #testing }
ClyQueryViewMorph >> hasKeyboardFocus [ 
	^super hasKeyboardFocus or: [ table hasKeyboardFocus  ]
]

{ #category : #testing }
ClyQueryViewMorph >> hasRealQuery [

	^self query ~~ ClyUnknownQuery instance
]

{ #category : #controlling }
ClyQueryViewMorph >> highlightItemsWhich: predicateBlock [

	highlighting selectItemsWhere: predicateBlock
]

{ #category : #controlling }
ClyQueryViewMorph >> ignoreNavigationDuring: aBlock [

	| selector |
	selector := navigationSelector.
	navigationSelector := nil.
	aBlock ensure: [ navigationSelector := selector ]
]

{ #category : #initialization }
ClyQueryViewMorph >> initialize [
	super initialize.
	self changeTableLayout.
	self initializeTable.
	self whenDoubleClickDo: [ self triggerDoubleClickCommands ].
	
	shouldRestoreSelection := true.
	changesWasInitiatedByUser := true.
	treeStructure := #().	
	self setUpDataSource: ClyDataSource empty
]

{ #category : #initialization }
ClyQueryViewMorph >> initializeTable [
	table := FTTableMorph new.
	table allowsDeselection: true.
	table beMultipleSelection.
	table beResizable.
	table dragEnabled: true.
	table dropEnabled: true.
	table onAnnouncement: FTSelectionChanged send: #selectionChanged to: self.
	table addColumn: ClyMainTableColumn default.
	table vResizing: #spaceFill.
	table hResizing: #spaceFill.
	self addMorph: table
]

{ #category : #controlling }
ClyQueryViewMorph >> initiateUIChangeBy: aBlock [
	"We need to distingish UI state changes produced by user or by tool itself.
	This method setup special flag which shows that all following operations are performed by tool.
	So in any method we could check that it was initiated by user or not"
	
	changesWasInitiatedByUser ifFalse: [ ^aBlock value ].
	changesWasInitiatedByUser := false.
	aBlock ensure: [ changesWasInitiatedByUser := true ]
]

{ #category : #testing }
ClyQueryViewMorph >> isFilterActive [
	table initialDataSource ifNil: [ ^false ].
	
	^self dataSource ~~ table initialDataSource
]

{ #category : #testing }
ClyQueryViewMorph >> isFilterChanged [
	"when user filters the table in the filter field 
	the table resets selection and sets the new data source.
	But existing selection will points to another original data source 
	which allows detect this event in current fast table logic"
	table initialDataSource ifNil: [ 
		"it means that filter is not used by user"
		^false ]. 
	"only way to change data source of table without affecting selection is by using filter 
	which set up new filtered data source almost on every key stroke"
	^selection rootDataSource ~~ self dataSource
]

{ #category : #accessing }
ClyQueryViewMorph >> itemAt: rowIndex [
	^self dataSource elementAt: rowIndex
]

{ #category : #accessing }
ClyQueryViewMorph >> itemCount [
	^self dataSource numberOfRows
]

{ #category : #'event handling' }
ClyQueryViewMorph >> itemsChangedIn: aDataSource [ 
	| selectionWasEmpty |
	self refreshAsyncState.
	selectionWasEmpty := 	self selection isEmpty.
		
	browser ignoreNavigationDuring: [ 
		self updateSelectedItemsOf: aDataSource.
		selectionWasEmpty ifTrue: [self ensureSelectedItemIfNeeded]].
	browser itemsChanged
]

{ #category : #keymapping }
ClyQueryViewMorph >> kmDispatcher [

	^ CmdKMDispatcher attachedTo: self
]

{ #category : #accessing }
ClyQueryViewMorph >> mainColumn [
	"Answer the main column in table"

	^ table columns detect: #isMainColumn
]

{ #category : #'menu building' }
ClyQueryViewMorph >> menuColumn: column row: rowIndex [
	
	| menuSelection context |
	menuSelection := self grabSelectionAt: rowIndex.
		
	context := self createSelectionContextOf: menuSelection.
	
	^CmdContextMenuActivation buildContextMenuFor: self inContext: context
]

{ #category : #accessing }
ClyQueryViewMorph >> moveMainColumnAtTheEnd [

	| mainColumn |
	mainColumn := self mainColumn.
	table columns: (table columns copyWithout: mainColumn), {mainColumn}
]

{ #category : #controlling }
ClyQueryViewMorph >> neverRestoreSelection [
	shouldRestoreSelection := false
]

{ #category : #initialization }
ClyQueryViewMorph >> newSelectionWith: dataSourceItems [
	^self dataSource newSelectionWith: dataSourceItems 
]

{ #category : #accessing }
ClyQueryViewMorph >> query [
	^self dataSource query
]

{ #category : #'tree support' }
ClyQueryViewMorph >> queryToExpand: aDataSourceItem ifAbsent: absentBlock [
	
	| itemTypeAndQuerySelector |
	itemTypeAndQuerySelector := treeStructure 
		detect: [:each | aDataSourceItem isBasedOnItemType: each key ] 
		ifNone: absentBlock.
	^aDataSourceItem type 
		perform: itemTypeAndQuerySelector value 
		with: aDataSourceItem actualObject
		with: self dataSource queryEnvironment
]

{ #category : #initialization }
ClyQueryViewMorph >> refreshAsyncState [
	(self findA: ClyActivityAnimationIconMorph) ifNotNil: #delete.
	
	self areItemsLoaded ifFalse: [ 
		self addMorph: (ClyActivityAnimationIconMorph label: 'loading items') ]
]

{ #category : #controlling }
ClyQueryViewMorph >> refreshTable [
	table refresh
]

{ #category : #accessing }
ClyQueryViewMorph >> requestNavigationBy: aBlock [
	navigationSelector := aBlock
]

{ #category : #controlling }
ClyQueryViewMorph >> restoreSelectedItems [

	self initiateUIChangeBy: [ 
		selection restoreTableSelection].
	highlighting restoreTableSelection
]

{ #category : #controlling }
ClyQueryViewMorph >> selectLastItem [

	| rowsCount |
	rowsCount := self dataSource numberOfRows.
	rowsCount = 0 ifTrue: [ ^self ].
	
	self selection selectItems: {self dataSource elementAt: rowsCount}.
	UIManager default defer: [self selection ensureVisibleLastItem]
]

{ #category : #accessing }
ClyQueryViewMorph >> selection [
	"following logic fixes the case when filter is applied on table without selected items.
	In that case selectionChanged is not triggered and existing selection is not updated.
	It continue points to the old data source from the last selection update"
	self isFilterChanged ifTrue: [ 
		self initiateUIChangeBy: [self updateSelection] ].
	selection updateIfDirty.
	
	^selection
]

{ #category : #'event handling' }
ClyQueryViewMorph >> selectionChanged [
	"This method is called by two reasons:
		- user selects the item
		- user typed the filter (table is reset selection in current Fast table logic)
	The isFilterChanged condition handle last case 
	when we want to keep selection on filtered data source if it exists.
	The main complexity is how and when update desired selection instance
	which is performed by #updateSelectionForNewFilter and #updateSelection methods"
	| selectionIsChanged |
	selectionIsChanged := true.
	self changeStateBy: [		
		self isFilterChanged ifTrue: [ 
			selectionIsChanged := self updateSelectionForNewFilter.
			selectionIsChanged ifFalse: [ ^self ] "No selection change happens"].		
		selectionIsChanged ifTrue: [ self updateSelection].
		navigationSelector ifNotNil: [
			browser 
				perform: navigationSelector 
				withEnoughArguments: {self selection}].
	].
	self triggerClickCommands
]

{ #category : #initialization }
ClyQueryViewMorph >> setUpDataSource: aDataSource [
	table dataSource: aDataSource.
	table initialDataSource: nil. "We should always cleanup initial data source when set up new one. And it is required to restart filter process if it was terminated before"
	highlighting := ClyHighlightingSelection fromRoot: aDataSource items: #().
	highlighting restoreTableSelection. 
	"it is important to reset highligting before selection restore because desired selection could lead to new highlighting items"
	selection := self newSelectionWith: #().	
	aDataSource openOn: self.	
	self showDesiredSelection.
	self refreshAsyncState.
	self ensureSelectedItemIfNeeded
]

{ #category : #controlling }
ClyQueryViewMorph >> showDesiredSelection [
	
	self initiateUIChangeBy: [
		desiredSelection ifNil: [ ^selection beEmpty ].
		
		desiredSelection restoreCurrentSelection: selection]
]

{ #category : #queries }
ClyQueryViewMorph >> showQueries: queries as: aQueryResult [

	| fullQuery |
	fullQuery := ClyQuery unionFrom: queries as: aQueryResult.
	
	self showQuery: fullQuery
]

{ #category : #queries }
ClyQueryViewMorph >> showQuery: aQuery [

	| dataSource |
	self initiateUIChangeBy: [ 
		dataSource := self dataSourceClass on: aQuery.
		self dataSource: dataSource.
		self ensureSelectedItemIfNeeded].
]

{ #category : #testing }
ClyQueryViewMorph >> showsItemsFromMultipleScope [

	^self query isExecutedFromMultipleScope
]

{ #category : #testing }
ClyQueryViewMorph >> showsItemsFromQuery: aTypedQueryClass [

	^self query executesQuery: aTypedQueryClass 
]

{ #category : #testing }
ClyQueryViewMorph >> showsItemsFromScope: aTypedScopeClass [

	^self query isExecutedFromScope: aTypedScopeClass
]

{ #category : #testing }
ClyQueryViewMorph >> showsItemsOfType: itemTypeClass [

	^self query retrievesItemsOfType: itemTypeClass
]

{ #category : #accessing }
ClyQueryViewMorph >> snapshotState [
	
	| dataSourceSnapshot |
	dataSourceSnapshot := selection rootDataSource copyForBrowserStateSnapshot.
	
	^ClyQueryViewState new 
		dataSource: dataSourceSnapshot;
		selection: (selection copyForBrowserStateSnapshotOf: dataSourceSnapshot)
]

{ #category : #accessing }
ClyQueryViewMorph >> table [
	^table
]

{ #category : #controlling }
ClyQueryViewMorph >> takeKeyboardFocus [
	table takeKeyboardFocus 
]

{ #category : #accessing }
ClyQueryViewMorph >> treeStructure [
	^ treeStructure
]

{ #category : #accessing }
ClyQueryViewMorph >> treeStructure: anObject [
	treeStructure := anObject
]

{ #category : #'event handling' }
ClyQueryViewMorph >> triggerClickCommands [

	CmdClickActivation executeCommandInContext: self createSelectionContext
]

{ #category : #'event handling' }
ClyQueryViewMorph >> triggerDoubleClickCommands [

	CmdDoubleClickActivation executeCommandInContext: self createSelectionContext
]

{ #category : #controlling }
ClyQueryViewMorph >> update [

	self dataSource forceFullUpdate
]

{ #category : #controlling }
ClyQueryViewMorph >> updateSelectedItemsOf: aDataSource [

	| actualSelectionChanged |
	self initiateUIChangeBy: [ 
		actualSelectionChanged := selection updateItemsWhichBelongsTo: aDataSource.
		highlighting updateItemsWhichBelongsTo: aDataSource.
		desiredSelection ifNotNil: [
			desiredSelection updateItemsWhichBelongsTo: aDataSource.
			actualSelectionChanged := actualSelectionChanged 
				| (desiredSelection restoreCurrentSelectionAfterUpdate: selection)].
		^actualSelectionChanged]
]

{ #category : #controlling }
ClyQueryViewMorph >> updateSelection [
	| selectedItems |
	"in some conditions table returnes bad index 0 which should not happens normaly.
	Following select protects from this case"
	selectedItems := table selectedIndexes
		select: [ :i | i between: 1 and: self dataSource numberOfRows ]
		thenCollect: [ :each | self itemAt: each ].
	selection := self newSelectionWith: selectedItems.
	shouldRestoreSelection
		ifTrue: [ changesWasInitiatedByUser
				ifTrue: [ desiredSelection := selection asDesiredSelection ]
				ifFalse: [ desiredSelection
						ifNotNil: [ desiredSelection checkItemsOfCurrentSelection: selection ] ] ]
]

{ #category : #'event handling' }
ClyQueryViewMorph >> updateSelectionForNewFilter [
	"This method is supposed to update selection instance for new filtered data source.
	And it tries to recover previously selected items using desired selection.
	At the end method returns the anwer: does selection really changed
	which is true when filtered data source does not include selected items"
	| oldSelection |
	oldSelection := selection.
	
	self initiateUIChangeBy: [ 
		self updateSelection.
		(desiredSelection notNil and: [ desiredSelection isEmpty not ]) ifTrue: [
			"We should never restore empty selection when filter was changed"
			desiredSelection restoreCurrentSelection: selection]].
	
	^(selection isSameAs: oldSelection) not
]

{ #category : #'drag and drop support' }
ClyQueryViewMorph >> wantsDropPassenger: aPassenger at: aDataSourceItem [
	| context |
	context := self createSelectionContextOf: aDataSourceItem asSelection.
	
	^aPassenger canBeDroppedInContext: context
]

{ #category : #'events subscription' }
ClyQueryViewMorph >> whenDoubleClickDo: aBlock [

	table onAnnouncement: FTStrongSelectionChanged do: aBlock
]

{ #category : #'events subscription' }
ClyQueryViewMorph >> whenEnterKeyPressedDo: aBlock [

	table bindKeyCombination: Character cr asShortcut toAction: aBlock 
]

{ #category : #'events subscription' }
ClyQueryViewMorph >> whenEscapeKeyPressedDo: aBlock [

	table bindKeyCombination: Character escape asShortcut toAction: aBlock 
]

{ #category : #controlling }
ClyQueryViewMorph >> windowIsClosing [
	self closeDataSource
]
