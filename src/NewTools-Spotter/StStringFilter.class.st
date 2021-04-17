Class {
	#name : #StStringFilter,
	#superclass : #StBaseFilter,
	#instVars : [
		'caseSensitive',
		'query'
	],
	#category : #'NewTools-Spotter-Filters'
}

{ #category : #private }
StStringFilter >> applyFilter [
	self hasQuery ifFalse: [ 
		self applyFilterWithoutQuery.
		^ self allItems. " return the unfiltered items (all) - used for divein (no filtering appied) "  ].
	self applyFilterWithQuery.
	^ self filteredItems " return the filtered items only "
]

{ #category : #private }
StStringFilter >> applyFilterWithQuery [

	[ self doApplyFilterWithQuery ]
		on: StLimitArrived do: [ ^ self ]
]

{ #category : #private }
StStringFilter >> applyFilterWithoutQuery [
	" WARNING: this is not a copy of GTNullFilter>>#applyFilterWithoutQuery !!! "

	[self streamed 
		ifTrue: [
			" this will be more responsive (faster) for very large collections and/or expensive filters "
			| reducedItems |
			self filteredItems: (reducedItems := OrderedCollection new).
			self allItems withIndexDo: [ :each :index |
				reducedItems add: each.
				self addItem: each.
				index = self itemsLimit ifTrue: [ StLimitArrived signal ] ] ]
		ifFalse: [
			" this will be much much faster for small collections and/or very quick filters " 
			self filteredItems: (self allItems first: (self itemsLimit min: self allItems size)).
			self addItems: self filteredItems ]] on: StLimitArrived do: [ ^ self ]
]

{ #category : #accessing }
StStringFilter >> caseSensitive [
	^ caseSensitive
]

{ #category : #accessing }
StStringFilter >> caseSensitive: anObject [
	caseSensitive := anObject
]

{ #category : #'accessing-defaults' }
StStringFilter >> defaultCaseSensitive [
	^ false
]

{ #category : #private }
StStringFilter >> doApplyFilterWithQuery [

	self subclassResponsibility 
]

{ #category : #testing }
StStringFilter >> hasQuery [
	^ self query isEmptyOrNil not
]

{ #category : #private }
StStringFilter >> prepareFilterInContext: aSpotterContext [
	super prepareFilterInContext: aSpotterContext.
	
	caseSensitive ifNil: [ caseSensitive := self defaultCaseSensitive ]. " performance optimization "
	self query: (caseSensitive " performance optimization "
		ifTrue: [ self context textTrimmed ]
		ifFalse: [ self context textLowercase ])
]

{ #category : #accessing }
StStringFilter >> query [
	^ query
]

{ #category : #accessing }
StStringFilter >> query: anObject [
	query := anObject
]
