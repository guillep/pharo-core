"
I am an abstract base class for package refactorings.

All that I provide is the package name, my subclass refactorings are operating on, and a instance creation method for setting the package name and an initial namespace model.
"
Class {
	#name : #RBPackageRefactoring,
	#superclass : #RBRefactoring,
	#instVars : [
		'packageName',
		'newName'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBPackageRefactoring class >> model: aRBModel packageName: aName [ 
	^ self new
		model: aRBModel;
		packageName: aName;
		yourself
]

{ #category : #'instance creation' }
RBPackageRefactoring class >> packageName: aName [
	^self new packageName: aName
]

{ #category : #accessing }
RBPackageRefactoring >> packageName [

	^ packageName
]

{ #category : #accessing }
RBPackageRefactoring >> packageName: anObject [

	packageName := anObject
]

{ #category : #preconditions }
RBPackageRefactoring >> preconditions [ 
	^ (RBCondition withBlock: [ [ RPackage organizer includesPackageNamed: packageName ]
			on: Error 
			do: [ :e | self refactoringError: e messageText ]
		])
]
