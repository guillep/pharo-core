"
I holding a set of OpenGL attributes, used to initialize an opengl rendering context for a window.
"
Class {
	#name : #OSWindowGLAttributes,
	#superclass : #Object,
	#instVars : [
		'redSize',
		'blueSize',
		'greenSize',
		'alphaSize',
		'depthSize',
		'doubleBuffer',
		'swapControl',
		'stencilSize',
		'minorVersion',
		'majorVersion',
		'profileType',
		'srgbFramebuffer'
	],
	#classVars : [
		'DefaultAlphaSize',
		'DefaultBlueSize',
		'DefaultDepthSize',
		'DefaultDoubleBuffer',
		'DefaultGreenSize',
		'DefaultMajorVersion',
		'DefaultMinorVersion',
		'DefaultProfileType',
		'DefaultRedSize',
		'DefaultSRGBFramebuffer',
		'DefaultStencilSize',
		'DefaultSwapControl'
	],
	#category : #'OSWindow-Core-OpenGL'
}

{ #category : #defaults }
OSWindowGLAttributes class >> defaultAlphaSize [
	^ DefaultAlphaSize
]

{ #category : #defaults }
OSWindowGLAttributes class >> defaultBlueSize [
	^ DefaultBlueSize
]

{ #category : #defaults }
OSWindowGLAttributes class >> defaultDepthSize [
	^ DefaultDepthSize
]

{ #category : #defaults }
OSWindowGLAttributes class >> defaultDoubleBuffer [
	^ DefaultDoubleBuffer
]

{ #category : #defaults }
OSWindowGLAttributes class >> defaultGreenSize [
	^ DefaultGreenSize
]

{ #category : #defaults }
OSWindowGLAttributes class >> defaultMajorVersion [
	^ DefaultMajorVersion
]

{ #category : #defaults }
OSWindowGLAttributes class >> defaultMinorVersion [
	^ DefaultMinorVersion
]

{ #category : #defaults }
OSWindowGLAttributes class >> defaultProfileType [
	^ DefaultProfileType
]

{ #category : #defaults }
OSWindowGLAttributes class >> defaultRedSize [
	^ DefaultRedSize
]

{ #category : #defaults }
OSWindowGLAttributes class >> defaultSRGBFramebuffer [
	^ DefaultSRGBFramebuffer
]

{ #category : #defaults }
OSWindowGLAttributes class >> defaultStencilSize [
	^ DefaultStencilSize
]

{ #category : #defaults }
OSWindowGLAttributes class >> defaultSwapControl [
	^ DefaultSwapControl
]

{ #category : #'class initialization' }
OSWindowGLAttributes class >> initialize [
	DefaultRedSize := 5.
	DefaultGreenSize := 5.
	DefaultBlueSize := 5.
	DefaultAlphaSize := 5.
	DefaultDepthSize := 16.
	DefaultDoubleBuffer := 1.
	DefaultStencilSize := 0.
	DefaultSwapControl := 0.
	DefaultMajorVersion := nil.
	DefaultMinorVersion := nil.
	DefaultProfileType := nil.
	DefaultSRGBFramebuffer := false.
]

{ #category : #accessing }
OSWindowGLAttributes >> alphaSize [
	
	^ alphaSize
]

{ #category : #accessing }
OSWindowGLAttributes >> alphaSize: anObject [
	
	alphaSize := anObject
]

{ #category : #accessing }
OSWindowGLAttributes >> blueSize [
	
	^ blueSize
]

{ #category : #accessing }
OSWindowGLAttributes >> blueSize: anObject [
	
	blueSize := anObject
]

{ #category : #accessing }
OSWindowGLAttributes >> depthSize [
	
	^ depthSize
]

{ #category : #accessing }
OSWindowGLAttributes >> depthSize: anObject [
	
	depthSize := anObject
]

{ #category : #accessing }
OSWindowGLAttributes >> doubleBuffer [
	
	^ doubleBuffer
]

{ #category : #accessing }
OSWindowGLAttributes >> doubleBuffer: anObject [
	
	doubleBuffer := anObject
]

{ #category : #accessing }
OSWindowGLAttributes >> greenSize [
	
	^ greenSize
]

{ #category : #accessing }
OSWindowGLAttributes >> greenSize: anObject [
	
	greenSize := anObject
]

{ #category : #'profile selection' }
OSWindowGLAttributes >> hasCompatibilityProfile [
	^ self profileType = #compatibility
]

{ #category : #'profile selection' }
OSWindowGLAttributes >> hasCoreProfile [
	^ self profileType = #core
]

{ #category : #'profile selection' }
OSWindowGLAttributes >> hasESProfile [
	^ self profileType = #es
]

{ #category : #initialization }
OSWindowGLAttributes >> initialize [
	redSize := DefaultRedSize.
	greenSize := DefaultGreenSize.
	blueSize := DefaultBlueSize.
	alphaSize := DefaultAlphaSize.
	depthSize := DefaultDepthSize.
	stencilSize := DefaultStencilSize.
	doubleBuffer := DefaultDoubleBuffer.
	swapControl := DefaultSwapControl.
	minorVersion := DefaultMinorVersion.
	majorVersion := DefaultMajorVersion.
	profileType := DefaultProfileType.
	srgbFramebuffer := DefaultSRGBFramebuffer.
]

{ #category : #accessing }
OSWindowGLAttributes >> majorVersion [
	^ majorVersion
]

{ #category : #accessing }
OSWindowGLAttributes >> majorVersion: anObject [
	majorVersion := anObject
]

{ #category : #accessing }
OSWindowGLAttributes >> minorVersion [
	^ minorVersion
]

{ #category : #accessing }
OSWindowGLAttributes >> minorVersion: anObject [
	minorVersion := anObject
]

{ #category : #accessing }
OSWindowGLAttributes >> profileType [
	^ profileType
]

{ #category : #accessing }
OSWindowGLAttributes >> profileType: anObject [
	profileType := anObject
]

{ #category : #accessing }
OSWindowGLAttributes >> redSize [
	
	^ redSize
]

{ #category : #accessing }
OSWindowGLAttributes >> redSize: anObject [
	
	redSize := anObject
]

{ #category : #'profile selection' }
OSWindowGLAttributes >> setCompatibilityProfile [
	self profileType: #compatibility
]

{ #category : #'profile selection' }
OSWindowGLAttributes >> setCoreProfile [
	self profileType: #core
]

{ #category : #'profile selection' }
OSWindowGLAttributes >> setESProfile [
	self profileType: #es
]

{ #category : #'profile selection' }
OSWindowGLAttributes >> setForOpenGLES20 [
	self
		setESProfile;
		majorVersion: 2;
		minorVersion: 0
]

{ #category : #'profile selection' }
OSWindowGLAttributes >> setForOpenGLES30 [
	self
		setESProfile;
		majorVersion: 3;
		minorVersion: 0
]

{ #category : #accessing }
OSWindowGLAttributes >> srgbFramebuffer [
	^ srgbFramebuffer
]

{ #category : #accessing }
OSWindowGLAttributes >> srgbFramebuffer: anObject [
	srgbFramebuffer := anObject
]

{ #category : #accessing }
OSWindowGLAttributes >> stencilSize [
	^ stencilSize
]

{ #category : #accessing }
OSWindowGLAttributes >> stencilSize: aStencilSize [
	stencilSize := aStencilSize
]

{ #category : #accessing }
OSWindowGLAttributes >> swapControl [
	
	^ swapControl
]

{ #category : #accessing }
OSWindowGLAttributes >> swapControl: anObject [
	
	swapControl := anObject
]
