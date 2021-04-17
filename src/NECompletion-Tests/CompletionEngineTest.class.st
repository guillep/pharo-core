"
A NECControllerTest is a test class for testing the behavior of NECController
"
Class {
	#name : #CompletionEngineTest,
	#superclass : #TestCase,
	#instVars : [
		'controller',
		'editor'
	],
	#category : #'NECompletion-Tests'
}

{ #category : #'tests-keyboard' }
CompletionEngineTest >> allSelfClosingCharacters [
	^ {'{}' . '[]' . '()' . '<>' . '||' . '""' . ''''''}
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> allSmartCharacters [
	^ self allSelfClosingCharacters , { '||'. '<>' }
]

{ #category : #accessing }
CompletionEngineTest >> interactionModel [
	
	^ nil
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> keyboardEventFor: char [

	^ self keyboardEventFor: char useCommand: false
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> keyboardEventFor: char useCommand: command [

	| event modifier |
	event := KeyboardEvent new.
	modifier := 0.
	command ifTrue: [ modifier := modifier + 64].
	event 
		setType: #keyDown
		buttons: modifier
		position:  0@0
		keyValue: char asciiValue 
		charCode: char asciiValue
		hand: nil 
		stamp: Time now.
	event key: (KeyboardKey fromCharacter: char).
	^event
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> keyboardPressFor: char [

	| event |
	event := KeyboardEvent new.
	event 
		setType: #keypress
		buttons: 0
		position:  0@0
		keyValue: char asciiValue 
		charCode: char asciiValue
		hand: nil 
		stamp: Time now.
	^event
]

{ #category : #running }
CompletionEngineTest >> newCompletionEngine [
	
	^ CompletionEngine new
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> selectAll [
	editor selectAll 
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> selectAt: anIndex [
	editor selectFrom: anIndex to: anIndex - 1
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> selectFrom: start to: stop [
	editor selectFrom: start to: stop
]

{ #category : #accessing }
CompletionEngineTest >> selectedClassOrMetaClass [
	
	^ nil
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> setEditorText: aString [
	editor selectAll; addString:  aString 
	
]

{ #category : #running }
CompletionEngineTest >> setUp [
	super setUp.
	
	editor := RubSmalltalkEditor forTextArea: RubEditingArea new beForSmalltalkCode.
	controller := self newCompletionEngine.
	controller setEditor: editor.
	editor completionEngine: controller.
	editor textArea model: self.
]

{ #category : #running }
CompletionEngineTest >> tearDown [
	
	controller closeMenu.
	editor textArea delete.
	super tearDown
]

{ #category : #'test-interaction' }
CompletionEngineTest >> testReplaceTokenAfterMovingCaretToMiddleOfWordWithFollowingWordsReplacesEntireWord [

	"If the caret is at the end of a word, replace the entire word"
	
	| text |
	text := 'self mEthOdThatDoesNotExist something that follows'.
	
	self
		setEditorText: text;
		selectAt: 'self mEthOdThatDoesNotExist' size + 1.
	
	editor textArea openInWorld.
	controller openMenu.

	controller context replaceTokenInEditorWith: 'toto'.
	
	self assert: editor text equals: 'self toto something that follows'
]

{ #category : #'test-interaction' }
CompletionEngineTest >> testReplaceTokenWithCaretInTheMiddleOfWordReplacesEntireWord [

	"If the caret is at the end of a word, replace the entire word"
	
	| text |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: 'self mEthOdThatDoes' size + 1.
	
	editor textArea openInWorld.
	controller openMenu.

	controller context replaceTokenInEditorWith: 'toto'.
	
	self assert: editor text equals: 'self toto'
]

{ #category : #'test-interaction' }
CompletionEngineTest >> testReplaceTokenWithCaretInTheMiddleOfWordWithFollowingWordsReplacesEntireWord [

	"If the caret is at the end of a word, replace the entire word"
	
	| text |
	text := 'self mEthOdThatDoesNotExist something that follows'.
	
	self
		setEditorText: text;
		selectAt: 'self mEthOdThatDoes' size + 1.
	
	editor textArea openInWorld.
	controller openMenu.
	editor keyDown: (self keyboardEventFor: Character arrowLeft).
	editor keyDown: (self keyboardEventFor: Character arrowLeft).

	controller context replaceTokenInEditorWith: 'toto'.
	
	self assert: editor text asString equals: 'self toto something that follows'
]

{ #category : #'test-interaction' }
CompletionEngineTest >> testReplaceTokenWithCaretOnEndOfWordReplacesEntireWord [

	"If the caret is at the end of a word, replace the entire word"
	
	| text |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: text size + 1.
	
	editor textArea openInWorld.
	controller openMenu.

	controller context replaceTokenInEditorWith: 'toto'.
	
	self assert: editor text equals: 'self toto'
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartBackspace [
	"Pressing backspace inside paired smart characters should remove both of them"
	self allSmartCharacters
		do: [ :chars | 
			self
				setEditorText: '.' , chars , ';';
				selectAt: 3.
			self
				assert: controller smartBackspace
				description: 'smartbackspace if next to smart characters [' , chars , ']'.
			self assert: editor text equals: '.;' ]
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartBackspaceOutsideSmartCharacters [

	self setEditorText: '.[];'; selectAll.
	self selectAt: 2.
	self
		assert: controller smartBackspace not
		description: 'smartbackspace ignored if before smart character'.
		
	self selectAt: 4.
	self
		assert: controller smartBackspace not
		description: 'smartbackspace ignored if after smart character'
		
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartBackspaceWithSelection [

	self setEditorText: 'Hello'; selectAll.
	self assert: controller smartBackspace not description: 'No smartbackspace if selection'.
	
	self selectAt: 2.
	self
		assert: controller smartBackspace not
		description: 'No smartbackspace if no selection and not a smart character'.
		
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartCharacterAfterEspace [
	"Test we surround selected text with smart characters properly"
	self
		setEditorText: 'a b';
		selectFrom: 2 to: 4.
	editor keystroke: (self keyboardPressFor: $").
	self assert: editor text equals: 'a" b"'.
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartCharacterPairForIfAbsent [

	"Check leading smart character has matching trailing character - e.g. { and }"
	self allSmartCharacters do: [ :pairs |
		self assert: (controller smartCharacterPairFor: pairs first ifAbsent: [ nil ]) equals: pairs first -> pairs last].
	
	"Check trailing smart character has matching leading character - e.g. } and {"
	self allSmartCharacters do: [ :pairs |
		self assert: (controller smartCharacterPairFor: pairs last ifAbsent: [ nil ]) equals: pairs first -> pairs last].
	
	self assert: (controller smartCharacterPairFor: $% ifAbsent: [ nil ]) equals: nil.
		
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartCharacterWithEventAndSelection [
	"Test we surround selected text with smart characters properly"
	self
		setEditorText: ' text ';
		selectFrom: 2 to: 5.
		
	controller smartCharacterWithEvent: (self keyboardEventFor: $|).
	self assert: editor text equals: ' |text| '.
	
	self
		setEditorText: ' text ';
		selectFrom: 2 to: 5.
		
	controller smartCharacterWithEvent: (self keyboardEventFor: $[).
	self assert: editor text equals: ' [text] '.
	
	self
		setEditorText: ' text ';
		selectFrom: 2 to: 5.
	controller smartCharacterWithEvent: (self keyboardEventFor: $]).
	self assert: editor text equals: ' [text] '
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartCharacterWithEventSelfClosing [
	self
		setEditorText: ' ';
		selectAt: 2.
		
	controller smartCharacterWithEvent: (self keyboardEventFor: $().
	self assert: editor text equals: ' ()'.
	
	self
		setEditorText: ' ';
		selectAt: 2.
		
	controller smartCharacterWithEvent: (self keyboardEventFor: $)).
	self assert: editor text equals: ' '.
	
	self
		setEditorText: ' ';
		selectAt: 2.
		
	controller smartCharacterWithEvent: (self keyboardEventFor: $<).
	self assert: editor text equals: ' '.
	
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartCharactersOppositeOf [
	
	self allSmartCharacters
		do: [ :pairs | 
			self
				assert: (controller smartCharacterOppositeOf: pairs first ifAbsent: [ nil ])
				equals: pairs last ]
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartCharactersShouldClose [
	"Some smart characters shouldn't auto close, ohers not"
	self assert: (controller smartCharacterShouldClose: $() equals: true.
	self assert: (controller smartCharacterShouldClose: $<) equals: false.
	
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartDoubleQuoteDoesNotEscapeQuote [
	"Test we surround selected text with smart characters properly"
	self
		setEditorText: ' te''xt ';
		selectFrom: 2 to: 6.
		
	controller smartCharacterWithEvent: (self keyboardPressFor: $").
	self assert: editor text equals: ' "te''xt" '.
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartDoubleQuoteSurroundsEscapesSelection [
	"Test we surround selected text with smart characters properly"
	self
		setEditorText: ' te"xt ';
		selectFrom: 2 to: 6.
		
	controller smartCharacterWithEvent: (self keyboardPressFor: $").
	self assert: editor text equals: ' "te""xt" '.
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartDoubleQuoteSurroundsSelection [
	"Test we surround selected text with smart characters properly"
	self
		setEditorText: ' text ';
		selectFrom: 2 to: 5.
		
	controller smartCharacterWithEvent: (self keyboardPressFor: $").
	self assert: editor text equals: ' "text" '.
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartNeedExtraRemoveInForOppositeAt [

	self assert: (controller smartNeedExtraRemoveIn: '()' for: $( opposite:$) at:1).
	self deny: (controller smartNeedExtraRemoveIn: '(()' for: $( opposite:$) at:2).
	self assert: (controller smartNeedExtraRemoveIn: '(1()' for: $( opposite:$) at:3).
	self assert: (controller smartNeedExtraRemoveIn: '(1(1())' for: $( opposite:$) at:5).
	self assert: (controller smartNeedExtraRemoveIn: '((1)1())))' for: $( opposite:$) at:6).
	self deny: (controller smartNeedExtraRemoveIn: '()(()' for: $( opposite:$) at:3).
	self assert: (controller smartNeedExtraRemoveIn: '(foobar()' for: $( opposite:$) at:8).
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartQuoteSurroundsDoesNotEscapeDoubleQuote [
	"Test we surround selected text with smart characters properly"
	self
		setEditorText: ' te"xt ';
		selectFrom: 2 to: 6.
		
	controller smartCharacterWithEvent: (self keyboardPressFor: $').
	self assert: editor text equals: ' ''te"xt'' '.
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartQuoteSurroundsEscapesSelection [
	"Test we surround selected text with smart characters properly"
	self
		setEditorText: ' te''xt ';
		selectFrom: 2 to: 6.
		
	controller smartCharacterWithEvent: (self keyboardPressFor: $').
	self assert: editor text equals: ' ''te''''xt'' '.
]

{ #category : #'tests-keyboard' }
CompletionEngineTest >> testSmartQuoteSurroundsSelection [
	"Test we surround selected text with smart characters properly"
	self
		setEditorText: ' text ';
		selectFrom: 2 to: 5.
		
	controller smartCharacterWithEvent: (self keyboardPressFor: $').
	self assert: editor text equals: ' ''text'' '.
]
