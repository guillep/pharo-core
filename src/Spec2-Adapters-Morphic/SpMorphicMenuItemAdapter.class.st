"
I am the bridge between a MenuItemPresenter and a ToggleMenuItemMorph
"
Class {
	#name : #SpMorphicMenuItemAdapter,
	#superclass : #SpAbstractMorphicAdapter,
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> action [

	^ self model action
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> actionArguments [

	^ [ Array with: self ]
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> autoRefresh [

	| autoRefresh |
	autoRefresh := self model autoRefresh.

	^ (autoRefresh isBlock or: [ autoRefresh isMessageSend ])
		  ifTrue: [ autoRefresh cull: self model ]
		  ifFalse: [ autoRefresh ]
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> balloonText [
	| balloonText | 
	
	balloonText := self model description.
	balloonText ifNil: [ ^ nil ].
	
	^ (balloonText isBlock or: [ balloonText isMessageSend ])
		ifTrue: [ balloonText cull: self model ]
		ifFalse: [ balloonText ]
]

{ #category : #factory }
SpMorphicMenuItemAdapter >> buildWidget [

	^ self autoRefresh
		  ifTrue: [ self buildWidgetAutoRefresh ]
		  ifFalse: [ self buildWidgetNoRefresh ]
]

{ #category : #factory }
SpMorphicMenuItemAdapter >> buildWidgetAutoRefresh [

	^ UpdatingMenuItemMorph new
		  target: self;
		  balloonTextSelector: #balloonText;
		  subMenuSelector: #subMenu;
		  nameSelector: #name;
		  selector: #performMenuActionWith:;
		  argumentsBlock: self actionArguments;
		  getStateSelector: #state;
		  iconSelector: #icon;
		  enablementSelector: #enabled;
		  keyText: self shortcutText;
		  yourself
]

{ #category : #factory }
SpMorphicMenuItemAdapter >> buildWidgetNoRefresh [

	| item |
	item := ToggleMenuItemMorph new
		        contents: self name;
		        target: self;
		        selector: #performMenuActionWith:;
		        subMenu: self subMenu;
		        argumentsBlock: self actionArguments;
		        getStateSelector: self stateSelector;
		        icon: self icon;
		        enablementSelector: #enabled;
		        balloonText: self balloonText;
		        keyText: self shortcutText;
		        yourself.

	self presenter whenNameChangedDo: [ item contents: self name ].
	self presenter whenIconChangedDo: [ item icon: self icon ].
	self presenter whenDescriptionChangedDo: [ 
		item balloonText: self balloonText ].

	^ item
]

{ #category : #private }
SpMorphicMenuItemAdapter >> defaultModifierShortcut [
	
	^ self shortcut first isUppercase
		ifTrue: [ OSPlatform current defaultModifier + KMModifier shift + self shortcut first ]
		ifFalse: [ OSPlatform current defaultModifier + self shortcut first ]
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> enabled [

	| enabled |
	enabled := self model isEnabled.

	^ (enabled isBlock or: [ enabled isMessageSend ])
		  ifTrue: [ enabled cull: self model ]
		  ifFalse: [ enabled ]
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> icon [

	| icon |
	icon := self model icon.

	^ (icon isBlock or: [ icon isMessageSend ])
		  ifTrue: [ icon cull: self model ]
		  ifFalse: [ icon ]
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> name [

	| name |
	name := self presenter name.

	^ (name isBlock or: [ name isMessageSend ])
		  ifTrue: [ name cull: self model ]
		  ifFalse: [ 
			  name ifNotNil: [ :aString | 
				  aString localizedForPresenter: self presenter ] ]
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> performMenuActionWith: arguments [

	^ self model performMenuActionWith: arguments
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> shortcut [

	| shortcut |
	shortcut := self model shortcut.

	^ (shortcut isBlock or: [ shortcut isMessageSend ])
		  ifTrue: [ shortcut cull: self model ]
		  ifFalse: [ shortcut ]
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> shortcutText [
	
	| shortcut |
	
	shortcut := self shortcut.
	shortcut isString ifTrue: [ shortcut := self defaultModifierShortcut ].
	shortcut ifNil: [ ^ nil ].

	"We can use the KMShortcutPrinter. ToggleMenuItemMorph handles when it has been already normalized or not"
		
	^ shortcut asKeyCombination acceptVisitor: OSPlatform current shortcutPrinter	
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> state [

	| state |
	state := self model state.

	^ (state isBlock or: [ state isMessageSend ])
		  ifTrue: [ state cull: self model ]
		  ifFalse: [ state ]
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> stateSelector [

	^ self state ifNotNil: [ #state ]
]

{ #category : #'widget API' }
SpMorphicMenuItemAdapter >> subMenu [

	| subMenu |
	subMenu := self model subMenu.
	subMenu ifNil: [ ^ nil ].

	^ (subMenu isBlock or: [ subMenu isMessageSend ])
		  ifTrue: [ subMenu cull: self model ]
		  ifFalse: [ subMenu buildWithSpecAsPopup ]
]

{ #category : #private }
SpMorphicMenuItemAdapter >> widgetIcon [
	"For testing purposes"
	
	^ self widget icon
]

{ #category : #private }
SpMorphicMenuItemAdapter >> widgetName [
	"For testing purposes"
	
	^ self widget contents
]
