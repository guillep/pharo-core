Extension { #name : #Slot }

{ #category : #'*SystemCommands-VariableCommands' }
Slot >> createRefactoring: variableRefactoringClass for: declarationClass [
	^variableRefactoringClass 
			variable: self name
			class: declarationClass
]

{ #category : #'*SystemCommands-VariableCommands' }
Slot >> createRefactoring: variableRefactoringClass for: declarationClass in: aModel [
	^variableRefactoringClass 
			model: aModel
			variable: self name
			class: declarationClass
]
