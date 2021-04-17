"
This is meant to be used for inspecting objects. It offers multiple views and it uses a finder as a navigation. One particular feature is that you can use the evaluator tab to enter code, and evaluating it results in opening another pane to the right.

The object finder asks dynamically the object for the actual presentations that are displayed in each pane.

Example:
self openOn: Smalltalk.

Register it as a replacement for explorer:
self registerToolsOn: Smalltalk tools.
"
Class {
	#name : #GTInspector,
	#superclass : #GLMCompositePresentation,
	#instVars : [
		'presentationFilter'
	],
	#classVars : [
		'EnabledStepRefreshStatus',
		'GTInspectorEnabledStatus',
		'GTNumberOfInspectorPanes',
		'IndexableDisplayLimit',
		'PreferredExtent',
		'RememberPreferredExtent',
		'StepRefreshRate'
	],
	#category : #'GT-Inspector'
}

{ #category : #'utilities api' }
GTInspector class >> closeAllInspectors [
	<script>
	"self closeAllInspectors"
	(SystemWindow allSubInstances select: [:w | 
		 w model isKindOf: self])
			do: [:w | w delete ].

]

{ #category : #settings }
GTInspector class >> disableStepRefresh [
	self setEnabledStepRefreshStatus: false
]

{ #category : #settings }
GTInspector class >> enableStepRefresh [
	self setEnabledStepRefreshStatus: true
]

{ #category : #openning }
GTInspector class >> explore: anObject [ 
	self openOn: anObject.
	^ anObject
]

{ #category : #accessing }
GTInspector class >> extensionsPragma [
	^ #gtInspectorPresentationOrder:
]

{ #category : #settings }
GTInspector class >> extentSettingsOn: aBuilder [ 
	<systemsettings>
	
	(aBuilder setting: #GTInspectorPreferredWidth)
		target: self;
		parent: #gt;
		default: 600;
		getSelector: #preferredWidth;
		setSelector: #preferredWidth:; 
		label: 'Inspector width';
		description: 'The preferred width of new Inspector windows'.
	(aBuilder setting: #GTInspectorPreferredHeight)
		target: self;
		parent: #gt;
		default: 400;
		getSelector: #preferredHeight;
		setSelector: #preferredHeight:; 
		label: 'Inspector height';
		description: 'The preferred height of new Inspector windows'.
	(aBuilder setting: #GTInspectorRememberPreferredExtent)
		target: self;
		parent: #gt;
		getSelector: #rememberPreferredExtent;
		setSelector: #rememberPreferredExtent:;
		default: true; 
		label: 'Remember extent of Inspector';
		description: 'Enable or disable remembering of the extent of Inspector windows on resize. When the preference is true, resizing a Inspector window will affect the preferred width and height of future Inspector windows'

]

{ #category : #inspecting }
GTInspector class >> gtInspectorExtensionsIn: composite [
	<gtInspectorPresentationOrder: 40>
	composite list
		title: 'Extensions';
		display: [ self inspectorExtendingMethods ];
		showOnly: 50;
		format: [ :each | each displayString ];
		filterOn: [ :text :each | each displayString includesSubstring: text caseSensitive: false ]
]

{ #category : #settings }
GTInspector class >> indexableDisplayLimit [
	^ IndexableDisplayLimit ifNil: [ 5000 ]
]

{ #category : #settings }
GTInspector class >> indexableDisplayLimit: anInteger [
	IndexableDisplayLimit := anInteger
]

{ #category : #'class initialization' }
GTInspector class >> initialize [ 
	self numberOfInspectorPanes: 2
]

{ #category : #openning }
GTInspector class >> inspect: anObject [ 
	self openOn: anObject.
	^ anObject
]

{ #category : #openning }
GTInspector class >> inspect: anObject label: aString [
	self new 
		title: aString;
		openOn: anObject.
	^ anObject

]

{ #category : #openning }
GTInspector class >> inspector: anObject [

	^ self openOn: anObject
]

{ #category : #inspecting }
GTInspector class >> inspectorExtendingMethods [
	^ (SystemNavigation default allBehaviors flatCollect: [ :each | 
			(Pragma allNamed: self extensionsPragma in: each) 
				collect: [ :p | p method asRingDefinition ] ])
		sorted
]

{ #category : #settings }
GTInspector class >> isGTInspectorEnabled [

	^ GTInspectorEnabledStatus ifNil: [ GTInspectorEnabledStatus := Smalltalk tools inspector = self ]
]

{ #category : #settings }
GTInspector class >> isStepRefreshEnabled [

	^ EnabledStepRefreshStatus ifNil: [ true ]
]

{ #category : #settings }
GTInspector class >> numberOfInspectorPanes [
	^ GTNumberOfInspectorPanes 
]

{ #category : #settings }
GTInspector class >> numberOfInspectorPanes: anInteger [
	GTNumberOfInspectorPanes := anInteger 
]

{ #category : #openning }
GTInspector class >> openOn: anObject [ 
	^ self new openOn: anObject
]

{ #category : #settings }
GTInspector class >> preferredExtent [
	^ PreferredExtent ifNil: [ PreferredExtent := 600@400 ]
]

{ #category : #settings }
GTInspector class >> preferredExtent: aPoint [
	PreferredExtent := aPoint
]

{ #category : #settings }
GTInspector class >> preferredHeight [
	^ self preferredExtent y
]

{ #category : #settings }
GTInspector class >> preferredHeight: aHeight [
	self preferredExtent setX: self preferredExtent x setY: aHeight
]

{ #category : #settings }
GTInspector class >> preferredWidth [
	^ self preferredExtent x
]

{ #category : #settings }
GTInspector class >> preferredWidth: aWidth [
	self preferredExtent setX: aWidth setY: self preferredExtent y
]

{ #category : #'tools registry' }
GTInspector class >> register [

	self registerToolsOn: Smalltalk tools

]

{ #category : #'tools registry' }
GTInspector class >> registerToolsOn: registry [
	"IMPORTANT: This method is disabled because the bootstrap process initializes tools by traversing
	 all classes implementing this method in alphabetical order. Since GTInspector is not anymore the 
	 default playground, we disable its auto-registration in that step. 
	 Notice that the #register method still works if needed"

	"self registerToolsOn: Smalltalk tools " 
	"registry register: self as: #inspector"

]

{ #category : #settings }
GTInspector class >> rememberPreferredExtent [
	^ RememberPreferredExtent ifNil: [ RememberPreferredExtent := true ]
]

{ #category : #settings }
GTInspector class >> rememberPreferredExtent: aBoolean [
	^ RememberPreferredExtent := aBoolean
]

{ #category : #settings }
GTInspector class >> setEnabledStepRefreshStatus: aBoolean [
	EnabledStepRefreshStatus := aBoolean
]

{ #category : #settings }
GTInspector class >> setGTInspectorEnabledStatus: aBoolean [
	| oldStatus |
	
	oldStatus := self isGTInspectorEnabled.
	GTInspectorEnabledStatus := aBoolean.
	oldStatus ~= GTInspectorEnabledStatus ifTrue: [ 
		GTInspectorEnabledStatus 
			ifTrue: [ self register ]
			ifFalse: [ EyeInspector registerToolsOn: Smalltalk tools ] ]
	
	
]

{ #category : #settings }
GTInspector class >> setPreferredExtentIfWanted: anExtent [
	self rememberPreferredExtent ifTrue: [ 
		self preferredExtent: anExtent ]
]

{ #category : #settings }
GTInspector class >> settingsOn: aBuilder [ 
	<systemsettings>
	
	(aBuilder group: #gt)
		parent: #tools;
		label: 'Glamorous Toolkit';
		with: [
			(aBuilder setting: #numberOfInspectorPanes)
				target: self; 
				label: 'Number of inspector panes';
				default: 2;
		 		description: 'Specifies the maximum number of panes that are visible at every moment in a Glamorous Inspector.'.
			(aBuilder setting: #GTInspectorStatus)
				target: self;
				getSelector: #isGTInspectorEnabled;
				setSelector: #setGTInspectorEnabledStatus:; 
				label: 'GTInspector';
				default: false;
		 		description: 'Enable or disable the GTInspector.'.
			(aBuilder setting: #EnabledStepRefreshStatus)
				target: self;
				getSelector: #isStepRefreshEnabled;
				setSelector: #setEnabledStepRefreshStatus:; 
				label: 'GTInspector Step Refresh';
				default: true;
		 		description: 'Enable or disable the automatic refresh in GTInspector that uses a busy update loop (based on the stepping mechanism from Morphic).']
]

{ #category : #settings }
GTInspector class >> stepRefreshRate [
	^ StepRefreshRate ifNil: [ 1500 ]
]

{ #category : #settings }
GTInspector class >> stepRefreshRate: anInteger [
	StepRefreshRate := anInteger
]

{ #category : #callbacks }
GTInspector >> actOnPaneAdded: anAnnouncement [
	
	"Update toolbar of a pane before the last (added) pane if there is one"
	(self panes atLast: 2 ifAbsent: [ ^ self ])
		updateToolbar
]

{ #category : #callbacks }
GTInspector >> actOnPaneRemoved: anAnnouncement [

	"Update toolbar of a pane before the removed pane (now it is last one)"
	self panes last updateToolbar
]

{ #category : #accessing }
GTInspector >> browser [
	^ self first
]

{ #category : #actions }
GTInspector >> closeActionFor: aPresentation [

	^ GLMGenericAction new
			action: [ self removeLastPane ];
			icon: GLMUIThemeExtraIcons glamorousClose;
			condition: [ :currentPresentation |
				self panes size > 1 and: [ self panes last presentations = currentPresentation ] ];
			title: 'Close this inspector column'
]

{ #category : #building }
GTInspector >> compose [

	self title: [:anObject | 'Inspector on ', (self printObjectAsAnItem: anObject)].
	self titleIcon: (self iconNamed: #smallInspectIt).
	self act: [:b | b update] icon: GLMUIThemeExtraIcons glamorousRefresh entitled: 'Update'.	 
	self act: [:b | b presentationFilter changeFilterRequestFor: b ] entitled: 'Filter presentations'.
	self pager with: [ :browser | 
		browser fixedSizePanes: self class numberOfInspectorPanes.
		browser show: [ :a :each |
			a title: [ self printObjectAsAnItem: each ].
			a dynamicActions: [ :aPresentation | 
				each gtInspectorActions asOrderedCollection ].
			a titleAction: [ :aPresentation | self closeActionFor: aPresentation ].
			a dynamic 
				display: [ :x | 
					(GLMCompositePresentation new with: [:d | 
						each 
							gtInspectorPresentationsIn: d 
							inContext: self ])
							startOn: x ] ] ].
			
	self browser when: GLMPaneAdded send: #actOnPaneAdded: to: self.
	self browser when: GLMPaneRemoved send: #actOnPaneRemoved: to: self.
	
	self class isStepRefreshEnabled ifTrue: [ 
		self wantsAutomaticRefresh: true.
		self wantsSteps: true.
		self stepTime: self class stepRefreshRate ].
	
]

{ #category : #accessing }
GTInspector >> entities [
	"returns the list of objects from the #entity port of each pane of the finder"
	^ self panes collect: [ :each | (each port: #entity) value ]
]

{ #category : #context }
GTInspector >> filterByMethods: aCollection [
	| filter |
	
	filter := GTInspectorMethodListFilter new.
	aCollection do: [ :aMethod |
		filter addAndSelectSignatureFor: aMethod ].
	self presentationFilter: filter
]

{ #category : #accessing }
GTInspector >> firstPresentation [

	^ self panes first presentations first
]

{ #category : #initialization }
GTInspector >> initialize [
	super initialize.
	
	self presentationFilter: (GTInspectorTagFilter new
			defaultTag: #custom;
			addAndSelectTag: #basic;
			addAndSelectTag: #custom;
			addAndSelectTag: #examples)
]

{ #category : #actions }
GTInspector >> openExplorerFor: anObject [
	"this method is needed for compatibility with ObjectExplorer"
	self openOn: anObject
]

{ #category : #'scripting opening' }
GTInspector >> openOn: aPage [
	| window |
	window := super openOn: aPage.
	window extent: self class preferredExtent.
	window when: WindowResizing do: [ 
		(window isMinimized or: [ window isMaximized ]) ifFalse: [ 
			"we only wnat to react to real resizing,
			not to minization or maximization"
			self class setPreferredExtentIfWanted: window extent ] ].
	^ window
]

{ #category : #accessing }
GTInspector >> panes [
	^ self browser panes
]

{ #category : #context }
GTInspector >> presentationFilter [
	"Return a filter for limiting the number of visible presentations.
	Filter can not be nil"
	<return: #GTInspectorPresentationFilter>

	^ presentationFilter
]

{ #category : #context }
GTInspector >> presentationFilter: aPresentationFilter [
	"Set a filter for limiting the number of visible presentations.
	Presentation filter must not be nil. If you don't need any filter use GTInspectorNoneFilter instead"
	
	self
		assert: [ aPresentationFilter isNotNil ]
		description: [ 'Presentation filter must not be nil' ].
	
	presentationFilter := aPresentationFilter
]

{ #category : #private }
GTInspector >> printObjectAsAnItem: anObject [
	| header printString |
	header := (anObject class name first isVowel
		ifTrue: [ 'an ' ]
		ifFalse: [ 'a ' ]) , anObject class name.
	printString := (GTObjectPrinter asTruncatedTextFrom: anObject) asString.
	^ (printString beginsWith: header)
		ifTrue: [ printString ]
		ifFalse: [ 
			String streamContents: [ :out | 
				out << header; << ' ('; << printString; << ')' ] ]
]

{ #category : #updating }
GTInspector >> refreshPanes [
	self panes do: [ :aPane | 
		aPane updateToolbar.
		aPane presentations presentations first withAllPresentations do: [ :aPresentation |
			aPresentation wantsAutomaticRefresh ifTrue: [ 
				aPresentation requestRefresh ] ]  ]
]

{ #category : #actions }
GTInspector >> removeLastPane [
	| lastPane |
	
	lastPane := self panes last.
	self browser removeLastPane.
	self browser announce: (GLMPaneRemoved pane: lastPane fromBrowser: self browser)
]

{ #category : #updating }
GTInspector >> requestRefresh [
	self updateToolbar.
	self refreshPanes
]

{ #category : #context }
GTInspector >> shouldDisplayPresentationCreatedBy: aMethod [
	"Verify whether or not the presentation created by the given method should be displayed.
	If no filter is given display all presentations."

	^ self presentationFilter shouldDisplayPresentationCreatedBy: aMethod
]

{ #category : #scripting }
GTInspector >> showFirst: aBlock [

	self browser showFirst: aBlock
]

{ #category : #stepping }
GTInspector >> step [
	self window ifNil: [ ^ self ].
	self window isActive ifFalse: [ ^ self ].
	
	self wantsAutomaticRefresh ifTrue: [
		self requestRefresh ]
]
