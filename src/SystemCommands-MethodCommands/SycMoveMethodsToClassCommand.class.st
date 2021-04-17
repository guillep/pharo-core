"
I am a command to move methods to given class
 
Internal Representation and Key Implementation Points.

    Instance Variables
	targetClass:		<Class>
"
Class {
	#name : #SycMoveMethodsToClassCommand,
	#superclass : #SycMethodCommand,
	#instVars : [
		'targetClass'
	],
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #activation }
SycMoveMethodsToClassCommand class >> methodContextMenuActivation [
	<classAnnotation>
	
	^ SycMethodMenuActivation byRootGroupItemOrder: 60 for: ClyMethod asCalypsoItemContext
]

{ #category : #'instance creation' }
SycMoveMethodsToClassCommand class >> methods: methods class: targetClass [
	^(self for: methods)
		targetClass: targetClass
		
]

{ #category : #accessing }
SycMoveMethodsToClassCommand >> defaultMenuIconName [ 
	^ #smallRedo
]

{ #category : #accessing }
SycMoveMethodsToClassCommand >> defaultMenuItemName [
	^'Move to another class'
]

{ #category : #execution }
SycMoveMethodsToClassCommand >> execute [
	
	methods 
		collect: [ :each | RBMoveMethodToClassRefactoring model: model method: each class: targetClass ]
		thenDo: [ :each | each execute ]
]

{ #category : #'drag and drop support' }
SycMoveMethodsToClassCommand >> prepareExecutionInDropContext: aToolContext [
	super prepareExecutionInDropContext: aToolContext.
	targetClass := aToolContext lastSelectedClass.
	targetClass := aToolContext currentMetaLevelOf: targetClass
]

{ #category : #execution }
SycMoveMethodsToClassCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	
	targetClass := aToolContext requestSingleClass: 'Choose class'.
	targetClass := aToolContext currentMetaLevelOf: targetClass
]

{ #category : #accessing }
SycMoveMethodsToClassCommand >> targetClass [
	^ targetClass
]

{ #category : #accessing }
SycMoveMethodsToClassCommand >> targetClass: anObject [
	targetClass := anObject
]
