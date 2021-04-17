"
I am a command to open browser with methods where halts or breakpoints are installed.

I am registered in world toolbar using class side method #worldMenuOn:
"
Class {
	#name : #ClyBrowseBreakpointsCommand,
	#superclass : #CmdCommand,
	#category : #'Calypso-SystemPlugins-Reflectivity-Browser-Breakpoints'
}

{ #category : #'world menu' }
ClyBrowseBreakpointsCommand class >> worldMenuOn: aBuilder [
	<worldMenu>
	
	| command |
	command := self new.
	(aBuilder item: command defaultMenuItemName)
		parent: #Breakpoints;
		order: 1;
		icon: command defaultMenuIcon;
		help: command description;
		action: [ command execute ]
]

{ #category : #accessing }
ClyBrowseBreakpointsCommand >> defaultMenuIconName [

	^#smallDebug
]

{ #category : #accessing }
ClyBrowseBreakpointsCommand >> defaultMenuItemName [

	^'Browse breakpoints'
]

{ #category : #accessing }
ClyBrowseBreakpointsCommand >> description [

	^'Open browser with methods where Halts or Breakpoints are installed'
]

{ #category : #execution }
ClyBrowseBreakpointsCommand >> execute [ 
	
	ClyQueryBrowser browseBreakpoints
]
