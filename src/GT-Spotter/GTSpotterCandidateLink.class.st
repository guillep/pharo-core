Class {
	#name : #GTSpotterCandidateLink,
	#superclass : #DoubleLink,
	#instVars : [
		'processorLink',
		'weight',
		'renderingProcessorLink'
	],
	#category : #'GT-Spotter-Utils'
}

{ #category : #comparing }
GTSpotterCandidateLink >> < anotherCandidateLink [

	^ self weight < anotherCandidateLink weight
]

{ #category : #comparing }
GTSpotterCandidateLink >> > anotherCandidateLink [

	^ self weight > anotherCandidateLink weight
]

{ #category : #converting }
GTSpotterCandidateLink >> asSpotterCandidateLink [

	^ self
]

{ #category : #accessing }
GTSpotterCandidateLink >> candidate [
	^ self value
]

{ #category : #copying }
GTSpotterCandidateLink >> copy [
	|link|
	link := self class value: self value.
	link privateProcessorLink: processorLink.
	link privateRenderingProcessorLink: renderingProcessorLink.
	link weight: weight.
	^ link
]

{ #category : #printing }
GTSpotterCandidateLink >> displayStringOn: stream [
	stream nextPutAll: 'Candidate link: '.
	self value displayStringOn: stream 
]

{ #category : #printing }
GTSpotterCandidateLink >> gtDisplayOn: stream [
	stream nextPutAll: 'Candidate link: '.
	self value displayStringOn: stream 
]

{ #category : #testing }
GTSpotterCandidateLink >> isFirst [

	^ (self previousLink processorLink = self processorLink) not
]

{ #category : #accessing }
GTSpotterCandidateLink >> next [
	^ self nextLink
]

{ #category : #accessing }
GTSpotterCandidateLink >> previous [
	^ self previousLink
]

{ #category : #private }
GTSpotterCandidateLink >> privateProcessorLink: aLink [

	processorLink := aLink
]

{ #category : #private }
GTSpotterCandidateLink >> privateRenderingProcessorLink: aLink [

	renderingProcessorLink := aLink
]

{ #category : #accessing }
GTSpotterCandidateLink >> processor [

	^ self processorLink value
]

{ #category : #accessing }
GTSpotterCandidateLink >> processorLink [
	^ processorLink
]

{ #category : #accessing }
GTSpotterCandidateLink >> processorLink: anObject [

	"we set rendering processor only if one is not set. it allows to have a collection of items,
	that have different rendering processors"
	
	processorLink ifNil: [ self renderingProcessor: anObject ].
	processorLink := anObject.
	
]

{ #category : #accessing }
GTSpotterCandidateLink >> renderingProcessor [

	renderingProcessorLink ifNil: [ self renderingProcessor: processorLink ].
	^ renderingProcessorLink value
]

{ #category : #accessing }
GTSpotterCandidateLink >> renderingProcessor: aProcessorLink [

	renderingProcessorLink ifNil: [ renderingProcessorLink := aProcessorLink processor asSpotterProcessorLink ].
	processorLink ifNil: [ processorLink := aProcessorLink ]
]

{ #category : #accessing }
GTSpotterCandidateLink >> weight [

	^ weight
]

{ #category : #accessing }
GTSpotterCandidateLink >> weight: anObject [ 

	weight := anObject
]
