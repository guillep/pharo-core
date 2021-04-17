"
I scan a paragraph
"
Class {
	#name : #RubCompositionScanner,
	#superclass : #RubCharacterScanner,
	#instVars : [
		'spaceX',
		'lineHeight',
		'baseline',
		'breakableIndex',
		'lineHeightAtBreak',
		'baselineAtBreak',
		'breakAtSpace'
	],
	#category : #'Rubric-TextScanning'
}

{ #category : #scanning }
RubCompositionScanner >> composeFrom: startIndex inRectangle: lineRectangle firstLine: firstLine leftSide: leftSide rightSide: rightSide [
	"Answer an instance of TextLineInterval that represents the next line in the paragraph."
	| runLength stopCondition |
	"Set up margins"
	leftMargin := lineRectangle left.
	leftSide ifTrue: [leftMargin := leftMargin +
						(firstLine ifTrue: [textStyle firstIndent]
								ifFalse: [textStyle restIndent])].
	destX := spaceX := leftMargin.
	firstDestX := destX.
	rightMargin := lineRectangle right.
	rightSide ifTrue: [rightMargin := rightMargin - textStyle rightIndent].
	lastIndex := startIndex.	"scanning sets last index"
	destY := lineRectangle top.
	lineHeight := baseline := 0.  "Will be increased by setFont"
	self setStopConditions.	"also sets font"
	runLength := text runLengthFor: startIndex.
	runStopIndex := (lastIndex := startIndex) + (runLength - 1).
	line := (RubTextLine start: lastIndex stop: 0 internalSpaces: 0 paddingWidth: 0)
				rectangle: lineRectangle.
	spaceCount := 0.
	self handleIndentation.
	leftMargin := destX.
	line leftMargin: leftMargin.

	[false]
		whileFalse: 
			[stopCondition := self scanCharactersFrom: lastIndex to: runStopIndex
				in: text string rightX: rightMargin stopConditions: stopConditions
				kern: kern.
			"See setStopConditions for stopping conditions for composing."
			line stopCondition: stopCondition.
			(self perform: stopCondition)
				ifTrue: [^ line lineHeight: lineHeight + textStyle leading baseline: baseline + textStyle leading]]
]

{ #category : #'stop conditions' }
RubCompositionScanner >> cr [
	"Answer true. Set up values for the text line interval currently being 
	composed."

	pendingKernX := 0.
	(lastIndex < text size and: [(text at: lastIndex) = Character cr  and: [(text at: lastIndex+1) = Character lf]]) ifTrue: [lastIndex := lastIndex + 1].
	line stop: lastIndex.
	spaceX := destX.
	line paddingWidth: rightMargin - spaceX.
	^true
]

{ #category : #'stop conditions' }
RubCompositionScanner >> crossedX [
	"There is a word that has fallen across the right edge of the composition 
	rectangle. This signals the need for wrapping which is done to the last 
	space that was encountered, as recorded by the space stop condition."

	pendingKernX := 0.
	breakAtSpace ifTrue: [
		spaceCount >= 1 ifTrue:
			["The common case. First back off to the space at which we wrap."
			line stop: breakableIndex.
			lineHeight := lineHeightAtBreak.
			baseline := baselineAtBreak.
			spaceCount := spaceCount - 1.
			breakableIndex := breakableIndex - 1.

			"Check to see if any spaces preceding the one at which we wrap.
				Double space after punctuation, most likely."
			[(spaceCount > 1 and: [(text at: breakableIndex) = Character space])]
				whileTrue:
					[spaceCount := spaceCount - 1.
					"Account for backing over a run which might
						change width of space."
					font := text fontAt: breakableIndex withStyle: textStyle.
					breakableIndex := breakableIndex - 1.
					spaceX := spaceX - (font widthOf: Character space)].
			line paddingWidth: rightMargin - spaceX.
			line internalSpaces: spaceCount]
		ifFalse:
			["Neither internal nor trailing spaces -- almost never happens."
			lastIndex := lastIndex - 1.
			[destX <= rightMargin]
				whileFalse:
					[destX := destX - (font widthOf: (text at: lastIndex)).
					lastIndex := lastIndex - 1].
			spaceX := destX.
			line paddingWidth: rightMargin - destX.
			line stop: (lastIndex max: line first)].
		^true
	].

	(breakableIndex isNil or: [breakableIndex < line first]) ifTrue: [
		"Any breakable point in this line.  Just wrap last character."
		breakableIndex := lastIndex - 1.
		lineHeightAtBreak := lineHeight.
		baselineAtBreak := baseline.
	].

	"It wasn't a space, but anyway this is where we break the line."
	line stop: breakableIndex.
	lineHeight := lineHeightAtBreak.
	baseline := baselineAtBreak.
	^ true.

]

{ #category : #'stop conditions' }
RubCompositionScanner >> endOfRun [
	"Answer true if scanning has reached the end of the paragraph. 
	Otherwise step conditions (mostly install potential new font) and answer 
	false."

	| runLength |
	^ lastIndex = text size
		ifTrue: [ line stop: lastIndex.
			spaceX := destX.
			line paddingWidth: rightMargin - destX.
			true ]
		ifFalse: [ "(text at: lastIndex) charCode = 32 ifTrue: [destX := destX + spaceWidth]."
			runLength := text runLengthFor: (lastIndex := lastIndex + 1).
			runStopIndex := lastIndex + (runLength - 1).
			self setStopConditions.
			false ]
]

{ #category : #'stop conditions' }
RubCompositionScanner >> placeEmbeddedObject: anchoredMorph [
	| descent |
	"Workaround: The following should really use #textAnchorType"
	anchoredMorph relativeTextAnchorPosition ifNotNil:[^true].
	(super placeEmbeddedObject: anchoredMorph) ifFalse: ["It doesn't fit"
		"But if it's the first character then leave it here"
		lastIndex < line first ifFalse:[
			line stop: lastIndex-1.
			^ false]].
	descent := lineHeight - baseline.
	lineHeight := lineHeight max: anchoredMorph height.
	baseline := lineHeight - descent.
	line stop: lastIndex.
	^ true
]

{ #category : #accessing }
RubCompositionScanner >> rightX [
	"Meaningful only when a line has just been composed -- refers to the 
	line most recently composed. This is a subtrefuge to allow for easy 
	resizing of a composition rectangle to the width of the maximum line. 
	Useful only when there is only one line in the form or when each line 
	is terminated by a carriage return. Handy for sizing menus and lists."

	breakAtSpace ifTrue: [^ spaceX].

	^ destX.

]

{ #category : #scanning }
RubCompositionScanner >> setActualFont: aFont [
	"Keep track of max height and ascent for auto lineheight"
	| descent |
	super setActualFont: aFont.
	"'   ', lastIndex printString, '   ' displayAt: (lastIndex * 15)@0."
	lineHeight == nil
		ifTrue: [descent := font descent.
				baseline := font ascent.
				lineHeight := baseline + descent]
		ifFalse: [descent := lineHeight - baseline max: font descent.
				baseline := baseline max: font ascent.
				lineHeight := lineHeight max: baseline + descent]
]

{ #category : #'stop conditions' }
RubCompositionScanner >> setFont [
	super setFont.
	breakAtSpace := false
]

{ #category : #'stop conditions' }
RubCompositionScanner >> setStopConditions [
	"Set the font and the stop conditions for the current run."
	
	self setFont
]

{ #category : #'stop conditions' }
RubCompositionScanner >> tab [
	"Advance destination x according to tab settings in the paragraph's 
	textStyle. Answer whether the character has crossed the right edge of 
	the composition rectangle of the paragraph."

	pendingKernX := 0.
	destX := self nextTabXFrom: destX.
	destX > rightMargin ifTrue:	[^self crossedX].
	lastIndex := lastIndex + 1.
	^false

]
