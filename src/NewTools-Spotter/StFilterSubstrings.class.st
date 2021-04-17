Class {
	#name : #StFilterSubstrings,
	#superclass : #StUnorderedFilter,
	#instVars : [
		'separators'
	],
	#category : #'NewTools-Spotter-Filters'
}

{ #category : #'accessing-defaults' }
StFilterSubstrings >> defaultSeparators [
	^ ' '
]

{ #category : #private }
StFilterSubstrings >> isMatchedItem: anItem [
	| itemName |
	itemName := self itemFilterNameFor: anItem.
	^ query allSatisfy: [ :fragment | 
		itemName includesSubstring: fragment caseSensitive: self caseSensitive ]
]

{ #category : #private }
StFilterSubstrings >> prepareFilterInContext: aSpotterContext [
	super prepareFilterInContext: aSpotterContext.
	
	separators ifNil: [  separators := self defaultSeparators  ]. " performance optimization "
	self query: (self query substrings: self separators) asSet asArray
]

{ #category : #accessing }
StFilterSubstrings >> separators [
	^ separators
]

{ #category : #accessing }
StFilterSubstrings >> separators: anObject [
	separators := anObject
]
