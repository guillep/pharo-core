Extension { #name : #CmdCommandActivator }

{ #category : #'*Commander-Activators-ContextMenu' }
CmdCommandActivator >> buildContextMenu: aMenu [
	
	self canExecuteCommand ifFalse: [ ^self ].
	
	command fillContextMenu: aMenu using: self
]

{ #category : #'*Commander-Activators-ContextMenu' }
CmdCommandActivator >> registerContextMenuItemsFor: aCommandItem withBuilder: aBuilder [
	
	self canExecuteCommand ifFalse: [ ^self ].
	
	command registerContextMenuItemsFor: aCommandItem withBuilder: aBuilder
]

{ #category : #'*Commander-Activators-ContextMenu' }
CmdCommandActivator >> setUpShortcutTipForMenuItem: aMenuItemMorph [
	
	CmdShortcutActivation 
		activeInstancesFor: command class inContext: context
		do: [ :shortcut |  	
			aMenuItemMorph keyText: (shortcut keyCombination acceptVisitor: OSPlatform current shortcutPrinter)]
]
