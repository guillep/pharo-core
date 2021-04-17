Class {
	#name : #StUnifiedProcessorTest,
	#superclass : #StAbstractProcessorTest,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StUnifiedProcessorTest >> processor [

	^ StUnifiedProcessor new
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindStClassProcessorTest [

	self runForText: 'stunifiedprocessortest'.
	self assertResultsIncludes: StUnifiedProcessorTest
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindStClassProcessorTestAfterAddingTest [

	self runForText: 'stun'.
	self rerunWithText: 'stunifiedprocess'.
	
	self assertResultsIncludes: self class
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindStClassProcessorTestWithPartialText [

	self runForText: 'stunifi'.
	self assertResultsIncludes: self class
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindThisMethod [

	self runForText: 'testFindThisMethod'.
	self assertResultsIncludes: thisContext method
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindThisMethodAfterAddingText [

	self runForText: 'test'.
	self runForText: 'testFindThisMethod'.
	
	self assertResultsIncludes: thisContext method
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindThisMethodWithFullClass [

	self runForText: 'StUnifiedProcessorTest >> #testFindThisMethod'.
	self assertResultsIncludes: thisContext method
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindThisMethodWithFullClassDoesNotIncludeOtherClassMethod [

	self runForText: 'StUnifiedProcessorTest >> #testFindThisMethod'.
	self denyResultsIncludes: StImplementorsProcessorTest >> #testFindThisMethod
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindThisMethodWithFullClassIsTheCorrectclass [

	self runForText: 'StUnifiedProcessorTest >> #testFindThisMethod'.
	self
		assert:
			((candidates results collect: [:each | each content])
				allSatisfy: [ :aMethod | aMethod methodClass = self class ])
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindThisPackage [

	self runForText: 'newtools-spotter-processors'.
	self assertResultsIncludes: StUnifiedProcessorTest package
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindThisPackageAfterAddingText [

	self runForText: 'newtools-spo'.
	self runForText: 'newtools-spotter-processors'.

	self assertResultsIncludes: StUnifiedProcessorTest package
	
	
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindThisPackageWithCategory [

	self runForText: '#Packages newtools-spotter-processors'.
	self assertResultsIncludes: StUnifiedProcessorTest package
]

{ #category : #tests }
StUnifiedProcessorTest >> testFindThisPackageWithOtherCategory [

	self runForText: '#Classes newtools-spotter-processors'.
	self denyResultsIncludes: self class package
]

{ #category : #tests }
StUnifiedProcessorTest >> testGTClassProcessorIsRemovedAfterUpdatingText [

	self runForText: 'stclass'.
	self rerunWithText: 'stclassprocesst'.
	
	self denyResultsIncludes: StClassProcessor
]

{ #category : #tests }
StUnifiedProcessorTest >> testGTSpotterNewIsRemovedAfterAddingText [

	self runForText: 'newtools-spotter'.
	self rerunWithText: 'newtools-spotter-other'.
	
	self denyResultsIncludes: StClassProcessor package
]

{ #category : #tests }
StUnifiedProcessorTest >> testLookingForDiskStoreWithSpaceReturnsDiskStore [

	self runForText: 'Disk Store'.
	self assertResultsIncludes: DiskStore
]

{ #category : #tests }
StUnifiedProcessorTest >> testLookingForStoreDiskLowercaseReturnsThisMethod [

	self runForText: 'store disk'.
	self assertResultsIncludes: StUnifiedProcessorTest >> #testLookingForStoreDiskLowercaseReturnsThisMethod
]

{ #category : #tests }
StUnifiedProcessorTest >> testLookingForStoreDiskReturnsDiskStore [

	self runForText: 'StoreDisk'.
	self assertResultsIncludes: DiskStore
]

{ #category : #tests }
StUnifiedProcessorTest >> testLookingForStoreDiskWithSpaceReturnsDiskStore [

	self runForText: 'Store Disk'.
	self assertResultsIncludes: DiskStore
]

{ #category : #tests }
StUnifiedProcessorTest >> testLookingForStoreLowercaseReturnsDiskStore [

	self runForText: 'store disk'.
	self assertResultsIncludes: DiskStore
]

{ #category : #tests }
StUnifiedProcessorTest >> testPopularStringDoesReturnOnlyTwentyResults [

	self runForText: 'test'.
	self assertQuantityOfResults: 25.
]

{ #category : #tests }
StUnifiedProcessorTest >> testPopularStringDoesReturnOnlyTwentyResultsForPackage [

	self runForText: '-Test'.
	self assertQuantityOfResults: 25.
]

{ #category : #tests }
StUnifiedProcessorTest >> testPopularStringDoesReturnOnlyTwentyResultsWithCapital [

	self runForText: 'Test'.
	self assertQuantityOfResults: 25.
]
