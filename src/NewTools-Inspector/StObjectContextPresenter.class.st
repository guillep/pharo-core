"
A presenter object inspection that is aware of the inspection context.
It is used to build enhance inspection view (e.g. show or not the evaluator).
"
Class {
	#name : #StObjectContextPresenter,
	#superclass : #StPresenter,
	#instVars : [
		'view',
		'evaluator',
		'model',
		'activationBlock'
	],
	#category : #'NewTools-Inspector-View'
}

{ #category : #api }
StObjectContextPresenter >> activateOnDoubleClick [
	
	view hasOutputActivationPort ifFalse: [ ^ self ].
	view activateOnDoubleClick
]

{ #category : #api }
StObjectContextPresenter >> activateOnSingleClick [
	
	view hasOutputActivationPort ifFalse: [ ^ self ].
	view activateOnSingleClick
]

{ #category : #commands }
StObjectContextPresenter >> doEvaluateAndGo [
	| value |
	
	activationBlock ifNil: [ ^ self ].

	value := evaluator 
		evaluate: evaluator selectedTextOrLine
		onCompileError: [ ^ self ]
		onError: [ :e | e pass ].
	
	activationBlock value: (StEvaluatedSelectionModel newValue: value)
]

{ #category : #private }
StObjectContextPresenter >> evaluatorActions [
	
	^ CmCommandGroup forSpec
		beDisplayedAsGroup;
		register: (StEvaluateCommand forSpecContext: self);
		yourself
]

{ #category : #private }
StObjectContextPresenter >> evaluatorInitialText [

	^ '"{1}"
{2}' 
	format: { 
		self model smallDescriptionString.
		self model codeSnippet }
]

{ #category : #testing }
StObjectContextPresenter >> hasEvaluator [

	^ self model hasEvaluator
]

{ #category : #testing }
StObjectContextPresenter >> hasOutputActivationPort [
	
	^ self hasEvaluator or: [ view hasOutputActivationPort ]
]

{ #category : #initialization }
StObjectContextPresenter >> initializePresenters [

	view := self model newInspectionView.
	self hasEvaluator
		ifTrue: [ self intializePresentersWithEvaluator ]
		ifFalse: [ self intializePresentersWithoutEvaluator ]
]

{ #category : #initialization }
StObjectContextPresenter >> intializePresentersWithEvaluator [
	
	(evaluator := self newCode)
		beForObject: self model inspectedObject;
		text: self evaluatorInitialText;
		overridingContextMenu;
		contextMenu: [ (self menuActionsFor: evaluator) asMenuPresenter ];
		contextKeyBindings: (self menuActionsFor: evaluator) asKMCategory;
		whenTextChangedDo: [ :aString | self model codeSnippet: aString ].
	
	self layout: (SpPanedLayout newVertical
		position: 70 percent;
		add: view;
		add: evaluator;
		yourself)
]

{ #category : #initialization }
StObjectContextPresenter >> intializePresentersWithoutEvaluator [
	
	self layout: (SpBoxLayout newVertical
		add: view;
		yourself)
]

{ #category : #private }
StObjectContextPresenter >> menuActionsFor: aCodePresenter [
	
	^ CmCommandGroup forSpec
		beRoot;
		register: ((CmCommandGroup named: 'Extra') asSpecGroup
			beDisplayedAsGroup;
			register: (StEvaluateCommand forSpecContext: self);
			yourself);
		register: (aCodePresenter rootCommandsGroup name: 'Code');
		register: (aCodePresenter editionCommandsGroup name: 'Edition');
		yourself
]

{ #category : #'accessing model' }
StObjectContextPresenter >> model [

	^ model
]

{ #category : #transmission }
StObjectContextPresenter >> outputActivationPort [

	^ view hasOutputActivationPort 
		ifTrue: [ (SpActivationPort newPresenter: self), view outputActivationPort ]
		ifFalse: [ SpActivationPort newPresenter: self ]
]

{ #category : #'accessing model' }
StObjectContextPresenter >> setModelBeforeInitialization: aModel [
	
	model := aModel
]

{ #category : #stepping }
StObjectContextPresenter >> step [

	view step
]

{ #category : #'api-events' }
StObjectContextPresenter >> whenActivatedDo: aBlock [

	activationBlock := aBlock
]
