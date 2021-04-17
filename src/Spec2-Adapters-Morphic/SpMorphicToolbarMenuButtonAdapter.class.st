"
I'm the adapter used to bridge a ToolBarMenuButton and its morphic representation.
"
Class {
	#name : #SpMorphicToolbarMenuButtonAdapter,
	#superclass : #SpMorphicToolbarButtonAdapter,
	#instVars : [
		'subMenuWidget'
	],
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #protocol }
SpMorphicToolbarMenuButtonAdapter >> askBeforeChanging [

	^ false
]

{ #category : #accessing }
SpMorphicToolbarMenuButtonAdapter >> badge [
	
	^ self presenter badge
]

{ #category : #factory }
SpMorphicToolbarMenuButtonAdapter >> buildWidget [

	^ SpMorphicToolbarMenuButtonMorph
		  newButton: super buildWidget
		  menuButton: self newMenuButton
]

{ #category : #updating }
SpMorphicToolbarMenuButtonAdapter >> button [

	^ widget submorphs first
]

{ #category : #control }
SpMorphicToolbarMenuButtonAdapter >> deleteIfPopUp: anEvent [ 
	
]

{ #category : #'drag and drop' }
SpMorphicToolbarMenuButtonAdapter >> dragEnabled [

	^ false
]

{ #category : #'drag and drop' }
SpMorphicToolbarMenuButtonAdapter >> dropEnabled [

	^ false
]

{ #category : #accessing }
SpMorphicToolbarMenuButtonAdapter >> icon [

	^ self presenter icon
]

{ #category : #testing }
SpMorphicToolbarMenuButtonAdapter >> isSelected: aBooolean [
]

{ #category : #accessing }
SpMorphicToolbarMenuButtonAdapter >> label [
	
	^ self presenter label
]

{ #category : #accessing }
SpMorphicToolbarMenuButtonAdapter >> menuIcon [

	^ self application iconNamed: #arrowDown
]

{ #category : #factory }
SpMorphicToolbarMenuButtonAdapter >> newMenuButton [

	^ IconicButtonMorph new
		  target: self;
		  actionSelector: #showMenu;
		  arguments: {  };
		  labelGraphic: self menuIcon;
		  color: Color transparent;
		  borderWidth: 0
]

{ #category : #accessing }
SpMorphicToolbarMenuButtonAdapter >> showMenu [

	self presenter menu ifNotNil: [ :aValuable | 
		aValuable value ifNotNil: [ :aMenu | 
			aMenu owner: self presenter.
			self showSubMenu: aMenu ] ].
	self widget ifNotNil: [ :m | m takeKeyboardFocus ]
]

{ #category : #'widget API' }
SpMorphicToolbarMenuButtonAdapter >> showSubMenu: aMenu [

	aMenu menuGroups ifNil: [ ^ self ].

	subMenuWidget ifNotNil: [ 
		subMenuWidget delete.
		subMenuWidget := nil ].
	subMenuWidget := (SpMorphicMenuAdapter adaptAsPopup: aMenu) widget.
	subMenuWidget
		popUpAdjacentTo: { 
				self widget bounds bottomLeft.
				self widget bounds bottomRight }
		forHand: self currentWorld activeHand
		from: self widget.
	subMenuWidget popUpOwner: self
]
