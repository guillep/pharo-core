"
I represent the creation of sources without indexes. 

"
Class {
	#name : #StDefaultSourceFactory,
	#superclass : #StSourceFactory,
	#category : #'NewTools-Spotter-Processors-Processors'
}

{ #category : #'detecting implementations' }
StDefaultSourceFactory class >> isAvailable [ 

	"I am always available, I am the default implementation"
	^ true
]

{ #category : #'detecting implementations' }
StDefaultSourceFactory class >> priority [ 
	
	"I have a lower priority, because I don't use any fancy scheme"
	^ 0 
]

{ #category : #'sources - classes' }
StDefaultSourceFactory >> classesBeginsWithSource [

	^ ((StClassIterator new select: [ :e | e isMeta not ])
		collect: [ :e | StClassEntry on: e ]) asBeginsWithFilter
]

{ #category : #'sources - classes' }
StDefaultSourceFactory >> classesSubstringSource [

	^ ((StClassIterator new select: [ :e | e isMeta not ])
		collect: [ :e | StClassEntry on: e ]) asSubstringFilter
]

{ #category : #'sources - implementors' }
StDefaultSourceFactory >> implementorsBeginsWithSource [

	^ (StImplementorsIterator new collect: [ :e | StMethodEntry on: e ]) asBeginsWithFilter
]

{ #category : #'sources - implementors' }
StDefaultSourceFactory >> implementorsSubstringSource [

	^ (StImplementorsIterator new collect: [ :e | StMethodEntry on: e ]) asSubstringFilter
]
