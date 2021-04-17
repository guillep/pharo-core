Class {
	#name : #CoResultSetTest,
	#superclass : #CoBasicCompletionTest,
	#instVars : [
		'completion'
	],
	#category : #'HeuristicCompletion-Tests-Core'
}

{ #category : #running }
CoResultSetTest >> setUp [

	super setUp.
	self completionClass addInstanceVariable: 'ba'.
	completion := CoResultSet
		fetcher: (CoInstanceVariableFetcher new
			completionClass: self completionClass).
			
	completion caseSensitive: true.
]

{ #category : #tests }
CoResultSetTest >> testBroadenFilterAfterFetchCompletionShouldBroadenResults [

	completion filterWithString: 'ba'.
	completion fetch: 1.
	completion filterWithString: 'b'.
	
	self assertEntry: completion first equals: (NECInstVarEntry contents: 'b' node: nil)
]

{ #category : #tests }
CoResultSetTest >> testBroadenFilterAfterFetchCompletionShouldBroadenResultsWhenCaseInsensitve [

	completion caseSensitive: false.
	
	completion filterWithString: 'BA'.
	completion fetch: 1.
	completion filterWithString: 'B'.

	self
		assertEntry: completion first
		equals: (NECInstVarEntry contents: 'b' node: nil)
]

{ #category : #tests }
CoResultSetTest >> testBroaderFilterCompletionShouldBroadenResults [

	completion filterWithString: 'ba'.
	completion filterWithString: 'b'.
	
	self assertEntry: completion first equals: (NECInstVarEntry contents: 'b' node: nil)
]

{ #category : #tests }
CoResultSetTest >> testBroaderFilterCompletionShouldBroadenResultsWhenCaseInsensitive [

	completion caseSensitive: false.

	completion filterWithString: 'ba'.
	completion filterWithString: 'B'.
	
	self assertEntry: completion first equals: (NECInstVarEntry contents: 'b' node: nil)
]

{ #category : #tests }
CoResultSetTest >> testCompletionWithElementsToFetchShouldHaveMore [

	self assert: completion hasMoreElements
]

{ #category : #tests }
CoResultSetTest >> testCompletionWithNoElementsToFetchShouldNotHaveMore [

	| c |
	c := CoResultSet fetcher: (CoInstanceVariableFetcher new
			completionClass: self completionClass).
	c fetchAll.	
	self deny: c hasMoreElements
]

{ #category : #tests }
CoResultSetTest >> testEnumerateShouldFetch [

	self assertEntry: completion first equals: (NECInstVarEntry contents: 'a' node: nil)
]

{ #category : #tests }
CoResultSetTest >> testFilterCompletionAfterFetchingShouldNarrowResults [

	completion fetch: 1.
	completion filterWithString: 'b'.

	self assertEntry: completion first equals: (NECInstVarEntry contents: 'b' node: nil)
]

{ #category : #tests }
CoResultSetTest >> testFilterTwiceWithSameCompletionShouldReturnSameResults [
	
	completion filterWithString: 'ba'.
	completion fetch: 2.
	completion filterWithString: 'ba'.

	self assertCollectionOfEntry: (completion first: 2) equals: { NECInstVarEntry contents: 'ba' node: nil }
]

{ #category : #tests }
CoResultSetTest >> testNarrowFilterAfterFetchCompletionShouldNarrowResults [

	completion filterWithString: 'b'.
	completion fetch: 1.
	completion filterWithString: 'ba'.

	self assertEntry: completion first equals: (NECInstVarEntry contents: 'ba' node: nil)
]

{ #category : #tests }
CoResultSetTest >> testNarrowerFilterCompletionShouldNarrowResults [

	completion filterWithString: 'b'.
	completion filterWithString: 'ba'.

	self assertEntry: completion first equals: (NECInstVarEntry contents: 'ba' node: nil)
]

{ #category : #tests }
CoResultSetTest >> testResetFilterShouldRetrievePreviousResults [

	completion filterWithString: 'b'.
	completion fetch: 5.
	completion resetFilter.

	self assertEntry: completion first equals: (NECInstVarEntry contents: 'a' node: nil)
]

{ #category : #tests }
CoResultSetTest >> testResetFilterWithNoFilterSetShouldNotAlterResults [

	completion resetFilter.

	self assertEntry: completion first equals: (NECInstVarEntry contents: 'a' node: nil)
]
