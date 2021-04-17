Extension { #name : #AbstractFont }

{ #category : #'*Deprecated90' }
AbstractFont >> scanMultibyteJapaneseCharactersFrom: startIndex to: stopIndex in: aWideString with: aCharacterScanner rightX: rightX [
	"scan a multibyte Japanese character string"
	self deprecated: 'Deprecated similar to JapaneseEnvironment in Pharo 9'.
	^aCharacterScanner scanJapaneseCharactersFrom: startIndex to: stopIndex in: aWideString rightX: rightX 

]
