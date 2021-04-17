"
I implement a simple substring string filter using includesSubstring:.
"
Class {
	#name : #StSubStringFilter,
	#superclass : #StAbstractStringFilter,
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #protected }
StSubStringFilter >> criterium: aValue [

	^ aValue asString asLowercase includesSubstring: filteringText asLowercase


]

{ #category : #filtering }
StSubStringFilter >> substringFilter: aString [
	
	self filteringText: aString
]
