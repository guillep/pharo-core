"
I am a command to open special method menu.
I show in menu all commands annotated by SycMethodMenuActivation
"
Class {
	#name : #SycOpenMethodMenuCommand,
	#superclass : #SycOpenContextMenuCommand,
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #activation }
SycOpenMethodMenuCommand class >> methodContextMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byRootGroupItemOrder: 10100 for: ClyMethod asCalypsoItemContext
]

{ #category : #activation }
SycOpenMethodMenuCommand class >> methodEditorShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation by: $t meta for: ClyMethod asCalypsoItemContext
]

{ #category : #execution }
SycOpenMethodMenuCommand >> activationStrategy [ 
	^ SycMethodMenuActivation
]

{ #category : #'context menu' }
SycOpenMethodMenuCommand >> cmCommandClass [ 
	^ SycMethodCmCommand
]

{ #category : #accessing }
SycOpenMethodMenuCommand >> defaultMenuItemName [
	^'Refactorings'
]

{ #category : #execution }
SycOpenMethodMenuCommand >> execute [

	context selectedTextInterval ifEmpty: [ 
		context showSourceNode].
	
	super execute
]
