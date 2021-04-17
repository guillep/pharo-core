"
I am the main entry point of the completion system.
I am built from a (potentially composed) fetcher and a filter-string.

When asked for results, I fetch them from the fetcher.
Internally, I keep also a list of already fetched results to avoid fetching many times the same.
This is particularly useful when the filter is being narrowed (e.g., we go from a filter 'ab' to a filter 'abc').
In such a case, some of the results already fetched are still valid, and the fetcher state is valid too.
  => we then filter the subresults and change the fetcher filter
In case the filter is being broadened (e.g., we go from 'abc' to 'ab'), all results we already have are valid, but probably lots of other results were filtered already. So we reset both the results and the fetcher and restart the search.
"
Class {
	#name : #CoResultSet,
	#superclass : #Object,
	#instVars : [
		'results',
		'fetcher',
		'completionString',
		'caseSensitive'
	],
	#category : #'HeuristicCompletion-Model-Core'
}

{ #category : #'instance creation' }
CoResultSet class >> fetcher: aFetcher [
	
	^ self new
		fetcher: aFetcher;
		yourself
]

{ #category : #'instance creation' }
CoResultSet class >> onContext: aCompletionContext fetcher: aFetcher [
	
	^ self new
		fetcher: aFetcher;
		yourself
]

{ #category : #accessing }
CoResultSet >> caseSensitive [

	^ caseSensitive
]

{ #category : #accessing }
CoResultSet >> caseSensitive: anObject [

	caseSensitive := anObject
]

{ #category : #accessing }
CoResultSet >> completionToken [
	
	^ completionString
]

{ #category : #'api-filtering' }
CoResultSet >> does: aCandidate matches: aLookupString [

	| aLookupStringToUse aCandidateString |

	caseSensitive 
		ifTrue: [
			aLookupStringToUse := aLookupString.
			aCandidateString := aCandidate contents]  
		ifFalse: [
			aLookupStringToUse := aLookupString asLowercase.
			aCandidateString := aCandidate contents asLowercase ].
	
	^ aLookupString isEmpty or: [ aCandidateString beginsWith: aLookupStringToUse ]
]

{ #category : #enumerating }
CoResultSet >> ensureResults: aSize [
	
	results size >= aSize ifTrue: [ ^ self ].
	self fetch: aSize - results size.
]

{ #category : #fetching }
CoResultSet >> fetch: anInteger [ 
	
	| newResults |
	newResults := fetcher next: anInteger.
	results addAll: newResults
]

{ #category : #fetching }
CoResultSet >> fetchAll [
	
	results addAll: fetcher upToEnd
]

{ #category : #accessing }
CoResultSet >> fetcher [
	^ fetcher
]

{ #category : #accessing }
CoResultSet >> fetcher: anObject [

	fetcher := anObject
]

{ #category : #'api-filtering' }
CoResultSet >> filterWithString: aString [

	"Narrow results"

	aString size >= completionString size
		ifTrue: [ "Filter existing results"
			fetcher := fetcher narrowFilterBlock: [ :e | 
				 self does: e matches: aString ].
			results := results select: [ :e | 
				self does: e matches: aString ] ]
		ifFalse: [ "Smaller filter, reset results and filter"
			results := OrderedCollection new.
			fetcher reset.
			fetcher := fetcher select: [ :e | self does: e matches: aString ] ].
	completionString := aString
]

{ #category : #enumerating }
CoResultSet >> first [
	
	self ensureResults: 1.
	^ results first
]

{ #category : #accessing }
CoResultSet >> first: anInteger [ 

	self ensureResults: anInteger.	
	
	results size > anInteger
		ifTrue: [ ^ results first: anInteger ].
	^ results
]

{ #category : #testing }
CoResultSet >> hasMoreElements [
	
	^ fetcher atEnd not
]

{ #category : #initialization }
CoResultSet >> initialize [

	super initialize.
	results := OrderedCollection new.
	completionString := ''.
]

{ #category : #testing }
CoResultSet >> notEmpty [
	
	^ results notEmpty or: [ fetcher atEnd not ]
]

{ #category : #'api-filtering' }
CoResultSet >> resetFilter [
	
	results removeAll.
	fetcher := fetcher withoutFilter.
]

{ #category : #accessing }
CoResultSet >> results [
	^ results
]

{ #category : #accessing }
CoResultSet >> results: anObject [
	results := anObject
]
