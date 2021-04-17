"
I am a processor that shows all the entries in the spotter history.
"
Class {
	#name : #StHistoryProcessor,
	#superclass : #StCollectionBasedProcessor,
	#category : #'NewTools-Spotter-Processors-Processors'
}

{ #category : #'default-settings' }
StHistoryProcessor class >> defaultEnabled [

	^ true
]

{ #category : #accessing }
StHistoryProcessor class >> order [
	
	^ 80
]

{ #category : #accessing }
StHistoryProcessor class >> title [

	^ 'History'
]

{ #category : #filtering }
StHistoryProcessor >> collection [

	^ StSpotter history reject: [ :each | each isNil ]
]

{ #category : #filtering }
StHistoryProcessor >> newEntryOn: anElement [

	^ anElement
]

{ #category : #configuration }
StHistoryProcessor >> showForEmptyQuery [

	^ true
]
