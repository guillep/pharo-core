Class {
	#name : #StSpotterStep,
	#superclass : #Object,
	#instVars : [
		'model',
		'origin',
		'activeQuery',
		'processors'
	],
	#category : #'NewTools-Spotter-Model'
}

{ #category : #'instance creation' }
StSpotterStep class >> on: aSpotterModel [

	^ self new 
		model: aSpotterModel;
		yourself
]

{ #category : #accessing }
StSpotterStep >> activate [

	activeQuery ifNil: [ ^ self ].
	self activateQuery: activeQuery
]

{ #category : #private }
StSpotterStep >> activateQuery: aQuery [

	activeQuery ifNotNil: [ self disconnectQuery: aQuery ].
	activeQuery := aQuery.
	self connectQuery: aQuery.
	self refreshQueryStatus: aQuery
]

{ #category : #accessing }
StSpotterStep >> activeQuery [

	^ activeQuery
]

{ #category : #accessing }
StSpotterStep >> addProcessor: processor [
	
	processors add: processor
]

{ #category : #accessing }
StSpotterStep >> candidatesList [

	^ activeQuery 
		ifNotNil: [ :aQuery | aQuery candidatesList ]
		ifNil: [ #() ]
]

{ #category : #private }
StSpotterStep >> connectQuery: aQuery [

	aQuery announcer
		when: StSpotterCandidateAdded send: #announceCandidateAdded: to: self model;
		when: StSpotterAllCandidatesAdded send: #announceAllCandidatesAdded: to: self model;
		when: StSpotterCandidatesAmountChanged send: #announceAmountChanged: to: self model;
		when: StSpotterQueryStarted send: #announceQueryStarted: to: self model;
		when: StSpotterQueryEnded send: #announceQueryEnded: to: self model.
]

{ #category : #accessing }
StSpotterStep >> deactivate [

	self activeQuery ifNil: [ ^ self ].

	self activeQuery terminate.
	self disconnectQuery: self activeQuery.

]

{ #category : #private }
StSpotterStep >> disconnectQuery: aQuery [

	aQuery announcer unsubscribe: self model
]

{ #category : #accessing }
StSpotterStep >> lastSearchText [

	^ self activeQuery searchText
]

{ #category : #accessing }
StSpotterStep >> links [

	^ activeQuery 
		ifNotNil: [ :aQuery | aQuery links ]
		ifNil: [ #() ]
]

{ #category : #factory }
StSpotterStep >> listProcessor [
	| processor |
	
	processor := StSpotterCandidatesListProcessor new.
	self addProcessor: processor.
	
	^ processor
]

{ #category : #accessing }
StSpotterStep >> model [

	^ model
]

{ #category : #accessing }
StSpotterStep >> model: aSpotterModel [

	model := aSpotterModel
]

{ #category : #accessing }
StSpotterStep >> origin [

	^ origin
]

{ #category : #accessing }
StSpotterStep >> origin: anObject [

	origin := anObject
]

{ #category : #accessing }
StSpotterStep >> previousProcessorFrom: aCollection [

	aCollection do: [ :each | 
		" we assume they are all identical "
		each asStSpotterCandidateLink processor ifNotNil: [ ^ each processor ] ]. 
	
	^ StSpotterCandidatesListProcessor new
		title: 'Items';
		filter: StFilterSubstring;
		yourself
]

{ #category : #accessing }
StSpotterStep >> processors [

	^ processors ifNil: [ 
		processors := OrderedCollection new.
		self origin stSpotterProcessorsFor: self.
		processors ]
]

{ #category : #accessing }
StSpotterStep >> processors: aCollection [

	processors := aCollection
]

{ #category : #'accessing query' }
StSpotterStep >> pushQuery: aQuery [

	self deactivate.
	
	aQuery processors: (self processors sort: #order ascending).
	self activateQuery: aQuery.
	aQuery process
]

{ #category : #private }
StSpotterStep >> refreshQueryStatus: aQuery [

	aQuery links ifEmpty: [ ^ self ].

	self model announceAllCandidatesAdded: (StSpotterAllCandidatesAdded new
		candidateLinks: aQuery links;
		yourself).

	aQuery isFinished ifTrue: [ 
		self model announceAmountChanged: (StSpotterCandidatesAmountChanged new 
			amount: aQuery links size;
			yourself) ]
]

{ #category : #accessing }
StSpotterStep >> results [

	^ activeQuery 
		ifNotNil: [ :aQuery | aQuery results ]
		ifNil: [ #() ]
]
