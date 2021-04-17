"
This is the chapter of the refactoring help book about the package refactoring available in the System Browser.
"
Class {
	#name : #RBBrowserPackageRefactoringHelp,
	#superclass : #RBBrowserSupportHelp,
	#category : #'Refactoring-Help'
}

{ #category : #accessing }
RBBrowserPackageRefactoringHelp class >> bookName [
	^ 'Package Refactorings'
]

{ #category : #accessing }
RBBrowserPackageRefactoringHelp class >> pages [ 
	^ #(renamePackage)
]

{ #category : #transforming }
RBBrowserPackageRefactoringHelp class >> renamePackage [
	^HelpTopic
		title: 'Rename'
		contents: RBRenamePackageRefactoring comment

]
