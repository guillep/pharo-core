"
I am simple processor that iterates on the classes
"
Class {
	#name : #StClassProcessor,
	#superclass : #StSpotterProcessor,
	#category : #'NewTools-Spotter-Processors-Processors'
}

{ #category : #'default-settings' }
StClassProcessor class >> defaultEnabled [

	^ false
]

{ #category : #settings }
StClassProcessor class >> hideInSettings [

	"I am hidden because the implementation in the unified processor is richer"
	^ true
]

{ #category : #accessing }
StClassProcessor class >> order [
	
	^ 100
]

{ #category : #accessing }
StClassProcessor class >> title [

	^ 'Classes'
]

{ #category : #filtering }
StClassProcessor >> newTextFilteringSource [

	^ StSourceFactory current classesSubstringSource
]
