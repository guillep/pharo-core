"
SDL2 library structure
"
Class {
	#name : #'SDL_Keysym',
	#superclass : #SDL2Structure,
	#classVars : [
		'OFFSET_MOD',
		'OFFSET_SCANCODE',
		'OFFSET_SYM',
		'OFFSET_UNUSED'
	],
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #'fields description' }
SDL_Keysym class >> fieldsDesc [
	"
	self initializeAccessors
	"
	^#(
    SDL_Scancode scancode;
    SDL_Keycode sym;
    Uint16 mod;
    Uint32 unused;
 	)
]

{ #category : #'accessing - structure variables' }
SDL_Keysym >> mod [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_MOD
]

{ #category : #'accessing - structure variables' }
SDL_Keysym >> mod: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_MOD put: anObject
]

{ #category : #printing }
SDL_Keysym >> printOn: aStream [

	super printOn: aStream.
	aStream print: { self mod. self scancode. self sym }.
]

{ #category : #'accessing - structure variables' }
SDL_Keysym >> scancode [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_SCANCODE
]

{ #category : #'accessing - structure variables' }
SDL_Keysym >> scancode: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_SCANCODE put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_Keysym >> sym [
	"This method was automatically generated"
	^handle signedLongAt: OFFSET_SYM
]

{ #category : #'accessing - structure variables' }
SDL_Keysym >> sym: anObject [
	"This method was automatically generated"
	handle signedLongAt: OFFSET_SYM put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_Keysym >> unused [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_UNUSED
]

{ #category : #'accessing - structure variables' }
SDL_Keysym >> unused: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_UNUSED put: anObject
]
