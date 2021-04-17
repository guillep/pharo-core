Class {
	#name : #StWorldMenuProcessorTest,
	#superclass : #StAbstractProcessorTest,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #asserting }
StWorldMenuProcessorTest >> assertResultsIncludesMenuEntry: aString [ 
	
	self assert: (candidates results anySatisfy: [:each | each content contents = aString ])
]

{ #category : #asserting }
StWorldMenuProcessorTest >> denyResultsIncludesMenuEntry: aString [ 
	
	self assert: (candidates results noneSatisfy: [:each | each content contents = aString ])
]

{ #category : #tests }
StWorldMenuProcessorTest >> processor [

	^ StWorldMenuProcessor new
]

{ #category : #tests }
StWorldMenuProcessorTest >> testEmptyQueryShowsResults [

	self runForText: ''.
	self assertResultsIncludesMenuEntry: 'Iceberg'.

]

{ #category : #tests }
StWorldMenuProcessorTest >> testSearchingSaDoesNotIncludeIceberg [

	self runForText: 'sa'.
	self denyResultsIncludesMenuEntry: 'Iceberg'.

]

{ #category : #tests }
StWorldMenuProcessorTest >> testSearchingSaIncludesSaveAndSaveAs [

	self runForText: 'sa'.
	self assertResultsIncludesMenuEntry: 'Save'.
	self assertResultsIncludesMenuEntry: 'Save as...'	
]

{ #category : #tests }
StWorldMenuProcessorTest >> testSearchingSettingsFindsTheCorrectEntry [

	self runForText: 'settings'.
	self assertResultsIncludesMenuEntry: 'Settings'
]

{ #category : #tests }
StWorldMenuProcessorTest >> testSearchingVeDoesNotIncludeIceberg [

	self runForText: 've'.
	self denyResultsIncludesMenuEntry: 'Iceberg'.

]

{ #category : #tests }
StWorldMenuProcessorTest >> testSearchingVeIncludesSaveAndSaveAs [

	self runForText: 'Ve'.
	self assertResultsIncludesMenuEntry: 'Save'.
	self assertResultsIncludesMenuEntry: 'Save as...'	
]
