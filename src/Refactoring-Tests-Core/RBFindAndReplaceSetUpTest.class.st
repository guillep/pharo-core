Class {
	#name : #RBFindAndReplaceSetUpTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #tests }
RBFindAndReplaceSetUpTest >> testClassDoesNotDefineSetUpMethod [
	| refactoring |
	refactoring := RBFindAndReplaceSetUpRefactoring 
			of: RBTest inWholeHierarchy: true.
	self shouldFail: refactoring
]

{ #category : #tests }
RBFindAndReplaceSetUpTest >> testReplaceSetUp [
	| class refactoring |
	refactoring := RBFindAndReplaceSetUpRefactoring 
			of: RBTest inWholeHierarchy: true.
	class := refactoring model classNamed: #RBTest.
	class compile: 'setUp self someClasses. aString := ''Example''.'
		classified: #(#accessing).
	self executeRefactoring: refactoring.
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
