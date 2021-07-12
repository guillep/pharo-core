"
SDL2 library structure
"
Class {
	#name : #'SDL_KeyboardEvent',
	#superclass : #SDL2MappedEvent,
	#classVars : [
		'OFFSET_KEYSYM',
		'OFFSET_PADDING2',
		'OFFSET_PADDING3',
		'OFFSET_REPEAT',
		'OFFSET_STATE',
		'OFFSET_TIMESTAMP',
		'OFFSET_TYPE',
		'OFFSET_WINDOWID'
	],
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #'field definition' }
SDL_KeyboardEvent class >> fieldsDesc [
	"
	self initializeAccessors
	"
	^ #(
	Uint32 type;
	Uint32 timestamp;
	Uint32 windowID;
	Uint8 state;
	Uint8 repeat;
    	Uint8 padding2;
    	Uint8 padding3;
    	SDL_Keysym keysym;
 	)
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> keysym [
	"This method was automatically generated"
	^ SDL_Keysym fromHandle: (handle referenceStructAt: OFFSET_KEYSYM length: SDL_Keysym byteSize)
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> keysym: anObject [
	"This method was automatically generated"
	handle structAt: OFFSET_KEYSYM put: anObject getHandle length: SDL_Keysym byteSize
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> padding2 [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_PADDING2
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> padding2: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_PADDING2 put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> padding3 [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_PADDING3
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> padding3: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_PADDING3 put: anObject
]

{ #category : #printing }
SDL_KeyboardEvent >> printOn: aStream [

	super printOn: aStream.
	
	aStream print: { self timestamp. self keysym. self type. self windowID. self state }.
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> repeat [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_REPEAT
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> repeat: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_REPEAT put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> state [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_STATE
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> state: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_STATE put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> timestamp [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_TIMESTAMP
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> timestamp: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_TIMESTAMP put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> type [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_TYPE
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> type: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_TYPE put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> windowID [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_WINDOWID
]

{ #category : #'accessing - structure variables' }
SDL_KeyboardEvent >> windowID: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_WINDOWID put: anObject
]
