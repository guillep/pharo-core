Class {
	#name : #StSpotterQuery,
	#superclass : #Object,
	#instVars : [
		'candidatesList',
		'processors',
		'candidateLinks',
		'searchText',
		'finished',
		'spotterPresenter'
	],
	#category : #'NewTools-Spotter-Model'
}

{ #category : #'instance creation' }
StSpotterQuery class >> new [

	self error: 'Use #newSearch:on:'
]

{ #category : #'instance creation' }
StSpotterQuery class >> newSearch: aString on: spotter [

	^ super new 
		spotter: spotter;
		searchText: aString;
		yourself
]

{ #category : #'instance creation' }
StSpotterQuery class >> on: aString [

	^ self basicNew 
		initializeText: aString; 
		yourself
]

{ #category : #private }
StSpotterQuery >> allCandidatesAdded: ann [
	
	ann candidateLinks ifEmpty: [ ^ self ].
	candidateLinks addAll: ann candidateLinks
]

{ #category : #accessing }
StSpotterQuery >> announcer [

	^ self candidatesList announcer
]

{ #category : #private }
StSpotterQuery >> candidateAdded: ann [

	candidateLinks add: ann candidateLink.
	spotterPresenter updateResultList: ann candidateLink
]

{ #category : #accessing }
StSpotterQuery >> candidatesList [

	^ candidatesList
]

{ #category : #private }
StSpotterQuery >> filteringText [
		
	^ self searchText substrings 
		detect: [ :each | each beginsWith: '#' ]
		ifFound: [ :categoryQuery | categoryQuery ]
		ifNone: [ nil ]
]

{ #category : #initialization }
StSpotterQuery >> initialize [

	super initialize.
	self initializeCandidatesList.
	finished := false.	
	candidateLinks := Set new
]

{ #category : #initialization }
StSpotterQuery >> initializeCandidatesList [

	candidatesList := StSpotterCandidatesList new.
	candidatesList announcer 
		when: StSpotterCandidateAdded send: #candidateAdded: to: self;
		when: StSpotterAllCandidatesAdded send: #allCandidatesAdded: to: self.
		"when: GTSpotterAllCandidatesRemoved do: [ self deselect ];
		when: StSpotterQueryStarted send: #queryStarted: to: self;
		when: StSpotterQueryEnded send: #queryEnded: to: self."
]

{ #category : #testing }
StSpotterQuery >> isFinished [

	^ finished
]

{ #category : #accessing }
StSpotterQuery >> links [

	^ candidateLinks
]

{ #category : #'private factory' }
StSpotterQuery >> newContextFor: aStream text: aString [

	^ StSpotterContext new 
		step: self;
		stream: aStream;
		text: aString;
		search: aString;
		yourself
]

{ #category : #'private factory' }
StSpotterQuery >> newStreamFor: candidates [

	^ StSpotterStream new
		onAddedSelector: #addCandidate:in:;
		onRemoveSelector: #removeAllCandidatesOf:;
		receiver: candidates;
		yourself
]

{ #category : #processing }
StSpotterQuery >> process [
	| stream context |

	spotterPresenter removeAll.

	finished := false.
	stream := self newStreamFor: candidatesList.
	context := self newContextFor: stream text: self searchText.
	self relevantProcessors
		do: [ :each | each filterInContext: context ].
	finished := true.

	self candidatesList isEmpty 
		ifTrue: [ spotterPresenter removeAllResults ]
]

{ #category : #accessing }
StSpotterQuery >> processors [

	^ processors
]

{ #category : #accessing }
StSpotterQuery >> processors: aCollection [

	processors := aCollection
]

{ #category : #private }
StSpotterQuery >> relevantProcessors [

	^ self filteringText
		ifNotNil: [ :aString | self relevantProcessorsFor: aString ]
		ifNil: [ self processors ]
]

{ #category : #private }
StSpotterQuery >> relevantProcessorsFor: aString [
		
	^ (self processors select: [ :each | each isRelevantForQuery: aString ])
]

{ #category : #accessing }
StSpotterQuery >> results [

	^ self links collect: [ :each | each value ]
]

{ #category : #accessing }
StSpotterQuery >> searchText [

	^ searchText
]

{ #category : #accessing }
StSpotterQuery >> searchText: aString [

	searchText := aString
]

{ #category : #accessing }
StSpotterQuery >> spotter: aSpotterPresenter [

 spotterPresenter := aSpotterPresenter
]

{ #category : #accessing }
StSpotterQuery >> terminate [

	self processors do: [ :each | each stop ]
]
