Class {
	#name : #BaselineOfSystemCommands,
	#superclass : #BaselineOf,
	#category : #BaselineOfSystemCommands
}

{ #category : #baselines }
BaselineOfSystemCommands >> baseline: spec [
	<baseline>
	| repository |
	repository := self packageRepositoryURL.
	spec
		for: #common
		do: [ spec baseline: 'Commander' with: [ spec repository: repository ].
			spec
				package: #'SystemCommands-RefactoringSupport'
					with: [ spec requires: #('Commander') ];
				package: #'SystemCommands-ClassCommands'
					with:
						[ spec requires: #('Commander' #'SystemCommands-RefactoringSupport') ];
				package: #'SystemCommands-ClassCommands-Tests'
					with:
						[ spec requires: #(#'SystemCommands-ClassCommands') ];
				package: #'SystemCommands-MessageCommands'
					with:
						[ spec requires: #('Commander' #'SystemCommands-RefactoringSupport') ];
				package: #'SystemCommands-MethodCommands'
					with:
						[ spec requires: #('Commander' #'SystemCommands-RefactoringSupport') ];
				package: #'SystemCommands-MethodCommands-Tests'
					with:
						[ spec requires: #('SystemCommands-MethodCommands') ];
				package: #'SystemCommands-PackageCommands'
					with: [ spec requires: #('Commander') ];
				package: #'SystemCommands-SourceCodeCommands'
					with:
						[ spec requires: #('Commander' #'SystemCommands-RefactoringSupport') ];
				package: #'SystemCommands-VariableCommands'
					with:
						[ spec requires: #('Commander' #'SystemCommands-RefactoringSupport') ];
				package: #'SystemCommands-RefactoringSupport-Tests'
					with: [ spec requires: #(#'SystemCommands-RefactoringSupport') ] ]
]
