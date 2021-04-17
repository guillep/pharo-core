"
I implement an abstract decorator for the implementors.
I have an iterator in the inner instance variable and all the messages are redirected to it. 
My subclasses can override the required behaviour.
"
Class {
	#name : #StIteratorDecorator,
	#superclass : #StIterator,
	#instVars : [
		'inner'
	],
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #testing }
StIteratorDecorator >> atEnd [ 

	^ inner atEnd
]

{ #category : #protected }
StIteratorDecorator >> doReset [ 
	
	inner reset
]

{ #category : #accessing }
StIteratorDecorator >> inner: anObject [
	inner := anObject
]

{ #category : #accessing }
StIteratorDecorator >> next [

	^ inner next
]
