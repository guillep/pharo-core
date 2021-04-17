"
I am a handler who can manage gestures and provide them informations on past and current touch events
"
Class {
	#name : #OSWindowGestureHandler,
	#superclass : #OSWindowEventGestureVisitor,
	#instVars : [
		'fingers',
		'fingerCount',
		'registeredGestures',
		'devicesFingers',
		'lastUpdateTimestamp'
	],
	#category : #'OSWindow-Core-Gestures'
}

{ #category : #accessing }
OSWindowGestureHandler >> fingerCount [
	^ fingerCount
]

{ #category : #accessing }
OSWindowGestureHandler >> fingerCount: anObject [
	fingerCount := anObject
]

{ #category : #accessing }
OSWindowGestureHandler >> fingers [
	^ fingers
]

{ #category : #accessing }
OSWindowGestureHandler >> fingersFromDevice: id [
	^ devicesFingers at: id ifAbsent: [ ^ fingers values ]
]

{ #category : #events }
OSWindowGestureHandler >> handleGestureEvent: anEvent [
	self handleEvent: anEvent.
	
	"Notifying gestures"
	self sendEventToGestures: anEvent
]

{ #category : #initialization }
OSWindowGestureHandler >> initialize [
	registeredGestures := OrderedCollection new.
	devicesFingers := Dictionary new.
	fingers := Dictionary new.
	fingerCount := 0.
]

{ #category : #accessing }
OSWindowGestureHandler >> lastUpdateTimestamp [
	^ lastUpdateTimestamp
]

{ #category : #accessing }
OSWindowGestureHandler >> lastUpdateTimestamp: anObject [ 
	lastUpdateTimestamp := anObject 
]

{ #category : #'detector registering' }
OSWindowGestureHandler >> registerGesture: aGesture [
	registeredGestures add: aGesture.
	aGesture eventHandler: self
]

{ #category : #events }
OSWindowGestureHandler >> sendEventToGestures: anEvent [
	registeredGestures
		do: [ :gesture | gesture handleEvent: anEvent ]
]

{ #category : #'handling fingers' }
OSWindowGestureHandler >> trackFinger: anEvent [
	| newFingerTracker |
	"Creating a new finger tracker"
	newFingerTracker := OSTouchFingerTracker for: anEvent.
	
	"Registering it in the right places"
	fingers at: anEvent fingerId put: newFingerTracker.
	(devicesFingers at: anEvent deviceId ifAbsentPut: [ OrderedCollection new ]) add: newFingerTracker.
	
	^ newFingerTracker
]

{ #category : #'detector registering' }
OSWindowGestureHandler >> unregisterGesture: anOSTouchGesture [
	registeredGestures remove: anOSTouchGesture 
]

{ #category : #'handling fingers' }
OSWindowGestureHandler >> untrackFinger: anEvent [
	| removedTracker |
	fingerCount := fingerCount - 1.
	removedTracker := fingers removeKey: anEvent fingerId ifAbsent: [ ^ self ].
	(devicesFingers at: anEvent deviceId) remove: removedTracker.
]

{ #category : #'handling fingers' }
OSWindowGestureHandler >> updateGesturesActiveFingers [
	registeredGestures do: [ :gesture | gesture activeFingers: (self fingersFromDevice: gesture deviceId) ]
]

{ #category : #visiting }
OSWindowGestureHandler >> visitTouchPointerDownEvent: anEvent [
	self trackFinger: anEvent.
	
	"Updating informations"
	fingerCount := fingerCount + 1 .
	lastUpdateTimestamp := anEvent timestamp.
	
	self updateGesturesActiveFingers.
	
	self sendEventToGestures: anEvent.
	
	self visitTouchActionPointerDownEvent: anEvent
]

{ #category : #visiting }
OSWindowGestureHandler >> visitTouchPointerMoveEvent: anEvent [
	| fingerTracker |
	fingerTracker := fingers at: anEvent fingerId ifAbsent: [ self trackFinger: anEvent].

	fingerTracker updateWithEvent: anEvent.
	lastUpdateTimestamp := anEvent timestamp.
	
	self sendEventToGestures: anEvent.

	self visitTouchActionPointerMoveEvent: anEvent
]

{ #category : #visiting }
OSWindowGestureHandler >> visitTouchPointerUpEvent: anEvent [
	self untrackFinger: anEvent.
	lastUpdateTimestamp := anEvent timestamp.
	self updateGesturesActiveFingers.
	self sendEventToGestures: anEvent.
	self visitTouchActionPointerUpEvent: anEvent
]
