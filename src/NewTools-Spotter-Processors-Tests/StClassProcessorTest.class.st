Class {
	#name : #StClassProcessorTest,
	#superclass : #StAbstractProcessorTest,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StClassProcessorTest >> processor [

	^ StClassProcessor new
]

{ #category : #tests }
StClassProcessorTest >> testFindGTClassProcessorTest [

	self runForText: 'stclassprocessortest'.
	self assertResultsIncludes: StClassProcessorTest
]

{ #category : #tests }
StClassProcessorTest >> testFindGTClassProcessorTestAfterAddingTest [

	self runForText: 'stclass'.
	self rerunWithText: 'stclassprocess'.
	
	self assertResultsIncludes: StClassProcessorTest 
]

{ #category : #tests }
StClassProcessorTest >> testFindGTClassProcessorTestWithPartialText [

	self runForText: 'stclass'.
	self assertResultsIncludes: StClassProcessorTest
]

{ #category : #tests }
StClassProcessorTest >> testGTClassProcessorIsRemovedAfterUpdatingText [

	self runForText: 'gtclass'.
	self rerunWithText: 'gtclassprocesst'.
	
	self denyResultsIncludes: SptClassProcessor
]

{ #category : #tests }
StClassProcessorTest >> testPopularStringDoesReturnOnlyTenResults [

	self runForText: 'test'.
	self assertQuantityOfResults: 25.
]
