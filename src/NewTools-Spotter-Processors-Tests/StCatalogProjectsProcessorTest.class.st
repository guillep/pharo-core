Class {
	#name : #StCatalogProjectsProcessorTest,
	#superclass : #StAbstractProcessorTest,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StCatalogProjectsProcessorTest >> processor [

	^ StCatalogProjectsProcessor new
]

{ #category : #running }
StCatalogProjectsProcessorTest >> setUp [ 
	
	super setUp.
	StMockCatalogProvider forTest
]

{ #category : #running }
StCatalogProjectsProcessorTest >> tearDown [ 

	StMockCatalogProvider reset.
	super tearDown
]

{ #category : #tests }
StCatalogProjectsProcessorTest >> testBeginsWithQueryShowsResults [

	| jsonProject |
	jsonProject := CatalogProvider default projects detect: [:e | e name = 'JSON'].

	self runForText: 'JSON'.
	self assertResultsIncludes: jsonProject.

]

{ #category : #tests }
StCatalogProjectsProcessorTest >> testEmptyQueryNotShowResults [

	self runForText: ''.
	self assert: candidates results isEmpty

]

{ #category : #tests }
StCatalogProjectsProcessorTest >> testLookingSubstringShowsResults [

	| jsonProject artefactProject |
	jsonProject := CatalogProvider default projects detect: [:e | e name = 'JSON'].
	artefactProject := CatalogProvider default projects detect: [:e | e name = 'Artefact'].

	self runForText: 'son'.
	self denyResultsIncludes: artefactProject.
	self assertResultsIncludes: jsonProject.

]
