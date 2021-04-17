Class {
	#name : #RBCopyPackageTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBCopyPackageTest >> testBadName [
	self
		shouldFail: (RBCopyPackageRefactoring 
				copyPackage: #'Refactoring-Tests-Core'
				in: #'Refactoring-Tests-Core').
]

{ #category : #tests }
RBCopyPackageTest >> testCopyPackage [
	| refactoring aModel |
	refactoring := (RBCopyPackageRefactoring 
				copyPackage: #'Refactoring-Tests-Changes'
				in: #'Refactoring-Tests-Changes1').
	aModel := refactoring model.
	self executeRefactoring: refactoring.
	self assert: (aModel packageNamed: #'Refactoring-Tests-Changes1') isNotNil.
	self assert: (aModel classNamed: #RBRefactoringChangeTestCopy) category equals: #'Refactoring-Tests-Changes1'.
	self assert: (aModel classNamed: #RBRefactoringChangeManagerTestCopy) category equals: #'Refactoring-Tests-Changes1'.
	
]

{ #category : #tests }
RBCopyPackageTest >> testCopyPackageAndChangesCopyReferences [
	| refactoring aModel |
	self timeLimit: 2 minutes.
	refactoring := (RBCopyPackageRefactoring 
				copyPackage: #'Refactoring-Help'
				in: #'Refactoring-Help1').
	aModel := refactoring model.
	self executeRefactoring: refactoring.
	self assert: (aModel classNamed: #RBRefactoringClassesHelpCopy) category 
		equals: #'Refactoring-Help1'.
	self assert: (aModel classNamed: #RBRefactoringClassesHelpCopy) superclass name 
		equals: #RBClassesHelpCopy.
	self assert: ((aModel classNamed: #RBCoreClassesHelpCopy) classSide parseTreeFor: #pages) 
		equals: (self parseMethod: 'pages
	^ #(RBASTClassesHelpCopy RBRefactoringClassesHelpCopy RBBrowserEnvironmentsClassesHelpCopy)')
]

{ #category : #'failure tests' }
RBCopyPackageTest >> testExistingPackage [
	self
		shouldFail: (RBCopyPackageRefactoring 
				copyPackage: #'Refactoring-Tests-Core'
				in: #'Refactoring-Tests-Changes')
]
