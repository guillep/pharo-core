Class {
	#name : #RBExtractSetUpMethodTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBExtractSetUpMethodTest >> testBadClass [
	self
		shouldFail:
			(RBExtractSetUpMethodRefactoring
				extract: (78 to: 197)
				from: #displayName
				in: RBLintRuleTestData)
]

{ #category : #'failure tests' }
RBExtractSetUpMethodTest >> testBadInterval [
	self
		shouldFail:
			(RBExtractSetUpMethodRefactoring
				extract: (14 to: 35)
				from: #testExample
				in: RBDataTest)
]

{ #category : #tests }
RBExtractSetUpMethodTest >> testExtractSetUp [
	| class refactoring |
	refactoring := RBExtractSetUpMethodRefactoring
				extract: (14 to: 29)
				from: #testExample
				in: RBDataTest.
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBDataTest.

	self assert: (class parseTreeFor: #testExample) equals: (self parseMethod: 'testExample
	self assert: true').
	self assert: (class parseTreeFor: #setUp) equals: (self parseMethod: 'setUp
	super setUp.
	self someMethod')
]

{ #category : #tests }
RBExtractSetUpMethodTest >> testExtractSetUpAndConvertTempsToInstVars [
	| class refactoring |
	refactoring := RBExtractSetUpMethodRefactoring
				extract: (36 to: 77)
				from: #testExample1
				in: RBDataTest.
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBDataTest.
	self assert: (class instanceVariableNames includes: #aString). 
	self assert: (class parseTreeFor: #testExample1) equals: (self parseMethod: 'testExample1
	| aNumber |
	aNumber := 4.
	self assert: aString isNotEmpty.
	self deny: (aString , aNumber asString) isEmpty.
	self assert: true').
	self assert: (class parseTreeFor: #testExample2) equals: (self parseMethod: 'testExample2
	| aNumber |
	aString := ''sa''.
	self someMethod.
	aNumber := 4.
	self assert: aString isNotEmpty.').
	self assert: (class parseTreeFor: #setUp) equals: (self parseMethod: 'setUp
	super setUp.
	aString := ''Some string''.
	self someMethod.')
]

{ #category : #'failure tests' }
RBExtractSetUpMethodTest >> testExtractSetUpWhenIsNotFirstsSentences [
	| refactoring |
	refactoring := RBExtractSetUpMethodRefactoring
				extract: (63 to: 77)
				from: #testExample1
				in: RBDataTest.
	self shouldFail: refactoring.
]

{ #category : #'failure tests' }
RBExtractSetUpMethodTest >> testModelExistingSetUpMethod [
	| class refactoring |
	model := RBClassModelFactory rbNamespace new.
	class := model classNamed: #RBDataTest.
	class compile: 'setUp #setUp'
		classified: #(#accessing).
	refactoring := RBExtractSetUpMethodRefactoring 
				model: model
				extract: (14 to: 29)
				from: #testExample
				in: RBDataTest.
	self shouldFail: refactoring.
]
