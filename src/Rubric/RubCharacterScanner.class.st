"
I scan characters
"
Class {
	#name : #RubCharacterScanner,
	#superclass : #Object,
	#instVars : [
		'destX',
		'lastIndex',
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
		'baselineY',
		'firstDestX',
		'pendingKernX'
	],
	#classVars : [
		'DefaultStopConditions',
		'NilCondition',
		'PaddedSpaceCondition',
		'SpaceCondition'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'Rubric-TextScanning'
}

{ #category : #'class initialization' }
RubCharacterScanner class >> initialize [
"
	RubCharacterScanner initialize
"
	| a |
	a := RubTextStopConditions new.
	a at: 1 + 1 put: #embeddedObject.
	a at: Character tab asciiValue + 1 put: #tab.
	a at: Character cr asciiValue + 1 put: #cr.
	a at: Character lf asciiValue + 1 put: #cr.
	
	NilCondition := a copy.
	DefaultStopConditions := a copy.

	PaddedSpaceCondition := a copy.
	PaddedSpaceCondition at: Character space asciiValue + 1 put: #paddedSpace.
	
	SpaceCondition := a copy.
	SpaceCondition at: Character space asciiValue + 1 put: #space.

]

{ #category : #private }
RubCharacterScanner >> addEmphasis: code [
	"Set the bold-ital-under-strike emphasis."
	emphasisCode := emphasisCode bitOr: code
]

{ #category : #private }
RubCharacterScanner >> addKern: kernDelta [
	"Set the current kern amount."
	kern := kern + kernDelta
]

{ #category : #private }
RubCharacterScanner >> backgroundColor: ignored [
	"Overridden in DisplayScanner"
]

{ #category : #scanning }
RubCharacterScanner >> basicScanCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX stopConditions: stops kern: kernDelta [
	"Primitive. This is the inner loop of text display--but see 
	scanCharactersFrom: to:rightX: which would get the string, 
	stopConditions and displaying from the instance. March through source 
	String from startIndex to stopIndex. If any character is flagged with a 
	non-nil entry in stops, then return the corresponding value. Determine 
	width of each character from xTable, indexed by map. 
	If dextX would exceed rightX, then return stops at: 258. 
	Advance destX by the width of the character. If stopIndex has been
	reached, then return stops at: 257. Optional. 
	See Object documentation whatIsAPrimitive."
	| ascii nextDestX char floatDestX widthAndKernedWidth nextChar atEndOfRun |
	<primitive: 103>
	lastIndex := startIndex.
	floatDestX := destX.
	widthAndKernedWidth := Array new: 2.
	atEndOfRun := false.
	[lastIndex <= stopIndex]
		whileTrue: [
			char := (sourceString at: lastIndex).
			ascii := char asciiValue.
			
			(ascii < stops size and: [(stops at: ascii + 1) notNil]) ifTrue: [^ stops at: ascii + 1].
			"Note: The following is querying the font about the width
			since the primitive may have failed due to a non-trivial
			mapping of characters to glyphs or a non-existing xTable."
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
			"note crossing of right component side, unless we would end up on the first position
			again (endless loop, if line is to narrow to hold this current character)"
			nextDestX > rightX ifTrue: [firstDestX ~= destX ifTrue:[ ^stops crossedX]].			
			floatDestX := floatDestX + kernDelta + (widthAndKernedWidth at: 2).
			atEndOfRun 
				ifTrue:[
					pendingKernX := (widthAndKernedWidth at: 2) - (widthAndKernedWidth at: 1).
					floatDestX := floatDestX - pendingKernX].
			destX := floatDestX.
			lastIndex := lastIndex + 1].
	lastIndex := stopIndex.
	^ stops endOfRun
]

{ #category : #'scanner methods' }
RubCharacterScanner >> combinableChar: char for: prevEntity [


]

{ #category : #scanning }
RubCharacterScanner >> embeddedObject [
	| savedIndex |
	savedIndex := lastIndex.
	text
		attributesAt: lastIndex
		do: [ :attr | 
			attr anchoredMorph
				ifNotNil: [ 
					"Following may look strange but logic gets reversed.
			If the morph fits on this line we're not done (return false for true) 
			and if the morph won't fit we're done (return true for false)"
					(self placeEmbeddedObject: attr anchoredMorph)
						ifFalse: [ ^ true ] ] ].
	lastIndex := savedIndex + 1.	"for multiple(!) embedded morphs"
	^ false
]

{ #category : #scanning }
RubCharacterScanner >> handleIndentation [
	self indentationLevel timesRepeat: [
		self plainTab]
]

{ #category : #scanning }
RubCharacterScanner >> indentationLevel [
	"return the number of tabs that are currently being placed at the beginning of each line"
	^indentationLevel ifNil:[0]
]

{ #category : #scanning }
RubCharacterScanner >> indentationLevel: anInteger [
	"set the number of tabs to put at the beginning of each line"
	indentationLevel := anInteger
]

{ #category : #initialization }
RubCharacterScanner >> initialize [
	super initialize.
	destX := destY := leftMargin := 0.
]

{ #category : #'scanner methods' }
RubCharacterScanner >> isBreakableAt: index in: sourceString in: encodingClass [

	^ encodingClass isBreakableAt: index in: sourceString.

]

{ #category : #'text constants' }
RubCharacterScanner >> justified [
	^ 3
]

{ #category : #scanning }
RubCharacterScanner >> leadingTab [
	"return true if only tabs lie to the left"
	line first to: lastIndex do:
		[:i | (text at: i) == Character tab ifFalse: [^ false]].
	^ true
]

{ #category : #scanning }
RubCharacterScanner >> measureString: aString inFont: aFont from: startIndex to: stopIndex [
	"WARNING: In order to use this method the receiver has to be set up using #initializeStringMeasurer"
	destX := destY := lastIndex := 0.
	baselineY := aFont ascent.
	font := aFont.  " added Dec 03, 2004 "
"	map := aFont characterToGlyphMap."
	self scanCharactersFrom: startIndex to: stopIndex in: aString rightX: 999999 stopConditions: stopConditions kern: 0.
	^destX
]

{ #category : #scanning }
RubCharacterScanner >> nextTabXFrom: anX [
	"Tab stops are distances from the left margin. Set the distance into the 
	argument, anX, normalized for the paragraph's left margin."

	| normalizedX tabX mx |
	mx := 9999.
	normalizedX := anX - leftMargin.
	tabX := self tabWidth.
	[ tabX <= normalizedX and: [ tabX < mx ] ] whileTrue: [ tabX := tabX + self tabWidth ].
	^ tabX < mx
		ifTrue: [ leftMargin + tabX min: rightMargin ]
		ifFalse: [ rightMargin ] 
]

{ #category : #scanning }
RubCharacterScanner >> placeEmbeddedObject: anchoredMorph [
	"Place the anchoredMorph or return false if it cannot be placed.
	In any event, advance destX by its width."
	| w |
	"Workaround: The following should really use #textAnchorType"
	anchoredMorph relativeTextAnchorPosition ifNotNil:[^true].
	destX := destX + (w := anchoredMorph width).
	(destX > rightMargin and: [(leftMargin + w) <= rightMargin])
		ifTrue: ["Won't fit, but would on next line"
				^ false].
	lastIndex := lastIndex + 1.
	
	^ true
]

{ #category : #scanning }
RubCharacterScanner >> plainTab [

	"This is the basic method of adjusting destX for a tab."
	destX := (alignment = self justified and: [self leadingTab not])
		ifTrue:		"embedded tabs in justified text are weird"
			[destX + (self tabWidth - (line justifiedTabDeltaFor: spaceCount)) max: destX]
		ifFalse: 
			[self nextTabXFrom: destX].
	pendingKernX := 0.
	firstDestX  := destX.
]

{ #category : #scanning }
RubCharacterScanner >> scanCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX stopConditions: stops kern: kernDelta [

	sourceString isByteString
		ifTrue: [ ^ self 
					basicScanCharactersFrom: startIndex 
					to: stopIndex 
					in: sourceString 
					rightX: rightX 
					stopConditions: stops 
					kern: kernDelta ].

	sourceString isWideString ifFalse: [ ^ stops endOfRun ].
		
	startIndex > stopIndex 
		ifTrue: [ 
			lastIndex := stopIndex.
			^ stops endOfRun ].

	^ self
		scanMultiCharactersFrom: startIndex
		to: stopIndex
		in: sourceString
		rightX: rightX
		stopConditions: stops
		kern: kernDelta.

	

]

{ #category : #scanning }
RubCharacterScanner >> scanMultiCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX stopConditions: stops kern: kernDelta [

	| ascii f nextDestX maxAscii floatDestX widthAndKernedWidth nextChar atEndOfRun |
	lastIndex := startIndex.
	lastIndex > stopIndex ifTrue: [lastIndex := stopIndex. ^ stops endOfRun].
	font ifNil: [font := TextStyle defaultFont fontArray at: 1].
	font isFontSet ifTrue: [
		f := [font fontArray at: 1]
			on: Exception do: [:ex | nil].
		f ifNil: [ f := font fontArray at: 1].
		maxAscii := f maxAscii.
		spaceWidth := f widthOf: Character space.
	] ifFalse: [
		maxAscii := font maxAscii.
	].
	floatDestX := destX.
	widthAndKernedWidth := Array new: 2.
	atEndOfRun := false.
	[lastIndex <= stopIndex] whileTrue: [
		ascii := (sourceString at: lastIndex) charCode.
		ascii > maxAscii ifTrue: [ascii := maxAscii].
		(ascii < stops size and: [(stops at: ascii + 1) ~~ nil])
			ifTrue: [^ stops at: ascii + 1].
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
			widthAndKernedWidthOfLeft: (sourceString at: lastIndex) 
			right: nextChar
			into: widthAndKernedWidth.
		nextDestX := floatDestX + (widthAndKernedWidth at: 1).
		nextDestX > rightX ifTrue: [destX ~= firstDestX ifTrue: [^stops crossedX]].
		floatDestX := floatDestX + kernDelta + (widthAndKernedWidth at: 2).
		atEndOfRun 
			ifTrue:[
				pendingKernX := (widthAndKernedWidth at: 2) - (widthAndKernedWidth at: 1).
				floatDestX := floatDestX - pendingKernX].
		destX := floatDestX .
		lastIndex := lastIndex + 1.
	].
	lastIndex := stopIndex.
	^ stops endOfRun
]

{ #category : #private }
RubCharacterScanner >> setActualFont: aFont [
	"Set the basal font to an isolated font reference."

	font := aFont
]

{ #category : #private }
RubCharacterScanner >> setAlignment: style [
	alignment := style.
	
]

{ #category : #private }
RubCharacterScanner >> setConditionArray: aSymbol [

	aSymbol == #paddedSpace ifTrue: [^stopConditions := PaddedSpaceCondition "copy"].
	"aSymbol == #space ifTrue: [^stopConditions := SpaceCondition copy]."
	aSymbol == nil ifTrue: [^stopConditions := NilCondition "copy"].
	self error: 'undefined stopcondition for space character'.

]

{ #category : #private }
RubCharacterScanner >> setFont [
	| priorFont |
	"Set the font and other emphasis."
	priorFont := font.
	text == nil
		ifFalse: [ 
			emphasisCode := 0.
			kern := 0.
			indentationLevel := 0.
			alignment := textStyle alignment.
			font := nil.
			(text attributesAt: lastIndex forStyle: textStyle) do: [ :att | att emphasizeScanner: self ] ].
	font == nil
		ifTrue: [ self setFont: textStyle defaultFontIndex ].
	font := font emphasized: emphasisCode.
	priorFont
		ifNotNil: [ 
			font = priorFont
				ifTrue: [ 
					"font is the same, perhaps the color has changed?
					We still want kerning between chars of the same
					font, but of different color. So add any pending kern to destX"
					destX := destX + (pendingKernX ifNil: [ 0 ]) ].
			destX := destX + priorFont descentKern ].
	pendingKernX := 0.	"clear any pending kern so there is no danger of it being added twice"
	destX := destX - font descentKern.	"NOTE: next statement should be removed when clipping works"
	leftMargin ifNotNil: [ destX := destX max: leftMargin ].
	kern := kern - font baseKern.	"Install various parameters from the font."
	spaceWidth := font widthOf: Character space.	"	map := font characterToGlyphMap."
	stopConditions := DefaultStopConditions
]

{ #category : #private }
RubCharacterScanner >> setFont: fontNumber [
	"Set the font by number from the textStyle."

	self setActualFont: (textStyle fontAt: fontNumber)
]

{ #category : #accessing }
RubCharacterScanner >> tabWidth [
	^ textStyle rubTabWidth
]

{ #category : #private }
RubCharacterScanner >> text: t textStyle: ts [ 
	text := t.
	textStyle := ts
]

{ #category : #private }
RubCharacterScanner >> textColor: ignored [
	"Overridden in DisplayScanner"
]

{ #category : #'multilingual scanning' }
RubCharacterScanner >> widthOf: char inFont: aFont [

	^ aFont widthOf: char
]
