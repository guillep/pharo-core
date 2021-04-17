"
A structure that contains information about the version of SDL in use.

See:
https://wiki.libsdl.org/SDL_version
"
Class {
	#name : #'SDL_Version',
	#superclass : #SDL2Structure,
	#classVars : [
		'OFFSET_MAJOR',
		'OFFSET_MINOR',
		'OFFSET_PATCH'
	],
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #accessing }
SDL_Version class >> bindingVersion [
	^ self new major: 2; minor: 0; patch: 4; yourself
]

{ #category : #'field definition' }
SDL_Version class >> fieldsDesc [
	"
	self initializeAccessors
	"
	^#(
		Uint8 major;
		Uint8 minor;
		Uint8 patch;
 	)
]

{ #category : #'accessing structure variables' }
SDL_Version >> major [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_MAJOR
]

{ #category : #'accessing structure variables' }
SDL_Version >> major: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_MAJOR put: anObject
]

{ #category : #'accessing structure variables' }
SDL_Version >> minor [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_MINOR
]

{ #category : #'accessing structure variables' }
SDL_Version >> minor: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_MINOR put: anObject
]

{ #category : #'accessing structure variables' }
SDL_Version >> patch [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_PATCH
]

{ #category : #'accessing structure variables' }
SDL_Version >> patch: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_PATCH put: anObject
]

{ #category : #printing }
SDL_Version >> printAsSemanticVersioningOn: aStream [
	"Print in format MAJOR.MINOR.PATCH."

	aStream
		print: self major;
		nextPut: $.;
		print: self minor;
		nextPut: $.;
		print: self patch

]

{ #category : #printing }
SDL_Version >> printOn: aStream [
	"Append a sequence of characters to aStream that identify the receiver."

	super printOn: aStream.
	aStream nextPut: $(.
	self printAsSemanticVersioningOn: aStream.
	aStream nextPut: $)
]
