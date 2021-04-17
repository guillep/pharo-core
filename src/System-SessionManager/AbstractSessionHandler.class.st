"
API  to manage startup and shutdown of a session.
On startup, isImageStarting indicates wheter the image is starting or just resuming from a save.
On shutdown, isQuitting indicates if we save and quit the image  or if we just save  the image.  
"
Class {
	#name : #AbstractSessionHandler,
	#superclass : #Object,
	#category : #'System-SessionManager-Handlers'
}

{ #category : #testing }
AbstractSessionHandler class >> isAbstract [ 
	
	^self == AbstractSessionHandler
]

{ #category : #accessing }
AbstractSessionHandler >> handledId [
	self subclassResponsibility
]

{ #category : #printing }
AbstractSessionHandler >> printOn: aStream [
	super printOn: aStream.
	aStream 
		nextPut: $(;
		nextPutAll: self handledId;
		nextPut: $)
]

{ #category : #handlers }
AbstractSessionHandler >> shutdown: isImageQuitting [
	self subclassResponsibility
]

{ #category : #handlers }
AbstractSessionHandler >> startup: isImageStarting [
	self subclassResponsibility
]
