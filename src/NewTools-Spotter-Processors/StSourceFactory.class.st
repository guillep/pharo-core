"
I represent the responsibility to create the sources, 
so there could be different strategies to generate the sources, for example with or without indexes.
"
Class {
	#name : #StSourceFactory,
	#superclass : #Object,
	#classVars : [
		'Current'
	],
	#category : #'NewTools-Spotter-Processors-Processors'
}

{ #category : #accessing }
StSourceFactory class >> current [

	^ Current ifNil: [ self defaultSourceFactory ]
]

{ #category : #'detecting implementations' }
StSourceFactory class >> defaultSourceFactory [

	| sourceFactoryClass |
	sourceFactoryClass := (self subclasses
		sorted: [ :a :b | a priority > b priority ])
		detect: [ :each | each isAvailable ].
		
	^ sourceFactoryClass new
]

{ #category : #accessing }
StSourceFactory class >> forTest [

	Current := self new
]

{ #category : #'detecting implementations' }
StSourceFactory class >> isAvailable [ 

	^ self subclassResponsibility
]

{ #category : #'detecting implementations' }
StSourceFactory class >> priority [ 

	^ self subclassResponsibility 
]

{ #category : #accessing }
StSourceFactory class >> reset [

	Current := nil
]

{ #category : #'sources - classes' }
StSourceFactory >> classesBeginsWithSource [

	 ^ self subclassResponsibility 
]

{ #category : #'sources - classes' }
StSourceFactory >> classesSubstringSource [

	 ^ self subclassResponsibility 
]

{ #category : #'sources - implementors' }
StSourceFactory >> implementorsBeginsWithSource [

	^ self subclassResponsibility
]

{ #category : #'sources - implementors' }
StSourceFactory >> implementorsSubstringSource [

	^ self subclassResponsibility
]
