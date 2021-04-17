Class {
	#name : #StAbstractProcessorTest,
	#superclass : #TestCase,
	#instVars : [
		'text',
		'candidates',
		'context',
		'processor',
		'stream'
	],
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #testing }
StAbstractProcessorTest class >> isAbstract [ 

	^ self == StAbstractProcessorTest
]

{ #category : #asserting }
StAbstractProcessorTest >> assertQuantityOfResults: anInteger [ 
	
	self assert: candidates results size equals: anInteger
]

{ #category : #asserting }
StAbstractProcessorTest >> assertResultsIncludes: anElement [ 
	
	self assert: ((candidates results collect: [:each | each content]) includes: anElement)
]

{ #category : #asserting }
StAbstractProcessorTest >> denyResultsIncludes: anElement [ 

	self deny: ((candidates results collect: [:each | each content]) includes: anElement )
]

{ #category : #tests }
StAbstractProcessorTest >> processor [

	^ self subclassResponsibility 
]

{ #category : #testing }
StAbstractProcessorTest >> rerunWithText: aText [ 
	
	text := aText.
	context search: aText.
	context text: aText.
	candidates reset.
	processor filterInContext: context
]

{ #category : #tests }
StAbstractProcessorTest >> runForText: aText [

	candidates := StMockCandidatesList new.
	text := aText.
	stream := StMockSpotterStream new
		receiver: candidates;
		yourself.

	context:= StSpotterContext new 
		step: self;
		stream: stream;
		text: text;
		search: text;
		yourself.

	processor := self processor.
			
	processor filterInContext: context.
]

{ #category : #running }
StAbstractProcessorTest >> setUp [ 
	
	super setUp.
	SptDefaultSourceFactory forTest.
]

{ #category : #running }
StAbstractProcessorTest >> tearDown [ 

	SptSourceFactory reset.
	super tearDown.
]

{ #category : #tests }
StAbstractProcessorTest >> testSearchingInvalidTextDoesNotReturnResult [

	self runForText: 'assdsadasdsada'.
	self assert: candidates results isEmpty
]
