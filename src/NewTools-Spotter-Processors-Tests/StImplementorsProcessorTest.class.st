Class {
	#name : #StImplementorsProcessorTest,
	#superclass : #StAbstractProcessorTest,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StImplementorsProcessorTest >> processor [

	^ StImplementorsProcessor new
]

{ #category : #tests }
StImplementorsProcessorTest >> testFindThisMethod [

	self runForText: 'testFindThisMethod'.
	self assertResultsIncludes: thisContext method
]

{ #category : #tests }
StImplementorsProcessorTest >> testFindThisMethodAfterAddingText [

	self runForText: 'test'.
	self runForText: 'testFindThisMethod'.
	
	self assertResultsIncludes: thisContext method
]

{ #category : #tests }
StImplementorsProcessorTest >> testPopularStringDoesReturnOnlyTenResults [

	self runForText: 'test'.
	self assertQuantityOfResults: 25.
]

{ #category : #tests }
StImplementorsProcessorTest >> testPopularStringDoesReturnOnlyTenResultsWithUppercase [

	self runForText: 'Test'.
	self assertQuantityOfResults: 25.
]
