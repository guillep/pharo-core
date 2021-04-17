"
I am a extensible spotter processor. 
I perform the integration with Spotter, but also I handle the lifecycle of the query, creating it from the spotter context; storing the results and the filter. 

The filter is divided in two instance variables. The #filter contains the whole iterator that will be used. As some of the parts of the decorator requires to be notified when the filtering text is changed there is a collection of filters that require this.

My subclasses should implement #newTextFilteringSource to return the filtering iterator to use or newSource if the iterator building is more complex (see SptUnifiedProcessor).

My subclasses can override #installKeymappingsOn: to install keybindings in Spotter.
Also, there is #configureFilter to extend the configuration of the source when there is a change in the query.

I also handled the notifications when the query finish, so Spotter UI can show it correctly.
"
Class {
	#name : #SptSpotterProcessor,
	#superclass : #AbstractSpotterProcessor,
	#instVars : [
		'filter',
		'results',
		'query',
		'spotterMorph',
		'running',
		'textFilteringIterators'
	],
	#classInstVars : [
		'enabled'
	],
	#category : #'GT-Spotter-Processors-Processors'
}

{ #category : #accessing }
SptSpotterProcessor class >> allConcreteSubclasses [
	
	^ self allSubclasses reject: [ :e | e isAbstract ]
]

{ #category : #'default-settings' }
SptSpotterProcessor class >> defaultEnabled [

	^ self subclassResponsibility 
]

{ #category : #settings }
SptSpotterProcessor class >> enabled [ 

	^ enabled ifNil: [ self defaultEnabled ]
]

{ #category : #settings }
SptSpotterProcessor class >> enabled: aValue [

	enabled := aValue
]

{ #category : #settings }
SptSpotterProcessor class >> hideInSettings [

	^ false
]

{ #category : #testing }
SptSpotterProcessor class >> isAbstract [ 

	^ self == SptSpotterProcessor 
]

{ #category : #testing }
SptSpotterProcessor class >> isEnabled [

	self isAbstract
		ifTrue: [ ^ false ].
	^ enabled ifNil: [ self defaultEnabled ] ifNotNil: [ enabled ]
]

{ #category : #accessing }
SptSpotterProcessor class >> order [
	
	^ self subclassResponsibility 
]

{ #category : #settings }
SptSpotterProcessor class >> settingsDescription [

	^ self title
]

{ #category : #settings }
SptSpotterProcessor class >> settingsOn: aBuilder [
	"<systemsettings>

	(aBuilder group: #spotterProcessors)
		parent: #spotter;
		label: 'Sources';
		description: 'It configures the sources that are queried when using spotter'.

	self allConcreteSubclasses reject: [:e | e hideInSettings ] thenDo: [ :aProcessorClass | 
		(aBuilder setting: aProcessorClass name , '_enabled')
			parent: #spotterProcessors;
			default: aProcessorClass defaultEnabled;
			getSelector: #enabled;
			setSelector: #enabled:;
			target: aProcessorClass;
			description: aProcessorClass settingsDescription;
			label: aProcessorClass settingsTitle
	]."
]

{ #category : #settings }
SptSpotterProcessor class >> settingsTitle [

	^ self title
]

{ #category : #accessing }
SptSpotterProcessor class >> title [
	
	^ self subclassResponsibility 
]

{ #category : #compatibility }
SptSpotterProcessor >> actLogic [
	^ [ :anItem :aStep | anItem evaluateFor: aStep ]
]

{ #category : #'spotter-api' }
SptSpotterProcessor >> actOn: anEntry for: aGTSpotterStep [ 

	^ anEntry evaluateFor: aGTSpotterStep
]

{ #category : #'spotter-api' }
SptSpotterProcessor >> allFilteredCandidates [

	self configureFilter.		
	^ self filter upToEnd
]

{ #category : #filtering }
SptSpotterProcessor >> configureFilter [

	self ensureFilter.
	textFilteringIterators do: [:e | 
		e filteringText: self query searchingText]
]

{ #category : #configuring }
SptSpotterProcessor >> configureOn: aGTSpotterStep [ 

	^ aGTSpotterStep addProcessor: self
]

{ #category : #filtering }
SptSpotterProcessor >> ensureFilter [

	^ filter ifNil: [
		filter := self newSource]
]

{ #category : #filtering }
SptSpotterProcessor >> executeQuery [

	(self query isSearchEmpty and: [self showForEmptyQuery not]) 
		ifTrue: [ ^ self ].
	
	self configureFilter.
		
	results := OrderedCollection new.

	[ self filter atEnd or: [ results size = self maxResults ] ] 
		whileFalse: [ self filter next ifNotNil: [ :aResult | 
				self query addResult: aResult.
				results add:aResult.
		]].

	(results size = self maxResults ) 
		ifTrue: [ ^ self ].

	self query informAllResultAmount: results size.	

]

{ #category : #filtering }
SptSpotterProcessor >> filter [ 
	
	^ filter ifNil: [ self ensureFilter ]
]

{ #category : #'spotter-api' }
SptSpotterProcessor >> filterInContext: aSpotterContext [ 

	self notifyStarted: aSpotterContext.
	self query updateFromContext: aSpotterContext.
	self executeQuery.
	self notifyEnded: aSpotterContext.

]

{ #category : #initialization }
SptSpotterProcessor >> initialize [

	super initialize.
	running := false.
]

{ #category : #'key-bindings' }
SptSpotterProcessor >> installKeymappingsOn: aGTSpotterMorph [ 
	
	"Nothing to do"
]

{ #category : #'spotter-api' }
SptSpotterProcessor >> isRelevantForQuery: categoryQueryPrefix [

	^ (self title asLowercase copyReplaceAll: String space with: '')
			beginsWith: categoryQueryPrefix
]

{ #category : #'spotter-api' }
SptSpotterProcessor >> isRunning [ 

	^ running
]

{ #category : #compatibility }
SptSpotterProcessor >> itemFilterName [

	^ self title
]

{ #category : #compatibility }
SptSpotterProcessor >> itemIcon [
	^ [ :anItem | anItem icon ]
]

{ #category : #compatibility }
SptSpotterProcessor >> itemName [
	^ [ :anItem | anItem asString ]
]

{ #category : #'key-bindings' }
SptSpotterProcessor >> keyBinding [ 
	^ nil
]

{ #category : #configuration }
SptSpotterProcessor >> maxResults [

	^ GTSpotterPragmaBasedProcessor defaultItemsLimit 
]

{ #category : #filtering }
SptSpotterProcessor >> newSource [

	| source |
	source := self newTextFilteringSource.

	textFilteringIterators := OrderedCollection new.
	textFilteringIterators add: source.
	
	^ source
	
]

{ #category : #filtering }
SptSpotterProcessor >> newTextFilteringSource [

	self subclassResponsibility 
]

{ #category : #events }
SptSpotterProcessor >> notifyEnded: aSpotterContext [

	running := false.
	aSpotterContext stream 
		performSymbol: #processorEnded: 
		withArguments: { self }.

]

{ #category : #events }
SptSpotterProcessor >> notifyStarted: aSpotterContext [

	running := true.
	aSpotterContext stream 
		performSymbol: #processorStarted: 
		withArguments: { self }.

]

{ #category : #accessing }
SptSpotterProcessor >> order [

	^ self class order
]

{ #category : #accessing }
SptSpotterProcessor >> query [

	^ query ifNil: [ query := SptQuery new processor: self; yourself ]
]

{ #category : #filtering }
SptSpotterProcessor >> render: anEntry [
		
	^ anEntry render
]

{ #category : #configuration }
SptSpotterProcessor >> showForEmptyQuery [

	^ false
]

{ #category : #accessing }
SptSpotterProcessor >> spotterMorph [
	^ spotterMorph
]

{ #category : #accessing }
SptSpotterProcessor >> title [

	^ self class title
]
