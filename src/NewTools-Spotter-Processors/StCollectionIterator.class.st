"
I wrap an existing collection and expose it as a iterator
"
Class {
	#name : #StCollectionIterator,
	#superclass : #StGenericGenerator,
	#instVars : [
		'collection'
	],
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #'instance creation' }
StCollectionIterator class >> on: aSequenceableCollection [

	^ self basicNew
		collection: aSequenceableCollection;
		initialize;
		yourself
]

{ #category : #accessing }
StCollectionIterator >> collection [
	^ collection
]

{ #category : #accessing }
StCollectionIterator >> collection: anObject [
	collection := anObject
]

{ #category : #enumerating }
StCollectionIterator >> elementsDo: aValuable [

	collection do: aValuable 
]
