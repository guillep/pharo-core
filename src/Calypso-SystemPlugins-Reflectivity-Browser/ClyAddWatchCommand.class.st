"
I am a command to install watchpoint into the given method or source node
"
Class {
	#name : #ClyAddWatchCommand,
	#superclass : #ClyDebuggingCommand,
	#category : #'Calypso-SystemPlugins-Reflectivity-Browser-Watchpoints'
}

{ #category : #execution }
ClyAddWatchCommand class >> canBeExecutedInContext: aBrowserContext [

	^aBrowserContext isSelectedItemHasWatch not
]

{ #category : #activation }
ClyAddWatchCommand class >> contextMenuOrder [
	^3
]

{ #category : #accessing }
ClyAddWatchCommand >> defaultMenuIconName [
	^#haloView
]

{ #category : #accessing }
ClyAddWatchCommand >> defaultMenuItemName [
	^'Add Watchpoint'
]

{ #category : #execution }
ClyAddWatchCommand >> execute [
	
	Watch in: sourceNode
]
