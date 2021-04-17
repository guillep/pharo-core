Class {
	#name : #StSpotterCandidateLink,
	#superclass : #DoubleLink,
	#instVars : [
		'processorLink',
		'weight',
		'renderingProcessorLink'
	],
	#category : #'NewTools-Spotter-Model'
}

{ #category : #comparing }
StSpotterCandidateLink >> < anotherCandidateLink [

	^ self weight < anotherCandidateLink weight
]

{ #category : #comparing }
StSpotterCandidateLink >> > anotherCandidateLink [

	^ self weight > anotherCandidateLink weight
]

{ #category : #converting }
StSpotterCandidateLink >> asStSpotterCandidateLink [

	^ self
]

{ #category : #accessing }
StSpotterCandidateLink >> candidate [
	^ self value
]

{ #category : #copying }
StSpotterCandidateLink >> copy [
	| link |
	
	link := self class value: self value.
	link privateProcessorLink: processorLink.
	link privateRenderingProcessorLink: renderingProcessorLink.
	link weight: weight.
	
	^ link
]

{ #category : #printing }
StSpotterCandidateLink >> displayStringOn: stream [

	stream nextPutAll: 'Candidate link: '.
	self value displayStringOn: stream 
]

{ #category : #printing }
StSpotterCandidateLink >> gtDisplayOn: stream [

	stream nextPutAll: 'Candidate link: '.
	self value displayStringOn: stream 
]

{ #category : #testing }
StSpotterCandidateLink >> isFirst [

	^ self previousLink processorLink ~= self processorLink
]

{ #category : #accessing }
StSpotterCandidateLink >> next [
	^ self nextLink
]

{ #category : #accessing }
StSpotterCandidateLink >> previous [
	^ self previousLink
]

{ #category : #private }
StSpotterCandidateLink >> privateProcessorLink: aLink [

	processorLink := aLink
]

{ #category : #private }
StSpotterCandidateLink >> privateRenderingProcessorLink: aLink [

	renderingProcessorLink := aLink
]

{ #category : #accessing }
StSpotterCandidateLink >> processor [

	^ self processorLink value
]

{ #category : #accessing }
StSpotterCandidateLink >> processorLink [
	^ processorLink
]

{ #category : #accessing }
StSpotterCandidateLink >> processorLink: anObject [

	"we set rendering processor only if one is not set. it allows to have a collection of items,
	that have different rendering processors"
	
	processorLink ifNil: [ self renderingProcessor: anObject ].
	processorLink := anObject.
	
]

{ #category : #accessing }
StSpotterCandidateLink >> renderingProcessor [

	renderingProcessorLink ifNil: [ self renderingProcessor: processorLink ].
	^ renderingProcessorLink value
]

{ #category : #accessing }
StSpotterCandidateLink >> renderingProcessor: aProcessorLink [

	renderingProcessorLink ifNil: [ 
		renderingProcessorLink := aProcessorLink processor asStSpotterProcessorLink ].
	processorLink ifNil: [ processorLink := aProcessorLink ]
]

{ #category : #accessing }
StSpotterCandidateLink >> weight [

	^ weight
]

{ #category : #accessing }
StSpotterCandidateLink >> weight: anObject [ 

	weight := anObject
]
