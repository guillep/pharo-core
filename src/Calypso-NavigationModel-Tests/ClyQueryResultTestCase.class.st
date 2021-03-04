Class {
	#name : #ClyQueryResultTestCase,
	#superclass : #ClyNavigationEnvironmentTestCase,
	#instVars : [
		'queryResult',
		'query'
	],
	#category : #'Calypso-NavigationModel-Tests'
}

{ #category : #testing }
ClyQueryResultTestCase class >> isAbstract [
	^self = ClyQueryResultTestCase
]

{ #category : #running }
ClyQueryResultTestCase >> createQuery [

	^ClyQueryExampleReturningScopeBasis 
		from: (ClyScopeExample emptyIn: environment)
]

{ #category : #running }
ClyQueryResultTestCase >> createQueryResult [
	self subclassResponsibility 
]

{ #category : #running }
ClyQueryResultTestCase >> setUp [
	super setUp.
	
	query := self createQuery.
	
	queryResult := self createQueryResult prepareNewFor: query in: environment.
	queryResult cancelRebuild. 
	"by default result is in state to be rebuilt by query.
	We do not need it in tests where we usually just test fillWith: logic"
	
]

{ #category : #tests }
ClyQueryResultTestCase >> testCheckingForEmpty [
	self
		assert: queryResult isEmpty;
		deny: queryResult notEmpty
]

{ #category : #tests }
ClyQueryResultTestCase >> testComparisonWithAnotherKindOfResult [
	self deny: queryResult equals: ClyQueryResult new
]

{ #category : #tests }
ClyQueryResultTestCase >> testComparisonWithCopy [

	| queryResult2 |
	queryResult2 := queryResult copy.
	
	self assert: queryResult equals: queryResult2
]

{ #category : #tests }
ClyQueryResultTestCase >> testComparisonWithItself [

	self assert: queryResult equals: queryResult
]

{ #category : #tests }
ClyQueryResultTestCase >> testComparisonWithSimilarResult [

	| queryResult2 |
	queryResult := self createQueryResult.
	queryResult2 := self createQueryResult.
	
	self assert: queryResult equals: queryResult2.
	self assert: queryResult hash equals: queryResult2 hash
]

{ #category : #tests }
ClyQueryResultTestCase >> testForceLazyRebuild [
	
	self assert: queryResult items notNil.
	
	queryResult forceLazyRebuild.
	
	self assert: queryResult needsRebuild
]

{ #category : #tests }
ClyQueryResultTestCase >> testIsBuiltWhenItemsExist [
	
	queryResult initializeItems.
	
	self assert: queryResult isBuilt
]

{ #category : #tests }
ClyQueryResultTestCase >> testItemsChangedNotificationShouldResetItems [
	
	queryResult initializeItems.
	self assert: queryResult isBuilt.
	
	queryResult itemsChanged.
	
	self deny: queryResult isBuilt.
	self assert: queryResult items isNil
]

{ #category : #tests }
ClyQueryResultTestCase >> testNeedsRebuildByDefault [
	
	queryResult := self createQueryResult.
	
	self assert: queryResult needsRebuild 
]

{ #category : #tests }
ClyQueryResultTestCase >> testPreparation [
	| newQuery newResult |
	newQuery := self createQuery.
	newResult := queryResult prepareNewFor: newQuery in: environment.

	self assert: newResult class equals: queryResult class.
	self deny: newResult identicalTo: queryResult.
	self assert: newResult buildingQuery identicalTo: newQuery.
	self assert: newResult environment equals: environment.
	self assert: newResult isProtected
]
