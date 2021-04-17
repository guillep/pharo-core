Extension { #name : #SycCopyPackageCommand }

{ #category : #'*Calypso-SystemTools-FullBrowser' }
SycCopyPackageCommand class >> fullBrowserMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byRootGroupItemOrder: 1.1 for: ClyFullBrowserPackageContext 
]

{ #category : #'*Calypso-SystemTools-FullBrowser' }
SycCopyPackageCommand class >> fullBrowserShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation by: $c meta for: ClyFullBrowserPackageContext
]
