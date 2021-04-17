Class {
	#name : #StHelpProcessorTest,
	#superclass : #StAbstractProcessorTest,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StHelpProcessorTest >> assertResultsIncludesHelpTopic: aHelpTopic [

	^ self assert: (candidates results
				anySatisfy: [ :each | each content title = aHelpTopic title ])
]

{ #category : #tests }
StHelpProcessorTest >> denyResultsIncludesHelpTopic: aHelpTopic [

	^ self assert: (candidates results
				noneSatisfy: [ :each | each content title = aHelpTopic title ])
]

{ #category : #tests }
StHelpProcessorTest >> processor [

	^ StHelpProcessor new
]

{ #category : #tests }
StHelpProcessorTest >> testBeginsWithQueryShowsResults [

	self runForText: 'Contr'.
	self assertResultsIncludesHelpTopic: HowToContributeHelp asHelpTopic.

]

{ #category : #tests }
StHelpProcessorTest >> testEmptyQueryShowsResults [

	self runForText: ''.
	self assertResultsIncludesHelpTopic: WelcomeHelp asHelpTopic.

]

{ #category : #tests }
StHelpProcessorTest >> testLookingSubstringShowsResults [

	self runForText: 'menu'.
	self denyResultsIncludesHelpTopic: HowToContributeHelp asHelpTopic.
	self assertResultsIncludesHelpTopic: WorldMenuHelp asHelpTopic.

]
