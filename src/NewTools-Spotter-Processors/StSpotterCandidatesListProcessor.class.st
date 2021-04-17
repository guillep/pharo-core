Class {
	#name : #StSpotterCandidatesListProcessor,
	#superclass : #StSpotterCandidatesProcessor,
	#instVars : [
		'allCandidatesBlock',
		'candidatesLimit',
		'title',
		'itemNameBlock',
		'itemIconBlock',
		'actBlock',
		'wantsToDisplayOnEmptyQuery',
		'filterBlock',
		'keyBinding',
		'sortBlock'
	],
	#category : #'NewTools-Spotter-Processors'
}

{ #category : #accessing }
StSpotterCandidatesListProcessor >> actLogic [
	^ actBlock
]

{ #category : #scripting }
StSpotterCandidatesListProcessor >> actLogic: aBlockWithTwoArguments [

	actBlock := aBlockWithTwoArguments
]

{ #category : #private }
StSpotterCandidatesListProcessor >> actOn: anObject for: aStep [
	
	actBlock
		ifNil: [ super actOn: anObject for: aStep ]
		ifNotNil: [ actBlock cull: anObject cull: aStep ]
]

{ #category : #compatibility }
StSpotterCandidatesListProcessor >> allCandidates: aBlockWithOneArgument [
	self items: aBlockWithOneArgument
]

{ #category : #compatibility }
StSpotterCandidatesListProcessor >> candidatesLimit: anInteger [
	self itemsLimit: anInteger
]

{ #category : #private }
StSpotterCandidatesListProcessor >> computeAllItemsIn: aContext [
	^ allCandidatesBlock cull: aContext
]

{ #category : #compatibility }
StSpotterCandidatesListProcessor >> defaultCandidatesLimit [
	^ self defaultItemsLimit
]

{ #category : #'accessing-defaults' }
StSpotterCandidatesListProcessor >> defaultContinueItemsLimit [
	" Spotter becomes extraordenary slow when rendering too many results. So we set the maximum limit to 100. This is only a temporary solution until we have fixed the problem. Until then no spotter processor will ever generate more then 100 results. "
	^ 100
]

{ #category : #'accessing-defaults' }
StSpotterCandidatesListProcessor >> defaultItemsLimit [
	^ self class defaultItemsLimit
]

{ #category : #private }
StSpotterCandidatesListProcessor >> doFilterInContext: aSpotterContext [

	^ aSpotterContext 
		doFilter: filterBlock stFilter 
		forProcessor: self
]

{ #category : #accessing }
StSpotterCandidatesListProcessor >> filter [
	^ filterBlock
]

{ #category : #scripting }
StSpotterCandidatesListProcessor >> filter: aGTFilterOrBlockWithOneArgument [
	filterBlock := aGTFilterOrBlockWithOneArgument 
]

{ #category : #scripting }
StSpotterCandidatesListProcessor >> filter: aGTFilter item: aGTSpotterIterator [ 
	self filter: aGTFilter.
	self items: aGTSpotterIterator gtIterator.
	
]

{ #category : #compatibility }
StSpotterCandidatesListProcessor >> filterUsing: aFilter [
	self filter: aFilter
]

{ #category : #testing }
StSpotterCandidatesListProcessor >> hasDynamicItems [
	^ allCandidatesBlock hasDynamicItems
]

{ #category : #accessing }
StSpotterCandidatesListProcessor >> itemIcon [
	^ itemIconBlock
]

{ #category : #scripting }
StSpotterCandidatesListProcessor >> itemIcon: aBlockWithOneArgument [
	itemIconBlock := aBlockWithOneArgument
]

{ #category : #private }
StSpotterCandidatesListProcessor >> itemIconFor: anObject [

	^ itemIconBlock ifNil: [ super itemIconFor: anObject ] ifNotNil: [ itemIconBlock cull: anObject ]
]

{ #category : #accessing }
StSpotterCandidatesListProcessor >> itemName [
	^ itemNameBlock
]

{ #category : #scripting }
StSpotterCandidatesListProcessor >> itemName: aBlockWithOneArgument [
	itemNameBlock := aBlockWithOneArgument
]

{ #category : #private }
StSpotterCandidatesListProcessor >> itemNameFor: anObject [

	^ itemNameBlock ifNil: [ super itemNameFor: anObject ] ifNotNil: [ itemNameBlock cull: anObject ]
]

{ #category : #scripting }
StSpotterCandidatesListProcessor >> items: aBlock [
	allCandidatesBlock := aBlock
]

{ #category : #accessing }
StSpotterCandidatesListProcessor >> itemsLimit [
	^ candidatesLimit ifNil: [ self defaultItemsLimit ]
]

{ #category : #scripting }
StSpotterCandidatesListProcessor >> itemsLimit: anInteger [
	candidatesLimit := anInteger
]

{ #category : #accessing }
StSpotterCandidatesListProcessor >> keyBinding [
	^ keyBinding
]

{ #category : #accessing }
StSpotterCandidatesListProcessor >> keyBinding: anObject [
	keyBinding := anObject
]

{ #category : #'scripting-convenience' }
StSpotterCandidatesListProcessor >> match: aBlockWithTwoArguments [

	self filter: (StFilterBlock new 
		matcher: aBlockWithTwoArguments;
		yourself)
]

{ #category : #'scripting-convenience' }
StSpotterCandidatesListProcessor >> matchAlike [
	self filter: StFilterAlike
]

{ #category : #'scripting-convenience' }
StSpotterCandidatesListProcessor >> matchRegex [
	self filter: StFilterRegex
]

{ #category : #'scripting-convenience' }
StSpotterCandidatesListProcessor >> matchString [
	self filter: StFilterStringMatch
]

{ #category : #'scripting-convenience' }
StSpotterCandidatesListProcessor >> matchSubstring [
	self filter: StFilterSubstring
]

{ #category : #'scripting-convenience' }
StSpotterCandidatesListProcessor >> matchSubstrings [
	self filter: StFilterSubstrings
]

{ #category : #accessing }
StSpotterCandidatesListProcessor >> sort [
	^ sortBlock
]

{ #category : #scripting }
StSpotterCandidatesListProcessor >> sort: aBlockWithTwoArguments [
	sortBlock := aBlockWithTwoArguments
]

{ #category : #accessing }
StSpotterCandidatesListProcessor >> title [
	^ title ifNil: [ super title ]
]

{ #category : #scripting }
StSpotterCandidatesListProcessor >> title: aString [
	title := aString
]

{ #category : #accessing }
StSpotterCandidatesListProcessor >> wantsToDisplayOnEmptyQuery [
	^ wantsToDisplayOnEmptyQuery ifNil: [ super wantsToDisplayOnEmptyQuery ]
]

{ #category : #scripting }
StSpotterCandidatesListProcessor >> wantsToDisplayOnEmptyQuery: anObject [
	wantsToDisplayOnEmptyQuery := anObject
]

{ #category : #private }
StSpotterCandidatesListProcessor >> withItemsLimit: aLimit do: aBlock [
	| previousCandidatesLimit |
	previousCandidatesLimit := candidatesLimit.
	^ [ candidatesLimit := aLimit. aBlock value ] 
		ensure: [ candidatesLimit := previousCandidatesLimit ]
]
