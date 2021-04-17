"
I represent the editor for plain text, I do the operations related to plain text
"
Class {
	#name : #RubTextEditor,
	#superclass : #Object,
	#instVars : [
		'defaultKeymappingIndex',
		'textArea'
	],
	#category : #'Rubric-Editing-Core'
}

{ #category : #keymapping }
RubTextEditor class >> buildPatchShortcutsForSelectAllInWindowsOn: aBuilder [
	<keymap>
	"this is because for some reason Ctrl+a means Ctrl+home on Windows"
	(aBuilder shortcut: #selectAllPatchForWin) 
		category: RubTextEditor name
		default: Character home ctrl win
		do: [ :target | target editor selectAll: nil ]
		description: 'Select all'

]

{ #category : #keymapping }
RubTextEditor class >> buildShortcutsOn: aBuilder [
	"We are defining the bindings twice because we want to support 
	both Cmd and Ctrl for Windows and Linux. This should happen at least as long as in the development environment
	both of these are supported.
	
	We list both variations explicitly because we want to be able to see the action code when inspecting the morph.
	"
	<keymap>
	(aBuilder shortcut: #cancel) 
		category: RubTextEditor name
		default: $l meta
		do: [ :target | target editor cancel ]
		description: 'Cancel unsaved editings'.
		
	(aBuilder shortcut: #accept) 
		category: RubTextEditor name
		default: $s meta
		do: [ :target | target editor accept ]
		description: 'Accept unsaved editings'.
	
	(aBuilder shortcut: #selectAll) 
		category: RubTextEditor name
		default: $a meta
		do: [ :target | target editor selectAll: nil ]
		description: 'Select all'.

	(aBuilder shortcut: #copySelection) 
		category: RubTextEditor name
		default: $c meta
		do: [ :target | target editor copySelection ]
		description: 'Copy selection'.

	(aBuilder shortcut: #paste) 
		category: RubTextEditor name
		default: $v meta
		do: [ :target | target editor paste ]
		description: 'Paste'.

	(aBuilder shortcut: #cut) 
		category: RubTextEditor name
		default: $x meta
		do: [ :target | target editor cut ]
		description: 'Cut selection'.

	(aBuilder shortcut: #undometa) 
		category: RubTextEditor name
		default: $z meta
		do: [ :target | target editor undo ]
		description: 'Undo'.

	(aBuilder shortcut: #redometa) 
		category: RubTextEditor name
		default: $z meta shift
		do: [ :target | target editor redo ]
		description: 'Redo'.

	(aBuilder shortcut: #find) 
		category: RubTextEditor name
		default: $f meta
		do: [ :target | target editor find: nil ]
		description: 'Find text'.

	(aBuilder shortcut: #findAgainmeta) 
		category: RubTextEditor name
		default: $g meta
		do: [ :target | target editor findAgain: nil ]
		description: 'Find text again'.
		
	(aBuilder shortcut: #indent) 
		category: RubTextEditor name
		default: $r meta shift
		do: [ :target | target editor indent: nil ]
		description: 'Indent'.

	(aBuilder shortcut: #outdent) 
		category: RubTextEditor name
		default: $l meta shift
		do: [ :target | target editor outdent: nil ]
		description: 'Outdent'.

	(aBuilder shortcut: #compareToClipboard) 
		category: RubTextEditor name
		default: $c meta shift
		do: [ :target | target editor compareToClipboard: nil ]
		description: 'Compare selection to clipboard'.
]

{ #category : #'instance creation' }
RubTextEditor class >> forTextArea: aMorph [
	^ self new textArea: aMorph
]

{ #category : #'menu messages' }
RubTextEditor >> accept [
	"Save the current text of the text being edited as the current acceptable version for purposes of canceling.  Allow my morph to take appropriate action"
	self canChangeText 
		ifTrue: [textArea acceptContents]
]

{ #category : #'menu messages' }
RubTextEditor >> accept: aKeyboardEvent [ 
	"Save the current text of the text being edited as the current acceptable version for purposes of canceling.  Allow my morph to take appropriate action"
	self accept.
	^ true
]

{ #category : #'undo-redo private' }
RubTextEditor >> addDeleteSelectionUndoRecord [
	| undoText redoText |
	undoText := self selection.
	redoText := self nullText.
	self
		redoArray:	{textArea. #undoTypeIn:interval:.	{redoText.	(self selectionInterval)}}
		undoArray:	{textArea. #redoTypeIn:interval:.	{undoText.	(self selectionInterval first to: self selectionInterval first - 1)}}
]

{ #category : #'typing support' }
RubTextEditor >> addString: aString [
	"Think of a better name"
	self zapSelectionWith: (Text string: aString attributes: self emphasisHere)
]

{ #category : #'undo-redo private' }
RubTextEditor >> addTypeInUndoRecord [
	| begin stop undoText redoText |
	begin := self startOfTyping min: self stopIndex. 
	stop := self stopIndex max: self startOfTyping.
	self editingState previousInterval: (begin to: stop - 1). 
	undoText := self nullText.
	redoText := stop > begin
			ifTrue: [self text copyFrom: begin to: stop - 1]
			ifFalse: [self nullText].
	((undoText isEmpty and: [redoText isEmpty]) and: [self editingState previousInterval size < 1])
			ifFalse: [self 
				redoArray: { textArea. #redoTypeIn:interval:.  {redoText. begin to: begin + self selection size - 1} } 
				undoArray: {textArea. #undoTypeIn:interval:.  {undoText. begin to: stop - 1} }].
	

]

{ #category : #'new selection' }
RubTextEditor >> afterSelectionInsertAndSelect: aString [

	self insertAndSelect: aString at: self stopIndex 
]

{ #category : #'menu messages' }
RubTextEditor >> align [
	"Align text according to the next greater alignment value,
	cycling among leftFlush, rightFlush, center, and justified."
	self changeAlignment.

]

{ #category : #'editing keys' }
RubTextEditor >> align: aKeyboardEvent [
	"Triggered by Cmd-u;  cycle through alignment alternatives."

	self align.
	^ true
]

{ #category : #constants }
RubTextEditor >> alignmentChoices [
	"Return the symbols representing the TextAlignment operations to get a text aligned."
	
	^ #(leftFlush centered justified rightFlush)
]

{ #category : #private }
RubTextEditor >> applyAttribute: aTextAttribute [
	"The user selected aTextAttribute via shortcut, menu or other means.
	If there is a selection, apply the attribute to the selection.
	In any case use the attribute for the user input (emphasisHere)"

	self editingState emphasisHere: (Text addAttribute: aTextAttribute toArray: self emphasisHere).
	self selection
		ifNotEmpty: [:s | self replaceSelectionWith: (s addAttribute: aTextAttribute)].
	self compose.
	self recomputeSelection
]

{ #category : #private }
RubTextEditor >> applyTextFont: aFont [
	self applyAttribute: (TextFontReference toFont: aFont).

]

{ #category : #'new selection' }
RubTextEditor >> atEndOfLineInsertAndSelect: aString [

	self insertAndSelect: aString at: (self encompassParagraph: self selectionInterval) last + 1.
]

{ #category : #'typing support' }
RubTextEditor >> backTo: startIndex [
	"Backspace typing"
	self stopIndex > startIndex ifTrue: [
		self selectFrom: startIndex to: self stopIndex - 1.
		self addDeleteSelectionUndoRecord.
		self zapSelectionWith: self nullText].
	^ false
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> backWord [
	"If the selection is not a caret, delete it and leave it in the backspace buffer.
	 Else, delete the word before the caret."
	^ self backWord: nil

]

{ #category : #'typing/selecting keys' }
RubTextEditor >> backWord: aKeyboardEvent [
	"If the selection is not a caret, delete it and leave it in the backspace buffer.
	 Else, delete the word before the caret."

	| startIndex |
	self hasCursor ifTrue: [ "a caret, delete at least one character"
		startIndex := 1 max: self markIndex - 1.
		[startIndex > 1 and:
			[(self string at: startIndex - 1) tokenish]]
				whileTrue: [
					startIndex := startIndex - 1]]
	ifFalse: [ "a non-caret, just delete it"
		startIndex := self markIndex].
	self backTo: startIndex.
	^false
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> backspace: aKeyboardEvent [
	| result startIndex |
	result := aKeyboardEvent shiftPressed
		ifTrue: [ self backWord: aKeyboardEvent keyCharacter ]
		ifFalse: [ 
			self hasSelection
				ifTrue: [ 
					self replaceSelectionWith: self nullText. 
					textArea changed]
				ifFalse: [ 
					startIndex := self markIndex
						+
							(self hasCursor
								ifTrue: [ 0 ]
								ifFalse: [ 1 ]).
					startIndex := 1 max: startIndex - 1.
					self backTo: startIndex ].
			false ].
	self closeTypeIn.
	^ result
]

{ #category : #'obsolete-parenblinking' }
RubTextEditor >> blinkParenAt: parenLocation [ 
	"kept because NECController is sending it to me"
]

{ #category : #'obsolete-parenblinking' }
RubTextEditor >> blinkPrevParen: aCharacter [
	"kept because NECController is sending it to me"
]

{ #category : #testing }
RubTextEditor >> canChangeText [
	^ textArea canChangeText
]

{ #category : #'menu messages' }
RubTextEditor >> cancel [
	"Cancel the changes made so far to this text"

	self canChangeText
		ifTrue: [ textArea cancelEdits ]
]

{ #category : #'editing keys' }
RubTextEditor >> cancel: aKeyboardEvent [
	"Cancel unsubmitted changes."
	self cancel.
	^ true
]

{ #category : #accessing }
RubTextEditor >> caret [
	"Return the index position of the caret"
	^ self startIndex 
]

{ #category : #settings }
RubTextEditor >> caseSensitiveFinds [
	^ textArea caseSensitiveFinds
]

{ #category : #'menu messages' }
RubTextEditor >> changeAlignment [
	"Interactively change the alignment of the text currently being edited."
	| reply  |
	reply := UIManager default 
				chooseFrom:  self alignmentChoices 
				values:  self alignmentChoices.	
	reply ifNil: [^self].
	self applyAttribute: (TextAlignment perform: reply).
	^ true
]

{ #category : #'menu messages' }
RubTextEditor >> changeEmphasis [

	|  reply code align menuList startIndex attribute choices |
	choices := self emphasisChoices.
	startIndex := self startIndex.
	align := self text alignmentAt: startIndex ifAbsent: [ 0 ].
	code := self text emphasisAt: startIndex.
	menuList := WriteStream on: Array new.
	menuList nextPut: (code isZero ->  'normal' translated).
	menuList nextPutAll: (choices  collect: [:emph|
							(code anyMask: (TextEmphasis perform: emph) emphasisCode)
								-> emph asString translated ]).
						
	menuList nextPut: ((self text attributesAt: startIndex)
							anySatisfy: [ :attr | attr isKern and: [attr kern < 0 ]]) -> 'narrow' translated.
	reply := UIManager default chooseFrom:  choices values: choices.
	reply notNil 
		ifTrue: [ attribute := TextEmphasis perform: reply.
				self applyAttribute:  attribute].
	^ true
]

{ #category : #'editing keys' }
RubTextEditor >> changeEmphasis: aKeyboardEvent [
	"Change the emphasis of the current selection or prepare to accept characters with the change in emphasis. Emphasis change amounts to a font change.  Keeps typeahead."

	"control 0..9 -> 0..9"

	| keyCode attribute oldAttributes index thisSel colors |
	keyCode := ('0123456789-=' indexOf: aKeyboardEvent keyCharacter ifAbsent: [1]) - 1.
	oldAttributes := self text attributesAt: self pointIndex.
	thisSel := self selection.

	"Decipher keyCodes for Command 0-9..."
	"
	(keyCode between: 1 and: 5) 
		ifTrue: [attribute := TextFontChange fontNumber: keyCode].
	"
	keyCode = 6 
		ifTrue: [
			colors := #(#black #magenta #red #yellow #green #blue #cyan #white).
			index := UIManager default chooseFrom:  colors title: 'choose color...'.
			index = 0 ifTrue: [^true].
			index <= colors size 
				ifTrue: [attribute := TextColor color: (Color perform: (colors at: index))]
				ifFalse: [
					index := index - colors size - 1.	"Re-number!!!"
					index = 0 ifTrue: [attribute := self chooseColor].
					thisSel ifNil: [^true]	"Could not figure out what to link to"]].
	(keyCode between: 7 and: 11) 
		ifTrue: [
			aKeyboardEvent shiftPressed 
				ifTrue: [
					keyCode = 10 ifTrue: [attribute := TextKern kern: -1].
					keyCode = 11 ifTrue: [attribute := TextKern kern: 1]]
				ifFalse: [
					attribute := TextEmphasis 
								perform: (#(#bold #italic #narrow #underlined #struckOut) at: keyCode - 6).
					oldAttributes 
						do: [:att | (att dominates: attribute) ifTrue: [attribute turnOff]]]].
	keyCode = 0 ifTrue: [ attribute := TextEmphasis normal ].
	attribute ifNotNil: [
		self applyAttribute: attribute].
	^true
]

{ #category : #'menu messages' }
RubTextEditor >> changeEmphasisOrAlignment [
	| aList reply  code align menuList startIndex attribute |
	startIndex := self startIndex.
	align := self text alignmentAt: startIndex ifAbsent: [ 0 ].
	code := self text emphasisAt: startIndex.
	menuList := WriteStream on: Array new.
	menuList nextPut: (code isZero -> 'normal' translated).
	menuList nextPutAll: (#(bold italic underlined struckOut) collect: [:emph|
		(code anyMask: (TextEmphasis perform: emph) emphasisCode) -> emph asString translated]).
	
	menuList nextPut: ((self text attributesAt: startIndex)
		anySatisfy: [ :attr | attr isKern and: [attr kern < 0 ]]) -> 'narrow' translated.
		
	self alignmentChoices collectWithIndex: [ :type :i |
		menuList nextPut: (align = (i-1)) -> type asString translated ].
	
	aList := #(normal bold italic underlined struckOut narrow leftFlush centered rightFlush justified).
	reply := UIManager default chooseFrom:  aList values: aList.
	reply notNil ifTrue: [
		(self alignmentChoices includes: reply)
			ifTrue: [ attribute :=TextAlignment perform: reply]
			ifFalse: [ attribute := TextEmphasis perform: reply].
		self applyAttribute:  attribute].
	^ true
]

{ #category : #'editing keys' }
RubTextEditor >> changeLfToCr: aKeyboardEvent [
	"Replace all LFs by CRs.
	Triggered by Cmd-U -- useful when getting code from FTP sites
	jmv- Modified to als change crlf by cr"
	
	| fixed |
	fixed := self selection string.
	fixed := fixed copyReplaceAll: String crlf with: String cr.
	fixed := fixed copyReplaceAll: String lf with: String cr. 
	self replaceSelectionWith: (Text fromString: fixed).
	^ true
]

{ #category : #'menu messages' }
RubTextEditor >> changeTextFont [
	"Present a menu of available fonts, and if one is chosen, apply it to the current selection."

	textArea
		forceCursorVisibleWhile: [ 
			| hadFocus |
			hadFocus := textArea hasFocus.
			(FontChooser
				openWithWindowTitle: 'Choose a Font'
				for: self
				setSelector: #applyTextFont:
				getSelector: self fontToUse) openModal.
			hadFocus
				ifTrue: [ textArea takeKeyboardFocus ] ]
]

{ #category : #'menu messages' }
RubTextEditor >> chooseAlignment [
	self changeAlignment
]

{ #category : #'editing keys' }
RubTextEditor >> chooseColor [
	"Make a new Text Color Attribute, let the user pick a color, and return the attribute"

	| attribute |	
	attribute := TextColor color: Color black "default".
	UIManager default chooseColor
		ifNotNil: [:nc | attribute color: nc].
	^ attribute

]

{ #category : #'undo-redo private' }
RubTextEditor >> clearUndoManager: aKeyboardEvent [
	^ self editingState clearUndoManager: aKeyboardEvent.

]

{ #category : #events }
RubTextEditor >> click: event [
	| p |
	self closeTypeIn.
	p := self paragraph characterBlockAtPoint: event cursorPoint.
	textArea markBlock: p pointBlock: p.
	self setEmphasisHereFromText.
	self storeSelectionInText.
	textArea announce: (RubMouseClick with: event)
]

{ #category : #'menu messages' }
RubTextEditor >> clipboardText [

	^ Clipboard clipboardText
]

{ #category : #'menu messages' }
RubTextEditor >> clipboardTextPut: text [

	^ Clipboard clipboardText: text
]

{ #category : #'typing support' }
RubTextEditor >> closeTypeIn [
	"See comment in openTypeIn. It is important to call
	closeTypeIn before executing any non-typing key, making a new selection, etc. It is
	called automatically for menu commands."
	self startOfTyping 
		ifNotNil: [self addTypeInUndoRecord.
			self doneTyping]
]

{ #category : #accessing }
RubTextEditor >> closingDelimiters [
	^ ')]}'

]

{ #category : #keymapping }
RubTextEditor >> cmdActions [
	
	^ self defaultKeymappingIndex at: #command
]

{ #category : #'menu messages' }
RubTextEditor >> compareToClipboard [
	"Check to see if whether the receiver's text is the same as the text currently on the clipboard, and inform the user."
	| s1 s2 |
	s1 := self clipboardText string.
	s2 := self string.
	s1 = s2 ifTrue: [^ self inform: 'Exact match'].
	UIManager default  
		longMessage: (TextDiffBuilder buildDisplayPatchFrom: s1 to: s2)
		title: 'Comparison to Clipboard Text'
]

{ #category : #'editing keys' }
RubTextEditor >> compareToClipboard: aKeyboardEvent [
	"Compare the receiver to the text on the clipboard."

	self compareToClipboard.
	^ true
]

{ #category : #'completion engine' }
RubTextEditor >> completionAround: aBlock keyStroke: anEvent [
	"No code completion for simple text editor, so nothing special to do here around the block execution"
	
	aBlock value
]

{ #category : #private }
RubTextEditor >> compose [
	^textArea compose
]

{ #category : #'new selection' }
RubTextEditor >> computeSelectionIntervalForCurrentLine [

	^ self encompassParagraph: self selectionInterval
]

{ #category : #'menu messages' }
RubTextEditor >> copySelection [
	"Copy the current selection and store it in the paste buffer, unless a caret.  Undoer & Redoer: undoCutCopy"

	self lineSelectAndEmptyCheck: [^ self].
	self clipboardTextPut: self selection.
	self editingState previousInterval: self selectionInterval.

]

{ #category : #'editing keys' }
RubTextEditor >> copySelection: aKeyboardEvent [
	"Copy the current text selection."
	self copySelection.
	^true
]

{ #category : #'new selection' }
RubTextEditor >> correctFrom: start to: stop with: aString [
	"Make a correction in the model that the user has authorised from somewhere else in the system (such as from the compilier).  
	The user's selection is not changed, only corrected."
	| userSelection delta |
	
	userSelection := self selectionInterval.
	self selectInvisiblyFrom: start to: stop.
	self replaceSelectionWith: aString asText.
	delta := aString size - (stop - start + 1).
	self selectInvisiblyFrom:
		userSelection first + (userSelection first > start ifFalse: [ 0 ] ifTrue: [ delta ])
		to: userSelection last + (userSelection last > start ifFalse: [ 0 ] ifTrue: [ delta ]).

]

{ #category : #'typing/selecting keys' }
RubTextEditor >> crWithIndent: aKeyboardEvent [
	"Replace the current text selection with CR followed by as many tabs
	as on the current line (+/- bracket count) -- initiated by Shift-Return."
	| char s i tabCount crChars|
	self closeTypeIn.
	s := self string.
	i := self stopIndex.
	tabCount := 0.
	crChars := Array with: Character cr with: Character lf.
	[(i := i-1) > 0 and: [(crChars includes: (char := s at: i)) not]]
		whileTrue:  "Count tabs and brackets (but not a leading bracket)"
		[(char = Character tab and: [i < s size and: [(s at: i+1) ~= $[ ]]) ifTrue: [tabCount := tabCount + 1].
		char = $[ ifTrue: [tabCount := tabCount + 1].
		char = $] ifTrue: [tabCount := tabCount - 1]].
	 "Now inject CR with tabCount tabs"
	self addString: (String streamContents: [ :strm | strm crtab: tabCount ]).
	self unselect.
	^ false
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> crlf: aKeyboardEvent [
	"Append a line feed character to the stream of characters."

	self addString: String crlf.
	^false
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> cursorDown: aKeyboardEvent [ 

	"Private - Move cursor from position in current line to same position in
	next line. If next line too short, put at end. If shift key down,
	select."

	self closeTypeIn.
	self 
		moveCursor:[:position | self
				sameColumn: position
				newLine:[:line | line + 1]
				forward: true]
		forward: true
		specialBlock:[:dummy | dummy]
		event: aKeyboardEvent.
	^true
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> cursorEnd: aKeyboardEvent [
	"Private - Move cursor end of current line."

	| string |
	self closeTypeIn.
	string := self string.
	self
		moveCursor: [ :position | string indexOf: Character cr startingAt: position ifAbsent: [ string size + 1 ] ]
		forward: true
		specialBlock: [ :dummy | string size + 1 ]
		event: aKeyboardEvent.
	^ true
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> cursorHome: aKeyboardEvent [
	"Private - Move cursor from position in current line to beginning of
	current line. If control key is pressed put cursor at beginning of text"

	| string |
	string := self string.
	self
		moveCursor: [ :position | (string lastIndexOf: Character cr startingAt: position - 1 ifAbsent: [ 0 ]) + 1 ]
		forward: false
		specialBlock: [ :dummy | 1 ]
		event: aKeyboardEvent.
	^ true
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> cursorLeft: aKeyboardEvent [ 
	"Private - Move cursor left one character if nothing selected, otherwise 
	move cursor to beginning of selection. If the shift key is down, start 
	selecting or extending current selection. Don't allow cursor past 
	beginning of text"

	self closeTypeIn.
	self
		moveCursor:[:position | position - 1 max: 1]
		forward: false
		specialBlock:[:position | self previousWord: position]
		event: aKeyboardEvent.
	^ true
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> cursorPageDown: aKeyboardEvent [ 

	self closeTypeIn.
	self 
		moveCursor: [:position |
			self
				sameColumn: position
				newLine: [:lineNo | lineNo + self pageHeight]
				forward: true]
		forward: true
		specialBlock:[:dummy | dummy]
		event: aKeyboardEvent.
	^true
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> cursorPageUp: aKeyboardEvent [ 

	self closeTypeIn.
	self 
		moveCursor: [:position |
			self
				sameColumn: position
				newLine: [:lineNo | lineNo - self pageHeight]
				forward: false]
		forward: false
		specialBlock:[:dummy | dummy]
		event: aKeyboardEvent.
	^true
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> cursorRight: aKeyboardEvent [ 
	"Private - Move cursor right one character if nothing selected, 
	otherwise move cursor to end of selection. If the shift key is down, 
	start selecting characters or extending already selected characters. 
	Don't allow cursor past end of text"

	self closeTypeIn.
	self
		moveCursor: [:position | position + 1]
		forward: true
		specialBlock:[:position | self nextWord: position]
		event: aKeyboardEvent.
	^ true
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> cursorTopHome: aKeyboardEvent [
	"Put cursor at beginning of text -- invoked from cmd-H shortcut, useful for keyboards that have no home key."

	self selectAt: 1.
	^ true
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> cursorUp: aKeyboardEvent [ 
"Private - Move cursor from position in current line to same position in
prior line. If prior line too short, put at end"

	self closeTypeIn.
	self
		moveCursor: [:position | self
				sameColumn: position
				newLine:[:line | line - 1]
				forward: false]
		forward: false
		specialBlock:[:dummy | dummy]
		event: aKeyboardEvent.
	^true
]

{ #category : #private }
RubTextEditor >> cut [
	"Cut out the current selection and redisplay the paragraph if necessary.  Undoer & Redoer: undoCutCopy:"

	self lineSelectAndEmptyCheck: [^ self].
	self clipboardTextPut: self selection.
	self replaceSelectionWith: self nullText.
	textArea changed

]

{ #category : #'editing keys' }
RubTextEditor >> cut: aKeyboardEvent [ 
	"Cut out the current text selection."

	self cut.
	^true
]

{ #category : #keymapping }
RubTextEditor >> defaultCommandKeymapping [
	| cmdMap |
		
	cmdMap := Dictionary new.
	{(KeyboardKey home -> #cursorHome:).
	(KeyboardKey end -> #cursorEnd:).
	(KeyboardKey backspace -> #backspace:).
	(KeyboardKey pageUp -> #cursorPageUp:).
	(KeyboardKey pageDown -> #cursorPageDown:).
	(KeyboardKey enter -> #crWithIndent:).
	(KeyboardKey escape -> #escape:).
	(KeyboardKey left -> #cursorLeft:).
	(KeyboardKey right -> #cursorRight:).
	(KeyboardKey up -> #cursorUp:).
	(KeyboardKey down -> #cursorDown:).
	(KeyboardKey keypadLeft -> #cursorLeft:).
	(KeyboardKey keypadRight -> #cursorRight:).
	(KeyboardKey keypadUp -> #cursorUp:).
	(KeyboardKey keypadDown -> #cursorDown:).
	(KeyboardKey tab -> #tab:).
	(KeyboardKey delete -> #forwardDelete:) } do: [ :assoc | 
		cmdMap at: assoc key  put: assoc value ].
	^ cmdMap
]

{ #category : #keymapping }
RubTextEditor >> defaultKeymappingIndex [
	^defaultKeymappingIndex ifNil: [ defaultKeymappingIndex := self newDefaultKeymappingIndex ]
]

{ #category : #'accessing-selection' }
RubTextEditor >> deselect [
	"If the text selection is visible on the screen, reverse its highlight."
	" ***** screw this logic ***** selectionShowing ifTrue: [self reverseSelection] "
]

{ #category : #'typing support' }
RubTextEditor >> dispatch: aKeyboardEvent [
	"Carry out the action associated with this character, if any.
	Type-ahead is passed so some routines can flush or use it."

	self
		dispatchCommandOn: aKeyboardEvent
		return: [ :val | ^ val ].
	^ false
]

{ #category : #'typing support' }
RubTextEditor >> dispatchCommandOn: aKeyboardEvent return: return [

	^ self performCmdActionsWith: aKeyboardEvent shifted: aKeyboardEvent shiftPressed return: return
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> doAgainMany: aKeyboardEvent [ 
	"Do the previous thing again repeatedly."

	self closeTypeIn.
	^ true
]

{ #category : #'typing support' }
RubTextEditor >> doneTyping [
	self startOfTyping: nil
]

{ #category : #events }
RubTextEditor >> doubleClick: evt [
	| here |
	self closeTypeIn.	"no matter what, if shift is pressed extend the selection"
	here := self pointIndex.
	(here between: 2 and: self string size)
		ifFalse: [ 
			"if at beginning or end, select entire string"
			self selectFrom: 1 to: self string size ]
		ifTrue: [ self selectWord ].
	self setEmphasisHereFromText.
	self storeSelectionInText
]

{ #category : #'editing keys' }
RubTextEditor >> duplicate: aKeyboardEvent [
	"Paste the current selection over the prior selection, if it is non-overlapping and
	 legal.  Undoer & Redoer: undoAndReselect."

	self closeTypeIn.
	(self hasSelection and: [self isDisjointFrom: self editingState previousInterval])
		ifTrue: "Something to duplicate"
			[self replace: self editingState previousInterval with: self selection and:
				[self selectAt: self pointIndex]]
		ifFalse:
			[textArea flash].
	^true
]

{ #category : #'accessing-selection' }
RubTextEditor >> editPrimarySelectionSeparately [
	textArea editPrimarySelectionSeparately
]

{ #category : #accessing }
RubTextEditor >> editingState [
	^ textArea editingState
]

{ #category : #constants }
RubTextEditor >> emphasisChoices [
	"Return the list of emphasis that are possible to apply on the currently edited text morph"
	
	^  #(normal bold italic narrow underlined struckOut).	
	
]

{ #category : #accessing }
RubTextEditor >> emphasisHere [
	^ textArea emphasisHere
]

{ #category : #'editing keys' }
RubTextEditor >> encloseWith: aMatchingPair [
	"Insert or remove bracket characters around the current selection."

	| left right startIndex stopIndex oldSelection text newString |
	self closeTypeIn.
	startIndex := self startIndex.
	stopIndex := self stopIndex.
	oldSelection := self selection.
	
	left := aMatchingPair key.
	right := aMatchingPair value.
	text := self text.
	((startIndex > 1 and: [stopIndex <= text size])
			and: [ (text at: startIndex-1) = left and: [(text at: stopIndex) = right]])
		ifTrue: [
			"already enclosed; strip off brackets"
			newString := (self shouldEscapeCharacter: left)
						 ifTrue: [ self unescapeCharacter: left inString: oldSelection ] 
						 ifFalse: [ oldSelection ].
			self selectFrom: startIndex-1 to: stopIndex.
			self replaceSelectionWith: newString ]
		ifFalse: [
			" Checks if the characters inside the selection need to be escaped or not. "
			newString := (self shouldEscapeCharacter: left)
						 ifTrue: [ self surroundString: oldSelection withCharacter: left ] 
						 ifFalse: [ "not enclosed; enclose by matching brackets"
									  (String with: left), oldSelection string, (String with: right) ].
			self replaceSelectionWith:
				(Text string: newString attributes: self emphasisHere).
			"we add the difference of the newString and the oldSelection, here, to ajust to eventual nesting. The 2 corrsponds to se left and right characters added which are not in oldSelection."
			self selectFrom: startIndex+1 to: stopIndex+(newString size - oldSelection size - 2)].
	^true
]

{ #category : #private }
RubTextEditor >> encompassParagraph: anInterval [
	"Return an interval that includes anInterval, and that comprises one or several whole paragraphs in the receiver.
	Answer starts at the position following a cr (or eventually 1) and ends at a cr (or eventually at self size)"
	^ self string encompassParagraph: anInterval

]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> escape [ 
	textArea escapePressed .
	
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> escape: aKeyboardEvent [
	textArea escapePressed.
	^ false  
]

{ #category : #nesting }
RubTextEditor >> escapeCharacter: aCharacter inString: aString [
	" To escape them, we double the character every time it's encountered"
	| result stream |
	result := WriteStream with: ''.
	stream := ReadStream on: aString string.
	[ stream atEnd ] whileFalse: 
		[ result nextPutAll: (stream upTo: aCharacter).
		stream peekBack = aCharacter ifTrue: [result nextPut: aCharacter]. 
		stream atEnd ifFalse: [ result nextPut: aCharacter ]
						 ifTrue: [ stream peekBack = aCharacter ifTrue: [result nextPut: aCharacter] ].].
	^result contents.
]

{ #category : #'menu messages' }
RubTextEditor >> exchange [
	"See comment in exchangeWith:"

	self exchangeWith: self editingState previousInterval
]

{ #category : #'editing keys' }
RubTextEditor >> exchange: aKeyboardEvent [
	"Exchange the current and prior selections."

	self closeTypeIn.
	self exchange.
	^true
]

{ #category : #private }
RubTextEditor >> exchangeWith: prior [
	"If the prior selection is non-overlapping and legal, exchange the text of
	 it with the current selection and leave the currently selected text selected
	 in the location of the prior selection (or leave a caret after a non-caret if it was
	 exchanged with a caret).  If both selections are carets, flash & do nothing.
	 Don't affect the paste buffer.  Undoer: itself; Redoer: Undoer."

	| start stop before currSelection priorSelection delta redoArgs altInterval undoArgs |
	start := self startIndex.
	stop := self stopIndex - 1.
	((prior first <= prior last) | (start <= stop) "Something to exchange" and:
			[self isDisjointFrom: prior])
		ifTrue:
			[before := prior last < start.
			currSelection := self selection.
			priorSelection := self text copyFrom: prior first to: prior last.
			delta := before ifTrue: [0] ifFalse: [priorSelection size - currSelection size].
			self zapSelectionWith: priorSelection.
			redoArgs := { prior. start to: stop}.
						
			self selectFrom: prior first + delta to: prior last + delta.
			delta := before ifTrue: [stop - prior last] ifFalse: [start - prior first].
			self zapSelectionWith: currSelection.
			
			altInterval := prior first + delta to: prior last + delta.
			undoArgs := {altInterval. self startIndex to: self stopIndex - 1}.
			"self undoer: #exchangeWith: with: altInterval."
			prior first > prior last ifTrue: [self selectAt: self editingState previousInterval last + 1].
			self 
				redoArray: { textArea. #undoRedoExchange:with:. redoArgs} 
				undoArray: {textArea. #undoRedoExchange:with:. undoArgs}]
		ifFalse:
			[textArea flash]
]

{ #category : #'undo-redo private' }
RubTextEditor >> exploreUndoManager: aKeyboardEvent [
	^ self editingState exploreUndoManager: aKeyboardEvent
]

{ #category : #'menu messages' }
RubTextEditor >> find [
	"Prompt the user for a string to search for, and search the receiver from the current selection onward for it."
	textArea openFindDialog
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> find: aKeyboardEvent [
	"Prompt the user for what to find, then find it, searching from the current selection onward."

	self closeTypeIn.
	self find.
	^ true
]

{ #category : #'menu messages' }
RubTextEditor >> findAgain [

	"Find the text-to-find again."

	| where |

	where := self findReplaceService findNext.
	where ifNil: [ self flash ] ifNotNil: [ self selectInterval: where ].
	^ where
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> findAgain: aKeyboardEvent [ 
	"Find the desired text again."
	self closeTypeIn.
	self findAgain.
	^ true
]

{ #category : #'menu messages' }
RubTextEditor >> findAgainAndReplace [
	"Find the text-to-find again and eventually replace it with the current replace text."

	| where |

	where := self findAgain.
	where
		ifNotNil: [ self findReplaceService replaceText ifNotEmpty: [ :rt | self replaceSelectionWith: rt ] ]
]

{ #category : #'find-select' }
RubTextEditor >> findAll: aRegex endingAt: searchIdx [ 
	| ranges |
	ranges := aRegex matchingRangesIn: (self string copyFrom: 1 to: searchIdx).
	^ ranges 
			
]

{ #category : #'find-select' }
RubTextEditor >> findAll: aRegex startingAt: searchIdx [ 
	| ranges |
	ranges := aRegex matchingRangesIn: (self string copyFrom: searchIdx to: self string size).
	^ ranges collect: [:i | i + searchIdx - 1]
			
]

{ #category : #'find-select' }
RubTextEditor >> findAndSelect: aRegex startingAt: anIndex searchBackwards: searchBackwards [
	| oldSelectionInterval where |
	self closeTypeIn.
	oldSelectionInterval := self selectionInterval.
	self selectInvisiblyFrom: anIndex to: anIndex - 1.
	where :=  searchBackwards
		ifTrue: [self findAndSelectPreviousOccurrenceOf: aRegex]
		ifFalse: [self findAndSelectNextOccurrenceOf: aRegex].
	where ifNil: [self selectInterval: oldSelectionInterval].
	^ where
]

{ #category : #generated }
RubTextEditor >> findAndSelectNextOccurenceOf: aRegex [

	self
		deprecated: 'Use #findAndSelectPreviousOccurrenceOf: instead'
		transformWith: '`@rec findAndSelectNextOccurenceOf: `@arg'
			-> '`@rec findAndSelectPreviousOccurrenceOf: `@arg'.
	^ self findAndSelectPreviousOccurrenceOf: aRegex
]

{ #category : #'find-select' }
RubTextEditor >> findAndSelectNextOccurrenceOf: aRegex [
	| where |
	where := self findNext: aRegex startingAt: self stopIndex.
	where ifNotNil: [self selectInterval: where].
	^ where
]

{ #category : #'find-select' }
RubTextEditor >> findAndSelectPreviousOccurrenceOf: aRegex [

	| where |
	where := self findPrevious: aRegex startingAt: self startIndex.
	where ifNotNil: [ self selectInterval: where ].
	^ where
]

{ #category : #'find-select' }
RubTextEditor >> findNext: aRegex startingAt: searchIdx [ 
	| strm match range |
	strm := (self string copyFrom: searchIdx to: self string size) readStream.
	aRegex searchStream: strm.
	match := aRegex subexpression: 1.
	match ifNotNil: [range := (aRegex position + searchIdx - match size) to: (aRegex position + searchIdx - 1)].
	^ range
]

{ #category : #'find-select' }
RubTextEditor >> findNextString: aSubstring startingAt: searchIdx [ 
	| idx |
	idx := self string findString: aSubstring startingAt: searchIdx.
	^ idx isZero ifFalse: [idx to: idx + aSubstring size - 1]
			
]

{ #category : #'find-select' }
RubTextEditor >> findPrevious: aRegex startingAt: searchIdx [ 
	| allRanges |
	allRanges := self findAll: aRegex endingAt: searchIdx.
	^ allRanges notEmpty
		ifTrue: [allRanges last].

]

{ #category : #accessing }
RubTextEditor >> findRegex [
	^ self findReplaceService findRegex
]

{ #category : #'find-select' }
RubTextEditor >> findReplaceService [
	^ self textArea findReplaceService
]

{ #category : #'find-select' }
RubTextEditor >> findText [
	^ self findReplaceService findText
]

{ #category : #'find-select' }
RubTextEditor >> findText: aStringOrText [
	self findReplaceService findText: aStringOrText 
]

{ #category : #accessing }
RubTextEditor >> findText: aString isRegex: aBoolean [
	self findReplaceService findText: aString isRegex: aBoolean
]

{ #category : #private }
RubTextEditor >> findText: aString isRegex: isRegex caseSensitive: caseSensitive entireWordsOnly: entireWordsOnly [
	self findReplaceService findText: aString isRegex: isRegex caseSensitive: caseSensitive entireWordsOnly: entireWordsOnly

]

{ #category : #private }
RubTextEditor >> findText: aString isRegex: isRegex entireWordsOnly: entireWordsOnly [
	self findReplaceService findText: aString isRegex: isRegex entireWordsOnly: entireWordsOnly

]

{ #category : #displaying }
RubTextEditor >> flash [
	^ textArea flash
]

{ #category : #private }
RubTextEditor >> focusChanged [
	"Nothing to do by default"
]

{ #category : #accessing }
RubTextEditor >> fontToUse [
	^ self text fontAt: self startIndex
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> forwardDelete: aKeyboardEvent [
	"Delete forward over the next character"

	self closeTypeIn.
	self hasSelection
		ifFalse: [ 
			| idx1 idx2 |
			idx1 := self startIndex min: self stopIndex.
			idx2 := self stopIndex max: self startIndex.
			aKeyboardEvent shiftPressed
				ifTrue: [ idx2 := self nextWord: idx1 ]
				ifFalse: [ idx2 := idx2 + 1 ].
			self selectInvisiblyFrom: idx1 to: idx2 - 1 ].
	self addDeleteSelectionUndoRecord.
	self zapSelectionWith: self nullText.
	^ false
]

{ #category : #nesting }
RubTextEditor >> getEscapeCharacterFromAst: anAST [
	"If there is no node (empty textArea) there is no nesting to be had."
	anAST ifNil: [ ^nil ].
	anAST isCommentNode ifTrue: [ ^$" ].
	(anAST isLiteralNode and: [anAST value isString]) ifTrue: [ ^$' ].
	^nil.
]

{ #category : #'accessing-selection' }
RubTextEditor >> getHighlightInterval [
	"Answer the interval that is or should be highligted."

	^ self hasSelection 
		ifTrue: [ self selectionInterval ]
		ifFalse: [ self computeSelectionIntervalForCurrentLine ]
]

{ #category : #'accessing-selection' }
RubTextEditor >> hasCursor [
	^self markBlock = self pointBlock
]

{ #category : #testing }
RubTextEditor >> hasError [
	^ false 
]

{ #category : #'accessing-selection' }
RubTextEditor >> hasSelection [
	^ self pointIndex ~= self markIndex
]

{ #category : #'menu messages' }
RubTextEditor >> highlightAndEmptyCheck: returnBlock [

	| selectionInterval |
	selectionInterval := self getHighlightInterval.
	selectionInterval ifEmpty: [ textArea flash.  ^ returnBlock value ].
	self highlightInterval: selectionInterval
]

{ #category : #'new selection' }
RubTextEditor >> highlightInterval: anInterval [

	self textArea 
		ensureAndGetNewHighlightSegmentFrom: anInterval first 
		to: anInterval last + 1.
]

{ #category : #'accessing-selection' }
RubTextEditor >> highlightedTextAsStream [
	"Answer a ReadStream on the text in the paragraph that is currently highlighted."

	| highlightedInterval |
	highlightedInterval := self getHighlightInterval.
	^ (self string copyFrom: highlightedInterval first to: highlightedInterval last) readStream
]

{ #category : #'new selection' }
RubTextEditor >> hoverHighlightInterval: anInterval [

	self textArea 
		ensureAndGetNewHoverHighlightSegmentFrom: anInterval first 
		to: anInterval last + 1.
]

{ #category : #'editing keys' }
RubTextEditor >> inOutdent: aKeyboardEvent delta: delta [
	"Add/remove a tab at the front of every line occupied by the selection. 
	Derived from work by Larry Tesler back in December 1985."

	| cr realStart realStop lines startLine stopLine start stop adjustStart indentation size numLines inStream newString outStream |
	cr := Character cr.

	"Operate on entire lines, but remember the real selection for re-highlighting later"
	realStart := self startIndex.
	realStop := self stopIndex - 1.

	"Special case a caret on a line of its own, including weird case at end of paragraph"
	(realStart > realStop and: [
				realStart < 2 or: [(self string at: realStart - 1) == cr]])
		ifTrue:
			[delta < 0
				ifTrue: [
					textArea flash]
				ifFalse: [
					self replaceSelectionWith: Character tab asSymbol asText.
					self selectAt: realStart + 1].
			^true].

	lines := self paragraph lines.
	startLine := self paragraph lineIndexOfCharacterIndex: realStart.
	stopLine := self paragraph lineIndexOfCharacterIndex: (realStart max: realStop).
	start := (lines at: startLine) first.
	stop := (lines at: stopLine) last.
	
	"Pin the start of highlighting unless the selection starts a line"
	adjustStart := realStart > start.

	"Find the indentation of the least-indented non-blank line; never outdent more"
	indentation := (startLine to: stopLine) inject: 1000 into: [ :previousValue :each |
		previousValue min: (self paragraph indentationOfLineIndex: each ifBlank: [ :tabs | 1000 ])].			

	size :=  stop + 1 - start.
	numLines := stopLine + 1 - startLine.
	inStream := ReadStream on: self string from: start to: stop.

	newString := String new: size + ((numLines * delta) max: 0).
	outStream := ReadWriteStream on: newString.

	"This subroutine does the actual work"
	self indent: delta fromStream: inStream toStream: outStream.

	"Adjust the range that will be highlighted later"
	adjustStart ifTrue: [realStart := (realStart + delta) max: start].
	realStop := realStop + outStream position - size.

	"Prepare for another iteration"
	indentation := indentation + delta.
	size := outStream position.
	inStream := outStream setFrom: 1 to: size.

	outStream == nil
		ifTrue: 	"tried to outdent but some line(s) were already left flush"
			[textArea flash]
		ifFalse:
			[self selectInvisiblyFrom: start to: stop.
			size = newString size ifFalse: [newString := outStream contents].
			self replaceSelectionWith: newString asText].
	self selectFrom: realStart to: realStop. 	"highlight only the original range"
	^ true
]

{ #category : #'editing keys' }
RubTextEditor >> indent: aKeyboardEvent [
	"Add a tab at the front of every line occupied by the selection."

	^ self inOutdent: aKeyboardEvent delta: 1
]

{ #category : #private }
RubTextEditor >> indent: delta fromStream: inStream toStream: outStream [
	"Append the contents of inStream to outStream, adding or deleting delta or -delta
	 tabs at the beginning, and after every CR except a final CR.  Do not add tabs
	 to totally empty lines, and be sure nothing but tabs are removed from lines."

	| ch skip cr tab prev atEnd |
	cr := Character cr.
	tab := Character tab.
	delta > 0
		ifTrue: "shift right"
			[prev := cr.
			 [ch := (atEnd := inStream atEnd) ifTrue: [cr] ifFalse: [inStream next].
			  (prev == cr and: [ch ~~ cr]) ifTrue:
				[delta timesRepeat: [outStream nextPut: tab]].
			  atEnd]
				whileFalse:
					[outStream nextPut: ch.
					prev := ch]]
		ifFalse: "shift left"
			[skip := delta. "a negative number"
			 [inStream atEnd] whileFalse:
				[((ch := inStream next) == tab and: [skip < 0]) ifFalse:
					[outStream nextPut: ch].
				skip := ch == cr ifTrue: [delta] ifFalse: [skip + 1]]]
]

{ #category : #keymapping }
RubTextEditor >> initializeShortcuts: aKMDispatcher [
	aKMDispatcher attachCategory: RubTextEditor name
]

{ #category : #'new selection' }
RubTextEditor >> insertAndSelect: aString at: anInteger [

	self replace: (anInteger to: anInteger - 1)
		with: (Text string: (' ' , aString)
					attributes: self emphasisHere)
		and: [self ]
]

{ #category : #testing }
RubTextEditor >> isCaretBehindChar [
	"Return true if the cursor position is after an alphanumeric character, otherwise false."

	| cursorPosition |
	^(cursorPosition := self startIndex) >= 2 and: [
		(self text at: cursorPosition - 1) isAlphaNumeric ]
]

{ #category : #private }
RubTextEditor >> isDisjointFrom: anInterval [
	"Answer true if anInterval is a caret not touching or within the current
	 interval, or if anInterval is a non-caret that does not overlap the current
	 selection."

	| fudge |
	fudge := anInterval size = 0 ifTrue: [1] ifFalse: [0].
	^(anInterval last + fudge < self startIndex or:
			[anInterval first - fudge >= self stopIndex])

]

{ #category : #testing }
RubTextEditor >> isScripting [
	^ false 
]

{ #category : #testing }
RubTextEditor >> isSmalltalkEditor [
	^ false 
]

{ #category : #testing }
RubTextEditor >> isTextEditor [
	^ true 
]

{ #category : #'typing support' }
RubTextEditor >> keyDown: aKeyboardEvent [
	textArea announce: ((RubKeystroke with: aKeyboardEvent) morph: self).
	(self dispatch: aKeyboardEvent) ifTrue: [
		self doneTyping.
		self storeSelectionInText.
		textArea scrollSelectionIntoView: nil ]
]

{ #category : #'typing support' }
RubTextEditor >> keystroke: aKeyboardEvent [
	textArea announce: ((RubKeystroke with: aKeyboardEvent) morph: self).
	self normalCharacter: aKeyboardEvent.
	"normal character"
	self openTypeIn.
	self hasSelection
		ifTrue: [ 
			"save highlighted characters"
			self editingState previousInterval: self selectionInterval].
	"Notice selection changed"
	self unselect.
	self storeSelectionInText
]

{ #category : #accessing }
RubTextEditor >> lastFont [	
	"Answer the Font for to be used if positioned at the end of the text"
	| t |	
	t := self text.	
	^ t fontAt: t size + 1
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> lf: aKeyboardEvent [ 
	"Append a line feed character to the stream of characters."

	self addString: Character lf asString.
	^false
]

{ #category : #'menu messages' }
RubTextEditor >> lineSelectAndEmptyCheck: returnBlock [
	"If the current selection is an insertion point, expand it to be the entire current line; if after that's done the selection is still empty, then evaluate the returnBlock, which will typically consist of '[^ self]' in the caller -- check senders of this method to understand this."

	self selectLine.  "if current selection is an insertion point, then first select the entire line in which occurs before proceeding"
	self hasSelection ifFalse: [textArea flash.  ^ returnBlock value]
]

{ #category : #private }
RubTextEditor >> lines [
	"Compute lines based on logical line breaks, not optical (which may change due to line wrapping of the editor).
	Subclasses using kinds of Paragraphs can instead use the service provided by it.
	"
	| lines string index lineIndex stringSize |
	string := self string.
	"Empty strings have no lines at all. Think of something."
	string isEmpty ifTrue:[^{#(1 0 0)}].
	stringSize := string size.
	lines := OrderedCollection new: (string size // 15).
	index := 0.
	lineIndex := 0.
	string linesDo:[:line |
		lines addLast: (Array
			with: (index := index + 1)
			with: (lineIndex := lineIndex + 1)
			with: (index := index + line size min: stringSize))].
	"Special workaround for last line empty."
	string last == Character cr
	"lines last last < stringSize" ifTrue:[lines addLast:{stringSize +1. lineIndex+1. stringSize}].
	^lines
]

{ #category : #'editing keys' }
RubTextEditor >> makeCapitalized: aKeyboardEvent [
	"Force the current selection to uppercase.  Triggered by Cmd-z."

	| prev |
	self closeTypeIn.
	prev := $-.  "not a letter"
	self replaceSelectionWith: (Text fromString:
		(self selection string collect:
			[:c | prev := prev isLetter ifTrue: [c asLowercase] ifFalse: [c asUppercase]])).
	^ true
]

{ #category : #'editing keys' }
RubTextEditor >> makeLowercase: aKeyboardEvent [
	"Force the current selection to lowercase.  Triggered by Cmd-X."

	self closeTypeIn.
	self replaceSelectionWith: (Text fromString: (self selection string asLowercase)).
	^ true
]

{ #category : #'editing keys' }
RubTextEditor >> makeUppercase: aKeyboardEvent [
	"Force the current selection to uppercase.  Triggered by Cmd-Y."

	self closeTypeIn.
	self replaceSelectionWith: (Text fromString: (self selection string asUppercase)).
	^ true
]

{ #category : #'accessing-selection' }
RubTextEditor >> markBlock [
	^ textArea markBlock
]

{ #category : #'accessing-selection' }
RubTextEditor >> markIndex [
	^ textArea markIndex
]

{ #category : #'accessing-selection' }
RubTextEditor >> markIndex: markIndex pointIndex: pointIndex [
	textArea markIndex: markIndex pointIndex: pointIndex

]

{ #category : #accessing }
RubTextEditor >> model [
	^ textArea model
]

{ #category : #accessing }
RubTextEditor >> morph [
	^ textArea
]

{ #category : #private }
RubTextEditor >> moveCursor: directionBlock forward: forward specialBlock: specialBlock event: aKeyboardEvent [
	"Private - Move cursor.
	directionBlock is a one argument Block that computes the new Position from a given one.
	specialBlock is a one argumentBlock that computes the new position from a given one under the alternate semantics.
	Note that directionBlock always is evaluated first."
	| shift indices newPosition |
	shift := aKeyboardEvent shiftPressed.
	indices := self setIndices: shift forward: forward.
	newPosition := directionBlock value: (indices at: #moving).
	(aKeyboardEvent commandKeyPressed or: [ aKeyboardEvent controlKeyPressed ])
		ifTrue: [newPosition := specialBlock value: newPosition].
	shift
		ifTrue: [self selectMark: (indices at: #fixed) point: newPosition - 1]
		ifFalse: [self selectAt: newPosition].
	self setEmphasisHereFromTextForward: forward
]

{ #category : #nesting }
RubTextEditor >> nestingForPaste: aString with: aCharacter [ 
	" To escape them, we double the character every time it's encountered"
	| result stream |
	result := WriteStream with: ''.
	stream := ReadStream on: aString string.
	[ stream atEnd ] whileFalse: 
		[ result nextPutAll: (stream upTo: aCharacter).
		stream peekBack = aCharacter ifTrue: [result nextPut: aCharacter]. 
		stream atEnd ifFalse: [ result nextPut: aCharacter ]
						 ifTrue: [ stream peekBack = aCharacter ifTrue: [result nextPut: aCharacter] ].].
	^result contents.
]

{ #category : #keymapping }
RubTextEditor >> newDefaultKeymappingIndex [
	defaultKeymappingIndex := IdentityDictionary new.
	defaultKeymappingIndex at: #command put: self defaultCommandKeymapping.
	^ defaultKeymappingIndex 
]

{ #category : #accessing }
RubTextEditor >> nextCharacterIfAbsent: aBlock [

	^ self text at: self startIndex ifAbsent: aBlock
]

{ #category : #private }
RubTextEditor >> nextWord: position [
	| string index  initialIsAlphaNumeric |
	string := self string.
	index := position.
	position >= string size ifTrue: [ ^ position ].
	initialIsAlphaNumeric := (string at: index - 1) isAlphaNumeric.

	[(index <= string size) 
		and: [(string at: index) isAlphaNumeric = initialIsAlphaNumeric]]
			whileTrue: [index := index + 1].
	^ index
]

{ #category : #'editing keys' }
RubTextEditor >> noop: aKeyboardEvent [ 
	"Unimplemented keyboard command; just ignore it."

	^ true
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> normalCharacter: aKeyboardEvent [ 
	"A nonspecial character is to be added to the stream of characters."

	self hasSelection 
		ifTrue: [self addDeleteSelectionUndoRecord].
	self addString: aKeyboardEvent keyCharacter asString.
	^false
]

{ #category : #private }
RubTextEditor >> nullText [

	^Text string: '' attributes: self emphasisHere
]

{ #category : #'menu messages' }
RubTextEditor >> offerFontMenu [
	"Present a menu of available fonts, and if one is chosen, apply it to the current selection.  
	Use only names of Fonts of this paragraph  "
	
	^self changeTextFont
]

{ #category : #'editing keys' }
RubTextEditor >> offerFontMenu: aKeyboardEvent [ 
	"The user typed the command key that requests a font change; Offer the font menu."

	self closeTypeIn.
	self offerFontMenu.
	^ true
]

{ #category : #deprecated }
RubTextEditor >> offerMenuFromEsc: aKeyboardEvent [
	"The escape key was hit while the receiver has the keyboard focus; take action"
 	textArea activeHand lastEvent shiftPressed 
		ifFalse: [ self raiseContextMenu: aKeyboardEvent].
	^ false 	
]

{ #category : #'typing support' }
RubTextEditor >> openTypeIn [
	"Set up startOfTyping to keep track of the leftmost backspace.
	 You can't undo typing until after closeTypeIn."

	self startOfTyping 
		ifNil: [self editingState previousInterval: (1 to: 0).
			self startOfTyping: self startIndex]
]

{ #category : #accessing }
RubTextEditor >> openingDelimiters [
	^ '([{'

]

{ #category : #'accessing-selection' }
RubTextEditor >> oppositeDelimiterSelection [
	^ RubTextSelectionColor oppositeDelimiterSelection
]

{ #category : #'editing keys' }
RubTextEditor >> outdent: aKeyboardEvent [
	"Remove a tab from the front of every line occupied by the selection."

	^ self inOutdent: aKeyboardEvent delta: -1
]

{ #category : #private }
RubTextEditor >> pageHeight [
	| howManyLines visibleHeight totalHeight ratio |
	howManyLines := self paragraph numberOfLines.
	visibleHeight := self visibleHeight.
	totalHeight := self totalTextHeight.
	ratio := visibleHeight / totalHeight.
	^(ratio * howManyLines) rounded - 2
]

{ #category : #private }
RubTextEditor >> paragraph [
	^ textArea paragraph
]

{ #category : #'menu messages' }
RubTextEditor >> paste [
	"Paste the text from the shared buffer over the current selection and 
	redisplay if necessary.  Undoer & Redoer: undoAndReselect."

	self replace: self selectionInterval with: self clipboardText and:
		[self selectAt: self pointIndex]
]

{ #category : #'editing keys' }
RubTextEditor >> paste: aKeyboardEvent [ 
	"Replace the current text selection by the text in the shared buffer."

	self closeTypeIn.
	self paste.
	^true
]

{ #category : #'menu messages' }
RubTextEditor >> pasteRecent [
	"Paste an item chose from RecentClippings."

	| clipping |
	(clipping := Clipboard chooseRecentClipping) ifNil: [^ self].
	Clipboard clipboardText: clipping.
	^ self paste
]

{ #category : #'typing support' }
RubTextEditor >> performCmdActionsWith: aKeyboardEvent shifted: aBoolean return: return [
	| key actions action|
	key := aKeyboardEvent key.
	actions := self cmdActions.
	action := (actions at: key ifAbsent: [ ^ false ]).
	return value: (self perform: action with: aKeyboardEvent).
]

{ #category : #'accessing-selection' }
RubTextEditor >> pointBlock [
	^ textArea pointBlock
]

{ #category : #'accessing-selection' }
RubTextEditor >> pointIndex [
	^ textArea pointIndex
]

{ #category : #accessing }
RubTextEditor >> previousCharacterIfAbsent: aBlock [

	^ self text at: self startIndex - 1 ifAbsent: aBlock
]

{ #category : #private }
RubTextEditor >> previousWord: position [
	| string index  initialIsAlphaNumeric |
	string := self string.
	index := position.
	position <= 1 ifTrue: [ ^ position ].
	initialIsAlphaNumeric := (string at: index) isAlphaNumeric.
	[index := index - 1] doWhileTrue:
		[(index > 0) and: [(string at: index) isAlphaNumeric = initialIsAlphaNumeric]].
	^ index + 1
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> raiseContextMenu: aKeyboardEvent [

	^ textArea yellowButtonActivity: textArea activeHand lastEvent shiftPressed
]

{ #category : #'accessing-selection' }
RubTextEditor >> recomputeSelection [
	"The same characters are selected but their coordinates may have changed.
	Redetermine the selection according to the start and stop block indices; 
	do not highlight."

	textArea recomputeSelection
]

{ #category : #'menu messages' }
RubTextEditor >> redo [
	"redo previous edit"

	self editingState redo ifFalse: [textArea flash]. 

]

{ #category : #'editing keys' }
RubTextEditor >> redo: aKeyboardEvent [ 
	"Redo the last edit."

	self redo.
	^true
]

{ #category : #'undo-redo private' }
RubTextEditor >> redoArray: doArray undoArray: undoArray [
	self editingState redoArray: doArray undoArray: undoArray
]

{ #category : #'undoers-redoers' }
RubTextEditor >> redoTypeIn: aText interval: anInterval [
	self selectInterval: anInterval.
	self replace: self selectionInterval with: aText and:
		[self selectInterval: (anInterval first to: anInterval first + aText size - 1)].

]

{ #category : #accessing }
RubTextEditor >> replace: xoldInterval with: newText and: selectingBlock [ 
	"Replace the text in oldInterval with newText and
	execute selectingBlock to establish the new selection.
	Create an UndoRecord to allow perfect undoing."
	| prevSel currInterval |
	self selectInterval: xoldInterval.
	prevSel := self selection.
	currInterval := self selectionInterval.
	self editingState previousInterval: currInterval.
	self zapSelectionWith: newText.
	selectingBlock value.
	((prevSel isEmpty and: [newText isEmpty]) and: [currInterval size < 1]) 
		ifFalse: [self 
			redoArray: {textArea. #redoTypeIn:interval:. {newText. currInterval}} 
			undoArray: {textArea. #undoTypeIn:interval:. {prevSel. currInterval first to: currInterval first + newText size - 1}}]
]

{ #category : #'find-select' }
RubTextEditor >> replaceAll: aRegex with: aText [
	self
		undoRedoTransaction: [ 
			| selec ranges |
			selec := self selectionInterval.
			ranges := self findAll: aRegex startingAt: selec first.
			ranges
				reverseDo: [ :r | 
					self selectInvisiblyFrom: r first to: r last.
					self replaceSelectionWith: aText ].
			self selectInterval: selec ]
]

{ #category : #'find-select' }
RubTextEditor >> replaceAll: aRegex with: aText startingAt: startIdx [
	self
		undoRedoTransaction: [ 
			| selec ranges |
			selec := self selectionInterval.
			ranges := self findAll: aRegex startingAt: startIdx.
			ranges
				reverseDo: [ :r | 
					self selectInvisiblyFrom: r first to: r last.
					self replaceSelectionWith: aText ].
			self selectInterval: selec ]
]

{ #category : #accessing }
RubTextEditor >> replaceSelectionWith: aText [
	self replace: self selectionInterval with: aText and: []

]

{ #category : #accessing }
RubTextEditor >> replaceTextFrom: start to: stop with: aText [
	self replace: (start to: stop - 1) with: aText and: []

]

{ #category : #private }
RubTextEditor >> resetState [
	"Establish the initial conditions for editing the paragraph: place cursor 
	before first character, set the emphasis to that of the first character"

	| b |
	b := self paragraph defaultCharacterBlock.
	textArea markBlock: b pointBlock: b copy.
	self editingState startOfTyping: nil.
	self editingState previousInterval: (1 to: 0).
	self setEmphasisHereFromText
]

{ #category : #private }
RubTextEditor >> sameColumn: start newLine: lineBlock forward: isForward [
	"Private - Compute the index in my text
	with the line number derived from lineBlock,"
	" a one argument block accepting the old line number.
	The position inside the line will be preserved as good as possible"
	"The boolean isForward is used in the border case to determine if
	we should move to the beginning or the end of the line."
	| column currentLine offsetAtTargetLine targetEOL lines numberOfLines currentLineNumber targetLineNumber |
	self walkAlongDisplayedLine
		ifTrue: [lines := self paragraph lines.
			numberOfLines := self paragraph numberOfLines.
			currentLineNumber := self paragraph lineIndexOfCharacterIndex: start.
			currentLine := lines at: currentLineNumber]
		ifFalse: [lines := self lines.
			numberOfLines := lines size.
			currentLine := lines
				detect:[:lineInterval | lineInterval last >= start]
				ifNone:[lines last].
			currentLineNumber := currentLine second].
	column := start - currentLine first.
	targetLineNumber := ((lineBlock value: currentLineNumber) max: 1) min: numberOfLines.
	offsetAtTargetLine := (lines at: targetLineNumber) first.
	targetEOL := (lines at: targetLineNumber) last + (targetLineNumber = numberOfLines ifTrue:[1]ifFalse:[0]).
	targetLineNumber = currentLineNumber
	"No movement or movement failed. Move to beginning or end of line."
		ifTrue:[^isForward
			ifTrue:[targetEOL]
			ifFalse:[offsetAtTargetLine]].
	^offsetAtTargetLine + column min: targetEOL.
]

{ #category : #'menu messages' }
RubTextEditor >> saveContentsInFile [
	"Save the receiver's contents string to a file, prompting the user for a file-name.  Suggest a reasonable file-name."

	| fileName stringToSave parentWindow labelToUse suggestedName lastIndex |
	stringToSave := self string. 
	stringToSave size = 0 ifTrue: [^self inform: 'nothing to save.'].
	parentWindow := self model dependents 
				detect: [:dep | dep isKindOf: SystemWindow]
				ifNone: [nil].
	labelToUse := parentWindow ifNil: ['Untitled']
				ifNotNil: [parentWindow label].
	suggestedName := nil.
	#(#('Decompressed contents of: ' '.gz')) do: 
			[:leaderTrailer | 
			"can add more here..."

			(labelToUse beginsWith: leaderTrailer first) 
				ifTrue: 
					[suggestedName := labelToUse copyFrom: leaderTrailer first size + 1
								to: labelToUse size.
					(labelToUse endsWith: leaderTrailer last) 
						ifTrue: 
							[suggestedName := suggestedName copyFrom: 1
										to: suggestedName size - leaderTrailer last size]
						ifFalse: 
							[lastIndex := suggestedName lastIndexOf: $. ifAbsent: [0].
							(lastIndex = 0 or: [lastIndex = 1]) 
								ifFalse: [suggestedName := suggestedName copyFrom: 1 to: lastIndex - 1]]]].
	suggestedName ifNil: [suggestedName := labelToUse , '.text'].
	fileName := UIManager default request: 'File name?'
				initialAnswer: suggestedName.
	fileName isEmptyOrNil
		ifFalse: [ fileName asFileReference writeStreamDo: [ :out | out nextPutAll: stringToSave ] ]
]

{ #category : #scrolling }
RubTextEditor >> scrollBy: ignore [ 
	"Ignore scroll requests."

]

{ #category : #'typing/selecting keys' }
RubTextEditor >> search: aKeyboardEvent [
	"Invoked by Ctrl-S.  Same as 'again', but always uses the existing findText
	 from current FindReplaceService"

	self closeTypeIn.
	self findAgain.
	^true
]

{ #category : #'accessing-selection' }
RubTextEditor >> select [
	"select what and how ?"
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> selectAll [

	self selectFrom: 1 to: self string size
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> selectAll: aKeyboardEvent [ 
	"select everything"

	self closeTypeIn.
	self selectFrom: 1 to: self string size.
	^ true
]

{ #category : #'new selection' }
RubTextEditor >> selectAt: characterIndex [ 
	"Place the caret before the character at characterIndex.
	 Be sure it is in view."

	self selectFrom: characterIndex to: characterIndex - 1
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> selectCurrentTypeIn: aKeyboardEvent [ 
	"Select what would be replaced by an undo (e.g., the last typeIn)."

	self closeTypeIn.
	self selectInterval: self editingState previousInterval.
	^ true
]

{ #category : #'new selection' }
RubTextEditor >> selectFrom: start to: stop [
	"Select the specified characters inclusive."
	self selectInvisiblyFrom: start to: stop.
	self closeTypeIn.
	self storeSelectionInText.
	"Preserve current emphasis if selection is empty"
	stop > start 
		ifTrue: [self setEmphasisHereFromTextForward: true ]
]

{ #category : #'new selection' }
RubTextEditor >> selectInterval: anInterval [
	"Select the specified characters inclusive.
	 Be sure the selection is in view."

	self selectFrom: anInterval first to: anInterval last
]

{ #category : #'new selection' }
RubTextEditor >> selectInvisiblyAt: characterIndex [ 
	"Place the caret before the character at characterIndex.
	 Be sure it is in view but vithout any further action."
	
	self selectInvisiblyFrom: characterIndex to:  characterIndex - 1

]

{ #category : #'new selection' }
RubTextEditor >> selectInvisiblyFrom: start to: stop [
	"Select the designated characters, inclusive.  Make no visual changes."

	self markIndex: start pointIndex: stop + 1
]

{ #category : #'new selection' }
RubTextEditor >> selectInvisiblyMark: mark point: point [
	"Select the designated characters, inclusive.  Make no visual changes."

	self markIndex: mark pointIndex: point + 1
]

{ #category : #'new selection' }
RubTextEditor >> selectLine [
	"Make the receiver's selection, if it currently consists of an insertion point only, encompass the current line."
	self hasSelection ifTrue: [^self].
	self selectInterval: self computeSelectionIntervalForCurrentLine
]

{ #category : #'new selection' }
RubTextEditor >> selectMark: mark point: point [
	"Select the specified characters inclusive.
	 Be sure the selection is in view."

	(mark =  self markIndex and: [point + 1 = self pointIndex]) ifFalse:
		[self deselect.
		self selectInvisiblyMark: mark point: point]
]

{ #category : #'new selection' }
RubTextEditor >> selectWord [
	"Select delimited text or word--the result of double-clicking."

	| openDelimiter closeDelimiter direction match level leftDelimiters rightDelimiters
	string here hereChar start stop |
	string := self string.
	here := self pointIndex.
	(here between: 2 and: string size)
		ifFalse: ["if at beginning or end, select entire string"
			^self selectLine].
	leftDelimiters := '([{<''"
'.
	rightDelimiters := ')]}>''"
'.
	openDelimiter := string at: here - 1.
	match := leftDelimiters indexOf: openDelimiter.
	match > 0
		ifTrue: 
			["delimiter is on left -- match to the right"
			start := here.
			direction := 1.
			here := here - 1.
			closeDelimiter := rightDelimiters at: match]
		ifFalse: 
			[openDelimiter := string at: here.
			match := rightDelimiters indexOf: openDelimiter.
			match > 0
				ifTrue: 
					["delimiter is on right -- match to the left"
					stop := here - 1.
					direction := -1.
					closeDelimiter := leftDelimiters at: match]
				ifFalse: ["no delimiters -- select a token"
					direction := -1]].
	level := 1.
	[level > 0 and: [direction > 0
			ifTrue: [here < string size]
			ifFalse: [here > 1]]]
		whileTrue: 
			[hereChar := string at: (here := here + direction).
			match = 0
				ifTrue: ["token scan goes left, then right"
					hereChar tokenish
						ifTrue: [here = 1
								ifTrue: 
									[start := 1.
									"go right if hit string start"
									direction := 1]]
						ifFalse: [direction < 0
								ifTrue: 
									[start := here + 1.
									"go right if hit non-token"
									direction := 1]
								ifFalse: [level := 0]]]
				ifFalse: ["bracket match just counts nesting level"
					hereChar = closeDelimiter
						ifTrue: [level := level - 1"leaving nest"]
						ifFalse: [hereChar = openDelimiter 
									ifTrue: [level := level + 1"entering deeper nest"]]]].

	level > 0 ifTrue: ["in case ran off string end"	here := here + direction].
	
	"to avoid selecting boringly the : in block argument: :aSerie will just select aSerie. 
	Such a boost of editing productivity!!!"	
	start ifNotNil: [ (self text at: start) = $: ifTrue: [ start := start + 1 ]].
	
	
	direction > 0
		ifTrue: [self selectFrom: start to: here - 1]
		ifFalse: [self selectFrom: here + 1 to: stop]
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> selectWord: aKeyboardEvent [

	self closeTypeIn.
	self selectWord.
	^ true
]

{ #category : #'accessing-selection' }
RubTextEditor >> selection [
	"Answer the text in the paragraph that is currently selected."
	^self text copyFrom: self startIndex to: self stopIndex - 1 
]

{ #category : #'accessing-selection' }
RubTextEditor >> selectionAsStream [
	"Answer a ReadStream on the text in the paragraph that is currently 
	selected."

	^ReadStream
		on: (self string copyFrom: self startIndex to: self stopIndex - 1)
]

{ #category : #'accessing-selection' }
RubTextEditor >> selectionInterval [
	"Answer the interval that is currently selected."

	^self startIndex to: self stopIndex - 1 
]

{ #category : #'accessing-selection' }
RubTextEditor >> selectionStart [
	^ textArea selectionStart
]

{ #category : #'accessing-selection' }
RubTextEditor >> selectionStop [
	^ textArea selectionStop
]

{ #category : #private }
RubTextEditor >> setEmphasisHere [
	self editingState
		emphasisHere:
			((self text attributesAt: (self pointIndex - 1 max: 1) forStyle: self textStyle) select: [ :att | att mayBeExtended ])
]

{ #category : #'typing support' }
RubTextEditor >> setEmphasisHereFromText [

	self setEmphasisHereFromTextForward: true
]

{ #category : #'typing support' }
RubTextEditor >> setEmphasisHereFromTextForward: lookForward [

	| i t forward delta prevIsSeparator nextIsSeparator |
	i := self pointIndex.
	t := self text.
	"Try to set emphasisHere correctly after whitespace.
	Most important after a cr, i.e. at the start of a new line"
	prevIsSeparator :=  i > 1 and: [ (t at: i-1) isSeparator ].
	nextIsSeparator := i <= t size and: [ (t at: i) isSeparator ].
	forward := prevIsSeparator = nextIsSeparator
		ifTrue: [ lookForward ]
		ifFalse: [ nextIsSeparator ].
	delta := forward ifTrue: [ 1 ] ifFalse: [ 0 ].
	self editingState emphasisHere: ((t attributesAt: (i - delta max: 1)) select: [:att | att mayBeExtended]).
	
]

{ #category : #private }
RubTextEditor >> setIndices: shiftPressed forward: forward [
	"Little helper method that sets the moving and fixed indices according to some flags."

	| indices |
	indices := Dictionary new.
	shiftPressed
		ifTrue: [ indices at: #moving put: self pointIndex.
			indices at: #fixed put: self markIndex ]
		ifFalse: [ forward
				ifTrue: [ indices at: #moving put: self stopIndex.
					indices at: #fixed put: self startIndex ]
				ifFalse: [ indices at: #moving put: self startIndex.
					indices at: #fixed put: self stopIndex ] ].
	^ indices
]

{ #category : #'menu messages' }
RubTextEditor >> setSearch: aString [
	"Make the current selection, if any, be the current search string."
	self findText: aString isRegex: false.
	^ true
]

{ #category : #'menu messages' }
RubTextEditor >> setSearchString [
	"Make the current selection, if any, be the current search string."
	self closeTypeIn.
	self setSearch: self selection string.
	^ true
]

{ #category : #'nonediting/nontyping keys' }
RubTextEditor >> setSearchString: aKeyboardEvent [
	"Establish the current selection as the current search string."
	^ self setSearchString
]

{ #category : #'menu messages' }
RubTextEditor >> setSelectorSearch: aStringOrText [ 
	"Make the current selection as a selector search in current FindReplaceService."
	| regex |
	regex := aStringOrText asString trimBoth.
	regex := regex copyReplaceAll: '#' with: ''.
	regex := regex copyReplaceAll: ' ' with: ''.
	self findText: regex isRegex: false caseSensitive: true entireWordsOnly: false.
	^ true
]

{ #category : #'editing keys' }
RubTextEditor >> shiftEnclose: aKeyboardEvent [
	"Insert or remove bracket characters around the current selection."

	| char left right startIndex stopIndex oldSelection which text |
	char := aKeyboardEvent keyCharacter.
	char = $9 ifTrue: [ char := $( ].
	char = $, ifTrue: [ char := $< ].
	char asciiValue = 27 ifTrue: [ char := ${ ].	"ctrl-["

	self closeTypeIn.
	startIndex := self startIndex.
	stopIndex := self stopIndex.
	oldSelection := self selection.
	which := '([<{"''' indexOf: char ifAbsent: [1].
	left := '([<{"''' at: which.
	right := ')]>}"''' at: which.
	text := self text.
	((startIndex > 1 and: [stopIndex <= text size])
			and: [ (text at: startIndex-1) = left and: [(text at: stopIndex) = right]])
		ifTrue: [
			"already enclosed; strip off brackets"
			self selectFrom: startIndex-1 to: stopIndex.
			self replaceSelectionWith: oldSelection]
		ifFalse: [
			"not enclosed; enclose by matching brackets"
			self replaceSelectionWith:
				(Text string: (String with: left), oldSelection string, (String with: right) attributes: self emphasisHere).
			self selectFrom: startIndex+1 to: stopIndex].
	^true
]

{ #category : #nesting }
RubTextEditor >> shouldEscapeCharacter: aCharacter [

	^ #($" $') includes: aCharacter
]

{ #category : #keymapping }
RubTextEditor >> specialShiftCmdKeys [

"Private - return array of key codes that represent single keys acting
as if shift-command were also being pressed"

^#(
	1	"home"
	3	"enter"
	4	"end"
	8	"backspace"
	9	"tab"
	11	"page up"
	12	"page down"
	13 "cr"
	27	"escape"
	28	"left arrow"
	29	"right arrow"
	30	"up arrow"
	31	"down arrow"
	127	"delete"
	)
]

{ #category : #'accessing-selection' }
RubTextEditor >> startIndex [
	^ textArea startIndex
]

{ #category : #'typing support' }
RubTextEditor >> startOfTyping [
	^ self editingState startOfTyping  
]

{ #category : #'typing support' }
RubTextEditor >> startOfTyping: anIntegerIndex [
	self editingState startOfTyping:  anIntegerIndex
]

{ #category : #'accessing-selection' }
RubTextEditor >> stopIndex [
	^ textArea stopIndex
]

{ #category : #'accessing-selection' }
RubTextEditor >> storeSelectionInText [
	self theme currentSettings haveSelectionTextColor 
		ifTrue: [
			self text removeAttribute: RubTextSelectionColor primarySelection.
			self text addAttribute: RubTextSelectionColor primarySelection from: self startIndex to: self stopIndex - 1]
]

{ #category : #accessing }
RubTextEditor >> string [

	^self text string
]

{ #category : #nesting }
RubTextEditor >> surroundString: aString withCharacter: aCharacter [
	"Returns a new string with contents equals to aString surrounded by aCharacter.
	Escapes all occurrences of aCharacter within aString by doubling them."
	
	"(self new surroundString: 'a' withCharacter: $') >>> '''a'''"
	"(self new surroundString: 'a''b' withCharacter: $') >>> '''a''''b'''"
	
	| result stream |
	result := WriteStream with: ''.
	stream := ReadStream on: aString string.
	result nextPut: aCharacter.
	[ stream atEnd ] whileFalse: 
		[ result nextPutAll: (stream upTo: aCharacter).
		stream peekBack = aCharacter ifTrue: [result nextPut: aCharacter]. 
		result nextPut: aCharacter.].
	stream peekBack = aCharacter ifTrue: [result nextPut: aCharacter].
	^result contents.
]

{ #category : #'editing keys' }
RubTextEditor >> swapChars [
	"Triggered byCmd-Y;.  Swap two characters, either those straddling the insertion point, or the two that comprise the selection.  Suggested by Ted Kaehler.  "

	^ self swapChars: nil
]

{ #category : #'editing keys' }
RubTextEditor >> swapChars: aKeyboardEvent [
	"Triggered byCmd-Y;.  Swap two characters, either those straddling the insertion point, or the two that comprise the selection.  Suggested by Ted Kaehler.  "

	| currentSelection aString chars |
	(chars := self selection) size = 0
		ifTrue:
			[currentSelection := self pointIndex.
			self selectMark: currentSelection - 1 point: currentSelection]
		ifFalse:
			[chars size = 2
				ifFalse:
					[textArea flash. ^ true]
				ifTrue:
					[currentSelection := self pointIndex - 1]].
	aString := self selection string.
	self replaceSelectionWith: (Text string: aString reversed attributes: self emphasisHere).
	self selectAt: currentSelection + 1.
	^ true
]

{ #category : #'typing/selecting keys' }
RubTextEditor >> tab: aKeyboardEvent [
	"Append a line feed character to the stream of characters."

	self addString: String tab.
	self unselect.
	^false
]

{ #category : #accessing }
RubTextEditor >> text [
	"Answer the text of the paragraph being edited."

	^ textArea text
]

{ #category : #accessing }
RubTextEditor >> textArea [
	^ textArea
]

{ #category : #accessing }
RubTextEditor >> textArea: atextArea [
	textArea := atextArea.
	self resetState.
]

{ #category : #accessing }
RubTextEditor >> textStyle [
	^ textArea textStyle
]

{ #category : #private }
RubTextEditor >> textStyle: aTextStyle [
	textArea textStyle: aTextStyle
]

{ #category : #private }
RubTextEditor >> textWasAccepted [
	self closeTypeIn.
	^ self accept
]

{ #category : #accessing }
RubTextEditor >> theme [
	^ UITheme current
]

{ #category : #accessing }
RubTextEditor >> totalTextHeight [

	^self paragraph totalTextHeight
]

{ #category : #accessing }
RubTextEditor >> transformFrom: owner [
	^textArea transformFrom: owner
]

{ #category : #events }
RubTextEditor >> tripleClick: evt [
	self closeTypeIn.	"no matter what, if shift is pressed extend the selection"
	self selectLine.
	self setEmphasisHereFromText.
	self storeSelectionInText.
]

{ #category : #nesting }
RubTextEditor >> unNesting: aString with: aCharacter [ 
	" To escape them, we double the character every time it's encountered"
	| result stream |
	result := WriteStream with: ''.
	stream := ReadStream on: aString.
	[ stream atEnd ] whileFalse: 
			[ result nextPutAll: (stream upTo: aCharacter).
			  stream peek ifNotNil: [result nextPut: stream next]].
	^result contents.
]

{ #category : #'menu messages' }
RubTextEditor >> undo [
	"Undo  previous edit."
	self closeTypeIn.
	self editingState undo ifFalse: [textArea flash]. 

]

{ #category : #'editing keys' }
RubTextEditor >> undo: aKeyboardEvent [ 
	"Undo the last edit."

	self undo.
	^true
]

{ #category : #'undoers-redoers' }
RubTextEditor >> undoRedoExchange: aninterval with: anotherInterval [
	self selectInvisiblyFrom: aninterval first to: aninterval last.
	self exchangeWith: anotherInterval

]

{ #category : #'find-select' }
RubTextEditor >> undoRedoTransaction: aBlock [
	self editingState undoRedoTransaction: aBlock
]

{ #category : #'undoers-redoers' }
RubTextEditor >> undoTypeIn: aText interval: anInterval [
	self selectInterval: anInterval.
	self replace: anInterval with: aText and:
		[self selectInterval: (anInterval first to: anInterval first - 1)].

]

{ #category : #nesting }
RubTextEditor >> unescapeCharacter: aCharacter inString: aString [
	"Unescape an escaped string.
	Assume the string has all occurrences of aCharacter are escaped.
	That is, they are in pairs.
	
	This method returns a copy of the string replacing all pairs of aCharacter by a single appearance of it."
	
	"(self unescapeCharacter: $' inString: '''''') >>> ''''"
	"(self unescapeCharacter: $' inString: '''') >>> ''''"
	
	| result stream |
	result := WriteStream with: ''.
	stream := ReadStream on: aString.
	[ stream atEnd ] whileFalse: 
			[ result nextPutAll: (stream upTo: aCharacter).
			  stream peek ifNotNil: [result nextPut: stream next]].
	^result contents.
]

{ #category : #private }
RubTextEditor >> unplug [
	textArea := nil.
	super unplug
]

{ #category : #'accessing-selection' }
RubTextEditor >> unselect [
	textArea unselect
]

{ #category : #accessing }
RubTextEditor >> visibleHeight [

	^textArea owner bounds height

]

{ #category : #settings }
RubTextEditor >> walkAlongDisplayedLine [
	^ textArea walkAlongDisplayedLine
]

{ #category : #accessing }
RubTextEditor >> wordAtCaret [

	^self paragraph text asString wordBefore: self startIndex - 1

]

{ #category : #'accessing-selection' }
RubTextEditor >> zapSelectionWith: aText [
	| start stop |
	self canChangeText
		ifFalse: [ ^ self ].
	start := self startIndex.
	stop := self stopIndex.
	(aText isEmpty and: [ stop > start ])
		ifTrue:
			[ "If deleting, then set emphasisHere from 1st character of the deletion"
			self editingState
				emphasisHere: ((self text attributesAt: start) select: [ :att | att mayBeExtended ]) ].
	(start = stop and: [ aText isEmpty ]) ifTrue: [ ^self ].
	textArea privateReplaceFrom: start to: stop - 1 with: aText asText.
			"We ask to editingSate directly instead to the morph "
			"to avoid unwanted SelectionChanged announce."
			"It will be send later while unselecting (with #unselect send)"
			self markIndex: start pointIndex: start + aText size.
			self editingState previousInterval: self selectionInterval
]
