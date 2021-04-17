"
I am a extensible spotter processor. 
I perform the integration with Spotter, but also I handle the lifecycle of the query, creating it from the spotter context; storing the results and the filter. 

The filter is divided in two instance variables. The #filter contains the whole iterator that will be used. As some of the parts of the decorator requires to be notified when the filtering text is changed there is a collection of filters that require this.

My subclasses should implement #newTextFilteringSource to return the filtering iterator to use or newSource if the iterator building is more complex (see StUnifiedProcessor).

My subclasses can override #installKeymappingsOn: to install keybindings in Spotter.
Also, there is #configureFilter to extend the configuration of the source when there is a change in the query.

I also handled the notifications when the query finish, so Spotter UI can show it correctly.
"
Class {
	#name : #StSpotterProcessor,
	#superclass : #Object,
	#instVars : [
		'order',
		'filter',
		'results',
		'query',
		'running',
		'textFilteringIterators'
	],
	#classInstVars : [
		'enabled'
	],
	#category : #'NewTools-Spotter-Processors-Processors'
}

{ #category : #accessing }
StSpotterProcessor class >> allConcreteSubclasses [
	
	^ self allSubclasses reject: [ :e | e isAbstract ]
]

{ #category : #accessing }
StSpotterProcessor class >> allEnabledSubclasses [
	
	^ self allConcreteSubclasses select: [ :e | e isEnabled ]
]

{ #category : #'default-settings' }
StSpotterProcessor class >> defaultEnabled [

	^ self subclassResponsibility 
]

{ #category : #settings }
StSpotterProcessor class >> enabled [ 

	^ enabled ifNil: [ self defaultEnabled ]
]

{ #category : #settings }
StSpotterProcessor class >> enabled: aValue [

	enabled := aValue
]

{ #category : #settings }
StSpotterProcessor class >> hideInSettings [

	^ false
]

{ #category : #testing }
StSpotterProcessor class >> isAbstract [ 

	^ self == StSpotterProcessor 
]

{ #category : #testing }
StSpotterProcessor class >> isEnabled [

	self isAbstract
		ifTrue: [ ^ false ].
	^ enabled ifNil: [ self defaultEnabled ] ifNotNil: [ enabled ]
]

{ #category : #accessing }
StSpotterProcessor class >> order [
	
	^ self subclassResponsibility 
]

{ #category : #settings }
StSpotterProcessor class >> settingsDescription [

	^ self title
]

{ #category : #settings }
StSpotterProcessor class >> settingsOn: aBuilder [
	<systemsettings>

	(aBuilder group: #spotterProcessors)
		parent: #spotter;
		label: 'Sources';
		description: 'It configures the sources that are queried when using spotter'.

	self allConcreteSubclasses 
		reject: [ :each | each hideInSettings ] 
		thenDo: [ :aProcessorClass | 
			(aBuilder setting: aProcessorClass name , '_enabled')
				parent: #spotterProcessors;
				default: aProcessorClass defaultEnabled;
				getSelector: #enabled;
				setSelector: #enabled:;
				target: aProcessorClass;
				description: aProcessorClass settingsDescription;
				label: aProcessorClass settingsTitle ]
]

{ #category : #settings }
StSpotterProcessor class >> settingsTitle [

	^ self title
]

{ #category : #accessing }
StSpotterProcessor class >> title [
	
	^ self subclassResponsibility 
]

{ #category : #accessing }
StSpotterProcessor >> actLogic [

	^ [ :anItem :aStep | anItem evaluateFor: aStep ]
]

{ #category : #'spotter-api' }
StSpotterProcessor >> allFilteredCandidates [

	self configureFilter.		
	^ self filter upToEnd
]

{ #category : #filtering }
StSpotterProcessor >> configureFilter [

	self ensureFilter.
	textFilteringIterators do: [ :each | 
		each filteringText: self query searchingText ]
]

{ #category : #filtering }
StSpotterProcessor >> ensureFilter [

	^ filter ifNil: [
		filter := self newSource ]
]

{ #category : #filtering }
StSpotterProcessor >> executeQuery [

	(self query isSearchEmpty and: [ self showForEmptyQuery not ]) 
		ifTrue: [ ^ self ].
	
	self configureFilter.
	
	results := OrderedCollection new.
	[ self isRunning and: [ self filter atEnd or: [ results size = self maxResults ] ] ] 
		whileFalse: [
			self filter next ifNotNil: [ :aResult | 
				self query addResult: aResult.
				results add: aResult ] ].

	(results size = self maxResults)
		ifTrue: [ ^ self ].

	self query informAllResultAmount: results size
]

{ #category : #filtering }
StSpotterProcessor >> filter [ 
	
	^ filter ifNil: [ self ensureFilter ]
]

{ #category : #'spotter-api' }
StSpotterProcessor >> filterInContext: aSpotterContext [ 

	self notifyStarted: aSpotterContext.
	self query updateFromContext: aSpotterContext.
	self executeQuery.
	self notifyEnded: aSpotterContext.
]

{ #category : #initialization }
StSpotterProcessor >> initialize [

	super initialize.
	running := false.
]

{ #category : #'key-bindings' }
StSpotterProcessor >> installKeymappingsOn: aPresenter [ 
	"Nothing to do"
]

{ #category : #'key-bindings' }
StSpotterProcessor >> installKeymappingsOn: aPresenter onExecution: aBlock [

	self installKeymappingsOn: aPresenter
]

{ #category : #'spotter-api' }
StSpotterProcessor >> isRelevantForQuery: categoryQueryPrefix [

	^ (self title asLowercase copyReplaceAll: String space with: '')
			beginsWith: categoryQueryPrefix
]

{ #category : #'spotter-api' }
StSpotterProcessor >> isRunning [ 

	^ running
]

{ #category : #accessing }
StSpotterProcessor >> itemIcon [

	^ [ :anItem | anItem icon ]
]

{ #category : #accessing }
StSpotterProcessor >> itemName [

	^ [ :anItem | anItem asString ]
]

{ #category : #'key-bindings' }
StSpotterProcessor >> keyBinding [ 
	^ nil
]

{ #category : #configuration }
StSpotterProcessor >> maxResults [

	^ StSpotterPragmaBasedProcessor defaultItemsLimit
]

{ #category : #filtering }
StSpotterProcessor >> newSource [

	| source |
	source := self newTextFilteringSource.

	textFilteringIterators := OrderedCollection new.
	textFilteringIterators add: source.
	
	^ source
	
]

{ #category : #filtering }
StSpotterProcessor >> newTextFilteringSource [

	self subclassResponsibility 
]

{ #category : #events }
StSpotterProcessor >> notifyEnded: aSpotterContext [

	running := false.
	aSpotterContext stream 
		performSymbol: #processorEnded: 
		withArguments: { self }.

]

{ #category : #events }
StSpotterProcessor >> notifyStarted: aSpotterContext [

	running := true.
	aSpotterContext stream 
		performSymbol: #processorStarted: 
		withArguments: { self }.

]

{ #category : #accessing }
StSpotterProcessor >> order [

	^ order ifNil: [ self class order ]
]

{ #category : #accessing }
StSpotterProcessor >> order: aNumber [

	^ order
]

{ #category : #accessing }
StSpotterProcessor >> query [

	^ query ifNil: [ 
		query := StQuery new 
			processor: self; 
			yourself ]
]

{ #category : #accessing }
StSpotterProcessor >> query: aQuery [

	query := aQuery
]

{ #category : #filtering }
StSpotterProcessor >> render: anEntry [
		
	^ anEntry render
]

{ #category : #configuration }
StSpotterProcessor >> showForEmptyQuery [

	^ false
]

{ #category : #filtering }
StSpotterProcessor >> stop [

	running := false
]

{ #category : #accessing }
StSpotterProcessor >> title [

	^ self class title
]
