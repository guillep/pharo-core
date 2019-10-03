Class {
	#name : #Apple,
	#superclass : #Fruit,
	#instVars : [
		'color'
	],
	#category : #'Equals-Examples'
}

{ #category : #'instance creation' }
Apple class >> color: aColor [
	^self new
		color: aColor;
		yourself
]

{ #category : #accessing }
Apple >> color [
	^ color
]

{ #category : #accessing }
Apple >> color: anObject [
	color := anObject
]
