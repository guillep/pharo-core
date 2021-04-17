Class {
	#name : #StSpotterModel,
	#superclass : #Object,
	#instVars : [
		'steps',
		'candidateAddedAction',
		'searchUpdatedAction',
		'amountChangedAction',
		'mutex',
		'queryStartedAction',
		'queryEndedAction',
		'noResultsAction',
		'scheduler'
	],
	#category : #'NewTools-Spotter-Model'
}

{ #category : #accessing }
StSpotterModel >> activeProcessors [

	^ self activeStep processors
]

{ #category : #accessing }
StSpotterModel >> activeStep [

	^ steps last
]

{ #category : #'private announcing' }
StSpotterModel >> announceAllCandidatesAdded: ann [

	searchUpdatedAction ifNil: [ ^ self ].
	ann candidateLinks 
		do: [ :each | searchUpdatedAction value: each ]
]

{ #category : #'private announcing' }
StSpotterModel >> announceAmountChanged: ann [

	amountChangedAction ifNil: [ ^ self ].
	amountChangedAction 
		value: ann category 
		value: ann amount
]

{ #category : #'private announcing' }
StSpotterModel >> announceCandidateAdded: ann [

	searchUpdatedAction ifNil: [ ^ self ].
	searchUpdatedAction value: ann candidateLink
]

{ #category : #'private announcing' }
StSpotterModel >> announceNoResults [

	noResultsAction ifNil: [ ^ self ].
	noResultsAction value
]

{ #category : #'private announcing' }
StSpotterModel >> announceQueryEnded: ann [

	queryEndedAction ifNil: [ ^ self ].
	queryEndedAction value
]

{ #category : #'private announcing' }
StSpotterModel >> announceQueryStarted: ann [

	queryStartedAction ifNil: [ ^ self ].
	queryStartedAction value
]

{ #category : #private }
StSpotterModel >> defaultProcessors [

	^ (StSpotterProcessor allEnabledSubclasses 
		collect: [ :each | each new ])
		sort: #order ascending
]

{ #category : #initialization }
StSpotterModel >> initialize [

	super initialize.
	
	scheduler := TKTWorkerPool new.
	scheduler poolMaxSize: 10.
	scheduler start.
	
	mutex := Mutex new.
	steps := OrderedCollection with: self newDefaultStep
]

{ #category : #testing }
StSpotterModel >> isNested [

	^ steps size > 1
]

{ #category : #accessing }
StSpotterModel >> lastSearchText [

	^ self activeStep lastSearchText
]

{ #category : #accessing }
StSpotterModel >> links [

	^ self activeStep links
]

{ #category : #'private factory' }
StSpotterModel >> newDefaultStep [

	^ self newStep
		origin: self;
		yourself
]

{ #category : #'private factory' }
StSpotterModel >> newStep [

	^ StSpotterStep on: self
]

{ #category : #accessing }
StSpotterModel >> popStep [
	| lastQuery |

	"Do not pop first"
	steps size > 1 ifFalse: [ ^ self ]. 

	lastQuery := self activeStep activeQuery.
	self activeStep deactivate.
	steps removeLast.
	self activeStep activate
]

{ #category : #'accessing query' }
StSpotterModel >> processSearch: aString on: spotter [
	| query |

	query := StSpotterQuery 
		newSearch: aString 
		on: spotter.
	self pushQuery: query
	
]

{ #category : #'accessing query' }
StSpotterModel >> pushQuery: aQuery [

	self schedule: [ 
		mutex critical: [ self activeStep pushQuery: aQuery ]
	]
]

{ #category : #accessing }
StSpotterModel >> pushStepForProcessor: aProcessor [
	| step allCandidates processorLink |

	self activeStep deactivate.

	step := self newStep.
	processorLink := aProcessor asStSpotterProcessorLink.
	allCandidates := aProcessor allFilteredCandidates collect: [ :each | 
		each asStSpotterCandidateLink renderingProcessor: processorLink ].
	step origin: allCandidates.
	steps addLast: step
]

{ #category : #accessing }
StSpotterModel >> results [

	^ self activeStep results
]

{ #category : #accessing }
StSpotterModel >> schedule: aBlock [

	scheduler schedule: [
		aBlock 
			on: Error 
			fork: [ :e | e pass ] ]
]

{ #category : #accessing }
StSpotterModel >> stSpotterProcessorsFor: aStep [

	self defaultProcessors 
		do: [ :each | aStep addProcessor: each ]
]

{ #category : #'accessing query' }
StSpotterModel >> startProcessingOn: spotter [

	self processSearch: '' on: spotter
]

{ #category : #'accessing query' }
StSpotterModel >> stopProcessing [

	self activeStep deactivate.
	scheduler stop
	
]

{ #category : #events }
StSpotterModel >> whenAmountChangedDo: aBlock [

	amountChangedAction := aBlock
]

{ #category : #events }
StSpotterModel >> whenNoResultsDo: aBlock [

	noResultsAction := aBlock
]

{ #category : #events }
StSpotterModel >> whenQueryEndedDo: aBlock [

	queryEndedAction := aBlock
]

{ #category : #events }
StSpotterModel >> whenQueryStartedDo: aBlock [

	queryStartedAction := aBlock
]

{ #category : #events }
StSpotterModel >> whenSearchUpdatedDo: aBlock [

	searchUpdatedAction := aBlock
]
