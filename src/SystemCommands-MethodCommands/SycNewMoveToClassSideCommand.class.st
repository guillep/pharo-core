"
I am a command to move method to the class side of defining class
"
Class {
	#name : #SycNewMoveToClassSideCommand,
	#superclass : #SycMethodCmCommand,
	#instVars : [
		'methods'
	],
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #accessing }
SycNewMoveToClassSideCommand >> executeRefactoring [
	
	methods 
		collect: [ :each | RBMoveMethodToClassSideRefactoring 
			model: model
			method: each 
			class: each origin ]
		thenDo: [ :each | each execute ]
]

{ #category : #accessing }
SycNewMoveToClassSideCommand >> icon [ 
	^ self iconNamed: #smallRedo
]

{ #category : #accessing }
SycNewMoveToClassSideCommand >> isEnabled [

	^ context isInstanceSideMethodSelected
]

{ #category : #accessing }
SycNewMoveToClassSideCommand >> name [ 
	^ 'New move to class side'
]

{ #category : #preparation }
SycNewMoveToClassSideCommand >> prepareFullExecution [
	super prepareFullExecution.
	methods := context selectedMethods.
]
