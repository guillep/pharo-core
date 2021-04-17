"
Superclass of all scrolls events
"
Class {
	#name : #OSTouchScrollEvent,
	#superclass : #OSTouchComplexEvent,
	#instVars : [
		'dDist',
		'direction'
	],
	#category : #'OSWindow-Core-Events-Touch'
}

{ #category : #accessing }
OSTouchScrollEvent class >> id [
	^ #scroll
]

{ #category : #accessing }
OSTouchScrollEvent >> dDist [
	^ dDist
]

{ #category : #accessing }
OSTouchScrollEvent >> dDist: anObject [
	dDist := anObject
]

{ #category : #accessing }
OSTouchScrollEvent >> direction [
	^ direction
]

{ #category : #accessing }
OSTouchScrollEvent >> direction: anObject [
	direction := anObject
]
