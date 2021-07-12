"
SDL2 library structure
"
Class {
	#name : #SDL2MappedEvent,
	#superclass : #SDL2Structure,
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #visitor }
SDL2MappedEvent class >> accept: aVisitor [
	self subclassResponsibility
]

{ #category : #'event type' }
SDL2MappedEvent class >> eventType [
	^ nil
]

{ #category : #'instance creation' }
SDL2MappedEvent class >> fromSdlEvent: event [
	"SDL event handlers are copied because there are allocated in Pharo memory as a bytearray"
	^  self new setHandle: event getHandle copy
]

{ #category : #'event type' }
SDL2MappedEvent >> eventType [
	^ nil
]

{ #category : #testing }
SDL2MappedEvent >> isClipboardUpdateEvent [

	^ false
]

{ #category : #testing }
SDL2MappedEvent >> isKeyDownEvent [

	^ false
]

{ #category : #testing }
SDL2MappedEvent >> isKeyUpEvent [

	^ false
]

{ #category : #testing }
SDL2MappedEvent >> isUserInterrupt [

	^ false
]

{ #category : #accessing }
SDL2MappedEvent >> windowID [
	^ nil
]
