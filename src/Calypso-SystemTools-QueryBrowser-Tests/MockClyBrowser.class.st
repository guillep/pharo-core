Class {
	#name : #MockClyBrowser,
	#superclass : #Object,
	#instVars : [
		'hasSpawned',
		'elements'
	],
	#category : #'Calypso-SystemTools-QueryBrowser-Tests-Commands-Classes'
}

{ #category : #testing }
MockClyBrowser >> hasSpawnedQueryBrowser [

	^hasSpawned 
]

{ #category : #testing }
MockClyBrowser >> hasSpawnedQueryBrowserOn: aCollection [

	^hasSpawned and: [ elements resultItems asArray = aCollection asArray ]
]

{ #category : #initialization }
MockClyBrowser >> initialize [

	hasSpawned := false
]

{ #category : #mocking }
MockClyBrowser >> spawnQueryBrowserOn: aCollection [

	hasSpawned := true.
	elements := aCollection
]
