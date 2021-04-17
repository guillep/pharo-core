"
A base for list presenters, it defines basic functionality common to all lists.
"
Class {
	#name : #SpAbstractListPresenter,
	#superclass : #SpAbstractWidgetPresenter,
	#traits : 'SpTHaveWrappingScrollBars + SpTContextMenu',
	#classTraits : 'SpTHaveWrappingScrollBars classTrait + SpTContextMenu classTrait',
	#instVars : [
		'#selectionMode',
		'#activationBlock',
		'#activateOnSingleClick',
		'#model',
		'#itemFilter => SpObservableSlot',
		'#verticalAlignment'
	],
	#category : #'Spec2-Core-Widgets-Table'
}

{ #category : #documentation }
SpAbstractListPresenter class >> documentSections [
		
	^ OrderedDictionary newFromPairs: {
		'Examples'. self class methods select: [ :each | each protocol = self documentExamplesProtocol ].
		'API Methods'. self methods select: [ :each | each protocol = #'api' ].
		'API Selection Methods'. self methods select: [ :each | each protocol = #'api-selection' ].
		'Testing Methods'. self methods select: [ :each | each protocol = #'testing' ].
		'Events'. self methods select: [ :each | each protocol = #'api-events' ].
	 }
]

{ #category : #api }
SpAbstractListPresenter >> activateOnDoubleClick [
	"Configure the list to trigger activation on double click.
	 An element on a list can be 'activated', meaning it will trigger an event to execute an 
	 action on it. An activation is different than a selection (one can 'select' an element without 
	 activating it).
	 See `SpAbstractListPresenter>>#whenActivatedDo:`"
	
	activateOnSingleClick := false
]

{ #category : #api }
SpAbstractListPresenter >> activateOnSingleClick [
	"Configure the list to trigger activation on single click.
	 An element on a list can be 'activated', meaning it will trigger an event to execute an 
	 action on it. An activation is different than a selection (one can 'select' an element without 
	 activating it).
	 See `SpAbstractListPresenter>>#whenActivatedDo:`"
	
	activateOnSingleClick := true
]

{ #category : #testing }
SpAbstractListPresenter >> activatesOnDoubleClick [
	"Answer true if activation event is triggered on double click"
	
	^ activateOnSingleClick not
]

{ #category : #testing }
SpAbstractListPresenter >> activatesOnSingleClick [
	"Answer true if activation event is triggered on single click"
	
	^ activateOnSingleClick
]

{ #category : #api }
SpAbstractListPresenter >> beMultipleSelection [
	"Enable multiple selection."

	self selectionMode: (SpMultipleSelectionMode on: self)
]

{ #category : #api }
SpAbstractListPresenter >> beSingleSelection [
	"Enable single selection (this is the default)."
	
	self selectionMode: (SpSingleSelectionMode on: self)
]

{ #category : #simulation }
SpAbstractListPresenter >> clickAtIndex: anIndex [

	self selectIndex: anIndex.

	activateOnSingleClick ifFalse: [ ^ self ].
	self doActivateAtIndex: anIndex
]

{ #category : #simulation }
SpAbstractListPresenter >> clickItem: anInteger [ 
	
	self selectIndex: anInteger
]

{ #category : #private }
SpAbstractListPresenter >> disableActivationDuring: aBlock [
	| oldActivate |
	
	oldActivate := activationBlock.
	activationBlock := [ ].
	aBlock ensure: [ 
		activationBlock := oldActivate ]
]

{ #category : #TOREMOVE }
SpAbstractListPresenter >> disableFilter [
	self itemFilter: nil
]

{ #category : #private }
SpAbstractListPresenter >> doActivateAtIndex: anIndex [

	"Activate only if there is an item at that position"
	self model at: anIndex ifAbsent: [ ^ self ].
	
	activationBlock cull: ((SpSingleSelectionMode on: self)
		basicSelectIndex: anIndex;
		yourself)
]

{ #category : #simulation }
SpAbstractListPresenter >> doubleClickAtIndex: anIndex [
	self selectIndex: anIndex.
	
	activateOnSingleClick ifTrue: [ ^ self ].
	self doActivateAtIndex: anIndex
]

{ #category : #initialization }
SpAbstractListPresenter >> initialize [

	super initialize.
	self initializeTHaveWrappingScrollBars.
	
	activationBlock := [ ].
	verticalAlignment := SpVerticalAlignment new.

	self withScrollBars.
	self model: 	self newEmptyModel.

	self beSingleSelection.
	self activateOnDoubleClick.

	self registerEvents
]

{ #category : #testing }
SpAbstractListPresenter >> isMultipleSelection [
	"Answer true if list accepts multiple selection"
	
	^ selectionMode isMultipleSelection
]

{ #category : #private }
SpAbstractListPresenter >> itemAt: index [ 
	"If there is an adapter the widget items indexes can be different thant the model items indexes, 
	e.g. when the sort by a column is activated. In this case, ask the adapter to get the element 
	displayed at index."

	^ self adapter 
		ifNotNil: [ :anAdapter | anAdapter elementAt: index ]
		ifNil: [ self model at: index ]
]

{ #category : #private }
SpAbstractListPresenter >> itemAtPath: anArray [
	"This is to provide polymorphism with SpTreeTablePresentrer"

	^ self itemAt: anArray first
]

{ #category : #TOREMOVE }
SpAbstractListPresenter >> itemFilter [
	^ itemFilter
]

{ #category : #TOREMOVE }
SpAbstractListPresenter >> itemFilter: aBlock [
	"This block will be used with the search field of the list to filter it with the user input dynamically."

	itemFilter := aBlock
]

{ #category : #api }
SpAbstractListPresenter >> items [
	"Answer the items of the list"
	
	^ self model collection
]

{ #category : #api }
SpAbstractListPresenter >> items: aSequenceableCollection [
	"Set the items of the list.
	`aSequenceableCollection` is a collection of your domain specific items.
	This resets the collection model and unselects any previously selected item."
	
	model collection: aSequenceableCollection.
	self unselectAll
]

{ #category : #private }
SpAbstractListPresenter >> itemsAt: aCollectionOfIndex [
	^ aCollectionOfIndex collect: [ :anIndex | self itemAt: anIndex ]
]

{ #category : #api }
SpAbstractListPresenter >> listSize [
	"Return the size of the item list contained in model (see `SpAbstractListPresenter>>#model`)"

	self flag: #TODO. "Maybe this should be called #itemsSize? (since we set #items: and not #list: )"
	^ self model size
]

{ #category : #TOREMOVE }
SpAbstractListPresenter >> matchBeginOfString [
	self itemFilter: [ :each :pattern | each asLowercase beginsWith: pattern asLowercase ]
]

{ #category : #TOREMOVE }
SpAbstractListPresenter >> matchSubstring [
	self itemFilter: [ :each :pattern | each asLowercase includesSubstring: pattern asLowercase ]
]

{ #category : #api }
SpAbstractListPresenter >> model [
	"Answer the model for this list. 
	 It is tipically, an instance of `SpCollectionListModel`."
	
	^ model
]

{ #category : #api }
SpAbstractListPresenter >> model: aModel [
	"Sets the model used to feed the list presenter with elements of the list. 
	 It is tipically an instance of `SpCollectionListModel`."
	
	model := aModel.
	model whenChangedDo: [ 
		self withAdapterDo: [ :anAdapter | anAdapter refreshList ] ]
]

{ #category : #private }
SpAbstractListPresenter >> newEmptyModel [

	^ SpCollectionListModel on: #()
]

{ #category : #api }
SpAbstractListPresenter >> refresh [
	"Forces a refresh of the list. 
	 This is useful when some model contents has changed, but we do not want to reset the whole list 
	 (and losing selections with it)"

	self withAdapterDo: [ :anAdapter | anAdapter refreshList ]
]

{ #category : #initialization }
SpAbstractListPresenter >> registerEvents [

	self whenSelectionModeChangedDo: [ :selection | 
		self withAdapterDo: [ :anAdapter | anAdapter refreshWidgetSelection ] ].
	self whenMenuChangedDo: [ 
		self withAdapterDo: [ :anAdapter | anAdapter updateMenu ] ]
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectAll [
	"Select all items in the list or table. 
	 It does not triggers activation event."
	
	self selection selectAll
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectFirst [
	"Select first element in list. 
	 Useful to avoid selecting by index."
	
	^ self selectIndex: 1
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectIndex: anInteger [ 
	"Select item at position `anInteger`.
	 Selection will not scroll the presenter view to show selected element."
	
	self selectionMode selectIndex: anInteger
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectIndex: anIndex scrollToSelection: shouldScrollToSelection [
	"Select item at position `anInteger`.
	 If `shouldScrollToSelection` is true, selection will scroll the presenter view 
	 to show selected element."

    self selectIndex: anIndex.
    shouldScrollToSelection ifTrue: [ 
        self verticalAlignment desiredVisibleRow: anIndex ].
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectIndexes: aCollectionOfIndexes [
	"Select items at positions included in `aCollectionOfIndexes`.
	 NOTE: in single selection mode, first element of `aCollectionOfIndexes` will be selected.
	 Selection will not scroll the presenter view to show selected(s) element(s)."

	self selectionMode selectIndexes: aCollectionOfIndexes
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectIndexes: aCollectionOfIndexes scrollToSelection: shouldScrollToSelection [
	"Select items at positions included in `aCollectionOfIndexes`.
	 NOTE: in single selection mode, first element of `aCollectionOfIndexes` will be selected.
	 If `shouldScrollToSelection` is true, selection will scroll the presenter view 
	 to show first selected element."
  
  self selectIndexes: aCollectionOfIndexes.
    shouldScrollToSelection ifTrue: [ 
        self verticalAlignment desiredVisibleRow: aCollectionOfIndexes first ].
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectItem: anItem [ 
	"Select `anItem` if it is included in model list.
	 It does not scrolls to selected element."
	
	self selectionMode selectItem: anItem
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectItems: aCollection [
	"Select items included in `aCollection` if they are included in model list.
	 NOTE: In single selection mode it will select the first element of `aCollection` 
	 It does not scrolls to selected element."

	self selectionMode selectItems: aCollection
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectedItem [
	"Return selected item."

	^ self selection selectedItem
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectedItems [
	"Return all the selected items in the case of a multiple selection list"

	^ self selection selectedItems
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectedItemsSorted [
	"Return all the selected items sorted by their index"

	^ self itemsAt: self selection selectedIndexes sort
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selection [
	"Answer the selection object (an instance of `SpSingleSelectionMode` or `SpMultipleSelectionMode`).
	 This is not the item selected, but the selection container (it may contain one or many selected 
	 items)"
	
	^ selectionMode
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectionMode [
	"Answer the selection object (an instance of `SpSingleSelectionMode` or `SpMultipleSelectionMode`).
	 This is not the item selected, but the selection container (it may contain one or many selected 
	 items).
	 This is the same as `SpAbstractListPresenter>>#selection`"
	
	^ selectionMode
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> selectionMode: aMode [
	
	selectionMode ifNotNil: [ 
		selectionMode transferSubscriptionsTo: aMode ].
	selectionMode := aMode
]

{ #category : #api }
SpAbstractListPresenter >> sortingBlock [
	"Answer the sorting block defined to sort the model list.
	 `aBlock` is a two arguments block that answer a boolean (e.g. `[ :a :b | a < b ]`) 
	 or a `SortFunction`"

	self flag: #TODO. "Find a better name than 'sortingBlock'"
	^ self model sortingBlock
]

{ #category : #api }
SpAbstractListPresenter >> sortingBlock: aBlock [
	"Set sorting block to sort the model list.
	 `aBlock` is a two arguments block that answer a boolean (e.g. `[ :a :b | a < b ]`) 
	 or a `SortFunction`"

	self model sortingBlock: aBlock
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> unselectAll [
	"Remove all selections"
	
	self selection unselectAll
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> unselectIndex: anInteger [ 
	"Remove selection of element at index `anInteger`"
	
	self selection unselectIndex: anInteger
]

{ #category : #'api-selection' }
SpAbstractListPresenter >> unselectItem: anObject [ 
	"Remove selection of element `anObject`"
	
	self selection unselectItem: anObject
]

{ #category : #api }
SpAbstractListPresenter >> updateItemsKeepingSelection: aCollection [
	"Update list items keeping current selection. 
	 WARNING: aCollection must includes the elements selected."
	
	self disableActivationDuring: [ 
		| items |
		items := self selection selectedItems.
		self items: aCollection.
		self selectItems: items ]
]

{ #category : #accessing }
SpAbstractListPresenter >> verticalAlignment [

	^ verticalAlignment
]

{ #category : #'api-events' }
SpAbstractListPresenter >> whenActivatedDo: aBlock [
	"Inform when an element has been 'activated'. 
	 `aBlock` receives one argument (a selection object, see `SpAbstractSelectionMode`)"
	
	activationBlock := aBlock
]

{ #category : #TOREMOVE }
SpAbstractListPresenter >> whenItemFilterBlockChangedDo: aBlock [

	self property: #itemFilter whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpAbstractListPresenter >> whenModelChangedDo: aBlock [
	"Inform when model has been changed (see `SpAbstractListPresenter>>#model:`. 
	 `aBlock` receive 3 optional arguments: 
	 - new value 
	 - old value 
	 - announcement triggered"

	model whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpAbstractListPresenter >> whenNoneSelectedDo: aBlock [
	"Inform when the list has clean selection (there are no items selected).
	 `aBlock` receives zero arguments"

	self whenSelectionChangedDo: [ :selection | 
		selection selectedItem 
			ifNil: [ aBlock value ] ]
]

{ #category : #'api-events' }
SpAbstractListPresenter >> whenSearchEnabledChangedDo: aBlock [
	"Inform when search enabled/disabled has changed.
	`aBlock` receives zero arguments."
	
	self property: #searchEnabled whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpAbstractListPresenter >> whenSelectedDo: aBlock [
	"Inform when an item was selected (a real object in the items list).
	 `aBlock` receives one argument (the new selected element)"

	self whenSelectionChangedDo: [ :selection | 
		selection selectedItem 
			ifNotNil: [ :item | aBlock value: item ] ]
]

{ #category : #'api-events' }
SpAbstractListPresenter >> whenSelectionChangedDo: aBlock [
	"Inform when there are changes in selection.
	This method works for all selection modes (single, multiple and no selection).
	`aBlock` receives an optional argument with the selection object."

	self selection whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpAbstractListPresenter >> whenSelectionModeChangedDo: aBlock [
	"Inform when selection mode (single/multiple) changed. 
	 `aBlock` receives zero arguments."

	selectionMode whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpAbstractListPresenter >> whenSortingBlockChangedDo: aBlock [
	"Inform when sorting block changed. 
	 `aBlock` receives one argument with the new sort function (or block with two arguments).
	 See `SpAbstractListPresenter>>#sortingBlock`"

	self model whenSortingBlockChangedDo: aBlock
]
