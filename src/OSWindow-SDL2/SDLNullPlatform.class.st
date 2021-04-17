"
I am the default platform. All my methods are empty or have a default implementation
"
Class {
	#name : #SDLNullPlatform,
	#superclass : #SDLAbstractPlatform,
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #operations }
SDLNullPlatform >> afterSetWindowTitle: aString onWindow: aOSSDLWindow [
]

{ #category : #initialization }
SDLNullPlatform >> initPlatformSpecific [

	"For windows and Unix, we activate linearization.
	This does not work properly on OSX with retina display, blurrying the rendering"
	
	SDL2 setHint: SDL_HINT_RENDER_SCALE_QUALITY value: '1'
]
