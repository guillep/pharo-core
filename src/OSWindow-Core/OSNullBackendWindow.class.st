"
i am a handle for null window , created using OSNullWindowDriver.
"
Class {
	#name : #OSNullBackendWindow,
	#superclass : #OSBackendWindow,
	#instVars : [
		'attributes',
		'isTextInputActive'
	],
	#category : #'OSWindow-Core-Utilities'
}

{ #category : #'instance creation' }
OSNullBackendWindow class >> fromAttributes: attributes for: anOSWindow [ 
	^ self new attributes: attributes
]

{ #category : #accessing }
OSNullBackendWindow >> attributes: newAttributes [
	attributes := newAttributes
]

{ #category : #accessing }
OSNullBackendWindow >> bounds: aRectangle [
]

{ #category : #accessing }
OSNullBackendWindow >> clipboardText [
	^ ''
]

{ #category : #accessing }
OSNullBackendWindow >> clipboardText: anObject [

]

{ #category : #initialize }
OSNullBackendWindow >> destroy [
]

{ #category : #accessing }
OSNullBackendWindow >> extent [
	^ attributes extent
]

{ #category : #accessing }
OSNullBackendWindow >> extent: newExtent [
	attributes extent: newExtent
]

{ #category : #accessing }
OSNullBackendWindow >> hide [
]

{ #category : #initialization }
OSNullBackendWindow >> initialize [
	super initialize.
	
	isTextInputActive := false
]

{ #category : #'text input' }
OSNullBackendWindow >> isTextInputActive [
	^ isTextInputActive
]

{ #category : #accessing }
OSNullBackendWindow >> isValid [
	^ true
]

{ #category : #factory }
OSNullBackendWindow >> newAthensRenderer [
	self subclassResponsibility
]

{ #category : #factory }
OSNullBackendWindow >> newFormRenderer: form [
	^ renderer := OSNullFormRenderer new form: form
]

{ #category : #factory }
OSNullBackendWindow >> newGenericRenderer [
	^ renderer := OSWindowNullGenericRenderer new
]

{ #category : #factory }
OSNullBackendWindow >> newOpenGLRenderer [
	self subclassResponsibility
]

{ #category : #accessing }
OSNullBackendWindow >> platformSpecificHandle [
	^ nil
]

{ #category : #accessing }
OSNullBackendWindow >> position [
	^ attributes position
]

{ #category : #accessing }
OSNullBackendWindow >> position: position [
	attributes position: position
]

{ #category : #accessing }
OSNullBackendWindow >> show [
]

{ #category : #'text input' }
OSNullBackendWindow >> startTextInput [
	isTextInputActive := true
]

{ #category : #'text input' }
OSNullBackendWindow >> stopTextInput [
	isTextInputActive := false
]

{ #category : #accessing }
OSNullBackendWindow >> title [
	^attributes title
]

{ #category : #accessing }
OSNullBackendWindow >> title: anObject [
]
