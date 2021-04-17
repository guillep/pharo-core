Extension { #name : #ToolDockingBarMorph }

{ #category : #'*Spec-MorphicAdapters' }
ToolDockingBarMorph >> adoptMenuGroupModel: aGroupModel first: aBoolean [
	| controls |
	
	aBoolean ifFalse: [ 
		self 
			addMorphBack: (self theme newToolSpacerIn: self);
			addMorphBack: (self theme newToolbarHandleIn: self);
			addMorphBack: (self theme newToolSpacerIn: self) ].
			
	controls := OrderedCollection new.
	aGroupModel menuItems do: [ :item | self adoptMenuItemModel: item accumulator: controls ].
	
	self emptyAccumulator: controls
]

{ #category : #'*Spec-MorphicAdapters' }
ToolDockingBarMorph >> adoptMenuItemModel: item accumulator: controls [
	
	item subMenu
		ifNil: [ | button |
			button := self buildButtonFor: item.
			controls add: button ]
		ifNotNil: [ 
			self emptyAccumulator: controls.
			self addMorphBack: (self theme newToolSpacerIn: self).
			self 
				add: item name
				font: self theme menuBarFont
				icon: item icon
				help: item description
				subMenu: item subMenu buildWithSpecAsPopup.
			self addMorphBack: (self theme newToolSpacerIn: self) ]
]

{ #category : #'*Spec-MorphicAdapters' }
ToolDockingBarMorph >> adoptMenuModel: aMenuModel [

	aMenuModel menuGroups doWithIndex: [ :aGroup :index | 
		self 
			adoptMenuGroupModel: aGroup
			first: (index = 1) ]
]

{ #category : #'*Spec-MorphicAdapters' }
ToolDockingBarMorph >> buildButtonFor: item [

	^ self theme
		newButtonIn: self for: item
		getState: nil
		action: #performMenuActionWith:
		arguments: { self }
		getEnabled: #enabled 
		label: (IconicListItemMorph text: item name icon: item icon)
		help: item description 
]

{ #category : #'*Spec-MorphicAdapters' }
ToolDockingBarMorph >> emptyAccumulator: controls [
	
	controls do: [ :button | self addMorphBack: button ].
	controls removeAll
]
