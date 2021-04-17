Class {
	#name : #StMockCandidatesList,
	#superclass : #Object,
	#instVars : [
		'results',
		'totalResults'
	],
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #adding }
StMockCandidatesList >> addAllCandidates: aCollection in: aProcessor [

	results removeAll.
	results addAll: aCollection
]

{ #category : #adding }
StMockCandidatesList >> addCandidate: anEntry in: aProcessor [

	results add: anEntry 
	
	
]

{ #category : #adding }
StMockCandidatesList >> addObject: anObject inProcessor: aProcessor [

	results add: anObject
]

{ #category : #adding }
StMockCandidatesList >> addObjects: aCollection inProcessor: aProcessor [

	results addAll: aCollection
]

{ #category : #adding }
StMockCandidatesList >> initialize [ 
	
	super initialize.
	results := OrderedCollection new
]

{ #category : #adding }
StMockCandidatesList >> onAmountChanged: aQuantity in: processor [

	totalResults := aQuantity
]

{ #category : #events }
StMockCandidatesList >> processorEnded: aSptClassProcessor [ 

	
]

{ #category : #events }
StMockCandidatesList >> processorStarted: aSptClassProcessor [ 
	
	
]

{ #category : #accessing }
StMockCandidatesList >> reset [
	
	results removeAll.
	totalResults := 0.
]

{ #category : #accessing }
StMockCandidatesList >> results [
	^ results
]
