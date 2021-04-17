"
I represent collection of items retrieved by query from environment. 
My subclasses implement specific format or transformation of items. They should implement method:

- fillWith: items 

Any query has special parameter #requiredResult which specifies what kind of result should represent retrieved items. It is an instance of result which is used as prototype to create actual result instances. 

When query is executed at first time the navigation environment prepares new instance of required result:
	
	actualResult := aQuery prepareNewResult.

where query asks #requiredResult for: 

	actualResult := requiredResult prepareNewFor: aQuery in: environment

Then actualResult is cached using query as a key. And subsequent query execution just returns existing value.

Thus my instances describe required result and they can be implemented using composition of other objects. So different instances of same result class can lead to different result of query.
For example there is ClySortedQueryResult with #sortFunction variable. It allows to sort retrieved items using different criteria and different direction (ascending or descending).

Since requiredResult is part of query it is used in query comparison and hashing logic. And therefore my subclasses should correctly implement equality and hash operations when they introduce new parameters.
Also instances which are used as required result should be immutable because instead modification of result can corrupt cache of queries. 
To ensure this property #requiredResult is marked as readOnlyObject when it is assigned to the query.

Actual query execution is initiated by me using method #rebuildIfNeeded. Navigation environment calls it before returning result to the user.

I maintain special flag #needsRebuild to detect that existing items are dirty or are not built yet. So at first time #rebuildIfNeeded will lead to actual query execution (result building). But then it will do nothing until update will be not requested again.

So #rebuildIfNeeded will call #rebuild which will ask #buildingQuery to build result: 

	aQuery buildResult: self 

At the end aQuery fills result instance with items retrieved from the scope of environment.

Notice that #rebuild itself is private method. Users should use #rebuildIfNeeded. In fact users do not need it too because it is lazely evaluated when my items are accessed. But in case when query is executed it is evaluated explicitly by navigation environment. So callers always receive fresh result.

In the case when you want force items update there are two methods: 

- forceRebuild 
It set flag #needsRebuild to true and notify observers about changes (observers will be explained below).

- forceLazyRebuild 
It silently set flag #needsRebuild to true without any notification to observers.

In first case observers can handle notification by requesting new items from the result instance.
For example if UI widget observes result items and shows them to the user the #forceRebuild message will update shown items immediately. 
But #forceLazyRebuild will not update items until user request it manually.
In addition both methods reset items to nil.

There is extra helper method #cancelRebuild which reset rebuild flag and reset items to the empty collection.

My instances are safe to be used from multiple processes. Building and updating of items are protected by my #accessGuard mutex.

I provide several methods to access built items: 

- itemsStartingAt: startIndex count: size

- itemsStartingWhere: conditionBlock count: size
It finds first item where condition is true and then it returns ""size"" items starting from the found position

- itemsWhere: conditionBlock
It collects all items where conditionBlock is true

- allItems

- size

- isEmpty

These methods are safe to be used at any time: when user calls them I first ensure that items are ready and if not I rebuild them. 
Also I protect these methods by #accessGuard mutex. So it is safe to access items from multiple processes.
To ensure this logic I use helper method #protectItemsWhile:.

So I am cached by navigation environment. And this cache requires updates when underlying system is changed.
For this purpose navigation environment subscribes on system changes. And when any change happens the environment asks every result in cache to handle given event object:

	aQueryResult handleSystemChange: aSystemAnnouncement
 
To handle system change I ask my #buildingQuery if it is affected by given event. And if it is affected I force rebuild using #itemsChanged method where I announce that I was changed.
I allow my users to be notified when my items are changed. Users should subscribe to me using #subscribe: method:
	
	aQueryResult subscribe: anObserver 
	
Underhood I subscribe anObserver for ClyEnvironmentChanged to my #announcer. And it will be notified using #itemsChanged message. So observers should implement this method.
Also observers must #unsubscribe: when they are not interested anymore. 

For the UI support I provide special stream kind access in the form of ClyBrowserQueryCursor instance which returns items as ClyBrowserItem instances.
ClyBrowserItem is a wrapper over actual result item which provides UI specific information like position in the result, depth in the hierarchy and extendable set of properties related to the underlying object.
To get cursor instance you should open it for concrete observer:

	cursor := aQueryResult openBrowserCursorFor: anObserver

anObserver will be subscribed on my changes and new cursor instance will be returned to the caller.
When cursor is not needed anymore it should be closed. It will unsubscribe observer in addition:

	cursor close

With cursor you are able access items as ClyBrowserItem instances. For example: 

	cursor currentItem.
	cursor moveToNext.
	cursor findItemsWhere: conditionBlock 
	
The important responsibility of cursor is to organize cache of retrieved browser items. It is especially important for remote scenario where cache represents loaded remote items. But also it caches all extended properties collected for items by environment plugins.  

So cursor expects instances of ClyBrowserItem from inderlying query result. 
Some my subclasses build them directly from retrieved raw items. They are subclasses of ClyBrowseQueryResult. They provide extra query methods to lookup browser items.
When cursor is requested for such result it is just created over receiver instance.
But other result classes can't be used directly in cursor because they have no knowledge about browser items. For example ClyRawQueryResult just returns raw objects which were retrieved by query.
For such cases I provide special adapter ClyQueryResultBrowserAdapter: by default cursor instance is always created over adapter which wraps actual result instance.
Adapter converts actual items to the ClyBrowserItem instances and implements same query methods as ClyBrowserQueryResult.
This logic is implemented in method #adoptForBrowser which is overridden by ClyBrowserQueryResult with self return.

For more details about cursor look at ClyBrowserQueryCursor comments. And read comments of ClyBrowserItem.

The last feature which I provide for my subclasses is metadata. I compute it lazily on demand and keed it in the #metadata variable. Metadata is updated together with items. So when items are changed the metadata is reset and subsequent call for it will recompute it again.
The metadata is an instance of ClyQueryResultMetadata which represents extended properties of result in general. For example the result of class query can include the count of success tests as metadata property.
Properties are represented by first class objects, a kind of ClyProperty.
The metadata is collected using environment plugins. So it is extended by them. 
Plugins collect information of concrete type of result items. For example: 
	
		plugin collectMetadataOfClasses: aQueryResult
		plugin collectMetadataOfMethods: aQueryResult
		
The decision what method to use is responsibility of #buildingQuery which knows what kind of items it retrieves:

	metadata := ClyQueryResultMetadata new.
	environment pluginsDo: [:each | 
		buildingQuery collectMetadataOf: self by: each	]

So every query class should implement the method #collectMetadataOf:by:.

To access metadata there are several methods:

- addMetaProperty: aProperty
- getMetaProperty: aPropertyClass
- hasMetaProperty: aPropertyClass	
- metadata

Same protocol is also implemented in ClyBrowserQueryCursor. So with cursor instance you are also able to access metadata of query result.


Internal Representation and Key Implementation Points.

    Instance Variables
	announcer:		<Announcer>
	buildingQuery:		<ClyQuery>
	environment:		<ClyNavigationEnvironment>
	items:		<SequenceableCollection of<ClyBrowserItem>>
	metadata:	<ClyQueryResultMetadata>
	accessGuard:	<Mutex>
	needsRebuild:	Boolean
"
Class {
	#name : #ClyQueryResult,
	#superclass : #Object,
	#instVars : [
		'environment',
		'buildingQuery',
		'metadata',
		'items',
		'accessGuard',
		'announcer',
		'needsRebuild'
	],
	#category : #'Calypso-NavigationModel-Result'
}

{ #category : #testing }
ClyQueryResult class >> isExpandedHierarchy [
	^false
]

{ #category : #comparing }
ClyQueryResult >> = anObject [
	"Answer whether the receiver and anObject represent the same object."

	self == anObject
		ifTrue: [ ^ true ].
	self class = anObject class
		ifFalse: [ ^ false ].
	^ items = anObject items
]

{ #category : #accessing }
ClyQueryResult >> addMetaProperty: aProperty [
	"I allow to annotate result about its internal items. For example SUnit plugin annotate method query result with summary about test runs"
	
	self metadata addProperty: aProperty
]

{ #category : #converting }
ClyQueryResult >> adoptForBrowser [

	^ClyQueryResultBrowserAdapter for: self
]

{ #category : #queries }
ClyQueryResult >> allItems [

	^self itemsStartingAt: 1 count: self size
]

{ #category : #accessing }
ClyQueryResult >> announcer [
	^announcer
]

{ #category : #private }
ClyQueryResult >> beProtected [
	accessGuard := Mutex new
]

{ #category : #building }
ClyQueryResult >> buildWith: objects [
	"it is suitable method to build result manually avoiding query logic.
	needsRebuild false value will prevent rebuilding when accessing items which were manually filled"
	needsRebuild := false.
	self initializeItems.
	self fillWith: objects
]

{ #category : #accessing }
ClyQueryResult >> buildingQuery [
	^ buildingQuery
]

{ #category : #accessing }
ClyQueryResult >> buildingQuery: anEnvironmentQuery [
	buildingQuery := anEnvironmentQuery
]

{ #category : #building }
ClyQueryResult >> cancelRebuild [

	items ifNil: [self initializeItems].
	needsRebuild := false
]

{ #category : #initialization }
ClyQueryResult >> collectMetadata [
	self protectAccessWhile: [ 
		metadata ifNotNil: [ ^self ].

		metadata := ClyQueryResultMetadata new.
		environment pluginsDo: [:each | 
			buildingQuery collectMetadataOf: self by: each	]
	]
]

{ #category : #initialization }
ClyQueryResult >> defaultItems [
	^OrderedCollection new
]

{ #category : #accessing }
ClyQueryResult >> environment [
	^ environment
]

{ #category : #accessing }
ClyQueryResult >> environment: anObject [
	environment := anObject
]

{ #category : #building }
ClyQueryResult >> fillWith: queriedObjects [
	self subclassResponsibility 
]

{ #category : #building }
ClyQueryResult >> forceLazyRebuild [
	"This method allows reset result cache without observers notification.
	It can be suitable for some queries to not force observers update after changes
	but instead allow them update items manually. 
	After this method is called observers will be updated only when they will try access items again"
	
	self protectAccessWhile: [ 	
		needsRebuild := true.
		items := nil]
]

{ #category : #building }
ClyQueryResult >> forceRebuild [

	self forceLazyRebuild.
	
	self notifyObservers
]

{ #category : #accessing }
ClyQueryResult >> getMetaProperty: aPropertyClass [
	^self metadata getProperty: aPropertyClass
]

{ #category : #'system changes' }
ClyQueryResult >> handleSystemChange: aSystemAnnouncement [
	needsRebuild ifTrue: [ ^self ].
	aSystemAnnouncement shouldBeConsideredByCalypsoEnvironment ifFalse: [ ^self ]. "some system events can happen in wrong system state or be just obsolete. This little hook allows skip such events"	

	self protectAccessWhile: [
		(buildingQuery isResult: self affectedBy: aSystemAnnouncement)
			ifTrue: [ self itemsChanged]]
]

{ #category : #'system changes' }
ClyQueryResult >> handleSystemChange: aSystemAnnouncement byProcessingList: allProcessingResults [ 
	needsRebuild ifTrue: [ ^allProcessingResults remove: self ]. 
	aSystemAnnouncement shouldBeConsideredByCalypsoEnvironment 
		ifFalse: [ ^allProcessingResults remove: self ]. "some system events can happen in wrong system state or be just obsolete. This little hook allows skip such events"
	accessGuard 
		tryEnterCritical: [self handleSystemChange: aSystemAnnouncement]
		ifLocked: [ ^self ].
		
	allProcessingResults remove: self
]

{ #category : #testing }
ClyQueryResult >> hasMetaProperty: aPropertyClass [

	^self metadata hasProperty: aPropertyClass
]

{ #category : #'system changes' }
ClyQueryResult >> hasSubscriber: anObject [

	announcer ifNil: [ ^false].
	
	^announcer hasSubscriber: anObject
]

{ #category : #comparing }
ClyQueryResult >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^ items hash
]

{ #category : #initialization }
ClyQueryResult >> initialize [
	super initialize.
	needsRebuild := true
]

{ #category : #initialization }
ClyQueryResult >> initializeItems [
	items := self defaultItems
]

{ #category : #testing }
ClyQueryResult >> isBuilt [
	^items notNil
]

{ #category : #testing }
ClyQueryResult >> isEmpty [
	^self size = 0
]

{ #category : #testing }
ClyQueryResult >> isProtected [
	^accessGuard notNil
]

{ #category : #accessing }
ClyQueryResult >> itemAt: index [
	^items at: index
]

{ #category : #accessing }
ClyQueryResult >> items [
	^ items
]

{ #category : #accessing }
ClyQueryResult >> items: anObject [
	items := anObject
]

{ #category : #'system changes' }
ClyQueryResult >> itemsChanged [

	self forceRebuild 
]

{ #category : #queries }
ClyQueryResult >> itemsStartingAt: startIndex count: size [

	^self protectItemsWhile: [	
		items copyFrom: startIndex to: (startIndex + size - 1 min: items size)]
]

{ #category : #queries }
ClyQueryResult >> itemsStartingWhere: conditionBlock count: size [

	| firstItemIndex |
	firstItemIndex := items findFirst: conditionBlock.
	firstItemIndex = 0 ifTrue: [ ^#() ].
	^self itemsStartingAt: firstItemIndex count: size
]

{ #category : #queries }
ClyQueryResult >> itemsWhere: conditionBlock [	
	^self protectItemsWhile: [ 
		items select: conditionBlock]
]

{ #category : #accessing }
ClyQueryResult >> metadata [
	^metadata ifNil: [ self collectMetadata. metadata ]
]

{ #category : #testing }
ClyQueryResult >> needsRebuild [
	^needsRebuild 
]

{ #category : #testing }
ClyQueryResult >> notEmpty [
	^self isEmpty not
]

{ #category : #'system changes' }
ClyQueryResult >> notifyChanges [

	announcer announce: ClyEnvironmentChanged
]

{ #category : #'system changes' }
ClyQueryResult >> notifyObservers [

	announcer ifNil: [ ^self ].	
	environment announceChangesOf: self
]

{ #category : #accessing }
ClyQueryResult >> openBrowserCursorFor: anItemObserver [

	| cursor |
	cursor := ClyBrowserQueryCursor for: self adoptForBrowser.
	cursor openFor: anItemObserver.
	^cursor.
]

{ #category : #initialization }
ClyQueryResult >> prepareNewFor: aQuery in: aNavigationEnvironment [
	^self copy 
		environment: aNavigationEnvironment;
		buildingQuery: aQuery;
		beProtected.
]

{ #category : #private }
ClyQueryResult >> protectAccessWhile: aBlock [

	^accessGuard critical: [
		aBlock value
	]
]

{ #category : #private }
ClyQueryResult >> protectItemsWhile: aBlock [

	^self protectAccessWhile: [ 
		self rebuildIfNeeded.
		aBlock value
	]
]

{ #category : #accessing }
ClyQueryResult >> rawItems [
	^items
]

{ #category : #accessing }
ClyQueryResult >> rawItemsDo: aBlock [

	^self rawItems do: aBlock
]

{ #category : #accessing }
ClyQueryResult >> rawItemsOf: itemTypeClass do: aBlock [

	^self rawItemsDo: [:each | 
		each calypsoEnvironmentType = itemTypeClass ifTrue: [ 
			aBlock value: each ]
	]
]

{ #category : #building }
ClyQueryResult >> rebuild [
	self initializeItems.
	buildingQuery buildResult: self.
	metadata := nil	"metadata is computed and updated lazily"
]

{ #category : #building }
ClyQueryResult >> rebuildIfNeeded [
	self protectAccessWhile: [
		
		needsRebuild ifTrue: [ 
			needsRebuild := false.
			self rebuild]
		
	]
]

{ #category : #testing }
ClyQueryResult >> representsBrowserItems [
	^false
]

{ #category : #accessing }
ClyQueryResult >> scope [
	^buildingQuery scope
]

{ #category : #accessing }
ClyQueryResult >> size [
	^self protectItemsWhile: [items size]
]

{ #category : #'system changes' }
ClyQueryResult >> subscribe: anObject [

	announcer ifNil: [ announcer := Announcer new].
	
	announcer when: ClyEnvironmentChanged send: #itemsChanged to: anObject
]

{ #category : #'system changes' }
ClyQueryResult >> unsubscribe: anObject [

	announcer ifNil: [ ^self ].
	announcer unsubscribe: anObject 
]
