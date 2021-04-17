"
I am  the main model class.

I handle the list of current search steps and provide the main functionality for spawning new search steps or removing old ones.
I maintain search steps as a stack.
 
I  trigger a search when the user enters a query (#setText:from:) and maintain the search text.

To avoid crashes due to exceptions in search processors I can install an exception handler that prints exceptions to the transcript instead of opening a debugger (#beDeployment). Afternatively I can install an exception handler that  propagates exceptions (#beDeployment)
"
Class {
	#name : #GTSpotter,
	#superclass : #Object,
	#instVars : [
		'foundationOrigin',
		'steps',
		'announcer',
		'currentStep',
		'pagerModel',
		'text',
		'isPreviewVisible',
		'isShiftPressed',
		'history',
		'processorsFilter'
	],
	#classInstVars : [
		'history',
		'isPreviewVisible',
		'wasOpened'
	],
	#category : #'GT-Spotter-Model'
}

{ #category : #cleanup }
GTSpotter class >> cleanUp [
	self resetHistory.
	wasOpened := false
]

{ #category : #accessing }
GTSpotter class >> dontShowPreview [

	isPreviewVisible := false
]

{ #category : #example }
GTSpotter class >> exampleSpotterWithoutMorph [
	<sampleInstance>
	<gtExample>
	<label: 'A GTSpotter without UI'>
	
	^ self new
]

{ #category : #accessing }
GTSpotter class >> extensionsPragma [
	^ #spotterOrder:
]

{ #category : #inspecting }
GTSpotter class >> gtInspectorExtensionsIn: composite [
	<gtInspectorPresentationOrder: 40>
	composite list
		title: 'Extensions';
		display: [ self spotterExtendingMethods ];
		showOnly: 50;
		format: [ :each | each displayString ];
		filterOn: [ :text :each | each displayString includesSubstring: text caseSensitive: false ]
]

{ #category : #accessing }
GTSpotter class >> history [
	^ history ifNil: [ history := WeakOrderedCollection new ]
]

{ #category : #testing }
GTSpotter class >> isPreviewVisible [

	^ isPreviewVisible ifNil: [ isPreviewVisible := false ]
]

{ #category : #accessing }
GTSpotter class >> markOpened [

	wasOpened := true
]

{ #category : #'instance creation' }
GTSpotter class >> on: anObject [
	
	^ self new foundationOrigin: anObject
]

{ #category : #'instance creation' }
GTSpotter class >> open [
	| spotterModel |
		
	GTSpotterGlobalShortcut reset.
	spotterModel := self new.
		
	GTSpotterMorph new
		extent: (self currentWorld width / 2.4 @ (self currentWorld height / 1.6)) asIntegerPoint;
		spotterModel: spotterModel;
		doLayout;
		openCenteredInWorld;
		initializeListeners;
		takeKeyboardFocus.
		
	spotterModel class markOpened
]

{ #category : #accessing }
GTSpotter class >> previewVisible [

	^ self isPreviewVisible 
]

{ #category : #accessing }
GTSpotter class >> previewVisible: aValue [

	isPreviewVisible := aValue
]

{ #category : #'instance creation' }
GTSpotter class >> registerToolsOn: registry [
	"self registerToolsOn: Smalltalk tools"

	"registry register: self as: #spotter"
]

{ #category : #accessing }
GTSpotter class >> resetHistory [
	"
	self resetHistory
	"
	^ history := nil
]

{ #category : #testing }
GTSpotter class >> settingsOn: aBuilder [
	"<systemsettings>
	(aBuilder group: #spotter)
		parent: #tools;
		label: 'Spotter';
		description: 'Spotter configuration'.

	(aBuilder setting: #previewVisible)
		parent: #spotter;
		default: false;
		target: self;
		description: 'If Spotter will show the preview panel on the right of spotter';
		label: 'Show Preview Panel'."
]

{ #category : #accessing }
GTSpotter class >> showPreview [

	isPreviewVisible := true
]

{ #category : #inspecting }
GTSpotter class >> spotterExtendingMethods [
	^(SystemNavigation default allBehaviors
		flatCollect: [ :each | 
			(Pragma allNamed: self extensionsPragma in: each) 
				collect: [ :p | p method asRingDefinition ] ])
		sorted
]

{ #category : #testing }
GTSpotter class >> wasOpened [

	^ wasOpened ifNil: [ false ]
]

{ #category : #'actions api' }
GTSpotter >> addStep: aStepModel [

	self steps add: aStepModel.
	self notifyStepAdded: aStepModel
]

{ #category : #'actions api' }
GTSpotter >> addStep: aSpotterStep during: aBlock [
	"Adds aSpotterStep without announcements,
	evaluates aBlock and removes previously added
	step after evaluation.
	May be used to determine if it is possible to dive in
	a candidate by adding a fake step to simulate dive in.
	aSpotterStep must not be nil
	aBlock must not be nil"
	self assert: aSpotterStep isNotNil.
	self assert: aBlock isNotNil.
	
	self steps add: aSpotterStep.
	aBlock ensure: [ 
		self steps remove: aSpotterStep ]
]

{ #category : #'actions api' }
GTSpotter >> after: afterBlock do: doBlock ifTrue: conditionBlock [
	|value|
	value := conditionBlock brickValue: self.
	afterBlock brickValue: self.
	value ifTrue: [ doBlock brickValue: value ]
]

{ #category : #'actions api' }
GTSpotter >> after: afterBlock do: doBlock with: withBlock [
	|value|
	value := withBlock brickValue: self.
	afterBlock brickValue: self.
	doBlock brickValue: value
]

{ #category : #notifying }
GTSpotter >> announce: anAnnouncement [
	
	self announcer announce: anAnnouncement
]

{ #category : #accessing }
GTSpotter >> announcer [

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
GTSpotter >> currentStep [
	^ currentStep
		ifNil: [ self hasSteps
				ifTrue: [ currentStep := self steps last ]
				ifFalse: [ self newStep origin: self foundationOrigin ] ]
]

{ #category : #accessing }
GTSpotter >> currentStep: aStepModel [
	
	currentStep := aStepModel.
	self notifyCurrentStepChanged
]

{ #category : #accessing }
GTSpotter >> defaultFilterClass [
    ^ GTFilterFuzzy
]

{ #category : #'accessing-defaults' }
GTSpotter >> defaultPagerModel [
	^ GLMPagerModel new
]

{ #category : #'accessing-defaults' }
GTSpotter >> defaultStep [
	^ GTSpotterStep new
]

{ #category : #printing }
GTSpotter >> displayStringOn: stream [

	stream nextPutAll: 'Spotter'
]

{ #category : #'actions api' }
GTSpotter >> doIt [
	| result |
	Smalltalk compiler
		silentlyDo: [ result := Smalltalk compiler evaluate: text string trimBoth ]
		exceptionDo: [:ex | ^ex ]. 
	"self exitDueTo: #doIt"
]

{ #category : #'actions api' }
GTSpotter >> exit [

	self exitDueTo: #unknown
]

{ #category : #'actions api' }
GTSpotter >> exitDueTo: anEventType [

	self notifySpotterExitFor: anEventType
]

{ #category : #filtering }
GTSpotter >> filterByMethods: aCollection [
	| filter |
	
	filter := GTSpotterMethodListProcessorFilter new.
	aCollection  do: [ :aMethod |
		filter allowProcessorsFrom: aMethod ].
	self processorsFilter: filter
		
]

{ #category : #accessing }
GTSpotter >> foundationOrigin [
	
	^ foundationOrigin ifNil: [ foundationOrigin := self ]
]

{ #category : #accessing }
GTSpotter >> foundationOrigin: anObject [
	
	foundationOrigin := anObject
]

{ #category : #'model access' }
GTSpotter >> getText [

	^ self text
]

{ #category : #printing }
GTSpotter >> gtDisplayOn: stream [

	stream nextPutAll: 'Spotter'
]

{ #category : #testing }
GTSpotter >> hasMultipleSteps [

	^ self steps size > 1
]

{ #category : #testing }
GTSpotter >> hasSelected [
	^ self hasSteps and: [ self currentStep hasSelected ]
]

{ #category : #testing }
GTSpotter >> hasSteps [
	^ 	self steps isNotEmpty
]

{ #category : #'actions api' }
GTSpotter >> hidePreview [

	self isPreviewVisible ifFalse: [ ^ self ].
	isPreviewVisible := false.
	self class dontShowPreview.
	self notifyHidePreview
	
]

{ #category : #'actions api' }
GTSpotter >> historize: target [

	(target = self or: [ target isNil ])
		ifFalse: [ 
			self history removeAllSuchThat: [ :each | each value = target value ] .
			self history addFirst: target ]
]

{ #category : #accessing }
GTSpotter >> history [
	^ history ifNil: [ self class history ]
]

{ #category : #accessing }
GTSpotter >> history: aWeakCollection [
	history := aWeakCollection
]

{ #category : #initialization }
GTSpotter >> initialize [
	super initialize.
	
	processorsFilter := GTSpotterSettingsProcessorFilter new
]

{ #category : #testing }
GTSpotter >> isEmpty [
	self 
		deprecated: 'Use hasSteps instead'
		transformWith: '`@rec isEmpty' -> '`@rec hasSteps not'.
	^ self hasSteps not
]

{ #category : #testing }
GTSpotter >> isPreviewVisible [

	^ isPreviewVisible ifNil: [ isPreviewVisible := false ]
]

{ #category : #accessing }
GTSpotter >> isShiftPressed [

	^ isShiftPressed ifNil: [ isShiftPressed := false ]
]

{ #category : #protocol }
GTSpotter >> menu [

	^ nil
]

{ #category : #'instance creation' }
GTSpotter >> newStep [

	| step |
	
	step := self defaultStep
						spotter: self;
						yourself.
	
	step announcer 
			when: GTSpotterQueryStarted send: #propagateEvent: to: self;
			when: GTSpotterQueryEnded send: #propagateEvent: to: self.

	^ step
]

{ #category : #notifying }
GTSpotter >> notifyActOn: anObject for: anEventType [

	self announce: (GTSpotterActOn new 
		element: anObject;
		eventType: anEventType)
]

{ #category : #notifying }
GTSpotter >> notifyCandidateSelected: anObject for: anEventType [

	self announce: (GTSpotterSelectedCandidateChanged new 
		select: anObject;
		eventType: anEventType)
]

{ #category : #notifying }
GTSpotter >> notifyCategorySelected: aProcessor [

	self announce: (GTSpotterCategorySelected new category: aProcessor)
]

{ #category : #notifying }
GTSpotter >> notifyContextChangedFrom: aPreviousContext to: aCurrentContext [
	self announce: (GTSpotterContextChanged new
		previous: aPreviousContext;
		current: aCurrentContext;
		yourself)
]

{ #category : #notifying }
GTSpotter >> notifyCurrentStepChanged [

	self announce: GTSpotterCurrentStepChanged new
]

{ #category : #notifying }
GTSpotter >> notifyDiveIn: anObject for: anEventType [

	self announce: (GTSpotterDiveInElement new 
		element: anObject;
		eventType: anEventType )
]

{ #category : #notifying }
GTSpotter >> notifyDiveInCategory: aProcessor for: anEventType [

	self announce: (GTSpotterDiveInCategory new 
		category: aProcessor;
		eventType: anEventType)
]

{ #category : #notifying }
GTSpotter >> notifyDiveOut: anObject [

	self announce: (GTSpotterDiveOut new element: anObject)
]

{ #category : #notifying }
GTSpotter >> notifyHideHints [

	self announce: GTSpotterHideHints new
]

{ #category : #notifying }
GTSpotter >> notifyHidePreview [

	self announce: GTSpotterHidePreview new
]

{ #category : #notifying }
GTSpotter >> notifyRevealHints [

	self announce: GTSpotterRevealHints new
]

{ #category : #notifying }
GTSpotter >> notifySearchFinishedFor: aString processors: aCollectionOfProcessors [

	self announce: (GTSpotterSearchFinished new 
								query: aString;
								processors: aCollectionOfProcessors;
								yourself)
]

{ #category : #notifying }
GTSpotter >> notifyShowPreview [

	self announce: GTSpotterShowPreview new

	
]

{ #category : #notifying }
GTSpotter >> notifySpotterExitFor: anEventType [

	self announce: (GTSpotterExitAnnouncement new
		eventType: anEventType)
]

{ #category : #notifying }
GTSpotter >> notifyStepAdded: aStep [

	self announce: (GTSpotterStepAdded new stepModel: aStep)
]

{ #category : #notifying }
GTSpotter >> notifyStepPopped [

	self announce: GTSpotterStepPopped new
]

{ #category : #accessing }
GTSpotter >> processorsFilter [

	^ processorsFilter
]

{ #category : #accessing }
GTSpotter >> processorsFilter: aFilter [
   "Set the filter for determining whether or not processors get added to a step."

	processorsFilter := aFilter
]

{ #category : #'event handling' }
GTSpotter >> propagateEvent: ann [

	self announcer announce: ann	
]

{ #category : #'actions api' }
GTSpotter >> pushStep: stepModel [
	
	self addStep: stepModel.
	"updating current step"
	self currentStep: stepModel
]

{ #category : #'event handling' }
GTSpotter >> requestNextStepWith: origin for: anEventType [

	text := ''.
	self pushStep: (self newStep origin: origin; event: anEventType; yourself).
	self steps last process: nil
]

{ #category : #'model access' }
GTSpotter >> setText: aText from: aView [
	"I am the main entry point for triggering a new search in the current step."
	
	self steps isEmpty
		"by default there are no steps, so we need to create one based on foundation origin"
		ifTrue: [ self addStep: ( self newStep origin: self foundationOrigin ) ].

	(aText asString isEmpty and: [ self text isEmpty not ])
		ifTrue: [ self currentStep process: nil ]
		ifFalse: [ self currentStep process: aText asString ].
	
	text := aText asString asText.
	^ true
]

{ #category : #'processors-discovery' }
GTSpotter >> spotterProcessorsFor: aSpotterStep [

	| processors |
	processors := AbstractSpotterProcessor allEnabledSubclasses collect: [ :e | e new ].
	processors sort: [ :a :b | a order < b order ].
	processors do: [ :e | e configureOn: aSpotterStep ]
]

{ #category : #accessing }
GTSpotter >> steps [

	^ steps ifNil: [ steps := OrderedCollection new ]
]

{ #category : #'actions api' }
GTSpotter >> terminateProcessors [

	self steps do: [ :each | each terminateProcessors ]
]

{ #category : #accessing }
GTSpotter >> text [

	^ text ifNil: [ text := '' asText ]
]
