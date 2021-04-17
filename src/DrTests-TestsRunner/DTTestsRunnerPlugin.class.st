"
I am the plugin implementing test runner for DrTests.
"
Class {
	#name : #DTTestsRunnerPlugin,
	#superclass : #DrTestsPlugin,
	#category : #'DrTests-TestsRunner-Base'
}

{ #category : #'api - accessing' }
DTTestsRunnerPlugin class >> pluginName [
	^ 'Tests Runner'
]

{ #category : #'api - accessing' }
DTTestsRunnerPlugin class >> pluginResultClass [
	^ DTTestsRunnerResult
]

{ #category : #'api - accessing' }
DTTestsRunnerPlugin class >> weight [
	^ 0
]

{ #category : #api }
DTTestsRunnerPlugin >> allowMiniDrTests [
	^ true
]

{ #category : #'configuration building' }
DTTestsRunnerPlugin >> buildConfigurationFrom: aDrTests [
	"Builds a configuration from the plugin by reading the information held by the UI (aDrTests)."
	^ DTTestsRunnerConfiguration
		items: aDrTests selectedItems
		packages: aDrTests packagesSelected
]

{ #category : #api }
DTTestsRunnerPlugin >> buildContextualMenuGroupWith: presenterInstance [
	^ (CmCommandGroup named: 'TestRunnerResult context menu') asSpecGroup
		description: 'Commands related to re-run a result.';
		register:
			(DTRerunCommand forSpec context: presenterInstance)
				beHiddenWhenCantBeRun;
		register:
			(DTDebugTestCommand forSpec context: presenterInstance)
				beHiddenWhenCantBeRun;
		beDisplayedAsGroup;
		yourself
]

{ #category : #api }
DTTestsRunnerPlugin >> firstListLabel [
	^ 'Packages'
]

{ #category : #api }
DTTestsRunnerPlugin >> handleReRunResult: rerunnedResult forConfiguration: aDTRerunConfiguration [
	| oldResult |
	oldResult := self
		removeTests: aDTRerunConfiguration configurationToRun items
		from: aDTRerunConfiguration previousResult testResults.
	^ self pluginResultClass new
		testResults: (self joinTestResult: oldResult with: rerunnedResult testResults);
		yourself
]

{ #category : #private }
DTTestsRunnerPlugin >> joinTestResult: aTestResult with: partialResult [
	| newResult |
	newResult := aTestResult.
	partialResult passed do: [ :each | newResult addPass: each ].
	partialResult errors do: [ :each | newResult addError: each ].
	partialResult failures do: [ :each | newResult addFailure: each ].
	partialResult skipped do: [ :each | newResult addSkip: each ].
	^ newResult
]

{ #category : #tests }
DTTestsRunnerPlugin >> label: aString forSuite: aTestSuite [
	^ String streamContents: [ :stream |
		stream nextPutAll: 'Running '; print: aTestSuite tests size; space; nextPutAll: aString.
		aTestSuite tests size > 1 ifTrue: [ stream nextPut: $s ] ]. 
]

{ #category : #accessing }
DTTestsRunnerPlugin >> pragmaForResultTrees [
	^ #'dtTestRunnerResultTreeNamed:order:'
]

{ #category : #private }
DTTestsRunnerPlugin >> removeTest: aTest from: aTestResult [
	aTestResult
		passed: (aTestResult passed copyWithout: aTest).
	aTestResult
		failures: (aTestResult failures copyWithout: aTest).
	aTestResult
		errors: (aTestResult errors copyWithout: aTest).
	^ aTestResult
]

{ #category : #private }
DTTestsRunnerPlugin >> removeTests: aCollectionOfTest from: aTestResult [
	aCollectionOfTest do: [ :test |
		self removeTest: test from: aTestResult ].
	^ aTestResult
]

{ #category : #api }
DTTestsRunnerPlugin >> resultButtonHelp [
	^ 'Browse the test selected in the results list.' translated
]

{ #category : #api }
DTTestsRunnerPlugin >> runForConfiguration: aDTpluginConfiguration [
	| results |
	results := self pluginResultClass new
		testResults: (self runTestSuites: { aDTpluginConfiguration asTestSuite });
		yourself.
	^ aDTpluginConfiguration handleResults: results for: self
]

{ #category : #private }
DTTestsRunnerPlugin >> runSuite: aTestSuite withResult: aResult [
	aTestSuite
		when: TestAnnouncement
		do: [ :testAnnouncement | 
			self flag: #TODO. "Dirty"
			testAnnouncement test class = TestSuite
				ifTrue: [ self announcer
				announce:
					(DTStatusUpdate
						message: ('Running test {1}.' format: {testAnnouncement test name})) ] ].
	[ aTestSuite run: aResult ]
		ensure: [ aTestSuite unsubscribe: TestAnnouncement ]
]

{ #category : #private }
DTTestsRunnerPlugin >> runTestSuites: testSuites [

	| result |
	result := TestAsserter classForTestResult new.
	CurrentExecutionEnvironment runTestsBy: [ 
		testSuites
			do: [ :testSuite | 
				| specificResult |
				specificResult := testSuite resultClass new.
				self runSuite: testSuite withResult: specificResult.
				result mergeWith: specificResult ]
			displayingProgress: 'Running Tests' ].
	^ result
]

{ #category : #api }
DTTestsRunnerPlugin >> secondListLabel [
	^ 'Tests Cases'
]

{ #category : #api }
DTTestsRunnerPlugin >> startButtonHelp [
	^ 'Run tests selected.' translated
]

{ #category : #api }
DTTestsRunnerPlugin >> startButtonLabel [
	^ 'Run Tests' translated
]

{ #category : #tests }
DTTestsRunnerPlugin >> testSuiteOf: aSetOfTest withName: aString [
	^ aSetOfTest
		collect: [ :each | 
			TestSuite new
				in: [ :suite | 
					suite
						addTest: each;
						name: (self label: aString forSuite: suite) ];
				yourself ]
]
