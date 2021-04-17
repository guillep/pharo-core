"
I am a simple class implementing some features of SDL that are platform specific.
Get the corresponding class to use through

 OSPlatform current sdlPlatform
"
Class {
	#name : #SDLAbstractPlatform,
	#superclass : #Object,
	#pools : [
		'SDL2ConstantsHint'
	],
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #operations }
SDLAbstractPlatform >> afterSetWindowTitle: aString onWindow: aOSSDLWindow [

	self subclassResponsibility
]

{ #category : #initialization }
SDLAbstractPlatform >> initPlatformSpecific [

	self subclassResponsibility
]
