Extension { #name : #CmdCommand }

{ #category : #'*Calypso-Browser' }
CmdCommand >> addToolbarItemInto: toolbarMorph using: aCommandActivator [
	
	| item |
	item := self createToolbarItemFor: aCommandActivator.
	self decorateToolbarItem: item.
	toolbarMorph addNewItem: item
]

{ #category : #'*Calypso-Browser' }
CmdCommand >> browserTabActionIcon [

	^self secureMenuIcon 
]

{ #category : #'*Calypso-Browser' }
CmdCommand >> buildBrowserNotebookActionsUsing: aCommandActivator [
	
	^ { ClyNotebookPageActionButtonMorph forAction: (ClyNotebookPageAction 
		action: [ aCommandActivator executeCommand ]
		icon: self browserTabActionIcon
		label: aCommandActivator commandDescription) }
]

{ #category : #'*Calypso-Browser' }
CmdCommand >> buildBrowserTabActionsUsing: aCommandActivator [

	^{
		TabAction 
			action: [ aCommandActivator executeCommand ]
			icon: self browserTabActionIcon
			label: aCommandActivator commandDescription
	}
]

{ #category : #'*Calypso-Browser' }
CmdCommand >> createTableCellButtonUsing: aCommandActivator [

	| icon |
	icon := self tableCellIcon.
	
	^self createTableCellButtonWith: icon using: aCommandActivator.
		
]

{ #category : #'*Calypso-Browser' }
CmdCommand >> createTableCellButtonWith: anIcon using: aCommandActivator [

	^IconicButtonMorph new
		target: aCommandActivator;
		actionSelector: #executeCommand;
		color: Color transparent;
		helpText: self defaultMenuItemName;
		borderWidth: 0;
		labelGraphic: anIcon;
		extent: anIcon extent
]

{ #category : #'*Calypso-Browser' }
CmdCommand >> createToolbarItemFor: aCommandActivator [
	
	^ClyBrowserButtonMorph activatingBy: aCommandActivator
]

{ #category : #'*Calypso-Browser' }
CmdCommand >> decorateTableCell: anItemCellMorph using: aCommandActivator [

	| button |
	button := self createTableCellButtonUsing: aCommandActivator.
		
	self decorateTableCell: anItemCellMorph with: button
]

{ #category : #'*Calypso-Browser' }
CmdCommand >> decorateTableCell: anItemCellMorph with: aMorph [

	anItemCellMorph definitionMorph: aMorph
]

{ #category : #'*Calypso-Browser' }
CmdCommand >> decorateToolbarItem: aBrowserToolbarItem [

	self description ifNotNil: [ :d | 
		aBrowserToolbarItem setBalloonText: d ].
	
	self defaultMenuIcon ifNotNil: [:icon |
		aBrowserToolbarItem addIcon: icon asMorph]
]

{ #category : #'*Calypso-Browser' }
CmdCommand >> defaultToolbarItemName [
	^self defaultMenuItemName
]

{ #category : #'*Calypso-Browser' }
CmdCommand >> tableCellIcon [

	^self secureMenuIcon 
]
