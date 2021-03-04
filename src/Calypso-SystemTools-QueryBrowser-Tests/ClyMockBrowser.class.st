Class {
	#name : #ClyMockBrowser,
	#superclass : #Object,
	#instVars : [
		'hasSpawned',
		'elements'
	],
	#category : #'Calypso-SystemTools-QueryBrowser-Tests-Commands-Classes'
}

{ #category : #testing }
ClyMockBrowser >> hasSpawnedQueryBrowser [

	^hasSpawned 
]

{ #category : #testing }
ClyMockBrowser >> hasSpawnedQueryBrowserOn: aCollection [

	^hasSpawned and: [ elements resultItems asArray = aCollection asArray ]
]

{ #category : #initialization }
ClyMockBrowser >> initialize [

	hasSpawned := false
]

{ #category : #mocking }
ClyMockBrowser >> spawnQueryBrowserOn: aCollection [

	hasSpawned := true.
	elements := aCollection
]
