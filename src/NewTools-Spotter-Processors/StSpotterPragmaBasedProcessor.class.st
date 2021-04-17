Class {
	#name : #StSpotterPragmaBasedProcessor,
	#superclass : #Object,
	#instVars : [
		'allFilteredCandidates',
		'order',
		'running'
	],
	#classVars : [
		'DefaultItemsLimit'
	],
	#category : #'NewTools-Spotter-Processors'
}

{ #category : #'accessing-defaults' }
StSpotterPragmaBasedProcessor class >> defaultItemsLimit [

	^ DefaultItemsLimit ifNil: [ DefaultItemsLimit := 25 ]
]

{ #category : #'accessing-defaults' }
StSpotterPragmaBasedProcessor class >> defaultItemsLimit: aValue [

	DefaultItemsLimit := aValue
]

{ #category : #'accessing-defaults' }
StSpotterPragmaBasedProcessor class >> settingsOn: aBuilder [
	<systemsettings>

	(aBuilder setting: #defaultItemsLimit)
		target: self;
		parent: #spotter;
		label: 'Number of results per category';
		default: 25;
		order: 100;
		description: 'Number of results per category to show in Spotter'
]

{ #category : #public }
StSpotterPragmaBasedProcessor >> actOn: anObject for: aStep [
	anObject spotterActDefault: aStep
]

{ #category : #public }
StSpotterPragmaBasedProcessor >> allFilteredCandidates [
	^ allFilteredCandidates ifNil: [ allFilteredCandidates := OrderedCollection new ]
]

{ #category : #private }
StSpotterPragmaBasedProcessor >> continueFilterInContext: aSpotterContext [

	" We DO NOT prepare the context since we could no longer continue producing filtered candidates. "
	(self shouldFilterInContext: aSpotterContext) ifTrue: [
		" The continue-filter only puts more items on the stream but doesn't do any filtering at all. Therefore the original collection (=result/candidates) and its size remains the same and can be reused after the continue-filter has added more items. So we do not ressign the result to #allFilteredCandidates as it is done for the regular filter-loop. #allFilteredCandidates must never be modified more than once because the next #diveIntoCategory would render an invalid set of items !!! "
		self doContinueFilterInContext: aSpotterContext ].
	aSpotterContext stream 
		performSymbol: #onAmountChanged:in:
		withArguments: { self allFilteredCandidates size . self }
]

{ #category : #printing }
StSpotterPragmaBasedProcessor >> displayStringOn: stream [
	stream 
		nextPutAll: 'Processor: ';
		nextPutAll: self title asString
]

{ #category : #private }
StSpotterPragmaBasedProcessor >> doContinueFilterInContext: aSpotterContext [
	^ aSpotterContext doContinueFilterForProcessor: self
]

{ #category : #private }
StSpotterPragmaBasedProcessor >> doFilterInContext: aSpotterContext [
	"override this method to:
	- add items to the stream
	- return all found items at the end"
	self subclassResponsibility
]

{ #category : #private }
StSpotterPragmaBasedProcessor >> filterInContext: aSpotterContext [

	running := true.
	aSpotterContext stream 
		performSymbol: #processorStarted: 
		withArguments: { self }.
	
	self prepareProcessorInContext: aSpotterContext.
	(self shouldFilterInContext: aSpotterContext) ifTrue: [
		allFilteredCandidates := self doFilterInContext: aSpotterContext ].
	aSpotterContext stream 
		performSymbol: #onAmountChanged:in: 
		withArguments: { self allFilteredCandidates size . self }.
		
	running := false.
	aSpotterContext stream 
		performSymbol: #processorEnded: 
		withArguments: { self }.

]

{ #category : #printing }
StSpotterPragmaBasedProcessor >> gtDisplayOn: stream [
	stream 
		nextPutAll: 'Processor: ';
		nextPutAll: self title asString
]

{ #category : #testing }
StSpotterPragmaBasedProcessor >> hasFilteredCandidates [
	^ self allFilteredCandidates notEmpty
]

{ #category : #initialization }
StSpotterPragmaBasedProcessor >> initialize [ 

	super initialize.
	running := false
]

{ #category : #'key-bindings' }
StSpotterPragmaBasedProcessor >> installKeymappingsOn: aGTSpotterMorph [

	self keyBinding
		ifNotNil: [ | keyCombination |
			keyCombination := self keyBinding asKeyCombination.
			aGTSpotterMorph 
				bindKeyCombination: keyCombination 
				ofProcessor: self 
				toAction: [ aGTSpotterMorph onKeyProcessor: self ] ]
]

{ #category : #testing }
StSpotterPragmaBasedProcessor >> isRelevantForQuery: categoryQueryPrefix [
	| trimmedProcessorTitle |
	trimmedProcessorTitle := self title asLowercase 
										copyReplaceAll: String space
										with: ''.
	^ trimmedProcessorTitle beginsWith: categoryQueryPrefix
]

{ #category : #testing }
StSpotterPragmaBasedProcessor >> isRunning [ 
	
	^ running
]

{ #category : #'key-bindings' }
StSpotterPragmaBasedProcessor >> keyBinding [

	^ nil
]

{ #category : #accessing }
StSpotterPragmaBasedProcessor >> order [
	"Return assigned spotter order used to arrange categories in spotter UI"
	<return: #Number>
	
	^ order
]

{ #category : #accessing }
StSpotterPragmaBasedProcessor >> order: aNumber [
	"Assign to processor its spotter order to arrange categories
	within spotter ui"
	order := aNumber
]

{ #category : #private }
StSpotterPragmaBasedProcessor >> prepareProcessorInContext: aContext [
	allFilteredCandidates := nil
]

{ #category : #testing }
StSpotterPragmaBasedProcessor >> shouldFilterInContext: aSpotterContext [
	^ aSpotterContext notEmpty 
		or: [ self wantsToDisplayOnEmptyQuery ]
]

{ #category : #accessing }
StSpotterPragmaBasedProcessor >> stop [
	
	running := false
]

{ #category : #accessing }
StSpotterPragmaBasedProcessor >> title [
	self subclassResponsibility
]

{ #category : #accessing }
StSpotterPragmaBasedProcessor >> wantsToDisplayOnEmptyQuery [
	^ true
]

{ #category : #private }
StSpotterPragmaBasedProcessor >> withItemsLimit: aLimit do: aBlock [
	^ aBlock value
]
