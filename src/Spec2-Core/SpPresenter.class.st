"
SpPresenter is an abstract class which represent a applicative presenter made to be composed with other SpPresenter

Most often, I am used to display other subclasses of SpPresenter or subclasses of SpAbstractWidgetPresenter.

I collaborate with 
- ValueHolder to managed some of my variables.
- SpecFocusOrder when no focusOrder are specified.
- SpecLayout
- WindowPresenter or DialogWindowPresenter to display myself.

A new subclass of SpPresenter must at least define initializeWidgets and defaultSpec on the class side.

I provide the following methods
- aboutText: set the text displayed in the About.
- initializeWindow: to set the title, and other information related to the window.
- extent: set the initial size of the window, alternative possibility is define again initialExtent, it must be called before have displayed the widget. 
- focusOrder: set an instance what manage the order of focus of the keyboard navigation.
- bindKeyCombination:toAction: create a shortcut on keyboard what perform the block of the  action.
- owner getter of my parent.
- window getter of the window displaying me.

On my class side, I provide methods returning standard height and width for some elements.

todo
- announce:
- applyMenuModel: and neglectMenuModel:
- keyStrokeForNextFocus:, giveFocusToNextFrom: and takeKeyboardFocus
- ensureExtentFor:
- hide
- needRebuild
- on:do:
- update:
- widget

Window
=======

- openWithSpec instantiates a WindowPresenter using the lookup to found the layout to use.
- openDialogWithSpec instanciates a DialogWindowPresenter using the lookup to found the layout to use.
Their variants openWithSpec: and openDialogWithSpec:  use the layout parameter.

These methods can be useful to manage the window
- isDisplayed returns true if the window of the widget is displayed
- hasWindow returns true if the widget have a window
- centered to center the window in the world.
- delete to delete the window.

todo
- cancelled
- setModal:
- windowIcon:


Instantiation
===========

* initializeWidgets is called by the initialize method, it should contain initialization of subwidgets and of the focusorder.

The instantiation of a subwidget should use one of that way
- instantiate: take a class in parameter and return the created instance.
- methods named 'new' followed by a widget name are shortcut working with instatiate:

Usually, the subwidgets must be added in the focusOrder using something like 'self focusOrder add: accessor of  the  subwidget'

Note that instantiateModels: is legacy code in ComposablePresenter and must not be used. It will be deprecated and removed.

* initializePresenter is called by the initialize method after initializeWidgets, it should manage interaction of subwidgets.

Methods named 'when' followed by an event provide hook to perform the action in parameter.

Note
-------
Be careful about code order if you are overriding initialize method.
Normally in Spec initializing instance variables should be done BEFORE calling super initialize (so the opposite of the normal approach), because super initialize calls initalizeWidgets and initializePresenter that normally would make use of those variables.

Layout
======

See SpecLayout

defaultSpec or a method containing the pragma <spec: #default> must be defined in the class side of my subclasses.
It contains informations about how place its elements.
It possible to define more than one method to give the possibility to use another layout, by default the one containing the pragma will be used if it exists, if not defaultSpec will be used.
"
Class {
	#name : #SpPresenter,
	#superclass : #SpAbstractPresenter,
	#traits : 'SpTPresenterBuilder',
	#instVars : [
		'#application',
		'#focusOrder',
		'#contextKeyBindings => SpObservableSlot',
		'#windowIcon => SpObservableSlot',
		'#aboutText => SpObservableSlot',
		'#askOkToClose => SpObservableSlot',
		'#titleHolder => SpObservableSlot',
		'#additionalSubpresentersMap',
		'#layout => SpObservableSlot',
		'#visible => SpObservableSlot',
		'#extent => SpObservableSlot',
		'#styles'
	],
	#category : #'Spec2-Core-Base'
}

{ #category : #accessing }
SpPresenter class >> currentApplication [ 

	^ SpApplication defaultApplication
]

{ #category : #specs }
SpPresenter class >> defaultSpec [

	^ self subclassResponsibility
]

{ #category : #accessing }
SpPresenter class >> iconNamed: aSymbol [
	^ Smalltalk ui icons iconNamed: aSymbol
]

{ #category : #'labelled-presenters' }
SpPresenter class >> iconWidth [
	^ 24
]

{ #category : #testing }
SpPresenter class >> isAbstract [
	^ self = SpPresenter
]

{ #category : #'labelled-presenters' }
SpPresenter class >> labelWidth [
	^ 100
]

{ #category : #'instance creation' }
SpPresenter class >> newApplication: anApplication [

	^ self basicNew
		application: anApplication;
		initialize;
		yourself
]

{ #category : #'instance creation' }
SpPresenter class >> newApplication: anApplication model: aModel [

	^ self basicNew
		application: anApplication;
		setModelBeforeInitialization: aModel;
		initialize;
		yourself
]

{ #category : #'instance creation' }
SpPresenter class >> newApplication: anApplication owner: anOwningPresenter [

	^ self basicNew
		application: anApplication;
		owner: anOwningPresenter;
		initialize;
		yourself
]

{ #category : #'instance creation' }
SpPresenter class >> newApplication: anApplication owner: anOwningPresenter model: aDomainObject [

	^ self basicNew
		application: anApplication;
		owner: anOwningPresenter;
		setModelBeforeInitialization: aDomainObject;
		initialize;
		yourself
]

{ #category : #'instance creation' }
SpPresenter class >> on: aDomainObject [

	^ self 
		newApplication: self currentApplication
		model: aDomainObject 
]

{ #category : #'instance creation' }
SpPresenter class >> owner: anOwningPresenter on: aDomainObject [

	^ self basicNew
		owner: anOwningPresenter;
		setModelBeforeInitialization: aDomainObject;
		initialize;
		yourself
]

{ #category : #specs }
SpPresenter class >> title [
	
	^ 'Untitled window'
]

{ #category : #TOREMOVE }
SpPresenter >> aboutText [
	"DO NOT USE
	With Spec 2, SpPresenter was refactored to move all window management to WindowPresenter.
	From now on, if you want to interact with a window you need to:
	- Implement #initializeWindow: method (#initializeDialog: for dialogs) to manage window elements before the presenter is opened
	- Use the method #window or #withWindowDo: to interact with windows after it has been opened.
	
	This method cannot be deprecated because during a transition phase we keep this mecanism. "

	^ aboutText
]

{ #category : #private }
SpPresenter >> addAll: aWindow withSpecLayout: aSpec [

	aWindow
		addMorph: (self buildWithSpecLayout: aSpec)
		frame: (0@0 corner: 1@1).
]

{ #category : #TOREMOVE }
SpPresenter >> addMenuItemsToWindowMenu: aMenu [
	"Do nothing"
]

{ #category : #api }
SpPresenter >> addStyle: aStyle [
	"Add a style-class to a presenter. Styles are defined in the application stylesheet and will 
	 affect presenters by applying the properties the user adds to the class.
	 - Styles can just be added to widget presenters (the ones that inherits of *SpAbstractWidgetPresenter*).
	 - Styles can be added and removed dynamically (see also *SpAbstractWidgetPresenter>>removeStyle:*
	
	[[[language=Smalltalk
	button := self newButton 
		label: 'Example of style';
		addStyle: 'myButton';
		yourself.
	]]]"

	(styles includes: aStyle) ifTrue: [ ^ self ].
	styles := styles copyWith: aStyle.
	self withAdapterDo: [ :anAdapter | anAdapter addStyle: aStyle ]
]

{ #category : #TOREMOVE }
SpPresenter >> additionalSubpresentersMap [

	"additionalSubpresentersMap serves for storing of sub-presenters that are not
	stored in instance variables"
	
	self flag: #TOREMOVE. "This is now provided by TDynamicPresenter"
	^ additionalSubpresentersMap ifNil: [ additionalSubpresentersMap := Dictionary new ]
]

{ #category : #'private-traversing' }
SpPresenter >> allPresenters [
	| allPresenters |

	allPresenters := OrderedCollection new.
	self traversePresentersDo: [ :each | 
		allPresenters add: each ].
	^ allPresenters
]

{ #category : #private }
SpPresenter >> allPresentersInFocusOrder [
	| allPresenters |

	allPresenters := OrderedCollection new.
	self traverseInFocusOrderDo: [ :each |
		allPresenters add: each  ].
	^ allPresenters
]

{ #category : #api }
SpPresenter >> announce: anAnnouncement [

	self announcer announce: anAnnouncement
]

{ #category : #'api-events' }
SpPresenter >> announceDisplayed [
	"When using a VersatileDialogPresenter the adapter is nil.
	We do not know if that is a correct behaviour"

	self announcer
		announce:
			(SpWidgetDisplayed new
				presenter: self;
				widget: (adapter ifNotNil: [ adapter widget ]);
				yourself)
]

{ #category : #accessing }
SpPresenter >> application [

	^ self hasOwner 
		ifTrue: [ self owner application ]
		ifFalse: [
			application ifNil: [ 
				self flag: #TODO. "This is incorrect, no component who is also a root
				(it does not has owner) should not have an application. But in older times
				it was not like that and to support such components we assign them to a 
				default application"
				application := SpApplication defaultApplication ] ]
]

{ #category : #accessing }
SpPresenter >> application: anApplication [

	application := anApplication
]

{ #category : #TOREMOVE }
SpPresenter >> applyMenuModel: aMenuModel [

	aMenuModel menuGroups do: [ :group |
		group menuItems do: [ :item |
			item shortcut ifNotNil: [ :shortcut | 
				self 
					bindKeyCombination: shortcut 
					toAction: [ item performMenuActionWith: #() ] ].
			item subMenu ifNotNil: [ :subMenu | subMenu applyTo: self	] ] ]
]

{ #category : #converting }
SpPresenter >> asPresenter [
	"This allows to use presenter instances inside layouts directly"

	^ self
]

{ #category : #TOREMOVE }
SpPresenter >> askOkToClose [
	"DO NOT USE
	With Spec 2, SpPresenter was refactored to move all window management to WindowPresenter.
	From now on, if you want to interact with a window you need to:
	- Implement #initializeWindow: method (#initializeDialog: for dialogs) to manage window elements before the presenter is opened
	- Use the method #window or #withWindowDo: to interact with windows after it has been opened.
	
	This method cannot be deprecated because during a transition phase we keep this mecanism. "

	^ askOkToClose
]

{ #category : #'private building' }
SpPresenter >> basicBuildAdapterWithSpecLayout: aSpecLayout [

	layout == aSpecLayout 
		ifFalse: [ layout := aSpecLayout ].
	^ super basicBuildAdapterWithSpecLayout: aSpecLayout
]

{ #category : #'api-shortcuts' }
SpPresenter >> bindKeyCombination: aShortcut toAction: aBlock [

	contextKeyBindings ifNil: [ contextKeyBindings := KMCategory new ].
	contextKeyBindings addKeymapEntry: (KMKeymap
		shortcut: aShortcut
		action: aBlock).
	self withAdapterDo: [ :anAdapter | 
		anAdapter bindKeyCombination: aShortcut toAction: aBlock ]
]

{ #category : #testing }
SpPresenter >> canTakeKeyboardFocus [
	"Answer when the presenter can take keyboard focus."

	^ true
]

{ #category : #'api-window' }
SpPresenter >> cancelled [
	self flag: #TODO. "just for dialogs... I wonder if we need it here?"

	self withWindowDo: #cancelled
]

{ #category : #'api-window' }
SpPresenter >> centered [

	self withWindowDo: #centered
]

{ #category : #initialization }
SpPresenter >> connectPresenters [
	"The method connectPresenters defines the interactions between the dif- ferent widgets. By connecting the behaviors of the different widgets it speci- fies the overall presentation, i.e., how the overall UI responds to interactions by the user. Usually this method consists of specifications of actions to per- form when a certain event is received by a widget. The whole interaction flow of the UI then emerges from the propagation of those events."
]

{ #category : #'api-shortcuts' }
SpPresenter >> contextKeyBindings [
	"contextKeyBindings stores a KMCategory with keybindings for this presenter"

	self flag: #TODO. "Think is... not all presenters can have keybindings. Why are we
	putting this functionality here and not in a trait?"
	^ contextKeyBindings
]

{ #category : #'api-shortcuts' }
SpPresenter >> contextKeyBindings: aKMCategory [

	contextKeyBindings := aKMCategory
]

{ #category : #private }
SpPresenter >> createInstanceFor: aClassSymbol [
	"Retrieve the class corresponding to aClassSymbol using the bindings, then create a new instance of theis class"
	| class |
	
	class := self resolveSymbol: aClassSymbol.
	^ self instantiate: class.
]

{ #category : #'api-focus' }
SpPresenter >> defaultKeyboardFocus [
	"Override this to allow the presenter to re-define the one that will answer the 
	 takeKeyboardFocus call in composed presenters"

	^ self
]

{ #category : #specs }
SpPresenter >> defaultSpec [

	^ self class perform: self defaultSpecSelector
]

{ #category : #'api-showing' }
SpPresenter >> defaultWindowPresenterClass [

	^ SpWindowPresenter
]

{ #category : #accessing }
SpPresenter >> defer: aBlock [

	self application defer: aBlock
]

{ #category : #private }
SpPresenter >> delete [

	self withWindowDo: #delete
]

{ #category : #accessing }
SpPresenter >> enabled: aBoolean [

	self presentersDo: [ :each | 
		each enabled: aBoolean ]
]

{ #category : #TOREMOVE }
SpPresenter >> extent [
	^ extent
]

{ #category : #TOREMOVE }
SpPresenter >> extent: aPoint [
	^ extent := aPoint
]

{ #category : #accessing }
SpPresenter >> focusOrder [

	^ focusOrder ifNil: [ focusOrder := OrderedCollection new ].
]

{ #category : #accessing }
SpPresenter >> focusOrder: anObject [
	^ focusOrder := anObject
]

{ #category : #'inspector-Extensions' }
SpPresenter >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: 30>
	self adapter ifNotNil: [ :w | w gtInspectorPreviewIn: composite ]
]

{ #category : #'inspector-Extensions' }
SpPresenter >> gtInspectorSubPresentersIn: composite [
	<gtInspectorPresentationOrder: 20>
	composite tree
		title: 'Sub presenters';
		rootsExpanded;
		display: [ :each | {each} ];
		children: [ :each | each presenters ];
		when: [ :each | each presenters isNotEmpty ]
]

{ #category : #'api-focus' }
SpPresenter >> hasKeyboardFocus [

	self canTakeKeyboardFocus ifFalse: [ ^ false ].
	self withAdapterDo: [ :anAdapter | ^ anAdapter hasKeyboardFocus ].
	^ false
]

{ #category : #api }
SpPresenter >> hide [

	visible := false
]

{ #category : #accessing }
SpPresenter >> iconNamed: aSymbol [

	^ self class iconNamed: aSymbol
]

{ #category : #TOREMOVE }
SpPresenter >> initialExtent [
	
	"DO NOT USE
	With Spec 2, SpPresenter was refactored to move all window management to WindowPresenter.
	From now on, if you want to interact with a window you need to:
	- Implement #initializeWindow: method (#initializeDialog: for dialogs) to manage window elements before the presenter is opened
	- Use the method #window or #withWindowDo: to interact with windows after it has been opened.
	
	This method cannot be deprecated because during a transition phase we keep this mecanism. "
	^ nil
]

{ #category : #initialization }
SpPresenter >> initialize [

	super initialize.

	visible := true.
	styles := #().

	self initializePrivateAnnouncer.
	self initializePrivateValueHolders.
	self initializePrivateHooks.
	self initializePrivateAnnouncements
]

{ #category : #initialization }
SpPresenter >> initializePresenter [
	"Now, presenters should implement #connectPresenters instead."

	self 
		property: #extent 
		whenChangedDo: [ :ex | 
			self withAdapterDo: [ :widget | 
				(widget respondsTo: #extent:) 
					ifTrue: [ widget extent: ex ] ] ]
]

{ #category : #initialization }
SpPresenter >> initializePresenters [
	"The method initializePresenters instantiates, saves in instance vari- ables, and partially configures the different widgets that will be part of the UI.
	In general the initializePresenters method should follow the pattern:
		• widget instantiation
		• widget configuration specification
		• specification of focus order"

	"self subclassResponsibility"
]

{ #category : #'initialization - private' }
SpPresenter >> initializePrivateAnnouncements [

	self property: #titleHolder whenChangedDo: [ self updateTitle ].
	self property: #layout whenChangedDo: [ :newLayout | self replaceLayoutWith: newLayout ]
]

{ #category : #'initialization - private' }
SpPresenter >> initializePrivateAnnouncer [

  announcer := Announcer new
]

{ #category : #'initialization - private' }
SpPresenter >> initializePrivateHooks [
	self flag: #todo. "We should remove later #initializeWidgets and #initializePresenter."
	self initializeWidgets.
	self initializePresenters.
	self initializePresenter.
	self connectPresenters.
	self updatePresenter.

]

{ #category : #'initialization - private' }
SpPresenter >> initializePrivateValueHolders [

	askOkToClose := false.
	titleHolder := self class title
]

{ #category : #initialization }
SpPresenter >> initializeWidgets [
	"Now, presenters should implement #initializePresenters instead."
]

{ #category : #initialization }
SpPresenter >> initializeWindow: aWindowPresenter [
	"override this to set window values before opening. 
	 You may want to add a menu, a toolbar or a statusbar"

	"IMPORTANT: Please ovirride this method and set yourself the informations you want in your window.
	The content of this method is here to help the transition between Spec 1 and 2.
	In the next Spec version the content of this method will be removed and it will do nothing by default because the goal is to remove the management of all of those informations from Composable to put them in WindowPresenter."

	aWindowPresenter
		title: self title;
		initialExtent: self initialExtent;
		windowIcon: self windowIcon;
		askOkToClose: self askOkToClose;
		aboutText: self aboutText
]

{ #category : #'inspector-Extensions' }
SpPresenter >> inspectionSubPresenters [
	<inspectorPresentationOrder: 910 title: 'Subpresenters'>
	
	^ SpTreePresenter new
		roots: self presenters;
		children: [ :each | each presenters ];
		expandRoots;
		yourself
]

{ #category : #'inspector-Extensions' }
SpPresenter >> inspectionSubPresentersContext: aContext [
	
	aContext active: self presenters notEmpty
]

{ #category : #'instance creation' }
SpPresenter >> instantiatePresenters: aCollectionOfPairs [
	"instantiatePresenters: is legacy code in SpPresenter and must not be used. It will be deprecated and removed."

	"Used to instantiate multiple sub widget at once. Take aCollectionOfPairs where each odd element is an inst var name and each even element is a class name, create an instance from the class name and store it into the inst var"

	(aCollectionOfPairs anySatisfy: [ :e | e isKindOf: Association ])
		ifTrue: [ aCollectionOfPairs
				do: [ :a | 
					| k v |
					k := a key.
					v := a value.
					self instVarNamed: k asString put: (self createInstanceFor: v) ] ]
		ifFalse: [ aCollectionOfPairs
				pairsDo: [ :k :v | self instVarNamed: k asString put: (self createInstanceFor: v) ] ]
]

{ #category : #testing }
SpPresenter >> isBuilt [
	^ self isDisplayed
]

{ #category : #testing }
SpPresenter >> isDisplayed [
	"Return true if the widget is currently displayed on screen"
	
	self flag: #TODO. "To move to WindowPresenter exclusive?"
	^ self hasWindow 
		ifTrue: [ self root isDisplayed ]
		ifFalse: [ false ]
]

{ #category : #testing }
SpPresenter >> isRoot [

	self withWindowDo: [ :w |
		^ w presenter = self ].
	^ false
]

{ #category : #testing }
SpPresenter >> isVisible [
	
	^ visible value
]

{ #category : #accessing }
SpPresenter >> layout [

	^ layout
]

{ #category : #api }
SpPresenter >> layout: aLayout [

	layout := aLayout
]

{ #category : #private }
SpPresenter >> layoutPresenters [

	layout ifNil: [ ^ self presenters ].
	
	^ layout deepPresenters
		select: [ :each | each isSymbol or: [ each isPresenter ] ]
		thenCollect: [ :each | 
			each isPresenter 
				ifTrue: [ each ]
				ifFalse:[ self presenterAt: each ] ]
]

{ #category : #accessing }
SpPresenter >> locale [ 

	^ self application locale
]

{ #category : #localization }
SpPresenter >> localeChanged [

	"do nothing here. Override me in subclasses to update strings presented to the users"
	
]

{ #category : #TOREMOVE }
SpPresenter >> neglectMenuModel: aMenuModel [

	aMenuModel menuGroups do: [ :group |
		group menuItems do: [ :item |
			item shortcut ifNotNil: [ :shortcut | self removeKeyCombination: shortcut ].
			item subMenu ifNotNil: [ :subMenu | subMenu neglect: self	] ] ]
]

{ #category : #private }
SpPresenter >> okToChange [

	^ self hasWindow
		ifTrue: [ self window okToChange ]
		ifFalse: [ true ] 
]

{ #category : #'api-announcements' }
SpPresenter >> on: anAnnouncement send: aSelector to: aTarget [

	self announcer
		when: anAnnouncement 
		send: aSelector 
		to: aTarget
]

{ #category : #accessing }
SpPresenter >> presenterAt: aName [
	"Retrieves a subpresenter of this composed presenter."

	^ self readSlotNamed: aName
]

{ #category : #accessing }
SpPresenter >> presenterAt: aName ifAbsent: aBlock [
	"Retrieves a subpresenter of this composed presenter."

	^ [ self readSlotNamed: aName ]
		on: SlotNotFound
		do: aBlock
]

{ #category : #'private-traversing' }
SpPresenter >> presenters [
	| presenters |

	presenters := OrderedCollection new.
	self presentersDo: [ :each | 
		presenters add: each ].
	^ presenters
]

{ #category : #'private-traversing' }
SpPresenter >> presentersDo: aBlock [

	self class allSlots 
		reject: [ :each | each name = #owner ] 
		thenDo: [ :each | | var |
			var := self readSlot: each.
			(var isKindOf: SpAbstractPresenter) ifTrue: [ 
				aBlock value: var ] ]
]

{ #category : #private }
SpPresenter >> presentersInFocusOrder [

	^ focusOrder ifNil: [ 
		self layoutPresenters
			select: [ :each | each isVisible and: [ each canTakeKeyboardFocus ] ] ]
]

{ #category : #private }
SpPresenter >> rebuildLayout [

	self replaceLayoutWith: self layout
]

{ #category : #'api-shortcuts' }
SpPresenter >> removeKeyCombination: aShortcut [

	self contextKeyBindings removeKey: aShortcut ifAbsent: [ ^ self ].
	self withAdapterDo: [ :anAdapter | 
		anAdapter removeKeyCombination: aShortcut ]
]

{ #category : #api }
SpPresenter >> removeStyle: aStyle [

	(styles includes: aStyle) ifFalse: [ ^ self ].
	styles := styles copyWithout: aStyle.
	self withAdapterDo: [ :anAdapter | anAdapter removeStyle: aStyle ]
]

{ #category : #private }
SpPresenter >> replaceLayoutWith: aLayout [

	self withAdapterDo: [ :anAdapter |
		anAdapter replaceLayoutWith: aLayout ]
]

{ #category : #'api-window' }
SpPresenter >> requestWindowClose [

	"returns <true> if the user is allowed to close the window. Useful if you want to ask user if he wants to save the changed content etc."
	
	^ true
]

{ #category : #private }
SpPresenter >> resolveSymbol: aSymbol [

	^ Smalltalk at: aSymbol
]

{ #category : #api }
SpPresenter >> retrieveSpec: aSelector [

	self layout ifNotNil: [ ^ self layout ].
	^ super retrieveSpec: aSelector
]

{ #category : #'accessing model' }
SpPresenter >> setModel: aDomainObject [


]

{ #category : #'accessing model' }
SpPresenter >> setModelBeforeInitialization: aDomainObject [


]

{ #category : #api }
SpPresenter >> show [

	visible := true
]

{ #category : #api }
SpPresenter >> styles [ 

	^ styles
]

{ #category : #'api-focus' }
SpPresenter >> takeKeyboardFocus [
	| focus |

	focus := self defaultKeyboardFocus ifNil: [ self ].
	focus == self ifFalse: [ ^ focus takeKeyboardFocus ].
	
	self withAdapterDo: [ :anAdapter | 
		anAdapter takeKeyboardFocus ]
]

{ #category : #TOREMOVE }
SpPresenter >> title [
	"DO NOT USE
	With Spec 2, SpPresenter was refactored to move all window management to WindowPresenter.
	From now on, if you want to interact with a window you need to:
	- Implement #initializeWindow: method (#initializeDialog: for dialogs) to manage window elements before the presenter is opened
	- Use the method #window or #withWindowDo: to interact with windows after it has been opened.
	
	This method cannot be deprecated because during a transition phase we keep this mecanism. "

	^ titleHolder
]

{ #category : #TOREMOVE }
SpPresenter >> toolName [

	^ self class toolName
]

{ #category : #'private-traversing' }
SpPresenter >> traverseInFocusOrderDo: aBlock [

	self 
		traverseInFocusOrderDo: aBlock 
		excluding: Set new
]

{ #category : #'private-traversing' }
SpPresenter >> traverseInFocusOrderDo: aBlock excluding: excludes [

	"(excludes includes: self) ifTrue: [ ^ self ]. 
	excludes add: self.
	aBlock value: self."

	self presentersInFocusOrder do: [ :each |
		each traverseInFocusOrderDo: aBlock excluding: excludes ]
]

{ #category : #'private-traversing' }
SpPresenter >> traversePresentersDo: aBlock [

	self 
		traversePresentersDo: aBlock 
		excluding: Set new
]

{ #category : #'private-traversing' }
SpPresenter >> traversePresentersDo: aBlock excluding: excludes [

	(excludes includes: self) ifTrue: [ ^ self ]. 
	excludes add: self.
	aBlock value: self.

	self class allSlots do: [ :each | | var |
		var := self readSlot: each.
		(var isKindOf: SpAbstractPresenter) ifTrue: [ 
			var traversePresentersDo: aBlock excluding: excludes ] ]
]

{ #category : #updating }
SpPresenter >> update [
	self needRebuild: false.
	self buildWithSpec
]

{ #category : #initialization }
SpPresenter >> updatePresenter [
]

{ #category : #api }
SpPresenter >> visibleIf: aValuable [
	visible := aValuable
]

{ #category : #'api-events' }
SpPresenter >> whenContextKeyBindingsChangedDo: aBlock [
	
	self property: #contextKeyBindings whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpPresenter >> whenDisplayDo: aBlock [

	self announcer when: SpWidgetDisplayed do: aBlock
]

{ #category : #'api-events' }
SpPresenter >> whenVisibleChangedDo: aBlock [
	
	self property: #visible whenChangedDo: aBlock
]

{ #category : #'api-window' }
SpPresenter >> whenWindowChanged: aBlock [

	self flag: #TODO. "This is here for backwards compatibility (you can have same 
	functionality in #initializeWindow:"
	self announcer 
		when: SpWindowBuilt 
		do: [ :ann | aBlock cull: ann model ]
]

{ #category : #TOREMOVE }
SpPresenter >> windowIcon [
	"DO NOT USE
	With Spec 2, SpPresenter was refactored to move all window management to WindowPresenter.
	From now on, if you want to interact with a window you need to:
	- Implement #initializeWindow: method (#initializeDialog: for dialogs) to manage window elements before the presenter is opened
	- Use the method #window or #withWindowDo: to interact with windows after it has been opened.
	
	This method cannot be deprecated because during a transition phase we keep this mecanism. "

	^ windowIcon
]
