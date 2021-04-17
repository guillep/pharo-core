"
I'm a dataSource to be used in MorphicTableAdapter to realise a TablePresenter.
I define my cells following the definition on columns (MorphicTableColumn).
I use a builder (MorphicTreeTableCellBuilder) to realise the cell content. 
"
Class {
	#name : #SpMorphicTreeTableDataSource,
	#superclass : #FTTreeDataSource,
	#traits : 'SpTMorphicTableDataSourceCommons',
	#classTraits : 'SpTMorphicTableDataSourceCommons classTrait',
	#category : #'Spec2-Adapters-Morphic-Table'
}

{ #category : #'search strategies' }
SpMorphicTreeTableDataSource class >> allItemsStrategy [

	^ SpMorphicAllItemsStrategy
]

{ #category : #'search strategies' }
SpMorphicTreeTableDataSource class >> defaultStrategy [

	^ SpMorphicVisibleItemsStrategy
]

{ #category : #'search strategies' }
SpMorphicTreeTableDataSource class >> rootsOnlyStrategy [

	^ SpMorphicRootItemsStrategy
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> allShownItems [

	^ rootItem children flatCollect: [ :e | e withExpandedChildren ].
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> buttonFor: item [

	^ (self shouldDisplayExpandableArrowFor: item) 
		ifTrue: [ item generateButton ] 
		ifFalse: [ self class emptyMorph ]
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> cellColumn: column row: rowIndex [
	| cell builder item |
	
	item := self elementAt: rowIndex.
	cell := FTIndentedCellMorph new.
	cell indentBy: (self cellIndentFor: item).
	(self isFirstColumn: column) ifTrue: [
		cell addMorphBack: (self buttonFor: item) ].

	builder := SpMorphicTreeTableCellBuilder on: self.
	builder 
		cell: cell;
		item: item data;
		visit: column model.
	
	^ cell 
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> cellIndentFor: item [ 

	^ item depth * 16
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> expandPath: anArray [

	self expandPath: anArray root: self rootItem children
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> expandPath: anArray root: nodes [ 
	| node |
	
	anArray ifEmpty: [ ^ self ].
	nodes ifEmpty: [ ^ self ].

	node := nodes at: anArray first.
	node expand.
	self expandPath: anArray allButFirst root: node children
]

{ #category : #paths }
SpMorphicTreeTableDataSource >> indexFromPath: anArray [ 

	^ anArray sum
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> indexOfItem: anItem [ 
	
	^ self allShownItems indexOf: anItem
]

{ #category : #testing }
SpMorphicTreeTableDataSource >> isFirstColumn: column [
	
	^ (table columns indexOf: column) = 1
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> itemAtIndex: anInteger [ 
	
	^ self allShownItems at: anInteger
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> itemAtPath: aPath [ 
	
	^ self itemAtPath: aPath expanding: false
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> itemAtPath: aPath expanding: shouldExpandItems [
	
	| item |
	
	(aPath isNil or: [aPath isEmpty]) ifTrue: [ ^ nil ].
	item := self rootItem.
	
	aPath do: [ :index |
		(shouldExpandItems and: [item isRoot not]) ifTrue: [ item expand ].
		item children size < index ifTrue: [ ^ nil ].		
		item := item children at: index.
	].

	^ item
]

{ #category : #'drag and drop' }
SpMorphicTreeTableDataSource >> passengerAt: rowIndex [
	"Answer 'passenger' for drag&drop operation (a passenger is the object who will travel between 
	 drag and drop). By default, passenger is same as current element"
	^ (self allShownItems at: rowIndex) data
]

{ #category : #paths }
SpMorphicTreeTableDataSource >> pathFromIndex: anInteger [ 
	| item |
	
	item := self allShownItems at: anInteger ifAbsent: [ ^ #() ].
	^ self pathOfNode: item root: rootItem
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> pathOfItem: anItem root: aNode [
	"Looks for the path of an item (contained in a node)"
	
	aNode isExpanded ifFalse: [ ^#() ].
	
	aNode children 
		detect: [ :each | each data = anItem ]
		ifFound: [ :childNode | ^ { aNode children indexOf: childNode } ].
		
	aNode children withIndexDo: [ :aChild :index | | aSubPath |
		aSubPath := self pathOfItem: anItem root: aChild.
		aSubPath ifNotEmpty: [ ^ { index } , aSubPath ] ].
	
	^ #()
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> pathOfNode: anItem root: aRoot [ 
	
	aRoot isExpanded ifFalse: [ ^#() ].
	
	(aRoot children includes: anItem)
		ifTrue: [ ^ { aRoot children indexOf: anItem } ].
		
	aRoot children withIndexDo: [ :aChild :index | | aSubPath |
		aSubPath := self pathOfNode: anItem root: aChild.
		aSubPath ifNotEmpty: [ ^ { index } , aSubPath ] ].
	
	^ #().
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> rootItem: anItem [

	super rootItem: anItem.
	self addSourceToRootItem
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> searchText: aString [

	^ (self class perform: (self searchStrategy, 'Strategy') asSymbol) 
		searchWith: aString 
		dataSource: self
]

{ #category : #testing }
SpMorphicTreeTableDataSource >> shouldDisplayExpandableArrowFor: item [
	^ (self canDisplayChildrenOf: item) and: [
			self model shouldLazilyComputeChildren
				ifTrue: [ item hasComputedChildren ]
				ifFalse: [ item hasChildren ] ]
]

{ #category : #sorting }
SpMorphicTreeTableDataSource >> sortElements: aSortFunction [

	unsortedElements ifNil: [ unsortedElements := self rootsItems ].
	self rootItem data: ((self rootItem children collect: #data) sorted: aSortFunction)
]

{ #category : #accessing }
SpMorphicTreeTableDataSource >> toString: anItem [
	"Override me if you expect something else."

	^ super toString: anItem data
]
