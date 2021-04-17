Class {
	#name : #StFilterRegex,
	#superclass : #StUnorderedFilter,
	#instVars : [
		'regex'
	],
	#category : #'NewTools-Spotter-Filters'
}

{ #category : #private }
StFilterRegex >> applyFilterInContext: aSpotterContext error: exception [
	
	super applyFilterInContext: aSpotterContext error: exception.
	^ (StFilterSubstrings new
		caseSensitive: self caseSensitive;
		yourself) value: aSpotterContext
]

{ #category : #private }
StFilterRegex >> isMatchedItem: anItem [
	^ self regex matches: (self itemFilterNameFor: anItem)
]

{ #category : #private }
StFilterRegex >> prepareFilterInContext: aSpotterContext [
	super prepareFilterInContext: aSpotterContext.
	
	self regex: (caseSensitive " performance optimization "
		ifTrue: [ self query asRegex ] 
		ifFalse: [ self query asRegexIgnoringCase ])
]

{ #category : #accessing }
StFilterRegex >> regex [
	^ regex
]

{ #category : #accessing }
StFilterRegex >> regex: anObject [
	regex := anObject
]
