Extension { #name : #SycRemoveClassCommand }

{ #category : #'*Calypso-SystemTools-FullBrowser' }
SycRemoveClassCommand class >> fullBrowserMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byRootGroupItemOrder: 10000 for: ClyFullBrowserClassContext
]

{ #category : #'*Calypso-SystemTools-FullBrowser' }
SycRemoveClassCommand class >> fullBrowserShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation removalFor: ClyFullBrowserClassContext 
]
