"
I am abstract class, representing an OSWindow handle.
Each instance of OSWindow holds a handle, through which it communicates with underlaying operating system.

The implementation of OSWindowHandle (and subclasses) is highly driver-specific and therefore considered private.
"
Class {
	#name : #OSBackendWindow,
	#superclass : #Object,
	#instVars : [
		'osWindow',
		'renderer'
	],
	#category : #'OSWindow-Core-Utilities'
}

{ #category : #accessing }
OSBackendWindow >> borderless [
	^ false
]

{ #category : #accessing }
OSBackendWindow >> borderless: aBoolean [
	
]

{ #category : #accessing }
OSBackendWindow >> bounds [
	^ self position extent: self extent
]

{ #category : #accessing }
OSBackendWindow >> bounds: newBounds [
	self subclassResponsibility 
]

{ #category : #'mouse capture' }
OSBackendWindow >> captureMouse [
]

{ #category : #accessing }
OSBackendWindow >> clipboardText [
	self subclassResponsibility 
]

{ #category : #accessing }
OSBackendWindow >> clipboardText: aString [
	self subclassResponsibility 
]

{ #category : #accessing }
OSBackendWindow >> diagonalDPI [
	^ self screenScaleFactorBaseDPI
]

{ #category : #accessing }
OSBackendWindow >> extent [
	^ self bounds extent
]

{ #category : #accessing }
OSBackendWindow >> extent: newExtent [
	self subclassResponsibility 
]

{ #category : #accessing }
OSBackendWindow >> fullscreen: aBoolean [
]

{ #category : #accessing }
OSBackendWindow >> hide [
	self subclassResponsibility 
]

{ #category : #accessing }
OSBackendWindow >> horizontalDPI [
	^ self screenScaleFactorBaseDPI
]

{ #category : #accessing }
OSBackendWindow >> icon: aForm [
]

{ #category : #'text input' }
OSBackendWindow >> isTextInputActive [
	^ self subclassResponsibility
]

{ #category : #testing }
OSBackendWindow >> isValid [
	self subclassResponsibility 
]

{ #category : #factory }
OSBackendWindow >> newFormRenderer: aForm [
	self subclassResponsibility
]

{ #category : #factory }
OSBackendWindow >> newGenericRenderer [
	self subclassResponsibility
]

{ #category : #accessing }
OSBackendWindow >> osWindow [
	
	^ osWindow
]

{ #category : #accessing }
OSBackendWindow >> osWindow: anObject [
	
	osWindow := anObject
]

{ #category : #accessing }
OSBackendWindow >> platformSpecificHandle [
	self subclassResponsibility
]

{ #category : #accessing }
OSBackendWindow >> position [
	^ self subclassResponsibility
]

{ #category : #accessing }
OSBackendWindow >> position: newPosition [
	self subclassResponsibility 
]

{ #category : #accessing }
OSBackendWindow >> prepareExternalResourceForAutoRelease [
	"This hook will allow just create handlers to prepate their external resources for being 
	 releases by the GC (if needed). By default, do nothing."
]

{ #category : #'mouse capture' }
OSBackendWindow >> releaseMouse [
]

{ #category : #accessing }
OSBackendWindow >> renderer [
	
	^ renderer
]

{ #category : #accessing }
OSBackendWindow >> renderer: anObject [
	
	renderer := anObject
]

{ #category : #accessing }
OSBackendWindow >> resizable [
	^ true
]

{ #category : #accessing }
OSBackendWindow >> resizable: aBoolean [
	
]

{ #category : #accessing }
OSBackendWindow >> screenScaleFactor [
	^ 1
]

{ #category : #accessing }
OSBackendWindow >> screenScaleFactorBaseDPI [
	^ OSPlatform current osWindowScreenScaleFactorBaseDPI
]

{ #category : #cursor }
OSBackendWindow >> setMouseCursor: cursorWithMask [
	self setMouseCursor: cursorWithMask mask: cursorWithMask maskForm
]

{ #category : #accessing }
OSBackendWindow >> setMouseCursor: cursor mask: mask [
]

{ #category : #accessing }
OSBackendWindow >> show [
	self subclassResponsibility 
]

{ #category : #'text input' }
OSBackendWindow >> startTextInput [
	self subclassResponsibility
]

{ #category : #'text input' }
OSBackendWindow >> stopTextInput [
	self subclassResponsibility
]

{ #category : #accessing }
OSBackendWindow >> title [
	self subclassResponsibility 
]

{ #category : #accessing }
OSBackendWindow >> title: aTitle [
	self subclassResponsibility 
]

{ #category : #accessing }
OSBackendWindow >> verticalDPI [
	^ self screenScaleFactorBaseDPI
]

{ #category : #accessing }
OSBackendWindow >> windowId [
	^ nil
]
