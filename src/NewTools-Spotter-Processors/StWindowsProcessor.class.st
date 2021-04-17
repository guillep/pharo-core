"
I am a processor to get all the windows open in the world. It filters out the top most window
"
Class {
	#name : #StWindowsProcessor,
	#superclass : #StCollectionBasedProcessor,
	#category : #'NewTools-Spotter-Processors-Processors'
}

{ #category : #'default-settings' }
StWindowsProcessor class >> defaultEnabled [

	^ true
]

{ #category : #accessing }
StWindowsProcessor class >> order [
	
	^ 50
]

{ #category : #accessing }
StWindowsProcessor class >> title [

	^ 'Windows'
]

{ #category : #filtering }
StWindowsProcessor >> collection [

	^ (self currentWorld submorphs
		select: [ :window | window isKindOf: SystemWindow ])
		ifNotEmpty: [ :aCollection | aCollection allButFirst ]
]

{ #category : #filtering }
StWindowsProcessor >> newEntryOn: anElement [

	^ StWindowEntry on: anElement
]

{ #category : #configuration }
StWindowsProcessor >> showForEmptyQuery [

	^ true
]
