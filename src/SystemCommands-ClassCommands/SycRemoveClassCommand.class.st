"
I am a command to remove all given classes
"
Class {
	#name : #SycRemoveClassCommand,
	#superclass : #SycClassCommand,
	#instVars : [
		'removeStrategy'
	],
	#category : #'SystemCommands-ClassCommands'
}

{ #category : #execution }
SycRemoveClassCommand >> asRefactorings [

	^self asRefactoringsOfClass: RBRemoveClassRefactoring
]

{ #category : #execution }
SycRemoveClassCommand >> asRefactoringsOfClass: aClass [

	^{aClass classNames: (classes collect: [:each | each name])}
]

{ #category : #execution }
SycRemoveClassCommand >> confirmRefactoringInContext: aToolContext by: aCommandActivator [
	"All refactoring errors here are related to existance of removed class users.
	All these cases are handled on the level of #confirmUnusedClasses
	and here we need to ignore RB signals.
	Notice that existing logic of RB engine for class removal 
	does not allow correctly handle class users like show them in browser 
	because there is no information about kind of users in #openBrowser option"
	
	[super confirmRefactoringInContext: aToolContext by: aCommandActivator ]
		on: RBRefactoringError do: [ :err | err resume: true ]
]

{ #category : #accessing }
SycRemoveClassCommand >> defaultMenuIconName [
	^#removeIcon
]

{ #category : #accessing }
SycRemoveClassCommand >> defaultMenuItemName [
	^'Remove'
]

{ #category : #execution }
SycRemoveClassCommand >> execute [

	removeStrategy execute: self.
]

{ #category : #execution }
SycRemoveClassCommand >> executeRefactoringsAs: aClass [

	(self asRefactoringsOfClass: aClass) do: [ :each | each execute ]
]

{ #category : #testing }
SycRemoveClassCommand >> isComplexRefactoring [
	^removeStrategy isComplexRefactoring 
]

{ #category : #execution }
SycRemoveClassCommand >> prepareFullExecutionInContext: aToolContext [

	super prepareFullExecutionInContext: aToolContext.
	
	removeStrategy := aToolContext requestRemoveClassStrategyFor: classes.
]
