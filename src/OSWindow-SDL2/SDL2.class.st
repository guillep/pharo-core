"
A bunch of functions in a single class for accessing SDL2 interface
"
Class {
	#name : #SDL2,
	#superclass : #Object,
	#classVars : [
		'ModuleName',
		'ModuleSession',
		'Session'
	],
	#pools : [
		'SDL2Constants',
		'SDL2ConstantsHint',
		'SDL2Types'
	],
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #'error handling' }
SDL2 class >> checkForError [
	| msg |
	msg := self getErrorMessage.
	( msg ~= SDL2 and: msg ~= '' ) ifTrue:[SDL2Error signal: msg]
]

{ #category : #native }
SDL2 class >> checkLibraryName: aName [
	^ (ExternalAddress loadSymbol: 'SDL_Init' from: aName) notNil
]

{ #category : #clipboard }
SDL2 class >> clipboardText [
	| text |
	
	text := self primClipboardText.
	^ text readStringUTF8

]

{ #category : #clipboard }
SDL2 class >> clipboardText: text [
	| encoded encoder |
	
	encoded := ByteArray streamContents: [ :stream |
		encoder := ZnUTF8Encoder new.
		encoder 
			next: text size 
			putAll: text asString
			startingAt: 1 
			toStream: stream.
		stream nextPut: 0 ].
	
	encoded pinInMemory.
	self primClipboardText: encoded
]

{ #category : #audio }
SDL2 class >> closeAudioDevice: dev [
	^ self ffiCall: #( void SDL_CloseAudioDevice(SDL_AudioDeviceID dev) )
]

{ #category : #video }
SDL2 class >> composeCustomBlendMode_srcColorFactor: srcColorFactor dstColorFactor: dstColorFactor colorOperation: colorOperation srcAlphaFactor: srcAlphaFactor dstAlphaFactor: dstAlphaFactor alphaOperation: alphaOperation [
	^ self ffiCall: #(SDL_BlendMode SDL_ComposeCustomBlendMode(SDL_BlendFactor srcColorFactor,
                                                                 SDL_BlendFactor dstColorFactor,
                                                                 SDL_BlendOperation colorOperation,
                                                                 SDL_BlendFactor srcAlphaFactor,
                                                                 SDL_BlendFactor dstAlphaFactor,
                                                                 SDL_BlendOperation alphaOperation))
]

{ #category : #cursor }
SDL2 class >> createCursor: data mask: mask w: w h: h hotX: hotX hotY: hotY [
	^ self ffiCall: #( SDL_Cursor SDL_CreateCursor ( Uint8* data, Uint8* mask, int w, int h, int hotX, int hotY ) )
]

{ #category : #cairo }
SDL2 class >> createRGBSurfaceForCairoWidth: width height: height [

	^ (self primCreateRGBSurfaceForCairoWidth: width height: height) initialize.
]

{ #category : #video }
SDL2 class >> createRGBSurfaceFromPixels: pixels width: width height: height depth: depth pitch: pitch
	rmask: rmask gmask: gmask bmask: bmask amask: amask [
	^ self ffiCall: #( SDL_Surface* SDL_CreateRGBSurfaceFrom 
						( void* pixels , int width , int height , int depth , int pitch ,
						  Uint32 rmask , Uint32 gmask , Uint32 bmask , Uint32 amask ) )
]

{ #category : #video }
SDL2 class >> createWindow: title x: x y: y width: w height: h flags: flags [
	^ self ffiCall: #( SDL_Window SDL_CreateWindow ( String title, int x, int y, int w, int h, Uint32 flags ) )
]

{ #category : #timer }
SDL2 class >> delay: milliseconds [
	^ self ffiCall: #( void SDL_Delay ( Uint32 milliseconds ) )
]

{ #category : #video }
SDL2 class >> disableScreenSaver [

	^ self ffiCall: #(void SDL_DisableScreenSaver(void))
]

{ #category : #native }
SDL2 class >> ffiLibraryName [
	^ self moduleName
]

{ #category : #native }
SDL2 class >> findSDL2 [
	"In Linux, try to use the linked version."
	OSSDL2Driver hasPlugin.
	
	"Look for SDL2 using different names."
	#(0							"Static"
	SDL2
	'libSDL2-2.0.0.dylib'		"Mac"
	'libSDL2-2.0.so.0'			"Linux 1"
	'libSDL2-2.0.so.0.2.1'	"Linux 2"
	'SDL2.dll'					"Windows"
	) do: [ :eachName | 
		[ (self checkLibraryName: eachName) ifTrue: [ ^ eachName ] ] 
		onErrorDo: [nil] ].
	self error: 'Failed to find SDL2 library.'
]

{ #category : #video }
SDL2 class >> freeSurface: surface [
	^ self ffiCall: #( void SDL_FreeSurface ( SDL_Surface* surface ) )
]

{ #category : #'game controller' }
SDL2 class >> gameControllerNameForIndex: deviceIndex [
	^ self ffiCall: #( SDL_String SDL_GameControllerNameForIndex ( int deviceIndex ) )
]

{ #category : #'game controller' }
SDL2 class >> gameControllerOpen: deviceIndex [
	^ self ffiCall: #( SDL_GameController SDL_GameControllerOpen ( int deviceIndex ) )
]

{ #category : #audio }
SDL2 class >> getAudioDeviceName: index isCapture: isCapture [
	^ self ffiCall: #( char* SDL_GetAudioDeviceName(int index, int isCapture) ) options: #( optStringEncodingUtf8 ).
]

{ #category : #video }
SDL2 class >> getDisplay: displayIndex ddpi: ddpi hdpi: hdpi vdpi: vdpi [
	^ self ffiCall: #( int SDL_GetDisplayDPI(int displayIndex, float* ddpi, float* hdpi, float* vdpi))
]

{ #category : #'error handling' }
SDL2 class >> getErrorMessage [
	^ self ffiCall: #( String SDL_GetError ( void ) )
]

{ #category : #audio }
SDL2 class >> getNumAudioDevices: isCapture [
	^ self ffiCall: #( int SDL_GetNumAudioDevices(int isCapture) )
]

{ #category : #audio }
SDL2 class >> getQueuedAudioSize: dev [
	^ self ffiCall: #( Uint32 SDL_GetQueuedAudioSize(SDL_AudioDeviceID dev) )
]

{ #category : #common }
SDL2 class >> getVersion: ver [
	"Get the version of SDL.

	See: https://wiki.libsdl.org/SDL_GetVersion
	"

	^ self ffiCall: #( void SDL_GetVersion(SDL_Version* ver) )
]

{ #category : #opengl }
SDL2 class >> glCreateContext: window [
	^ self ffiCall: #( SDL_GLContext SDL_GL_CreateContext ( SDL_Window window ) )
]

{ #category : #opengl }
SDL2 class >> glGetAttribute: attr [

	^ ExternalAddress allocate: 4 bytesDuring: [ :value | 
		  self glGetAttribute: attr into: value.
		  value nbUInt32AtOffset: 0 ]
]

{ #category : #opengl }
SDL2 class >> glGetAttribute: attr into: value [
	^ self ffiCall: #( int SDL_GL_GetAttribute(SDL_GLattr attr, int *value) )
]

{ #category : #opengl }
SDL2 class >> glGetProcAddress: procName [
	^ self ffiCall: #( void* SDL_GL_GetProcAddress ( String procName ) )
]

{ #category : #opengl }
SDL2 class >> glMakeCurrent: window context: context [
	^ self ffiCall: #( int SDL_GL_MakeCurrent ( SDL_Window window , SDL_GLContext context ) )
]

{ #category : #opengl }
SDL2 class >> glSetAttribute: attr value: value [
	^ self ffiCall: #( int SDL_GL_SetAttribute(SDL_GLattr attr, int value) )
]

{ #category : #opengl }
SDL2 class >> glSwapWindow: window [
	^ self ffiCall: #( void SDL_GL_SwapWindow ( SDL_Window window ) )
]

{ #category : #common }
SDL2 class >> init: flags [
	^ self ffiCall: #( int SDL_Init ( Uint32 flags ) )
]

{ #category : #common }
SDL2 class >> initAudio [
	self initLibrary;
		 initSubSystem: SDL_INIT_AUDIO
]

{ #category : #common }
SDL2 class >> initEverything [
	self initLibrary;
		 initSubSystem: SDL_INIT_EVERYTHING
]

{ #category : #common }
SDL2 class >> initGameController [
	self initLibrary;
		 initSubSystem: SDL_INIT_GAMECONTROLLER
]

{ #category : #common }
SDL2 class >> initJoystick [
	self initLibrary;
		 initSubSystem: SDL_INIT_JOYSTICK
]

{ #category : #common }
SDL2 class >> initLibrary [
	Session == Smalltalk session ifTrue: [ ^ 1 ].
	"Configure SDL2 in 'application mode', to let the screen to turn off on inactivity.
	 But we let the user to restore 'game mode' on screen, by using #disableScreenSaver"
	
	self initPlatformSpecific.
	
	self
		setHint: SDL_HINT_VIDEO_ALLOW_SCREENSAVER value: '1';
		setHint: SDL_HINT_NO_SIGNAL_HANDLERS value: '1'.
		
	self init: SDL_INIT_NOPARACHUTE.
	Session := Smalltalk session.
]

{ #category : #common }
SDL2 class >> initPlatformSpecific [

	OSPlatform current sdlPlatform initPlatformSpecific.

]

{ #category : #common }
SDL2 class >> initSubSystem: flags [
	^ self ffiCall: #( int SDL_InitSubSystem ( Uint32 flags ) )
]

{ #category : #common }
SDL2 class >> initVideo [
	self initLibrary;
		 initSubSystem: SDL_INIT_VIDEO
]

{ #category : #common }
SDL2 class >> isAvailable [
	^ [ (ExternalAddress loadSymbol: 'SDL_Init' from: SDL2 moduleName) notNil ] 	
		onErrorDo: [ false ]
]

{ #category : #'game controller' }
SDL2 class >> isGameController: deviceIndex [
	^ self ffiCall: #( bool SDL_IsGameController ( int deviceIndex ) )
]

{ #category : #joystick }
SDL2 class >> joystickEventState: state [
	^ self ffiCall: #( SDL_Joystick SDL_JoystickEventState ( int state ) )
]

{ #category : #joystick }
SDL2 class >> joystickOpen: deviceIndex [
	^ self ffiCall: #( SDL_Joystick SDL_JoystickOpen ( int deviceIndex ) )
]

{ #category : #mouse }
SDL2 class >> modState [
	^ self ffiCall: #( SDL_Keymod SDL_GetModState ( ) )
]

{ #category : #native }
SDL2 class >> moduleName [
	ModuleSession ~~ Smalltalk session ifTrue: [
		ModuleName := self findSDL2.
		ModuleSession := Smalltalk session
	].
	^ ModuleName
]

{ #category : #mouse }
SDL2 class >> mouseState [
	^ self ffiCall: #( Uint32 SDL_GetMouseState ( nil , nil ) )
]

{ #category : #mouse }
SDL2 class >> mouseStateX: x y: y [
	^ self ffiCall: #( Uint32 SDL_GetMouseState ( int* x , int* y ) )
]

{ #category : #joystick }
SDL2 class >> numberOfJoysticks [
	^ self ffiCall: #( int SDL_NumJoysticks() )
]

{ #category : #audio }
SDL2 class >> openAudioDevice: device isCapture: isCapture desired: desired obtained: obtained allowedChanges: allowedChanges [
	^ self ffiCall: #( SDL_AudioDeviceID SDL_OpenAudioDevice(void* device, int isCapture, SDL_AudioSpec* desired, SDL_AudioSpec* obtained, int allowedChanges) )
]

{ #category : #audio }
SDL2 class >> pauseAudioDevice: dev pauseOn: pauseOn [
	^ self ffiCall: #( void SDL_PauseAudioDevice(SDL_AudioDeviceID dev, int pauseOn) )
]

{ #category : #event }
SDL2 class >> pollEvent: event [
	^ self ffiCall: #( int SDL_PollEvent ( SDL_Event event ) )
]

{ #category : #clipboard }
SDL2 class >> primClipboardText [
	^ self ffiCall: #(void* SDL_GetClipboardText ( ) )
]

{ #category : #clipboard }
SDL2 class >> primClipboardText: text [
	"It receives a ByteArray because it can be encoded"

	^ self ffiCall: #( int SDL_SetClipboardText ( ByteArray text ) )
]

{ #category : #cairo }
SDL2 class >> primCreateRGBSurfaceForCairoWidth: width height: height [
	^ self ffiCall: #( SDL_Surface* SDL_CreateRGBSurface 
						( 0 , int width , int height , 32 ,
						  16r00FF0000 , 16r0000FF00 , 16r000000FF , 0 ) )
]

{ #category : #audio }
SDL2 class >> queueAudio: dev data: data len: len [
	^ self ffiCall: #( int SDL_QueueAudio(SDL_AudioDeviceID dev, void* data, Uint32 len) )
]

{ #category : #common }
SDL2 class >> quit [
	^ self ffiCall: #( void SDL_Quit ( ) )
]

{ #category : #common }
SDL2 class >> quitSubSystem: flags [
	^ self ffiCall: #( void SDL_QuitSubSystem ( Uint32 flags ) )
]

{ #category : #video }
SDL2 class >> setHint: aName value: aValue [
	^ self ffiCall: #(int SDL_SetHint(const char* aName, const char* aValue))
]

{ #category : #mouse }
SDL2 class >> setRelativeMouseMode: enabled [
	^ self ffiCall: #( int SDL_SetRelativeMouseMode ( bool enabled ) )
]

{ #category : #cursor }
SDL2 class >> showCursor: toggle [
	^ self ffiCall: #( int SDL_ShowCursor ( int toggle ) )
]

{ #category : #timer }
SDL2 class >> ticks [
	"Gets the number of milliseconds since the SDL library was initialized"
	^ self ffiCall: #( Uint32 SDL_GetTicks ( ) )
]

{ #category : #common }
SDL2 class >> version [
	"Answer the SDL version. For example, a SDL_Version(2.0.7)."

	| version |
	version := SDL_Version new.
	self getVersion: version.
	version autoRelease.
	^ version
]

{ #category : #common }
SDL2 class >> wasInit: flags [
	^ self ffiCall: #( int SDL_WasInit ( Uint32 flags ) )
]

{ #category : #'nb-library' }
SDL2 >> ffiLibraryName [
	^self class ffiLibraryName
]
