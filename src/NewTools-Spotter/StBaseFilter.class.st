Class {
	#name : #StBaseFilter,
	#superclass : #Object,
	#instVars : [
		'context',
		'filteredItems',
		'streamed'
	],
	#category : #'NewTools-Spotter-Filters'
}

{ #category : #public }
StBaseFilter class >> stFilter [

	^ self new
]

{ #category : #public }
StBaseFilter class >> stListFilter [

	^ self new
]

{ #category : #'private-model' }
StBaseFilter >> addItem: anItem [
	self context streamed add: anItem.
	self context addItem: anItem
]

{ #category : #'private-model' }
StBaseFilter >> addItems: aCollection [
	self context streamed addAll: aCollection.
	self context addItems: aCollection
]

{ #category : #'private-model' }
StBaseFilter >> allItems [
	" WARNING: #allItems might be a list, block or iterator. we have to evaluate it in order to calculate the remaining/unstreamed items. #allItems are/were designed to be polymorphic to collections and streams. so this should be safe "
	| allItems |
	allItems := self processor allItemsIn: self context.
	^ self context isContinuing
		ifTrue: [ allItems value fasterDifferencePreservingOrder: self context streamed ]
		ifFalse: [ allItems ]
]

{ #category : #'private-model' }
StBaseFilter >> allItemsDo: aBlock [
	self allItems do: aBlock
]

{ #category : #private }
StBaseFilter >> applyFilter [
	^ self filteredItems
]

{ #category : #private }
StBaseFilter >> applyFilterInContext: aSpotterContext [
	self prepareFilterInContext: aSpotterContext.
	^ self applyFilter
]

{ #category : #private }
StBaseFilter >> applyFilterInContext: aSpotterContext error: anException [
	('[Spotter] Exception in filter <' , self class name , '>: '
		, anException asString) traceCr.
	^ self defaultFilteredItems
]

{ #category : #accessing }
StBaseFilter >> context [
	^ context
]

{ #category : #accessing }
StBaseFilter >> context: anObject [
	context := anObject
]

{ #category : #'accessing-defaults' }
StBaseFilter >> defaultFilteredItems [
	^ OrderedCollection new: 100 " not a limitation, just a reasonable start size "
]

{ #category : #'accessing-defaults' }
StBaseFilter >> defaultStreamed [
	^ true
]

{ #category : #accessing }
StBaseFilter >> filteredItems [
	^ filteredItems
]

{ #category : #accessing }
StBaseFilter >> filteredItems: aCollection [
	filteredItems := aCollection
]

{ #category : #testing }
StBaseFilter >> hasFilteredItems [
	^ self filteredItems isEmptyOrNil not
]

{ #category : #initialization }
StBaseFilter >> initialize [
	super initialize.
	
	self filteredItems: self defaultFilteredItems
]

{ #category : #'private-model' }
StBaseFilter >> itemFilterNameFor: anItem [
	"I return the string/text representation of an item used by the filter."
	
	^ self processor itemFilterNameFor: anItem
]

{ #category : #'private-model' }
StBaseFilter >> itemsLimit [
	^ self context itemsLimit
]

{ #category : #private }
StBaseFilter >> prepareFilterInContext: aSpotterContext [
	"I provide a hook for preprocessing the query once before performing a search."
	
	self context: aSpotterContext.
]

{ #category : #'private-model' }
StBaseFilter >> processor [
	^ self context processor
]

{ #category : #public }
StBaseFilter >> stFilter [

	^ self
]

{ #category : #public }
StBaseFilter >> stListFilter [

	^ self
]

{ #category : #'private-model' }
StBaseFilter >> step [
	^ self context step
]

{ #category : #accessing }
StBaseFilter >> streamed [
	^ streamed ifNil: [ streamed := self defaultStreamed ]
]

{ #category : #accessing }
StBaseFilter >> streamed: anObject [
	streamed := anObject
]

{ #category : #public }
StBaseFilter >> value: aSpotterContext [
	"I provide an entry point for performing a search that is 
	polymorphic with BlockClosure>>value:. I return the list of
	filtered items."
	
	^ [ self applyFilterInContext: aSpotterContext ]
		ensure: [ context := nil " release the context after search is completed " ] 
]
