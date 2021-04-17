Class {
	#name : #GTMockCandidatesList,
	#superclass : #Object,
	#instVars : [
		'results',
		'totalResults'
	],
	#category : #'GT-Tests-Spotter-Processors'
}

{ #category : #adding }
GTMockCandidatesList >> addAllCandidates: aCollection in: aProcessor [

	results removeAll.
	results addAll: aCollection
]

{ #category : #adding }
GTMockCandidatesList >> addCandidate: anEntry in: aProcessor [

	results add: anEntry 
	
	
]

{ #category : #adding }
GTMockCandidatesList >> addObject: anObject inProcessor: aProcessor [

	results add: anObject
]

{ #category : #adding }
GTMockCandidatesList >> addObjects: aCollection inProcessor: aProcessor [

	results addAll: aCollection
]

{ #category : #adding }
GTMockCandidatesList >> initialize [ 
	
	super initialize.
	results := OrderedCollection new
]

{ #category : #adding }
GTMockCandidatesList >> onAmountChanged: aQuantity in: processor [

	totalResults := aQuantity
]

{ #category : #events }
GTMockCandidatesList >> processorEnded: aSptClassProcessor [ 

	
]

{ #category : #events }
GTMockCandidatesList >> processorStarted: aSptClassProcessor [ 
	
	
]

{ #category : #accessing }
GTMockCandidatesList >> reset [
	
	results removeAll.
	totalResults := 0.
]

{ #category : #accessing }
GTMockCandidatesList >> results [
	^ results
]
