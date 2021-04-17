"
I am a basic class of OSEvent hierarchy.
The specific events are coming from operating system and converted to corresponding OSEvent subinstance(s) in order to handle them.

Events can implement a default action, which will be performed after dispatch on event handling,
unless they are suppressed using #suppressDefaultAction message.
"
Class {
	#name : #OSEvent,
	#superclass : #Object,
	#instVars : [
		'window',
		'suppressDefaultAction'
	],
	#category : #'OSWindow-Core-Events'
}

{ #category : #'instance creation' }
OSEvent class >> for: aWindow [
	^ self new window: aWindow; yourself
]

{ #category : #visitor }
OSEvent >> accept: aVisitor [
	self subclassResponsibility 
]

{ #category : #'default actions' }
OSEvent >> defaultAction [
	"do nothing by default"
]

{ #category : #dispatching }
OSEvent >> deliver [
	"deliver an event to its handler(s)"
	
	^ window deliverEvent: self
]

{ #category : #initialization }
OSEvent >> initialize [
	suppressDefaultAction := false
]

{ #category : #'default actions' }
OSEvent >> performDefaultAction [
	suppressDefaultAction ifFalse: [  self defaultAction ]
]

{ #category : #printing }
OSEvent >> printOn: aStream [
	super printOn: aStream. 
	window ifNotNil: [ 
		aStream 
			nextPutAll:  ' (WindowId='; 
			print: window windowId;  
			nextPut:  $) ]

]

{ #category : #'default actions' }
OSEvent >> suppressDefaultAction [ 
	suppressDefaultAction  := true
]

{ #category : #accessing }
OSEvent >> window [
	^ window
]

{ #category : #accessing }
OSEvent >> window: anOSWindow [ 
	window := anOSWindow
]
