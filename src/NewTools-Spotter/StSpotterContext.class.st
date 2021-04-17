Class {
	#name : #StSpotterContext,
	#superclass : #Object,
	#instVars : [
		'step',
		'stream',
		'search',
		'text',
		'textTrimmed',
		'textLowercase',
		'processor',
		'filter',
		'streamed',
		'cache',
		'continuing'
	],
	#category : #'NewTools-Spotter-Model'
}

{ #category : #public }
StSpotterContext >> addItem: anObject [

	self stream 
		addObject: anObject 
		inProcessor: self processor
]

{ #category : #public }
StSpotterContext >> addItems: aCollection [

	self stream 
		addObjects: aCollection 
		inProcessor: self processor
]

{ #category : #accessing }
StSpotterContext >> cache [
	^ cache
]

{ #category : #accessing }
StSpotterContext >> cache: anObject [
	cache := anObject
]

{ #category : #public }
StSpotterContext >> cacheAt: aSymbol [
	^ self cacheAt: aSymbol ifAbsent: [ nil ]
]

{ #category : #public }
StSpotterContext >> cacheAt: aSymbol ifAbsent: aBlock [
	^ self cache at: aSymbol ifAbsent: aBlock
]

{ #category : #public }
StSpotterContext >> cacheAt: aSymbol ifAbsentPut: aBlock [
	^ self cache at: aSymbol ifAbsentPut: aBlock
]

{ #category : #public }
StSpotterContext >> cacheAt: aSymbol put: anObject [
	^ self cache at: aSymbol put: anObject
]

{ #category : #testing }
StSpotterContext >> canContinue [
	 " divein / really ugly, spotter-step does not really know why it was created or where it comes from :( "
	" another hack: diveIncategory must never continue because it just streams all items from the previous step. continuing in diveInCategory would duplicate all items! " 
	^ self step event == #diveIn
		or: [ self step event isNil ]
]

{ #category : #private }
StSpotterContext >> continueFilter [
	| processors nonEmptyProcessors |
	processors := self cache at: #processorsAndFilters ifAbsent: [ ^ self ].
	nonEmptyProcessors := processors associations select: [ :assoc | assoc key hasFilteredCandidates ].
	nonEmptyProcessors size = 1 ifFalse: [ ^ self ].
	self canContinue ifFalse: [ ^ self ].
	
	self withContinue: true do: [ 
		nonEmptyProcessors do: [ :assoc | 
			assoc key continueFilterInContext: self ] ]
]

{ #category : #accessing }
StSpotterContext >> continuing [
	^ continuing
]

{ #category : #accessing }
StSpotterContext >> continuing: anObject [
	continuing := anObject
]

{ #category : #'accessing-defaults' }
StSpotterContext >> defaultCache [
	^ IdentityDictionary new 
		at: #processorsAndFilters put: (IdentityDictionary new: 100); " not a limitation, just a reasonable start size "
		at: #processorsAndStreamed put: (IdentityDictionary new: 100); " not a limitation, just a reasonable start size "
		yourself
]

{ #category : #'accessing-defaults' }
StSpotterContext >> defaultContinuing [
	^ false
]

{ #category : #'accessing-defaults' }
StSpotterContext >> defaultText [
	^ ''
]

{ #category : #'accessing-defaults' }
StSpotterContext >> defaultTextLowercase [
	^ self textTrimmed asLowercase
]

{ #category : #'accessing-defaults' }
StSpotterContext >> defaultTextTrimmed [
	^ self text trimBoth
]

{ #category : #private }
StSpotterContext >> doContinueFilterForProcessor: aGTProcessor [
	self processor: aGTProcessor.
	self filter: ((self cache at: #processorsAndFilters) at: aGTProcessor).
	self streamed: ((self cache at: #processorsAndStreamed) at: aGTProcessor).

	^ aGTProcessor withItemsLimit: aGTProcessor continueItemsLimit do: [ filter value: self ]
]

{ #category : #private }
StSpotterContext >> doFilter: aFilter forProcessor: aProcessor [

	self processor: aProcessor.
	self filter: aFilter.
	self streamed: (OrderedCollection new: 100). " not a limitation, just a reasonable start size "
	(self cache at: #processorsAndFilters) at: aProcessor put: aFilter.
	(self cache at: #processorsAndStreamed) at: aProcessor put: streamed.

	^ aFilter value: self
]

{ #category : #comparing }
StSpotterContext >> equals: aContext [
	aContext ifNil: [ ^ false ].
   ^ self matches: aContext search
]

{ #category : #accessing }
StSpotterContext >> filter [
	^ filter
]

{ #category : #accessing }
StSpotterContext >> filter: anObject [
	filter := anObject
]

{ #category : #initialization }
StSpotterContext >> initialize [
	super initialize.
	
	cache := self defaultCache.
	text := self defaultText.
	continuing := self defaultContinuing.
]

{ #category : #testing }
StSpotterContext >> isContinuing [
	^ self continuing 
		and: [ self streamed isEmptyOrNil not 
			and: [ self canContinue ] ]
]

{ #category : #testing }
StSpotterContext >> isEmpty [
	^ self text isNil
		or: [ self textTrimmed isEmpty ]
]

{ #category : #public }
StSpotterContext >> itemsLimit [
	^ self processor itemsLimit
]

{ #category : #testing }
StSpotterContext >> matches: aString [
	^ self isEmpty not
		and: [ self search = aString ]
]

{ #category : #testing }
StSpotterContext >> notEmpty [
	^ self isEmpty not
]

{ #category : #accessing }
StSpotterContext >> processor [
	^ processor
]

{ #category : #accessing }
StSpotterContext >> processor: anObject [
	processor := anObject
]

{ #category : #public }
StSpotterContext >> removeCacheAt: aSymbol [
	^ self cache removeKey: aSymbol ifAbsent: [ nil ]
]

{ #category : #initializing }
StSpotterContext >> search [
	^ search
]

{ #category : #initializing }
StSpotterContext >> search: anObject [
	" search stores the fully entered text (including categories) "
	search := anObject
]

{ #category : #'accessing-dynamic' }
StSpotterContext >> spotter [
	^ self step spotter
]

{ #category : #accessing }
StSpotterContext >> step [
	^ step
]

{ #category : #accessing }
StSpotterContext >> step: anObject [
	step := anObject
]

{ #category : #accessing }
StSpotterContext >> stream [
	^ stream
]

{ #category : #accessing }
StSpotterContext >> stream: anObject [
	stream := anObject
]

{ #category : #accessing }
StSpotterContext >> streamed [
	^ streamed
]

{ #category : #accessing }
StSpotterContext >> streamed: anObject [
	streamed := anObject
]

{ #category : #accessing }
StSpotterContext >> text [
	^ text
]

{ #category : #accessing }
StSpotterContext >> text: anObject [
	text := anObject ifNil: [ self defaultText ]
]

{ #category : #public }
StSpotterContext >> textLowercase [
	^ textLowercase ifNil: [ textLowercase := self defaultTextLowercase ]
]

{ #category : #public }
StSpotterContext >> textTrimmed [
	^ textTrimmed ifNil: [ textTrimmed := self defaultTextTrimmed ]
]

{ #category : #private }
StSpotterContext >> withContinue: aBoolean do: aBlock [
	| previousContinuing |
	previousContinuing := continuing.
	^ [ continuing := aBoolean. aBlock value ]
		ensure: [ continuing := previousContinuing ]
]
