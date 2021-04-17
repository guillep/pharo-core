Class {
	#name : #RBExtractSetUpMethodAndOccurrencesTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBExtractSetUpMethodAndOccurrencesTest >> testBadInterval [
	| refactoring |
	refactoring := RBExtractSetUpMethodAndOccurrences
				extract: (36 to: 56)
				from: #testExample1
				in: RBTest.
	self setupSearchInAllHierarchyFor: refactoring toReturn: true.
	self shouldFail: refactoring.
]

{ #category : #'failure tests' }
RBExtractSetUpMethodAndOccurrencesTest >> testBadMethodName [
	| refactoring |
	refactoring := RBExtractSetUpMethodAndOccurrences
				extract: (36 to: 56)
				from: #testExample7
				in: RBTest.
	self setupSearchInAllHierarchyFor: refactoring toReturn: true.
	self shouldFail: refactoring.
]

{ #category : #tests }
RBExtractSetUpMethodAndOccurrencesTest >> testExtractSimpleMethodAndOcurrences [
	|class refactoring|
	refactoring := RBExtractSetUpMethodAndOccurrences
				extract: (17 to: 56)
				from: #testExample1
				in: RBTest.
	self setupSearchInAllHierarchyFor: refactoring toReturn: true.
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBTest.
	self assert: (class parseTreeFor: #setUp) 
		equals: (self parseMethod: 'setUp
		super setUp. self someClasses. aString := ''Example''').
	self assert: (class parseTreeFor: #testExample1) 
		equals: (self parseMethod: 'testExample1 
		self assert: 4 > 5 equals: false').
	self assert: (class parseTreeFor: #testExample2) 
		equals: (self parseMethod: 'testExample2
		self assert: true').
	self assert: (class parseTreeFor: #testExample3) 
		equals: (self parseMethod: 'testExample3
		self deny: false').
	self assert: (class parseTreeFor: #testExample4) 
		equals: (self parseMethod: 'testExample4
		self assert: true.
		self deny: false').
]
