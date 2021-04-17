Class {
	#name : #StSpotterProcessorLink,
	#superclass : #DoubleLink,
	#instVars : [
		'headLink',
		'tailLink',
		'size'
	],
	#category : #'NewTools-Spotter-Model'
}

{ #category : #accessing }
StSpotterProcessorLink class >> from: aDoubleLink [

	
]

{ #category : #accessing }
StSpotterProcessorLink >> asStSpotterProcessorLink [

	^ self
]

{ #category : #actions }
StSpotterProcessorLink >> clear [

	self
		headLink: nil;
		tailLink: nil.
		
	size := 0.
]

{ #category : #printing }
StSpotterProcessorLink >> displayStringOn: stream [
	stream 
		nextPutAll: 'Processor link: ';
		nextPutAll: self processor title asString
]

{ #category : #printing }
StSpotterProcessorLink >> gtDisplayOn: stream [
	stream 
		nextPutAll: 'Processor link: ';
		nextPutAll: self processor title asString
]

{ #category : #accessing }
StSpotterProcessorLink >> headLink [
	^ headLink
]

{ #category : #accessing }
StSpotterProcessorLink >> headLink: anObject [
	headLink := anObject
]

{ #category : #actions }
StSpotterProcessorLink >> incrementSize [

	size := self size + 1
]

{ #category : #testing }
StSpotterProcessorLink >> isEmpty [

	^ self headLink isNil
]

{ #category : #testing }
StSpotterProcessorLink >> isFull [

	^ self size = self processor itemsLimit
]

{ #category : #accessing }
StSpotterProcessorLink >> processor [

	^ self value
]

{ #category : #accessing }
StSpotterProcessorLink >> size [

	^ size ifNil: [ size := 0 ]
]

{ #category : #accessing }
StSpotterProcessorLink >> tailLink [
	^ tailLink
]

{ #category : #accessing }
StSpotterProcessorLink >> tailLink: anObject [
	tailLink := anObject
]
