"
This processor adds the ability of computing and caching all possible candidates. It is useful when we know all candidates upfront.
"
Class {
	#name : #GTSpotterCandidatesProcessor,
	#superclass : #GTSpotterPragmaBasedProcessor,
	#instVars : [
		'origin',
		'allCandidates'
	],
	#category : #'GT-Spotter-Pragma-Based-Processors'
}

{ #category : #'instance creation' }
GTSpotterCandidatesProcessor class >> on: anObject [

	^ self new origin: anObject
]

{ #category : #compatibility }
GTSpotterCandidatesProcessor >> allCandidatesIn: aContext [
	^ self allItemsIn: aContext
]

{ #category : #public }
GTSpotterCandidatesProcessor >> allItemsIn: aContext [

	^ allCandidates ifNil: [ allCandidates := (self computeAllItemsIn: aContext) copy ].
]

{ #category : #compatibility }
GTSpotterCandidatesProcessor >> candidatesLimit [
	^ self itemsLimit
]

{ #category : #private }
GTSpotterCandidatesProcessor >> computeAllItemsIn: aContext [

	^ OrderedCollection new
	
]

{ #category : #compatibility }
GTSpotterCandidatesProcessor >> computeCandidatesIn: aContext [

	^ self computeAllItemsIn: aContext
]

{ #category : #private }
GTSpotterCandidatesProcessor >> continueItemsLimit [
	^ (self defaultContinueItemsLimit - self itemsLimit) max: 0
]

{ #category : #private }
GTSpotterCandidatesProcessor >> doFilterInContext: aSpotterContext [
	^ aSpotterContext doFilter: GTFilterBlock gtFilter forProcessor: self
]

{ #category : #private }
GTSpotterCandidatesProcessor >> itemFilterNameFor: anObject [
	^ self itemNameFor: anObject
]

{ #category : #private }
GTSpotterCandidatesProcessor >> itemIconFor: anObject [
	^ nil
]

{ #category : #private }
GTSpotterCandidatesProcessor >> itemNameFor: anObject [
	^ anObject displayString
]

{ #category : #accessing }
GTSpotterCandidatesProcessor >> itemsLimit [
	"Return the maximal number of elements that can be found during search.
	Default implementation returns infinity, so the number of element is not limited."
	^ Float infinity
]

{ #category : #accessing }
GTSpotterCandidatesProcessor >> origin [

	^ origin
]

{ #category : #accessing }
GTSpotterCandidatesProcessor >> origin: anObject [

	origin := anObject
]

{ #category : #private }
GTSpotterCandidatesProcessor >> prepareProcessorInContext: aContext [
	super prepareProcessorInContext: aContext.
	
	self hasDynamicItems ifTrue: [ allCandidates := nil ]
]

{ #category : #accessing }
GTSpotterCandidatesProcessor >> title [
	^ 'undefined'
]
