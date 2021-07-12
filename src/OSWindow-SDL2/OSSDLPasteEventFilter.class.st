Class {
	#name : #OSSDLPasteEventFilter,
	#superclass : #Object,
	#instVars : [
		'next',
		'lastEvents',
		'currentState'
	],
	#pools : [
		'SDL2Constants'
	],
	#category : #'OSWindow-SDL2-Base'
}

{ #category : #'last events' }
OSSDLPasteEventFilter >> addEvent: aEvent [

	self lastEvents add: aEvent
]

{ #category : #'events-processing' }
OSSDLPasteEventFilter >> changeEventsToIncludeModifier [

	| modifierToUse defaultModifier |

	"We modify the KeyUp/KeyDown events to include the correct modifier.
	This is because tools to handle copy/paste use virtual events, and SDL is dropping the modifier.
	
	The correct modifier is calculated depending of the current platform modifier"

	modifierToUse := 0.
	defaultModifier := OSPlatform current defaultModifier.
	
	defaultModifier = KMModifier command ifTrue: [ modifierToUse := KMOD_GUI ].
	defaultModifier = KMModifier alt ifTrue: [ 	modifierToUse := KMOD_LALT ].
	defaultModifier = KMModifier ctrl ifTrue: [ modifierToUse := KMOD_LCTRL ].

	self lastEvents do: [ :anEvent | 
		(anEvent isKeyUpEvent or: [ anEvent isKeyDownEvent ]) 
			ifTrue: [ anEvent keysym mod: (anEvent keysym mod bitOr: modifierToUse) ] ]
]

{ #category : #accessing }
OSSDLPasteEventFilter >> currentState [

	^ currentState ifNil: [ currentState := 1 ]
]

{ #category : #accessing }
OSSDLPasteEventFilter >> currentState: aValue [

	currentState := aValue
]

{ #category : #'events-processing' }
OSSDLPasteEventFilter >> dispatchEvent: aSDLEvent [
	
	"
	This isssue was first detected in OSX, but we have seen the other platforms code in SDL and it is
	possible the issue will happen in all platforms.
	
	This filter will handle the case when an external Clipboard handling tool is used.
	When an external tool modifies the clipboard and send a virtual paste command, it sends three events:
	
	1) SDL_CLIPBOARDUPDATEEVENT
	2) SDL_KEYDOWN with $v as the key
	3) SDL KEYUP with $v as the keysym 
	
	If we find these three events, we need to modify the last two events to include defaul system modifier.
	Check #changeEventsToIncludeModifier.
	
	This is implemented with a 3 state machine.
	
	State 1: This is the default state. All events are passed to the next filter (or the driver if there is not filter).
	         If we found a Clipboard Update event, we store the event for the future, and change the state to 2. We don't dispatch the event.
	
	State 2: It will check if the event is a KeyDown with a $V and if it is, it will store the event and change to state 3.
	         If the event is other one, it will go to error state and flush all pending events, change to state one and dispatch current event.
	
	State 3: It will check if the event is a KeyUp with a $V and if it is, it will update pending events to have the virtual modifier.
		      Then pending events are flushed.
	         If the event is other one, it will go to error state and flush all pending events, change to state one and dispatch current event. "
	
	(self currentState = 1 and: [aSDLEvent isClipboardUpdateEvent not]) 
		ifTrue: [  ^ next dispatchEvent: aSDLEvent ].

	(self currentState = 1 and: [aSDLEvent isClipboardUpdateEvent]) 
		ifTrue: [ 
			self addEvent: aSDLEvent.
			self currentState: 2.
			 ^ self ].

	(self currentState = 2 and: [self isKeyDownV: aSDLEvent]) 
		ifTrue: [ 
			self addEvent: aSDLEvent.
			self currentState: 3.
			 ^ self ].

	(self currentState = 3 and: [self isKeyUpV: aSDLEvent]) 
		ifTrue: [ 
			self addEvent: aSDLEvent.
			self changeEventsToIncludeModifier.
			self flushEvents.
			self currentState: 1.
			^ self].
	
	self flushEvents.
	self currentState: 1.
	^ next dispatchEvent: aSDLEvent		
]

{ #category : #'last events' }
OSSDLPasteEventFilter >> flushEvents [ 

	self lastEvents do: [ :anEvent | next dispatchEvent: anEvent ].
	self lastEvents removeAll.
]

{ #category : #'events-processing' }
OSSDLPasteEventFilter >> isKeyDownV: aSDLEvent [

	^ aSDLEvent isKeyDownEvent 
		and: [ aSDLEvent keysym scancode = 25 "SDL_SCANCODE_V" 
			and: [aSDLEvent keysym sym = SDLK_v]]
		
]

{ #category : #'events-processing' }
OSSDLPasteEventFilter >> isKeyUpV: aSDLEvent [

	^ aSDLEvent isKeyUpEvent 
		and: [ aSDLEvent keysym scancode = 25 "SDL_SCANCODE_V" 
			and: [aSDLEvent keysym sym = SDLK_v]]
		
]

{ #category : #'last events' }
OSSDLPasteEventFilter >> lastEvents [

	^ lastEvents ifNil: [ lastEvents := OrderedCollection new ]
]

{ #category : #accessing }
OSSDLPasteEventFilter >> next [

	^ next
]

{ #category : #accessing }
OSSDLPasteEventFilter >> next: anObject [

	next := anObject
]
