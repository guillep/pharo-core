"
I am a DrTestPlugin.
I show the time that takes execute the test and the result of the tests.
"
Class {
	#name : #DTTestsProfilingPlugin,
	#superclass : #DrTestsPlugin,
	#category : #'DrTests-TestsProfiling'
}

{ #category : #'api - accessing' }
DTTestsProfilingPlugin class >> pluginName [
	^ 'Tests Profiler'
]

{ #category : #'api - accessing' }
DTTestsProfilingPlugin class >> pluginResultClass [
	^ DTTestsProfilingResult
]

{ #category : #'api - accessing' }
DTTestsProfilingPlugin class >> weight [
 ^ 5
]

{ #category : #api }
DTTestsProfilingPlugin >> firstListLabel [
	^ 'Packages'
]

{ #category : #accessing }
DTTestsProfilingPlugin >> pragmaForResultTrees [
	^ #'drTestsProfilingResultTreeNamed:order:'
]

{ #category : #api }
DTTestsProfilingPlugin >> resultButtonHelp [
	^ 'Browse the test selected in the results list.' translated
]

{ #category : #api }
DTTestsProfilingPlugin >> runForConfiguration: aDTpluginConfiguration [
	| results profilerVisitor |
	profilerVisitor := DTTestsProfilerVisitor new.
	aDTpluginConfiguration asTestSuite
		acceptSUnitVisitor: profilerVisitor.
	results := self pluginResultClass new
		testResults: profilerVisitor profilingData;
		yourself.
	^ results
]

{ #category : #api }
DTTestsProfilingPlugin >> secondListLabel [
	^ 'Tests Cases'
]

{ #category : #api }
DTTestsProfilingPlugin >> startButtonHelp [
	^ 'Run tests selected.' translated
]

{ #category : #api }
DTTestsProfilingPlugin >> startButtonLabel [
	^ 'Profile Tests' translated
]
