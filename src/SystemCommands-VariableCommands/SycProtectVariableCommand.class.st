"
I am a command to protect given variables
"
Class {
	#name : #SycProtectVariableCommand,
	#superclass : #SycRefactorVariableCommand,
	#category : #'SystemCommands-VariableCommands'
}

{ #category : #activation }
SycProtectVariableCommand class >> sourceCodeMenuActivation [
	<classAnnotation>
	
	^SycSourceCodeMenuActivation byRootGroupItemOrder: 1.2 for: ClySourceCodeContext 
]

{ #category : #execution }
SycProtectVariableCommand >> asRefactorings [

	^self 
		createRefactorings: RBProtectInstanceVariableRefactoring 
		using: [ :refactoring :var |
			refactoring variable: var name class: var definingClass ]
]

{ #category : #accessing }
SycProtectVariableCommand >> defaultMenuIconName [ 
	^ #group
]

{ #category : #accessing }
SycProtectVariableCommand >> defaultMenuItemName [
	^'Protect'
]
