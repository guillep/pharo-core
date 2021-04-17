"
I am sequence iterator, I will take all the iterators I have in myself and then I will go over the elements of them.
I iterate first all elements from the first one, and then the elements of the second one, and so on.
"
Class {
	#name : #StSequenceIterator,
	#superclass : #StIterator,
	#instVars : [
		'iterators'
	],
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #'instance creation' }
StSequenceIterator class >> with: aCollection [ 
	
	^ self new
		iterators: aCollection;
		yourself
]

{ #category : #testing }
StSequenceIterator >> atEnd [ 

	^ iterators allSatisfy: [ :e | e atEnd ]
]

{ #category : #protected }
StSequenceIterator >> doReset [

	^ iterators do: [ :e | e reset ]
]

{ #category : #accessing }
StSequenceIterator >> iterators: aCollection [ 

	iterators := aCollection 
]

{ #category : #accessing }
StSequenceIterator >> next [

	iterators do: [ :e | e next ifNotNil: [ :aValue | ^ aValue ] ].
	^ nil
]
