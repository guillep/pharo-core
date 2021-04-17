"
I am a complex processor that unifies queries from: Classes, Implementors and Packages.
I can handle filtering by categories, so to have different behavior when the query includes #Classes, #Packages, #Implementors.
I configure the keymapping for the categories in spotter.

My source is a complex one: 
 
 - I will filter the duplicates out.
 - I will configure it using the categories in the query.
 - I have two behaviors, depending of the case of query. If it is uppercase, I will search first in implementors, then in classes and then in packages. If it is lowercase I will search in classes, packages and then implementors.
 - I first search for matches starting with the query and then for matches with the query in any place of the entry.
"
Class {
	#name : #StUnifiedProcessor,
	#superclass : #StSpotterProcessor,
	#instVars : [
		'categories'
	],
	#category : #'NewTools-Spotter-Processors-Processors'
}

{ #category : #'default-settings' }
StUnifiedProcessor class >> defaultEnabled [

	^ true
]

{ #category : #accessing }
StUnifiedProcessor class >> order [
	
	^ 100
]

{ #category : #settings }
StUnifiedProcessor class >> settingsDescription [

	^ 'I am the main processor: I show classes, packages and implementors'
]

{ #category : #settings }
StUnifiedProcessor class >> settingsTitle [

	^ 'Classes, Implementors & Packages'
]

{ #category : #accessing }
StUnifiedProcessor class >> title [

	^ 'Results'
]

{ #category : #sources }
StUnifiedProcessor >> calculateLowercaseSourcesOn: anStream [

	| implementorsBeginsWith implementorsSubstring wordsAwareImplementors |

	(self categoriesIncludes: #Implementors) 
		ifFalse: [ ^ self ].

	implementorsBeginsWith := StSourceFactory current implementorsBeginsWithSource.
	implementorsSubstring := StSourceFactory current implementorsSubstringSource.
	wordsAwareImplementors := StWordsAwareFilter new 
		inner: (StSourceFactory current implementorsSubstringSource); 
		yourself.
	
	textFilteringIterators add: implementorsBeginsWith.
	textFilteringIterators add: implementorsSubstring.
	textFilteringIterators add: wordsAwareImplementors.
	
	anStream nextPut: implementorsBeginsWith.
	anStream nextPut: implementorsSubstring.
	anStream nextPut: wordsAwareImplementors 

]

{ #category : #sources }
StUnifiedProcessor >> calculateUppercaseSourcesOn: anStream [
	| classesBeginsWith classesIncludesString packagesBeginsWith packagesIncludesString wordsAwareClassesSource wordsAwarePackageSource classAndSelectorImplementors |
	
	(self categoriesIncludes: #Classes) 
		ifTrue: [
			classesBeginsWith := StSourceFactory current classesBeginsWithSource.			
			textFilteringIterators add: classesBeginsWith.
			anStream nextPut: classesBeginsWith ].

	(self categoriesIncludes: #Packages) 
		ifTrue: [
			packagesBeginsWith := (StPackageIterator new 
				collect: [ :each | StPackageEntry on: each ]) 
				asBeginsWithFilter.			
			textFilteringIterators add: packagesBeginsWith.
			anStream nextPut: packagesBeginsWith ].

	(self categoriesIncludes: #Classes) 
		ifTrue: [
			classesIncludesString := StSourceFactory current classesSubstringSource.
			textFilteringIterators add: classesIncludesString.
			anStream nextPut: classesIncludesString ].
		
	(self categoriesIncludes: #Packages) 
		ifTrue: [
			packagesIncludesString := (StPackageIterator new 
				collect: [ :each | StPackageEntry on: each ]) 
				asSubstringFilter.		
			textFilteringIterators add: packagesIncludesString.
			anStream nextPut: packagesIncludesString ].
		
	(self categoriesIncludes: #Classes) 
		ifTrue: [
			wordsAwareClassesSource := StWordsAwareFilter new 
				inner: (StSourceFactory current classesSubstringSource); 
				yourself.
			textFilteringIterators add: wordsAwareClassesSource.
			anStream nextPut: wordsAwareClassesSource ].

	(self categoriesIncludes: #Implementors) 
		ifTrue: 	[ 	
			classAndSelectorImplementors := StClassWithSelectorWordFilter new 
				inner: (StSourceFactory current implementorsSubstringSource); 
				yourself.
			textFilteringIterators add: classAndSelectorImplementors.
			anStream nextPut: classAndSelectorImplementors ].

	(self categoriesIncludes: #Packages) 
		ifTrue: [
			wordsAwarePackageSource := StWordsAwareFilter new 
				inner: ((StPackageIterator new 
					collect: [ :each | StPackageEntry on: each ]) 
					asSubstringFilter); 
				yourself.
			textFilteringIterators add: wordsAwarePackageSource.
			anStream nextPut: wordsAwarePackageSource ]
]

{ #category : #sources }
StUnifiedProcessor >> categoriesIncludes: aCategory [

	^ categories isNil 
		or: [ categories isEmpty 
		or: [ (categories includes: aCategory)
		or: [ categories anySatisfy: [ :each | aCategory asLowercase beginsWith: each asLowercase ] ] ] ]
]

{ #category : #'spotter-api' }
StUnifiedProcessor >> classesTag [

	^ #Classes
]

{ #category : #filtering }
StUnifiedProcessor >> configureFilter [

	(categories ~= self query categoriesSelected)
		ifTrue: [
			categories := self query categoriesSelected.
			filter := nil ].

	super configureFilter.
	
	"I will clear the duplicates, as a new query have done"
	filter clearDuplicates
]

{ #category : #'spotter-api' }
StUnifiedProcessor >> implementorsTag [

	^ #Implementors
]

{ #category : #'key-bindings' }
StUnifiedProcessor >> installKeymappingsOn: aPresenter onExecution: aBlock [

	aPresenter
		bindKeyCombination: $b meta
		toAction: [
			self query toggleFilter: self classesTag.
			aBlock cull: self ].

	aPresenter
		bindKeyCombination: $m meta
		toAction: [ 
			self query toggleFilter: self implementorsTag.
			aBlock cull: self ].
		
	aPresenter
		bindKeyCombination: $p meta
		toAction: [ 
			self query toggleFilter: self packagesTag.
			aBlock cull: self ]	
]

{ #category : #'spotter-api' }
StUnifiedProcessor >> isRelevantForQuery: aString [ 
	
	^ true
]

{ #category : #filtering }
StUnifiedProcessor >> newSource [
	| uppercaseIterators lowercaseIterators caseSelectorIterator root |
	
	textFilteringIterators := OrderedCollection new.
	lowercaseIterators := OrderedCollection streamContents: [ :stream | 
		self calculateLowercaseSourcesOn: stream ].
	uppercaseIterators := OrderedCollection streamContents: [ :stream | 
		self calculateUppercaseSourcesOn: stream ].

	caseSelectorIterator := StCaseSelectorIterator new 
		lowercaseIterator: (StSequenceIterator with: lowercaseIterators);
		uppercaseIterator: (StSequenceIterator with: uppercaseIterators).
		
	textFilteringIterators add: caseSelectorIterator.
	
	root := caseSelectorIterator asWithoutDuplicates.
		
	^ root
]

{ #category : #filtering }
StUnifiedProcessor >> newTextFilteringSource [
	"It should not arrive here"
	^ nil
]

{ #category : #'spotter-api' }
StUnifiedProcessor >> packagesTag [

	^ #Packages
]
