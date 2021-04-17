"
I am a command to open special class menu.
I show in menu all commands annotated by SycClassMenuActivation class
"
Class {
	#name : #SycOpenClassMenuCommand,
	#superclass : #SycOpenContextMenuCommand,
	#category : #'SystemCommands-ClassCommands'
}

{ #category : #activation }
SycOpenClassMenuCommand class >> fullBrowserMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byRootGroupItemOrder: 10100 
		for: ClyClass asCalypsoItemContext 
]

{ #category : #activation }
SycOpenClassMenuCommand class >> fullBrowserShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation by: $t meta for: ClyClass asCalypsoItemContext 
]

{ #category : #activation }
SycOpenClassMenuCommand class >> fullBrowserTabActivation [
	<classAnnotation>
	
	^ClyBrowserTabCommandActivation for: ClyFullBrowserClassContext 
]

{ #category : #execution }
SycOpenClassMenuCommand >> activationStrategy [ 
	^ SycClassMenuActivation
]

{ #category : #'context menu' }
SycOpenClassMenuCommand >> cmCommandClass [ 
	^ SycClassCmCommand
]

{ #category : #execution }
SycOpenClassMenuCommand >> defaultMenuItemName [
	^'Refactorings'
]
