"
I am an abstract processor that is used when the results collection already exists or this is really cheap to calculate.
"
Class {
	#name : #StCollectionBasedProcessor,
	#superclass : #StSpotterProcessor,
	#category : #'NewTools-Spotter-Processors-Processors'
}

{ #category : #testing }
StCollectionBasedProcessor class >> isAbstract [ 

	^ self = StCollectionBasedProcessor 
]

{ #category : #filtering }
StCollectionBasedProcessor >> collection [

	^ self subclassResponsibility 
]

{ #category : #filtering }
StCollectionBasedProcessor >> newEntryOn: anElement [

	^ self subclassResponsibility 
]

{ #category : #filtering }
StCollectionBasedProcessor >> newTextFilteringSource [

	^ ((StCollectionIterator on: self collection) 
			collect: [ :each | self newEntryOn: each ]) 
			asSubstringFilter
]
