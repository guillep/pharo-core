Class {
	#name : #StSpotterStream,
	#superclass : #Object,
	#instVars : [
		'onAddedSelector',
		'onRemoveSelector',
		'receiver',
		'timestamp'
	],
	#category : #'NewTools-Spotter-Model'
}

{ #category : #'adding/removing' }
StSpotterStream >> addObject: firstObject inProcessor: secondObject [

	self 
		performSymbol: self onAddedSelector 
		withArguments: { firstObject. secondObject }.
	Processor yield
]

{ #category : #'adding/removing' }
StSpotterStream >> addObjects: aCollection inProcessor: aProcessor [

	self 
		performSymbol: #addAllCandidates:in: 
		withArguments: { aCollection . aProcessor }.
	Processor yield
]

{ #category : #accessing }
StSpotterStream >> onAddedSelector [

	^ onAddedSelector
]

{ #category : #accessing }
StSpotterStream >> onAddedSelector: anObject [

	onAddedSelector := anObject
]

{ #category : #accessing }
StSpotterStream >> onRemoveSelector [

	^ onRemoveSelector
]

{ #category : #accessing }
StSpotterStream >> onRemoveSelector: anObject [

	onRemoveSelector := anObject
]

{ #category : #performing }
StSpotterStream >> performSymbol: aSymbol withArguments: aCollection [
	| time |

	"we save current timestamp here, so that defer block can check if it belongs to the correct task"
	time := self timestamp.
	"UI manages commands for us"
	Processor yield.
	"if timestamp is wrong just skip command"
	time = self timestamp ifTrue: [ 
		self receiver perform: aSymbol withEnoughArguments: aCollection ]
]

{ #category : #accessing }
StSpotterStream >> receiver [
	^ receiver
]

{ #category : #accessing }
StSpotterStream >> receiver: anObject [
	receiver := anObject
]

{ #category : #'adding/removing' }
StSpotterStream >> removeAllCandidates [

	self 
		performSymbol: #removeAllCandidates 
		withArguments: { }.
	Processor yield
]

{ #category : #accessing }
StSpotterStream >> timestamp [
	^ timestamp
]

{ #category : #accessing }
StSpotterStream >> timestamp: anObject [
	timestamp := anObject
]

{ #category : #updating }
StSpotterStream >> updateTimestamp [

	self timestamp: Time microsecondClockValue
]
