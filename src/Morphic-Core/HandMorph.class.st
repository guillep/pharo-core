"
The cursor may be thought of as the HandMorph.  The hand's submorphs hold anything being carried by dragging.  

There is some minimal support for multiple hands in the same world.
"
Class {
	#name : #HandMorph,
	#superclass : #Morph,
	#instVars : [
		'mouseFocus',
		'keyboardFocus',
		'eventListeners',
		'mouseListeners',
		'mouseClickState',
		'mouseOverHandler',
		'lastMouseEvent',
		'targetOffset',
		'damageRecorder',
		'cacheCanvas',
		'cachedCanvasHasHoles',
		'temporaryCursor',
		'temporaryCursorOffset',
		'hardwareCursor',
		'hasChanged',
		'savedPatch',
		'lastEventBuffer',
		'lastKeyScanCode',
		'captureBlock',
		'recentModifiers',
		'pendingEventQueue',
		'supressNextKeyPress'
	],
	#classVars : [
		'DoubleClickTime',
		'EventStats',
		'NormalCursor',
		'PasteBuffer',
		'ShowEvents',
		'UpperHandLimit'
	],
	#pools : [
		'EventSensorConstants'
	],
	#category : #'Morphic-Core-Kernel'
}

{ #category : #cleanup }
HandMorph class >> cleanUp [
	"Called from ImageCleaner>>cleanUpForRelease --> SmalltalkImage>>cleanUp:except:confirming:"
	self logEventStatsStop.


]

{ #category : #accessing }
HandMorph class >> doubleClickTime [

	^ DoubleClickTime

]

{ #category : #accessing }
HandMorph class >> doubleClickTime: milliseconds [

	DoubleClickTime := milliseconds.

]

{ #category : #'events-processing' }
HandMorph class >> eventStats [
	^ EventStats ifNil: [ 'EventStats are disabled' ].
]

{ #category : #'class initialization' }
HandMorph class >> initialize [
	"HandMorph initialize"

	PasteBuffer := nil.
	DoubleClickTime := 350.
	NormalCursor := CursorWithMask normal asCursorForm.

]

{ #category : #'events-processing' }
HandMorph class >> logEventStats: evt [
	EventStats ifNotNil: [
		EventStats at: #count put: (EventStats at: #count ifAbsent:[0]) + 1.
		EventStats at: evt type put: (EventStats at: evt type ifAbsent:[0]) + 1.
		].
]

{ #category : #settings }
HandMorph class >> logEventStatsEnabled [
	"self logEventStatsEnabled"
	^ EventStats isNotNil 
]

{ #category : #settings }
HandMorph class >> logEventStatsEnabled: aBoolean [
	aBoolean
		ifTrue: [ self logEventStatsStart ]
		ifFalse: [ self logEventStatsStop ].
]

{ #category : #'events-processing' }
HandMorph class >> logEventStatsStart [
	EventStats ifNil:[EventStats := IdentityDictionary new].
]

{ #category : #'events-processing' }
HandMorph class >> logEventStatsStop [
	EventStats := nil.
]

{ #category : #settings }
HandMorph class >> settingsOn: aBuilder [
	<systemsettings>
	(aBuilder setting: #handMorphsLogEventStats)
		parent: #pharoSystem;
		label: 'HandMorph event statistics';
		target: self;
		default: false;
		selector: #logEventStatsEnabled;
		description: 'Enable/disable gathering global statistics of events handled by HandMorphs.
"HandMorph eventStats inspect"'

]

{ #category : #utilities }
HandMorph class >> showEvents: aBool [
	"HandMorph showEvents: true"
	"HandMorph showEvents: false"
	ShowEvents := aBool.
	aBool ifFalse: [ self currentWorld invalidRect: (0@0 extent: 500@120) ].
]

{ #category : #accessing }
HandMorph class >> upperHandLimit [

	^ UpperHandLimit ifNil: [ UpperHandLimit := 0 ]
]

{ #category : #accessing }
HandMorph class >> upperHandLimit: anInteger [

	UpperHandLimit := anInteger
]

{ #category : #listeners }
HandMorph >> addEventListener: anObject [
	"Make anObject a listener for all events. All events will be reported to the object."
	self eventListeners: (self addListener: anObject to: self eventListeners)
]

{ #category : #listeners }
HandMorph >> addListener: anObject to: aListenerGroup [
	"Add anObject to the given listener group. Return the new group."
	| listeners |
	listeners := aListenerGroup.
	(listeners notNil and:[listeners includes: anObject]) ifFalse:[
		listeners
			ifNil:[listeners := WeakArray with: anObject]
			ifNotNil:[listeners := listeners copyWith: anObject]].
	listeners := listeners copyWithout: nil. "obsolete entries"
	^listeners
]

{ #category : #listeners }
HandMorph >> addMouseListener: anObject [
	"Make anObject a listener for mouse events. All mouse events will be reported to the object."
	self mouseListeners: (self addListener: anObject to: self mouseListeners)
]

{ #category : #accessing }
HandMorph >> anyButtonPressed [
	^lastMouseEvent anyButtonPressed
]

{ #category : #accessing }
HandMorph >> anyModifierKeyPressed [
	^recentModifiers anyMask: 16r0E	"cmd | opt | ctrl"
]

{ #category : #'grabbing/dropping' }
HandMorph >> attachMorph: m [
	"Position the center of the given morph under this hand, then grab it.
	This method is used to grab far away or newly created morphs."
	| delta |
	self releaseMouseFocus. "Break focus"
	delta := m bounds extent // 2.
	m position: (self position - delta).
	m formerPosition: m position.
	targetOffset := m position - self position.
	self addMorphBack: m.
]

{ #category : #'balloon help' }
HandMorph >> balloonHelp [
	"Return the balloon morph associated with this hand"
	^self valueOfProperty: #balloonHelpMorph
]

{ #category : #'balloon help' }
HandMorph >> balloonHelp: aBalloonMorph [
	"Return the balloon morph associated with this hand"
	self balloonHelp ifNotNil:[:oldHelp |oldHelp delete].
	aBalloonMorph
		ifNil:[self removeProperty: #balloonHelpMorph]
		ifNotNil:[self setProperty: #balloonHelpMorph toValue: aBalloonMorph]
]

{ #category : #'events-processing' }
HandMorph >> captureEventsUntil: aBlock [
"
	Capture all input events, bypassing normal processing flow and redirect all events into block instead.
	Repeat until block will answer true.

	World activeHand captureEventsUntil: [:evt |
		evt isKeyboard and: [ evt keyCharacter = $a ] ]
"

	| release |
	
	release := false.
	
	captureBlock := [:evt | release := aBlock value: evt ].
	
	[
		MorphicRenderLoop new doOneCycleWhile: [ release not ].
	] ensure: [
		captureBlock := nil.
	]
]

{ #category : #'events-processing' }
HandMorph >> captureEventsWhile: aBlock [
"
	Capture all input events, bypassing normal processing flow and redirect all events into block instead.
	Repeat until block will answer false.

"

	^ self captureEventsUntil: [:evt | (aBlock value: evt) not ]
]

{ #category : #updating }
HandMorph >> changed [

	hasChanged := true.

]

{ #category : #accessing }
HandMorph >> colorForInsets [
	"Morphs being dragged by the hand use the world's color"
	^ owner colorForInsets
]

{ #category : #'meta-actions' }
HandMorph >> copyToPasteBuffer: aMorph [
	"Save this morph in the paste buffer. This is mostly useful for copying morphs between projects."
	aMorph ifNil:[^PasteBuffer := nil].
	Cursor wait showWhile:[
		PasteBuffer := aMorph topRendererOrSelf veryDeepCopy.
		PasteBuffer privateOwner: nil].


]

{ #category : #cursor }
HandMorph >> currentCursor [

	^ self world currentCursor
]

{ #category : #cursor }
HandMorph >> currentCursor: aCursor [

	self world currentCursor: aCursor.
	self world isCursorOwner ifTrue: [
		aCursor activateInCursorOwner: self world ]
]

{ #category : #accessing }
HandMorph >> cursorBounds [
	^ temporaryCursor
		ifNil: [ self position extent: NormalCursor extent ]
		ifNotNil: [ self position + temporaryCursorOffset extent: temporaryCursor extent ]
]

{ #category : #'event handling' }
HandMorph >> cursorPoint [

	^ self position
]

{ #category : #'balloon help' }
HandMorph >> deleteBalloonTarget: aMorph [
	"Delete any existing balloon help.  This is now done unconditionally, whether or not the morph supplied is the same as the current balloon target"
	
	self balloonHelp: nil

"	| h |
	h := self balloonHelp ifNil: [^ self].
	h balloonOwner == aMorph ifTrue: [self balloonHelp: nil]"
]

{ #category : #drawing }
HandMorph >> drawOn: aCanvas [ 
	"Draw the hand itself (i.e., the cursor)."

	temporaryCursor 
		ifNil: [aCanvas paintImage: NormalCursor at: bounds topLeft]
		ifNotNil: [aCanvas paintImage: temporaryCursor at: bounds topLeft].
	
]

{ #category : #'grabbing/dropping' }
HandMorph >> dropMorph: aMorph event: anEvent [
	"Drop the given morph which was carried by the hand"
	| event dropped |
	(anEvent isMouseUp and:[aMorph shouldDropOnMouseUp not]) ifTrue:[^self].

	"Note: For robustness in drag and drop handling we remove the morph BEFORE we drop him, but we keep his owner set to the hand. This prevents system lockups when there is a problem in drop handling (for example if there's an error in #wantsToBeDroppedInto:). THIS TECHNIQUE IS NOT RECOMMENDED FOR CASUAL USE."
	self privateRemove: aMorph.
	aMorph privateOwner: self.

	dropped := aMorph.
	(dropped hasProperty: #addedFlexAtGrab) 
		ifTrue:[dropped := aMorph removeFlexShell].
	event := DropEvent new setPosition: self position contents: dropped hand: self.
	self sendEvent: event focus: nil.
	event wasHandled ifFalse:[aMorph rejectDropMorphEvent: event].
	aMorph owner == self ifTrue:[aMorph delete].
	self mouseOverHandler processMouseOver: anEvent.
]

{ #category : #'grabbing/dropping' }
HandMorph >> dropMorphs [
	"Drop the morphs at the hands position"
	self dropMorphs: lastMouseEvent.
]

{ #category : #'grabbing/dropping' }
HandMorph >> dropMorphs: anEvent [
	"Drop the morphs at the hands position"
	self submorphsReverseDo:[:m|
		"Drop back to front to maintain z-order"
		self dropMorph: m event: anEvent.
	].
]

{ #category : #listeners }
HandMorph >> eventListeners [
	^eventListeners
]

{ #category : #listeners }
HandMorph >> eventListeners: anArrayOrNil [
	eventListeners := anArrayOrNil
]

{ #category : #'private events' }
HandMorph >> eventQueue [
	^ Sensor
]

{ #category : #layout }
HandMorph >> fullBounds [
	"Extend my bounds by the shadow offset when carrying morphs."

	| bnds |
	bnds := super fullBounds.
	^ submorphs
		ifEmpty: [ bnds ]
		ifNotEmpty: [ bnds topLeft corner: bnds bottomRight + self shadowOffset ]
]

{ #category : #drawing }
HandMorph >> fullDrawOn: aCanvas [ 
	"A HandMorph has unusual drawing requirements:
		1. the hand itself (i.e., the cursor) appears in front of its submorphs
		2. morphs being held by the hand cast a shadow on the world/morphs below
	The illusion is that the hand plucks up morphs and carries them above the world."

	"Note: This version caches an image of the morphs being held by the hand for
	 better performance. This cache is invalidated if one of those morphs changes."

	| disableCaching subBnds roundCorners rounded |
	self visible ifFalse: [^self].
	(aCanvas isVisible: self fullBounds) ifFalse: [^self].
	disableCaching := false.
	disableCaching 
		ifTrue: 
			[self nonCachingFullDrawOn: aCanvas.
			^self].
	submorphs isEmpty 
		ifTrue: 
			[cacheCanvas := nil.
			^self drawOn: aCanvas].	"just draw the hand itself"
	subBnds := Rectangle merging: (submorphs collect: [:m | m fullBounds]).
	self updateCacheCanvas: aCanvas.
	(cacheCanvas isNil 
		or: [cachedCanvasHasHoles and: [cacheCanvas depth = 1]]
	)ifTrue: ["could not use caching due to translucency; do full draw"
		self nonCachingFullDrawOn: aCanvas.
		^self
	].

	"--> begin rounded corners hack <---"
	roundCorners := cachedCanvasHasHoles == false 
				and: [submorphs size = 1 and: [submorphs first wantsRoundedCorners]].
	roundCorners 
		ifTrue: 
			[rounded := submorphs first.
			aCanvas asShadowDrawingCanvas translateBy: self shadowOffset
				during: 
					[:shadowCanvas | 
					shadowCanvas roundCornersOf: rounded
						during: 
							[(subBnds areasOutside: (rounded boundsWithinCorners 
										translateBy: self shadowOffset negated)) 
								do: [:r | shadowCanvas fillRectangle: r color: Color black]]].
			aCanvas roundCornersOf: rounded
				during: 
					[aCanvas 
						drawImage: cacheCanvas form
						at: subBnds origin
						sourceRect: cacheCanvas form boundingBox].
			^self drawOn: aCanvas	"draw the hand itself in front of morphs"].
	"--> end rounded corners hack <---"

	"draw the shadow"
	(submorphs anySatisfy: [:m | m handlesDropShadowInHand not]) ifTrue: [
		aCanvas asShadowDrawingCanvas translateBy: self shadowOffset
		during: 
			[:shadowCanvas | 
			cachedCanvasHasHoles 
				ifTrue: 
					["Have to draw the real shadow of the form"

					shadowCanvas paintImage: cacheCanvas form at: subBnds origin]
				ifFalse: 
					["Much faster if only have to shade the edge of a solid rectangle"

					(subBnds areasOutside: (subBnds translateBy: self shadowOffset negated)) 
						do: [:r | shadowCanvas fillRectangle: r color: Color black]]]].

	"draw morphs in front of the shadow using the cached Form"
	cachedCanvasHasHoles 
		ifTrue: [aCanvas paintImage: cacheCanvas form at: subBnds origin]
		ifFalse: 	[
			aCanvas 
			drawImage: cacheCanvas form
			at: subBnds origin
			sourceRect: cacheCanvas form boundingBox
		].
	self drawOn: aCanvas	"draw the hand itself in front of morphs"
]

{ #category : #'private events' }
HandMorph >> generateKeyboardEvent: evtBuf [
	"Generate the appropriate mouse event for the given raw event buffer"

	| buttons modifiers type pressType stamp charCode keyValue keyEvent |
	stamp := evtBuf second.
	stamp = 0 ifTrue: [stamp := Time millisecondClockValue].
	pressType := evtBuf fourth.
	pressType = EventKeyDown
		ifTrue: [
			type := #keyDown.
			lastKeyScanCode := evtBuf third].
	pressType = EventKeyUp ifTrue: [type := #keyUp].
	pressType = EventKeyChar ifTrue: [
		type := #keystroke].
	modifiers := evtBuf fifth.
	buttons := modifiers bitShift: 3.
	keyValue := evtBuf third. 
	charCode := evtBuf sixth.

	"This piece of code handles the creation of scrolling events. When a scroll is done by the user, the VM forwards a keystroke event with the up/down key. So we reconvert it to a MouseWheelEvent in that case."
	(type = #keystroke 
	 and: [(buttons anyMask: 16) 
	  and: [{Character arrowUp. Character arrowDown} includes: (charCode asCharacter)]])
		ifTrue: [^ MouseWheelEvent
					fromCharacter: charCode asCharacter
					position: lastMouseEvent cursorPoint
					buttons: buttons
					hand: self
					stamp: stamp].

	"All control keys (tab, cr...) should be managed as keydown and ignored as text"	
	(type = #keystroke and: [
		charCode <= 31 or: [ (127 to: 159) includes: charCode ]])
		ifTrue: [ ^ #invalid ].

   "If charCode is not single-byte, we definately have Unicode input. Zero keyValue to avoid garbage values from som VMs."
   self flag: #pharoFixMe. "I need to look at the windows vm side, to see why this keyvalue is generated in the first place".

   (charCode notNil and:[charCode > 255]) ifTrue: [keyValue:=0].
	keyEvent := KeyboardEvent new
		setType: type
		buttons: buttons
		position: self position
		keyValue: keyValue
		charCode: (type == #keystroke 
			ifTrue: [ charCode ]
			ifFalse: [ self mapSymbolToKeyValue: keyValue ])
		hand: self
		stamp: stamp.
	
	"If a modifier key is pressed the keystroke event is handled by #visitMouseDownEvent:"
	(type == #keystroke
		and: [ keyEvent commandKeyPressed
			or: [ keyEvent controlKeyPressed ] ])
				ifTrue: [ ^ #invalid ].
	
	keyEvent scanCode: lastKeyScanCode.
	^keyEvent

]

{ #category : #'private events' }
HandMorph >> generateMouseEvent: evtBuf [ 
	"Generate the appropriate mouse event for the given raw event buffer"

	| position buttons modifiers type trail stamp oldButtons evtChanged |
	self class environment at: #KMBuffer ifPresent: [ :kmBuffer | kmBuffer uniqueInstance clearBuffer].
	evtBuf first = lastEventBuffer first 
		ifTrue: 
			["Workaround for Mac VM bug, *always* generating 3 events on clicks"

			evtChanged := false.
			3 to: evtBuf size
				do: [:i | (lastEventBuffer at: i) = (evtBuf at: i) ifFalse: [evtChanged := true]].
			evtChanged ifFalse: [^nil]].
	stamp := evtBuf second.
	stamp = 0 ifTrue: [stamp := Time millisecondClockValue].
	position := evtBuf third @ evtBuf fourth.
	buttons := evtBuf fifth.
	modifiers := evtBuf sixth.
	type := buttons = 0 
		ifTrue: 
			[lastEventBuffer fifth = 0 ifTrue: [#mouseMove] ifFalse: [#mouseUp]]
		ifFalse: 
			[lastEventBuffer fifth = 0 
						ifTrue: [#mouseDown]
						ifFalse: [#mouseMove]].
	buttons := buttons bitOr: (modifiers bitShift: 3).
	oldButtons := lastEventBuffer fifth 
				bitOr: (lastEventBuffer sixth bitShift: 3).
	lastEventBuffer := evtBuf.
	type == #mouseMove 
		ifTrue: 
			[trail := self mouseTrailFrom: evtBuf.
			^MouseMoveEvent basicNew 
				setType: type
				startPoint: (self position)
				endPoint: trail last
				trail: trail
				buttons: buttons
				hand: self
				stamp: stamp].
	^MouseButtonEvent basicNew 
		setType: type
		position: position
		which: (oldButtons bitXor: buttons)
		buttons: buttons
		hand: self
		stamp: stamp
]

{ #category : #'private events' }
HandMorph >> generateWindowEvent: evtBuf [ 
	"Generate the appropriate window event for the given raw event buffer"

	| evt |
	evt := WindowEvent new.
	evt setTimeStamp: evtBuf second.
	evt timeStamp = 0 ifTrue: [evt setTimeStamp: Time millisecondClockValue].
	evt action: evtBuf third.
	evt rectangle: (Rectangle origin: evtBuf fourth @ evtBuf fifth corner: evtBuf sixth @ evtBuf seventh ).
	
	^evt

]

{ #category : #'meta-actions' }
HandMorph >> grabMorph: aMorph [
	"Grab the given morph (i.e., add it to this hand and remove it from its current owner) without changing its position. This is used to pick up a morph under the hand's current position, versus attachMorph: which is used to pick up a morph that may not be near this hand."
	
	| grabbed |
	aMorph = self world ifTrue: [^ self].
	self releaseMouseFocus.
	grabbed := aMorph aboutToBeGrabbedBy: self.
	grabbed ifNil: [^self].
	grabbed := grabbed topRendererOrSelf.
	^self grabMorph: grabbed from: grabbed owner
]

{ #category : #'grabbing/dropping' }
HandMorph >> grabMorph: aMorph from: formerOwner [ 
	"Grab the given morph (i.e., add it to this hand and remove it from its
	current owner) without changing its position. This is used to pick up a
	morph under the hand's current position, versus attachMorph: which
	is used to pick up a morph that may not be near this hand."
	| grabbed offset targetPoint grabTransform fullTransform |
	self releaseMouseFocus.
	"Break focus"
	grabbed := aMorph.
	aMorph keepsTransform
		ifTrue: [grabTransform := fullTransform := IdentityTransform new]
		ifFalse: ["Compute the transform to apply to the grabbed morph"
			grabTransform := formerOwner
						ifNil: [IdentityTransform new]
						ifNotNil: [formerOwner grabTransform].
			fullTransform := formerOwner
						ifNil: [IdentityTransform new]
						ifNotNil: [formerOwner transformFrom: owner]].
	"targetPoint is point in aMorphs reference frame"
	targetPoint := fullTransform globalPointToLocal: self position.
	"but current position will be determined by grabTransform, so
	compute offset"
	offset := targetPoint
				- (grabTransform globalPointToLocal: self position).
	"apply the transform that should be used after grabbing"
	grabbed := grabbed transformedBy: grabTransform.
	grabbed == aMorph
		ifFalse: [grabbed setProperty: #addedFlexAtGrab toValue: true].
	"offset target to compensate for differences in transforms"
	grabbed position: grabbed position - offset asIntegerPoint.
	"And compute distance from hand's position" 
	targetOffset := grabbed position - self position.
	self addMorphBack: grabbed.
	grabbed justGrabbedFrom: formerOwner
]

{ #category : #'halos and balloon help' }
HandMorph >> halo [
	"Return the halo associated with this hand, if any"
	^self valueOfProperty: #halo
]

{ #category : #'halo handling' }
HandMorph >> halo: newHalo [
	"Set halo associated with this hand"
	| oldHalo |
	oldHalo := self halo.
	(oldHalo isNil or:[oldHalo == newHalo]) ifFalse:[oldHalo delete].
	newHalo
		ifNil:[self removeProperty: #halo]
		ifNotNil:[self setProperty: #halo toValue: newHalo]
]

{ #category : #'events-processing' }
HandMorph >> handleEvent: anEvent [
	| evt  |
	owner ifNil:[^self].
	evt := anEvent.
	
	"nil test here is for efficiency in the normal case"
	EventStats ifNotNil: [ self class logEventStats: evt ]. 
	
	evt isMouse ifTrue:[
		 "just for record, to be used by capture block" 
		lastMouseEvent := evt].

	captureBlock ifNotNil: [ ^ captureBlock value: anEvent ].
	evt isMouseOver ifTrue:[^self sendMouseEvent: evt].
	
	self showDebugEvent: evt.
	
	"Notify listeners"
	self sendListenEvent: evt to: self eventListeners.

	evt isWindowEvent ifTrue: [
		^ self sendEvent: evt focus: nil ].
	

	evt isKeyboard ifTrue:[
		
		(evt isKeystroke and: [supressNextKeyPress == true])
			ifTrue: [
				supressNextKeyPress := false.
				^ self ].
		
			self sendListenEvent: evt to: self keyboardListeners.
			self sendKeyboardEvent: evt.
			supressNextKeyPress := evt isKeyDown and: [evt supressNextKeyPress].
		^ self ].

	evt isDropEvent ifTrue:[
		^ self sendEvent: evt focus: nil ].

	evt isMouse ifTrue:[
		self sendListenEvent: evt to: self mouseListeners.
		lastMouseEvent := evt].

	"Check for pending drag or double click operations."
	mouseClickState ifNotNil:[
		(mouseClickState handleEvent: evt from: self) ifFalse:[
			"Possibly dispatched #click: or something and will not re-establish otherwise"
			^self ]].

	evt isMove ifTrue:[
		| pos |
		pos := evt position.
		evt isDraggingEvent ifTrue: [ 
			| treshold |
			treshold := 0.
			(self submorphs at: 1 ifAbsent: [ nil ])
				ifNotNil: [ :first | treshold := self top-first top ].
			pos y < (self class upperHandLimit+treshold) ifTrue: [ pos := pos x @ (self class upperHandLimit + treshold)] ].
		
		self position: pos.
		self sendMouseEvent: evt.
	] ifFalse:[
		"Issue a synthetic move event if we're not at the position of the event"
		(evt position = self position) ifFalse:[self moveToEvent: evt].
		"Drop submorphs on button events"
		(self hasSubmorphs) 
			ifTrue:[self dropMorphs: evt]
			ifFalse:[self sendMouseEvent: evt].
	].
	self showMouseFocusEvent: evt.
	self mouseOverHandler processMouseOver: lastMouseEvent.

]

{ #category : #drawing }
HandMorph >> hasChanged [
	"Return true if this hand has changed, either because it has moved or because some morph it is holding has changed."

	^ hasChanged ifNil: [ true ]

]

{ #category : #initialization }
HandMorph >> initForEvents [
	mouseOverHandler := nil.
	lastMouseEvent := MouseEvent basicNew setType: #mouseMove position: 0@0 buttons: 0 hand: self.
	lastEventBuffer := {1. 0. 0. 0. 0. 0. nil. nil}.
	recentModifiers := 0.
	self resetClickState.
]

{ #category : #initialization }
HandMorph >> initialize [
	super initialize.
	self initForEvents.
	bounds := 0 @ 0 extent: Cursor normal extent.
	damageRecorder := DamageRecorder new.
	cachedCanvasHasHoles := false.
	supressNextKeyPress := false.
	self initForEvents
]

{ #category : #initialization }
HandMorph >> interrupted [
	"Something went wrong - we're about to bring up a debugger. 
	Release some stuff that could be problematic."
	self releaseAllFocus. "or else debugger might not handle clicks"

]

{ #category : #'change reporting' }
HandMorph >> invalidRect: damageRect from: aMorph [
	"Note that a change has occurred and record the given damage rectangle relative to the origin this hand's cache."
	hasChanged := true.
	aMorph == self ifTrue:[^self].
	damageRecorder recordInvalidRect: damageRect.

]

{ #category : #classification }
HandMorph >> isHandMorph [

	^ true
]

{ #category : #'focus handling' }
HandMorph >> keyboardFocus [ 
	^ keyboardFocus
]

{ #category : #'focus handling' }
HandMorph >> keyboardFocus: aMorphOrNil [
	self newKeyboardFocus: aMorphOrNil
]

{ #category : #listeners }
HandMorph >> keyboardListeners [
	^nil
]

{ #category : #accessing }
HandMorph >> lastEvent [
	^ lastMouseEvent
]

{ #category : #'private events' }
HandMorph >> mapSymbolToKeyValue: keyValue [

	"Backwards compatibility.
	Transform a VM keycode to a corresponding ascii value"

	^ { KeyboardKey down -> 31.
		KeyboardKey keypadDown -> 31.
		KeyboardKey left -> 28.
		KeyboardKey keypadLeft -> 28.
		KeyboardKey right -> 29.
		KeyboardKey keypadRight -> 29.
		KeyboardKey up -> 30.
		KeyboardKey keypadUp -> 30.
		KeyboardKey enter -> 13.
		KeyboardKey keypadEnter -> 13.
		KeyboardKey tab -> 9.
		KeyboardKey backspace -> 8.
		} asDictionary
		at: (Smalltalk os keyForValue: keyValue)
		ifAbsent: [ 0 ]
]

{ #category : #'focus handling' }
HandMorph >> mouseFocus [
	^mouseFocus
]

{ #category : #'focus handling' }
HandMorph >> mouseFocus: aMorphOrNil [
	mouseFocus := aMorphOrNil
]

{ #category : #listeners }
HandMorph >> mouseListeners [
	^mouseListeners
]

{ #category : #listeners }
HandMorph >> mouseListeners: anArrayOrNil [
	mouseListeners := anArrayOrNil
]

{ #category : #accessing }
HandMorph >> mouseOverHandler [
	^mouseOverHandler ifNil:[mouseOverHandler := MouseOverHandler new].
]

{ #category : #'private events' }
HandMorph >> mouseTrailFrom: currentBuf [ 
  "Current event, a mouse event buffer, is about to be processed.  If there are other similar mouse events queued up, then drop them from the queue, and report the positions inbetween."

  | nextEvent trail |
  trail := (Array new: 1) writeStream.
  trail nextPut: currentBuf third @ currentBuf fourth.
  [(nextEvent := Sensor peekEvent) isNil] whileFalse: 
      [nextEvent first = currentBuf first 
        ifFalse: [^trail contents "different event type"].
      nextEvent fifth = currentBuf fifth 
        ifFalse: [^trail contents "buttons changed"].
      nextEvent sixth = currentBuf sixth 
        ifFalse: [^trail contents "modifiers changed"].
      "nextEvent is similar.  Remove it from the queue, and check the next."
      nextEvent := Sensor nextEvent.
      nextEvent 
        ifNotNil: [ trail nextPut: nextEvent third @ nextEvent fourth ]].
  ^trail contents
]

{ #category : #'private events' }
HandMorph >> moveToEvent: anEvent [
	"Issue a mouse move event to make the receiver appear at the given position"
	self handleEvent: (MouseMoveEvent basicNew
		setType: #mouseMove 
		startPoint: self position 
		endPoint: anEvent position 
		trail: (Array with: self position with: anEvent position)
		buttons: anEvent buttons
		hand: self
		stamp: anEvent timeStamp)
]

{ #category : #drawing }
HandMorph >> needsToBeDrawn [
	"Return true if this hand must be drawn explicitly instead of being drawn via the hardware cursor. This is the case if it (a) it is a remote hand, (b) it is showing a temporary cursor, or (c) it is not empty and there are any visible submorphs. If using the software cursor, ensure that the hardware cursor is hidden."
	"Details:  Return true if this hand has a saved patch to ensure that is is processed by the world. This saved patch will be deleted after one final display pass when it becomes possible to start using the hardware cursor again. This trick gives us one last display cycle to allow us to remove the software cursor and shadow from the display."
	| cursor |
	(savedPatch notNil
		or: [ (submorphs anySatisfy: [ :ea | ea visible ])
			or: [ (temporaryCursor notNil and: [hardwareCursor isNil])
				]])
		ifTrue: [
			"using the software cursor; hide the hardware one"
			self currentCursor == Cursor blank ifFalse: [Cursor blank show].
			^ true].
	"Switch from one hardware cursor to another, if needed."
	cursor := hardwareCursor ifNil: [Cursor normal].
	self currentCursor == cursor ifFalse: [cursor show].
	^ false

]

{ #category : #'focus handling' }
HandMorph >> newKeyboardFocus: aMorphOrNil [
	"Make the given morph the new keyboard focus, canceling the previous keyboard focus if any. If the argument is nil, the current keyboard focus is cancelled."
	| oldFocus |
	keyboardFocus == aMorphOrNil ifTrue: [ ^self ].
	oldFocus := keyboardFocus.
	keyboardFocus := aMorphOrNil.
	
	oldFocus ifNotNil: [oldFocus keyboardFocusChange: false].
	aMorphOrNil ifNotNil: [ aMorphOrNil keyboardFocusChange: true ].

]

{ #category : #'focus handling' }
HandMorph >> newMouseFocus: aMorphOrNil [
	"Make the given morph the new mouse focus, canceling the previous mouse focus if any. If the argument is nil, the current mouse focus is cancelled."
	self mouseFocus: aMorphOrNil.

]

{ #category : #'focus handling' }
HandMorph >> newMouseFocus: aMorph event: event [ 
	aMorph ifNotNil: [targetOffset := event cursorPoint - aMorph position].
	^self newMouseFocus: aMorph
]

{ #category : #'private events' }
HandMorph >> nextEventFrom: anEventBufferQueue [
	"Returns the next morphic event to handle.
	Three cases may arise:
	 - If possible, a valid morphic event is returned
	 - If no more events are available, nil is returned
	 - If we find an invalid event in the queue, we consume it and return the #invalid symbol
	
	The first morphic events available are those in the pending queue.
	An event handling cycle should generate and manage a single event.
	In the case a cycle needs to generate several events (see MouseClickState), only one event is handled.
	Remaining events are queued for later processing.
	"
	| eventBuffer morphicEvent type pendingMorphicEvent |
	
	pendingMorphicEvent := self pendingEventQueue nextOrNil.
	pendingMorphicEvent ifNotNil: [ ^ pendingMorphicEvent ].
	
	anEventBufferQueue ifNil: [ ^ nil ].
	eventBuffer := anEventBufferQueue nextEvent.
	eventBuffer ifNil: [ ^ nil ].
	
	morphicEvent := nil.	"for unknown event types"
	type := eventBuffer first.
	type = EventTypeMouse ifTrue: [ self world beCursorOwner.
		recentModifiers := eventBuffer sixth.
		morphicEvent := self generateMouseEvent: eventBuffer
	].
	type = EventTypeKeyboard ifTrue: [
		recentModifiers := eventBuffer fifth.
		morphicEvent := self generateKeyboardEvent: eventBuffer
	].
	type = EventTypeDragDropFiles ifTrue: [ 
		morphicEvent := self generateDropFilesEvent: eventBuffer ].
	type = EventTypeWindow ifTrue: [ 
		morphicEvent := self generateWindowEvent: eventBuffer ].
	
	"If the event did not match any of the categories above, it is an invalid event"
	( type ~= EventTypeDragDropFiles and: [ morphicEvent isNil ] )
		ifTrue: [ ^ #invalid ].
	^ morphicEvent
]

{ #category : #accessing }
HandMorph >> noButtonPressed [
	"Answer whether any mouse button is not being pressed."

	^self anyButtonPressed not
]

{ #category : #drawing }
HandMorph >> nonCachingFullDrawOn: aCanvas [
	
	"A HandMorph has unusual drawing requirements:
		1. the hand itself (i.e., the cursor) appears in front of its submorphs
		2. morphs being held by the hand cast a shadow on the world/morphs below
	The illusion is that the hand plucks up morphs and carries them above the world."
	"Note: This version does not cache an image of the morphs being held by the hand.
	 Thus, it is slower for complex morphs, but consumes less space."

	submorphs isEmpty ifTrue: [^ self drawOn: aCanvas].  "just draw the hand itself"
	aCanvas asShadowDrawingCanvas
		translateBy: self shadowOffset during:[:shadowCanvas| | shadowForm |
		"Note: We use a shadow form here to prevent drawing
		overlapping morphs multiple times using the transparent
		shadow color."
		shadowForm := self shadowForm.
"
shadowForm displayAt: shadowForm offset negated. Display forceToScreen: (0@0 extent: shadowForm extent).
"
		shadowCanvas paintImage: shadowForm at: shadowForm offset.  "draw shadows"
	].
	"draw morphs in front of shadows"
	self drawSubmorphsOn: aCanvas.
	self drawOn: aCanvas.  "draw the hand itself in front of morphs"

]

{ #category : #'event handling' }
HandMorph >> noticeMouseOver: aMorph event: anEvent [
	mouseOverHandler ifNil:[^self].
	mouseOverHandler noticeMouseOver: aMorph event: anEvent.
]

{ #category : #'paste buffer' }
HandMorph >> objectToPaste [
	"It may need to be sent #startRunning by the client"
	^ Cursor wait showWhile: [PasteBuffer veryDeepCopy]

	"PasteBuffer usableDuplicateIn: self world"

]

{ #category : #'halo handling' }
HandMorph >> obtainHalo: aHalo [
	"Used for transfering halos between hands"

	self halo == aHalo
		ifTrue: [ ^ self ].	
	"Find former owner"
	self world hands detect: [ :hand | hand halo == aHalo ] ifFound: [ :formerOwner | formerOwner releaseHalo: aHalo ].
	self halo: aHalo
]

{ #category : #'paste buffer' }
HandMorph >> pasteBuffer [
	"Return the paste buffer associated with this hand"
	^ PasteBuffer
]

{ #category : #'paste buffer' }
HandMorph >> pasteBuffer: aMorphOrNil [
	"Set the contents of the paste buffer."
	PasteBuffer := aMorphOrNil.


]

{ #category : #'private events' }
HandMorph >> pendingEventQueue [

	^ pendingEventQueue ifNil: [ pendingEventQueue := WaitfreeQueue new ]
]

{ #category : #geometry }
HandMorph >> position [

	^temporaryCursor
		ifNil: [bounds topLeft]
		ifNotNil: [
			temporaryCursorOffset 
				ifNil: [ bounds topLeft ]
				ifNotNil: [ :anOffset | bounds topLeft - anOffset ] ]
]

{ #category : #geometry }
HandMorph >> position: aPoint [
	"Overridden to align submorph origins to the grid if gridding is on."
	| adjustedPosition delta box |
	adjustedPosition := aPoint.
	temporaryCursor ifNotNil: [adjustedPosition := adjustedPosition + temporaryCursorOffset].

	"Copied from Morph to avoid owner layoutChanged"
	"Change the position of this morph and and all of its submorphs."
	delta := adjustedPosition - bounds topLeft.
	(delta x = 0 and: [delta y = 0]) ifTrue: [^ self].  "Null change"
	box := self fullBounds.
	(delta dotProduct: delta) > 100 ifTrue:[
		"e.g., more than 10 pixels moved"
		self invalidRect: box.
		self invalidRect: (box translateBy: delta).
	] ifFalse:[
		self invalidRect: (box merge: (box translateBy: delta)).
	].
	self privateFullMoveBy: delta.

]

{ #category : #'private events' }
HandMorph >> processEvents [
	^ self processEventsFromQueue: self eventQueue
]

{ #category : #'private events' }
HandMorph >> processEventsFromQueue: anEventBufferQueue [

	"Process user input events from the local input devices."

	| evt |

	[ (evt := self nextEventFrom: anEventBufferQueue) notNil ] whileTrue: [ 
		evt == #invalid ifTrue: [ ^ self ].
		evt ifNotNil: [ "Finally, handle it"
			self handleEvent: evt.
			"For better user feedback, return immediately after a mouse event has been processed."
			( evt isMouse and: [ evt isMouseWheel not ] )
				ifTrue: [ ^ self ]
		]
	].
	
	"note: if we come here we didn't have any mouse events"
	mouseClickState notNil ifTrue: [ 
		"No mouse events during this cycle. Make sure click states time out accordingly"
		mouseClickState handleEvent: lastMouseEvent asMouseMove from: self ].

]

{ #category : #'private events' }
HandMorph >> queuePendingEvent: aMorphicEvent [
	"Queue an (extra) event produced during an event handling cycle, to be processed in later cycles.
	An event handling cycle should generate and manage a single event.
	In the case a cycle needs to generate several events (see MouseClickState), only one event is handled.
	Remaining events are queued for later processing.
	"
	self pendingEventQueue nextPut: aMorphicEvent
]

{ #category : #'focus handling' }
HandMorph >> releaseAllFocus [
	mouseFocus := nil.
	self newKeyboardFocus: nil.

]

{ #category : #caching }
HandMorph >> releaseCachedState [
	| oo |
	super releaseCachedState.
	cacheCanvas := nil.
	oo := owner.
	self removeAllMorphs.
	self initialize.	"nuke everything"
	self privateOwner: oo.
	self releaseAllFocus.
]

{ #category : #'halo handling' }
HandMorph >> releaseHalo: aHalo [
	"Used for transfering halos between hands"
	self removeProperty: #halo
]

{ #category : #'focus handling' }
HandMorph >> releaseKeyboardFocus [
	"Release the current keyboard focus unconditionally"
	self newKeyboardFocus: nil.

]

{ #category : #'focus handling' }
HandMorph >> releaseKeyboardFocus: aMorph [
	"If the given morph had the keyboard focus before, release it"
	self keyboardFocus == aMorph ifTrue:[self releaseKeyboardFocus].
]

{ #category : #'focus handling' }
HandMorph >> releaseMouseFocus [
	"Release the current mouse focus unconditionally."
	self newMouseFocus: nil.
]

{ #category : #'focus handling' }
HandMorph >> releaseMouseFocus: aMorph [
	"If the given morph had the mouse focus before, release it"
	self mouseFocus == aMorph ifTrue:[self releaseMouseFocus].
]

{ #category : #listeners }
HandMorph >> removeEventListener: anObject [
	"Remove anObject from the current event listeners."
	self eventListeners: (self removeListener: anObject from: self eventListeners).
]

{ #category : #'halo handling' }
HandMorph >> removeHalo [
	"remove the receiver's halo (if any)"
	self halo ifNotNil: [ :h | self removeHaloAround: h target ]
]

{ #category : #'halo handling' }
HandMorph >> removeHaloAround: aMorph [
	"remove the receiver's halo associated to aMorph (if any)"
	| halo |
	halo := self halo.
	halo
		ifNil: [ ^ self ].
	halo target == aMorph
		ifFalse: [ ^ self ].
	self removeProperty: #halo.
	halo delete.
]

{ #category : #'halo handling' }
HandMorph >> removeHaloFromClick: anEvent on: aMorph [ 
	| halo |
	halo := self halo
				ifNil: [^ self].
	(halo target hasOwner: self)
		ifTrue: [^ self].
	(halo staysUpWhenMouseIsDownIn: aMorph)
		ifFalse: [self removeHalo]
]

{ #category : #listeners }
HandMorph >> removeListener: anObject from: aListenerGroup [ 
	"Remove anObject from the given listener group. Return the new group."

	| listeners |
	aListenerGroup ifNil: [^nil].
	listeners := aListenerGroup.
	listeners := listeners copyWithout: anObject.
	listeners := listeners copyWithout: nil.	"obsolete entries"
	listeners isEmpty ifTrue: [listeners := nil].
	^listeners
]

{ #category : #listeners }
HandMorph >> removeMouseListener: anObject [
	"Remove anObject from the current mouse listeners."
	self mouseListeners: (self removeListener: anObject from: self mouseListeners).
]

{ #category : #'balloon help' }
HandMorph >> removePendingBalloonFor: aMorph [
	"Get rid of pending balloon help."
	self removeAlarm: #spawnBalloonFor:.
	self deleteBalloonTarget: aMorph.
]

{ #category : #'double click support' }
HandMorph >> resetClickState [
	"Reset the double-click detection state to normal (i.e., not waiting for a double-click)."
	mouseClickState := nil.
]

{ #category : #drawing }
HandMorph >> restoreSavedPatchOn: aCanvas [ 
	"Clear the changed flag and restore the part of the given canvas under this hand from the previously saved patch. If necessary, handle the transition to using the hardware cursor."
	| cursor |

	hasChanged := false.
	savedPatch ifNotNil: 
			[aCanvas drawImage: savedPatch at: savedPatch offset.
			submorphs notEmpty ifTrue: [^self].
			(temporaryCursor notNil and: [hardwareCursor isNil]) ifTrue: [^self].

			"Make the transition to using hardware cursor. Clear savedPatch and
		 report one final damage rectangle to erase the image of the software cursor."
			super invalidRect: (savedPatch offset 
						extent: savedPatch extent + self shadowOffset)
				from: self.
			cursor := hardwareCursor ifNil: [Cursor normal].
			self currentCursor == cursor ifFalse: [cursor show].	"show hardware cursor"
			savedPatch := nil]
]

{ #category : #drawing }
HandMorph >> savePatchFrom: aCanvas [ 
	"Save the part of the given canvas under this hand as a Form and return its bounding rectangle."

	"Details: The previously used patch Form is recycled when possible to reduce the burden on storage management."

	| damageRect myBnds |
	damageRect := myBnds := self fullBounds.
	savedPatch ifNotNil: 
			[damageRect := myBnds merge: (savedPatch offset extent: savedPatch extent)].
	(savedPatch isNil or: [savedPatch extent ~= myBnds extent]) 
		ifTrue: 
			["allocate new patch form if needed"

			savedPatch := aCanvas form allocateForm: myBnds extent].
	aCanvas contentsOfArea: (myBnds translateBy: aCanvas origin)
		into: savedPatch.
	savedPatch offset: myBnds topLeft.
	^damageRect
]

{ #category : #'selected object' }
HandMorph >> selectedObject [
	"answer the selected object for the hand or nil is none"
	| halo |
	halo := self halo.
	halo ifNil: [^ nil].
	^ halo target renderedMorph
]

{ #category : #'private events' }
HandMorph >> sendEvent: anEvent focus: focusHolder [
	"Send the event to the morph currently holding the focus, or if none to the owner of the hand."
	^self sendEvent: anEvent focus: focusHolder clear:[nil]
]

{ #category : #'private events' }
HandMorph >> sendEvent: anEvent focus: focusHolder clear: aBlock [
	"Send the event to the morph currently holding the focus, or if none to the owner of the hand."
	| result |
	focusHolder ifNotNil:[^self sendFocusEvent: anEvent to: focusHolder clear: aBlock].
	result := owner processEvent: anEvent.
	^result
]

{ #category : #'private events' }
HandMorph >> sendFocusEvent: anEvent to: focusHolder clear: aBlock [
	"Send the event to the morph currently holding the focus"
	| result w transformedEvent |
	
	w := focusHolder world ifNil:[^ aBlock value].
	transformedEvent := anEvent transformedBy: (focusHolder transformedFrom: self).

	w becomeActiveDuring:[
		result := focusHolder handleFocusEvent: transformedEvent.
	].

	"As I am copying the event, I have to propagate the supressNextKeyPress, so it is correctly handled."
	anEvent isKeyboard 
		ifTrue: [ anEvent supressNextKeyPress: transformedEvent supressNextKeyPress ]. 

	^result
]

{ #category : #'private events' }
HandMorph >> sendKeyboardEvent: anEvent [ 
	"Send the event to the morph currently holding the focus, or if none to
	the owner of the hand."
	^ self
		sendEvent: anEvent
		focus: self keyboardFocus
		clear: [self keyboardFocus: nil]
]

{ #category : #'private events' }
HandMorph >> sendListenEvent: anEvent to: listenerGroup [
	"Send the event to the given group of listeners"
	listenerGroup ifNil:[^self].
	listenerGroup do:[:listener| 
		listener ifNotNil:[listener handleListenEvent: anEvent copy]].
]

{ #category : #'private events' }
HandMorph >> sendMouseEvent: anEvent [
	"Send the event to the morph currently holding the focus, or if none to the owner of the hand."
	^self sendEvent: anEvent focus: self mouseFocus clear:[self mouseFocus: nil]
]

{ #category : #drawing }
HandMorph >> shadowForm [
	"Return a 1-bit shadow of my submorphs.  Assumes submorphs is not empty"
	| bnds canvas |
	bnds := Rectangle merging: (submorphs collect: [:m | m fullBounds]).
	canvas := (Display defaultCanvasClass extent: bnds extent depth: 1) 
		asShadowDrawingCanvas: Color black.
	canvas translateBy: bnds topLeft negated
		during:[:tempCanvas| self drawSubmorphsOn: tempCanvas].
	^ canvas form offset: bnds topLeft
]

{ #category : #'drop shadows' }
HandMorph >> shadowOffset [

	^ 6@8
]

{ #category : #accessing }
HandMorph >> shiftPressed [
	^lastMouseEvent shiftPressed
]

{ #category : #'events-processing' }
HandMorph >> showDebugEvent: evt [

	ShowEvents == true ifTrue: [
		| ofs| 
		Display fill: (0@0 extent: 500@120) rule: Form over fillColor: Color white.
		ofs := (owner hands indexOf: self) - 1 * 60.
		evt printString displayAt: (0@ofs) + (evt isKeyboard ifTrue: [0@30] ifFalse: [0@0]).
		self keyboardFocus printString displayAt: (0@ofs)+(0@45).
		].
]

{ #category : #'events-processing' }
HandMorph >> showMouseFocusEvent: evt [

	ShowEvents == true ifTrue: [
		| ofs| 
		ofs := (owner hands indexOf: self) - 1 * 60.
		self mouseFocus printString displayAt: (0@ofs) + (0@15)].
		
]

{ #category : #cursor }
HandMorph >> showTemporaryCursor: cursorOrNil [
	"Set the temporary cursor to the given Form. If the argument is nil, revert to the normal cursor."

	self showTemporaryCursor: cursorOrNil hotSpotOffset: 0@0

]

{ #category : #cursor }
HandMorph >> showTemporaryCursor: cursorOrNil hotSpotOffset: hotSpotOffset [ 
	"Set the temporary cursor to the given Form.
	If the argument is nil, revert to the normal hardware cursor."

	self changed.
	temporaryCursorOffset 
		ifNotNil: [bounds := bounds translateBy: temporaryCursorOffset negated].
	cursorOrNil 
		ifNil: [temporaryCursor := temporaryCursorOffset := hardwareCursor := nil]
		ifNotNil: 
			[temporaryCursor := cursorOrNil asCursorForm.
			temporaryCursorOffset := temporaryCursor offset - hotSpotOffset.
			(cursorOrNil isKindOf: Cursor) ifTrue: [hardwareCursor := cursorOrNil]].
	bounds := self cursorBounds.
	self
		layoutChanged;
		changed
]

{ #category : #'balloon help' }
HandMorph >> spawnBalloonFor: aMorph [
	aMorph showBalloon: aMorph balloonText hand: self.
]

{ #category : #accessing }
HandMorph >> targetOffset [
	"Return the offset of the last mouseDown location relative to the origin of the recipient morph. During menu interactions, this is the absolute location of the mouse down event that invoked the menu."

	^ targetOffset

]

{ #category : #accessing }
HandMorph >> targetPoint [
	"Return the new position of the target.
	I.E. return the position of the hand less 
	the original distance between hand and target position"

	^ self position - targetOffset

]

{ #category : #cursor }
HandMorph >> temporaryCursor [
	^ temporaryCursor
]

{ #category : #'balloon help' }
HandMorph >> triggerBalloonFor: aMorph after: timeOut [
	"Trigger balloon help after the given time out for some morph"
	self addAlarm: #spawnBalloonFor: with: aMorph after: timeOut.
]

{ #category : #drawing }
HandMorph >> updateCacheCanvas: aCanvas [ 
	"Update the cached image of the morphs being held by this hand."

	"Note: The following is an attempt to quickly get out if there's no change"

	| subBnds rectList nPix |
	subBnds := Rectangle merging: (submorphs collect: [:m | m fullBounds]).
	rectList := damageRecorder invalidRectsFullBounds: subBnds.
	damageRecorder reset.
	(rectList isEmpty 
		and: [cacheCanvas notNil and: [cacheCanvas extent = subBnds extent]]) 
			ifTrue: [^self].

	"Always check for real translucency -- can't be cached in a form"
	self submorphsDo: 
			[:m | 
			m wantsToBeCachedByHand 
				ifFalse: 
					[cacheCanvas := nil.
					cachedCanvasHasHoles := true.
					^self]].
	(cacheCanvas isNil or: [cacheCanvas extent ~= subBnds extent]) 
		ifTrue: 
			[cacheCanvas := (aCanvas allocateForm: subBnds extent) getCanvas.
			cacheCanvas translateBy: subBnds origin negated
				during: [:tempCanvas | self drawSubmorphsOn: tempCanvas].
			self submorphsDo: 
					[:m | 
					(m areasRemainingToFill: subBnds) isEmpty 
						ifTrue: [^cachedCanvasHasHoles := false]].
			nPix := cacheCanvas form tallyPixelValues first.
			"--> begin rounded corners hack <---"
			cachedCanvasHasHoles := (nPix = 48 
						and: [submorphs size = 1 and: [submorphs first wantsRoundedCorners]]) 
							ifTrue: [false]
							ifFalse: [nPix > 0].
			"--> end rounded corners hack <---"
			^self].

	"incrementally update the cache canvas"
	cacheCanvas translateBy: subBnds origin negated
		during: 
			[:cc | 
			rectList do: 
					[:r | 
					cc clipBy: r
						during: 
							[:c | 
							c fillColor: Color transparent.
							self drawSubmorphsOn: c]]]
]

{ #category : #copying }
HandMorph >> veryDeepCopyWith: deepCopier [
	"Return self.  Do not copy hands this way."
	^ self
]

{ #category : #drawing }
HandMorph >> visible: aBoolean [
	self needsToBeDrawn ifFalse: [ ^self ].
	super visible: aBoolean
]

{ #category : #'events-processing' }
HandMorph >> waitButton [
	self captureEventsUntil: [:evt | self anyButtonPressed ]

]

{ #category : #'double click support' }
HandMorph >> waitForClicksOrDrag: aMorph event: evt [
	"Wait for mouse button and movement events, informing aMorph about events interesting to it via callbacks.
	This message is typically sent to the Hand by aMorph when it first receives a mouse-down event.
	The callback methods invoked on aMorph (which are passed a copy of evt) are:
		#click:	sent when the mouse button goes up within doubleClickTime.
		#doubleClick:	sent when the mouse goes up, down, and up again all within DoubleClickTime.
		#doubleClickTimeout:  sent when the mouse does not have a doubleClick within DoubleClickTime.
		#startDrag:	sent when the mouse moves more than 10 pixels from evt's position within DoubleClickTime.
	Note that mouseMove: and mouseUp: events are not sent to aMorph until it becomes the mouse focus,
	which is typically done by aMorph in its click:, doubleClick:, or drag: methods."
	
	^self waitForClicksOrDrag: aMorph event: evt selectors: #( #click: #doubleClick: #doubleClickTimeout: #startDrag:) threshold: 10

]
