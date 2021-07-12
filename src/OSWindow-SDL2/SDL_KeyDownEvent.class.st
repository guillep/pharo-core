"
SDL2 library structure
"
Class {
	#name : #'SDL_KeyDownEvent',
	#superclass : #'SDL_KeyboardEvent',
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #'event type' }
SDL_KeyDownEvent class >> eventType [
	^ SDL_KEYDOWN
]

{ #category : #visitor }
SDL_KeyDownEvent >> accept: aVisitor [
	^ aVisitor visitKeyDownEvent: self
]

{ #category : #testing }
SDL_KeyDownEvent >> isKeyDownEvent [

	^ true
]

{ #category : #testing }
SDL_KeyDownEvent >> isUserInterrupt [

	^ ((self keysym mod bitAnd: 16r200) = 0) "ignore all if AltGr is pressed" 
		and: [(self keysym mod anyMask: 1344) 
			and: [ self keysym scancode = 55 ] ]
	
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> keysym [
	"This method was automatically generated"
	^ SDL_Keysym fromHandle: (handle referenceStructAt: OFFSET_KEYSYM length: SDL_Keysym byteSize)
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> keysym: anObject [
	"This method was automatically generated"
	handle structAt: OFFSET_KEYSYM put: anObject getHandle length: SDL_Keysym byteSize
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> padding2 [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_PADDING2
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> padding2: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_PADDING2 put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> padding3 [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_PADDING3
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> padding3: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_PADDING3 put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> repeat [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_REPEAT
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> repeat: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_REPEAT put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> state [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_STATE
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> state: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_STATE put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> timestamp [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_TIMESTAMP
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> timestamp: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_TIMESTAMP put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> type [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_TYPE
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> type: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_TYPE put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> windowID [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_WINDOWID
]

{ #category : #'accessing - structure variables' }
SDL_KeyDownEvent >> windowID: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_WINDOWID put: anObject
]
