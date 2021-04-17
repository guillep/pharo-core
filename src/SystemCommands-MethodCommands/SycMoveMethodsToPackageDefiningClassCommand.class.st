"
I am a command to move method to the package of defining class.

I am used to convert extension method to normal one
"
Class {
	#name : #SycMoveMethodsToPackageDefiningClassCommand,
	#superclass : #SycMethodRepackagingCommand,
	#instVars : [
		'targetTagName'
	],
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #testing }
SycMoveMethodsToPackageDefiningClassCommand class >> canBeExecutedInContext: aToolContext [
	^aToolContext isExtensionMethodSelected
]

{ #category : #activation }
SycMoveMethodsToPackageDefiningClassCommand class >> methodContextMenuActivation [
	<classAnnotation>
	
	^ SycMethodMenuActivation byRootGroupItemOrder: 80 for: ClyMethod asCalypsoItemContext
]

{ #category : #accessing }
SycMoveMethodsToPackageDefiningClassCommand >> defaultMenuIconName [ 
	^ #smallRedo
]

{ #category : #accessing }
SycMoveMethodsToPackageDefiningClassCommand >> defaultMenuItemName [
	^'Move to package defining the class'
]

{ #category : #execution }
SycMoveMethodsToPackageDefiningClassCommand >> execute [

	| classPackage |
	methods do: [ :each | 
		classPackage := each origin package.
		self moveMethod: each toPackage: classPackage.
		each tagWith: targetTagName]
]

{ #category : #execution }
SycMoveMethodsToPackageDefiningClassCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	
	targetTagName := aToolContext requestSingleMethodTag: 'Choose protocol for methods'
]

{ #category : #accessing }
SycMoveMethodsToPackageDefiningClassCommand >> targetTagName [
	^ targetTagName
]

{ #category : #accessing }
SycMoveMethodsToPackageDefiningClassCommand >> targetTagName: anObject [
	targetTagName := anObject
]
