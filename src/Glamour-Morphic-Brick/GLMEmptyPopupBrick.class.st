"
I am a general popup widget that also visually preserves a context of a trigger element.
I can opened based on opening strategy (hover, shift + hover, or double click + shift).
Subclasses should implement #onCreated method to customize popup content
"
Class {
	#name : #GLMEmptyPopupBrick,
	#superclass : #GLMInteractableBrick,
	#instVars : [
		'anchorBrick',
		'triggerBrick',
		'contentBrick',
		'popupLayout',
		'closer',
		'inset',
		'spacing'
	],
	#category : #'Glamour-Morphic-Brick-Widgets-UI-Popup'
}

{ #category : #examples }
GLMEmptyPopupBrick class >> createButton: hoverAction [

	^ (GLMActionButtonBrick new
			color: Color white;
			icon: GLMUIThemeExtraIcons glamorousBrowse;
			hoverAction: hoverAction;
			width: [ :b | b icon width * 2 ];
			height: [ :b | b icon height * 2 ])
]

{ #category : #examples }
GLMEmptyPopupBrick class >> createLabel: hoverAction [
	| label |

	label := GLMLabelBrick new
			enable;
			color: Color white;
			text: 'Hover me';
			vShrinkWrap;
			hShrinkWrap;
			yourself.
	
	
	label	when: #onMouseHover do: [ hoverAction value: label ].
	
	^ label
]

{ #category : #'popup - listeners' }
GLMEmptyPopupBrick >> addCloserListener [

	self
		assert: [ self closer isNotNil ]
		description: [ 'Closer must not be nil' ].
	
	self closer popup: self.
]

{ #category : #accessing }
GLMEmptyPopupBrick >> addContentBricks [
	
	self onCreated.
	self announce: #onCreated event: self triggerBrick
]

{ #category : #accessing }
GLMEmptyPopupBrick >> anchorBrick [

	^ anchorBrick
]

{ #category : #accessing }
GLMEmptyPopupBrick >> anchorBrick: aBrick [

	anchorBrick := aBrick.	
	self updateTriggerBrick
]

{ #category : #'brick-geometry' }
GLMEmptyPopupBrick >> area [
	| firstBounds secondBounds |

	firstBounds := self subbricks first outerBounds.
	secondBounds := self subbricks second outerBounds.

	^ GLMArea
		origin: firstBounds origin
		vectors: { 
			GLMVector east: firstBounds width.
			GLMVector south: firstBounds height.
			GLMVector horizontal: secondBounds corner x - firstBounds corner x.
			GLMVector south: secondBounds height.
			GLMVector west: secondBounds width.
			GLMVector north: secondBounds height.
			GLMVector horizontal: firstBounds origin x - secondBounds origin x.
			GLMVector north: firstBounds height
		}
]

{ #category : #'popup - layout' }
GLMEmptyPopupBrick >> beDownward [
	"Make popup layout to be downward"

	self popupLayout: GLMPopupBrickDownwardLayout new
]

{ #category : #'popup - opening' }
GLMEmptyPopupBrick >> beRightToLeftWithOffset: anOffset [

	self invalidateWith: [
		self triggerBrick hAlign: #right.
		self triggerBrick marginRight: anOffset.
		self foundationBrick bounds: (self foundationBrick bounds translateBy: (self width - self triggerBrick width - anOffset - inset left @ 0) negated) ]
]

{ #category : #'popup - layout' }
GLMEmptyPopupBrick >> beUpward [
	"Make popup layout to be upward"

	self popupLayout: GLMPopupBrickUpwardLayout new
]

{ #category : #'popup - opening' }
GLMEmptyPopupBrick >> close [
	"Close popup and remove it from the world"
	
	self foundationBrick delete.
	self onClosed
]

{ #category : #accessing }
GLMEmptyPopupBrick >> closer [
	"Return a current popup closer"
	^ closer
]

{ #category : #accessing }
GLMEmptyPopupBrick >> closer: aPopupCloser [
	"Change current popup closer to a given one"
	
	self removeCloserListener.
	closer := aPopupCloser.
	self addCloserListener
]

{ #category : #accessing }
GLMEmptyPopupBrick >> contentBrick [

	^ contentBrick

	
]

{ #category : #accessing }
GLMEmptyPopupBrick >> contentBrick: aBrick [

	contentBrick := aBrick.
	self addBrickBack: contentBrick
]

{ #category : #initialization }
GLMEmptyPopupBrick >> defaultCloser [
	"Return a default popup closer responsible for hiding a popup"
	<return: #GLMPopupBrickCloser>

	^ GLMPopupBrickCloser new
		predicate: GLMPopupBrickUnhoverPredicate new;
		yourself
]

{ #category : #initialization }
GLMEmptyPopupBrick >> defaultPopupLayout [
	^ GLMPopupBrickDownwardLayout new
]

{ #category : #initialization }
GLMEmptyPopupBrick >> defaultRenderer [
	^ GLMBrickAreaRenderer new
]

{ #category : #accessing }
GLMEmptyPopupBrick >> foundationBrick [

	^ (self owner isKindOf: GLMFoundationBrick)
		ifTrue: [ self owner ]
		ifFalse: [ self ]
]

{ #category : #'events-processing' }
GLMEmptyPopupBrick >> handlesKeyStroke: anEvent [

	^ true
]

{ #category : #'events-processing' }
GLMEmptyPopupBrick >> handlesMouseOver: anEvent [

	^ true
]

{ #category : #initialization }
GLMEmptyPopupBrick >> initialize [
	super initialize.
	
	anchorBrick := Morph new extent: 1@1.
	popupLayout := self defaultPopupLayout.
	closer := self defaultCloser.
	inset := self themer popupThemer inset asMargin.
	spacing := self themer popupThemer spacing.

	self
		initializeListeners;
		useVerticalLinearLayout;
		vShrinkWrap;
		hShrinkWrap;
		enable;
		initializeLayout
]

{ #category : #'popup - layout' }
GLMEmptyPopupBrick >> initializeLayout [
	"Create trigger and content bricks and let my popup layout
	to build a popup out of them"
	
	self popupLayout
		build: self
		trigger: self newTriggerBrick
		content: self newContentBrick
]

{ #category : #'popup - listeners' }
GLMEmptyPopupBrick >> initializeListeners [
	"using the most general event subscribtion for all events spawned by the hand"
	
	self addCloserListener
]

{ #category : #'popup - properties' }
GLMEmptyPopupBrick >> inset [
	^ inset
]

{ #category : #'popup - properties' }
GLMEmptyPopupBrick >> inset: aMargin [

	inset := aMargin asMargin.
	self updateInsetAndSpacing
]

{ #category : #'events-processing' }
GLMEmptyPopupBrick >> isInsideOfContentBrick: anEvent [
	self contentBrick 
		ifNil: [^ false]
		ifNotNil: [:aBrick | 
			anEvent withHandPositionDo: [ :position | ^ aBrick boundsInWorld containsPoint: position ]]
]

{ #category : #'events-processing' }
GLMEmptyPopupBrick >> isInsideOfPopupBrick: anEvent [
	^ (self isInsideOfTriggerBrick: anEvent) | (self isInsideOfContentBrick: anEvent)
]

{ #category : #'events-processing' }
GLMEmptyPopupBrick >> isInsideOfTriggerBrick: anEvent [
	self triggerBrick 
		ifNil: [^ false]
		ifNotNil: [:aBrick | 
			anEvent withHandPositionDo: [ :position | ^ aBrick globalBounds containsPoint: position ] ]
]

{ #category : #'events-processing' }
GLMEmptyPopupBrick >> keyDown: anEvent [

	self closer handleListenEvent: anEvent
]

{ #category : #'events-processing' }
GLMEmptyPopupBrick >> keyStroke: anEvent [

	self closer handleListenEvent: anEvent
]

{ #category : #'events-processing' }
GLMEmptyPopupBrick >> keyboardFocusChange: gotFocus [

	super keyboardFocusChange: gotFocus.
	gotFocus ifFalse: [
		self closer handleLostFocus ]
]

{ #category : #'events-processing' }
GLMEmptyPopupBrick >> mouseLeave: anEvent [

	self closer handleListenEvent: anEvent
]

{ #category : #'instance creation' }
GLMEmptyPopupBrick >> newContentBrick [
	^ GLMBandBrick new
		hShrinkWrap;
		vShrinkWrap;
		yourself
]

{ #category : #'instance creation' }
GLMEmptyPopupBrick >> newTriggerBrick [
	^ GLMActionButtonBrick new
		hShrinkWrap;
		vShrinkWrap;
		yourself
]

{ #category : #'popup - hooks' }
GLMEmptyPopupBrick >> onClosed [
	"I am send after popup is closed and removed from the world.
	Override me to perform additional actions, for example restore keyboard or mouse focus"
]

{ #category : #'popup - hooks' }
GLMEmptyPopupBrick >> onCreated [
	self subclassResponsibility
]

{ #category : #'popup - hooks' }
GLMEmptyPopupBrick >> onOpened [
	"I am send after popup is opened in the world and became visible to the user.
	Override me to perform additional actions, for example give keyboard or mouse focus
	to me or any of my content elements"
	
	self takeKeyboardFocus
]

{ #category : #'popup - hooks' }
GLMEmptyPopupBrick >> onThemerChanged [
	| aThemer |
	super onThemerChanged.
	
	aThemer := self themer popupThemer.

	self color: aThemer backgroundColor.
	self borderWidth: aThemer borderWidth.
	self borderColor: aThemer borderColor.

	self inset: aThemer inset.
	self spacing: aThemer spacing.
	
	self shadowWidth: aThemer shadowWidth.
	self shadowColor: aThemer shadowColor.
	self shadowOffset: aThemer shadowOffset.
	self shadowInset: aThemer shadowInset.

	self contentBrick padding: aThemer contentPadding.
	self contentBrick color: aThemer contentBackgroundColor.
	self updateTriggerBrick
]

{ #category : #'popup - opening dispatch' }
GLMEmptyPopupBrick >> openAbove: aRectangle [
	"aRectangle must be in global coordinates"
	| anOrigin |
	
	anOrigin := aRectangle origin - (0 @ self contentBrick height) - ( 0 @ self inset top).
	^ self openAt: anOrigin
]

{ #category : #'popup - opening' }
GLMEmptyPopupBrick >> openAt: aPoint [
	"Open me in the world at a given position provided in global coordinates.
	Return a morphic foundation brick that is used to wrap a popup"
	<return: #GLMFoundationBrick>
	| aFoundationBrick |

	aFoundationBrick := self asBrickedMorph
		vShrinkWrap;
		hShrinkWrap;
		position: aPoint;
		openInWorld.

	self onOpened.
	
	^ aFoundationBrick
]

{ #category : #'popup - opening dispatch' }
GLMEmptyPopupBrick >> openBelow: aRectangle [
	"aRectangle must be in global coordinates"
	^ self openAt: aRectangle origin
]

{ #category : #'popup - opening' }
GLMEmptyPopupBrick >> openOn: aBrick [
	"Open popup for a given brick playing a role of my anchor"

	self
		assert: [ aBrick isNotNil ]
		description: [ 'Can not open below a nil brick!' ].

	self anchorBrick: aBrick.
	self onCreated.
	self announce: #onCreated event: self.

	^ self popupLayout open: self with: (aBrick boundsInWorld expandBy: self inset)
]

{ #category : #initialization }
GLMEmptyPopupBrick >> outOfWorld: aWorld [
	super outOfWorld: aWorld.
	self unsubscribeListeners: aWorld
]

{ #category : #'popup - layout' }
GLMEmptyPopupBrick >> popupLayout [
	"Return my current popup layout.
	popupLayout can not be nil"
	<return: #GLMPopupBrickLayout>

	self
		assert: [ popupLayout isNotNil ]
		description: [ 'Popup layout can not be nil' ].

	^ popupLayout
]

{ #category : #'popup - layout' }
GLMEmptyPopupBrick >> popupLayout: aPopupLayout [
	"Change my popup layout to a given one rebuilding popup"

	popupLayout := aPopupLayout.

	self popupLayout
		build: self
		trigger: self triggerBrick
		content: self contentBrick
]

{ #category : #'popup - listeners' }
GLMEmptyPopupBrick >> removeCloserListener [

	self
		assert: [ self closer isNotNil ]
		description: [ 'Closer must not be nil' ].
	
	self closer popup: nil
]

{ #category : #'popup - properties' }
GLMEmptyPopupBrick >> spacing [
	^ spacing
]

{ #category : #'popup - properties' }
GLMEmptyPopupBrick >> spacing: aNumber [
	"Set amount of free space between trigger and content bricks"
	
	spacing := aNumber.
	self updateInsetAndSpacing
]

{ #category : #accessing }
GLMEmptyPopupBrick >> triggerBrick [
	"Return an interactable trigger brick.
	triggerBrick can not be nil"
	<return: #GLMInteractableBrick>
	
	self
		assert: [ triggerBrick isNotNil ]
		description: [ 'Trigger brick can not be nil' ].
	
	^ triggerBrick
]

{ #category : #accessing }
GLMEmptyPopupBrick >> triggerBrick: aBrick [
	"Add a given interractable brick as my trigger brick.
	Trigger brick is a visual element that should be located exactly above original
	anchor brick and should have the same (visual) content.
	Note: background of trigger brick may differ from background of anchor brick.
	aBrick must not be nil"
	
	self
		assert: [ aBrick isNotNil ]
		description: [ 'Trigger brick must not be nil' ].

	"If we already have a trigger brick, replace it with new one"
	triggerBrick ifNotNil: [
		self removeBrick: triggerBrick ].

	triggerBrick := aBrick.
	self addBrickBack: self triggerBrick
]

{ #category : #generated }
GLMEmptyPopupBrick >> unsubscribeListeners [

	self deprecated: 'Use #unsubscribeListeners: instead'.
	self removeCloserListener
]

{ #category : #'popup - listeners' }
GLMEmptyPopupBrick >> unsubscribeListeners: anObject [

	self removeCloserListener
]

{ #category : #private }
GLMEmptyPopupBrick >> updateInsetAndSpacing [

	self triggerBrick margin: {
		self inset top.
		self inset right.
		0.
		self inset left }.

	self contentBrick margin: {
		self spacing.
		self inset right.
		self inset bottom.
		self inset left }
]

{ #category : #private }
GLMEmptyPopupBrick >> updateTriggerBrick [
	| aTriggerImage |
	
	aTriggerImage := self anchorBrick brickImageForm: self themer popupThemer backgroundColor.
	self triggerBrick icon: aTriggerImage
]
