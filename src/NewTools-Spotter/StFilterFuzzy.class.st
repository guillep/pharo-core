Class {
	#name : #StFilterFuzzy,
	#superclass : #StOrderedFilter,
	#category : #'NewTools-Spotter-Filters'
}

{ #category : #private }
StFilterFuzzy >> applyFilterWithQuery [
	
	| result |

	result := FuzzyMatcher allSortedByScoreMatching: query 
		in: self allItems
		by: [ :each | self itemFilterNameFor: each ].
	
	self 
		addItems: (result takeFirst: self itemsLimit);
		filteredItems: result

]
