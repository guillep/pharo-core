Class {
	#name : #GTSpotterProcessorLink,
	#superclass : #DoubleLink,
	#instVars : [
		'headLink',
		'tailLink',
		'size'
	],
	#category : #'GT-Spotter-Utils'
}

{ #category : #accessing }
GTSpotterProcessorLink class >> from: aDoubleLink [

	
]

{ #category : #accessing }
GTSpotterProcessorLink >> asSpotterProcessorLink [

	^ self
]

{ #category : #actions }
GTSpotterProcessorLink >> clear [

	self
		headLink: nil;
		tailLink: nil.
		
	size := 0.
]

{ #category : #printing }
GTSpotterProcessorLink >> displayStringOn: stream [
	stream 
		nextPutAll: 'Processor link: ';
		nextPutAll: self processor title asString
]

{ #category : #printing }
GTSpotterProcessorLink >> gtDisplayOn: stream [
	stream 
		nextPutAll: 'Processor link: ';
		nextPutAll: self processor title asString
]

{ #category : #accessing }
GTSpotterProcessorLink >> headLink [
	^ headLink
]

{ #category : #accessing }
GTSpotterProcessorLink >> headLink: anObject [
	headLink := anObject
]

{ #category : #actions }
GTSpotterProcessorLink >> incrementSize [

	size := self size + 1
]

{ #category : #testing }
GTSpotterProcessorLink >> isEmpty [

	^ self headLink isNil
]

{ #category : #testing }
GTSpotterProcessorLink >> isFull [

	^ self size = self processor itemsLimit
]

{ #category : #accessing }
GTSpotterProcessorLink >> processor [

	^ self value
]

{ #category : #accessing }
GTSpotterProcessorLink >> size [

	^ size ifNil: [ size := 0 ]
]

{ #category : #accessing }
GTSpotterProcessorLink >> tailLink [
	^ tailLink
]

{ #category : #accessing }
GTSpotterProcessorLink >> tailLink: anObject [
	tailLink := anObject
]
