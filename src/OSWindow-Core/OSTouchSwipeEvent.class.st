"
Superclass of all swipes events
"
Class {
	#name : #OSTouchSwipeEvent,
	#superclass : #OSTouchComplexEvent,
	#instVars : [
		'dDist',
		'direction'
	],
	#category : #'OSWindow-Core-Events-Touch'
}

{ #category : #accessing }
OSTouchSwipeEvent class >> id [
	^ #swipe
]

{ #category : #accessing }
OSTouchSwipeEvent >> dDist [
	^ dDist
]

{ #category : #accessing }
OSTouchSwipeEvent >> dDist: anObject [
	dDist := anObject
]

{ #category : #accessing }
OSTouchSwipeEvent >> direction [
	^ direction
]

{ #category : #accessing }
OSTouchSwipeEvent >> direction: anObject [
	direction := anObject
]
