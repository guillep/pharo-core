"
I am the adapter used to bridge a WindowPresenter and a SystemWindow
"
Class {
	#name : #SpMorphicWindowAdapter,
	#superclass : #SpAbstractMorphicWindowAdapter,
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #'widget API' }
SpMorphicWindowAdapter >> aboutText [

	^ self model model
		ifNotNil: [ :m | m aboutText ]
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> aboutTitle [
    ^ self model model
         ifNotNil: [ :m | (m respondsTo: #aboutTitle)
		ifTrue: [m aboutTitle]
		ifFalse: [m class name]].
]

{ #category : #initialization }
SpMorphicWindowAdapter >> addFocusRotationKeyBindings [
	"Windows should not process keybindings (because then the active widget will not get 
	 the event)"
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> addModelItemsToWindowMenu: aMenu [

	self model addMenuItemsToWindowMenu: aMenu
]

{ #category : #protocol }
SpMorphicWindowAdapter >> addPresenterIn: aWindow withSpecLayout: aSpec [

	self presenter initialPosition 
		ifNotNil: [ :position | aWindow position: position ].
	self presenter initialExtent 
		ifNotNil: [ :extent | aWindow extent: extent ].
	self presenter hasDecorations 
		ifFalse: [ aWindow removeLabelArea ].
	self presenter whenDecorationsChangedDo: [ :aBoolean |
		aBoolean 
			ifTrue: [ aWindow initializeLabelArea ]
			ifFalse: [ aWindow removeLabelArea ] ].
	
	self 
		addContent: (self presenter presenter buildWithSpecLayout: aSpec) 
		toWindow: aWindow
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> askOkToClose [

	^ self model askOkToClose
]

{ #category : #protocol }
SpMorphicWindowAdapter >> beep [ 
	
	widget flash
]

{ #category : #factory }
SpMorphicWindowAdapter >> buildWidget [

	^ SpWindow new
		model: model;
		isResizeable: self isResizeable;
		in: [ :this | self subscribeToAnnouncements: this ];
		yourself
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> cancelled [

	^ false
]

{ #category : #protocol }
SpMorphicWindowAdapter >> centered [

	self widgetDo: [ :w | 
		w
			computeFullBounds;
			position: (self currentWorld extent - w extent) // 2 ]
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> centeredRelativeTo: aWindowPresenter [
	| bounds position |

	self widgetDo: [ :w | 
		w computeFullBounds.
		bounds := aWindowPresenter
			ifNotNil: [ aWindowPresenter adapter widget bounds ]
			ifNil: [ self currentWorld bounds ].
		position := bounds origin + ((bounds extent - w extent) // 2).
		w position: position ]
]

{ #category : #protocol }
SpMorphicWindowAdapter >> close [

	self widget ifNotNil: [ :w | w close ]
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> delete [

	self widgetDo: [ :w | 
		w delete.
		self application windowClosed: self ]
]

{ #category : #protocol }
SpMorphicWindowAdapter >> extent: aPoint [

	^ self widget extent: aPoint
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> initialExtent [

	^ self model initialExtent
]

{ #category : #'event installing' }
SpMorphicWindowAdapter >> installFocusLostEvent: anEvent to: aWidget [

	aWidget announcer
		when: WindowDeActivated
		do: [ anEvent action value ]
]

{ #category : #'event installing' }
SpMorphicWindowAdapter >> installFocusReceivedEvent: anEvent to: aWidget [

	aWidget announcer
		when: WindowActivated
		do: [ anEvent action value ]
]

{ #category : #protocol }
SpMorphicWindowAdapter >> isDisplayed [

	^ self widget isDisplayed
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> isMaximized [

	self widgetDo: [ :w | ^ w isMaximized ].
	^ false
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> isMinimized [

	self widgetDo: [ :w | ^ w isMinimized ].
	^ false
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> isResizeable [

	^ self model isResizeable
]

{ #category : #'spec protocol' }
SpMorphicWindowAdapter >> isResizeable: aBoolean [

	^ self widgetDo: [ :w | w isResizeable: aBoolean ]
]

{ #category : #'spec protocol' }
SpMorphicWindowAdapter >> isTopWindow [

	self widgetDo: [ :w | ^ w isTopWindow ].
	^ false
]

{ #category : #'spec protocol' }
SpMorphicWindowAdapter >> maximize [

	self widgetDo: [ :w | w maximize ]
]

{ #category : #'spec protocol' }
SpMorphicWindowAdapter >> minimize [

	self widgetDo: [ :w | w minimize ]
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> okToChange [

	^ self model okToChange
]

{ #category : #protocol }
SpMorphicWindowAdapter >> open [

	self widget openInWorld.
	self presenter initialPosition 
		ifNotNil: [ :aPosition | self widget position: aPosition ].
	self presenter isCentered 
		ifTrue: [ self centered ].
	self presenter presenter takeKeyboardFocus.
	self windowIsOpening
]

{ #category : #protocol }
SpMorphicWindowAdapter >> rebuildWithSpecLayout: aSpec [

	| sub |
	sub := self model window submorphs copy.
	self model window removeAllMorphs.
	sub allButLast do: [ :e | self model window addMorphBack: e ].
	self model addPresenterIn: self widget withSpecLayout: aSpec.
	self widget model: self
]

{ #category : #factory }
SpMorphicWindowAdapter >> subscribeToAnnouncements: aWindow [

	aWindow announcer 
		when: SpWindowWillClose send: #announce: to: self presenter announcer;
		when: SpWindowResizing send: #announce: to: self presenter announcer;
		when: WindowClosed send: #windowClosed to: self
]

{ #category : #icons }
SpMorphicWindowAdapter >> taskbarIcon [

	^ self model taskbarIcon
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> title [

	^ self model title
]

{ #category : #'widget API' }
SpMorphicWindowAdapter >> title: aString [

	self widgetDo: [ :w | 
		w setLabel: (aString ifNotNil: [ :theString | 
				 theString localizedForPresenter: self presenter ]) ]
]

{ #category : #updating }
SpMorphicWindowAdapter >> windowClosed [

	self windowIsClosing.
	self presenter windowClosed
]

{ #category : #updating }
SpMorphicWindowAdapter >> windowIsClosing [

	self model windowIsClosing
]

{ #category : #updating }
SpMorphicWindowAdapter >> windowIsOpening [

	self presenter windowIsOpening
]
