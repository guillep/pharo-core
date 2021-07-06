"
I am a root of fast table data source classes which adopt Calypso query result to FastTable interface.

My subclasses represent concrete kind of underlying tree structure: all items can be initialy expanded or initialy collapsed.
To create my instances use following expression:
	dataSource := ClyCollapsedDataSource on: aQuery.
It just creates instance of data source without executing given query.
Query is opened by ClyQueryView when you pass data source to it: 
	queryView dataSource: aDataSource 
It ask data source to open for itself:
	dataSource openOn: queryView
It executes the query and retrieves cursor to access result items in optimized way.
Also it subscribes on result changes. So the query view is updated when result is changed.
When data source is not needed anymore it should be closed:
	dataSource close

I represent actual elements of fast table by ClyDataSourceItem.
	dataSource elementAt: 1 ""=>aDataSourceItem""  
Management of children is implemented by my subclasses. According to type of tree structure they implement following methods: 
- numberOfRows
- elementAt: rowIndex
- globalPositionOf: childDataSourceItem
- countChildrenOf: aDataSourceItem
- isItemHasChildren: aDataSourceItem
- definesChildren
- collapse: aDataSourceItem
- expand: aDataSourceItem
- isExpanded: aDataSourceItem
- updateExpandingItems
Children are represented by data sources too. My parentItem and depth variables point to the position in full tree.
You can ask global position in the tree using: 
	dataSource globalPositionOf: childDataSourceItem
It should return global row index in the table of given children item.

I implement query interface to find items
- findItemsWhere: conditionBlock 
- findItemsWith: actualObjects 
- findItemsSimilarTo: dataSourceItems

My instances are subscribed on ClyEnvironmentChanged event which happen when underlying query result is changed.
In case of the event I update my children structure and refresh table:
- itemsChanged
Update is performed in special logic to prevent multiple updates during complex system changes.
First I check if I am already dirty. In that case I do nothing.
Otherwise I mark myself as dirty and defer actual update using UpdateScheduler which performs update in low priority process when there is a time. So if complex system change is initiated from UI operation (which is common scenario) I will be updated only when full operation will be finished. And it will be always single update independently how many changes operation produces with the system. 
For details look at ClyDataSourceUpdateScheduler comments.

Internal Representation and Key Implementation Points.

    Instance Variables
	query:		<ClyQuery>
	queryView:		<ClyQueryView>
	itemCursor:		<ClyBrowserQueryCursor>
	parentItem:		<ClyDataSourceItem>
	depth:		<Integer>
	dirty: <Boolean>
	lastFilteredDataSource: <ClyDataSource>
"
Class {
	#name : #ClyDataSource,
	#superclass : #FTDataSource,
	#instVars : [
		'query',
		'itemCursor',
		'depth',
		'parentItem',
		'lastFilteredDataSource',
		'queryView',
		'dirty'
	],
	#classVars : [
		'UpdateScheduler'
	],
	#category : #'Calypso-Browser-DataSource'
}

{ #category : #'instance creation' }
ClyDataSource class >> empty [

	^ClyCollapsedDataSource on: ClyUnknownQuery instance
]

{ #category : #'instance creation' }
ClyDataSource class >> on: aQuery [
	^self new 
		query: aQuery
]

{ #category : #'scheduling updates' }
ClyDataSource class >> scheduleUpdateOf: aDataSource [

	UpdateScheduler ifNil: [ UpdateScheduler := ClyDataSourceUpdateScheduler new ].
	
	UpdateScheduler register: aDataSource
]

{ #category : #accessing }
ClyDataSource >> allElements [
	^(1 to: self numberOfRows) collect: [ :i | 
		self elementAt: i] 
]

{ #category : #accessing }
ClyDataSource >> cellColumn: column row: rowIndex [

	| item |
	item := self elementAt: rowIndex.
	^column createCellFor: item in: queryView 
]

{ #category : #controlling }
ClyDataSource >> close [
	lastFilteredDataSource ifNotNil: [ 
		lastFilteredDataSource close].
	
	itemCursor := itemCursor close
]

{ #category : #controlling }
ClyDataSource >> collapse: aDataSourceItem [
	self subclassResponsibility 
]

{ #category : #copying }
ClyDataSource >> copyForBrowserStateSnapshot [

	^self copy
		initializeForBrowserStateSpanshot;
		yourself
]

{ #category : #accessing }
ClyDataSource >> countChildrenOf: aDataSourceItem [
	self subclassResponsibility 
]

{ #category : #private }
ClyDataSource >> createElementWith: anEnvironmentItem [

	^self 
		findCachedElementWith: anEnvironmentItem 
		ifAbsent: [ ClyDataSourceItem of: self value: anEnvironmentItem]
]

{ #category : #testing }
ClyDataSource >> definesChildren [
	self subclassResponsibility 
]

{ #category : #accessing }
ClyDataSource >> depth [
	^ depth
]

{ #category : #accessing }
ClyDataSource >> depth: anObject [
	depth := anObject
]

{ #category : #testing }
ClyDataSource >> doesItemHaveChildren: aDataSourceItem [
	self subclassResponsibility 
]

{ #category : #'drag and drop' }
ClyDataSource >> dragTransferType [
	^#CommanderDragAndDrop
]

{ #category : #'drag and drop' }
ClyDataSource >> dropElements: aPassenger index: rowIndex [
	| dropTargetItem |
	dropTargetItem := self elementAt: rowIndex.
	
	^queryView dropPassenger: aPassenger at: dropTargetItem
]

{ #category : #accessing }
ClyDataSource >> elementAt: rowIndex [
	self subclassResponsibility 
]

{ #category : #controlling }
ClyDataSource >> expand: aDataSourceItem [
	self subclassResponsibility 
]

{ #category : #controlling }
ClyDataSource >> expansionChanged [
	queryView restoreSelectedItems.
	self tableRefresh.
	self table resetFunction
]

{ #category : #private }
ClyDataSource >> findCachedElementWith: anEnvironmentItem ifAbsent: absentBlock [
	self subclassResponsibility 
]

{ #category : #accessing }
ClyDataSource >> findDataSourceSameAs: aDataSource ifNone: noneBlock [
	^(self isSameAs: aDataSource) 
		ifTrue: [ ^self ]
		ifFalse: noneBlock

]

{ #category : #queries }
ClyDataSource >> findItemsSimilarTo: dataSourceItems [

	| foundItems relatedItems |
	relatedItems := dataSourceItems 
		select: [ :each | self isBasedOnQueryOf: each type ]
		thenCollect: [ :each | each browserItem ].
	foundItems := self itemCursor findItemsSimilarTo: relatedItems.
	^foundItems collect: [:each | self createElementWith: each ]
]

{ #category : #queries }
ClyDataSource >> findItemsWhere: conditionBlock [

	| foundItems |
	foundItems := self itemCursor findItemsWhere: conditionBlock.

	^foundItems collect: [:each | self createElementWith: each ]
]

{ #category : #queries }
ClyDataSource >> findItemsWith: actualObjects [

	| foundItems |
	foundItems := self itemCursor findItemsWith: actualObjects.

	^foundItems select: #notNil thenCollect: [:each | 
		self createElementWith: each ]
]

{ #category : #controlling }
ClyDataSource >> forceFullUpdate [

	itemCursor forceFullUpdate
]

{ #category : #accessing }
ClyDataSource >> getMetaProperty: aPropertyClass [
	^self itemCursor getMetaProperty: aPropertyClass
]

{ #category : #accessing }
ClyDataSource >> globalPositionOf: childDataSourceItem [
	self subclassResponsibility 
]

{ #category : #testing }
ClyDataSource >> hasMetaProperty: aPropertyClass [

	^self itemCursor hasMetaProperty: aPropertyClass
]

{ #category : #initialization }
ClyDataSource >> initialize [
	super initialize.
	query := ClyUnknownQuery instance.
	itemCursor := ClyClosedBrowserCursor instance.
	depth := 0.
	dirty := false
]

{ #category : #copying }
ClyDataSource >> initializeForBrowserStateSpanshot [
	table := nil.
	queryView := nil.	
	itemCursor := ClyClosedBrowserCursor instance.	
	lastFilteredDataSource := nil.
	dirty := false.
]

{ #category : #testing }
ClyDataSource >> isBasedOn: aQuery [

	^query = aQuery
]

{ #category : #testing }
ClyDataSource >> isBasedOnQueryOf: itemTypeClass [

	^query retrievesItemsOfType: itemTypeClass
]

{ #category : #testing }
ClyDataSource >> isClosed [
	^itemCursor == ClyClosedBrowserCursor instance
]

{ #category : #testing }
ClyDataSource >> isDirty [
	^dirty
]

{ #category : #testing }
ClyDataSource >> isEmpty [
	^self itemCursor itemCount = 0
]

{ #category : #testing }
ClyDataSource >> isExpanded: aDataSourceItem [
	self subclassResponsibility 
]

{ #category : #testing }
ClyDataSource >> isInSameStateAs: anotherDataSource [

	^self isSameAs: anotherDataSource
	 
]

{ #category : #testing }
ClyDataSource >> isParentCollapsed [
	^self isParentExpanded not
]

{ #category : #testing }
ClyDataSource >> isParentExpanded [
	parentItem ifNil: [ ^true ].
	^parentItem isExpanded
]

{ #category : #testing }
ClyDataSource >> isParentRemoved [
	parentItem ifNil: [ ^false ].
	^parentItem isRemoved
]

{ #category : #testing }
ClyDataSource >> isRoot [
	^parentItem isNil
]

{ #category : #testing }
ClyDataSource >> isSameAs: anotherDataSource [

	self class == anotherDataSource class ifFalse: [ ^false ].
	
	^self isBasedOn: anotherDataSource query
]

{ #category : #accessing }
ClyDataSource >> itemCursor [
	dirty ifTrue: [ self runUpdate ].
	^itemCursor 
]

{ #category : #controlling }
ClyDataSource >> itemsChanged [
	"Method is called when underlying query result was changed.
	In that case we implement lazy updating 
	when we only mark data source as dirty 
	and defer actual update for future processing by next UI iteration.
	It allows to ensure only update of UI despite of multiple system changes
	when they are happen during single UI command.
	At the and it optimizes UI reaction on system changes and makes UI smooth.
	Notice that update (#runUpdate) can be forced by user 
	when he manually requests operations with data source.
	In that case deferred update is skipped 
	because dirty flag is reset during processing (look at #runUpdate)"
	dirty ifTrue: [ ^self ].
	dirty := true.
	self scheduleUpdate
]

{ #category : #'context menu' }
ClyDataSource >> menuColumn: column row: rowIndex [
	
	^queryView menuColumn: column row: rowIndex
]

{ #category : #queries }
ClyDataSource >> newDataSourceMatching: anItemFilter [
	"IMPORTANT: DO NOT CALL IT FROM THE UI PROCESS"
	"Any data source instance should be closed after usage.
	Problem that filtered data sources are managed out of the application, internally inside FastTable.
	So this method is supposed to be called by fast table to create filtered data source 
	which will be not shared to any other users.
	And to close retrieved data source together with original one (self) it will keep reference to it.
	And every new filter request will close existing filtered data source"
	lastFilteredDataSource ifNotNil: [lastFilteredDataSource close].
	self isClosed ifTrue: [
		"This is hackish solution to the current fast table problem with filter process.
		Filter process is not managed by anybody 
		and will continue work after table is removed from the world"
		(Processor activeProcess == UIManager default uiProcess) ifTrue: [ 
			self error: 'Should not happens'].
		^Processor terminateActive].
	lastFilteredDataSource := self class on: (query filteredBy: anItemFilter).
	lastFilteredDataSource openOn: queryView.
	^lastFilteredDataSource
]

{ #category : #accessing }
ClyDataSource >> newSelectionWith: dataSourceItems [
	^ClyDataSourceSelection fromRoot: self items: dataSourceItems 
]

{ #category : #controlling }
ClyDataSource >> openOn: aQueryView [
	
	self isClosed ifFalse: [ self close ].

	queryView := aQueryView.	
	table := aQueryView table.
	itemCursor := query openBrowserCursorFor: self.
	dirty := false
]

{ #category : #accessing }
ClyDataSource >> parentGlobalPosition [
	^parentItem ifNil: [ 0 ] ifNotNil: [ parentItem globalPosition ]
]

{ #category : #accessing }
ClyDataSource >> parentItem [
	^ parentItem
]

{ #category : #accessing }
ClyDataSource >> parentItem: anObject [
	parentItem := anObject
]

{ #category : #accessing }
ClyDataSource >> query [
	^ query
]

{ #category : #accessing }
ClyDataSource >> query: anObject [
	query := anObject
]

{ #category : #accessing }
ClyDataSource >> queryEnvironment [
	^query environment
]

{ #category : #accessing }
ClyDataSource >> queryResult [
	^self itemCursor queryResult
]

{ #category : #accessing }
ClyDataSource >> queryView [
	^ queryView
]

{ #category : #accessing }
ClyDataSource >> queryView: aQueryView [
	queryView := aQueryView
]

{ #category : #accessing }
ClyDataSource >> realElementAt: anIndex [

	^ (self elementAt: anIndex) browserItem
]

{ #category : #private }
ClyDataSource >> runUpdate [
	self isClosed ifTrue: [^self].
	dirty ifFalse: [ ^self ].
	
	dirty := false.
	itemCursor updateItemCache.
	self updateExpandingItems.
	queryView itemsChangedIn: self.
	self tableRefresh
]

{ #category : #controlling }
ClyDataSource >> scheduleUpdate [

	self class scheduleUpdateOf: self
]

{ #category : #queries }
ClyDataSource >> searchText: aString [
	"we search only original elements"
	| found |
	found := self itemCursor moveToItemWhich: [ :each | 
		each name asLowercase beginsWith: aString asLowercase ].
	
	^found ifFalse: [ #() ] ifTrue: [ {self itemCursor position}]
]

{ #category : #accessing }
ClyDataSource >> toString: anItem [

	^anItem  name
]

{ #category : #'drag and drop' }
ClyDataSource >> transferFor: dataSourceItems from: aMorph [
	| selection passenger |
	selection := dataSourceItems first rootDataSource 
		newSelectionWith: dataSourceItems. "to get selection bound to last selected item. In FastTable last selected item is first in the list"

	passenger := queryView createDragPassengerFor: selection.
	
	^super transferFor: passenger from: aMorph
]

{ #category : #private }
ClyDataSource >> updateExpandingItems [
	self subclassResponsibility 
]

{ #category : #private }
ClyDataSource >> updateItems: dataSourceItems [
	"I update given data source items with refreshed environment items	which belongs to same actual objects. If there is no actual object anymore for some of data source item I will put nil to it.
	Then users should correctly process updated items"
	| updatedItems |
	updatedItems := itemCursor findItemsWith: (dataSourceItems collect: [:each | each actualObject]).
	dataSourceItems with: updatedItems do: [ :myItem :updatedBrowserItem | 
		myItem updateItemWith: updatedBrowserItem  ]
]

{ #category : #'drag and drop' }
ClyDataSource >> wantsDropElements: aPassanger type: type index: rowIndex [
	| dropTargetItem result |
	rowIndex = 0 | (rowIndex > self numberOfRows) ifTrue: [ ^false ].
	self dragTransferType == type ifFalse: [ ^false ].
	dropTargetItem := self elementAt: rowIndex.		
	result := queryView wantsDropPassenger: aPassanger at: dropTargetItem.
	queryView expandForDrag: dropTargetItem.
	
	result & dropTargetItem hasChildren ifTrue: [ dropTargetItem expand ].
	
	^result
]
