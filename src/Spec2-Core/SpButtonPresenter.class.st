"
A button who executes an action when pressed.

"
Class {
	#name : #SpButtonPresenter,
	#superclass : #SpAbstractButtonPresenter,
	#traits : 'SpTContextMenu',
	#classTraits : 'SpTContextMenu classTrait',
	#instVars : [
		'#action => SpObservableSlot',
		'#actionPerformed => SpObservableSlot',
		'#askBeforeChanging => SpObservableSlot',
		'#font => SpObservableSlot',
		'#shortcut => SpObservableSlot',
		'#state => SpObservableSlot'
	],
	#category : #'Spec2-Core-Widgets'
}

{ #category : #specs }
SpButtonPresenter class >> adapterName [

	^ #ButtonAdapter
]

{ #category : #documentation }
SpButtonPresenter class >> documentFactoryMethodSelector [

	^ #newButton
]

{ #category : #specs }
SpButtonPresenter class >> title [

	^ 'Button'
]

{ #category : #api }
SpButtonPresenter >> action [
	"Answer the block performed when the button is clicked."

	^ action
]

{ #category : #api }
SpButtonPresenter >> action: aBlock [
	"Set the block performed when the button is clicked. 
	 `aBlock` receives zero arguments."

	action := aBlock
]

{ #category : #TOREMOVE }
SpButtonPresenter >> askBeforeChanging [
	^ askBeforeChanging
]

{ #category : #TOREMOVE }
SpButtonPresenter >> askBeforeChanging: aBoolean [
	askBeforeChanging := aBoolean
]

{ #category : #simulating }
SpButtonPresenter >> click [

	"I emulate the click from the presenter point of view.
	Of course if the button is disabled, I do nothing, like in real life!!
	If you want to emulate other stuff use performAction"
	
	self isEnabled ifFalse: [ ^ self ].
	^ self performAction
]

{ #category : #'private-focus' }
SpButtonPresenter >> ensureKeyBindingsFor: widget [

	super ensureKeyBindingsFor: widget.
	self shortcut ifNotNil: [ :s | self registerShortcut: s ]
]

{ #category : #TOREMOVE }
SpButtonPresenter >> font [
	^ font
]

{ #category : #TOREMOVE }
SpButtonPresenter >> font: aFont [
	font := aFont
]

{ #category : #initialization }
SpButtonPresenter >> initialize [
	super initialize.

	action := [  ].
	state := false.
	askBeforeChanging := false.

	self whenFontChangedDo: [ self changed: #font ].
	self whenStateChangedDo: [ self changed: #state ].
	self whenMenuChangedDo: [ 
		self withAdapterDo: [ :anAdapter | anAdapter updateMenu ] ].
	self 
		property: #askBeforeChanging 
		whenChangedDo: [ :newValue | self changed: {#askBeforeChanging: . newValue} ].
	self
		property: #shortcut
		whenChangedDo: [ :newShortcut :oldShortcut | 
			self unregisterShortcut: oldShortcut.
			self registerShortcut: newShortcut.
			self changed: #label ].

	self color: nil
]

{ #category : #private }
SpButtonPresenter >> performAction [

	self action value.
	" Here I set a dummy value just to make the holder raise an event"
	actionPerformed := nil
]

{ #category : #private }
SpButtonPresenter >> registerShortcut: newShortcut [
	| receiver |
	
	receiver := self window.
	(receiver isNil or: [ newShortcut isNil ]) ifTrue: [ ^ self ].
	receiver presenter
		bindKeyCombination: newShortcut
		toAction: [ self performAction ]
]

{ #category : #api }
SpButtonPresenter >> shortcut [
	"Answer the shortcut used to trigger button's action from keyboard."

	^ shortcut
]

{ #category : #api }
SpButtonPresenter >> shortcut: aShortcut [
	"Set the shortcut used to trigger button's action from keyboard.
	 `aShortcut` needs to be an instance of `KMKeyCombination` (or polymorphic with it), 
	 usually <meta+some character>"

	shortcut := aShortcut
]

{ #category : #private }
SpButtonPresenter >> shortcutCharacter [

	^ self shortcut ifNotNil: [ :s | s platformCharacter ]
]

{ #category : #TOREMOVE }
SpButtonPresenter >> state [

	self flag: #TODO. "To remove or move to morphic extension"
	^ state
]

{ #category : #TOREMOVE }
SpButtonPresenter >> state: aBoolean [
	"set if the button is highlighted"

	state := aBoolean
]

{ #category : #private }
SpButtonPresenter >> unregisterShortcut: oldShortcut [
	| receiver |
	receiver := self window.
	(receiver isNil or: [ oldShortcut isNil ]) ifTrue: [ ^ self ].

	receiver model
		removeKeyCombination: oldShortcut 
]

{ #category : #'api-events' }
SpButtonPresenter >> whenActionChangedDo: aBlock [
	"Inform when action block has been changed. 
	 `aBlock` receives two optional arguments: 
	 - new action block
	 - old action block"

	self property: #action whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpButtonPresenter >> whenActionPerformedDo: aBlock [
	"Inform that the button has been aclicked, and its action has been performed.
	 `aBlock` receive zero arguments."

	self property: #actionPerformed whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpButtonPresenter >> whenActivatedDo: aBlock [
	"Inform that the button has been aclicked, and its action has been performed.
	 `aBlock` receive zero arguments.
	 See also `SpButtonPresenter>>#whenActionPerformedDo:`"
	
	^ self whenActionPerformedDo: aBlock 
]

{ #category : #TOREMOVE }
SpButtonPresenter >> whenFontChangedDo: aBlock [
	"set a block to perform after that the button has been aclicked, and its action performed"

	self property: #font whenChangedDo: aBlock
]

{ #category : #TOREMOVE }
SpButtonPresenter >> whenStateChangedDo: aBlock [
	"set a block to perform after that the button has been aclicked, and its action performed"

	self property: #state whenChangedDo: aBlock
]
