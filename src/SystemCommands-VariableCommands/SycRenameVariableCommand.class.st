"
I am a command to remove given variable.

My #variable should be compatible variable object like ClassVariable or Slot. Or Calypso provide ClyVariable subclasses.

Internal Representation and Key Implementation Points.

    Instance Variables
	newName:		<String>
	variable:		<Variable>

"
Class {
	#name : #SycRenameVariableCommand,
	#superclass : #CmdCommand,
	#instVars : [
		'newName',
		'variable'
	],
	#category : #'SystemCommands-VariableCommands'
}

{ #category : #testing }
SycRenameVariableCommand class >> canBeExecutedInContext: aToolContext [
	^aToolContext isVariableSelected and: [ aToolContext isGlobalVariableSelected not ]
]

{ #category : #accessing }
SycRenameVariableCommand class >> defaultMenuIconName [ 
	^ #edit
]

{ #category : #execution }
SycRenameVariableCommand >> applyResultInContext: aToolContext [
	super applyResultInContext: aToolContext.
	aToolContext showVariableNamed: newName
]

{ #category : #execution }
SycRenameVariableCommand >> classRefactoring [

	^ RBRenameInstanceVariableRefactoring
]

{ #category : #accessing }
SycRenameVariableCommand >> defaultMenuItemName [
	^'Rename'
]

{ #category : #execution }
SycRenameVariableCommand >> execute [

	| refactoring |
	refactoring := variable createVariableRefactoring:
		               self classRefactoring.
	refactoring newName: self newVariableName.

	refactoring execute
]

{ #category : #accessing }
SycRenameVariableCommand >> newName [
	^ newName
]

{ #category : #accessing }
SycRenameVariableCommand >> newName: anObject [
	newName := anObject
]

{ #category : #execution }
SycRenameVariableCommand >> newVariableName [

	^ newName asSymbol
]

{ #category : #execution }
SycRenameVariableCommand >> prepareFullExecutionInContext: aToolContext [

	super prepareFullExecutionInContext: aToolContext.
	variable := aToolContext lastSelectedVariable.
	self requestNewNameIn: aToolContext
]

{ #category : #execution }
SycRenameVariableCommand >> requestNewNameIn: aToolContext [

	newName := UIManager default
		           request: 'New name of the variable'
		           initialAnswer: variable name
		           title: 'Rename a variable'.
	newName isEmptyOrNil | (newName = variable name) ifTrue: [ 
		CmdCommandAborted signal ]
]

{ #category : #accessing }
SycRenameVariableCommand >> variable [
	^ variable
]

{ #category : #accessing }
SycRenameVariableCommand >> variable: anObject [
	variable := anObject
]
