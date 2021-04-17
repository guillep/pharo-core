Extension { #name : #SycRemoveMethodCommand }

{ #category : #'*Calypso-SystemTools-Core' }
SycRemoveMethodCommand class >> methodMenuActivation [
	<classAnnotation>
	
	^ CmdContextMenuActivation byRootGroupItemOrder: 10000 for: ClyMethod asCalypsoItemContext
]

{ #category : #'*Calypso-SystemTools-Core' }
SycRemoveMethodCommand class >> methodShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation removalFor: ClyMethod asCalypsoItemContext
]
