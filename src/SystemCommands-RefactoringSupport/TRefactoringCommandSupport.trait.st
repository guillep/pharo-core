Trait {
	#name : #TRefactoringCommandSupport,
	#instVars : [
		'model'
	],
	#category : #'SystemCommands-RefactoringSupport'
}

{ #category : #initialization }
TRefactoringCommandSupport >> initializeDefaultOptionsOf: refactoring [

	NautilusRefactoring new refactoringOptions: refactoring
]

{ #category : #initialization }
TRefactoringCommandSupport >> setUpModelFromContext: aContext [
	| browser scope |
	browser := aContext browser.
	scope := browser defaultNavigationScope.
	model := RBClassModelFactory rbNamespace onEnvironment: scope asRBEnvironment
]
