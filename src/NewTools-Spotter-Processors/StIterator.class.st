"
I represent an abstract Iterator.
My subclasses should implement #next, #doReset, and #atEnd.

I implement some construction messages to ease the construction of chains of iterators.

#, allows to create sequence of iterators, the results are from the first one, then from the second one and so on. 

#asBeginsWithFilter
Creates an iterator that allows to filter by a string, comparing with beginsWith:, with an starting filter of ''.
#beginsWithFilter: aString
Create an iterator that allows to filter by a string, comparing with beginsWith:, with an starting filter of aString.

#asSubStringFilter
Creates an iterator that allows to filter by a string, comparing with substring:, with an starting filter of ''.

#substringFilter: aString
Create an iterator that allows to filter by a string, comparing with substring:, with an starting filter of aString.

#asWithoutDuplicates 
Creates an itearator that returns no duplicates.
"
Class {
	#name : #StIterator,
	#superclass : #Object,
	#instVars : [
		'onReset'
	],
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #sequencing }
StIterator >> , aStGeneratorIterator [ 
	
	^ StSequenceIterator with: { self. aStGeneratorIterator }
]

{ #category : #filtering }
StIterator >> asBeginsWithFilter [
	
	^ self beginsWithFilter: ''
]

{ #category : #filtering }
StIterator >> asSubstringFilter [
	
	^ self substringFilter: ''
]

{ #category : #filtering }
StIterator >> asWithoutDuplicates [
	
	^ StWithoutDuplicatesDecorator on: self
]

{ #category : #testing }
StIterator >> atEnd [ 

	^ self subclassResponsibility 
]

{ #category : #filtering }
StIterator >> beginsWithFilter: aString [ 
	
	^ StBeginsWithFilter on: self with: aString
]

{ #category : #transforming }
StIterator >> collect: aBlockClosure [ 
	
	^ StTransformation on: self with: aBlockClosure
]

{ #category : #protected }
StIterator >> doReset [
	
	^ self subclassResponsibility
]

{ #category : #accessing }
StIterator >> next [

	self subclassResponsibility 
]

{ #category : #initialization }
StIterator >> next: aQuantity [

	^ OrderedCollection streamContents: [ :stream | | total last |
			total := 0.
			[ (last := self next).
				last ifNotNil: [  
					stream nextPut: last.
					total := total + 1 ] ]
				doWhileTrue: [ total < aQuantity and: [ last notNil ] ] ]
]

{ #category : #events }
StIterator >> onReset: aValuable [

	onReset := aValuable
]

{ #category : #reseting }
StIterator >> reset [

	self doReset.
	onReset ifNotNil: [ onReset value ]
]

{ #category : #filtering }
StIterator >> select: aBlockClosure [ 
	
	^ StFilter on: self with: aBlockClosure 
]

{ #category : #filtering }
StIterator >> substringFilter: aString [ 
	
	^ StSubStringFilter on: self with: aString
]

{ #category : #accessing }
StIterator >> upToEnd [

	^ OrderedCollection
		streamContents:
			[ :stream | [ self atEnd ] whileFalse: [ stream nextPut: self next ] ]
]
