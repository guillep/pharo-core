"
A CompositionScanner measures text and determines where line breaks.
Given a rectangular zone on input, it is used to split text in horizontal lines, and produce information about those lines on output (at which index a line starts/stops, which vertical space does the line require, which horizontal space if left for adjusting inter-word spacing, etc...)

Instance Variables
	baseline:		<Number>
	baselineAtSpace:		<Number>
	lastBreakIsNotASpace:		<Boolean>
	lineHeight:		<Number>
	lineHeightAtSpace:		<Number>
	nextIndexAfterLineBreak:		<Integer>
	spaceIndex:		<Integer>
	spaceX:		<Number>

baseline
	- the distance between top of line and the base line (that is the bottom of latin characters abcdehiklmnorstuvwx in most fonts)

baselineAtSpace
	- memorize the baseline at last encountered space or other breakable character.
	This is necessary because the CompositionScanner wants to break line at a breakable character.
	If a word layout overflows the right margin, the scanner has to roll back and restore the line state to last encountered breakable character.

lastBreakIsNotASpace
	- indicates that the last breakable character was not a space.
	This is necessary because handling a line break at a space differs from non space.
	If line break occurs on space, the space won't be displayed in next line.
	If it's another breakable character, it has to be displayed on next line.

lineHeight
	- the total line height from top to bottom, including inter-line spacing.

lineHeightAtSpace
	- the line height at last encountered space or other breakable character.
	See baselineAtSpace for explanation.

nextIndexAfterLineBreak
	- the index of character after the last line break that was encountered.

spaceIndex
	- the index of last space or other breakable character that was encountered

spaceX
	- the distance from left of composition zone to left of last encountered space or other breakable character 
	See baselineAtSpace for explanation.

Note: if a line breaks on a space, a linefeed or a carriage return, then the space, linefeed or carriage return is integrated in the line.
If there is a carriage return - linefeed pair, the pair is integrated to the line as if it were a single line break for compatibility with legacy software.
"
Class {
	#name : #CompositionScanner,
	#superclass : #CharacterScanner,
	#instVars : [
		'spaceX',
		'spaceIndex',
		'lineHeight',
		'baseline',
		'lineHeightAtSpace',
		'baselineAtSpace',
		'lastBreakIsNotASpace',
		'nextIndexAfterLineBreak',
		'wantsColumnBreaks'
	],
	#category : #'Text-Scanning'
}

{ #category : #testing }
CompositionScanner >> canComputeDefaultLineHeight [
	^ rightMargin notNil
]

{ #category : #'stop conditions' }
CompositionScanner >> columnBreak [

	"Answer true. Set up values for the text line interval currently being 
	composed."

	pendingKernX := 0.
	line stop: lastIndex.
	spaceX := destX.
	lastBreakIsNotASpace := false.
	line paddingWidth: rightMargin - spaceX.
	^true
]

{ #category : #scanning }
CompositionScanner >> composeFrom: startIndex inRectangle: lineRectangle
	firstLine: firstLine leftSide: leftSide rightSide: rightSide [
	"Answer an instance of TextLineInterval that represents the next line in the paragraph."
	| runLength stopCondition |
	"Set up margins"
	leftMargin := lineRectangle left.
	leftSide ifTrue: [leftMargin := leftMargin +
						(firstLine ifTrue: [textStyle firstIndent]
								ifFalse: [textStyle restIndent])].
	destX := spaceX := leftMargin.
	rightMargin := lineRectangle right.
	rightSide ifTrue: [rightMargin := rightMargin - textStyle rightIndent].
	lastIndex := startIndex.	"scanning sets last index"
	destY := lineRectangle top.
	lineHeight := baseline := 0.  "Will be increased by setFont"
	line := (TextLine start: lastIndex stop: 0 internalSpaces: 0 paddingWidth: 0)
				rectangle: lineRectangle.
	self setStopConditions.	"also sets font"
	runLength := text runLengthFor: startIndex.
	runStopIndex := (lastIndex := startIndex) + (runLength - 1).
	nextIndexAfterLineBreak := spaceCount := 0.
	lastBreakIsNotASpace := false.
	self handleIndentation.
	leftMargin := destX.
	line leftMargin: leftMargin.

	[stopCondition := self scanCharactersFrom: lastIndex to: runStopIndex
		in: text string rightX: rightMargin.
	"See setStopConditions for stopping conditions for composing."
	self perform: stopCondition] whileFalse.

	^ line
		lineHeight: lineHeight + textStyle leading
		baseline: baseline + textStyle leading
]

{ #category : #scanning }
CompositionScanner >> computeDefaultLineHeight [
	"Compute the default line height for a potentially empty text"

	^ rightMargin notNil
		ifTrue: [ lastIndex := 1.
			self setFont.
			lineHeight + textStyle leading ]
		ifFalse: [ textStyle lineGrid ]
]

{ #category : #'stop conditions' }
CompositionScanner >> cr [
	"Answer true. Set up values for the text line interval currently being 
	composed."

	pendingKernX := 0.
	(lastIndex < text size and: [(text at: lastIndex) = CR and: [(text at: lastIndex+1) = Character lf]]) ifTrue: [lastIndex := lastIndex + 1].
	line stop: lastIndex.
	nextIndexAfterLineBreak := lastIndex + 1.
	spaceX := destX.
	lastBreakIsNotASpace := false.
	line paddingWidth: rightMargin - spaceX.
	^true
]

{ #category : #'stop conditions' }
CompositionScanner >> crossedX [
	"There is a word that has fallen across the right edge of the composition 
	rectangle. This signals the need for wrapping which is done to the last 
	space that was encountered, as recorded by the space stop condition,
	or any other breakable character if the language permits so."

	pendingKernX := 0.
	
	lastBreakIsNotASpace ifTrue:
		["In some languages line break is possible before a non space."
		^self wrapAtLastBreakable].
	 
	spaceCount >= 1 ifTrue:
		["The common case. there is a space on the line."
		^self wrapAtLastSpace].
	
	"Neither internal nor trailing spaces -- almost never happens."
	self advanceIfFirstCharOfLine.
	^self wrapHere
]

{ #category : #accessing }
CompositionScanner >> doesTheLineBreaksAfterLastChar [
	^nextIndexAfterLineBreak > text size
]

{ #category : #'stop conditions' }
CompositionScanner >> endOfRun [
	"Answer true if scanning has reached the end of the paragraph. 
	Otherwise step conditions (mostly install potential new font) and answer 
	false."

	| runLength |
	^ lastIndex = text size
		ifTrue: [ line stop: lastIndex.
			spaceX := destX.
			line paddingWidth: rightMargin - destX.
			true ]
		ifFalse: [ runLength := text runLengthFor: (lastIndex := lastIndex + 1).
			runStopIndex := lastIndex + (runLength - 1).
			self setStopConditions.
			false ]
]

{ #category : #initialization }
CompositionScanner >> initialize [
	wantsColumnBreaks := false.
	super initialize
]

{ #category : #private }
CompositionScanner >> placeEmbeddedObject: anchoredMorph [
	| w descent |
	"Workaround: The following should really use #textAnchorType"
	anchoredMorph relativeTextAnchorPosition ifNotNil:[^true].
	w := anchoredMorph width.
	(destX + w > rightMargin and: [(leftMargin + w) <= rightMargin or: [lastIndex > line first]])
		ifTrue: ["Won't fit, but would on next line"
				^ false].
	destX := destX + w + kern.
	descent := lineHeight - baseline.
	baseline := baseline max: anchoredMorph height.
	lineHeight := baseline + descent.
	^ true
]

{ #category : #accessing }
CompositionScanner >> rightX [
	"Meaningful only when a line has just been composed -- refers to the 
	line most recently composed. This is a subtrefuge to allow for easy 
	resizing of a composition rectangle to the width of the maximum line. 
	Useful only when there is only one line in the form or when each line 
	is terminated by a carriage return. Handy for sizing menus and lists."

	^spaceX
]

{ #category : #'text attributes' }
CompositionScanner >> setActualFont: aFont [

	"Keep track of max height and ascent for auto lineheight"

	| descent |

	super setActualFont: aFont.
	lineHeight
		ifNil: [ descent := font descent.
			baseline := font ascent.
			lineHeight := baseline + descent
			]
		ifNotNil: [ descent := lineHeight - baseline max: font descent.
			baseline := baseline max: font ascent.
			lineHeight := lineHeight max: baseline + descent
			]
]

{ #category : #private }
CompositionScanner >> setStopConditions [
	"Set the font and the stop conditions for the current run."
	
	self setFont.
	stopConditions := wantsColumnBreaks == true
		ifTrue: [ColumnBreakStopConditions]
		ifFalse: [CompositionStopConditions]
]

{ #category : #'stop conditions' }
CompositionScanner >> space [
	"Record left x and character index of the space character just encountered. 
	Used for wrap-around. Answer whether the character has crossed the 
	right edge of the composition rectangle of the paragraph."

	spaceX := destX.
	spaceIndex := lastIndex.
	lineHeightAtSpace := lineHeight.
	baselineAtSpace := baseline.
	spaceCount := spaceCount + 1.
	lastBreakIsNotASpace := false.
	destX + spaceWidth > rightMargin ifTrue:[^self crossedX].
	destX := spaceX + spaceWidth + kern.
	lastIndex := lastIndex + 1.
	^false

]

{ #category : #'stop conditions' }
CompositionScanner >> tab [
	"Advance destination x according to tab settings in the paragraph's 
	textStyle. Answer whether the character has crossed the right edge of 
	the composition rectangle of the paragraph."

	pendingKernX := 0.
	destX := textStyle
				nextTabXFrom: destX leftMargin: leftMargin rightMargin: rightMargin.
	destX > rightMargin ifTrue:	[^self crossedX].
	lastIndex := lastIndex + 1.
	^false

]

{ #category : #initialize }
CompositionScanner >> wantsColumnBreaks: aBoolean [

	wantsColumnBreaks := aBoolean
]

{ #category : #'stop conditions' }
CompositionScanner >> wrapAtLastBreakable [
	"Wrap the line before last encountered breakable character."
	pendingKernX := 0.
	nextIndexAfterLineBreak := spaceIndex.
	line stop: spaceIndex - 1.
	lineHeight := lineHeightAtSpace.
	baseline := baselineAtSpace.
	line paddingWidth: rightMargin - spaceX.
	line internalSpaces: spaceCount.
	^true
]

{ #category : #'stop conditions' }
CompositionScanner >> wrapAtLastSpace [
	"Wrap the line before last encountered space"
	
	pendingKernX := 0.
	nextIndexAfterLineBreak := spaceIndex + 1.
	alignment = Justified ifTrue: [
		"gobble all subsequent spaces"
		[nextIndexAfterLineBreak <= text size and: [(text at: nextIndexAfterLineBreak) == Space]]
			whileTrue: [nextIndexAfterLineBreak := nextIndexAfterLineBreak + 1]].
	
	line stop: nextIndexAfterLineBreak - 1.
	lineHeight := lineHeightAtSpace.
	baseline := baselineAtSpace.

	["remove the space at which we break..."
	spaceCount := spaceCount - 1.
	spaceIndex := spaceIndex - 1.

	"...and every other spaces preceding the one at which we wrap.
		Double space after punctuation, most likely."
	spaceCount >= 1 and: [(text at: spaceIndex) = Space]]
		whileTrue:
			["Account for backing over a run which might
				change width of space."
			font := text fontAt: spaceIndex withStyle: textStyle.
			spaceX := spaceX - (font widthOf: Space)].
	line paddingWidth: rightMargin - spaceX.
	line internalSpaces: spaceCount.
	^true
]

{ #category : #'stop conditions' }
CompositionScanner >> wrapHere [
	"Wrap the line before current character."
	pendingKernX := 0.
	nextIndexAfterLineBreak := lastIndex.
	lastIndex := lastIndex - 1.
	spaceX := destX.
	line paddingWidth: rightMargin - destX.
	line stop: (lastIndex max: line first).
	^true
]
