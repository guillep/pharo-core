"
I am a command to find method in methodView of full browser.
I request user with search dialog using method view query.
So dialog shows all methods from method view panel.

By default I am activated by cmd+f.
"
Class {
	#name : #ClyFindMethodInBrowserCommand,
	#superclass : #ClyBrowserCommand,
	#category : #'Calypso-SystemTools-FullBrowser-Commands-Methods'
}

{ #category : #menu }
ClyFindMethodInBrowserCommand class >> fullBrowserMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byItemOf: ClyQueryMenuGroup for: ClyFullBrowserMethodContext 
]

{ #category : #menu }
ClyFindMethodInBrowserCommand class >> fullBrowserShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation by: $f meta for: ClyFullBrowserMethodContext 
]

{ #category : #accessing }
ClyFindMethodInBrowserCommand >> defaultMenuIconName [
	^#smallFindIcon
]

{ #category : #accessing }
ClyFindMethodInBrowserCommand >> defaultMenuItemName [
	^'Find method'
]

{ #category : #execution }
ClyFindMethodInBrowserCommand >> execute [
	| method |
	
	method := browser searchDialog 
		requestSingleObject: 'Choose method' from: browser methodView query.
	
	browser selectMethod: method
]
