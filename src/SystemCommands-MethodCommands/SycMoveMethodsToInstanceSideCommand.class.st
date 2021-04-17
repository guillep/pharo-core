"
I am a command to move method to the instance side of defining class
"
Class {
	#name : #SycMoveMethodsToInstanceSideCommand,
	#superclass : #SycMethodCommand,
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #testing }
SycMoveMethodsToInstanceSideCommand class >> canBeExecutedInContext: aToolContext [
	^(super canBeExecutedInContext: aToolContext)
		and: [ aToolContext isClassSideMethodSelected ]
]

{ #category : #activation }
SycMoveMethodsToInstanceSideCommand class >> methodContextMenuActivation [
	<classAnnotation>
	
	^ SycMethodMenuActivation byRootGroupItemOrder: 50 for: ClyMethod asCalypsoItemContext
]

{ #category : #activation }
SycMoveMethodsToInstanceSideCommand class >> methodShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation by: $t meta, $i meta for: ClyMethod asCalypsoItemContext
]

{ #category : #accessing }
SycMoveMethodsToInstanceSideCommand >> defaultMenuIconName [ 
	^ #smallRedo
]

{ #category : #accessing }
SycMoveMethodsToInstanceSideCommand >> defaultMenuItemName [
	^'Move to instance side'
]

{ #category : #execution }
SycMoveMethodsToInstanceSideCommand >> execute [
	
	methods 
		collect: [ :each | RBMoveMethodToClassRefactoring model: model method: each class: each origin instanceSide]
		thenDo: [ :each | each execute ]
]
