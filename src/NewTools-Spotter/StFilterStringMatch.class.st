Class {
	#name : #StFilterStringMatch,
	#superclass : #StUnorderedFilter,
	#category : #'NewTools-Spotter-Filters'
}

{ #category : #private }
StFilterStringMatch >> isMatchedItem: anItem [
	^ query match: (self itemFilterNameFor: anItem)
]
