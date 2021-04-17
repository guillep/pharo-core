"
I prepare a shortcut as a combination of symbols (the command, alt, etc. symbols... check #symbolTable to have a detail). 
We also trust in the presence of FreeType fonts (a default nowadays) and ""Lucida Grande"" font, the mac font used to show menus. 

If any of this conditions are not fullfilled, ToggleMenuIttemMorph with not use me but my sibling.
"
Class {
	#name : #ToggleWithSymbolMenuItemShortcut,
	#superclass : #ToggleMenuItemShortcut,
	#classVars : [
		'SymbolFont',
		'SymbolTable'
	],
	#category : #'Morphic-Base-Menus'
}

{ #category : #testing }
ToggleWithSymbolMenuItemShortcut class >> canBeUsed [
	^ OSPlatform current isMacOS 
		and: [ self symbolFont isTTCFont 
		and: [ self symbolFont familyName = self symbolFont realFont face familyName ] ]
]

{ #category : #private }
ToggleWithSymbolMenuItemShortcut class >> createSymbolFont [
	^ LogicalFont 
		familyName: 'Lucida Grande' 
		pointSize: 10
]

{ #category : #private }
ToggleWithSymbolMenuItemShortcut class >> createSymbolTable [
	| attributes |
	attributes := {TextFontReference toFont: self symbolFont}.
	^ Dictionary newFromPairs: { 
		#Cmd. 		Text string: (Character value: 16r2318) asString attributes: attributes.
		#Alt. 		Text string: (Character value: 16r2325) asString attributes: attributes. 
		#Ctrl.  	Text string: (Character value: 16r2303) asString attributes: attributes. 
		#Shift. 	Text string: (Character value: 16r21E7) asString attributes: attributes.
		"Lucida does not have the enter key"
		"#Enter. 	Text string: (Character value: 16r23ce) asString attributes: attributes" }.

]

{ #category : #accessing }
ToggleWithSymbolMenuItemShortcut class >> priority [
	^ 0
]

{ #category : #accessing }
ToggleWithSymbolMenuItemShortcut class >> symbolFont [
	^ SymbolFont ifNil: [ SymbolFont := self createSymbolFont ]
]

{ #category : #accessing }
ToggleWithSymbolMenuItemShortcut class >> symbolTable [
	^ SymbolTable ifNil: [ SymbolTable := self createSymbolTable ]
]

{ #category : #accessing }
ToggleWithSymbolMenuItemShortcut class >> symbolTableAt: anObject ifAbsent: aBlock [
	^ self symbolTable at: anObject ifAbsent: aBlock
]

{ #category : #drawing }
ToggleWithSymbolMenuItemShortcut >> drawOn: aCanvas [
	| text paragraph keyBounds keyFont |

	text := self text.
	keyFont := self class symbolFont.

	keyBounds := self boundsForKeyText: text string font: keyFont.
	paragraph := Paragraph new
		compose: text
			style: (TextStyle fontArray: { keyFont })
			from: 1
			in: (0@0 corner: keyBounds corner);
		yourself.
		
	aCanvas 
		paragraph: paragraph 
		bounds: keyBounds 
		color: self color
]

{ #category : #drawing }
ToggleWithSymbolMenuItemShortcut >> text [
	| keyParts |
	keyParts := (self keyText substrings: '+') collect: [:each | each trimBoth].

	"Ensure shift is first"
	((keyParts includes: 'Shift') and: [ (keyParts first = 'Shift') not ])
		ifTrue: [ keyParts := (keyParts copyWithout: 'Shift') copyWithFirst: 'Shift' ].
	^ keyParts inject: Text new into: [ :s :each | s , (self class symbolTableAt: each ifAbsent: [ each capitalized ]) ]
]
