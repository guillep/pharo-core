"
A CharacterScanner holds the state associated with scanning text. Subclasses scan characters for specified purposes, such as computing a CharacterBlock or placing characters into Forms.

Instance Variables
	alignment:		<Integer>
	destX:		<Number>
	destY:		<Number>
	emphasisCode:		<Object>
	font:		<AbstractFont>
	indentationLevel:		<Integer>
	kern:		<Number>
	lastIndex:		<Integer>
	leftMargin:		<Number>
	line:		<TextLine>
	map:		<Array>
	pendingKernX:		<Number>
	rightMargin:		<Number>
	runStopIndex:		<Integer>
	spaceCount:		<Integer>
	spaceWidth:		<Number>
	stopConditions:		<Array>
	text:		<Text>
	textStyle:		<TextStyle>
	wantsColumnBreaks:		<Boolean>
	xTable:		<Array>

alignment
	- an Integer encoding the alignment of text

destX
	- horizontal position for next character (distance from left of composition area)

destY
	- vertical position for next character (distance from top of composition area)

emphasisCode
	- an Integer encoding the current text emphasis to use (bold, italic, ...)

font
	- the current font used for measuring/composing/displaying characters

indentationLevel
	- an Integer specifying a number of leading tabs to be inserted at beginning of new lines

kern
	- a Number specifying additional horizontal spacing to place between characters (spacing is reduced when kern is negative)

lastIndex
	- the Integer index of next character to be processed in the text

leftMargin
	- a Number specifying the distance between left of composition zone and left of first character in the line.

line
	- an object holding information about the line currently being displayed (like first and last index in text).
	Note: this is either a TextLine in Morphic, or TextLineInterval for ST80 compatibility

map
	- an array mapping character code to glyph position.
	This is used by primitive 103 only, in case of ByteString.

pendingKernX
	- a Number to be added to horizontal spacing of next char if ever it is in the same font than previous one.
	The inner scan loop is interrupted by a change of text run.
	But some changes won't change the font, so the kerning must be remembered and applied later.

rightMargin
	- a Number specifying the distance between right of composition zone and right of last character in the line.

runStopIndex
	- the Integer index of last character in current text run.

spaceCount
	- the number of spaces encoutered so far in current line. This is useful for adjusting the spacing in cas of Justified alignment.

spaceWidth
	- the width of space character in current font.

stopConditions
	- an Array mapping a table of characters codes for which special actions are to be taken.
	These are typically control characters like carriage return or horizontal tab.

text
	- the text to be measured/composed/displayed

textStyle
	- an object holding a context for the text style (which set of font to use, which margins, etc...)

wantsColumnBreaks
	- a Boolean indicating whether some special handling for multiple columns is requested.
	THIS ONLY MAKES SENSE IN CompositionScanner AND SHOULD BE MOVED TO THE SUBCLASS
	
xTable
	- an array mapping character code to glyph x coordinate in form.
	This is used by primitive 103 only, in case of ByteString.
	
Implementation note: accelerated Character scanning with primitive 103 requires following order for 5 first instance variables, please don't alter:
destX lastIndex xTable map destY

"
Class {
	#name : #CharacterScanner,
	#superclass : #Object,
	#instVars : [
		'destX',
		'lastIndex',
		'xTable',
		'map',
		'destY',
		'stopConditions',
		'text',
		'textStyle',
		'alignment',
		'leftMargin',
		'rightMargin',
		'font',
		'line',
		'runStopIndex',
		'spaceCount',
		'spaceWidth',
		'emphasisCode',
		'kern',
		'indentationLevel',
		'pendingKernX'
	],
	#classVars : [
		'ColumnBreakStopConditions',
		'CompositionStopConditions',
		'DefaultStopConditions',
		'MeasuringStopConditions',
		'PaddedSpaceCondition'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'Text-Scanning'
}

{ #category : #'class initialization' }
CharacterScanner class >> initialize [
"
	CharacterScanner initialize
"
	| a |
	a := Array new: 258.
	a at: 1 + 1 put: #embeddedObject.
	a at: Tab asciiValue + 1 put: #tab.
	a at: CR asciiValue + 1 put: #cr.
	a at: Character lf asciiValue + 1 put: #cr.
	"Note: following two codes are used only by primitive 103 for accelerated Character scanning"
	a at: 257 put: #endOfRun.
	a at: 258 put: #crossedX.
	
	DefaultStopConditions := a copy.

	CompositionStopConditions := a copy.
	CompositionStopConditions at: Space asciiValue + 1 put: #space.
	ColumnBreakStopConditions := CompositionStopConditions copy.
	ColumnBreakStopConditions at: TextComposer characterForColumnBreak asciiValue + 1 put: #columnBreak.

	PaddedSpaceCondition := a copy.
	PaddedSpaceCondition at: Space asciiValue + 1 put: #paddedSpace.

	MeasuringStopConditions := (Array new: 258)
		at: 257 put: #endOfRun;
		at: 258 put: #crossedX;
		yourself
]

{ #category : #'text attributes' }
CharacterScanner >> addEmphasis: code [
	"Set the bold-ital-under-strike emphasis."
	emphasisCode := emphasisCode bitOr: code
]

{ #category : #'text attributes' }
CharacterScanner >> addKern: kernDelta [
	"Set the current kern amount."
	kern := kern + kernDelta
]

{ #category : #private }
CharacterScanner >> advanceIfFirstCharOfLine [
	lastIndex = line first
		ifTrue:
			[destX := destX + pendingKernX + (font widthOf: (text at: line first)).
			lastIndex := lastIndex + 1.
			pendingKernX := 0].
]

{ #category : #scanning }
CharacterScanner >> basicScanByteCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX [ 
"this is a scanning method for
single byte characters in a ByteString
a font that does not do character-pair kerning"
	| ascii nextDestX char |
	lastIndex := startIndex.
	[lastIndex <= stopIndex]
		whileTrue: [
			"get the character value"
			char := sourceString at: lastIndex.
			ascii := char asciiValue + 1.
			"if there is an entry in 'stops' for this value, return it"
			(stopConditions at: ascii)
				ifNotNil: [^ stopConditions at: ascii].
			"bump nextDestX by the width of the current character"
			nextDestX := destX + (font widthOf: char).
			"if the next x is past the right edge, return crossedX"
			nextDestX > rightX
				ifTrue: [^#crossedX].
			"update destX and incorporate thr kernDelta"
			destX := nextDestX + kern.
			lastIndex := lastIndex + 1].
	^self handleEndOfRunAt: stopIndex


]

{ #category : #'stop conditions' }
CharacterScanner >> columnBreak [

	pendingKernX := 0.
	^true
]

{ #category : #'stop conditions' }
CharacterScanner >> embeddedObject [
	pendingKernX := 0.
	text attributesAt: lastIndex do:[:attr| 
		attr anchoredMorph ifNotNil:[
			"Try to placeEmbeddedObject: - if it answers false, then there's no place left"
			(self placeEmbeddedObject: attr anchoredMorph) ifFalse:[^self crossedX]]].
	"Note: if ever several objects are embedded on same character, only indent lastIndex once"
	lastIndex := lastIndex + 1.
	^false
]

{ #category : #'stop conditions' }
CharacterScanner >> handleEndOfRunAt: stopIndex [
	" make sure the lastIndex is set to stopIndex and then return the stopCondition for endOfRun; important for  a couple of outside users"

	lastIndex := stopIndex.
	^#endOfRun
]

{ #category : #private }
CharacterScanner >> handleIndentation [
	self indentationLevel timesRepeat: [
		destX := self plainTab]
]

{ #category : #private }
CharacterScanner >> indentationLevel [
	"return the number of tabs that are currently being placed at the beginning of each line"
	^indentationLevel ifNil:[0]
]

{ #category : #'text attributes' }
CharacterScanner >> indentationLevel: anInteger [
	"set the number of tabs to put at the beginning of each line"
	indentationLevel := anInteger
]

{ #category : #initialization }
CharacterScanner >> initialize [
	destX := destY := leftMargin := 0.
]

{ #category : #private }
CharacterScanner >> leadingTab [
	"return true if only tabs lie to the left"
	line first to: lastIndex do:
		[:i | (text at: i) == Tab ifFalse: [^ false]].
	^ true
]

{ #category : #scanning }
CharacterScanner >> measureString: aString inFont: aFont from: startIndex to: stopIndex [
	"Measure aString width in given font aFont.
	The string shall not include line breaking, tab or other control character."
	destX := destY := lastIndex := 0.
	pendingKernX := 0.
	font := aFont.
	kern := 0 - font baseKern.
	spaceWidth := font widthOf: Space.
	stopConditions := MeasuringStopConditions.
	self scanCharactersFrom: startIndex to: stopIndex in: aString rightX: 999999.
	^destX
]

{ #category : #private }
CharacterScanner >> placeEmbeddedObject: anchoredMorph [
	"Place the anchoredMorph or return false if it cannot be placed"
	^ true
]

{ #category : #private }
CharacterScanner >> plainTab [
	"This is the basic method of adjusting destX for a tab.
	Answer the next destX"
	pendingKernX := 0.
	^(alignment = Justified and: [self leadingTab not])
		ifTrue:		"embedded tabs in justified text are weird"
			[destX + (textStyle tabWidth - (line justifiedTabDeltaFor: spaceCount)) max: destX]
		ifFalse: 
			[textStyle nextTabXFrom: destX
				leftMargin: leftMargin
				rightMargin: rightMargin].
]

{ #category : #scanning }
CharacterScanner >> scanByteCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX [ 
"this is a scanning method for
single byte characters in a ByteString
a font that does not do character-pair kerning"

	^ self basicScanByteCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX.

]

{ #category : #scanning }
CharacterScanner >> scanCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX [ 
	^sourceString scanCharactersFrom: startIndex to: stopIndex with: self rightX: rightX font: font
]

{ #category : #scanning }
CharacterScanner >> scanCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX stopConditions: stops kern: kernDelta [ 
	^sourceString scanCharactersFrom: startIndex to: stopIndex with: self rightX: rightX font: font
]

{ #category : #scanning }
CharacterScanner >> scanKernableByteCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX [ 
"this is a scanning method for
single byte characters in a ByteString
a font that does do character-pair kerning via widthAndKernedWidthOfLeft:right:into:"
	| ascii nextDestX char floatDestX widthAndKernedWidth nextCharOrNil atEndOfRun |
	lastIndex := startIndex.
	floatDestX := destX.
	widthAndKernedWidth := Array new: 2.
	atEndOfRun := false.
	[lastIndex <= stopIndex]
		whileTrue: [
			"get the character value"
			char := sourceString at: lastIndex.
			ascii := char asciiValue + 1.
			"if there is an entry in 'stops' for this value, return it"
			(stopConditions at: ascii)
				ifNotNil: [^ stopConditions at: ascii].
			"get the next character..."
			nextCharOrNil := lastIndex + 1 <= stopIndex
						ifTrue: [sourceString at: lastIndex + 1]
						ifFalse: ["if we're at or past the stopIndex, see if there is anything in the full string"
							atEndOfRun := true.
							lastIndex + 1 <= sourceString size
								ifTrue: [sourceString at: lastIndex + 1]].
			"get the font's kerning info for the pair of current character and next character"
			"for almost all fonts in common use this is a waste of time since they don't support pair kerning and both values are #widthOf: char"
			font
				widthAndKernedWidthOfLeft: char
				right: nextCharOrNil
				into: widthAndKernedWidth.
			"bump nextDestX by the width of the current character"
			nextDestX := floatDestX
						+ (widthAndKernedWidth at: 1).
			"if the next x is past the right edge, return crossedX"
			nextDestX > rightX
				ifTrue: [^ #crossedX].
			"bump floatDestX by the *kerned* width of the current
			character, which is where the *next* char will go"
			floatDestX := floatDestX + kern
						+ (widthAndKernedWidth at: 2).
			"if we are at the end of this run we keep track of the
			character-kern-delta for possible later use and then rather
			insanely remove that character-kern-delta from floatDestX,
			making it equivalent to (old floatDestX) + kernDelta +
			width-of-character - no idea why"
			atEndOfRun
				ifTrue: [pendingKernX := (widthAndKernedWidth at: 2)
								- (widthAndKernedWidth at: 1).
					floatDestX := floatDestX - pendingKernX].
			"save the next x for next time around the loop"
			destX := floatDestX.
			lastIndex := lastIndex + 1].
	^self handleEndOfRunAt: stopIndex

]

{ #category : #scanning }
CharacterScanner >> scanKernableMultibyteCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX [ 
"this is a scanning method for
multibyte characters in a WideString
a font that does do character-pair kerning via widthAndKernedWidthOfLeft:right:into:"

	| ascii nextDestX floatDestX widthAndKernedWidth nextChar atEndOfRun char |
	lastIndex := startIndex.
	lastIndex > stopIndex ifTrue: [^self handleEndOfRunAt: stopIndex].
	floatDestX := destX.
	widthAndKernedWidth := Array new: 2.
	atEndOfRun := false.
	[lastIndex <= stopIndex] whileTrue: [
		char := sourceString at: lastIndex.
		ascii := char charCode.
		(ascii < 256 and: [(stopConditions at: ascii + 1) ~~ nil])
			ifTrue: [^ stopConditions at: ascii + 1].
		nextChar := (lastIndex + 1 <= stopIndex) 
			ifTrue:[sourceString at: lastIndex + 1]
			ifFalse:[
				atEndOfRun := true.
				"if there is a next char in sourceString, then get the kern 
				and store it in pendingKernX"
				lastIndex + 1 <= sourceString size
					ifTrue:[sourceString at: lastIndex + 1]
					ifFalse:[	nil]].
		font 
			widthAndKernedWidthOfLeft: char 
			right: nextChar
			into: widthAndKernedWidth.
		nextDestX := floatDestX + (widthAndKernedWidth at: 1).
		nextDestX > rightX ifTrue: [^#crossedX].
		floatDestX := floatDestX + kern + (widthAndKernedWidth at: 2).
		atEndOfRun 
			ifTrue:[
				pendingKernX := (widthAndKernedWidth at: 2) - (widthAndKernedWidth at: 1).
				floatDestX := floatDestX - pendingKernX].
		destX := floatDestX .
		lastIndex := lastIndex + 1.
	].
	^self handleEndOfRunAt: stopIndex
]

{ #category : #scanning }
CharacterScanner >> scanMultibyteCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX [ 
"this is a scanning method for
multibyte characters in a WideString
a font that does not do character-pair kerning"
	| char ascii nextDestX |
	lastIndex := startIndex.
	[lastIndex <= stopIndex] whileTrue: [
		char := sourceString at: lastIndex.
		ascii := char charCode.
		(ascii < 256 and: [(stopConditions at: ascii + 1) ~~ nil])
			ifTrue: [^ stopConditions at: ascii + 1].
		"bump nextDestX by the width of the current character"
		nextDestX := destX + (font widthOf: char).
		nextDestX > rightX ifTrue: [^#crossedX].
		destX := nextDestX + kern .
		lastIndex := lastIndex + 1.
	].
	^self handleEndOfRunAt: stopIndex
]

{ #category : #'text attributes' }
CharacterScanner >> setActualFont: aFont [
	"Set the basal font to an isolated font reference."

	xTable := aFont xTable.
	map := aFont characterToGlyphMap.
	font := aFont.
]

{ #category : #'text attributes' }
CharacterScanner >> setAlignment: style [
	alignment := style.
	
]

{ #category : #private }
CharacterScanner >> setFont [
	| priorFont |
	"Set the font and other emphasis."
	priorFont := font.
	text ifNotNil:[
		emphasisCode := 0.
		kern := 0.
		indentationLevel := 0.
		alignment := textStyle alignment.
		font := nil.
		(text attributesAt: lastIndex forStyle: textStyle)
			do: [:att | att emphasizeScanner: self]].
	font ifNil: [self setFont: textStyle defaultFontIndex].
	self setActualFont: (font emphasized: emphasisCode).
	priorFont 
		ifNotNil: [
			font = priorFont 
				ifTrue:[
					"font is the same, perhaps the color has changed?
					We still want kerning between chars of the same
					font, but of different color. So add any pending kern to destX"
					destX := destX + (pendingKernX ifNil:[0])].
			destX := destX + priorFont descentKern].
	pendingKernX := 0. "clear any pending kern so there is no danger of it being added twice"
	destX := destX - font descentKern.
	"NOTE: next statement should be removed when clipping works"
	leftMargin ifNotNil: [destX := destX max: leftMargin].
	kern := kern - font baseKern.

	"Install various parameters from the font."
	spaceWidth := font widthOf: Space.
]

{ #category : #'text attributes' }
CharacterScanner >> setFont: fontNumber [
	"Set the font by number from the textStyle."

	self setActualFont: (textStyle fontAt: fontNumber)
]

{ #category : #private }
CharacterScanner >> setStopConditions [
	"Set the font and the stop conditions for the current run."
	
	self setFont.
	stopConditions := alignment = Justified
		ifTrue: [PaddedSpaceCondition]
		ifFalse: [DefaultStopConditions]
]

{ #category : #private }
CharacterScanner >> text: t textStyle: ts [
	text := t.
	textStyle := ts
]

{ #category : #'text attributes' }
CharacterScanner >> textColor: ignored [
	"Overridden in DisplayScanner"
]
