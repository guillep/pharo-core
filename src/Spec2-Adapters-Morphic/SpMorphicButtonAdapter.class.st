"
SpecInterpreter
	interpretASpec: MorphicButtonAdapter  defaultSpec
	model: (MorphicButtonAdapter model: ButtonPresenter new)

"
Class {
	#name : #SpMorphicButtonAdapter,
	#superclass : #SpAbstractMorphicAdapter,
	#instVars : [
		'subMenuWidget',
		'styleName'
	],
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #'widget API' }
SpMorphicButtonAdapter >> action [

	self showSubMenuIfPresent.

	self widget ifNotNil: [:m | m takeKeyboardFocus ].
	self model performAction.
]

{ #category : #protocol }
SpMorphicButtonAdapter >> askBeforeChanging [

	^ self model askBeforeChanging
]

{ #category : #private }
SpMorphicButtonAdapter >> buildLabel: text withIcon: icon [
	| iconLabel |

	icon ifNil: [ 
		^ (text localizedForPresenter: self presenter) ifNil: [ '' ] ].
	
	iconLabel := IconicListItemMorph new.
	iconLabel icon: icon.
	text isEmptyOrNil ifFalse: [ 
		iconLabel morph: (text asMorph 
			lock;
			yourself) ].
		
	^ iconLabel
]

{ #category : #factory }
SpMorphicButtonAdapter >> buildWidget [

	| button | 
	button := self newButton.	
	button 
		getEnabledSelector: #enabled ;
		getFontSelector: #font ;
		hResizing: #spaceFill ;
		vResizing: #spaceFill ;
		askBeforeChanging: self askBeforeChanging ;
		setBalloonText: self getHelpText ;
		dragEnabled: self dragEnabled;
		dropEnabled: self dropEnabled ;	
		eventHandler: (MorphicEventHandler new 
			on: #keyStroke 
			send: #keyStroke:fromMorph: 
			to: self).
	
	self color ifNotNil: [ self setWidgetColor: button ].
	
	button 
		bindKeyCombination: Character space 
		toAction: [ self action ].

	^ button
]

{ #category : #emulating }
SpMorphicButtonAdapter >> clicked [

	| evt |
	evt := MouseButtonEvent new
		       setType: nil
		       position: widget center
		       which: MouseButtonEvent redButton
		       buttons: MouseButtonEvent redButton
		       hand: nil
		       stamp: nil.

	(widget handlesMouseDown: evt) ifTrue: [ 
		widget 
			mouseDown: evt;
			mouseUp: evt ]
]

{ #category : #'menus support' }
SpMorphicButtonAdapter >> deleteIfPopUp: evt [
]

{ #category : #'widget API' }
SpMorphicButtonAdapter >> font [

	^ self model font
]

{ #category : #private }
SpMorphicButtonAdapter >> getHelpText [

	^ self presenter help ifNotNil: [ :aString | aString localizedForPresenter: self presenter ]
]

{ #category : #private }
SpMorphicButtonAdapter >> getLabelText [

	^ self presenter label ifNotNil: [ :aString | aString localizedForPresenter: self presenter ]
]

{ #category : #accessing }
SpMorphicButtonAdapter >> helpText [

	^ self widget helpText
]

{ #category : #accessing }
SpMorphicButtonAdapter >> icon [

	^ widget label icon
]

{ #category : #'menus support' }
SpMorphicButtonAdapter >> isSelected: aBooolean [
]

{ #category : #'widget API' }
SpMorphicButtonAdapter >> keyStroke: anEvent fromMorph: aMorph [
]

{ #category : #'widget API' }
SpMorphicButtonAdapter >> label [
	
	^ self buildLabel: self presenter label withIcon: self presenter icon
]

{ #category : #'widget API' }
SpMorphicButtonAdapter >> menu: aMenu [

	| menuPresenter |
	menuPresenter := self model contextMenu.
	menuPresenter ifNil: [ ^ nil ].
	^ SpBindings
		  value: self model application adapterBindings
		  during: [ menuPresenter buildWithSpec ]
]

{ #category : #factory }
SpMorphicButtonAdapter >> newButton [

	^ PluggableButtonMorph
		  on: self
		  getState: #state
		  action: #action
		  label: #label
		  menu: #menu:
]

{ #category : #factory }
SpMorphicButtonAdapter >> setWidgetColor: button [

	| normalColorBlock clickedColorBlock |

	normalColorBlock := [ :aButton |
			(aButton valueOfProperty: #noFill ifAbsent: [false]) 
					ifTrue: [ SolidFillStyle color: Color transparent ]
					ifFalse: [ SolidFillStyle color: self color ] ].
	
	clickedColorBlock := [ :aButton | SolidFillStyle color: self color muchDarker ].
	button theme: ((SpUIThemeDecorator theme: button theme)
							property: #buttonNormalFillStyleFor: returnsValueOf: normalColorBlock;
							property: #buttonMouseOverFillStyleFor: returnsValueOf: normalColorBlock;
							property: #buttonPressedFillStyleFor: returnsValueOf: clickedColorBlock;
							yourself)
]

{ #category : #'widget API' }
SpMorphicButtonAdapter >> showSubMenu: aMenu [

	aMenu menuGroups ifNil: [ ^ self ].

	subMenuWidget ifNotNil: [ 
		subMenuWidget delete.
		subMenuWidget := nil ].
	subMenuWidget := (SpMorphicMenuAdapter adaptAsPopup: aMenu) widget.
	subMenuWidget
		popUpAdjacentTo: { 
				self widget bounds bottomLeft.
				self widget bounds bottomRight }
		forHand: self widget activeHand
		from: self widget.
	subMenuWidget popUpOwner: self
]

{ #category : #'widget API' }
SpMorphicButtonAdapter >> showSubMenuIfPresent [

	self model contextMenu ifNil: [ ^ self ].
	self showSubMenu: self model contextMenu
	
]

{ #category : #'widget API' }
SpMorphicButtonAdapter >> state [

	^ self model state
]

{ #category : #accessing }
SpMorphicButtonAdapter >> styleName [

	^ styleName ifNil: [ super styleName ]
]

{ #category : #accessing }
SpMorphicButtonAdapter >> styleName: aString [ 

	styleName := aString
]

{ #category : #accessing }
SpMorphicButtonAdapter >> unscaledInitialExtent [

	^ 15@26
]

{ #category : #updating }
SpMorphicButtonAdapter >> updateMenu [	
	"There is no need to updateMenu here because it will be resolved at #menu:"
]
