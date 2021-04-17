Class {
	#name : #StFilterSubstring,
	#superclass : #StOrderedFilter,
	#category : #'NewTools-Spotter-Filters'
}

{ #category : #private }
StFilterSubstring >> doApplyFilterWithQuery [
	| exactMatches prefixMatches otherMatches nonExactMatches |
	"we want to distinguish between exact matches"
	exactMatches := OrderedCollection new.
	"... results for which the query matches the prefix"
	prefixMatches := OrderedCollection new.	
	"... and the rest of the results"
	otherMatches := OrderedCollection new.

	self allItemsDo: [ :each | 
		| index queryString itemName |
		itemName := self itemFilterNameFor: each.
		queryString := self queryForItem: each.
		index := self indexForItemName: itemName andQuery: queryString.
		index >= 1 ifTrue: [
			index = 1 
				ifTrue: [ 
					itemName size = queryString size 
						ifTrue: [ 
							exactMatches add: each.
							self addItem: each.
														
							exactMatches size = self itemsLimit ifTrue: [ 
								self filteredItems: exactMatches.
								StLimitArrived signal	] ]							
						ifFalse: [ prefixMatches add: each ] ]
				ifFalse: [ otherMatches add: each ] ] ].
	nonExactMatches := prefixMatches, otherMatches.
	(exactMatches size < self itemsLimit) ifTrue: [ 
		| restVisibleItems |
		restVisibleItems := nonExactMatches first: ((self itemsLimit - exactMatches size) min: nonExactMatches size).
		self addItems: restVisibleItems ].
	self filteredItems: exactMatches, nonExactMatches
]

{ #category : #private }
StFilterSubstring >> indexForItemName: aString andQuery: aQueryString [
	^ aString 
		findString: aQueryString
		startingAt: 1 
		caseSensitive: self caseSensitive
]

{ #category : #private }
StFilterSubstring >> queryForItem: each [
	^ query " performance optimization "
]
