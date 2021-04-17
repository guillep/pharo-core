"
This is the abstract class that models a processor that is associated with a spotter category. It can spot items to be displayed in that category by reacting to a filter: message. 
"
Class {
	#name : #GTSpotterPragmaBasedProcessor,
	#superclass : #Object,
	#instVars : [
		'allFilteredCandidates',
		'order',
		'running'
	],
	#classVars : [
		'DefaultItemsLimit'
	],
	#category : #'GT-Spotter-Pragma-Based-Processors'
}

{ #category : #'accessing-defaults' }
GTSpotterPragmaBasedProcessor class >> defaultItemsLimit [

	^ DefaultItemsLimit ifNil: [ DefaultItemsLimit := 25 ]
]

{ #category : #'accessing-defaults' }
GTSpotterPragmaBasedProcessor class >> defaultItemsLimit: aValue [

	DefaultItemsLimit := aValue
]

{ #category : #'accessing-defaults' }
GTSpotterPragmaBasedProcessor class >> settingsOn: aBuilder [
	"<systemsettings>

	(aBuilder setting: #defaultItemsLimit)
		target: self;
		parent: #spotter;
		label: 'Number of results per category';
		default: 25;
		order: 100;
		description:
			'Number of results per category to show in Spotter'"
]

{ #category : #public }
GTSpotterPragmaBasedProcessor >> actOn: anObject for: aStep [
	anObject spotterActDefault: aStep
]

{ #category : #public }
GTSpotterPragmaBasedProcessor >> allFilteredCandidates [
	^ allFilteredCandidates ifNil: [ allFilteredCandidates := OrderedCollection new ]
]

{ #category : #private }
GTSpotterPragmaBasedProcessor >> continueFilterInContext: aSpotterContext [

	" We DO NOT prepare the context since we could no longer continue producing filtered candidates. "
	(self shouldFilterInContext: aSpotterContext) ifTrue: [
		" The continue-filter only puts more items on the stream but doesn't do any filtering at all. Therefore the original collection (=result/candidates) and its size remains the same and can be reused after the continue-filter has added more items. So we do not ressign the result to #allFilteredCandidates as it is done for the regular filter-loop. #allFilteredCandidates must never be modified more than once because the next #diveIntoCategory would render an invalid set of items !!! "
		self doContinueFilterInContext: aSpotterContext ].
	aSpotterContext stream 
		performSymbol: #onAmountChanged:in:
		withArguments: { self allFilteredCandidates size . self }
]

{ #category : #printing }
GTSpotterPragmaBasedProcessor >> displayStringOn: stream [
	stream 
		nextPutAll: 'Processor: ';
		nextPutAll: self title asString
]

{ #category : #private }
GTSpotterPragmaBasedProcessor >> doContinueFilterInContext: aSpotterContext [
	^ aSpotterContext doContinueFilterForProcessor: self
]

{ #category : #private }
GTSpotterPragmaBasedProcessor >> doFilterInContext: aSpotterContext [
	"override this method to:
	- add items to the stream
	- return all found items at the end"
	self subclassResponsibility
]

{ #category : #private }
GTSpotterPragmaBasedProcessor >> filterInContext: aSpotterContext [

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
GTSpotterPragmaBasedProcessor >> gtDisplayOn: stream [
	stream 
		nextPutAll: 'Processor: ';
		nextPutAll: self title asString
]

{ #category : #testing }
GTSpotterPragmaBasedProcessor >> hasFilteredCandidates [
	^ self allFilteredCandidates notEmpty
]

{ #category : #initialization }
GTSpotterPragmaBasedProcessor >> initialize [ 

	super initialize.
	running := false
]

{ #category : #'key-bindings' }
GTSpotterPragmaBasedProcessor >> installKeymappingsOn: aGTSpotterMorph [

	self keyBinding
		ifNotNil: [ | keyCombination |
			keyCombination := self keyBinding asKeyCombination.
			aGTSpotterMorph 
				bindKeyCombination: keyCombination 
				ofProcessor: self 
				toAction: [ aGTSpotterMorph onKeyProcessor: self ] ]
]

{ #category : #testing }
GTSpotterPragmaBasedProcessor >> isRelevantForQuery: categoryQueryPrefix [
	| trimmedProcessorTitle |
	trimmedProcessorTitle := self title asLowercase 
										copyReplaceAll: String space
										with: ''.
	^ trimmedProcessorTitle beginsWith: categoryQueryPrefix
]

{ #category : #testing }
GTSpotterPragmaBasedProcessor >> isRunning [ 
	
	^ running
]

{ #category : #'key-bindings' }
GTSpotterPragmaBasedProcessor >> keyBinding [

	^ nil
]

{ #category : #accessing }
GTSpotterPragmaBasedProcessor >> order [
	"Return assigned spotter order used to arrange categories in spotter UI"
	<return: #Number>
	
	^ order
]

{ #category : #accessing }
GTSpotterPragmaBasedProcessor >> order: aNumber [
	"Assign to processor its spotter order to arrange categories
	within spotter ui"
	order := aNumber
]

{ #category : #private }
GTSpotterPragmaBasedProcessor >> prepareProcessorInContext: aContext [
	allFilteredCandidates := nil
]

{ #category : #testing }
GTSpotterPragmaBasedProcessor >> shouldFilterInContext: aSpotterContext [
	^ aSpotterContext notEmpty 
		or: [ self wantsToDisplayOnEmptyQuery ]
]

{ #category : #accessing }
GTSpotterPragmaBasedProcessor >> title [
	self subclassResponsibility
]

{ #category : #accessing }
GTSpotterPragmaBasedProcessor >> wantsToDisplayOnEmptyQuery [
	^ true
]

{ #category : #private }
GTSpotterPragmaBasedProcessor >> withItemsLimit: aLimit do: aBlock [
	^ aBlock value
]
