"
I am a single object inspector.
I present a notebook with the possible inspection of the object.

I am usually embedded into an StInspector, but I can be used standalone.
"
Class {
	#name : #StObjectInspectorPresenter,
	#superclass : #StPresenter,
	#instVars : [
		'views',
		'evaluator',
		'model',
		'activationBlock',
		'header',
		'alivePresentersByPage',
		'activateOnSingleClick'
	],
	#classInstVars : [
		'header'
	],
	#category : #'NewTools-Inspector-View'
}

{ #category : #commands }
StObjectInspectorPresenter class >> buildCommandsGroupWith: presenter forRoot: aCmCommandsGroup [
	| group |
	
	group := (CmCommandGroup named: 'Toolbar') asSpecGroup.
	(StInspectorCommand toolbarCommandsFor: presenter)
		do: [ :cmd | group register: cmd ].
	
	aCmCommandsGroup register: group
]

{ #category : #commands }
StObjectInspectorPresenter class >> buildRootCommandsGroupFor: aPresenter [
	| rootCommandGroup |
	
	rootCommandGroup := CmCommandGroup forSpec beRoot.
	"Register extension commands first."
	self buildExtensionCommandsWith: aPresenter forRoot: rootCommandGroup.
	"Register default commands."
	self buildCommandsGroupWith: aPresenter forRoot: rootCommandGroup.
	
	^ rootCommandGroup
]

{ #category : #accessing }
StObjectInspectorPresenter class >> defaultTitle [

	^ 'Inspector'
]

{ #category : #'tools registry' }
StObjectInspectorPresenter class >> inspect: anObject [

	^ self openOn: anObject
]

{ #category : #opening }
StObjectInspectorPresenter class >> onObject: anObject [

	^ self on: (StInspectorModel on: anObject)
]

{ #category : #opening }
StObjectInspectorPresenter class >> openOn: anObject [

	^ (self onObject: anObject) openWithSpec
]

{ #category : #private }
StObjectInspectorPresenter >> activate: aSelection [

	activationBlock ifNil: [ ^ self ].
	activationBlock cull: aSelection
]

{ #category : #accessing }
StObjectInspectorPresenter >> activateOnDoubleClick [

	activateOnSingleClick := true
]

{ #category : #accessing }
StObjectInspectorPresenter >> activateOnSingleClick [

	activateOnSingleClick := true
]

{ #category : #private }
StObjectInspectorPresenter >> addActivationTo: aPresenter [
	
	aPresenter hasOutputActivationPort ifFalse: [ ^ self ]. 
	activateOnSingleClick ifTrue: [ aPresenter activateOnSingleClick ].
	aPresenter outputActivationPort 
		transmitDo: [ :selection | self activate: selection ]
]

{ #category : #private }
StObjectInspectorPresenter >> allContexts [

	^ self model objectInspectionContexts
]

{ #category : #private }
StObjectInspectorPresenter >> allPages [
	
	^ self allContexts 
		collect: [ :each | self newPageForContext: each ]
	
]

{ #category : #'private builder' }
StObjectInspectorPresenter >> buildToolbar [

	^ self rootCommandsGroup asToolbarPresenterWith: [ :presenter | 
			presenter 
				displayMode: self application toolbarDisplayMode;
				addStyle: 'stToolbar' ]
]

{ #category : #transmission }
StObjectInspectorPresenter >> defaultInputPort [

	^ self inputModelPort
]

{ #category : #'api-focus' }
StObjectInspectorPresenter >> defaultKeyboardFocus [

	views pages ifNotEmpty: [ :pages | 
		pages first activePresenter 
			ifNotNil: [ :aPresenter | ^ aPresenter ] ].
		
	^ self
]

{ #category : #accessing }
StObjectInspectorPresenter >> evaluator [ 
	^evaluator
]

{ #category : #initialization }
StObjectInspectorPresenter >> initialize [

	activateOnSingleClick := false.
	super initialize.
	"I keep the presenters I'm showing in this variable because they can change (and they are 
	 initialized lazily in the notebook)"
	alivePresentersByPage := WeakSet new
]

{ #category : #initialization }
StObjectInspectorPresenter >> initializeLayout [
	
	self layout: (SpBoxLayout newVertical 
		add: header expand: false fill: false padding: 5;
		add: views;
		yourself)
]

{ #category : #initialization }
StObjectInspectorPresenter >> initializePresenters [

	views := self newNotebook.
	header := self instantiate: StHeaderBar.
	self initializeLayout.

	self refresh
]

{ #category : #initialization }
StObjectInspectorPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter 
		title: self title;
		toolbar: self buildToolbar
]

{ #category : #transmission }
StObjectInspectorPresenter >> inputModelPort [

	^ SpModelPort newPresenter: self
]

{ #category : #accessing }
StObjectInspectorPresenter >> inspectedObject [
 	
	^ self model inspectedObject
]

{ #category : #private }
StObjectInspectorPresenter >> keepPresenter: aPresenter [

	alivePresentersByPage add: aPresenter
]

{ #category : #'model access' }
StObjectInspectorPresenter >> model [ 

	^ model
]

{ #category : #'model access' }
StObjectInspectorPresenter >> model: anInspectorModel [

	"if same object, I do not want to update to not trigger infinite updates"
	model inspectedObject == anInspectorModel inspectedObject 
		ifTrue: [ ^ self ].
	model := anInspectorModel.
	self refresh
]

{ #category : #'private factory' }
StObjectInspectorPresenter >> newInspectionForContext: aContext [
	
	^ StObjectContextPresenter on: (StObjectContextModel new 
		inspection: self model;
		inspectedObject: self inspectedObject;
		context: aContext; 
		yourself)
]

{ #category : #'private factory' }
StObjectInspectorPresenter >> newPageForContext: aContext [ 

	^ SpNotebookPage new
		title: aContext title;
		presenterProvider: [ self newInspectionForContext: aContext ];
		whenRetrievedDo: [ :presenter | 
			self keepPresenter: presenter.
			self addActivationTo: presenter ];
		yourself
]

{ #category : #accessing }
StObjectInspectorPresenter >> rawInspectorPageOrNil [

	^ views pages 
		detect: [ :page | page title = 'Raw' ] 
		ifNone: [ nil ]
]

{ #category : #'private updating' }
StObjectInspectorPresenter >> refresh [
	"model changed?  
	 update inspector values."

	self updateTitle.
	self updateHeaderBar.
	self updateEvaluator.
	self updatePages
]

{ #category : #accessing }
StObjectInspectorPresenter >> refreshContent [
	"I force a refresh of current page contents. "

	views selectedPage resetContent
]

{ #category : #accessing }
StObjectInspectorPresenter >> selectedObject [
	^ self inspectedObject
]

{ #category : #accessing }
StObjectInspectorPresenter >> selectedPage [

	^ views selectedPage
]

{ #category : #accessing }
StObjectInspectorPresenter >> selectedPageName [

	^ self selectedPage title
]

{ #category : #private }
StObjectInspectorPresenter >> setModel: aModel [

	self model: aModel
]

{ #category : #'model access' }
StObjectInspectorPresenter >> setModelBeforeInitialization: anInspectorModel [

	model := anInspectorModel
]

{ #category : #stepping }
StObjectInspectorPresenter >> step [

	alivePresentersByPage 
		do: [ :each | each step ]
]

{ #category : #accessing }
StObjectInspectorPresenter >> title [

	^ self model windowTitle
]

{ #category : #accessing }
StObjectInspectorPresenter >> trySelectAnyPageWithName: aCollection [
	"Tries to select a the first page of aCollection that exists in the pages list."
	| pagesToSearch |

	pagesToSearch := ((aCollection asOrderedCollection 
		reject: [ :each | each isNil ])
		reject: [ :each | each = StRawInspection label ])
		removeDuplicates.
	pagesToSearch ifEmpty: [ ^ self ].

	pagesToSearch do: [ :eachName |
		views pages 
			detect: [ :each | each title = eachName ]
			ifFound: [ :aPage | 
				views selectPage: aPage.
				^ self ] ]
]

{ #category : #'private updating' }
StObjectInspectorPresenter >> updateEvaluator [

	"evaluator beForObject: self model inspectedObject"
]

{ #category : #'private updating' }
StObjectInspectorPresenter >> updateHeaderBar [
		
	header label: self model labelString.
	header toolbarActions: self rootCommandsGroup 
]

{ #category : #'private updating' }
StObjectInspectorPresenter >> updatePages [

	views 
		pages: self allPages;
		selectPageIndex: 1
]

{ #category : #'private updating' }
StObjectInspectorPresenter >> updateTitle [
		
	self isRoot ifFalse: [ ^ self ].
	self withWindowDo: [ :window | 
		window title: self title ].
]

{ #category : #'api-events' }
StObjectInspectorPresenter >> whenActivatedDo: aBlock [

	activationBlock := aBlock
]

{ #category : #'api-events' }
StObjectInspectorPresenter >> whenClosedDo: aBlock [

	header whenClosedDo: aBlock
]
