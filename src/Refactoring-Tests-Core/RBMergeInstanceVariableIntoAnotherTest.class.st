Class {
	#name : #RBMergeInstanceVariableIntoAnotherTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBMergeInstanceVariableIntoAnotherTest >> testNonExistingVariable [
	self shouldFail: (RBMergeInstanceVariableIntoAnother 
			rename: 'classBlock'
			to: 'anInstVar1'
			in: RBBasicLintRuleTestData)
]

{ #category : #tests }
RBMergeInstanceVariableIntoAnotherTest >> testReplaceVariableIntoAnother [
	| refactoring class |
	refactoring := RBMergeInstanceVariableIntoAnother 
			rename: 'classBlock'
			to: 'anInstVar'
			in: RBBasicLintRuleTestData.
	class := refactoring model classNamed: #RBBasicLintRuleTestData.
	self assert: (class whichSelectorsReferToInstanceVariable: 'classBlock') isNotEmpty.
	self executeRefactoring: refactoring.
	
	self assert: (class whichSelectorsReferToInstanceVariable: 'classBlock') isEmpty.
]

{ #category : #tests }
RBMergeInstanceVariableIntoAnotherTest >> testReplaceVariableIntoSupeclassVariable [
	| refactoring class |
	refactoring := RBMergeInstanceVariableIntoAnother 
			rename: 'name'
			to: 'classBlock'
			in: RBBasicLintRuleTestData.
	class := refactoring model classNamed: #RBBasicLintRuleTestData.
	self assert: (class whichSelectorsReferToInstanceVariable: 'name') isNotEmpty.
	self executeRefactoring: refactoring.
	self assert: (class definesInstanceVariable: 'name').
	self assert: (class directlyDefinesInstanceVariable: 'classBlock').
	
	self assert: (class whichSelectorsReferToInstanceVariable: 'name') isEmpty.
]
