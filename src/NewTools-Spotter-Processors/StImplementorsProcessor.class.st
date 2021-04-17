"
I am simple processor that iterates on the implementors
"
Class {
	#name : #StImplementorsProcessor,
	#superclass : #StSpotterProcessor,
	#category : #'NewTools-Spotter-Processors-Processors'
}

{ #category : #'default-settings' }
StImplementorsProcessor class >> defaultEnabled [

	^ false
]

{ #category : #settings }
StImplementorsProcessor class >> hideInSettings [

	"I am hidden because the implementation in the unified processor is richer"
	^ true
]

{ #category : #accessing }
StImplementorsProcessor class >> order [
	
	^ 100
]

{ #category : #accessing }
StImplementorsProcessor class >> title [

	^ 'Implementors'
]

{ #category : #filtering }
StImplementorsProcessor >> newTextFilteringSource [

	^ StSourceFactory current implementorsSubstringSource
]
