"
A DrTestsUITest is a test class for testing the behavior of DrTests-TestRunner UI
"
Class {
	#name : #DrTestsTestRunnerUITest,
	#superclass : #TestCase,
	#instVars : [
		'drTest'
	],
	#category : #'DrTests-Tests'
}

{ #category : #running }
DrTestsTestRunnerUITest >> setUp [

	super setUp.
	drTest := DrTests on: { DTTestsRunnerPlugin }.
]

{ #category : #tests }
DrTestsTestRunnerUITest >> testRunTestsUpdatesUIWithResults [
	drTest startButton performAction.
	self assert: drTest resultsList roots notEmpty
]
