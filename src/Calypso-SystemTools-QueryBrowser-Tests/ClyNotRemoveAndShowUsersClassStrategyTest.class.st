"
A ClyNotRemoveAndShowUsersClassStrategyTest is a test class for testing the behavior of ClyNotRemoveAndShowUsersClassStrategy
"
Class {
	#name : #ClyNotRemoveAndShowUsersClassStrategyTest,
	#superclass : #TestCase,
	#category : #'Calypso-SystemTools-QueryBrowser-Tests-Commands-Classes'
}

{ #category : #tests }
ClyNotRemoveAndShowUsersClassStrategyTest >> testExecutingCommand [
	| browser command strategy |
	browser := ClyMockBrowser new.
	strategy := ClyNotRemoveAndShowUsersClassStrategy newForBrowser: browser.
	command := SycRemoveClassCommand for: { TRBProgramNodeVisitor }.
	strategy execute: command.
	self assert: (browser hasSpawnedQueryBrowserOn: TRBProgramNodeVisitor users)
]
