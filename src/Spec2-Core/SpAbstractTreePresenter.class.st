"
A base for tree presenters, it defines basic functionality common to all trees.
"
Class {
	#name : #SpAbstractTreePresenter,
	#superclass : #SpAbstractWidgetPresenter,
	#traits : 'SpTHaveWrappingScrollBars + SpTContextMenu + SpTSearchable',
	#instVars : [
		'#roots => SpObservableSlot',
		'#childrenBlock',
		'#activateOnSingleClick',
		'#activationBlock',
		'#selectionMode',
		'#verticalAlignment'
	],
	#category : #'Spec2-Core-Widgets-Tree'
}

{ #category : #api }
SpAbstractTreePresenter >> activateOnDoubleClick [
	"Configure the list to trigger activation on double click.
	 An element on a list can be 'activated', meaning it will trigger an event to execute an 
	 action on it. An activation is different than a selection (one can 'select' an element without 
	 activating it).
	 See `SpTreeTablePresenter>>#whenActivatedDo:`"
	
	activateOnSingleClick := false
]

{ #category : #api }
SpAbstractTreePresenter >> activateOnSingleClick [
	"Configure the list to trigger activation on single click.
	 An element on a list can be 'activated', meaning it will trigger an event to execute an 
	 action on it. An activation is different than a selection (one can 'select' an element without 
	 activating it).
	 See `SpTreeTablePresenter>>#whenActivatedDo:`"
	
	activateOnSingleClick := true
]

{ #category : #testing }
SpAbstractTreePresenter >> activatesOnDoubleClick [
	"Answer true if activation event is triggered on double click"
	
	^ activateOnSingleClick not
]

{ #category : #testing }
SpAbstractTreePresenter >> activatesOnSingleClick [
	"Answer true if activation event is triggered on single click"

	^ activateOnSingleClick
]

{ #category : #api }
SpAbstractTreePresenter >> beMultipleSelection [
	"Enable multiple selection."

	self selectionMode: (SpTreeMultipleSelectionMode on: self)
]

{ #category : #api }
SpAbstractTreePresenter >> beSingleSelection [
	"Enable single selection (this is the default)."
	
	self selectionMode: (SpTreeSingleSelectionMode on: self)
]

{ #category : #private }
SpAbstractTreePresenter >> children [

	^ childrenBlock
]

{ #category : #api }
SpAbstractTreePresenter >> children: aBlock [
	"Set a block to answer the children of a node when it is expanded.
	 `aBlock` receives one argument, the node element to expand.
	 If there are no children to answer, `aBlock` needs to answer an empty collection."		

	childrenBlock := aBlock
]

{ #category : #private }
SpAbstractTreePresenter >> childrenFor: anObject [ 

	^ self children value: anObject
]

{ #category : #simulation }
SpAbstractTreePresenter >> clickAtPath: aPath [

	self selectPath: aPath.

	activateOnSingleClick ifFalse: [ ^ self ].
	self doActivateAtPath: aPath
]

{ #category : #private }
SpAbstractTreePresenter >> disableActivationDuring: aBlock [
	| oldActivate |
	
	oldActivate := activationBlock.
	activationBlock := [ ].
	aBlock ensure: [ 
		activationBlock := oldActivate ]
]

{ #category : #private }
SpAbstractTreePresenter >> doActivateAtPath: aPath [
	"Activate only if there is an item at that position"

	self itemAtPath: aPath ifAbsent: [ ^ self ].
	activationBlock cull: ((SpTreeSingleSelectionMode on: self)
		selectPath: aPath;
		yourself)
]

{ #category : #simulation }
SpAbstractTreePresenter >> doubleClickAtPath: aPath [
	self selectPath: aPath.
	
	activateOnSingleClick ifTrue: [ ^ self ].
	self doActivateAtPath: aPath
]

{ #category : #api }
SpAbstractTreePresenter >> expandAll [
	"Expand all nodes of the tree. 
	 WARNING: If your tree is big, this operation can be slow."

	self withAdapterPerformOrDefer: [ :anAdapter | 
		anAdapter expandAll ]
]

{ #category : #api }
SpAbstractTreePresenter >> expandPath: aPath [
	"Expand the tree path.
	`aPath` is the path to expand. A path is an array of node indexes (e.g. #(1 2 3))"

	self withAdapterPerformOrDefer: [ :anAdapter |
		anAdapter expandPath: aPath ]
]

{ #category : #api }
SpAbstractTreePresenter >> expandRoots [
	"Expand all roots of the tree"

	self withAdapterPerformOrDefer: [ :anAdapter | 
		anAdapter expandRoots ]
]

{ #category : #initialization }
SpAbstractTreePresenter >> initialize [
	
	super initialize.
	self initializeTSearchable.
	self initializeTHaveWrappingScrollBars
]

{ #category : #private }
SpAbstractTreePresenter >> itemAt: index of: anArray then: path [
	"dives into elements of tree to find the one that corresponds to path"
	| element |
	
	element := anArray at: index.
	^ path 
		ifNotEmpty: [ 
			self 
				itemAt: path first 
				of: (self childrenFor: element) 
				then: path allButFirst ]
		ifEmpty: [ 
			element ]
]

{ #category : #private }
SpAbstractTreePresenter >> itemAtPath: anArray [
	
	self withAdapterDo: [ :anAdapter | 
		^ anAdapter itemAtPath: anArray ].

	^ self 
		itemAt: anArray first
		of: self roots
		then: anArray allButFirst
]

{ #category : #private }
SpAbstractTreePresenter >> itemAtPath: anArray ifAbsent: aBlock [
	^ [ self itemAtPath: anArray ]
		on: SubscriptOutOfBounds
		do: [ aBlock value ]
]

{ #category : #api }
SpAbstractTreePresenter >> items: aCollection [
	"Set the roots of a tree. This is a convenience method, synonym of `SpTreePresenter>>#roots:`"

	self roots: aCollection
]

{ #category : #private }
SpAbstractTreePresenter >> pathIndexOf: anArrayOfElements [

	^ self 
		pathIndexOf: anArrayOfElements 
		in: self roots
]

{ #category : #private }
SpAbstractTreePresenter >> pathIndexOf: pathArray in: aCollection [ 
	| pathElement |
	
	pathElement := { aCollection indexOf: pathArray first }.
	pathArray size = 1 ifTrue: [ ^ pathElement ].
	
	^ pathElement, (self 
		pathIndexOf: pathArray allButFirst
		in: (self childrenFor: pathArray first))

]

{ #category : #api }
SpAbstractTreePresenter >> refresh [
	"Forces a refresh of the tree. 
	 This is useful when some model contents has changed, but we do not want to reset the whole list 
	 (and losing selections with it)"

	self withAdapterDo: [ :anAdapter | anAdapter refreshTree ]
]

{ #category : #initialization }
SpAbstractTreePresenter >> registerEvents [

	self whenMenuChangedDo: [ 
		self withAdapterDo: [ :anAdapter | anAdapter updateMenu ] ]
]

{ #category : #api }
SpAbstractTreePresenter >> roots [
	"Answer the roots of the tree"

	^ roots
]

{ #category : #api }
SpAbstractTreePresenter >> roots: aCollection [
	"Set the roots of the tree table.
	 This is the starting point from where the whole tree will be shown."

	roots := aCollection.
	self selection clearSelection
]

{ #category : #private }
SpAbstractTreePresenter >> searchValueOf: item [ 

	^ item asString
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> selectItem: anItem [
	"Select `anItem` if it is included in model list.
	 It does not scrolls to selected element."

	self selection selectItem: anItem
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> selectItems: aListOfItem [
	"Select items included in `aCollection` if they are included in model list.
	 NOTE: In single selection mode it will select the first element of `aCollection` 
	 It does not scrolls to selected element."

	self selection selectItems: aListOfItem
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> selectPath: aPath [
	"Selects element in `aPath`
	`aPath` is the path to select. A path is an array of node indexes (e.g. #(1 2 3)).
	 It does not scrolls to selected element."

	self selection selectPath: aPath
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> selectPath: aPath scrollToSelection: shouldScrollToSelection [
	"Selects element in `aPath`
	`aPath` is the path to select. A path is an array of node indexes (e.g. #(1 2 3)).
	 If `shouldScrollToSelection` is true, it will scroll to selected element.
	 IMPORTANT: Scrolling to selection just has sense when the widget is already shown, because before it 
	 is displayed it does not has real bounds. In morphic (and gtk) it has a minimal extent assigned, 
	 but that will change as soon as the widget is inserted in a container and the container applies its 
	 layout."

	self withAdapterPerformOrDefer: [ :anAdapter |
		self selectPath: aPath.
		shouldScrollToSelection ifTrue: [ adapter scrollToSelection ] ]
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> selectPathByItems: pathArray [

	self selectPathByItems: pathArray scrollToSelection: false
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> selectPathByItems: pathArray scrollToSelection: aBoolean [
	"IMPORTANT: Scrolling to selection just has sense when the widget is already shown, because before it 
	 is displayed it does not has real bounds. In morphic (and gtk) it has a minimal extent assigned, 
	 but that will change as soon as the widget is inserted in a container and the container applies its 
	 layout."
	| pathIndexes |

	pathIndexes := self pathIndexOf: pathArray.
	pathIndexes size > 1 ifTrue: [ 
		self expandPath: pathIndexes allButLast ].
	self 
		selectPath: pathIndexes
		scrollToSelection: aBoolean
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> selectPaths: pathArray [
	"Selects all elements in `pathsArray``
	`pathsArray` is an array of paths. A path is an array of node indexes (e.g. #(1 2 3))"

	self selection selectPaths: pathArray
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> selectedItem [
	"Return selected item."
	
	^ self selection selectedItem
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> selectedItems [
	"Return all the selected items in the case of a multiple selection list"
	
	^ self selection selectedItems
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> selection [
	"Answer the selection object (an instance of `SpSingleSelectionMode` or `SpMultipleSelectionMode`).
	 This is not the item selected, but the selection container (it may contain one or many selected 
	 items)"
	
	^ selectionMode value
]

{ #category : #private }
SpAbstractTreePresenter >> selectionMode: aMode [
	
	selectionMode ifNotNil: [ 
		selectionMode transferSubscriptionsTo: aMode ].
	selectionMode := aMode
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> unselectAll [ 
	"Remove all selections"

	self selection unselectAll
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> unselectItem: anItem [
	"Remove selection of element `anItem`"

	self selection unselectItem: anItem
]

{ #category : #'api-selection' }
SpAbstractTreePresenter >> unselectPath: aPath [
	"Unselects element in `aPath`
	`aPath` is the path to select. A path is an array of node indexes (e.g. #(1 2 3))"

	self selection unselectPath: aPath
]

{ #category : #api }
SpAbstractTreePresenter >> updateRootsKeepingSelection: aCollection [ 
	"Update tree roots keeping current selection. 
	 WARNING: aCollection must includes the elements selected."

	self disableActivationDuring: [ 
		| selectedPaths |
		
		selectedPaths := self selection selectedPaths.
		self roots: aCollection.
		selectedPaths ifNotEmpty: [ 
			self selectPaths: selectedPaths ] ]
]

{ #category : #private }
SpAbstractTreePresenter >> verticalAlignment [
	^ verticalAlignment
]

{ #category : #'api-events' }
SpAbstractTreePresenter >> whenActivatedDo: aBlock [
	"Inform when an element has been 'activated'. 
	 `aBlock` receives one argument (a selection object, see `SpAbstractSelectionMode`)"

	activationBlock := aBlock
]

{ #category : #'api-events' }
SpAbstractTreePresenter >> whenMultiSelectionChangedDo: aBlockClosure [ 
	"Inform when selection mode has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"
	
	selectionMode whenChangedDo: aBlockClosure 
]

{ #category : #'api-events' }
SpAbstractTreePresenter >> whenRootsChangedDo: aBlockClosure [ 
	"Inform when roots have changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"

	self property: #roots whenChangedDo: aBlockClosure
]

{ #category : #'api-events' }
SpAbstractTreePresenter >> whenSelectedIndexChangedDo: aBlock [ 
	"Inform when selected index has changed. 
	 `aBlock` receives one optional argument (the new element)."
	
	self whenSelectionChangedDo: [ :selection | 
		aBlock cull: selection first ]
]

{ #category : #'api-events' }
SpAbstractTreePresenter >> whenSelectedItemChangedDo: aBlockClosure [ 
	"Inform when selected index has changed. 
	 `aBlock` receives one optional argument (the new element)."
	
	self whenSelectionChangedDo: [ :selection | aBlockClosure cull: selection second ]
]

{ #category : #'api-events' }
SpAbstractTreePresenter >> whenSelectionChangedDo: aBlock [ 
	"Inform when selection has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"
	
	self selection whenChangedDo: [ aBlock cull: selectionMode ]
]

{ #category : #'api-events' }
SpAbstractTreePresenter >> whenShowColumnHeadersChangedDo: aBlock [ 
	"Inform when showColumnHeaders property has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"
	
	self property: #showColumnHeaders whenChangedDo: aBlock 
]
