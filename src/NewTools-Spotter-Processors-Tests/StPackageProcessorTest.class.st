Class {
	#name : #StPackageProcessorTest,
	#superclass : #StAbstractProcessorTest,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StPackageProcessorTest >> processor [

	^ StPackageProcessor new
]

{ #category : #tests }
StPackageProcessorTest >> testFindThisPackage [

	self runForText: 'newtools-spotter-processors-tests'.
	self assertResultsIncludes: self class package
]

{ #category : #tests }
StPackageProcessorTest >> testFindThisPackageAfterAddingText [

	self runForText: 'newtools-spo'.
	self runForText: 'newtools-spotter-processors-tests'.

	self assertResultsIncludes: self class package
	
	
]

{ #category : #tests }
StPackageProcessorTest >> testGTSpotterNewIsRemovedAfterAddingText [

	self runForText: 'gt-spotter'.
	self rerunWithText: 'gt-spotter-new-te'.
	
	self denyResultsIncludes: SptClassProcessor package
]

{ #category : #tests }
StPackageProcessorTest >> testPopularStringDoesReturnOnlyTenResults [

	self runForText: 'test'.
	self assertQuantityOfResults: 25.
]
