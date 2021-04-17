Extension { #name : #CharacterScanner }

{ #category : #'*Deprecated90' }
CharacterScanner >> isBreakableAt: index in: sourceString in: encodingClass [
"check with the encoding whether the character at index is a breakable character.
Only the JISX0208 & JapaneseEnvironments  ever return true, so only the scanJapaneseCharacters... method calls this"
	self deprecated: 'Deprecated similar to JapaneseEnvironment in Pharo 9'.
	^ encodingClass isBreakableAt: index in: sourceString.

]

{ #category : #'*Deprecated90' }
CharacterScanner >> scanJapaneseCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX [ 
"this is a scanning method for
multibyte Japanese characters in a WideString - hence the isBreakable:in:in:
a font that does not do character-pair kerning "

	| ascii encoding nextDestX char charset |
	self deprecated: 'Deprecated similar to JapaneseEnvironment in Pharo 9'.
	lastIndex := startIndex.
	lastIndex > stopIndex ifTrue: [^self handleEndOfRunAt: stopIndex].
	charset := EncodedCharSet charsetAt: 0.
	[lastIndex <= stopIndex] whileTrue: [
		char := sourceString at: lastIndex.
		ascii := char charCode.
		(encoding = 0 and: [ascii < 256 and:[(stopConditions at: ascii + 1) ~~ nil]]) 
			ifTrue: [^ stopConditions at: ascii + 1].
		(self isBreakableAt: lastIndex in: sourceString in: charset)
			ifTrue: [	self registerBreakableIndex].
		nextDestX := destX + (font widthOf: char).
		nextDestX > rightX
			ifTrue: [^#crossedX].
		destX := nextDestX + kern.
		lastIndex := lastIndex + 1.
	].
	^self handleEndOfRunAt: stopIndex
]
