"
SDL2 library structure
"
Class {
	#name : #'SDL_CommonEvent',
	#superclass : #SDL2MappedEvent,
	#classVars : [
		'OFFSET_TIMESTAMP',
		'OFFSET_TYPE'
	],
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #'fields description' }
SDL_CommonEvent class >> fieldsDesc [
	"
	self initializeAccessors
	"
	^ #(
    		Uint32 type;
    		Uint32 timestamp;
 	)
]

{ #category : #visitor }
SDL_CommonEvent >> accept: aVisitor [
	^ aVisitor visitCommonEvent: self
]

{ #category : #'accessing - structure variables' }
SDL_CommonEvent >> printOn: aStream [

	super printOn: aStream.
	aStream print: { self timestamp }.
]

{ #category : #'accessing - structure variables' }
SDL_CommonEvent >> timestamp [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_TIMESTAMP
]

{ #category : #'accessing - structure variables' }
SDL_CommonEvent >> timestamp: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_TIMESTAMP put: anObject
]

{ #category : #'accessing - structure variables' }
SDL_CommonEvent >> type [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_TYPE
]

{ #category : #'accessing - structure variables' }
SDL_CommonEvent >> type: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_TYPE put: anObject
]
