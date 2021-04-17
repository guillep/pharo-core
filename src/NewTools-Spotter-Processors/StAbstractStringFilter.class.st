"
I implement an abstract string based filter.
My users can update the filteringText using the message #filteringText:
When a new filtering is done I can handle the update of the filtering strategy and also I keep a list of already returned values so on a reset the filter is reapply to them, without reseting the inner iterator.
If the filter requires a full reset, I reset myself and the inner one.

My subclasses implements #criterium: to change how the strings are compared.
"
Class {
	#name : #StAbstractStringFilter,
	#superclass : #StIteratorDecorator,
	#instVars : [
		'returnedIndex',
		'originalUnwrapped',
		'results',
		'filteringText'
	],
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #'instance creation' }
StAbstractStringFilter class >> on: aStCombinator with: aString [

	^ self new
		originalUnwrapped: aStCombinator;
		filteringText: aString
]

{ #category : #testing }
StAbstractStringFilter >> atEnd [

	^ (returnedIndex = results size) and: [ inner atEnd ]
]

{ #category : #protected }
StAbstractStringFilter >> criterium: aString [

	self subclassResponsibility 

]

{ #category : #protected }
StAbstractStringFilter >> doReset [

	originalUnwrapped reset.
	returnedIndex := 0.
	results := OrderedCollection new
]

{ #category : #accessing }
StAbstractStringFilter >> filteringText: aString [

	inner := originalUnwrapped select: [ :e | self criterium: e].

	(aString asLowercase beginsWith: filteringText asLowercase) 
		ifFalse: [ 
			self reset ].

	filteringText := aString.
	results := results select: [ :e | self criterium: e].
	returnedIndex := 0.


]

{ #category : #initialization }
StAbstractStringFilter >> initialize [

	filteringText := ''.
	results := OrderedCollection new.
	returnedIndex := ''.
]

{ #category : #accessing }
StAbstractStringFilter >> next [

	| nextOne |

	(returnedIndex < results size) ifTrue: [  
		returnedIndex := returnedIndex + 1.
		^ results at: returnedIndex.	
	].

	nextOne := super next.
	
	nextOne 
		ifNil: [ ^ nil ].
	
	results add: nextOne.
	returnedIndex := results size.
	
	^ nextOne
]

{ #category : #accessing }
StAbstractStringFilter >> originalUnwrapped [
	^ originalUnwrapped
]

{ #category : #accessing }
StAbstractStringFilter >> originalUnwrapped: anObject [
	originalUnwrapped := anObject
]
