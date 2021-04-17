Class {
	#name : #RBRemoveClassKeepingSubclassesTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #tests }
RBRemoveClassKeepingSubclassesTest >> testRemoveClassWithReferencesRaisesRBRefactoringError [
	self shouldFail: (RBRemoveClassKeepingSubclassesRefactoring classNames: #(#RBBasicLintRuleTestData ))
]

{ #category : #tests }
RBRemoveClassKeepingSubclassesTest >> testRemoveNotEmptySuperclass [

	| refactoring class removedClass subclass |
	
	removedClass := ('RBTransformation' , 'RuleTestData1') asSymbol.
	subclass := ('RBTransformation' , 'RuleTestData2') asSymbol.
	refactoring := RBRemoveClassKeepingSubclassesRefactoring classNames:
		               { removedClass }. 
	class := refactoring model classNamed: subclass.
	self deny: (class directlyDefinesMethod: #foo).
	self executeRefactoring: refactoring.
	self assert: (refactoring model classNamed: removedClass) isNil.
	self
		assert: class superclass
		equals: (refactoring model classNamed: #RBFooLintRuleTestData1).
	self assert: (class directlyDefinesMethod: #foo)
]
