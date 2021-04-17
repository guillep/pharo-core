Class {
	#name : #RBExtractToTemporaryTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBExtractToTemporaryTest >> testBadInterval [
	self
		shouldFail:
			(RBExtractToTemporaryRefactoring
				extract: (24 to: 30)
				to: 'asdf'
				from: #testMethod
				in: RBRefactoryTestDataApp);
		shouldFail:
			(RBExtractToTemporaryRefactoring
				extract: (14 to: 105)
				to: 'asdf'
				from: #testMethod1
				in: RBRefactoryTestDataApp);
		shouldFail:
			(RBExtractToTemporaryRefactoring
				extract: (61 to: 101)
				to: 'asdf'
				from: #noMoveDefinition
				in: RBRefactoryTestDataApp)
]

{ #category : #'failure tests' }
RBExtractToTemporaryTest >> testBadName [
	self
		shouldFail:
			(RBExtractToTemporaryRefactoring
				extract: (14 to: 23)
				to: 'a sdf'
				from: #testMethod
				in: RBRefactoryTestDataApp)
]

{ #category : #tests }
RBExtractToTemporaryTest >> testExtractToTemporaryForLastStatementInBlock [
	| refactoring methodName |
	methodName := ('caller', '2') asSymbol.
	refactoring := RBExtractToTemporaryRefactoring
		extract: (52 to: 73)
		to: 'temp'
		from: methodName
		in: RBRefactoryTestDataApp.
	self executeRefactoring: refactoring.

	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: methodName) equals: (self parseMethod: 'caller2
	^(1 to: 10) inject: 1 into: [:sum :each | | temp | temp := sum * (self foo: each). temp]')
]

{ #category : #tests }
RBExtractToTemporaryTest >> testExtractToTemporaryInsideBlock [
	| refactoring |
	refactoring := RBExtractToTemporaryRefactoring
		extract: (133 to: 141)
		to: 'asdf'
		from: #noMoveDefinition
		in: RBRefactoryTestDataApp.
	self executeRefactoring: refactoring.

	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: #noMoveDefinition) equals: (self parseMethod: 'noMoveDefinition
	| temp |
	^(self collect: 
			[:each | 
			temp := each printString.
			temp , temp]) 
		select: [:each | | asdf | asdf := each size. temp := asdf + temp]')
]

{ #category : #tests }
RBExtractToTemporaryTest >> testExtractToTemporaryWithDuplicates [
	| refactoring |
	refactoring := RBExtractToTemporaryRefactoring 
		extract: (73 to: 77)
		to: 'temp'
		from: #demoMethodWithDuplicates
		in: RBRefactoryTestDataApp.
	self executeRefactoring: refactoring.
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: #demoMethodWithDuplicates) equals: (self parseMethod: 'demoMethodWithDuplicates
	| a b result1 result2 answer temp |
	a := 3.
	temp := a + 5.
	b := temp.
	result1 := a + b.
	result2 := temp.
	answer := result1 + result2 + temp.
	^ answer')
]

{ #category : #'failure tests' }
RBExtractToTemporaryTest >> testNoValidNameOfTemp [
	self shouldFail: (RBExtractToTemporaryRefactoring 
			extract: (51 to: 60)
			to: 'collection'
			from: #modifiesCollection
			in: RBRefactoryTestDataApp)
]

{ #category : #'failure tests' }
RBExtractToTemporaryTest >> testNonExistantSelector [
	self shouldFail: (RBExtractToTemporaryRefactoring 
			extract: (14 to: 23)
			to: 'asdf'
			from: #checkClass1:
			in: RBRefactoryTestDataApp)
]
