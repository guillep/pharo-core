"
I implement an iteration over all the classes in the system.

"
Class {
	#name : #StClassIterator,
	#superclass : #StGenericGenerator,
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #enumerating }
StClassIterator >> elementsDo: aValuable [

	SystemNavigation default allBehaviorsDo: aValuable
]
