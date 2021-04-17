"
I am a command to merge given variable into another
"
Class {
	#name : #SycMergeVariableCommand,
	#superclass : #SycRenameVariableCommand,
	#category : #'SystemCommands-VariableCommands'
}

{ #category : #accessing }
SycMergeVariableCommand class >> defaultMenuIconName [ 
	^ #merge
]

{ #category : #execution }
SycMergeVariableCommand >> classRefactoring [
	^ RBMergeInstanceVariableIntoAnother
]

{ #category : #accessing }
SycMergeVariableCommand >> defaultMenuItemName [
	^'Merge into another'
]

{ #category : #execution }
SycMergeVariableCommand >> newVariableName [

	^ newName name
]

{ #category : #execution }
SycMergeVariableCommand >> requestNewNameIn: aToolContext [
	newName := aToolContext
		           requestSimpleVariable: 'Select a variable'
		           from: (Array with: variable definingClass).
]
