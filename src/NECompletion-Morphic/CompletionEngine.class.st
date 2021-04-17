"
I live as an instance variable in a Browser, Debugger, Workspace or other window. I'm the glue between all participants of the completion system. I create the NECContext and pass myself to the NECMenuMorph. I process the keyboard events and pass them to the NECMenuMorph or close the morph if needed.

My method codeCompletionAround: aBlock textMorph: aTextMorph keyStroke: evt
is the starting point of the completion process.

I'm invoked before and after a keystroke. Check method handleKeystrokeBefore: evt editor: editor and handleKeystrokeAfter: evt editor: editor.

The completion occurs in specific character position. The editor is responsible for determining such positions: look at senders of ==atCompletionPosition==
"
Class {
	#name : #CompletionEngine,
	#superclass : #AbstractCompletionEngine,
	#instVars : [
		'contextClass',
		'menuMorph',
		'editor',
		'context',
		'inverseMapping',
		'completionDelay'
	],
	#classVars : [
		'ContextClass'
	],
	#category : #'NECompletion-Morphic'
}

{ #category : #accessing }
CompletionEngine class >> contextClass [
	^ContextClass ifNil: [ CompletionContext ] 
]

{ #category : #accessing }
CompletionEngine class >> contextClass: aClass [
	ContextClass := aClass
]

{ #category : #accessing }
CompletionEngine class >> isCompletionEnabled [
	^NECPreferences enabled
]

{ #category : #testing }
CompletionEngine >> captureNavigationKeys [
	^ NECPreferences captureNavigationKeys
]

{ #category : #'menu morph' }
CompletionEngine >> closeMenu [
	self stopCompletionDelay.
	menuMorph
		ifNotNil: [ menuMorph delete ].
	menuMorph := nil.
]

{ #category : #replacement }
CompletionEngine >> completionToken [

	"Return the word just before the caret"
	^ (self editor text copyFrom: self completionTokenStart to: self editor caret - 1) asString
]

{ #category : #replacement }
CompletionEngine >> completionTokenStart [
	"This is the position in the editor where the completion token starts"
	^ self editor previousWord: self editor caret - 1
]

{ #category : #accessing }
CompletionEngine >> context [
	^context
]

{ #category : #private }
CompletionEngine >> contextClass [
	
	^ contextClass ifNil: [ self class contextClass ]
]

{ #category : #accessing }
CompletionEngine >> contextClass: aClass [ 
	contextClass := aClass
]

{ #category : #'menu morph' }
CompletionEngine >> createContext [
	
	| class |
	class := editor model ifNotNil: [ :model | model selectedClassOrMetaClass ].
	^ self contextClass
		engine: self
		class: class
		source: editor text string
		position: editor caret - 1
]

{ #category : #accessing }
CompletionEngine >> editor [
	^ editor
]

{ #category : #keyboard }
CompletionEngine >> handleKeyDownAfter: aKeyboardEvent editor: aParagraphEditor [

	^ self updateCompletionAfterEdition: aParagraphEditor
]

{ #category : #keyboard }
CompletionEngine >> handleKeyDownBefore: aKeyboardEvent editor: anEditor [
	"I return a boolean. 
	true when I have handled the event and no futher processing is needed by the caller.
	
	This method would be cleaner if splitted."

	| key controlKeyPressed commandKeyPressed |
	self setEditor: anEditor.
	key := aKeyboardEvent key.
	controlKeyPressed := aKeyboardEvent controlKeyPressed.
	commandKeyPressed := aKeyboardEvent commandKeyPressed.
	
	(self isMenuOpen not and: [
		self editor atCompletionPosition and: [
			NECPreferences popupShowWithShortcut matches: {aKeyboardEvent}]])
				ifTrue: [ 
					aKeyboardEvent supressNextKeyPress: true.
					self openMenu. ^ true ].
	
	key = KeyboardKey backspace
		ifTrue: [ 
			self smartBackspace ifTrue: [ ^ true ]].	
	
	self isMenuOpen ifFalse: [ ^ false ].
	
	({ KeyboardKey left . KeyboardKey right.
		KeyboardKey keypadLeft . KeyboardKey keypadRight }
			includes: key) ifTrue: [ "just move the caret" ^ false ].
	
	({ KeyboardKey up . KeyboardKey keypadUp } includes: key)
		ifTrue: [ 
			menuMorph moveUp.
			^ true ].
	({ KeyboardKey down . KeyboardKey keypadDown } includes: key)
		ifTrue: [ 
			menuMorph moveDown.
			^ true ].
	(key = KeyboardKey pageUp)
		ifTrue: [ 
			menuMorph pageUp.
			^ true ].
	(key = KeyboardKey pageDown)
		ifTrue: [ 
			menuMorph pageDown.
			^ true ].
	(key = KeyboardKey enter and: [ NECPreferences useEnterToAccept ])
		ifTrue: [ 
			menuMorph insertSelected
				ifTrue: [ ^ true ] ].
	key = KeyboardKey tab
		ifTrue: [ 
			menuMorph insertSelected
						ifTrue: [ ^ true ] ].
	key = KeyboardKey backspace
		ifTrue: [ 
			editor isCaretBehindChar
				ifFalse: [ self closeMenu ].
			^ false ].
	(controlKeyPressed or: [ commandKeyPressed or: [ key = KeyboardKey escape ] ])
		ifTrue: [ 
			self closeMenu.
			^ true ].
	^ false
]

{ #category : #keyboard }
CompletionEngine >> handleKeystrokeAfter: aKeyboardEvent editor: aParagraphEditor [

	^ self updateCompletionAfterEdition: aParagraphEditor
]

{ #category : #keyboard }
CompletionEngine >> handleKeystrokeBefore: aKeyboardEvent editor: anEditor [
	"I return a boolean. 
	true when I have handled the event and no futher processing is needed by the caller.
	
	This method would be cleaner if splitted."

	| keyCharacter controlKeyPressed |
	self setEditor: anEditor.
	keyCharacter := aKeyboardEvent keyCharacter.
	controlKeyPressed := aKeyboardEvent controlKeyPressed.
	
	(self smartInputWithEvent: aKeyboardEvent )
		ifNotNil: [ ^ true ].
	
	self isMenuOpen
		ifFalse: [ ^ self handleKeystrokeWithoutMenu: aKeyboardEvent ].
	
	(controlKeyPressed not and: [ aKeyboardEvent keyCharacter isCompletionCharacter ])
		ifFalse: [ 
			self closeMenu.
			^ keyCharacter = Character escape ].
	^ false
]

{ #category : #keyboard }
CompletionEngine >> handleKeystrokeWithoutMenu: aKeyboardEvent [
	"I handle resetting the completion menu, and I return true when I handle an event."
	
	self stopCompletionDelay.

	NECPreferences popupShowAutomatic ifTrue: [
		(aKeyboardEvent anyModifierKeyPressed not 
		and: [ aKeyboardEvent keyCharacter isCompletionCharacter ]) 
			ifTrue: [ self resetCompletionDelay ] ].
	
	^ false
]

{ #category : #testing }
CompletionEngine >> hasCompletionContext [
	
	^ context notNil
]

{ #category : #keyboard }
CompletionEngine >> invalidateEditorMorph [
		editor morph invalidRect: editor morph bounds.

]

{ #category : #'menu morph' }
CompletionEngine >> isMenuOpen [
	^menuMorph notNil
]

{ #category : #testing }
CompletionEngine >> isScripting [

	^ self editor 
		ifNotNil: [ self editor isScripting ]
		ifNil: [ false ]
]

{ #category : #keyboard }
CompletionEngine >> leftArrow [
	"I return false when the arrow is at its left-most position.
	Otherwise i return true."
	
	(menuMorph hideDetail)	
			ifFalse: [ 
				self closeMenu.
				^ false ].	
	^ true
]

{ #category : #'menu morph' }
CompletionEngine >> menuClosed [
	menuMorph := nil.
	context := nil.
]

{ #category : #private }
CompletionEngine >> menuMorphClass [
	^ NECMenuMorph
]

{ #category : #keyboard }
CompletionEngine >> newSmartCharacterInsertionStringForLeft: left right: right [
	((NECPreferences smartCharactersWithDoubleSpace includes: left) or: [
	(NECPreferences smartCharactersWithDoubleSpace includes: right)])
	ifTrue: [ 
		^ String with: left with: Character space with: Character space  with: right ].
	
	((NECPreferences smartCharactersWithSingleSpace includes: left) or: [
	(NECPreferences smartCharactersWithSingleSpace includes: right)])
	ifTrue: [ 
		^ String with: left with: Character space  with: right ].
	
	^ String with: left with: right
]

{ #category : #'menu morph' }
CompletionEngine >> openMenu [
	| theMenu |
	self stopCompletionDelay.

	context := self createContext.
	theMenu := self menuMorphClass
				engine: self
				position: (editor selectionPosition: context completionToken).
				
	theMenu isClosed ifFalse: [ menuMorph := theMenu ]
]

{ #category : #replacement }
CompletionEngine >> replaceTokenInEditorWith: aString [
	"Main API with the completion context.
	Replace the current completion token (as it was extracted by the completion context) by aString.
	aString may contain a keyword selector string where each keyword is separated by two spaces (between:  and:)
	After replacing, set the caret after the first keyword.
	The completion context uses this API to insert text into the text editor"

	| wordEnd old positionAfterFirstKeyword offset firstKeyword wordStart |
	"Try to correctly replace the current token in the word.
	The code editor should be able to do it by himself"
	wordEnd := self editor nextWord: self editor caret.
	wordStart := self editor previousWord: self editor caret - 1.
	self editor
		selectInvisiblyFrom: wordStart
		to: wordEnd - 1.
	old := self editor selection.
	self editor replaceSelectionWith: aString.
	
	offset := NECPreferences spaceAfterCompletion
		ifTrue: [ 1 ]
		ifFalse: [ 0 ].
	firstKeyword := (aString copyUpTo: $ ) size.
	positionAfterFirstKeyword := wordEnd + firstKeyword + offset - old size.
	self editor selectAt: positionAfterFirstKeyword.
	
	self editor morph invalidRect: self editor morph bounds
]

{ #category : #private }
CompletionEngine >> resetCompletionDelay [
	"Open the popup after 100ms and only after certain characters"
	self stopCompletionDelay.
	self isMenuOpen ifTrue: [ ^ self ].
	editor atCompletionPosition ifFalse: [ ^ self ].
	
	completionDelay := [
			(Delay forMilliseconds: NECPreferences popupAutomaticDelay) wait.
			UIManager default defer:  [ 
				editor atCompletionPosition ifTrue: [ self openMenu ]]
		] fork.
	
]

{ #category : #private }
CompletionEngine >> setEditor: anObject [
	editor ifNotNil: [  
		"make sure we unsubscribe from old editor"
		editor morph ifNotNil: [:m | m announcer unsubscribe: self] ].
	editor := anObject.
	editor morph onAnnouncement: MorphLostFocus send: #closeMenu to: self.
	editor morph onAnnouncement: MorphClosePopups send: #closeMenu to: self.
]

{ #category : #keyboard }
CompletionEngine >> smartBackspace [
	| opposite currentText currentEditor smartCharacter |
	
	currentEditor := editor.
	currentEditor hasSelection
		ifTrue: [ ^ false ].
	
	currentText := currentEditor text.
	smartCharacter := currentText at: currentEditor startIndex - 1 ifAbsent: [ ^ false ].	"take the opposite"
	
	opposite := self smartCharacterOppositeOf: smartCharacter ifAbsent: [ ^false ].	"test if the next char is opposite"
	
	opposite = (currentText at: currentEditor stopIndex ifAbsent: [ ^ false ])
		ifFalse: [ ^ false ].	"test if there is an extra opposite to remove"
	
	(self 
		smartNeedExtraRemoveIn: currentText 
		for: smartCharacter 
		opposite: opposite 
		at: currentEditor startIndex)
			ifFalse: [  ^ false ].	
			
	currentEditor closeTypeIn.
	
	currentEditor 
		selectInvisiblyFrom: currentEditor startIndex - 1 
		to: currentEditor stopIndex.
	currentEditor replaceSelectionWith: currentEditor nullText.
	
	self invalidateEditorMorph.
	
	^ true
]

{ #category : #settings }
CompletionEngine >> smartCharacterOppositeOf: char ifAbsent: aBlock [
	^(self smartCharactersMapping at: char ifAbsent: [ ^aBlock value ]) key
]

{ #category : #settings }
CompletionEngine >> smartCharacterPairFor: char ifAbsent: aBlock [
	| left right |
	
	left := self smartCharactersMapping at: char ifPresent: [ char ] ifAbsent: [ 
		self smartInverseMapping at: char ifPresent: [:key | key ] ifAbsent: [ ^aBlock value ]].
	
	right := self smartCharacterOppositeOf: left ifAbsent: [ ^aBlock value ].
	
 	^ left -> right
]

{ #category : #settings }
CompletionEngine >> smartCharacterShouldClose: char [
	^(self smartCharactersMapping at: char ifAbsent: [ ^false ]) value
]

{ #category : #keyboard }
CompletionEngine >> smartCharacterWithEvent: anEvent [
	"char is extracted from anEvent, anEvent is passed because we may need it.
	We may remove char if this is not costly."

	| opposite previous next char insertion insertionCenter matchingPair |
	char := anEvent keyCharacter.
	editor hasSelection
		ifTrue: [ 
			"we selected a piece of text and we type the same character that previously, so
		we unwrap it"
			"we selected a piece of text if the character is not a special one we do nothing."
			matchingPair := self smartCharacterPairFor: char ifAbsent: [  ^nil ].	"else we wrap the selection"	"editor replaceSelectionWith: (String with: char) , (editor selection) , (String with: opposite)."	"ugly logic it should be encapsulated in the editor "
			
			editor encloseWith: matchingPair.
			self invalidateEditorMorph.
			^ true ].	"we are not in a selection"
			
	(self smartCharacterShouldClose: char)	
		ifFalse: [ 
			"if the character is not a special character"
			self smartInverseMapping at: char ifAbsent: [ ^ nil ].	"if the character is not a closing special character do nothing"	"The character is special"
			editor blinkPrevParen: char.
			(editor nextCharacterIfAbsent: [ ^ nil ]) = char
				ifFalse: [ ^ nil ].	"do not get this test but if we comment it out we cannot type closing ) anymore"
			editor selectFrom: editor startIndex + 1 to: editor startIndex.
			self invalidateEditorMorph.
			^ true ].
		
	opposite := self smartCharacterOppositeOf: char ifAbsent: [ ^nil ].
	previous := editor previousCharacterIfAbsent: [ Character space ].
	next := editor nextCharacterIfAbsent: [ Character space ].
	insertion := next isSeparator
				ifFalse: [ char asString ]
				ifTrue: [ 
					previous isSeparator
						ifFalse: [ char asString ]
						ifTrue: [ self newSmartCharacterInsertionStringForLeft: char right: opposite ]].
	editor replaceSelectionWith: insertion.
	insertionCenter := insertion size // 2 max: 1.
	editor selectFrom: editor startIndex + insertionCenter to: editor startIndex + (insertionCenter - 1).
	self invalidateEditorMorph.
	^ true
]

{ #category : #settings }
CompletionEngine >> smartCharacters [
	^ NECPreferences smartCharacters 
]

{ #category : #settings }
CompletionEngine >> smartCharactersMapping [
	^ NECPreferences smartCharactersMapping 
]

{ #category : #keyboard }
CompletionEngine >> smartInputWithEvent: anEvent [
	"aCharacter is extracted from anEvent, anEvent is passed because we may need it.
	We may remove aCharacter if this is not costly."
	
	self smartCharacters 
		ifFalse: [ ^ nil ].
	
	^ self smartCharacterWithEvent: anEvent
]

{ #category : #settings }
CompletionEngine >> smartInverseMapping [
	^ inverseMapping ifNil: [ 
		inverseMapping := Dictionary new.
		self smartCharactersMapping
			keysAndValuesDo: [ :char :inverse | inverseMapping at: inverse key put: char ].
		inverseMapping ]
]

{ #category : #private }
CompletionEngine >> smartNeedExtraRemoveIn: currentText for: opposite [
	"Test if smart remove need to remove an extra character when the smart character 
	 is equal to its opposite"
	
	(currentText select: [ :char | char = opposite ]) size odd
		ifTrue: [ ^ false ].
	^true
]

{ #category : #private }
CompletionEngine >> smartNeedExtraRemoveIn: currentText for: smartCharacter opposite: opposite at: position [
	"Test if we need to remove an extra character when removing a smart character (any kind of smart character)"
	
	smartCharacter = opposite
		ifTrue: [ 
			(self smartNeedExtraRemoveIn: currentText for: opposite)
				ifFalse: [ ^ false ] ]
		ifFalse: [ 
			(self
				smartNeedExtraRemovePairedIn: currentText
				for: smartCharacter
				opposite: opposite
				at: position)
					ifFalse: [ ^false ] ].
	^ true
]

{ #category : #private }
CompletionEngine >> smartNeedExtraRemovePairedIn: currentText for: smartCharacter opposite: opposite at: position [
	"Test if we need to remove an extra character when removed a paired smart character.
	 A paired smart character is any smart character who has an opposite who is diferent to itself: [], ()"
	
	| startIndex countSmart countOpposite |
	
	countSmart := 0.
	countOpposite := 0.
	startIndex := self
		smartStartIndexIn: currentText
		for: smartCharacter
		opposite: opposite
		at: position.
		
	(currentText allButFirst: startIndex) 
		do: [ :char | 
			char = smartCharacter
				ifTrue: [ countSmart := countSmart + 1 ].
			char = opposite
				ifTrue: [ countOpposite := countOpposite + 1 ] ].
	
	(countSmart > countOpposite and: [ (countOpposite - countSmart) odd ])
		ifTrue: [ ^ false ].
		
	^true
]

{ #category : #private }
CompletionEngine >> smartStartIndexIn: currentText for: smartCharacter  opposite: opposite  at: position [
	
	(position - 1) to: 1 by: -1 do: [ :index | | char | 
		char := currentText at: index.
		(char = smartCharacter or: [ char = opposite])
			 ifFalse: [ ^index ] ].
	
	^0
]

{ #category : #private }
CompletionEngine >> stopCompletionDelay [

    completionDelay ifNotNil: [ 
        completionDelay isTerminating ifFalse: [ completionDelay terminate ] ]
]

{ #category : #keyboard }
CompletionEngine >> updateCompletionAfterEdition: aParagraphEditor [

	(aParagraphEditor isNil or: [ self isMenuOpen not ]) ifTrue: [ 
		^ self ].

	aParagraphEditor atCompletionPosition ifFalse: [ ^ self closeMenu ].

	context narrowWith: aParagraphEditor wordAtCaret.
	menuMorph refreshSelection
]
