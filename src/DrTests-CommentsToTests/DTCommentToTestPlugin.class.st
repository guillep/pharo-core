"
I am a DrTestPlugin.
I create tests from executable comments and run these tests.
"
Class {
	#name : #DTCommentToTestPlugin,
	#superclass : #DrTestsPlugin,
	#category : #'DrTests-CommentsToTests-Base'
}

{ #category : #'api - accessing' }
DTCommentToTestPlugin class >> pluginName [
	"The name of the plugin to be displayed in DrTests UI."
	^ 'Executable comments checker'
]

{ #category : #'api - accessing' }
DTCommentToTestPlugin class >> pluginResultClass [
	^ DTCommentToTestResult
]

{ #category : #'api - accessing' }
DTCommentToTestPlugin class >> weight [
	"The lighter is a plugin, the higher it is displayed in the drop list for plugin selection."
	^ 10
]

{ #category : #'configuration building' }
DTCommentToTestPlugin >> buildConfigurationFrom: aDrTests [
	^ DTCommentTestConfiguration items: aDrTests selectedItems packages: aDrTests packagesSelected 
]

{ #category : #api }
DTCommentToTestPlugin >> firstListLabel [
	^ 'Packages'
]

{ #category : #api }
DTCommentToTestPlugin >> itemsToBeAnalysedFor: packagesSelected [

	^ packagesSelected flatCollect: [ :package | 
		  package definedClasses select: [ :class | class hasDocComment ] ]
]

{ #category : #api }
DTCommentToTestPlugin >> packagesAvailableForAnalysis [
	^ RPackage organizer packages
		select: [ :p | p definedClasses anySatisfy: [ :c | c isTestCase not ] ]
]

{ #category : #accessing }
DTCommentToTestPlugin >> pragmaForResultTrees [
	^ #'dtCommentToTestResultTreeNamed:order:'
]

{ #category : #api }
DTCommentToTestPlugin >> resultButtonHelp [
	^ 'Browse the test selected in the result list.'
]

{ #category : #api }
DTCommentToTestPlugin >> runForConfiguration: aDTpluginConfiguration [
	^ self pluginResultClass new
			testResults: (self runTestSuites: {aDTpluginConfiguration asTestSuite});
			yourself
]

{ #category : #api }
DTCommentToTestPlugin >> runSuite: aTestSuite withResult: aResult [
	aTestSuite
		when: TestAnnouncement
		do: [ :testAnnouncement | 
			self announcer
				announce:
					(DTStatusUpdate
						message: ('Running test {1}.' format: {testAnnouncement test asString})) ].
	[ aTestSuite run: aResult ]
		ensure: [ aTestSuite unsubscribe: TestAnnouncement ]
]

{ #category : #api }
DTCommentToTestPlugin >> runTestSuites: testSuites [
	| result |
	result := TestAsserter classForTestResult new.
	CurrentExecutionEnvironment
		runTestsBy: [ testSuites
				do: [ :testSuite | self runSuite: testSuite withResult: result ]
				displayingProgress: 'Running Tests' ].
	^ result
]

{ #category : #api }
DTCommentToTestPlugin >> secondListLabel [
	^ 'Classes'
]

{ #category : #api }
DTCommentToTestPlugin >> startButtonHelp [
	^ 'Run selected tests.' 
]

{ #category : #api }
DTCommentToTestPlugin >> startButtonLabel [
	^ 'Run Tests' translated
]
