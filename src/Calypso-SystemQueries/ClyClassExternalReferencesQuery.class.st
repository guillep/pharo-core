Class {
	#name : #ClyClassExternalReferencesQuery,
	#superclass : #ClyClassReferencesQuery,
	#category : #'Calypso-SystemQueries-Queries'
}

{ #category : #execution }
ClyClassExternalReferencesQuery >> buildResult: aQueryResult [
	| toExclude |
	
	super buildResult: aQueryResult.
	toExclude := self variableQuery resultItems flatCollect: [ :each | { each . each classSide } ].
	aQueryResult items removeAllSuchThat: [ :each | toExclude includes: each origin ]
]
