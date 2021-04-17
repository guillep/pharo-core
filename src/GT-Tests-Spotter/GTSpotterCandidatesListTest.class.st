Class {
	#name : #GTSpotterCandidatesListTest,
	#superclass : #TestCase,
	#instVars : [
		'candidates'
	],
	#category : #'GT-Tests-Spotter'
}

{ #category : #accessing }
GTSpotterCandidatesListTest >> addCategories: aCollection [

	aCollection do: [ :each | candidates addProcessor: each ]
]

{ #category : #testing }
GTSpotterCandidatesListTest >> hasCategories: aCollection [
	|counter|
	candidates processors asArray size = aCollection size ifFalse: [ ^ false ].
	counter := 1.
	candidates processors asArray
		do: [ :each | (each = (aCollection at: counter)) ifFalse: [ ^ false ] . counter := counter + 1].
	^ true
]

{ #category : #running }
GTSpotterCandidatesListTest >> setUp [
	super setUp.
	candidates := GTSpotterCandidatesList new.
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testAddCategories [
	|categories|
	categories := { GTSpotterA1 . GTSpotterA2 . GTSpotterA3 }.
	
	self addCategories: categories.
	self assert: (self hasCategories: categories)
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testAddOneCandidateA1 [
	| link category |
	category := candidates addProcessor: GTSpotterA1.
	link := candidates addCandidate: 11 in: GTSpotterA1.

	self assert: link nextLink equals: link.
	self assert: link previousLink equals: link.
	self assert: candidates head equals: link.
	self assert: candidates tail equals: link.
	self assert: category headLink equals: link.
	self assert: category tailLink equals: link
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testAddOneCandidateA1A2 [
	| link11 link21 category1 category2 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.
	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link21 := candidates addCandidate: 21 in: GTSpotterA2.

	self assert: link11 nextLink equals: link21.
	self assert: link11 previousLink equals: link21.

	self assert: link21 nextLink equals: link11.
	self assert: link21 previousLink equals: link11.

	self assert: candidates head equals: link11.
	self assert: candidates tail equals: link21.

	self assert: category1 headLink equals: link11.
	self assert: category1 tailLink equals: link11.

	self assert: category2 headLink equals: link21.
	self assert: category2 tailLink equals: link21
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testAddOneCandidateA1A2A3 [
	| link11 link21 link31 category1 category2 category3 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.
	category3 := candidates addProcessor: GTSpotterA3.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link21 := candidates addCandidate: 21 in: GTSpotterA2.
	link31 := candidates addCandidate: 31 in: GTSpotterA3.

	self assert: link11 nextLink equals: link21.
	self assert: link11 previousLink equals: link31.

	self assert: link21 nextLink equals: link31.
	self assert: link21 previousLink equals: link11.

	self assert: link31 nextLink equals: link11.
	self assert: link31 previousLink equals: link21.

	self assert: candidates head equals: link11.
	self assert: candidates tail equals: link31.

	self assert: category1 headLink equals: link11.
	self assert: category1 tailLink equals: link11.

	self assert: category2 headLink equals: link21.
	self assert: category2 tailLink equals: link21.

	self assert: category3 headLink equals: link31.
	self assert: category3 tailLink equals: link31
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testAddThreeCandidateA1 [
	| link1 link2 link3 category |
	category := candidates addProcessor: GTSpotterA1.
	link1 := candidates addCandidate: 11 in: GTSpotterA1.
	link2 := candidates addCandidate: 12 in: GTSpotterA1.
	link3 := candidates addCandidate: 13 in: GTSpotterA1.

	self assert: link1 nextLink equals: link2.
	self assert: link1 previousLink equals: link3.

	self assert: link2 nextLink equals: link3.
	self assert: link2 previousLink equals: link1.

	self assert: link3 nextLink equals: link1.
	self assert: link3 previousLink equals: link2.

	self assert: candidates head equals: link1.
	self assert: candidates tail equals: link3.
	self assert: category headLink equals: link1.
	self assert: category tailLink equals: link3
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testAddThreeCandidateA1A2 [
	| link11 link12 link13 link21 link22 link23 category1 category2 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link13 := candidates addCandidate: 13 in: GTSpotterA1.
	link21 := candidates addCandidate: 21 in: GTSpotterA2.
	link22 := candidates addCandidate: 22 in: GTSpotterA2.
	link23 := candidates addCandidate: 23 in: GTSpotterA2.

	self assert: link11 nextLink equals: link12.
	self assert: link11 previousLink equals: link23.

	self assert: link12 nextLink equals: link13.
	self assert: link12 previousLink equals: link11.

	self assert: link13 nextLink equals: link21.
	self assert: link13 previousLink equals: link12.

	self assert: link21 nextLink equals: link22.
	self assert: link21 previousLink equals: link13.

	self assert: link22 nextLink equals: link23.
	self assert: link22 previousLink equals: link21.

	self assert: link23 nextLink equals: link11.
	self assert: link23 previousLink equals: link22.

	self assert: candidates head equals: link11.
	self assert: candidates tail equals: link23.

	self assert: category1 headLink equals: link11.
	self assert: category1 tailLink equals: link13.

	self assert: category2 headLink equals: link21.
	self assert: category2 tailLink equals: link23
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testAddThreeCandidateA1A2A3 [
	| link11 link12 link13 link21 link22 link23 link31 link32 link33 category1 category2 category3 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.
	category3 := candidates addProcessor: GTSpotterA3.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link13 := candidates addCandidate: 13 in: GTSpotterA1.
	link21 := candidates addCandidate: 21 in: GTSpotterA2.
	link22 := candidates addCandidate: 22 in: GTSpotterA2.
	link23 := candidates addCandidate: 23 in: GTSpotterA2.
	link31 := candidates addCandidate: 31 in: GTSpotterA3.
	link32 := candidates addCandidate: 32 in: GTSpotterA3.
	link33 := candidates addCandidate: 33 in: GTSpotterA3.

	self assert: link11 nextLink equals: link12.
	self assert: link11 previousLink equals: link33.

	self assert: link12 nextLink equals: link13.
	self assert: link12 previousLink equals: link11.

	self assert: link13 nextLink equals: link21.
	self assert: link13 previousLink equals: link12.

	self assert: link21 nextLink equals: link22.
	self assert: link21 previousLink equals: link13.

	self assert: link22 nextLink equals: link23.
	self assert: link22 previousLink equals: link21.

	self assert: link23 nextLink equals: link31.
	self assert: link23 previousLink equals: link22.

	self assert: link31 nextLink equals: link32.
	self assert: link31 previousLink equals: link23.

	self assert: link32 nextLink equals: link33.
	self assert: link32 previousLink equals: link31.

	self assert: link33 nextLink equals: link11.
	self assert: link33 previousLink equals: link32.

	self assert: candidates head equals: link11.
	self assert: candidates tail equals: link33.

	self assert: category1 headLink equals: link11.
	self assert: category1 tailLink equals: link13.

	self assert: category2 headLink equals: link21.
	self assert: category2 tailLink equals: link23.

	self assert: category3 headLink equals: link31.
	self assert: category3 tailLink equals: link33
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testAddThreeCandidateA1A2A3Shuffled [
	| link11 link12 link13 link21 link22 link23 link31 link32 link33 category1 category2 category3 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.
	category3 := candidates addProcessor: GTSpotterA3.

	link21 := candidates addCandidate: 21 in: GTSpotterA2.
	link22 := candidates addCandidate: 22 in: GTSpotterA2.
	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link31 := candidates addCandidate: 31 in: GTSpotterA3.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link32 := candidates addCandidate: 32 in: GTSpotterA3.
	link23 := candidates addCandidate: 23 in: GTSpotterA2.
	link33 := candidates addCandidate: 33 in: GTSpotterA3.
	link13 := candidates addCandidate: 13 in: GTSpotterA1.

	self assert: link11 nextLink equals: link12.
	self assert: link11 previousLink equals: link33.

	self assert: link12 nextLink equals: link13.
	self assert: link12 previousLink equals: link11.

	self assert: link13 nextLink equals: link21.
	self assert: link13 previousLink equals: link12.

	self assert: link21 nextLink equals: link22.
	self assert: link21 previousLink equals: link13.

	self assert: link22 nextLink equals: link23.
	self assert: link22 previousLink equals: link21.

	self assert: link23 nextLink equals: link31.
	self assert: link23 previousLink equals: link22.

	self assert: link31 nextLink equals: link32.
	self assert: link31 previousLink equals: link23.

	self assert: link32 nextLink equals: link33.
	self assert: link32 previousLink equals: link31.

	self assert: link33 nextLink equals: link11.
	self assert: link33 previousLink equals: link32.

	self assert: candidates head equals: link11.
	self assert: candidates tail equals: link33.

	self assert: category1 headLink equals: link11.
	self assert: category1 tailLink equals: link13.

	self assert: category2 headLink equals: link21.
	self assert: category2 tailLink equals: link23.

	self assert: category3 headLink equals: link31.
	self assert: category3 tailLink equals: link33
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testAddTwoCandidateA1 [
	| link1 link2 category |
	category := candidates addProcessor: GTSpotterA1.
	link1 := candidates addCandidate: 11 in: GTSpotterA1.
	link2 := candidates addCandidate: 12 in: GTSpotterA1.

	self assert: link1 nextLink equals: link2.
	self assert: link1 previousLink equals: link2.

	self assert: link2 nextLink equals: link1.
	self assert: link2 previousLink equals: link1.

	self assert: candidates head equals: link1.
	self assert: candidates tail equals: link2.
	self assert: category headLink equals: link1.
	self assert: category tailLink equals: link2
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testAddTwoCandidateA1A2 [
	| link11 link12 link21 link22 category1 category2 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link21 := candidates addCandidate: 21 in: GTSpotterA2.
	link22 := candidates addCandidate: 22 in: GTSpotterA2.

	self assert: link11 nextLink equals: link12.
	self assert: link11 previousLink equals: link22.

	self assert: link12 nextLink equals: link21.
	self assert: link12 previousLink equals: link11.

	self assert: link21 nextLink equals: link22.
	self assert: link21 previousLink equals: link12.

	self assert: link22 nextLink equals: link11.
	self assert: link22 previousLink equals: link21.

	self assert: candidates head equals: link11.
	self assert: candidates tail equals: link22.

	self assert: category1 headLink equals: link11.
	self assert: category1 tailLink equals: link12.

	self assert: category2 headLink equals: link21.
	self assert: category2 tailLink equals: link22
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testAddTwoCandidateA1A2A3 [
	| link11 link12 link21 link22 link31 link32 category1 category2 category3 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.
	category3 := candidates addProcessor: GTSpotterA3.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link21 := candidates addCandidate: 21 in: GTSpotterA2.
	link22 := candidates addCandidate: 22 in: GTSpotterA2.
	link31 := candidates addCandidate: 31 in: GTSpotterA3.
	link32 := candidates addCandidate: 32 in: GTSpotterA3.

	self assert: link11 nextLink equals: link12.
	self assert: link11 previousLink equals: link32.

	self assert: link12 nextLink equals: link21.
	self assert: link12 previousLink equals: link11.

	self assert: link21 nextLink equals: link22.
	self assert: link21 previousLink equals: link12.

	self assert: link22 nextLink equals: link31.
	self assert: link22 previousLink equals: link21.

	self assert: link31 nextLink equals: link32.
	self assert: link31 previousLink equals: link22.

	self assert: link32 nextLink equals: link11.
	self assert: link32 previousLink equals: link31.

	self assert: candidates head equals: link11.
	self assert: candidates tail equals: link32.

	self assert: category1 headLink equals: link11.
	self assert: category1 tailLink equals: link12.

	self assert: category2 headLink equals: link21.
	self assert: category2 tailLink equals: link22.

	self assert: category3 headLink equals: link31.
	self assert: category3 tailLink equals: link32
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testCategoryLinkByCandidateLinkThreeA1A2A3 [
	| link11 link12 link13 link21 link22 link23 link31 link32 link33 category1 category2 category3 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.
	category3 := candidates addProcessor: GTSpotterA3.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link13 := candidates addCandidate: 13 in: GTSpotterA1.
	link21 := candidates addCandidate: 21 in: GTSpotterA2.
	link22 := candidates addCandidate: 22 in: GTSpotterA2.
	link23 := candidates addCandidate: 23 in: GTSpotterA2.
	link31 := candidates addCandidate: 31 in: GTSpotterA3.
	link32 := candidates addCandidate: 32 in: GTSpotterA3.
	link33 := candidates addCandidate: 33 in: GTSpotterA3.

	self assert: category1 equals: (candidates getProcessorLinkByCandidateLink: link11).
	self assert: category1 equals: (candidates getProcessorLinkByCandidateLink: link12).
	self assert: category1 equals: (candidates getProcessorLinkByCandidateLink: link13).

	self assert: category2 equals: (candidates getProcessorLinkByCandidateLink: link21).
	self assert: category2 equals: (candidates getProcessorLinkByCandidateLink: link22).
	self assert: category2 equals: (candidates getProcessorLinkByCandidateLink: link23).

	self assert: category3 equals: (candidates getProcessorLinkByCandidateLink: link31).
	self assert: category3 equals: (candidates getProcessorLinkByCandidateLink: link32).
	self assert: category3 equals: (candidates getProcessorLinkByCandidateLink: link33)
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testNextA1A2Category [
	| link11 link12 link13 link21 link22 link23 category1 category2 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link13 := candidates addCandidate: 13 in: GTSpotterA1.
	link21 := candidates addCandidate: 21 in: GTSpotterA2.
	link22 := candidates addCandidate: 22 in: GTSpotterA2.
	link23 := candidates addCandidate: 23 in: GTSpotterA2.

	self assert: category1 equals: (candidates nextProcessorLinkOf: category2).
	self assert: category2 equals: (candidates nextProcessorLinkOf: category1)
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testNextA1A2EmptyCategory [
	| link11 link12 link13 category1 category2 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link13 := candidates addCandidate: 13 in: GTSpotterA1.

	self assert: category1 equals: (candidates nextProcessorLinkOf: category1).
	self assert: category1 equals: (candidates nextProcessorLinkOf: category2)
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testNextA1Category [
	| link11 link12 link13 category1 |
	category1 := candidates addProcessor: GTSpotterA1.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link13 := candidates addCandidate: 13 in: GTSpotterA1.

	self assert: category1 equals: (candidates nextProcessorLinkOf: category1)
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testPreviousA1A2Category [
	| link11 link12 link13 link21 link22 link23 category1 category2 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link13 := candidates addCandidate: 13 in: GTSpotterA1.
	link21 := candidates addCandidate: 21 in: GTSpotterA2.
	link22 := candidates addCandidate: 22 in: GTSpotterA2.
	link23 := candidates addCandidate: 23 in: GTSpotterA2.

	self assert: category1 equals: (candidates previousProcessorLinkOf: category2).
	self assert: category2 equals: (candidates previousProcessorLinkOf: category1)
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testPreviousA1A2EmptyCategory [
	| link11 link12 link13 category1 category2 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link13 := candidates addCandidate: 13 in: GTSpotterA1.

	self assert: category1 equals: (candidates previousProcessorLinkOf: category1).
	self assert: category1 equals: (candidates previousProcessorLinkOf: category2)
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testPreviousA1Category [
	| link11 link12 link13 category1 |
	category1 := candidates addProcessor: GTSpotterA1.

	link11 := candidates addCandidate: 11 in: GTSpotterA1.
	link12 := candidates addCandidate: 12 in: GTSpotterA1.
	link13 := candidates addCandidate: 13 in: GTSpotterA1.

	self assert: category1 equals: (candidates previousProcessorLinkOf: category1)
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testRemoveCandidatesA1A2A3FromA1A2A3 [
	| category1 category2 category3 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.
	category3 := candidates addProcessor: GTSpotterA3.

	candidates addCandidate: 11 in: GTSpotterA1.
	candidates addCandidate: 12 in: GTSpotterA1.
	candidates addCandidate: 13 in: GTSpotterA1.
	candidates addCandidate: 21 in: GTSpotterA2.
	candidates addCandidate: 22 in: GTSpotterA2.
	candidates addCandidate: 23 in: GTSpotterA2.
	candidates addCandidate: 31 in: GTSpotterA3.
	candidates addCandidate: 32 in: GTSpotterA3.
	candidates addCandidate: 33 in: GTSpotterA3.

	candidates removeAllCandidatesOf: GTSpotterA1.
	candidates removeAllCandidatesOf: GTSpotterA3.
	candidates removeAllCandidatesOf: GTSpotterA2.

	self assert: candidates head equals: nil.
	self assert: candidates tail equals: nil.

	self assert: category1 headLink equals: nil.
	self assert: category1 tailLink equals: nil.

	self assert: category2 headLink equals: nil.
	self assert: category2 tailLink equals: nil.

	self assert: category3 headLink equals: nil.
	self assert: category3 tailLink equals: nil
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testRemoveCandidatesA1A3FromA1A2A3 [
	| link21 link22 link23 category1 category2 category3 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.
	category3 := candidates addProcessor: GTSpotterA3.

	candidates addCandidate: 11 in: GTSpotterA1.
	candidates addCandidate: 12 in: GTSpotterA1.
	candidates addCandidate: 13 in: GTSpotterA1.
	link21 := candidates addCandidate: 21 in: GTSpotterA2.
	link22 := candidates addCandidate: 22 in: GTSpotterA2.
	link23 := candidates addCandidate: 23 in: GTSpotterA2.
	candidates addCandidate: 31 in: GTSpotterA3.
	candidates addCandidate: 32 in: GTSpotterA3.
	candidates addCandidate: 33 in: GTSpotterA3.

	candidates removeAllCandidatesOf: GTSpotterA1.
	candidates removeAllCandidatesOf: GTSpotterA3.

	self assert: link21 nextLink equals: link22.
	self assert: link21 previousLink equals: link23.

	self assert: link22 nextLink equals: link23.
	self assert: link22 previousLink equals: link21.

	self assert: link23 nextLink equals: link21.
	self assert: link23 previousLink equals: link22.

	self assert: candidates head equals: link21.
	self assert: candidates tail equals: link23.

	self assert: category1 headLink equals: nil.
	self assert: category1 tailLink equals: nil.

	self assert: category2 headLink equals: link21.
	self assert: category2 tailLink equals: link23.

	self assert: category3 headLink equals: nil.
	self assert: category3 tailLink equals: nil
]

{ #category : #tests }
GTSpotterCandidatesListTest >> testRemoveCandidatesA1FromA1A2A3 [
	| link21 link22 link23 link31 link32 link33 category1 category2 category3 |
	category1 := candidates addProcessor: GTSpotterA1.
	category2 := candidates addProcessor: GTSpotterA2.
	category3 := candidates addProcessor: GTSpotterA3.

	candidates addCandidate: 11 in: GTSpotterA1.
	candidates addCandidate: 12 in: GTSpotterA1.
	candidates addCandidate: 13 in: GTSpotterA1.
	link21 := candidates addCandidate: 21 in: GTSpotterA2.
	link22 := candidates addCandidate: 22 in: GTSpotterA2.
	link23 := candidates addCandidate: 23 in: GTSpotterA2.
	link31 := candidates addCandidate: 31 in: GTSpotterA3.
	link32 := candidates addCandidate: 32 in: GTSpotterA3.
	link33 := candidates addCandidate: 33 in: GTSpotterA3.

	candidates removeAllCandidatesOf: GTSpotterA1.

	self assert: link21 nextLink equals: link22.
	self assert: link21 previousLink equals: link33.

	self assert: link22 nextLink equals: link23.
	self assert: link22 previousLink equals: link21.

	self assert: link23 nextLink equals: link31.
	self assert: link23 previousLink equals: link22.

	self assert: link31 nextLink equals: link32.
	self assert: link31 previousLink equals: link23.

	self assert: link32 nextLink equals: link33.
	self assert: link32 previousLink equals: link31.

	self assert: link33 nextLink equals: link21.
	self assert: link33 previousLink equals: link32.

	self assert: candidates head equals: link21.
	self assert: candidates tail equals: link33.

	self assert: category1 headLink equals: nil.
	self assert: category1 tailLink equals: nil.

	self assert: category2 headLink equals: link21.
	self assert: category2 tailLink equals: link23.

	self assert: category3 headLink equals: link31.
	self assert: category3 tailLink equals: link33
]
