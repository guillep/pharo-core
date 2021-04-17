"
I implement an iterator over all the implementors in the system
"
Class {
	#name : #StImplementorsIterator,
	#superclass : #StGenericGenerator,
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #enumerating }
StImplementorsIterator >> elementsDo: aValuable [

	SystemNavigation default
		allBehaviorsDo: [ :aClass | aClass methodsDo: aValuable ]
]
