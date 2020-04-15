Class {
	#name : #EqApple,
	#superclass : #EqFruit,
	#instVars : [
		'color'
	],
	#category : #'Equals-Examples'
}

{ #category : #'instance creation' }
EqApple class >> color: aColor [
	^self new
		color: aColor;
		yourself
]

{ #category : #accessing }
EqApple >> color [
	^ color
]

{ #category : #accessing }
EqApple >> color: anObject [
	color := anObject
]
