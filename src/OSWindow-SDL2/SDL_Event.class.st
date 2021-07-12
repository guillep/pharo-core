"
This is a raw SDL2 event
"
Class {
	#name : #'SDL_Event',
	#superclass : #FFIExternalObject,
	#classVars : [
		'EventTypeMap'
	],
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #'class initialization' }
SDL_Event class >> initialize [
	"self initialize"

	SDL2Types initialize.  "make sure its initialized"
	self initializeEventTypeMap
]

{ #category : #'class initialization' }
SDL_Event class >> initializeEventTypeMap [
	"self initializeEventTypeMap"
	EventTypeMap := Dictionary new.
	SDL2MappedEvent  allSubclassesDo: [ :cls |
		| eventType |
		eventType := cls eventType.
		eventType ifNotNil: [ EventTypeMap at: eventType put: cls ] ]

]

{ #category : #initialization }
SDL_Event >> initialize [
	super initialize.
	self setHandle: (ByteArray new: 56)
]

{ #category : #accessing }
SDL_Event >> mapped [
	"This method converts a raw event in a mapped event.
	It should always return an event. Nil is not a valid return object"
	^ (EventTypeMap at: self type ifAbsent: [ ^ self unknownEvent ]) fromSdlEvent: self
]

{ #category : #accessing }
SDL_Event >> type [
	^self getHandle nbUInt32AtOffset: 0
]

{ #category : #accessing }
SDL_Event >> unknownEvent [
	^ SDL_CommonEvent fromSdlEvent: self
]
