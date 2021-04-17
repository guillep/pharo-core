Class {
	#name : #StFilterBlock,
	#superclass : #StUnorderedFilter,
	#instVars : [
		'matcher'
	],
	#category : #'NewTools-Spotter-Filters'
}

{ #category : #private }
StFilterBlock >> isMatchedItem: anItem [

	^ self matcher 
		ifNotNil: [ self matcher value: anItem value: self context ]
		ifNil: [ (self itemFilterNameFor: anItem) includesSubstring: query caseSensitive: caseSensitive ]
		
]

{ #category : #accessing }
StFilterBlock >> matcher [
	^ matcher
]

{ #category : #accessing }
StFilterBlock >> matcher: anObject [
	matcher := anObject
]
