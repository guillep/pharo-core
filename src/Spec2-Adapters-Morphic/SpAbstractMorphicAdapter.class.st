"
I am an abstract class providing all the properties shared amongs all the morphic specific adapters
"
Class {
	#name : #SpAbstractMorphicAdapter,
	#superclass : #SpAbstractAdapter,
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #accessing }
SpAbstractMorphicAdapter class >> adaptingName [
	"Override me if adapter will not follow the common pattern"

	"remove 'SpMorphic' part and *in general*, I will have the adapting name"

	^ (self name withoutPrefix: 'SpMorphic') asSymbol
]

{ #category : #accessing }
SpAbstractMorphicAdapter class >> allAdapters [

	^ self allSubclasses
]

{ #category : #'drag and drop' }
SpAbstractMorphicAdapter >> acceptDropBlock [

	^ self model acceptDropBlock
]

{ #category : #'drag and drop - private' }
SpAbstractMorphicAdapter >> acceptDroppingMorph: draggedMorph event: event inMorph: source [

	^ self acceptDropBlock cull: draggedMorph model model cull: event cull: source model model
]

{ #category : #initialization }
SpAbstractMorphicAdapter >> adapt: aPresenter [

	super adapt: aPresenter.
	self addSettingsTo: self widget.
	self addKeyBindingsTo: self widget.
	self addEventsTo: self widget
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> add: anAdapter [
	self widgetDo: [ :w | w spEnsureLayoutAndAddMorph: anAdapter widget ]
]

{ #category : #private }
SpAbstractMorphicAdapter >> addContextMenuKeyBindings: aWidget [
	
	self flag: #TODO. "Take this from a configuration"
	self 
		bindKeyCombination: $t command mac | $t control unix | $t control win
		toAction: [ self showContextMenu ]

]

{ #category : #initialization }
SpAbstractMorphicAdapter >> addFocusRotationKeyBindings [

	self presenter canTakeKeyboardFocus ifFalse: [ ^ self ].

	self 
		bindKeyCombination: Character tab asKeyCombination 
		toAction: [ self focusNext ]. 
	self
		bindKeyCombination: Character tab shift asKeyCombination 
		toAction: [ self focusPrevious ]
]

{ #category : #initialization }
SpAbstractMorphicAdapter >> addKeyBindingsTo: aMorph [

	self addFocusRotationKeyBindings.
	self presenter contextKeyBindings ifNotNil: [ :aCategory | 
		aCategory allEntries keymaps do: [ :each |
			self 
				bindKeyCombination: each shortcut 
				toAction: each action ] ]
]

{ #category : #initialization }
SpAbstractMorphicAdapter >> addSettingsTo: aMorph [
	
	self widget ifNil: [ ^ self ].
	self applyVisibility
]

{ #category : #styling }
SpAbstractMorphicAdapter >> addStyle: aStyle [
	"ignore style and just apply it again (the new style will not there)"
	self applyStyle: self widget
]

{ #category : #accessing }
SpAbstractMorphicAdapter >> application [ 

	^ self presenter application
]

{ #category : #styling }
SpAbstractMorphicAdapter >> applyStyle [

	self applyStyle: self widget
]

{ #category : #styling }
SpAbstractMorphicAdapter >> applyStyle: morph [
	"this will apply general properties to the built morph"

	self style applyTo: morph
]

{ #category : #initialization }
SpAbstractMorphicAdapter >> applyVisibility [
	
	"It may happen that some presenters use generic adapters and they do not have an associated presenter.
	In that case, do not manage visibility..."
	self presenter ifNil: [ ^ self ].

	self widget visible: self presenter isVisible.
	self presenter whenVisibleChangedDo: [ :visible |
		self presenter isVisible
			ifTrue: [ self widget show ]
			ifFalse: [ self widget hide ] ]
]

{ #category : #'protocol-shortcuts' }
SpAbstractMorphicAdapter >> bindKeyCombination: aShortcut toAction: aBlock [

	self widgetDo: [ :w | 
		w 
			bindKeyCombination: aShortcut 
			toAction: aBlock ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> borderColor [

	^ self model borderColor
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> borderColor: color [

	self widget ifNotNil: [ :w | w borderColor: color ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> borderWidth [

	^ self model borderWidth
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> borderWidth: width [

	self widget ifNotNil: [ :w | w borderWidth: width ]
]

{ #category : #private }
SpAbstractMorphicAdapter >> buildMenu: aMenuPresenter [

	^ aMenuPresenter 
		owner: self presenter;
		buildWithSpec
]

{ #category : #'spec protocol' }
SpAbstractMorphicAdapter >> changed [

	^ self widgetDo: [ :w | w changed ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> color [

	^ self model color
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> color: color [

	self widgetDo: [ :w | w color: color ]
]

{ #category : #'spec protocol' }
SpAbstractMorphicAdapter >> delete [
	
	self widgetDo: [ :w | w delete ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> disable [
	
	self model enabled: false
]

{ #category : #'drag and drop' }
SpAbstractMorphicAdapter >> dragEnabled [

	^ self presenter dragEnabled
]

{ #category : #'drag and drop' }
SpAbstractMorphicAdapter >> dragEnabled: aBoolean [

	self widget ifNotNil: [ :w | w dragEnabled: aBoolean ]
]

{ #category : #'drag and drop' }
SpAbstractMorphicAdapter >> dropEnabled [

	^ self presenter dropEnabled
]

{ #category : #'drag and drop' }
SpAbstractMorphicAdapter >> dropEnabled: aBoolean [

	self widget ifNotNil: [ :w | w dropEnabled: aBoolean ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> enable [

	self model enabled: true
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> enabled [
	^ self presenter isEnabled
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> enabled: aBoolean [

	self widget ifNotNil: [ :w | w enabled: aBoolean ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> extent [

	^ self widget extent
]

{ #category : #'focus handling' }
SpAbstractMorphicAdapter >> focusNext [
	
	self presenter withWindowDo: [ :window | | presenters |
		presenters := window allPresentersInFocusOrder.
		(presenters 
			after: self presenter
			ifAbsent: [ presenters first ])
			takeKeyboardFocus ]
]

{ #category : #'focus handling' }
SpAbstractMorphicAdapter >> focusPrevious [
	
	self presenter withWindowDo: [ :window | | presenters |
		presenters := window allPresentersInFocusOrder.
		(presenters 
			before: self presenter
			ifAbsent: [ presenters last ])
			takeKeyboardFocus ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> hRigid [
	
	self widgetDo: [ :w | w hResizing: #rigid ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> hShrinkWrap [
	
	self widgetDo: [ :w | w hResizing: #shrinkWrap ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> hSpaceFill [
	
	self widgetDo: [ :w | w hResizing: #spaceFill ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> help [

	^ self model help
]

{ #category : #accessing }
SpAbstractMorphicAdapter >> helpText [
	
	^ self widget balloonText 
]

{ #category : #'event installing' }
SpAbstractMorphicAdapter >> installEvent: anEvent [
	"Used when installing events into presenters already built"

	self widgetDo: [ :w |
		anEvent 
			installOn: self 
			target: (self eventHandlerReceiver: w) ]
]

{ #category : #'event installing' }
SpAbstractMorphicAdapter >> installFocusLostEvent: anEvent to: aWidget [

	aWidget announcer 
		when: MorphLostFocus
		do: [ anEvent action value ]
]

{ #category : #'event installing' }
SpAbstractMorphicAdapter >> installFocusReceivedEvent: anEvent to: aWidget [

	aWidget announcer 
		when: MorphGotFocus
		do: [ anEvent action value ]
]

{ #category : #'event installing' }
SpAbstractMorphicAdapter >> installKeyDownEvent: anEvent to: aWidget [

	aWidget 
		on: #keyDown
		send: #value:
		to: anEvent action
]

{ #category : #'event installing' }
SpAbstractMorphicAdapter >> installKeyUpEvent: anEvent to: aWidget [

	aWidget 
		on: #keyUp
		send: #value:
		to: anEvent action
]

{ #category : #'event installing' }
SpAbstractMorphicAdapter >> installMouseDoubleClickEvent: anEvent to: aWidget [

	aWidget 
		on: #doubleClick
		send: #value:
		to: anEvent action
]

{ #category : #'event installing' }
SpAbstractMorphicAdapter >> installMouseDownEvent: anEvent to: aWidget [

	aWidget 
		on: #mouseDown
		send: #value:
		to: anEvent action
]

{ #category : #'event installing' }
SpAbstractMorphicAdapter >> installMouseEnterEvent: anEvent to: aWidget [

	aWidget 
		on: #mouseEnter
		send: #value:
		to: anEvent action
]

{ #category : #'event installing' }
SpAbstractMorphicAdapter >> installMouseLeaveEvent: anEvent to: aWidget [

	aWidget 
		on: #mouseLeave
		send: #value:
		to: anEvent action
]

{ #category : #'event installing' }
SpAbstractMorphicAdapter >> installMouseMoveEvent: anEvent to: aWidget [

	aWidget 
		on: #mouseMove
		send: #value:
		to: anEvent action
]

{ #category : #'event installing' }
SpAbstractMorphicAdapter >> installMouseUpEvent: anEvent to: aWidget [

	aWidget 
		on: #mouseUp
		send: #value:
		to: anEvent action
]

{ #category : #testing }
SpAbstractMorphicAdapter >> isMorphicAdapter [

	^ true
]

{ #category : #visibility }
SpAbstractMorphicAdapter >> isVisible [
	
	^ widget visible
]

{ #category : #emulating }
SpAbstractMorphicAdapter >> keyDown: keyCode shift: shiftBoolean meta: metaBoolean control: controlBoolean option: optionBoolean [
	
	^ self 
		keyEvent: #keyDown
		code: keyCode 
		shift: shiftBoolean 
		meta: metaBoolean 
		control: controlBoolean 
		option: optionBoolean
]

{ #category : #emulating }
SpAbstractMorphicAdapter >> keyEvent: type code: keyCode shift: shiftBoolean meta: metaBoolean control: controlBoolean option: optionBoolean [
	| evt modifiers |
	
	modifiers := 0.
	shiftBoolean ifTrue: [ modifiers := modifiers | 8 ].
	metaBoolean ifTrue: [ modifiers := modifiers |
		(Smalltalk os isWin32 | Smalltalk os isUnix
			ifTrue: [ 2r00010000 ]
			ifFalse: [ 2r01000000 ]) ].
	controlBoolean ifTrue: [ modifiers := modifiers | 2r00010000 ].
	optionBoolean ifTrue: [ modifiers := modifiers |
		(Smalltalk os isWin32 | Smalltalk os isUnix
			ifTrue: [ 2r01000000 ]
			ifFalse: [ 2r00100000 ]) ].
		
	evt := KeyboardEvent new
		setType: type
		buttons: modifiers
		position: self widget position + (1 @ 1)
		keyValue: keyCode
		charCode: keyCode
		hand: self currentWorld activeHand
		stamp: Time millisecondClockValue.

	evt key: (KeyboardKey fromCharacter: keyCode asCharacter).
	evt sentTo: self widgetEventReceiver.
	"Some time to allow things to happen?"
	10 milliSeconds wait
]

{ #category : #emulating }
SpAbstractMorphicAdapter >> keyPressed: keyCode shift: shiftBoolean meta: metaBoolean control: controlBoolean option: optionBoolean [
	
	^ self 
		keyEvent: #keystroke
		code: keyCode asciiValue
		shift: shiftBoolean 
		meta: metaBoolean 
		control: controlBoolean 
		option: optionBoolean
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> layout: aLayout [
	| layout |
	layout := aLayout asMorphicLayout.
	self widgetDo: [ :w | w layoutFrame: layout ].
]

{ #category : #styling }
SpAbstractMorphicAdapter >> presenterStyles [
	"The presenters in the style"

	^ self presenter styles
]

{ #category : #'protocol-shortcuts' }
SpAbstractMorphicAdapter >> removeKeyCombination: aShortcut [

	self widgetDo: [ :w | 
		w removeKeyCombination: aShortcut ]
]

{ #category : #styling }
SpAbstractMorphicAdapter >> removeStyle: aStyle [
	"ignore style and just apply it again (the removed style will not be there)"
	self applyStyle: self widget
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> removeSubWidgets [
	
	self widgetDo: [ :w | w removeAllMorphs ]
]

{ #category : #emulating }
SpAbstractMorphicAdapter >> sendClickEvent [
	| evt |

	evt := MouseButtonEvent new 
		setType: nil 
		position: widget center 
		which: MouseButtonEvent redButton 
		buttons: MouseButtonEvent redButton 
		hand: nil 
		stamp: nil.

	(widget handlesMouseDown: evt) ifTrue: [
		widget handleMouseDown: evt.
		widget handleMouseUp: evt ]
]

{ #category : #emulating }
SpAbstractMorphicAdapter >> sendRightClickEvent [
	| evt |

	evt := MouseButtonEvent new 
		setType: nil 
		position: widget center 
		which: MouseButtonEvent yellowButton 
		buttons: MouseButtonEvent yellowButton 
		hand: nil 
		stamp: nil.

	(widget handlesMouseDown: evt) ifTrue: [
		widget mouseDown: evt.
		widget mouseUp: evt ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> setBalloonText: aString [

	self widget ifNotNil: [ :w | 
		w setBalloonText: (
			aString ifNotNil: [ :theString | theString localizedForPresenter: self presenter ] ) ]
	
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> show [ 

	self widgetDo: #show
]

{ #category : #private }
SpAbstractMorphicAdapter >> showContextMenu [

	self presenter contextMenu ifNil: [ ^ self ].
	self showMenu: self presenter contextMenu
]

{ #category : #private }
SpAbstractMorphicAdapter >> showMenu: aValuable [
	| lastShownMenu |
	
	lastShownMenu := self buildMenu: aValuable value.
	lastShownMenu openWithSpec
]

{ #category : #styling }
SpAbstractMorphicAdapter >> style [

	^ SpMorphStyle 
		fromStylesheet: self styleSheet 
		adapter: self
]

{ #category : #styling }
SpAbstractMorphicAdapter >> styleName [
	"i.e. SpButtonAdapter = button"
	
	^ ((self className withoutPrefix: 'SpMorphic') allButLast: 7) uncapitalized
]

{ #category : #styling }
SpAbstractMorphicAdapter >> styleSheet [

	^ self application styleSheet
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> takeKeyboardFocus [
	
	self widgetDo: [ :w | w takeKeyboardFocus ]
]

{ #category : #'drag and drop' }
SpAbstractMorphicAdapter >> transferFor: passenger from: source [

	^ SpTransferPresenter new
		transfer: passenger;
		from: source;
		yourself
]

{ #category : #emulating }
SpAbstractMorphicAdapter >> type: aString [

	aString do: [ :each | 
		self 
			keyPressed: each 
			shift: each isUppercase
			meta: false 
			control: false 
			option: false ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> useProportionalLayout [

	self widgetDo: [ :w | w changeProportionalLayout ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> vRigid [
	
	self widgetDo: [ :w | w vResizing: #rigid ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> vShrinkWrap [
	
	self widgetDo: [ :w | w vResizing: #shrinkWrap ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> vSpaceFill [
	
	self widgetDo: [ :w | w vResizing: #spaceFill ]
]

{ #category : #protocol }
SpAbstractMorphicAdapter >> when: anAnnouncement do: aBlock [

	self widgetDo: [ :w | w announcer
		when: anAnnouncement do: aBlock ]
]

{ #category : #emulating }
SpAbstractMorphicAdapter >> widgetEventReceiver [
	
	^ self eventHandlerReceiver: widget
]
