"
A ClyNotRemoveAndShowSubclassesClassStrategyTest is a test class for testing the behavior of ClyNotRemoveAndShowSubclassesClassStrategy
"
Class {
	#name : #ClyNotRemoveAndShowSubclassesClassStrategyTest,
	#superclass : #TestCase,
	#category : #'Calypso-SystemTools-QueryBrowser-Tests-Commands-Classes'
}

{ #category : #tests }
ClyNotRemoveAndShowSubclassesClassStrategyTest >> testExecutingCommand [
	| browser command strategy |
	browser := ClyMockBrowser new.
	strategy := ClyNotRemoveAndShowSubclassesClassStrategy newForBrowser: browser.
	command := SycRemoveClassCommand for: { ClyInteractiveRemoveClassStrategy }.
	strategy execute: command.
	self assert: (browser hasSpawnedQueryBrowserOn: ClyInteractiveRemoveClassStrategy allSubclasses)
]
