Class {
	#name : #DTTestProfilingTest,
	#superclass : #TestCase,
	#instVars : [
		'package',
		'classes',
		'dTconf',
		'plugin'
	],
	#category : #'DrTests-TestsProfiling-Tests'
}

{ #category : #running }
DTTestProfilingTest >> setUp [
	super setUp.
	plugin := DTTestsProfilingPlugin  new.
	package := RPackage organizer
		packageNamed: 'DrTests-TestCoverage-Tests-Mocks'.
	classes := plugin itemsToBeAnalysedFor: {package}.
	dTconf := DTPluginConfiguration items: classes packages: {package}
]

{ #category : #running }
DTTestProfilingTest >> testCoverageResultIsAnInstanceOfDTTestProfilingResult [
	| result |
	result := plugin runForConfiguration: dTconf.
	self assert: result class equals: DTTestsProfilingResult
]

{ #category : #running }
DTTestProfilingTest >> testDTTestCoverageResulLeafsContentHaveATestCase [
	| resultTree leafs |
	resultTree := (plugin runForConfiguration: dTconf) buildTreeForUI.
	leafs := resultTree subResults at: 4.
	self
		assert:
			(leafs subResults
				allSatisfy: [ :subResult | subResult content testCase isKindOf: TestCase])
]

{ #category : #running }
DTTestProfilingTest >> testDTTestCoverageResulLeafsContentHaveATestResult [
	| resultTree leafs |
	resultTree := (plugin runForConfiguration: dTconf) buildTreeForUI.
	leafs := resultTree subResults at: 4.
	self
		assert:
			(leafs subResults
				allSatisfy: [ :subResult | subResult content testResult isKindOf: TestResult ])
]

{ #category : #running }
DTTestProfilingTest >> testDTTestCoverageResulLeafsContentHaveDuration [
	| resultTree leafs |
	resultTree := (plugin runForConfiguration: dTconf) buildTreeForUI.
	leafs := resultTree subResults at: 4.
	self
		assert:
			(leafs subResults
				allSatisfy: [ :subResult | subResult content duration class = Duration ])
]

{ #category : #running }
DTTestProfilingTest >> testDTTestCoverageResultHas4Nodes [
	| resultTree |
	resultTree := (plugin runForConfiguration: dTconf) buildTreeForUI.
	self assert: resultTree subResults size equals: 4
]

{ #category : #running }
DTTestProfilingTest >> testDTTestCoverageResultTheSecondNodeSubResultsAreLeafs [
	| resultTree leafs |
	resultTree := (plugin runForConfiguration: dTconf) buildTreeForUI.
	leafs := resultTree subResults at: 3.
	self
		assert:
			(leafs subResults
				allSatisfy: [ :subResult | subResult class = DTTreeLeafNode  ])
]

{ #category : #running }
DTTestProfilingTest >> testDTTestCoverageResultTheThirdNodeSubResultsLeafsContentsAreDTTestCaseProfilingData [
	| resultTree leafs |
	resultTree := (plugin runForConfiguration: dTconf) buildTreeForUI.
	leafs := resultTree subResults at: 3.
	self
		assert:
			(leafs subResults
				allSatisfy: [ :subResult | subResult content class = DTTestCaseProfilingData  ])
]

{ #category : #running }
DTTestProfilingTest >> testItemsAvailableInTestProfilerPlugin [
	| items |
	items := plugin itemsToBeAnalysedFor: {package}.
	self
		assert:
			(items
				allSatisfy: [ :p | p methods anySatisfy: [ :m | m isTestMethod ] ])
]
