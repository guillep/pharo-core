"
It models one step in the spotter search.

A step knows:
- the origin object 
- the active processors that handle the query, and the candidates
- the selected candidate, and
- the list of all filtered candidates

It also knows the stream through which the list of candidates is affected.

The key method is process:
"
Class {
	#name : #GTSpotterStep,
	#superclass : #Object,
	#instVars : [
		'announcer',
		'processors',
		'origin',
		'context',
		'selected',
		'stream',
		'candidates',
		'asyncTask',
		'spotter',
		'lastSearchContext',
		'event'
	],
	#category : #'GT-Spotter-Model'
}

{ #category : #example }
GTSpotterStep class >> gtExampleBasic [
	<gtExample>
	^ self new
]

{ #category : #actions }
GTSpotterStep >> actDueTo: anEventType [
	"Perform an action associated with currently selected item.
	(can be triggered by doubleClick: or keyboard Enter press)"
	
	self
		assert: [ self hasSelected ]
		description: [ 'Spotter can not perform an action due to ', anEventType asString, ' if there is no selected candidate' ].

	self spotter
		historize: self selected;
		notifyActOn: self selectedCandidate for: anEventType.
	self selectedCategory actOn: self selectedCandidate for: self
]

{ #category : #accessing }
GTSpotterStep >> addProcessor: aProcessor [

	self processors add: aProcessor
]

{ #category : #accessing }
GTSpotterStep >> announcer [

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
GTSpotterStep >> asyncTask [

	^ asyncTask ifNil: [ asyncTask := self defaultTask ]
]

{ #category : #private }
GTSpotterStep >> basicRelevantProcessorsProcess: aSpotterContext do: aBlock [
	aSpotterContext text substrings 
		detect: [ :each | each beginsWith: '#' ]
		ifFound: [ :categoryQuery | 
			| categoryQueryPrefix |
			aSpotterContext text: (aSpotterContext text copyReplaceAll: categoryQuery with: '').
			categoryQueryPrefix := categoryQuery allButFirst asLowercase.
			self processors 
				select: [ :each | each isRelevantForQuery: categoryQueryPrefix ]
				thenDo: aBlock ]
		ifNone: [ 
			self processors do: aBlock ]
]

{ #category : #actions }
GTSpotterStep >> canDiveIn: aCandidate [
	| newFakeStep canDiveIn|
	canDiveIn := false.
	newFakeStep := self spotter newStep origin: self origin.
	self spotter
		addStep: newFakeStep
		during: [ aCandidate spotterProcessorsFor: newFakeStep.
			canDiveIn := newFakeStep processors notEmpty ].
	^ canDiveIn
]

{ #category : #actions }
GTSpotterStep >> canDiveInSelectedCandidate [

	^ self canDiveIn: self selected candidate
]

{ #category : #accessing }
GTSpotterStep >> candidates [

	^ candidates ifNil: [
		candidates := GTSpotterCandidatesList new.
		candidates announcer when: GTSpotterCandidateAdded send: #onCandidateAdded to: self.
		candidates announcer when: GTSpotterAllCandidatesAdded send: #onCandidateAdded to: self.
		candidates announcer when: GTSpotterAllCandidatesRemoved do: [ self deselect ].
		candidates announcer when: GTSpotterQueryStarted send: #propagateEvent: to: self.
		candidates announcer when: GTSpotterQueryEnded send: #propagateEvent: to: self.
		candidates ]
]

{ #category : #processing }
GTSpotterStep >> configureProcessorsStartingAt: anIndex with: aConfigurationBlock [
	"Execute aConfigurationBlock with all processors starting at anIndex.
	(this assumes processors are stored in an OrderedCollection that captures the
	orderin which they are added to the step.)"
	
	(anIndex > self processors size) ifTrue: [ ^ self ].
	anIndex to: self processors size do: [ :processorIndex |
		aConfigurationBlock value: (self processors at: processorIndex) ]
]

{ #category : #accessing }
GTSpotterStep >> context [

	^ context ifNil: [ context := self newContextForQuery: nil ]
]

{ #category : #accessing }
GTSpotterStep >> context: aGTSpotterContext [
	context := aGTSpotterContext
]

{ #category : #'accessing - defaults' }
GTSpotterStep >> defaultStream [
	^ GTSpotterUIThreadStream new
]

{ #category : #'accessing - defaults' }
GTSpotterStep >> defaultTask [
	^ GLMAsyncTask new
]

{ #category : #selecting }
GTSpotterStep >> deselect [
	"Deselects a candidate without notifying anyone"

	selected := nil
]

{ #category : #actions }
GTSpotterStep >> diveIn [
	self diveInDueTo: #undefined
]

{ #category : #actions }
GTSpotterStep >> diveInDueTo: anEventType [
	self canDiveInSelectedCandidate ifTrue: [ 
		self spotter
			historize: self selected;
			requestNextStepWith: self selected candidate for: #diveIn;
			notifyDiveIn: self selected candidate for: anEventType ]
]

{ #category : #accessing }
GTSpotterStep >> event [
	^ event
]

{ #category : #accessing }
GTSpotterStep >> event: anObject [
	event := anObject
]

{ #category : #actions }
GTSpotterStep >> exit [

	self spotter exit
]

{ #category : #inspecting }
GTSpotterStep >> gtInspectorProcessorsIn: composite [
	<gtInspectorPresentationOrder: 40>
	composite list
		title: 'Processors';
		display: [ self processors ];
		format: #displayString;
		when: [ self spotter notNil ]
]

{ #category : #testing }
GTSpotterStep >> hasCandidates [
	"Return true if there are any candidates in all categories,
	false otherwise"
	<return: #Boolean>
	
	^ self candidates isNotEmpty
]

{ #category : #testing }
GTSpotterStep >> hasPreviousNavigationFromClass: aClass [
	"Return true if origin of the previous step is kind of aClass.
	Return false if there is no previous step or if origin is not a kind of aClass"
	<return: #Boolean>
	
	^ self hasPreviousStep and: [
		self previousStep origin isKindOf: aClass ]
]

{ #category : #testing }
GTSpotterStep >> hasPreviousStep [
	"Return true if there is previous step,
	meaning that I am not a first step in spotter,
	false otherwise"
	<return: #Boolean>
	
	^ self spotter hasSteps
		and: [ self spotter steps first ~= self ]
]

{ #category : #testing }
GTSpotterStep >> hasSelected [
	"Return true if there is a selected candidate, false otherwise"
	<return: #Boolean>
	
	^ selected isNotNil
]

{ #category : #testing }
GTSpotterStep >> isCategorySelected: aProcessor [
	"Return true if a category assigned to aProcessor is currently selected,
	false otherwise"
	<return: #Boolean>
	
	^ self hasSelected and: [ self selected processor == aProcessor ]
]

{ #category : #testing }
GTSpotterStep >> isSelected: aCandidateLink [
	"Return true if aCandidateLink is currently selected,
	false otherwise"
	<return: #Boolean>
	
	^ self hasSelected and: [ self selected == aCandidateLink ]
]

{ #category : #accessing }
GTSpotterStep >> listProcessor [
	| processor |
	processor := GTSpotterCandidatesListProcessor new.
	self addProcessor: processor.
	^ processor
]

{ #category : #processing }
GTSpotterStep >> newContextForQuery: aString [
	^ GTSpotterContext new 
		step: self;
		stream: self stream;
		text: aString;
		search: aString;
		yourself
]

{ #category : #notifying }
GTSpotterStep >> notifySelectedCandidateChanged: aDoubleLink [
	
	self notifySelectedCandidateChanged: aDoubleLink for: #unknown
]

{ #category : #notifying }
GTSpotterStep >> notifySelectedCandidateChanged: aCandidateLink for: anEventType [
	| aCandidate |
	
	self
		assert: [ aCandidateLink isNotNil ]
		description: [ 'aCandidateLink must not be nil' ].

	aCandidate := aCandidateLink candidate.
	self announcer announce: (GTSpotterSelectedCandidateChanged new select: aCandidate).
	self spotter notifyCandidateSelected: aCandidate for: anEventType
]

{ #category : #'event processing' }
GTSpotterStep >> onCandidateAdded [
	"Select first candidate item in the list if there is no already selected
	candidate and candidate list has at least one candidate"
	(self hasSelected or: [ self candidates isEmpty ])
		ifFalse: [ self selectFirst ]
]

{ #category : #accessing }
GTSpotterStep >> origin [

	^ origin
]

{ #category : #accessing }
GTSpotterStep >> origin: anObject [

	origin := anObject
]

{ #category : #accessing }
GTSpotterStep >> previousProcessorFrom: aCollection [
	aCollection do: [ :each | 
		each asSpotterCandidateLink processor ifNotNil: [ ^ each processor ] ]. " we assume they are all identical "
	^ GTSpotterCandidatesListProcessor new
		title: 'Items';
		filter: GTFilterSubstring;
		yourself
]

{ #category : #'accessing - dynamic' }
GTSpotterStep >> previousStep [
	"Return a spotter step before me which must exist,
	otherwise behavior is undefined."
	<return: #GTSpotterStep>
	self assert: self hasPreviousStep.
	
	^ self spotter steps at: 
			(self spotter steps indexOf: self) - 1
]

{ #category : #processing }
GTSpotterStep >> process: aString [
	"I do not accept empty queries or the same queries as before.
	If nil is passed, than an empty string will be processed. This approach is used to
	destinguish when user deletes last character in the search and when search field became
	empty after spawning new step"
	
	"no need to search for the same query"
	(self context matches: aString) ifTrue: [ ^ self ].
	self context: (self newContextForQuery: aString).
	
	" updating timestamp in a stream, to prevent candidates from old process being shown "
	self stream updateTimestamp.
	
	self asyncTask
		execute: [ :aCurrentContext |
			self spotter notifyContextChangedFrom: lastSearchContext to: self context.
			self processContext: aCurrentContext ]
		withArguments: { self context. }
		callback: [
			lastSearchContext := self context. 
			self spotter notifySearchFinishedFor: aString processors: self processors ]
		"added small delay before actual searching. It makes spotter faster :)"
		delay: 200
]

{ #category : #processing }
GTSpotterStep >> processContext: aSpotterContext [

	self stream removeAllCandidates.
	self relevantProcessorsProcess: aSpotterContext
]

{ #category : #accessing }
GTSpotterStep >> processors [

	^ processors ifNil: [ 
		processors := OrderedCollection new.
		self origin spotterProcessorsFor: self.
		"this is a hack. we do it here just because we need to store the
		category name in the brick after the processors have been created"
		processors do: [ :each | 				
			self candidates addProcessor: each ].
		processors ]
]

{ #category : #accessing }
GTSpotterStep >> processors: aCollection [

	processors := aCollection
]

{ #category : #'accessing - dynamic' }
GTSpotterStep >> processorsFilter [

	^ self spotter processorsFilter
]

{ #category : #'event processing' }
GTSpotterStep >> propagateEvent: ann [ 

	self announcer announce: ann

	
]

{ #category : #private }
GTSpotterStep >> relevantProcessorsProcess: aSpotterContext [
	self basicRelevantProcessorsProcess: aSpotterContext do: [ :processor | 
		processor filterInContext: aSpotterContext ].
	aSpotterContext continueFilter
]

{ #category : #selecting }
GTSpotterStep >> select: aCandidateLink [
	"Select a given candidate link due to unknown reason.
	It is not recommended to use this method, unless you really need to.
	Note: use #select:dueTo: to allow better usage statistics"
	
	self select: aCandidateLink dueTo: #unknown
]

{ #category : #selecting }
GTSpotterStep >> select: aCandidateLink dueTo: anEventType [
	"Select a given candidate due to provided event type.
	A selection reason is used for statistical purposes and helps us
	better understand how users use spotter and as result improve it.
	aCandidateLink must not be nil.
	anEventType must not be nil"

	self
		assert: [ aCandidateLink isNotNil ]
		description: [ 'Candidate link must not be nil' ].

	self
		assert: [ aCandidateLink processor isNotNil ]
		description: [ 'Candidate must have assigned category (processor)' ].
	
	"A given candidate is already selected, do nothing"
	(self isSelected: aCandidateLink)
		ifTrue: [ ^ self ].

	self spotter
		after: [
			selected := aCandidateLink.
			self notifySelectedCandidateChanged: aCandidateLink for: anEventType ]
		do: [ self spotter notifyCategorySelected: self selected processor ]
		ifTrue: [ (self isCategorySelected: aCandidateLink processor) not ]
]

{ #category : #selecting }
GTSpotterStep >> selectFirst [
	"Select the first candidate.
	Note: there must be at least one candidate in order to select first,
	make sure to check #hasCandidates before using me"
	self
		assert: [ self candidates isNotEmpty ]
		description: [ 'There must be at least one candidate in order to select the first' ].

	self select: self candidates head
]

{ #category : #selecting }
GTSpotterStep >> selectNextCategory [
	| currentCategory nextCategory |

	currentCategory := self candidates getProcessorLinkByCandidateLink: self selected.
	nextCategory := self candidates nextProcessorLinkOf: currentCategory.
	
	self select: ((currentCategory = nextCategory)
		ifTrue: [ nextCategory tailLink ]
		ifFalse: [ nextCategory headLink ])
]

{ #category : #selecting }
GTSpotterStep >> selectNextDueTo: anEventType [
	
	self select: self selected next dueTo: anEventType
]

{ #category : #selecting }
GTSpotterStep >> selectPreviousCategory [
	|currentCategory previousCategory|
	self selected ifNil: [ ^ self ].
	
	currentCategory := self candidates getProcessorLinkByCandidateLink: self selected.
	previousCategory := self candidates previousProcessorLinkOf: currentCategory.
	
	self select: previousCategory headLink
]

{ #category : #selecting }
GTSpotterStep >> selectPreviousDueTo: anEventType [

	self select: self selected previous dueTo: anEventType
]

{ #category : #'accessing - selected' }
GTSpotterStep >> selected [
	"Return a candidate link (represented by double link) to allow fast access to
	next and previous candidate. In order to get actual candidate object behind
	the link send #candidate to it.
	selected can not be nil (always use hasSelected before using me)"
	<return: #GTSpotterCandidateLink>
	self
		assert: [ selected isNotNil ]
		description: [ 'Selected candidate can not be accessed where there is no one' ].
	
	^ selected
]

{ #category : #'accessing - selected' }
GTSpotterStep >> selectedCandidate [
	"Return an actual candidate object behind candidate link. 
	Note: Since selected link can not be accessed if there is no selected one,
	always check #hasSelected before using me"
	<return: #Object>

	^ self selected candidate
]

{ #category : #'accessing - selected' }
GTSpotterStep >> selectedCategory [
	"Return a category processor that produced a currently selected candidate.
	Note: Since selected link can not be accessed if there is no selected one,
	always check #hasSelected before using me"
	
	^ self selected processor
]

{ #category : #accessing }
GTSpotterStep >> spotter [

	^ spotter
]

{ #category : #accessing }
GTSpotterStep >> spotter: aSpotter [
	spotter := aSpotter 
]

{ #category : #accessing }
GTSpotterStep >> stream [

	^ stream ifNil: [
		stream := self defaultStream.
		stream
			onAddedSelector: #addCandidate:in:;
			onRemoveSelector: #removeAllCandidatesOf:;
			receiver: self candidates.
		stream ]
]

{ #category : #actions }
GTSpotterStep >> terminateProcessors [

	self asyncTask terminate
]
