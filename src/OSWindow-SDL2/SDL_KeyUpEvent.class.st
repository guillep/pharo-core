"
SDL2 library structure
"
Class {
	#name : #'SDL_KeyUpEvent',
	#superclass : #'SDL_KeyboardEvent',
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #'event type' }
SDL_KeyUpEvent class >> eventType [
	^ SDL_KEYUP
]

{ #category : #visitor }
SDL_KeyUpEvent >> accept: aVisitor [
	^ aVisitor visitKeyUpEvent: self
]

{ #category : #testing }
SDL_KeyUpEvent >> isKeyUpEvent [

	^ true
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> keysym [
	"This method was automatically generated"
	^ SDL_Keysym fromHandle: (handle referenceStructAt: OFFSET_KEYSYM length: SDL_Keysym byteSize)
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> keysym: anObject [
	"This method was automatically generated"
	handle structAt: OFFSET_KEYSYM put: anObject getHandle length: SDL_Keysym byteSize
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> padding2 [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_PADDING2
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> padding2: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_PADDING2 put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> padding3 [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_PADDING3
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> padding3: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_PADDING3 put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> repeat [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_REPEAT
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> repeat: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_REPEAT put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> state [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_STATE
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> state: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_STATE put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> timestamp [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_TIMESTAMP
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> timestamp: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_TIMESTAMP put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> type [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_TYPE
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> type: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_TYPE put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> windowID [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_WINDOWID
]

{ #category : #'accessing - structure variables' }
SDL_KeyUpEvent >> windowID: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_WINDOWID put: anObject
]
