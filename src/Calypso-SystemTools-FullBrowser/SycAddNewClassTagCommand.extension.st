Extension { #name : #SycAddNewClassTagCommand }

{ #category : #'*Calypso-SystemTools-FullBrowser' }
SycAddNewClassTagCommand class >> fullBrowserClassGroupMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byRootGroupItemFor: ClyFullBrowserClassGroupContext 
]

{ #category : #'*Calypso-SystemTools-FullBrowser' }
SycAddNewClassTagCommand class >> fullBrowserPackageMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byRootGroupItemFor: ClyFullBrowserPackageContext
]
