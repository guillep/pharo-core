"
Superclass of all rotation events
"
Class {
	#name : #OSTouchRotationEvent,
	#superclass : #OSTouchComplexEvent,
	#instVars : [
		'dTheta'
	],
	#category : #'OSWindow-Core-Events-Touch'
}

{ #category : #accessing }
OSTouchRotationEvent class >> id [
	^ #rotate
]

{ #category : #accessing }
OSTouchRotationEvent >> dTheta [
	^ dTheta
]

{ #category : #accessing }
OSTouchRotationEvent >> dTheta: anObject [
	dTheta := anObject
]
