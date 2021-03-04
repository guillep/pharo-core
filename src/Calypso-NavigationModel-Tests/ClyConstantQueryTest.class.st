Class {
	#name : #ClyConstantQueryTest,
	#superclass : #ClyTypedQueryTestCase,
	#category : #'Calypso-NavigationModel-Tests'
}

{ #category : #running }
ClyConstantQueryTest >> createQuery [

	^ self createQuery: #( #item1 #item2 )
]

{ #category : #running }
ClyConstantQueryTest >> createQuery: aCollection [

	^ ClyConstantQuery
		  returning: aCollection
		  from: (ClyScopeExample emptyIn: environment)
]

{ #category : #tests }
ClyConstantQueryTest >> testCheckingForEmptyResult [

	| empty notEmpty |
	empty := self createQuery: #().
	notEmpty := self createQuery.
	self assert: empty checkEmptyResult;
		deny: notEmpty checkEmptyResult.
]

{ #category : #tests }
ClyConstantQueryTest >> testComparisonToSimilarQueryWhichReturningDifferentObjects [
	| query2 |
	query2 := self createQuery.
	query2 resultItems: #(anotherResult).

	self deny: query equals: query2
]

{ #category : #tests }
ClyConstantQueryTest >> testConvertingToAsyncQuery [
	| convertedQuery |
	convertedQuery := query async.

	self assert: convertedQuery identicalTo: query
]

{ #category : #tests }
ClyConstantQueryTest >> testConvertingToSemiAsyncQuery [
	| convertedQuery |
	convertedQuery := query semiAsync.

	self assert: convertedQuery identicalTo: query
]

{ #category : #tests }
ClyConstantQueryTest >> testExecution [

	self executeQuery.
	
	self assert: resultItems asArray equals: query resultItems
]
