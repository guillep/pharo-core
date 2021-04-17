"
I implement a simple beginsWith: string filter.
"
Class {
	#name : #StBeginsWithFilter,
	#superclass : #StAbstractStringFilter,
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #filtering }
StBeginsWithFilter >> beginsWithFilter: aString [

	self filteringText: aString
]

{ #category : #protected }
StBeginsWithFilter >> criterium: aValue [

	^ aValue asString asLowercase beginsWith: filteringText asLowercase


]
