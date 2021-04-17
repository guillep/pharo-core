"
I implement a decorator for the iterators. 
I don't allow duplicates to be returned. For doing so, I have a collection of the already returned values, so I can filter duplicates.
"
Class {
	#name : #StWithoutDuplicatesDecorator,
	#superclass : #StIteratorDecorator,
	#instVars : [
		'uniqueResults'
	],
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #'instance creation' }
StWithoutDuplicatesDecorator class >> on: anInner [

	^ self new 
		inner: anInner;
		yourself
]

{ #category : #resetting }
StWithoutDuplicatesDecorator >> clearDuplicates [
	
	uniqueResults removeAll
]

{ #category : #protected }
StWithoutDuplicatesDecorator >> doReset [ 

	inner reset.
	self clearDuplicates
]

{ #category : #initialization }
StWithoutDuplicatesDecorator >> initialize [ 

	super initialize.
	uniqueResults := Set new.
]

{ #category : #accessing }
StWithoutDuplicatesDecorator >> next [

	| aValue |
	aValue := inner next.
	
	[aValue isNotNil and: [ uniqueResults includes: aValue ]]
		whileTrue: [ aValue := inner next ].
		
	uniqueResults add: aValue.
	^ aValue
	
]
