"
I'm a model to collect options for ""spotter navigation"" mode in a full browser.
"
Class {
	#name : #ClySpotterModel,
	#superclass : #Object,
	#instVars : [
		'browser'
	],
	#category : #'Calypso-SystemPlugins-Spotter'
}

{ #category : #'instance creation' }
ClySpotterModel class >> new [
	self error: 'Use #on:'
]

{ #category : #'instance creation' }
ClySpotterModel class >> on: aBrowser [
	^ self basicNew 
		initializeOn: aBrowser;
		yourself
]

{ #category : #accessing }
ClySpotterModel >> browser [
	^ browser
]

{ #category : #private }
ClySpotterModel >> collectCommandCandidatesInContext: aContext [
	| allActivators allCommands |
	allActivators := CmdContextMenuActivation createActivatorsExecutableInContext: aContext.
	allCommands := allActivators collect: [ :each | each command class ] as: IdentitySet.
	
	CmdMenuCommandActivationStrategy allSubclassesDo: [ :eachStrategy |
		eachStrategy activateAllInContext: aContext by: [ :eachActivator |
			(allCommands includes: eachActivator command class) ifFalse: [ 
				allActivators add: eachActivator.
				allCommands add: eachActivator command class] ] ].
	
	^allActivators
]

{ #category : #private }
ClySpotterModel >> collectGoToCandidates [
	
	| result |
	result := OrderedCollection new.
	
	browser allContextsDo: [ :each | 
		each asGoToSpotterCandidate ifNotNil: [:c |
			result add: c ] ].
	
	^result 
]

{ #category : #private }
ClySpotterModel >> commandListProcessorForContext: aContext step: aStep [
	aStep listProcessor
		order: 20;
		title: aContext simpleNameForSpotterMenu;
		allCandidates: [ self collectCommandCandidatesInContext: aContext ];
		itemName: #menuItemName;
		itemIcon: #menuItemIcon;
		candidatesLimit: 5;
		filter: GTFilterSubstring;
		actLogic: [ :activator :step | 
			step exit.
			activator executeCommand ]
]

{ #category : #printing }
ClySpotterModel >> displayStringOn: stream [
	stream << self browser newWindowTitle
]

{ #category : #printing }
ClySpotterModel >> gtDisplayOn: stream [
	stream << self browser newWindowTitle
]

{ #category : #initialization }
ClySpotterModel >> initializeOn: aBrowser [
	browser := aBrowser.
	self initialize	
]

{ #category : #private }
ClySpotterModel >> spotterForCommandsFor: aStep [
	<spotterOrder: 20>

	browser allContextsDo: [ :each | 
		self commandListProcessorForContext: each step: aStep]
]

{ #category : #'accessing spotter' }
ClySpotterModel >> spotterForGoToFor: aStep [
	<spotterOrder: 10>

	aStep listProcessor
		title: 'Go to';
		allCandidates: [ self collectGoToCandidates ];
		itemName: #name;
		itemIcon: #icon;
		candidatesLimit: 10;
		filter: GTFilterSubstring;
		actLogic: [ :assoc :step | 
			step exit. 
			assoc activate ]
]
