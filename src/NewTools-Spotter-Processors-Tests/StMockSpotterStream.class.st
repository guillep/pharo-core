Class {
	#name : #StMockSpotterStream,
	#superclass : #StSpotterStream,
	#category : #'NewTools-Spotter-Processors-Tests-Scripting-Mocks'
}

{ #category : #performing }
StMockSpotterStream >> performSymbol: aSymbol withArguments: aCollection [
	self receiver perform: aSymbol withEnoughArguments: aCollection
]
