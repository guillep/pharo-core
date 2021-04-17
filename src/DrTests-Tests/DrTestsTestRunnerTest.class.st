"
A DrTestsUITest is a test class for testing the behavior of DrTests-TestRunner
"
Class {
	#name : #DrTestsTestRunnerTest,
	#superclass : #TestCase,
	#instVars : [
		'plugin',
		'package',
		'testToReRun',
		'conf',
		'reRunconf',
		'testCase'
	],
	#category : #'DrTests-Tests'
}

{ #category : #running }
DrTestsTestRunnerTest >> setUp [
	super setUp.
	package := RPackage organizer
		packageNamed: 'DrTests-TestCoverage-Tests-Mocks'.
	testToReRun := DTCoverageMockTest
		selector: #testMethod1forMock.
	testCase := DTCoverageMockTest.
	conf := DTPluginConfiguration
		items:
			({package}
				flatCollect:
					[ :p | p definedClasses select: [ :c | c allSuperclasses includes: TestCase ] ])
		packages: {package}.
	reRunconf := DTReRunConfiguration new.
	plugin := DTTestsRunnerPlugin new
]

{ #category : #tests }
DrTestsTestRunnerTest >> testAllSelectedClassesAreTestCases [

	| thePackage |
	thePackage := plugin packagesAvailableForAnalysis anyOne.
	self assert: ((plugin itemsToBeAnalysedFor: {thePackage}) flattened allSatisfy: [ :each | each isTestCase ])
]

{ #category : #tests }
DrTestsTestRunnerTest >> testReRunResultIsDTTestRunnerResult [
	| pluginResult |
	pluginResult := plugin runForConfiguration: conf.
	reRunconf := DTReRunConfiguration new
		previousResult: pluginResult;
		configurationToRun: (DTTestsRunnerConfiguration items: { testToReRun });
		yourself.
	self
		assert: (plugin runForConfiguration: reRunconf) class
		equals: DTTestsRunnerResult
]

{ #category : #tests }
DrTestsTestRunnerTest >> testRunResultBuildTreeForUI [
	self
		assert: (plugin runForConfiguration: conf) buildTreeForUI class
		equals: DTTreeNode 
]

{ #category : #tests }
DrTestsTestRunnerTest >> testRunResultIsDTTestRunnerResult [
	self
		assert: (plugin runForConfiguration: conf) class
		equals: DTTestsRunnerResult 
]

{ #category : #tests }
DrTestsTestRunnerTest >> testSelectedPackagesContainTestCases [

	self assert: (plugin packagesAvailableForAnalysis allSatisfy: [ :pkg |
		pkg definedClasses anySatisfy: [ :class |
			class isTestCase ] ])
]

{ #category : #tests }
DrTestsTestRunnerTest >> testTestResultIsNotEmpty [
	self
		deny: (plugin runForConfiguration: conf) testResults passed isEmpty
]
