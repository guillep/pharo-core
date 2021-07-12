"
I am an event that is generated when the clipboard has been updated by other application.
"
Class {
	#name : #'SDL_ClipboardUpdateEvent',
	#superclass : #'SDL_CommonEvent',
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #'event type' }
SDL_ClipboardUpdateEvent class >> eventType [ 

	^ SDL_CLIPBOARDUPDATE
]

{ #category : #testing }
SDL_ClipboardUpdateEvent >> isClipboardUpdateEvent [

	^ true
]
