"
I command to launch the Abstract refactorings: create accessors and abstract the direct instance variable uses into accessors. 
"
Class {
	#name : #SycAbstractAllInstVarAccessorsCommand,
	#superclass : #SycClassCommand,
	#category : #'SystemCommands-ClassCommands'
}

{ #category : #activation }
SycAbstractAllInstVarAccessorsCommand class >> browserShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation  by: $a meta, $a meta for: ClyClass asCalypsoItemContext 
]

{ #category : #activation }
SycAbstractAllInstVarAccessorsCommand class >> fullBrowserMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byRootGroupItemOrder: 2.1 for: ClyFullBrowserClassContext 
]

{ #category : #accessing }
SycAbstractAllInstVarAccessorsCommand >> asRefactorings [
	| refactorings model1 |
	refactorings := classes flatCollect: [:each |
		each value collect: [:var | | refactoring |
			model1 ifNil: [ refactoring := var createRefactoring: RBAbstractInstanceVariableRefactoring for: each key.
				model1 := refactoring model ]
				ifNotNil: [refactoring := var createRefactoring: RBAbstractInstanceVariableRefactoring for: each key in: model1 ].
			refactoring ]].
	^ refactorings
]

{ #category : #accessing }
SycAbstractAllInstVarAccessorsCommand >> defaultMenuIconName [ 
	^ #smallAdd
]

{ #category : #accessing }
SycAbstractAllInstVarAccessorsCommand >> defaultMenuItemName [
	^'Abstract instance variables'
]

{ #category : #execution }
SycAbstractAllInstVarAccessorsCommand >> execute [

	self executeRefactorings
]

{ #category : #testing }
SycAbstractAllInstVarAccessorsCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	
	classes := classes collect: [:each | aToolContext currentMetaLevelOf: each].
	self selectVariables.
]

{ #category : #execution }
SycAbstractAllInstVarAccessorsCommand >> selectVariables [ 
	classes := classes collect: [:aClass | | vars dialog selectedVars |
		vars := aClass slots asOrderedCollection.
		selectedVars := vars copy.
		dialog := RBVariablesSelectionPresenter 
		   label: aClass name,' - Select all variables to covert abstract'
			withItems: vars 
			selecting: selectedVars. 
		dialog cancelled ifTrue: [ CmdCommandAborted signal ].
		aClass -> selectedVars
		]
]
