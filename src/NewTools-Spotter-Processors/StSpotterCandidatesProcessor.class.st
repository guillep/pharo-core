Class {
	#name : #StSpotterCandidatesProcessor,
	#superclass : #StSpotterPragmaBasedProcessor,
	#instVars : [
		'origin',
		'allCandidates'
	],
	#category : #'NewTools-Spotter-Processors'
}

{ #category : #'instance creation' }
StSpotterCandidatesProcessor class >> on: anObject [

	^ self new origin: anObject
]

{ #category : #compatibility }
StSpotterCandidatesProcessor >> allCandidatesIn: aContext [
	^ self allItemsIn: aContext
]

{ #category : #public }
StSpotterCandidatesProcessor >> allItemsIn: aContext [

	^ allCandidates ifNil: [ allCandidates := (self computeAllItemsIn: aContext) copy ].
]

{ #category : #compatibility }
StSpotterCandidatesProcessor >> candidatesLimit [
	^ self itemsLimit
]

{ #category : #private }
StSpotterCandidatesProcessor >> computeAllItemsIn: aContext [

	^ OrderedCollection new
	
]

{ #category : #compatibility }
StSpotterCandidatesProcessor >> computeCandidatesIn: aContext [

	^ self computeAllItemsIn: aContext
]

{ #category : #private }
StSpotterCandidatesProcessor >> continueItemsLimit [
	^ (self defaultContinueItemsLimit - self itemsLimit) max: 0
]

{ #category : #private }
StSpotterCandidatesProcessor >> doFilterInContext: aSpotterContext [

	^ aSpotterContext 
		doFilter: StFilterBlock stFilter 
		forProcessor: self
]

{ #category : #private }
StSpotterCandidatesProcessor >> itemFilterNameFor: anObject [
	^ self itemNameFor: anObject
]

{ #category : #private }
StSpotterCandidatesProcessor >> itemIconFor: anObject [
	^ nil
]

{ #category : #private }
StSpotterCandidatesProcessor >> itemNameFor: anObject [
	^ anObject displayString
]

{ #category : #accessing }
StSpotterCandidatesProcessor >> itemsLimit [
	"Return the maximal number of elements that can be found during search.
	Default implementation returns infinity, so the number of element is not limited."
	^ Float infinity
]

{ #category : #accessing }
StSpotterCandidatesProcessor >> origin [

	^ origin
]

{ #category : #accessing }
StSpotterCandidatesProcessor >> origin: anObject [

	origin := anObject
]

{ #category : #private }
StSpotterCandidatesProcessor >> prepareProcessorInContext: aContext [
	super prepareProcessorInContext: aContext.
	
	self hasDynamicItems ifTrue: [ allCandidates := nil ]
]

{ #category : #accessing }
StSpotterCandidatesProcessor >> title [
	^ 'undefined'
]
