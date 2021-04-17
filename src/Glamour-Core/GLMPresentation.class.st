"
A GLMPresentation is the abstract class for the hierarchy of presentations. A presentation specifies how the pane (held in the pane instance variable) is going to be displayed. It typically reads at least the #entity port of a pane and populates at least the #selection port.

updateActions holds a collection of GLMUpdateAction that are used to update the presentation via announcements.

rawSelectionTransmissions holds a collection of transmission whose origins are this presentation's #rawSelection port. Destinations of this transmissions are on the pane. This collection always contains at least one transmission to the pane's #selection port. To transform the values travelling through this transmission use #send:. To add new transmissions, use #send:as:.

Because Glamour has a prototype-based design it relies on copying the presentations before installing them in panes (via transmissions). The parentPrototype instance variable keeps track of the presentation from which the current one was copied.

It raises:
- GLMContextChanged to let the world know that something has changed in the containing pane. This is typically used by the renderer to update the rendering.
- GLMPresentationUpdated to let the world know that the presentations wants to be updated because of reasons other than the pane context changed.
"
Class {
	#name : #GLMPresentation,
	#superclass : #GLMLoggedObject,
	#instVars : [
		'pane',
		'title',
		'titleIcon',
		'transformation',
		'actions',
		'condition',
		'implicitNotNil',
		'dynamicActionsBlock',
		'color',
		'customValidation',
		'shouldValidate',
		'acceptsSelection',
		'parentPrototype',
		'registeredAnnouncers',
		'updateActions',
		'selectionActions',
		'selectionDynamicActionsBlock',
		'implicitAllNil',
		'rawSelectionTransmissions',
		'statusPane',
		'sourceLink',
		'initializationBlock',
		'cachedDisplayedValue',
		'labelActionBlock',
		'portChangeActions',
		'wantsSteps',
		'stepTime',
		'stepCondition',
		'wantsAutomaticRefresh'
	],
	#category : #'Glamour-Core'
}

{ #category : #accessing }
GLMPresentation >> acceptsSelection [
	"this flag is used to specify whether the presentation
	is allowed to populate the selection port or not"
	^ acceptsSelection ifNil: [acceptsSelection := true]
]

{ #category : #accessing }
GLMPresentation >> acceptsSelection: aBoolean [
	acceptsSelection := aBoolean
]

{ #category : #'scripting actions' }
GLMPresentation >> act: aBlock entitled: aString [ 
	 
	self 
		addAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				title: aString; 
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> act: aBlock entitled: aString categorized: anotherString [
	 
	self 
		addAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				title: aString; 
				category: anotherString;
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> act: aBlock icon: anIcon entitled: aString [
	self 
		addAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				icon: anIcon;
				title: aString;
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> act: aBlock icon: anIcon on: aCharacter entitled: aString [
	self 
		addAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				shortcut: aCharacter; 				
				icon: anIcon;
				title: aString;
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> act: aBlock iconName: aSymbol entitled: aString [
	self act: aBlock icon: (self iconNamed: aSymbol) entitled: aString
]

{ #category : #'scripting actions' }
GLMPresentation >> act: aBlock iconName: aSymbol on: aCharacter entitled: aString [
	self act: aBlock icon: (self iconNamed: aSymbol) on: aCharacter entitled: aString
]

{ #category : #'scripting actions' }
GLMPresentation >> act: aBlock on: aCharacter [ 
	 
	self 
		addAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				shortcut: aCharacter; 
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> act: aBlock on: aCharacter entitled: aString [ 
	 
	self 
		addAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				shortcut: aCharacter; 
				title: aString; 
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> act: aBlock on: aCharacter entitled: aString categorized: anotherString [ 
	 
	self 
		addAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				shortcut: aCharacter; 
				title: aString; 
				category: anotherString;
				yourself)
]

{ #category : #accessing }
GLMPresentation >> actions [
	"These are actions that make sense for the entire presentation."
	actions ifNil: [actions := OrderedCollection new].
	^ actions
]

{ #category : #'scripting actions' }
GLMPresentation >> actions: aBlock [ 
	self 
		deprecated: 'use dynamicActionsOnSelection: for contextual actions, and dynamicActions for presentation-wide actions'
		transformWith: '`@rec actions: `@block' -> '`@rec dynamicActionsOnSelection: `@block'.
	
	^ self dynamicActionsOnSelection: aBlock 
]

{ #category : #accessing }
GLMPresentation >> addAction: anAction [ 
	 
	self actions addLast: anAction
]

{ #category : #statusbar }
GLMPresentation >> addDefaultStatusbarTransmissionFrom: aPane [
	| defaultTransmission |
	defaultTransmission := GLMTransmission new
		ensureReplacePresentationsStrategy;
		addActiveOrigin: (aPane port: #status); 
		destination: (self statusbarPane port: #entity); 
		addPresentation: self statusbarPresentation; 
		yourself.
	self addTransmission: defaultTransmission.
]

{ #category : #transmitting }
GLMPresentation >> addRawSelectionTransmissionTo: aPortSymbol [
	^ rawSelectionTransmissions
		add:
			((GLMTransmission new)
				addActiveOrigin:
						((GLMPresentationBoundPort new)
								name: #rawSelection;
								presentation: self;
								yourself);
				destination:
						((GLMPresentationBoundPort new)
								name: aPortSymbol;
								presentation: self;
								yourself))
]

{ #category : #accessing }
GLMPresentation >> addSelectionAction: anAction [
	self selectionActions add: anAction
]

{ #category : #statusbar }
GLMPresentation >> addStatusbar [
	self hasStatusbar: true
	
]

{ #category : #accessing }
GLMPresentation >> allActions [ 
	^ (self actions, self dynamicActions) 
			select: [ :each | each isAvailableOn: self ]
]

{ #category : #accessing }
GLMPresentation >> allActionsWithShortcuts [ 
	^ (self allActions, self allSelectionActions) select: [ :action | action hasShortcut ]
]

{ #category : #accessing }
GLMPresentation >> allSelectionActions [ 
	^ (self selectionActions, self dynamicActionsOnSelection)
			select: [ :each | each isAvailableOn: self ]
]

{ #category : #scripting }
GLMPresentation >> allowAllNil [
	^ self useExplicitAllNil
]

{ #category : #scripting }
GLMPresentation >> allowNil [
	^ self useExplicitNotNil
]

{ #category : #accessing }
GLMPresentation >> color [
	^ color
]

{ #category : #accessing }
GLMPresentation >> color: aSymbolOrColor [
	color := aSymbolOrColor
]

{ #category : #'accessing values' }
GLMPresentation >> colorValue [
	^ self color notNil
		ifTrue: [ self color glamourValue: self entity ]
		ifFalse: [ self color ]
"
	
	self color isSymbol
		ifTrue: [ Color perform: self color ]
		ifFalse: [ self color ]"
]

{ #category : #accessing }
GLMPresentation >> condition [ 
	 
	^condition ifNil: [condition := [true]]
]

{ #category : #accessing }
GLMPresentation >> condition: anObject [ 
	 
	condition := anObject
]

{ #category : #copying }
GLMPresentation >> copy [
	"we are overriding the copy method simply to retain the tree of all prototype presentations. 
	this is useful for debugging."

	| copy |
	self flag: 'perhaps this should be replaced with smarter analysys mechanisms'.
	copy := super copy.
	copy parentPrototype: self.
	^ copy
]

{ #category : #'accessing validation' }
GLMPresentation >> customValidation [
	^ customValidation
]

{ #category : #'accessing validation' }
GLMPresentation >> customValidation: aBlock [
	customValidation := aBlock.
	shouldValidate := true.
]

{ #category : #validation }
GLMPresentation >> defaultValidate: anObject on: aPort [ 
	"by default any object is allowed in any port"
	"override this method in subclasses to specify stronger constraints"
	^ true
]

{ #category : #scripting }
GLMPresentation >> display: aBlock [ 
	 
	self transformation: aBlock
]

{ #category : #'accessing values' }
GLMPresentation >> displayValue [
	^ cachedDisplayedValue := self transformation glamourValue: self entity
]

{ #category : #'accessing values' }
GLMPresentation >> displayedValue [
	"This returns the cached displayed value.
	
	This is particularly useful when we need to work with the
	value being displayed in the presentation without recomputing it."
	^ cachedDisplayedValue
]

{ #category : #validation }
GLMPresentation >> doValidate: anObject on: aPort [ 
	^ self customValidation isNil ifFalse: [ 
		self customValidation glamourValue: (
			anObject asGlamorousMultiValue,
			aPort name asGlamorousMultiValue, 
			self entity asGlamorousMultiValue) ]
	ifTrue: [ self defaultValidate: anObject on: aPort ]
]

{ #category : #accessing }
GLMPresentation >> dynamicActions [

	"These are actions that make sense for the entire presentation.
	They are dynamic in the sense that they will be evaluated lazily by the renderer"

	dynamicActionsBlock ifNil: [ ^ OrderedCollection new ].
	^ dynamicActionsBlock glamourValue: self
]

{ #category : #'scripting actions' }
GLMPresentation >> dynamicActions: aBlock [ 
	dynamicActionsBlock := aBlock
]

{ #category : #accessing }
GLMPresentation >> dynamicActionsOnSelection [
	"These are actions that make sense only in the context of values held in the selection port.
	They are dynamic in the sense that they will be evaluated lazily by the renderer"
	(selectionDynamicActionsBlock isNil or: [ 
		self selection isNil ])
		ifTrue: [ ^ OrderedCollection new ].
	^ selectionDynamicActionsBlock glamourValue: self
]

{ #category : #accessing }
GLMPresentation >> dynamicActionsOnSelection: aBlock [
	selectionDynamicActionsBlock := aBlock
]

{ #category : #'accessing ports' }
GLMPresentation >> entity [
	^ (self pane port: #entity) value
]

{ #category : #'accessing ports' }
GLMPresentation >> entity: anObject [
	(self pane port: #entity) value: anObject
]

{ #category : #actions }
GLMPresentation >> gtActionsIn: composite [
	<gtInspectorPresentationOrder: 50>
	composite list 
		title: 'Actions';
		display: [ self actions ];
		format: [ :each | each displayString ]
]

{ #category : #testing }
GLMPresentation >> hasActions [
	^ self allActions notEmpty
]

{ #category : #statusbar }
GLMPresentation >> hasStatusbar [
	^ statusPane notNil
]

{ #category : #statusbar }
GLMPresentation >> hasStatusbar: aBoolean [
	aBoolean ifTrue: [
		statusPane := self addPane: (GLMPane new name: self class defaultStatusbarPane) ]
	
]

{ #category : #testing }
GLMPresentation >> hasTitle [
	^ title notNil
]

{ #category : #testing }
GLMPresentation >> hasTitleIcon [
	^ self titleIcon notNil
]

{ #category : #testing }
GLMPresentation >> hasTransformation [
	^ transformation isNotNil and: [ transformation ~= #yourself ]
]

{ #category : #initialization }
GLMPresentation >> initialize [
	super initialize.
	updateActions := OrderedCollection new.
	portChangeActions := OrderedCollection new.
	rawSelectionTransmissions := IdentitySet new.
	self addRawSelectionTransmissionTo: #selection
]

{ #category : #accessing }
GLMPresentation >> initialize: aBlock [
	"aBlock is called when the presentation is placed on a pane as a result
	of a transmission. It can be used to initialize  multiple ports."

	initializationBlock := aBlock
]

{ #category : #initialization }
GLMPresentation >> initializePresentation [
	initializationBlock ifNotNil: [ initializationBlock value: self ]
]

{ #category : #events }
GLMPresentation >> innerPortEvent: aPortEvent [ 
	 "Regular presentations do not have inner ports,
	  so the default behaviour is to do nothing"
]

{ #category : #testing }
GLMPresentation >> matches [ 
	<debuggingStone: #presentationCondition label: 'Presentation condition'>
	"answer true iff the presentation matches the current context so that it can be displayed"
	^ (self usesImplicitAllNil
	    ifTrue:[ GLMAllNilCondition new glamourValue: self entity ]
	    ifFalse:[ self usesImplicitNotNil 
			ifTrue: [GLMAllNotNilCondition new glamourValue: self entity] 
			ifFalse: [GLMSomeNotNilCondition new glamourValue: self entity] ]
		) and: [
			(self condition glamourValue: self entity) = true]
]

{ #category : #'scripting actions' }
GLMPresentation >> noActions [
	actions := nil.
	dynamicActionsBlock := nil.
]

{ #category : #scripting }
GLMPresentation >> noSelection [
	self acceptsSelection: false
]

{ #category : #scripting }
GLMPresentation >> noTitle [
	title := nil.
	titleIcon := nil
]

{ #category : #scripting }
GLMPresentation >> noTitleIcon [
	titleIcon := nil
]

{ #category : #'scripting actions' }
GLMPresentation >> onChangeOfPort: aPortName act: aBlock [
	self portChangeActions add: (
		GLMPortChangeAction new 
			portName: aPortName;
			action: aBlock)
]

{ #category : #scripting }
GLMPresentation >> open: aBlock on: aCharacter entitled: aString [ 
	 
	self 
		addAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				shortcut: aCharacter; 
				title: aString; 
				yourself)
]

{ #category : #events }
GLMPresentation >> outerPortEvent: aPortEvent [
	self announce: (GLMContextChanged new
				presentation: self; 
				property: aPortEvent portName; 
				value: aPortEvent value; 
				oldValue: aPortEvent oldValue; 
				yourself).
	self portChangeActions do: [ :each | 
		each portName = aPortEvent portName ifTrue: [ 
			each actOn: self ] ]
]

{ #category : #accessing }
GLMPresentation >> pane [
	^ pane ifNil: [
		pane := (GLMPane named: 'root' in: GLMNoBrowser new) 
				addPresentationSilently: self; 
				yourself]
]

{ #category : #accessing }
GLMPresentation >> pane: aPane [ 
	 
	pane := aPane
]

{ #category : #copying }
GLMPresentation >> parentPrototype [
	^ parentPrototype
]

{ #category : #copying }
GLMPresentation >> parentPrototype: aPresentation [
	"used to keep track of the (prototype) presentation from which
	the current one was copied"
	parentPrototype := aPresentation
]

{ #category : #'scripting actions' }
GLMPresentation >> populate: aPortSymbol icon: anIcon entitled: aString with: aBlock [ 
	 
	self 
		addAction: 
			((GLMGenericAction new) 
				action: 
						((GLMPortUpdater new) 
								portSymbol: aPortSymbol; 
								valueBlock: aBlock; 
								yourself); 
				icon: anIcon; 
				title: aString;
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> populate: aPortSymbol icon: anIcon on: aCharacter entitled: aString with: aBlock [ 
	 
	self 
		addAction: 
			((GLMGenericAction new) 
				action: 
						((GLMPortUpdater new) 
								portSymbol: aPortSymbol; 
								valueBlock: aBlock; 
								yourself); 
				shortcut: aCharacter; 
				icon: anIcon;
				title: aString;
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> populate: aPortSymbol iconName: aSymbol entitled: aString with: aBlock [ 
	 
	self populate: aPortSymbol icon: (self iconNamed: aSymbol) entitled: aString with: aBlock 
]

{ #category : #'scripting actions' }
GLMPresentation >> populate: aPortSymbol iconName: aSymbol on: aCharacter entitled: aString with: aBlock [ 
	 
	self populate: aPortSymbol icon: (self iconNamed: aSymbol) on: aCharacter entitled: aString with: aBlock 
]

{ #category : #'scripting actions' }
GLMPresentation >> populate: aPortSymbol on: aCharacter entitled: aString with: aBlock [ 
	 
	self 
		addAction: 
			((GLMGenericAction new) 
				action: 
						((GLMPortUpdater new) 
								portSymbol: aPortSymbol; 
								valueBlock: aBlock; 
								yourself); 
				shortcut: aCharacter; 
				title: aString;
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> populate: aPortSymbol on: aCharacter with: aBlock [
	self addAction: 
			((GLMGenericAction new) 
				action: ((GLMPortUpdater new) 
								portSymbol: aPortSymbol; 
								valueBlock: aBlock; 
								yourself); 
				shortcut: aCharacter; 
				yourself)
]

{ #category : #accessing }
GLMPresentation >> portChangeActions [
	^ portChangeActions
]

{ #category : #accessing }
GLMPresentation >> portChangeActions: anObject [
	portChangeActions := anObject
]

{ #category : #copying }
GLMPresentation >> postCopy [
	super postCopy.
	pane := nil.
	self flag: 'self unregisterFromAllAnnouncements.'.
	updateActions := updateActions
		collect: [ :each | 
			each copy
				presentation: self;
				yourself ].
	rawSelectionTransmissions := rawSelectionTransmissions collect: [:each | each copy].
	rawSelectionTransmissions do: [:transmission | transmission originReferences do: [:portRef | portRef port presentation: self]].
	rawSelectionTransmissions do: [:transmission | transmission destination presentation: self]
]

{ #category : #printing }
GLMPresentation >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(id=';
		print: self identityHash ;
		nextPutAll: ' title=';
		print: self titleValue ;
		nextPutAll: ' pane=';
		print: self pane ;
		nextPutAll: ')'
]

{ #category : #'accessing ports' }
GLMPresentation >> rawSelection [
	^ (self pane port: #rawSelection) value
]

{ #category : #transmitting }
GLMPresentation >> rawSelectionTransmissionFor: aPortSymbol ifNone: ifNoneBlock [
	^ rawSelectionTransmissions
		detect: [ :transmission | transmission destination port name = aPortSymbol ]
		ifNone: ifNoneBlock
]

{ #category : #updating }
GLMPresentation >> registerAnnouncements [
	"this method is called from the rendering code"
	self flag: 'The announcements should potentially be interested in any ports, not just in entity'.
	updateActions do: [:each | each registerInPresentation ].
]

{ #category : #updating }
GLMPresentation >> registeredAnnouncers [
	^ registeredAnnouncers ifNil: [registeredAnnouncers := OrderedCollection new]
]

{ #category : #rendering }
GLMPresentation >> renderGlamorouslyOn: aRenderer [ 
	self registerAnnouncements.
	^aRenderer renderPresentation: self
]

{ #category : #updating }
GLMPresentation >> requestRefresh [
	"I send the presentation a request to update that the presentation can ignore depending
	on it's state. For example the presentation can ingnore this if it is not visible on screen.
	Use #update to force a refresh."
	self pane ports do: [:each |
		(self validate: each value on: each) ifFalse: [each resetValue] ].
	self announce: (GLMPresentationRefreshRequest new presentation: self)
]

{ #category : #copying }
GLMPresentation >> rootPrototype [

	^ self parentPrototype ifNil: [ self ] ifNotNil: [ self parentPrototype rootPrototype ]
]

{ #category : #'accessing ports' }
GLMPresentation >> selection [
	^ (self pane port: #selection) value
]

{ #category : #'accessing ports' }
GLMPresentation >> selection: anObject [
	"Tell the pane about the new selection. This method is called when the user changes a view's selection' (e.g., he clicks on an element in a list morph)." 
	(self pane port: #rawSelection) value: anObject.
	self acceptsSelection ifFalse: [^ self].
	rawSelectionTransmissions do: #transmit
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionAct: aBlock entitled: aString [ 
	 
	self 
		addSelectionAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				title: aString; 
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionAct: aBlock entitled: aString categorized: anotherString [
	 
	self 
		addSelectionAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				title: aString; 
				category: anotherString;
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionAct: aBlock entitled: aString condition: conditionBlock [
	 
	self 
		addSelectionAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				title: aString;
				condition: conditionBlock; 
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionAct: aBlock entitled: aString enabledWhen: conditionBlock [
	 
	self 
		addSelectionAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				title: aString;
				enabledCondition: conditionBlock; 
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionAct: aBlock icon: anIcon entitled: aString [
	self 
		addSelectionAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				icon: anIcon;
				title: aString;
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionAct: aBlock icon: anIcon on: aCharacter entitled: aString [ 
	 
	self 
		addSelectionAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				icon: anIcon;
				shortcut: aCharacter; 
				title: aString; 
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionAct: aBlock iconName: aSymbol entitled: aString [
	self selectionAct: aBlock icon: (self iconNamed: aSymbol) entitled: aString
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionAct: aBlock iconName: aSymbol on: aCharacter entitled: aString [ 
	 
	self selectionAct: aBlock icon: (self iconNamed: aSymbol) on: aCharacter entitled: aString
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionAct: aBlock on: aCharacter [ 
	 
	self 
		addSelectionAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				shortcut: aCharacter; 
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionAct: aBlock on: aCharacter entitled: aString [ 
	 
	self 
		addSelectionAction: 
			((GLMGenericAction new) 
				action: aBlock; 
				shortcut: aCharacter; 
				title: aString; 
				yourself)
]

{ #category : #accessing }
GLMPresentation >> selectionActions [
	"These are actions that make sense only in the context of values held in the selection port."
	^ selectionActions ifNil: [ selectionActions := OrderedCollection new ]
]

{ #category : #accessing }
GLMPresentation >> selectionActions: anObject [
	selectionActions := anObject
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionPopulate: aPortSymbol entitled: aString with: aBlock [ 
	 
	self 
		addSelectionAction: 
			((GLMGenericAction new) 
				action: 
						((GLMPortUpdater new) 
								portSymbol: aPortSymbol; 
								valueBlock: aBlock; 
								yourself); 
				title: aString;
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionPopulate: aPortSymbol on: aCharacter entitled: aString with: aBlock [ 
	 
	self 
		addSelectionAction: 
			((GLMGenericAction new) 
				action: 
						((GLMPortUpdater new) 
								portSymbol: aPortSymbol; 
								valueBlock: aBlock; 
								yourself); 
				shortcut: aCharacter; 
				title: aString;
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> selectionSpawn: aBlock entitled: aString [ 
	 
	"These are actions that return a glamour browser to open at the end."
	self 
		addSelectionAction: 
			((GLMSpawnBrowserAction new) 
				action: aBlock; 
				title: aString; 
				yourself)
]

{ #category : #transmitting }
GLMPresentation >> selectionTransformation [
	"this is used for transforming the object before updating the selection"
	^ self selectionTransmission transformation ifNil: [#yourself]
]

{ #category : #transmitting }
GLMPresentation >> selectionTransformation: anObject [ 
	self selectionTransmission 	transformation: anObject 
]

{ #category : #transmitting }
GLMPresentation >> selectionTransmission [
	^ self rawSelectionTransmissionFor: #selection ifNone: [nil]
]

{ #category : #scripting }
GLMPresentation >> send: aBlock [ 
	self selectionTransformation: aBlock
]

{ #category : #scripting }
GLMPresentation >> send: aBlock as: aPortSymbol [
	(self
			rawSelectionTransmissionFor: aPortSymbol
			ifNone: [ self addRawSelectionTransmissionTo: aPortSymbol ])
		transformation: aBlock
]

{ #category : #scripting }
GLMPresentation >> sendOneOrMultiple [
	self sendOneOrMultipleAs: Array
]

{ #category : #scripting }
GLMPresentation >> sendOneOrMultipleAs: aCollectionClass [
	self sendOneOrMultipleAs: aCollectionClass updatedBy: [ :aCollection | aCollection ]
]

{ #category : #scripting }
GLMPresentation >> sendOneOrMultipleAs: aCollectionClass updatedBy: oneArgBlock [
	"It returns one selected item or a collection of aCollectionClass updated by oneArgBlock.
	oneArgBlock can add additional information to the collection or transform the collection."
	self send: [ :linkedListOrNil |
		linkedListOrNil ifNotNil: [ 
			linkedListOrNil size = 1
				ifTrue: [ (linkedListOrNil first isCollection and: [ linkedListOrNil first size = 1 ]) 
					ifTrue: [ linkedListOrNil first first ]
					ifFalse: [ linkedListOrNil first ] ]
				ifFalse: [ oneArgBlock cull: (linkedListOrNil as: aCollectionClass) ] ]
		 ]
]

{ #category : #'accessing validation' }
GLMPresentation >> shouldValidate [
	^ shouldValidate ifNil: [shouldValidate := false]
]

{ #category : #'accessing validation' }
GLMPresentation >> shouldValidate: aBoolean [
	shouldValidate := aBoolean 
]

{ #category : #accessing }
GLMPresentation >> sourceContext [
	^ sourceLink
]

{ #category : #accessing }
GLMPresentation >> sourceContext: aContext [
	sourceLink := aContext
]

{ #category : #'scripting actions' }
GLMPresentation >> spawn: aBlock entitled: aString [ 
	"These are actions that return a glamour browser to open at the end."
	self 
		addAction: 
			((GLMSpawnBrowserAction new) 
				action: aBlock; 
				title: aString; 
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> spawn: aBlock icon: anIcon entitled: aString [
	self 
		addAction: 
			((GLMSpawnBrowserAction new) 
				action: aBlock; 
				icon: anIcon;
				title: aString;
				yourself)
]

{ #category : #'scripting actions' }
GLMPresentation >> spawn: aBlock iconName: aSymbol entitled: aString [
	self spawn: aBlock icon: (self iconNamed: aSymbol) entitled: aString
	
]

{ #category : #'accessing ports' }
GLMPresentation >> status: anObject [ 
	self flag: 'what kind of transformation should we want here?'.
	(self pane port: #status) value: (self selectionTransformation glamourValue: anObject)
]

{ #category : #statusbar }
GLMPresentation >> statusbarPane [
	^ statusPane
]

{ #category : #statusbar }
GLMPresentation >> statusbarPresentation [
	^ GLMLabelPresentation new
]

{ #category : #stepping }
GLMPresentation >> step [
	"Be default no action is performed. Custom presentations that enable 
	stepping should specify a concrete behaviour."
]

{ #category : #stepping }
GLMPresentation >> stepCondition [

	^ stepCondition ifNil: [ [ false ] ]
]

{ #category : #stepping }
GLMPresentation >> stepCondition: aBlock [

	stepCondition := aBlock
]

{ #category : #stepping }
GLMPresentation >> stepTime [

	^ stepTime ifNil: [ super stepTime ]
]

{ #category : #stepping }
GLMPresentation >> stepTime: anInteger [

	stepTime := anInteger
]

{ #category : #'accessing ports' }
GLMPresentation >> strongSelection [
	^ (self pane port: #strongSelection) value
]

{ #category : #'accessing ports' }
GLMPresentation >> strongSelection: anObject [
	(self pane port: #strongSelection) value: (self selectionTransformation glamourValue: anObject)
]

{ #category : #accessing }
GLMPresentation >> taskbarIcon [ 
	^ self titleIcon
]

{ #category : #accessing }
GLMPresentation >> title [
	^ title
]

{ #category : #accessing }
GLMPresentation >> title: aStringOrBlock [ 
	 
	title := aStringOrBlock
]

{ #category : #accessing }
GLMPresentation >> titleAction [
	^ self titleActionBlock ifNotNil: [ :aBlock | aBlock glamourValue: self ]
]

{ #category : #'scripting actions' }
GLMPresentation >> titleAction: aBlock [ 

	labelActionBlock := aBlock
]

{ #category : #accessing }
GLMPresentation >> titleActionBlock [

	^ labelActionBlock
]

{ #category : #accessing }
GLMPresentation >> titleIcon [
	^ titleIcon
]

{ #category : #accessing }
GLMPresentation >> titleIcon: anObject [
	titleIcon := anObject
]

{ #category : #'accessing values' }
GLMPresentation >> titleIconValue [
	^ self titleIcon notNil
		ifTrue: [ self titleIcon glamourValue: self entity ]
		ifFalse: [ self titleIcon ]
]

{ #category : #'accessing values' }
GLMPresentation >> titleValue [
	^ self title glamourValue: self entity
]

{ #category : #accessing }
GLMPresentation >> transformation [ 
	 
	^transformation ifNil: [transformation := [:x | x ]]
]

{ #category : #accessing }
GLMPresentation >> transformation: aBlock [ 
	 
	transformation := aBlock
]

{ #category : #updating }
GLMPresentation >> unregisterFromAllAnnouncements [
	"this method should be called every time the presentation is not needed"
	updateActions do: [ :each | each unregisterFromAllAnnouncements ]
]

{ #category : #updating }
GLMPresentation >> update [
	self pane ports do: [:each |
		(self validate: each value on: each) ifFalse: [each resetValue] ].
	self announce: (GLMPresentationUpdated new presentation: self)
]

{ #category : #updating }
GLMPresentation >> updateOn: anAnnouncement from: aBlockOrSymbol [ 
	updateActions add: (GLMSingleUpdateAction new 
		presentation: self;
		announcement: anAnnouncement; 
		transformation: aBlockOrSymbol;
		yourself)
]

{ #category : #updating }
GLMPresentation >> updateOn: anAnnouncement from: aBlockOrSymbol when: aConditionBlock [
	updateActions add: (GLMSingleUpdateAction new
		presentation: self; 
		announcement: anAnnouncement; 
		transformation: aBlockOrSymbol;
		condition: aConditionBlock;
		yourself)
]

{ #category : #updating }
GLMPresentation >> updateOn: anAnnouncement fromAll: aBlockOrSymbol [ 
	updateActions add: (GLMMultipleUpdateAction new
		presentation: self; 
		announcement: anAnnouncement; 
		transformation: aBlockOrSymbol;
		yourself)
]

{ #category : #updating }
GLMPresentation >> updateToolbar [

	self announce: (GLMPresentationToolbarUpdated new presentation: self)
]

{ #category : #accessing }
GLMPresentation >> useExplicitAllNil [ 
	 
	implicitAllNil := true
]

{ #category : #accessing }
GLMPresentation >> useExplicitNotNil [ 
	 
	implicitNotNil := false
]

{ #category : #accessing }
GLMPresentation >> useImplicitAllNil [ 
	 
	implicitAllNil := true
]

{ #category : #accessing }
GLMPresentation >> useImplicitNotNil [ 
	 
	implicitNotNil := true
]

{ #category : #testing }
GLMPresentation >> usesExplicitNotNil [ 
	 
	^self usesImplicitNotNil not
]

{ #category : #testing }
GLMPresentation >> usesImplicitAllNil [
	 
	^implicitAllNil ifNil: [implicitAllNil := false ]
]

{ #category : #testing }
GLMPresentation >> usesImplicitNotNil [ 
	 
	^implicitNotNil ifNil: [implicitNotNil := true]
]

{ #category : #validation }
GLMPresentation >> validate: anObject on: aPort [ 
	"This gets triggered when aPort wants to be changed.
	The presentation has a chance to veto the value."
	self shouldValidate ifFalse: [ ^ true ].
	^ self doValidate: anObject on: aPort.
]

{ #category : #accessing }
GLMPresentation >> wantsAutomaticRefresh [
	"Answer whether this presentations supports automatic refresh. Unlike stepping
	the refresh rate is not controlled by the presentation but by the browser containing
	the presentation. If a presentation wants to control its refresh rate it should
	rely on #wantsStep."
	^ wantsAutomaticRefresh ifNil: [ false ]
]

{ #category : #accessing }
GLMPresentation >> wantsAutomaticRefresh: aBoolean [
	wantsAutomaticRefresh := aBoolean
]

{ #category : #stepping }
GLMPresentation >> wantsSteps [
	"Answer whether this presentation wants stepping. Stepping is controlled by the morph
	and sends to the presentation the message #step at intervals controlled by #stepTime."
	^ wantsSteps ifNil: [ false ]
]

{ #category : #stepping }
GLMPresentation >> wantsSteps: aBoolean [

	wantsSteps := aBoolean
]

{ #category : #accessing }
GLMPresentation >> watcherPane [
	^ nil
]

{ #category : #scripting }
GLMPresentation >> when: aBlock [ 
	 
	self condition: aBlock
]

{ #category : #scripting }
GLMPresentation >> whenKindOf: aClass [ 
	 
	self when: [:each | each isKindOf: aClass]
]

{ #category : #accessing }
GLMPresentation >> window [
	self announce: (GLMWindowRequest new
		action: [ :aWindow | ^ aWindow ]).
	^ nil
]

{ #category : #events }
GLMPresentation >> windowIsClosing [ 
	| event |
	event := GLMBrowserClosing new presentation: self.
	self withAllPresentations do: [ :each | each announce: event ]
]

{ #category : #scripting }
GLMPresentation >> with: aBlock [
	aBlock value: self
]

{ #category : #enumerating }
GLMPresentation >> withAllPanes [
	| result |
	result := OrderedCollection new.
	self withAllPanesAndPresentationsDo: [:each |
		(each isKindOf: GLMPane) ifTrue: [ result add: each ]].
	^ result
]

{ #category : #enumerating }
GLMPresentation >> withAllPanesAndPresentationsDo: aBlock [
	^ aBlock value: self
]

{ #category : #enumerating }
GLMPresentation >> withAllPresentations [
	| result |
	result := OrderedCollection new.
	self withAllPanesAndPresentationsDo: [:each |
		(each isKindOf: GLMPresentation) ifTrue: [ result add: each ]].
	^ result
]
