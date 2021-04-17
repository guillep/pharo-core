"
A ClyNotRemoveAndShowReferencesClassStrategyTest is a test class for testing the behavior of ClyNotRemoveAndShowReferencesClassStrategy
"
Class {
	#name : #ClyNotRemoveAndShowReferencesClassStrategyTest,
	#superclass : #TestCase,
	#category : #'Calypso-SystemTools-QueryBrowser-Tests-Commands-Classes'
}

{ #category : #tests }
ClyNotRemoveAndShowReferencesClassStrategyTest >> testExecutingCommand [
	| browser command strategy |
	browser := MockClyBrowser new.
	strategy := ClyNotRemoveAndShowReferencesClassStrategy newForBrowser: browser.
	command := SycRemoveClassCommand for: { SycRemoveClassCommand }.
	strategy execute: command.
	self assert: browser hasSpawnedQueryBrowser
]
