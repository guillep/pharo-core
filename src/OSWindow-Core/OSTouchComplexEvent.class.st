"
I am a touch event composed by several others basic events. 

"
Class {
	#name : #OSTouchComplexEvent,
	#superclass : #OSTouchEvent,
	#instVars : [
		'position'
	],
	#category : #'OSWindow-Core-Events-Touch'
}

{ #category : #accessing }
OSTouchComplexEvent class >> id [
	^ #default
]

{ #category : #accessing }
OSTouchComplexEvent >> position [
	^ position
]

{ #category : #accessing }
OSTouchComplexEvent >> position: anObject [
	position := anObject
]
