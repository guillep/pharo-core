"
An IdentifierChooserMorph is a menu builder which takes a list of labels as input and build/popup  a menu for them. The morph could be made of one menu in one column for all labels of of several menus in a scrollabe row. The action which is performed when a menu item is selected is also parametrized (see examples below).
The morph can take the keyboard focus and then, up, down, left and right arrows can be used to choose a menu item.
It is the responsibility of the user of this morph to decide when and how the keyboard focus is token.
The design is widely inpired from PopupChoiceDialogWindow.

example 1
A very simple example with three label. The nil value will be represented as a menu line in the resulting morph.
(IdentifierChooserMorph 
		labels: {'aaaaaa'. 'bbbbbbb'. nil. 'cccccccc'}
		chooseBlock: [ :chosen | UIManager default inform: (chosen, (' has been chosen' translated))])
			open
			
example 2
The same except that a color is specified		
(IdentifierChooserMorph 
		labels: {'aaaaaa'. 'bbbbbbb'. nil. 'cccccccc'}
		chooseBlock: [ :chosen | UIManager default inform: (chosen, (' has been chosen' translated))])
			baseColor: Color white;
			open

example 3
Allows the presentation of one menu (one column) vith two fixed labels followed by the list of all classes.
(IdentifierChooserMorph 
		labels: ({'aaaaaa'. 'bbbbbbb'}, { nil }, (Object allSubclasses collect: [:c | c theNonMetaClass  name]) asSet asArray sort)
		chooseBlock: [ :chosen | (Smalltalk globals at: chosen asSymbol) ifNotNil: [:c | c browse] ]) 
			oneMenuOfWidth: 300;
			baseColor: Color white;
			open

Instance Variables
	baseColor:		<Color>
	choiceMenus:		<Array>
	choicesMorph:		<AlignmentMorph>
	chooseBlock:		<Block>
	labels:		<Array>
	maxLines:		<Integer>
	requestor:		<Morph>
	scrollPaneWidth:		<Integer>

baseColor
	- The color used for the menu items and the receiver

choiceMenus
	- The array of EmbeddedMenuMorph

choicesMorph
	- The AlignmentMorph which contains all menus

chooseBlock
	- A block with one argument which is evaluated when a menu item is selected. The argument takes the chosen label as argument

labels
	- The array of labels 

maxLines
	- If not nil, gives the maximum number of lines for one menu

requestor
	- if not nil, a Morph from which the receiver is built

scrollPaneWidth
	- The maximum width of the scrollPane, this contraints the width of the receiver.

"
Class {
	#name : #IdentifierChooserMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'requestor',
		'labels',
		'choiceMenus',
		'chooseBlock',
		'maxLines',
		'choicesMorph',
		'scrollPaneWidth',
		'baseColor'
	],
	#category : #'Polymorph-Widgets-Base'
}

{ #category : #accessing }
IdentifierChooserMorph class >> allowedArea [
	"The area allowed for the building and positioning of the morph"
	| allowedArea |
	allowedArea := Display usableArea.
	allowedArea := allowedArea intersect: self currentWorld visibleClearArea ifNone: [ 0@0 corner: 0@0 "not sure about this"].
	^allowedArea
]

{ #category : #'instance creation' }
IdentifierChooserMorph class >> example [

	(self 
		labels: #('aaa' 'bbb' 'ccc') 
		chooseBlock:  [ :currText | currText matches: '*bb'])
	openInWorld
]

{ #category : #'instance creation' }
IdentifierChooserMorph class >> labels: aCollection chooseBlock: aBlock [
	"return a new chooser or nil"
	^ aCollection isEmpty
		ifFalse: [ self new chooseBlock: aBlock; labels: aCollection; yourself].

]

{ #category : #'event handling' }
IdentifierChooserMorph >> activate: evt [
	"Backstop."
	
]

{ #category : #accessing }
IdentifierChooserMorph >> allowedArea [
	^ self class allowedArea
]

{ #category : #accessing }
IdentifierChooserMorph >> baseColor [
	^ baseColor ifNil: [baseColor := self defaultBaseColor]
]

{ #category : #accessing }
IdentifierChooserMorph >> baseColor: aColor [
	baseColor := aColor.
	self setColor: aColor
]

{ #category : #accessing }
IdentifierChooserMorph >> choiceMenuItems [
	"Answer the value of choiceMenus"

	^ Array streamContents: [:strm | self choiceMenus  do: [:menu | strm nextPutAll: menu menuItems]].

]

{ #category : #accessing }
IdentifierChooserMorph >> choiceMenus [
	"Answer the value of choiceMenus"

	^ choiceMenus
]

{ #category : #accessing }
IdentifierChooserMorph >> choiceMenus: anObject [
	"Set the value of choiceMenus"

	choiceMenus := anObject
]

{ #category : #accessing }
IdentifierChooserMorph >> choicesMorph: aMorph [
	choicesMorph := aMorph
]

{ #category : #action }
IdentifierChooserMorph >> choose: index [
	"Set the given choice and ok."
	| chosen |
	chosen := index > 0 ifTrue: [self labels at: index] ifFalse: [nil].
	chooseBlock value: chosen.
	self close.
	requestor ifNotNil: [requestor takeKeyboardFocus]

]

{ #category : #accessing }
IdentifierChooserMorph >> chooseBlock: aBlock [
	chooseBlock := aBlock
]

{ #category : #action }
IdentifierChooserMorph >> close [
	self delete.

]

{ #category : #accessing }
IdentifierChooserMorph >> defaultBaseColor [
	^ Color transparent
]

{ #category : #'event handling' }
IdentifierChooserMorph >> deleteIfPopUp: evt [
	"For compatibility with MenuMorph."
]

{ #category : #'ui-building' }
IdentifierChooserMorph >> forcesHeight: aHeight [
	| sp |
	(sp := self scrollPane) minHeight: aHeight.
	sp height: sp minHeight.
 	self height: sp height. 
]

{ #category : #'event handling' }
IdentifierChooserMorph >> handlesKeyboard: evt [
	"True when either the filter morph doesn't have the focus and the key
	is a text key or backspace or no menus have the focus and is up or down arrow."
	^(super handlesKeyboard: evt) or: [
		(self hasKeyboardFocus)
			ifTrue: [	evt keyCharacter = Character escape
						or: [evt keyCharacter = Character cr
						or: [evt keyCharacter = Character arrowLeft
						or: [evt keyCharacter = Character arrowRight
						or: [evt keyCharacter = Character arrowUp
						or: [evt keyCharacter = Character arrowDown]]]]]]
			ifFalse: [	evt keyCharacter = Character escape
						or: [evt keyCharacter = Character arrowUp
						or: [evt keyCharacter = Character arrowDown
						or: [evt keyCharacter = Character arrowLeft
						or: [evt keyCharacter = Character arrowRight]]]]]]
]

{ #category : #initialization }
IdentifierChooserMorph >> initialize [
	super initialize.
	self borderWidth: 1.
	self layoutInset: 0.
	self changeTableLayout.
	self hResizing: #shrinkWrap.
	self vResizing: #shrinkWrap.
	self color: self defaultBaseColor.

]

{ #category : #'event handling' }
IdentifierChooserMorph >> keyDown: anEvent [
	anEvent keyCharacter = Character escape 
		ifTrue: [self close. 
			requestor 
				ifNotNil: [requestor takeKeyboardFocus]. 
				^true].
	anEvent keyCharacter = Character arrowUp ifTrue: [self selectPreviousItem. ^true].
	anEvent keyCharacter = Character arrowDown ifTrue: [self selectNextItem. ^true].
	anEvent keyCharacter = Character arrowLeft ifTrue: [self switchToPreviousColumn. ^true].
	anEvent keyCharacter = Character arrowRight ifTrue: [self switchToNextColumn. ^true].
	anEvent keyCharacter = Character cr
		ifTrue: [ ^ self processEnter: anEvent ].
	^false
]

{ #category : #'event handling' }
IdentifierChooserMorph >> keyStroke: anEvent [
	anEvent keyCharacter = Character space
		ifTrue: [ ^self processEnter: anEvent ].
	^false
]

{ #category : #accessing }
IdentifierChooserMorph >> labels [
	"Answer the value of labels"

	^ labels
]

{ #category : #accessing }
IdentifierChooserMorph >> labels: aCollectionOfString [
	"Set the value of labels"
	labels := aCollectionOfString
]

{ #category : #accessing }
IdentifierChooserMorph >> listHeight [
	"Answer the height for the list."

	^ choicesMorph height
]

{ #category : #accessing }
IdentifierChooserMorph >> listMorph [
	"Answer the height for the list."

	^ choicesMorph
]

{ #category : #accessing }
IdentifierChooserMorph >> maxLines [
	^ maxLines ifNil: [maxLines := 6]
]

{ #category : #accessing }
IdentifierChooserMorph >> maxLines: anInteger [
	maxLines := anInteger
]

{ #category : #'ui-building' }
IdentifierChooserMorph >> newChoiceButtonFor: index [
	"Answer a new choice button."
	^ (self labels at: index) 
		ifNotNil: [:v | (ToggleMenuItemMorph new
			contents: v asText;
			target: self;
			selector: #choose:;
			arguments: {index})
			cornerStyle: #square;
			hResizing: #spaceFill]
		ifNil: [MenuLineMorph new]
		
]

{ #category : #'ui-building' }
IdentifierChooserMorph >> newChoicesMorph [

	"Answer a row of columns of buttons and separators based on the model."

	| answer morphs str |

	answer := self newRow
		cellPositioning: #topLeft;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.
	self labels ifEmpty: [ ^ answer ].
	self labels first ifNil: [ self labels: self labels allButFirst ].
	self labels ifEmpty: [ ^ answer ].
	self labels last ifNil: [ self labels: self labels allButLast ].
	self labels ifEmpty: [ ^ answer ].
	morphs := OrderedCollection new.
	1 to: self labels size do: [ :i | morphs add: ( self newChoiceButtonFor: i ) ].
	str := morphs readStream.
	[ str atEnd ]
		whileFalse: [ answer
				addMorphBack: ( self newMenuWith: ( str next: self maxLines ) );
				addMorphBack: self newVerticalSeparator
			].
	answer removeMorph: answer submorphs last.
	answer submorphs last hResizing: #spaceFill.
	scrollPaneWidth
		ifNotNil: [ answer hResizing: #spaceFill.
			answer submorphs last hResizing: #rigid.
			answer submorphs last width: scrollPaneWidth
			].
	self choiceMenus: ( answer submorphs select: [ :m | m isMenuMorph ] ).
	^ answer
]

{ #category : #'ui-building' }
IdentifierChooserMorph >> newContentMorph [
	"Answer a new content morph."

	| sp choices |
	self choicesMorph: (choices := self newChoicesMorph).
	sp := (self newScrollPaneFor: choices)
		color: Color transparent;
		scrollTarget: choices;
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	sp
		minWidth: (scrollPaneWidth ifNil: [(choicesMorph width min: (Display width // 2) - 50) + sp scrollBarThickness]);
		minHeight: (choicesMorph height min: (Display height // 3)).
	choicesMorph width > sp minWidth
		ifTrue: [sp minHeight: sp minHeight + sp scrollBarThickness].
	^ sp
]

{ #category : #'ui-building' }
IdentifierChooserMorph >> newMenu [ 
	^ self theme
		newEmbeddedMenuIn: self
		for: self
]

{ #category : #'ui-building' }
IdentifierChooserMorph >> newMenuWith: menuItems [
	"Answer menu with the given morphs."

	| menu |
	menu := self newMenu.
	menu cornerStyle: #square.
	menuItems do: [:m | menu addMorphBack: m].
	menu
		borderWidth: 0;
		color: self baseColor;
		borderColor:  Color transparent;
		stayUp: true;
		beSticky;
		removeDropShadow;
		popUpOwner: (MenuItemMorph new privateOwner: self).
	^ menu
]

{ #category : #'ui-building' }
IdentifierChooserMorph >> newRow [
	^ AlignmentMorph new
		listDirection: #leftToRight;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		extent: 1@1;
		borderWidth: 0;
		color: Color transparent.

]

{ #category : #'ui-building' }
IdentifierChooserMorph >> newScrollPaneFor: aMorph [
	^ self theme
		newScrollPaneIn: self
		for: aMorph
]

{ #category : #'ui-building' }
IdentifierChooserMorph >> newVerticalSeparator [

	^ SeparatorMorph new
		fillStyle: Color transparent;
		borderStyle: (BorderStyle inset baseColor: Color gray; width: 1);
		extent: 1@1;
		vResizing: #spaceFill
]

{ #category : #'ui-building' }
IdentifierChooserMorph >> oneMenuOfWidth: anInteger [
	self maxLines: 999999999.
	scrollPaneWidth := anInteger.

]

{ #category : #'ui-building' }
IdentifierChooserMorph >> open [
	self addMorph: self newContentMorph.
	self openInWorld.

]

{ #category : #'event handling' }
IdentifierChooserMorph >> processEnter: anEvent [
	self choiceMenus do: [:embeddedMenu | 
		embeddedMenu selectedItem ifNotNil: [:item |
			item invokeWithEvent: anEvent.
			^true ] ].
	^false
]

{ #category : #accessing }
IdentifierChooserMorph >> requestor [
	^ requestor
]

{ #category : #accessing }
IdentifierChooserMorph >> requestor: aTextMorph [
	requestor := aTextMorph
]

{ #category : #'ui-building' }
IdentifierChooserMorph >> scrollPane [
	"Answer the scroll pane."

	^self findDeeplyA: GeneralScrollPaneMorph
]

{ #category : #'event handling' }
IdentifierChooserMorph >> selectFirstItem [
	"Select the first item in the embedded menus"

	self choiceMenus first selectItem:  self choiceMenuItems first event: nil.
	self takeKeyboardFocus.
]

{ #category : #'event handling' }
IdentifierChooserMorph >> selectLastItem [
	"Select the last item in the embedded menus"

	self choiceMenus last selectItem:  self choiceMenuItems last event: nil.
	self activeHand newKeyboardFocus: self.

]

{ #category : #'event handling' }
IdentifierChooserMorph >> selectNextItem [
	"Select the next item in the embedded menus"

	| idx next |
	self choiceMenus 
		do: [:embeddedMenu | embeddedMenu menuItems 
			do: [:mi | ((mi isMenuItemMorph)  and: [mi isSelected])
				ifTrue: [idx := embeddedMenu menuItems indexOf: mi.
					idx = embeddedMenu menuItems size
						ifTrue: [idx := 0].
					idx := idx + 1. 
					[(embeddedMenu menuItems at: idx) isMenuItemMorph]
						whileFalse: [idx := idx+ 1].
					next := embeddedMenu menuItems at: idx.
					self activeHand newKeyboardFocus: self.
					self scrollPane ifNotNil: [:sp | sp scrollToShow: next bounds].
					^ embeddedMenu selectItem: next event: nil]]].
	self selectFirstItem
]

{ #category : #'event handling' }
IdentifierChooserMorph >> selectPreviousItem [
	"Select the previous item in the embedded menus"

	| idx previous |
	self choiceMenus 
		do: [:embeddedMenu | embeddedMenu menuItems 
			do: [:mi | ((mi isMenuItemMorph)  and: [mi isSelected])
				ifTrue: [idx := embeddedMenu menuItems indexOf: mi.
					idx = 1
						ifTrue: [idx := embeddedMenu menuItems size + 1].
					idx := idx - 1. 
					[(embeddedMenu menuItems at: idx) isMenuItemMorph]
						whileFalse: [idx := idx- 1].
					previous := embeddedMenu menuItems at: idx.
					self scrollPane ifNotNil: [:sp | sp scrollToShow: previous bounds].
					^ embeddedMenu selectItem: previous event: nil]]].
	self selectFirstItem.

]

{ #category : #'ui-building' }
IdentifierChooserMorph >> setColor: aColor [
	self color: aColor.
	self choiceMenus 
		ifNotNil: [:menus | menus 
			do: [:cm | cm color: aColor]]
]

{ #category : #'event handling' }
IdentifierChooserMorph >> switchToNextColumn [
	"Give the next embedded menu keyboard focus."

	self switchToOtherColumn: [:prevIdx | 
		prevIdx =  self choiceMenus size
				ifTrue: [1]
				ifFalse: [prevIdx + 1]]

]

{ #category : #'event handling' }
IdentifierChooserMorph >> switchToOtherColumn: aBlock [

	"Give the next embedded menu keyboard focus. 
	The next menu indice is computed by the argument"

	| menuWithFocus idx menu sub subIdx |

	( self choiceMenus isNil or: [ self choiceMenus isEmpty ] )
		ifTrue: [ ^ self ].
	menuWithFocus := self choiceMenus
		detect: [ :m | 
			m menuItems
				anySatisfy: [ :sm | 
					( sm isMenuItemMorph and: [ sm isSelected ] )
						ifTrue: [ sub := sm ].
					sm isSelected
					]
			]
		ifNone: [  ].
	self choiceMenus do: [ :embeddedMenu | embeddedMenu selectItem: nil event: nil ].
	menuWithFocus
		ifNil: [ self selectFirstItem ]
		ifNotNil: [ idx := aBlock value: ( self choiceMenus indexOf: menuWithFocus ).
			menu := self choiceMenus at: idx.
			subIdx := sub
				ifNil: [ 1 ]
				ifNotNil: [ ( menuWithFocus menuItems indexOf: sub ) min: menu menuItems size ].
			menu selectItem: ( menu menuItems at: subIdx ) event: nil.
			self scrollPane ifNotNil: [ :sp | sp scrollToShow: menu bounds ]
			].
	self activeHand newKeyboardFocus: self
]

{ #category : #'event handling' }
IdentifierChooserMorph >> switchToPreviousColumn [
	"Give the previous embedded menu keyboard focus."

	self switchToOtherColumn: [:prevIdx | 
		prevIdx =  1
			ifTrue: [self choiceMenus size]
			ifFalse: [prevIdx - 1]]

]
