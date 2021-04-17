"
I am the reification of a Spotter query.
I know how to parse the search string and returns the categories selected (#Classes, #Implementors, etc) and the look up string.
I also handle how to return the results to spotter and how to update the searching morph when a category change.

I am updated from a Spotter context (updateFromContext:), and I update the search bar with #updateSearchingMorph.

The processors talk with me to add results to the query, and later show them (#addResult: #informAllResultAmount:).

I am also configurable to filter classes, implementors or add another modified.
"
Class {
	#name : #StQuery,
	#superclass : #Object,
	#instVars : [
		'query',
		'spotterContext',
		'processor',
		'modifiers'
	],
	#category : #'NewTools-Spotter-Processors-Query'
}

{ #category : #results }
StQuery >> addResult: anEntry [

	spotterContext stream
		performSymbol: #addCandidate:in:
		withArguments: { anEntry. processor }
]

{ #category : #accessing }
StQuery >> categoriesSelected [

	^ modifiers copy
]

{ #category : #testing }
StQuery >> hasAnyCategory [

	^ self categoriesSelected notEmpty
]

{ #category : #testing }
StQuery >> hasCategoryMatching: aSymbol [

	^ self categoriesSelected anySatisfy: [ :each | each asLowercase beginsWith: aSymbol ]
]

{ #category : #results }
StQuery >> informAllResultAmount: anInteger [ 

	spotterContext stream
		performSymbol: #onAmountChanged:in:
		withArguments: { anInteger. processor }.
	
]

{ #category : #initialization }
StQuery >> initialize [

	super initialize.
	modifiers := OrderedCollection new.
	query:= ''.
]

{ #category : #testing }
StQuery >> isSearchEmpty [

	^ query isEmpty
]

{ #category : #accessing }
StQuery >> processor [

	^ processor
]

{ #category : #accessing }
StQuery >> processor: aProcessor [

	processor := aProcessor
]

{ #category : #accessing }
StQuery >> searchingText [
	
	^ query
]

{ #category : #accessing }
StQuery >> textInSearchBar [

	^ String streamContents: [ :stream | 
		modifiers do: [ :each | stream print:each; space ].
		stream nextPutAll: query ]
]

{ #category : #configuring }
StQuery >> toggleFilter: filterTag [

	(modifiers includes: filterTag) 
		ifTrue: [ modifiers remove: filterTag ]
		ifFalse: [ modifiers add: filterTag ]
]

{ #category : #updating }
StQuery >> updateFromContext: aSpotterContext [
	| textParts texts |

	modifiers removeAll.
	texts := (aSpotterContext search ifNil:[ '' ]) trimBoth.
	textParts := texts substrings: { Character space. Character tab }.
	query := ''.
	
	textParts do: [ :aPart | 
		((aPart beginsWith: '#') 
			and: [ ((texts copyWithout: Character space) includesSubstring: '>>#') not ])
			ifTrue: [ modifiers add: aPart allButFirst asSymbol ]
			ifFalse: [ query := (query, ' ', aPart) trimBoth ] ].

	spotterContext := aSpotterContext
]
