Class {
	#name : #RBRenamePackageTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBRenamePackageTest >> testBadName [
	self
		shouldFail: (RBRenamePackageRefactoring 
				rename: #'Refactoring-Tests-Core'
				to: #'Refactoring-Tests-Core')
]

{ #category : #'failure tests' }
RBRenamePackageTest >> testExistingPackage [
	self
		shouldFail: (RBRenamePackageRefactoring 
				rename: #'Refactoring-Tests-Core'
				to: #'Refactoring-Tests-Changes')
]

{ #category : #tests }
RBRenamePackageTest >> testRenamePackage [
	| refactoring aModel |
	
	refactoring := (RBRenamePackageRefactoring 
				rename: #'Refactoring-Tests-Core'
				to: #'Refactoring-Tests-Core1').
	aModel := refactoring model.
	self executeRefactoring: refactoring.
	self assert: (aModel packageNamed: #'Refactoring-Tests-Core') isNil.
	self assert: (aModel packageNamed: #'Refactoring-Tests-Core1') isNotNil.
	
]
