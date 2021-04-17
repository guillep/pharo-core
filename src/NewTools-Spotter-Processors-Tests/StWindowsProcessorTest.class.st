Class {
	#name : #StWindowsProcessorTest,
	#superclass : #StAbstractProcessorTest,
	#instVars : [
		'backWindow1',
		'backWindow2',
		'topMostWindow'
	],
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StWindowsProcessorTest >> processor [

	^ StWindowsProcessor new
]

{ #category : #running }
StWindowsProcessorTest >> setUp [

	super setUp.
	backWindow1 := StandardWindow new title: 'backWindow1'; openInWorld; yourself.
	backWindow2 := StandardWindow new title: 'backWindow2'; openInWorld; yourself.
	topMostWindow := StandardWindow new title: 'topMostWindow'; openInWorld; yourself.		
	
]

{ #category : #running }
StWindowsProcessorTest >> tearDown [

	{backWindow1. backWindow2. topMostWindow} 
		do:[:e | e ifNotNil: [ e close ]].

	super tearDown.	
]

{ #category : #tests }
StWindowsProcessorTest >> testBackWindowsAreFind [

	self runForText: 'back'.
	self assertResultsIncludes: backWindow1.
	self assertResultsIncludes: backWindow2.	
]

{ #category : #tests }
StWindowsProcessorTest >> testBackWindowsAreFindWhenUsingSubstring [

	self runForText: 'wind'.
	self assertResultsIncludes: backWindow1.
	self assertResultsIncludes: backWindow2.	
]

{ #category : #tests }
StWindowsProcessorTest >> testBackWindowsAreShown [

	self runForText: ''.
	self assertResultsIncludes: backWindow1.
	self assertResultsIncludes: backWindow2.	
]

{ #category : #tests }
StWindowsProcessorTest >> testEmptyQueryShowsResults [

	self runForText: ''.
	self assertResultsIncludes: backWindow1
]

{ #category : #tests }
StWindowsProcessorTest >> testTopMostWindowIsNotShown [

	self runForText: ''.
	self denyResultsIncludes: topMostWindow
]
