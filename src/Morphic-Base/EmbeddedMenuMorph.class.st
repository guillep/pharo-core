"
Menu designed to be embedded in another morph rather than popped up directly.
"
Class {
	#name : #EmbeddedMenuMorph,
	#superclass : #MenuMorph,
	#category : #'Morphic-Base-Menus'
}

{ #category : #accessing }
EmbeddedMenuMorph >> allEnabledSiblingItems [
	"Answer the receiver's submorphs followed by the (wrapping) owner's
	submorph items. Answer only enabled items."

	^self allSiblingItems select: [:item | item isEnabled]
]

{ #category : #accessing }
EmbeddedMenuMorph >> allSiblingItems [
	"Answer the receiver's submorphs followed by the (wrapping) owner's
	submorph items. Nasty."

	|menus str index|
	str := (Array new: 40) writeStream.
	menus := self owner submorphs select: [:m | m isKindOf: self class].
	menus := (menus copyFrom: (index := menus indexOf: self) to: menus size), (menus copyFrom: 1 to: index - 1).
	menus do: [:menu |
		str nextPutAll: menu items].
	^str contents
]

{ #category : #drawing }
EmbeddedMenuMorph >> drawOn: aCanvas [
	"Draw the receiver on the canvas."

	self perform: #drawOn: withArguments: {aCanvas} inSuperclass: Morph.
	self hasKeyboardFocus ifTrue: [self drawKeyboardFocusOn: aCanvas]
]

{ #category : #'keyboard control' }
EmbeddedMenuMorph >> handlesKeyboard: evt [
	"Answer whether the receiver handles the keystroke represented by the event"

	^true
]

{ #category : #events }
EmbeddedMenuMorph >> keyDown: evt [
	"Handle tabbing and arrows and cr/space."

	| key |
		
	key := evt key.
	(key isArrowLeft or: [ key isArrowRight ])
		ifTrue: [ (selectedItem notNil and: [ selectedItem hasSubMenu ])
				ifTrue: [ evt hand newMouseFocus: selectedItem subMenu.
					selectedItem subMenu moveSelectionDown: 1 event: evt.
					^ evt hand newKeyboardFocus: selectedItem subMenu ] ].
	
	key isArrowUp ifTrue: [ ^ self moveSelectionDown: -1 event: evt ].	"up arrow key"
	key isArrowDown ifTrue: [ ^ self moveSelectionDown: 1 event: evt ].	"down arrow key"
	key = KeyboardKey pageUp ifTrue: [ ^ self moveSelectionDown: -5 event: evt ].	"page up key"
	key = KeyboardKey pageDown ifTrue: [ ^ self moveSelectionDown: 5 event: evt ].	"page down key"

	self window ifNotNil: [:win |
		(win handlesKeyDown: evt) ifTrue: [
			(win keyDown: evt) ifTrue: [^true]]].
]

{ #category : #events }
EmbeddedMenuMorph >> keyStroke: event [
	"Handle tabbing and arrows and cr/space."

	| selectable |

	self window ifNotNil: [:win |
		(win handlesKeyStroke: event) ifTrue: [
			(win keyStroke: event) ifTrue: [^true]]].
	event key = KeyboardKey space
		ifTrue: [ selectedItem
			ifNotNil: [ ^ selectedItem hasSubMenu
					ifTrue: [ event hand newMouseFocus: selectedItem subMenu.
						selectedItem subMenu takeKeyboardFocus ]
					ifFalse: [ selectedItem invokeWithEvent: event ] ].
		(selectable := self items) size = 1 ifTrue: [ ^ selectable first invokeWithEvent: event ].
		^ self ].
]

{ #category : #'keyboard control' }
EmbeddedMenuMorph >> keyboardFocusChange: aBoolean [
	"Nasty hack for scrolling upon keyboard focus."

	super keyboardFocusChange: aBoolean.
	aBoolean
		ifTrue: [(self ownerThatIsA: GeneralScrollPaneMorph) ifNotNil: [:sp |
					sp scrollToShow: self bounds]]
		ifFalse: [self selectItem: nil event: nil]
]

{ #category : #'keyboard control' }
EmbeddedMenuMorph >> moveSelectionDown: anInteger event: anEvent [
	"Move the selection down or up (negative number) by (at least)
	the specified amount. If the item is not enabled, scan one at a time
	in that direction. If we move off the top/bottom then switch focus to any
	sibling menu and start scanning at the relevant end."

	| allEnabledSiblingItems index|
	allEnabledSiblingItems := self allEnabledSiblingItems.
	index := (allEnabledSiblingItems indexOf: selectedItem ifAbsent: [0 + (anInteger negative ifTrue: [1] ifFalse: [0])]) + anInteger.
	allEnabledSiblingItems do: "Ensure finite"
		[:unused | | m | m := allEnabledSiblingItems atWrap: index.
		((m isMenuItemMorph) and: [m isEnabled]) ifTrue:
			[m owner = self owner ifFalse: [
				anEvent hand newKeyboardFocus: m owner].
				^m owner selectItem: m event: anEvent].
		"Keep looking for an enabled item"
		index := index + anInteger sign].
	^self selectItem: nil event: anEvent
]

{ #category : #control }
EmbeddedMenuMorph >> selectItem: aMenuItem event: anEvent [
	"Deselect any sibling menus."
	
	self owner ifNotNil: [
		|menus|
		menus := self owner submorphs select: [:m | (m isKindOf: self class) and: [m ~~ self]].
		menus do: [:menu |
			menu
				perform: #selectItem:event:
				withArguments: {nil. anEvent}
				inSuperclass: self class superclass] ].
		
	^super selectItem: aMenuItem event: anEvent
]

{ #category : #selecting }
EmbeddedMenuMorph >> selectLastMatch: aString [
	"Answer the last subitem that has text that includes the given substring.
	Answer nil if none.
	Disable non-matching items and enable matching items."

	|lastMatch|
	self items reverseDo: [:item | | match |
		match := aString isEmpty or: [item contents asString asLowercase includesSubstring: aString].
		item isEnabled: match.
		(match and: [lastMatch isNil]) ifTrue: [lastMatch := item]].
	^lastMatch
]

{ #category : #selecting }
EmbeddedMenuMorph >> selectLastPrefix: aString [
	"Answer the last subitem that has text that matches the given prefix.
	Answer nil if none.
	Disable non-matching items and enable matching items."

	|lastMatch|
	self items reverseDo: [:item | | match |
		match := aString isEmpty or: [item contents asString asLowercase beginsWith: aString].
		item isEnabled: match.
		(match and: [lastMatch isNil]) ifTrue: [lastMatch := item]].
	^lastMatch
]

{ #category : #selecting }
EmbeddedMenuMorph >> selectMatch: aString [
	"Answer the first subitem that has text that includes the given substring.
	Answer nil if none.
	Disable non-matching items and enable matching items."

	|firstMatch|
	self items do: [:item | | match |
		match := aString isEmpty or: [item contents asString asLowercase includesSubstring: aString].
		item isEnabled: match.
		(match and: [firstMatch isNil]) ifTrue: [firstMatch := item]].
	^firstMatch
]

{ #category : #selecting }
EmbeddedMenuMorph >> selectPrefix: aString [
	"Answer the first subitem that has text that matches the given prefix.
	Answer nil if none.
	Disable non-matching items and enable matching items."

	| firstMatch|
	self items do: [:item | | match |
		match := aString isEmpty or: [item contents asString asLowercase beginsWith: aString].
		item isEnabled: match.
		(match and: [firstMatch isNil]) ifTrue: [firstMatch := item]].
	^firstMatch
]
