"
This morph is used as support for the watcher (quick preview) behavior.

GLMWatcherWindow uniqueInstance openInWorld.
GLMWatcherWindow reset.
"
Class {
	#name : #GLMWatcherWindow,
	#superclass : #SystemWindow,
	#instVars : [
		'isOpen',
		'contentsMorph',
		'process'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'Glamour-Morphic-Widgets'
}

{ #category : #'instance creation' }
GLMWatcherWindow class >> buildKeymapsOn: aBuilder [
	<keymap>
	
	(aBuilder shortcut: #openGlamourWatcher) 
		category: #Glamour
		default: Character space meta shift 
		do: [ :morph | self uniqueInstance toggleOpen ].

	aBuilder attachShortcutCategory: #Glamour to: Morph.
]

{ #category : #initialization }
GLMWatcherWindow class >> reset [ 
	"self reset"
	uniqueInstance := nil
]

{ #category : #'instance creation' }
GLMWatcherWindow class >> uniqueInstance [ 
	^ uniqueInstance ifNil: [uniqueInstance := self new]
]

{ #category : #settings }
GLMWatcherWindow >> activeFillStyle [
	"Return the active fillStyle for the receiver."

	^ self theme watcherWindowActiveFillStyleFor: self
]

{ #category : #settings }
GLMWatcherWindow >> activeTitleFillStyle [
	"Return the active title fillStyle for the receiver."
	
	^ SolidFillStyle color: Color transparent
]

{ #category : #accessing }
GLMWatcherWindow >> addContent: aBlockWhoseValueReturnsAMorph [
	| newMorph |

	"if we are still rendering some contents for another watcher,
	we stop and replace with the current request"
	process ifNotNil: [ process terminate ].
	process := nil.
	
	process := [
		newMorph := aBlockWhoseValueReturnsAMorph value.
		WorldState addDeferredUIMessage:  [
			self contentsMorph
				removeAllMorphs;
				addMorph: newMorph fullFrame: (LayoutFrame identity)	
		]
	] newProcess. 
	process priority: Processor userBackgroundPriority.
	process resume
]

{ #category : #initialize }
GLMWatcherWindow >> addContentsMorph [
	self contentsMorph: GLMMorphic emptyMorph.
	self contentsMorph
		layoutFrame: (LayoutFrame identity 
							leftOffset: 10; 
							topOffset: 10; 
							rightOffset: -10;
							bottomOffset: -10);
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	self addMorphBack: self contentsMorph
]

{ #category : #accessing }
GLMWatcherWindow >> contentsMorph [
	^ contentsMorph
]

{ #category : #accessing }
GLMWatcherWindow >> contentsMorph: anObject [
	contentsMorph := anObject
]

{ #category : #settings }
GLMWatcherWindow >> defaultBorderStyle [
	^ FillBorderStyle color: (Color white darker alpha: 0.5) width: 10
]

{ #category : #initialize }
GLMWatcherWindow >> defaultFillStyle [
	^ SolidFillStyle color: Color transparent
]

{ #category : #'open/close' }
GLMWatcherWindow >> delete [ 
	super delete. 
	isOpen := false
]

{ #category : #initialize }
GLMWatcherWindow >> fastFramingOn [

	^self theme settings fastDragging and: [self isFlexed not]
]

{ #category : #settings }
GLMWatcherWindow >> inactiveFillStyle [
	"Return the active title fillStyle for the receiver."
	
	^ self theme watcherWindowInactiveFillStyleFor: self
]

{ #category : #settings }
GLMWatcherWindow >> inactiveTitleFillStyle [
	"Return the active title fillStyle for the receiver."
	
	^ SolidFillStyle color: Color transparent
]

{ #category : #initialization }
GLMWatcherWindow >> initialize [
	super initialize.
	self fillStyle: self defaultFillStyle.
	"	self borderStyle: self defaultBorderStyle."
	isOpen := false.
	self setLabel: 'Glamorous Watcher'.
	self addCornerGrips.
	self addEdgeGrips.
	self addContentsMorph.
	self
		on: Character escape
		do: [ self hide ]
]

{ #category : #accessing }
GLMWatcherWindow >> morphicLayerNumber [
	"We want this preview to be always on top"
	
	^ 10
]

{ #category : #display }
GLMWatcherWindow >> postOpenInWorld: aWorld [
	isOpen := true.

]

{ #category : #initialize }
GLMWatcherWindow >> replaceBoxes [
	"Rebuild the various boxes."
	
	labelArea removeAllMorphs.
	self setLabelWidgetAllowance.
	self theme configureWatcherWindowLabelAreaFor: self.
	self setFramesForLabelArea.
	self isActive ifFalse: [labelArea passivate]
]

{ #category : #settings }
GLMWatcherWindow >> taskbarTask [
	"Answer a new taskbar task for the receiver.
	Answer nil if not required."

	^nil
]

{ #category : #'open/close' }
GLMWatcherWindow >> toggleOpen [ 
	isOpen ifFalse: [ ^ self openInWorld ].
	self visible 
		ifTrue: [self hide] 
		ifFalse: [self show]
]

{ #category : #settings }
GLMWatcherWindow >> wantsExpandBox [
	"Answer whether I'd like an expand box"

	^ false
]
