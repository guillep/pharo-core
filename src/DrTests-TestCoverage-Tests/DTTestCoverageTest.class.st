Class {
	#name : #DTTestCoverageTest,
	#superclass : #TestCase,
	#instVars : [
		'plugin',
		'package',
		'pluginConfiguration'
	],
	#category : #'DrTests-TestCoverage-Tests'
}

{ #category : #running }
DTTestCoverageTest >> setUp [

	super setUp.
	package := RPackage organizer
		packageNamed: 'DrTests-TestCoverage-Tests-Mocks'.
	"The test classes are in the same package as classes under test."
	pluginConfiguration := DTPluginConfiguration items: {package} packages: {package}.
	plugin := DTTestCoveragePlugin new
]

{ #category : #running }
DTTestCoverageTest >> testCoveragePercentForMock [

	| result |
	result := plugin runForConfiguration: pluginConfiguration.
	self assert: result percent class equals: ScaledDecimal
]

{ #category : #running }
DTTestCoverageTest >> testCoverageResultIsAnInstanceOfDTTestCoverageResult [

	| result |
	result := plugin runForConfiguration: pluginConfiguration.
	self assert: result class equals: DTTestCoverageResult
]

{ #category : #running }
DTTestCoverageTest >> testDTTestCoverageResultAsResultForDrTests [
	"the packages contains at least one test class"

	| items |
	items := plugin packagesAvailableForAnalysis.
	self
		assert:
			(items
				allSatisfy: [ :p | p definedClasses anySatisfy: [ :c | c isTestCase ] ])
]

{ #category : #running }
DTTestCoverageTest >> testDTTestCoverageResultBuildTreeForUIContainsNodes [

	| resultTree |
	resultTree := (plugin runForConfiguration: pluginConfiguration) buildTreeForUI.
	self
		assert:
			(resultTree subResults
				allSatisfy: [ :subResult | subResult class = DTTreeNode ])
]

{ #category : #running }
DTTestCoverageTest >> testDTTestCoverageResultHas2Nodes [

	| resultTree |
	resultTree := (plugin runForConfiguration: pluginConfiguration) buildTreeForUI.
	self assert: resultTree subResults size equals: 2
]

{ #category : #running }
DTTestCoverageTest >> testDTTestCoverageResultTheFirstNodeIsPercent [

	| resultTree |
	resultTree := (plugin runForConfiguration: pluginConfiguration) buildTreeForUI.
	self
		assert:
			((resultTree subResults at: 1) name
				includesSubstring: '% Code Coverage')
]

{ #category : #running }
DTTestCoverageTest >> testDTTestCoverageResultTheSecondNodeSubResultsAreLeafs [

	| resultTree leafs |
	resultTree := (plugin runForConfiguration: pluginConfiguration) buildTreeForUI.
	leafs := resultTree subResults at: 2.
	self
		assert: (leafs subResults allSatisfy: #isLeaf )
]

{ #category : #running }
DTTestCoverageTest >> testItemsAvailableInTestCoveragePlugin [
	| items |
	items := plugin itemsToBeAnalysedFor: package.
	self
		assert:
			(items
				allSatisfy: [ :p | p definedClasses anySatisfy: [ :c | c isTestCase not ] ])
]

{ #category : #running }
DTTestCoverageTest >> testNotExecutedMethodList [

	| result notExecutedMethodList |
	result := plugin runForConfiguration: pluginConfiguration.
	notExecutedMethodList := {(MockForCoverage >> #method2ForMock:)}.
	self
		assert:
			(notExecutedMethodList
				allSatisfy: [ :expectedNotExecutedMethod | 
					result methodList
						anySatisfy: [ :anyMethod | 
							anyMethod methodClass = expectedNotExecutedMethod methodClass
								and: [ anyMethod selector = expectedNotExecutedMethod selector ] ] ])
]

{ #category : #running }
DTTestCoverageTest >> testPackagesAvailableInTestCoveragePlugin [
	| items |
	items := plugin packagesAvailableForAnalysis.
	self
		assert:
			(items
				allSatisfy: [ :p | p definedClasses anySatisfy: [ :c | c isTestCase ] ])
]
