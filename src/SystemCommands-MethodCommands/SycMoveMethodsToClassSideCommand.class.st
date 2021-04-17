"
I am a command to move method to the class side of defining class
"
Class {
	#name : #SycMoveMethodsToClassSideCommand,
	#superclass : #SycMethodCommand,
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #testing }
SycMoveMethodsToClassSideCommand class >> canBeExecutedInContext: aToolContext [
	^(super canBeExecutedInContext: aToolContext)
		and: [ aToolContext isInstanceSideMethodSelected ]
]

{ #category : #activation }
SycMoveMethodsToClassSideCommand class >> methodContextMenuActivation [
	<classAnnotation>
	
	^ SycMethodMenuActivation byRootGroupItemOrder: 50 for: ClyMethod asCalypsoItemContext
]

{ #category : #activation }
SycMoveMethodsToClassSideCommand class >> methodShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation by: $t meta, $c meta for: ClyMethod asCalypsoItemContext
]

{ #category : #accessing }
SycMoveMethodsToClassSideCommand >> defaultMenuIconName [ 
	^ #smallRedo
]

{ #category : #accessing }
SycMoveMethodsToClassSideCommand >> defaultMenuItemName [
	^'Move to class side'
]

{ #category : #execution }
SycMoveMethodsToClassSideCommand >> execute [
	
	methods 
		collect: [ :each | RBMoveMethodToClassRefactoring model: model method: each class: each origin classSide]
		thenDo: [ :each | each execute ]
]
