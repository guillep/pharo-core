Class {
	#name : #StHistoryProcessorTest,
	#superclass : #StAbstractProcessorTest,
	#instVars : [
		'firstValue',
		'secondValue'
	],
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StHistoryProcessorTest >> processor [

	^ StHistoryProcessor new
]

{ #category : #running }
StHistoryProcessorTest >> setUp [
	super setUp. 
	
	firstValue := StClassEntry on: self class.
	secondValue := StClassEntry on: StUnifiedProcessorTest.
	
	StSpotter new historize: firstValue.
	StSpotter new historize: secondValue.
]

{ #category : #running }
StHistoryProcessorTest >> tearDown [

	StSpotter resetHistory.
	super tearDown
]

{ #category : #tests }
StHistoryProcessorTest >> testEmptyQueryShowsResults [

	self runForText: ''.
	self assertResultsIncludes: self class.

]

{ #category : #tests }
StHistoryProcessorTest >> testLookingHistoryQueryShowsResults [

	self runForText: 'sthistory'.
	self assertResultsIncludes: self class.

]

{ #category : #tests }
StHistoryProcessorTest >> testLookingSubstringShowsResults [

	self runForText: 'unifi'.
	self denyResultsIncludes: self class.
	self assertResultsIncludes: StUnifiedProcessorTest.

]
