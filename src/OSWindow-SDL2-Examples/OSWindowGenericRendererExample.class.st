"
Example showing how to use the joystick.
"
Class {
	#name : #OSWindowGenericRendererExample,
	#superclass : #Object,
	#instVars : [
		'renderer',
		'window'
	],
	#category : #'OSWindow-SDL2-Examples-Examples'
}

{ #category : #factory }
OSWindowGenericRendererExample >> createEventHandler [
	"You should override this method with your own event handler"
	^ OSWindowGenericRendererExampleEventHandler new 
		example: self
]

{ #category : #'instance creation' }
OSWindowGenericRendererExample >> defaultExtent [
	^ 640@480
]

{ #category : #initialize }
OSWindowGenericRendererExample >> destroy [
	"This function must be called when the window is closed"
	"drawingProcess terminate"
]

{ #category : #accessing }
OSWindowGenericRendererExample >> enqueueRender [
	OSWindowRenderThread enqueueOperation: [ 
		renderer ifNotNil: [ self redrawAndPresent ].
	]
]

{ #category : #initialize }
OSWindowGenericRendererExample >> initializeWithRenderer [
		"Here we put all the things that needs the renderer to be initialized."
]

{ #category : #'instance creation' }
OSWindowGenericRendererExample >> maxFPS [
	^ 60
]

{ #category : #'instance creation' }
OSWindowGenericRendererExample >> open [
	| attrs |
	attrs := OSWindowAttributes new.
	attrs
		extent: self defaultExtent;
		resizable: false;
		windowCentered: true.
		
	window := OSWindowAnimated createWithAttributes: attrs.
	
	renderer := window newGenericRenderer.
	self initializeWithRenderer.
	
	window eventHandler: (self createEventHandler).

]

{ #category : #'instance creation' }
OSWindowGenericRendererExample >> present [
	renderer present
]

{ #category : #'instance creation' }
OSWindowGenericRendererExample >> redraw [
	^ self subclassResponsibility
]

{ #category : #'instance creation' }
OSWindowGenericRendererExample >> redrawAndPresent [
	self redraw.
	self present.
]
