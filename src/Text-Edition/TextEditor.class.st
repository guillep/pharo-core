"
My instances edit Text, this is, they support multiple lines and TextAttributes.
They have no specific facilities for editing Smalltalk code. Those are found in RubSmalltalkEditor.
"
Class {
	#name : #TextEditor,
	#superclass : #Object,
	#instVars : [
		'model',
		'editingState',
		'selectionShowing',
		'morph',
		'findReplaceService'
	],
	#classVars : [
		'BlinkingCursor',
		'CaseSensitiveFinds',
		'CmdKeysInText',
		'DumbbellCursor',
		'SkipOverMultipleSpaces',
		'UseFindReplaceSelection',
		'UseSecondarySelection',
		'UseSelectionBar',
		'WalkAlongDisplayedLine'
	],
	#classInstVars : [
		'cmdActions',
		'shiftCmdActions',
		'defaultFindReplaceServiceClass'
	],
	#category : #'Text-Edition-Editor'
}

{ #category : #settings }
TextEditor class >> blinkingCursor [	
	^ BlinkingCursor ifNil: [ BlinkingCursor := true ]
]

{ #category : #settings }
TextEditor class >> blinkingCursor: aBoolean [	
	BlinkingCursor := aBoolean
]

{ #category : #shortcuts }
TextEditor class >> buildTextEditorShortcutsOn: aBuilder [
	<keymap>
	
	(aBuilder shortcut: #toggleCommentOnSelectionOrLine)
		category: #TextEditor
		default: PharoShortcuts current toggleCommentOnSelectionOrLine
		do: [ :target  | target handleEdit: [ target toggleCommentOnSelectionOrLine ] ].
		
	(aBuilder shortcut: #selectAll) 
		category: #TextEditor
		default: PharoShortcuts current selectAllShortcut
		do: [ :target | target handleEdit: [ target selectAll ] ].

	(aBuilder shortcut: #copySelection) 
		category: #TextEditor
		default: PharoShortcuts current copySelectionShortcut
		do: [ :target | target copySelection ].
		
	(aBuilder shortcut: #find) 
		category: #TextEditor
		default: PharoShortcuts current findShortcut
		do: [ :target | target find ].
		
	(aBuilder shortcut: #findAgain) 
		category: #TextEditor
		default: PharoShortcuts current findAgainShortcut
		do: [ :target | target findAgain ].
		
	(aBuilder shortcut: #setSearchString)
		category: #TextEditor
		default: PharoShortcuts current setSearchStringShortcut
		do: [ :target | target setSearchString ].
		
	(aBuilder shortcut: #cancel) 
		category: #TextEditor
		default: PharoShortcuts current cancelShortcut
		do: [ :target | target cancelWithoutConfirmation ].
		
	(aBuilder shortcut: #paste) 
		category: #TextEditor
		default: PharoShortcuts current pasteShortcut
		do: [ :target | target paste ].
		
	(aBuilder shortcut: #cut) 
		category: #TextEditor
		default: PharoShortcuts current cutShortcut
		do: [ :target | target cut ].
				
	(aBuilder shortcut: #undo) 
		category: #TextEditor
		default: PharoShortcuts current undoShortcut
		do: [ :target | target undo ].
		
	(aBuilder shortcut: #redo) 
		category: #TextEditor
		default: PharoShortcuts current redoShortcut
		do: [ :target | target redo ].
	
	(aBuilder shortcut: #cursorHome)
		category: #TextEditor
		default: PharoShortcuts current cursorHomeShortcut
		do: [ :target :morph :event | target cursorHome: event ].
	
	(aBuilder shortcut: #cursorEnd)
		category: #TextEditor
		default: PharoShortcuts current cursorEndShortcut
		do: [ :target :morph :event | target cursorEnd: event ].
]

{ #category : #shortcuts }
TextEditor class >> buildTextEditorTabKeymapOn: aBuilder [
	"This is to mask the tab or shift tab character at the system window level."
	<keymap>
	
	(aBuilder shortcut: #doTab) 
		category: #TextEditorTab
		default: Character tab asKeyCombination
		do: [ :target | target handleEdit: [ target
				handleEdit: [ 
					target replaceSelectionWith: '	'.
					target selectInvisiblyFrom: target selectionInterval last + 1 to: target selectionInterval last ] ] ]
]

{ #category : #settings }
TextEditor class >> caseSensitiveFinds [
	^ CaseSensitiveFinds ifNil: [CaseSensitiveFinds := false]
]

{ #category : #settings }
TextEditor class >> caseSensitiveFinds: aBoolean [
	CaseSensitiveFinds := aBoolean
]

{ #category : #accessing }
TextEditor class >> cmdActions [
	^cmdActions
]

{ #category : #settings }
TextEditor class >> cmdKeysInText [
	^ CmdKeysInText ifNil: [CmdKeysInText := true]
]

{ #category : #settings }
TextEditor class >> cmdKeysInText: aBoolean [
	CmdKeysInText := aBoolean
]

{ #category : #shortcuts }
TextEditor class >> defaultFindReplaceServiceClass [

	^ defaultFindReplaceServiceClass ifNil: [ FindReplaceService ]
]

{ #category : #settings }
TextEditor class >> dumbbellCursor [
	^ DumbbellCursor ifNil: [ DumbbellCursor := false ]
]

{ #category : #settings }
TextEditor class >> dumbbellCursor: aBoolean [
	DumbbellCursor := aBoolean
]

{ #category : #settings }
TextEditor class >> editingSettingsOn: aBuilder [ 
	<systemsettings> 
	(aBuilder group: #codeEditing) 
		label: 'Text Editing';
		noOrdering;
		description: 'All settings concerned with text editing' ;
		with: [	
			(aBuilder setting: #selectionColor)
				target: UITheme;
				default: (Color r: 0.6862170087976539 g: 0.8347996089931574 b: 0.9794721407624634 alpha: 1.0);
				targetSelector: #currentSettings;
				label: 'Selection color'.
			(aBuilder setting: #unfocusedSelectionColor)
				target: UITheme;
				targetSelector: #currentSettings;
				description: 'The color of the selection for unfocused windows' ;
				default: (Color r: 0.729227761485826 g: 0.8318670576735093 b: 0.9335288367546432 alpha: 1.0);
				label: 'Unfocused selection color'.
			(aBuilder setting: #selectionTextColor)
				target: UITheme;
				targetSelector: #currentSettings;
				default: Color black;
				label: 'Selection text color';
				description: 'The color of the selection text'.
			(aBuilder setting: #useSelectionBar)
				target: TextEditor;
				default: true;
				label: 'Show the colored bar on the current line';
				with: [
					(aBuilder setting: #selectionBarColor)
						target: UITheme;
						targetSelector: #currentSettings;
						default: (Color r: 0.6862170087976539 g: 0.8347996089931574 b: 0.9794721407624634 alpha: 0.058823529411764705);
						label: 'Selection bar color'].
			(aBuilder setting: #useSecondarySelection)
				target: TextEditor;
				default: true;
				label: 'Use the secondary selection';
				with: [
					(aBuilder setting: #secondarySelectionTextColor)
						target: UITheme;
						targetSelector: #currentSettings;
						default: Color black;
						label: 'Secondary selection text color'].
			(aBuilder setting: #useFindReplaceSelection)
				target: TextEditor;
				default: true;
				label: 'Use the find and replace selection';
				with: [
					(aBuilder setting: #findReplaceSelectionColor)
						target: UITheme;
						targetSelector: #currentSettings;
						default: (Color r: 1.0 g: 0.6001955034213099 b: 0.0 alpha: 0.4);
						label: 'Find replace selection color'.
					(aBuilder setting: #findReplaceSelectionTextColor)
						target: UITheme;
						targetSelector: #currentSettings;
						default: Color black;
						label: 'Find replace selection text color'].
			(aBuilder setting: #caseSensitiveFinds) 
				label: 'Case sensitive search';
				target: TextEditor;
				default: false;
		 		description: 'If true, then the "find" command in text will always make its searches in a case-sensitive fashion'.
			(aBuilder setting: #blinkingCursor) 
				label: 'Blinking text cursor';
				target: TextEditor;
				default: true;
		 		description: 'When true, the text cursor will blink.'.
			(aBuilder setting: #dumbbellCursor) 
				label: 'Dumbbell-shaped text cursor';
				target: TextEditor;
				default: false;
		 		description: 'When true, the text cursor assumes the shape of a dumbbell, otherwise a vertical bar.'.
			(aBuilder setting: #skipOverMultipleSpaces) 
				label: 'Skip over white space';
				target: TextEditor;
				default: false;
		 		description: 'When true, the text cursor treats multiple white-space characters as a single space for navigating (moving left/right).'.
			(aBuilder setting: #walkAlongDisplayedLine) 
				label: 'Walk along displayed line';
				target: TextEditor;
				default: true;
		 		description: 'If set to true cursor movement will move along displayed lines rather than logical lines'.
		]

]

{ #category : #'instance creation' }
TextEditor class >> forMorph: aMorph [

	^ self new initWithMorph: aMorph
]

{ #category : #'class initialization' }
TextEditor class >> initialize [ 
	"Initialize the keyboard shortcut maps and the shared buffers
	for copying text across views and managing again and undo." 
 
	"
	TextEditor initialize
	" 

	self initializeCmdKeyShortcuts.
	self initializeShiftCmdKeyShortcuts.

]

{ #category : #'keyboard shortcut tables' }
TextEditor class >> initializeBasicCmdKeyShortcuts [
	"Initialize the (unshifted) command-key (or alt-key) shortcut table.
	
	TextEditor initialize
	"
	| cmdMap |
	
	cmdMap := Array new: 256 withAll: #noop:.		"use temp in case of a crash"
	cmdMap at: 1 + 1 put: #cursorHome:.				"home key"
	cmdMap at: 4 + 1 put: #cursorEnd:.				"end key"
	cmdMap at: 8 + 1 put: #backspace:.				"ctrl-H or delete key"
	cmdMap at: 11 + 1 put: #cursorPageUp:.			"page up key"
	cmdMap at: 12 + 1 put: #cursorPageDown:.		"page down key"
	cmdMap at: 13 + 1 put: #crWithIndent:.			"cmd-Return"
	cmdMap at: 27 + 1 put: #escape:.		"escape key"
	cmdMap at: 28 + 1 put: #cursorLeft:.				"left arrow key"
	cmdMap at: 29 + 1 put: #cursorRight:.			"right arrow key"
	cmdMap at: 30 + 1 put: #cursorUp:.				"up arrow key"
	cmdMap at: 31 + 1 put: #cursorDown:.			"down arrow key"
	"cmdMap at: 32 + 1 put: #selectWord:."			"space bar key"
	cmdMap at: 127 + 1 put: #forwardDelete:.		"del key"
	"cmdMap at: 115 + 1 put:#accept:".	
		
	#(
		$a #selectAll: 
		"$c #copySelection:" 
		$e #exchange: 
		"$f #find: "
		"$g #findAgain: "
		"$h #setSearchString: "
		"$v #paste: "
		$w #backWord: 
		"$x #cut:" 
		$y #swapChars: 
		"$z #undo:" 
		$j #redo: 
		"$u #exploreUndoManager: ")
	pairsDo: [ :char :symbol|
		cmdMap at: char asciiValue + 1 put: symbol].
		
	cmdActions := cmdMap
]

{ #category : #'keyboard shortcut tables' }
TextEditor class >> initializeBasicShiftCmdKeyShortcuts [ 
	"Initialize the shift-command-key (or control-key) shortcut table."

	"TextEditor initialize"
	
	| cmdMap |

	"shift-command and control shortcuts"
	cmdMap := Array new: 256 withAll: #noop:.  		"use temp in case of a crash"
	cmdMap at: ( 1 + 1) put: #cursorHome:.			"home key"
	cmdMap at: ( 4 + 1) put: #cursorEnd:.				"end key"
	cmdMap at: ( 8 + 1) put: #forwardDelete:.			"ctrl-H or delete key"
	cmdMap at: (11 + 1) put: #cursorPageUp:.			"page up key"
	cmdMap at: (12 + 1) put: #cursorPageDown:.		"page down key"
	cmdMap at: (13 + 1) put: #crWithIndent:.			"ctrl-Return"
	cmdMap at: (27 + 1) put: #offerMenuFromEsc:.	"escape key"
	cmdMap at: (28 + 1) put: #cursorLeft:.			"left arrow key"
	cmdMap at: (29 + 1) put: #cursorRight:.			"right arrow key"
	cmdMap at: (30 + 1) put: #cursorUp:.				"up arrow key"
	cmdMap at: (31 + 1) put: #cursorDown:.			"down arrow key"
	cmdMap at: (32 + 1) put: #selectWord:.			"space bar key"
	cmdMap at: (45 + 1) put: #changeEmphasis:.		"cmd-sh-minus"
	cmdMap at: (61 + 1) put: #changeEmphasis:.		"cmd-sh-plus"
	cmdMap at: (127 + 1) put: #forwardDelete:.		"del key"

	#(
		$c	compareToClipboard:
		$d	duplicate:
		$h	cursorTopHome:
		$j	doAgainMany:
		$k	changeStyle:
		$l	outdent:
		$m selectCurrentTypeIn:
		$r	indent:
		$s	search:
		$u	changeLfToCr:
		$x	makeLowercase:
		$y	makeUppercase:
		$z	makeCapitalized:
		"$g #findAgain:"
	) pairsDo: [ :char :symbol|
		cmdMap at: char asciiValue + 1 put: symbol.			"plain keys"
		cmdMap at: char asciiValue - 32 + 1 put: symbol.		"shifted keys"
		cmdMap at: char asciiValue - 96 + 1 put: symbol.		"ctrl keys"
	].
	shiftCmdActions := cmdMap
]

{ #category : #'keyboard shortcut tables' }
TextEditor class >> initializeCmdKeyShortcuts [
	"Initialize the (unshifted) command-key (or alt-key) shortcut table."



	"
	TextEditor initialize
	"

	| cmds |
	self initializeBasicCmdKeyShortcuts.
			
	'0123456789-=' 
		do: [:char | cmdActions at: char asciiValue + 1 put: #changeEmphasis:].
	
	cmds := #($k #offerFontMenu: $u #align: ).
	1 to: cmds size
		by: 2
		do: [:i | self cmdActions at: (cmds at: i) asciiValue + 1 put: (cmds at: i + 1)]
]

{ #category : #'keyboard shortcut tables' }
TextEditor class >> initializeShiftCmdKeyShortcuts [ 
	"Initialize the shift-command-key (or control-key) shortcut table."
	"wod 11/3/1998: Fix setting of cmdMap for shifted keys to actually use the 
	capitalized versions of the letters.
	TPR 2/18/99: add the plain ascii values back in for those VMs that don't return the shifted values."

	"TextEditor initialize"
	
	| cmds |

	self initializeBasicShiftCmdKeyShortcuts.
	self shiftCmdActions at: (45 + 1) put: #changeEmphasis:.		"cmd-sh-minus"
	self shiftCmdActions at: (61 + 1) put: #changeEmphasis:.		"cmd-sh-plus"

	cmds := #(
		$k	changeStyle:
		"$u #clearUndoManager:	"
	).
	1 to: cmds size by: 2 do: [ :i |
		self shiftCmdActions at: ((cmds at: i) asciiValue + 1) put: (cmds at: i + 1).			"plain keys"
		self shiftCmdActions at: ((cmds at: i) asciiValue - 32 + 1) put: (cmds at: i + 1).		"shifted keys"
		self shiftCmdActions at: ((cmds at: i) asciiValue - 96 + 1) put: (cmds at: i + 1).		"ctrl keys"
	].
]

{ #category : #accessing }
TextEditor class >> shiftCmdActions [
	^shiftCmdActions
]

{ #category : #settings }
TextEditor class >> skipOverMultipleSpaces [
	^ SkipOverMultipleSpaces  ifNil: [ SkipOverMultipleSpaces := false ]
]

{ #category : #settings }
TextEditor class >> skipOverMultipleSpaces: aBoolean [
	SkipOverMultipleSpaces := aBoolean
]

{ #category : #'private accessing' }
TextEditor class >> specialShiftCmdKeys [

"Private - return array of key codes that represent single keys acting
as if shift-command were also being pressed"

^#(
	1	"home"
	3	"enter"
	4	"end"
	8	"backspace"
	11	"page up"
	12	"page down"
	27	"escape"
	28	"left arrow"
	29	"right arrow"
	30	"up arrow"
	31	"down arrow"
	127	"delete"
	)
]

{ #category : #'menu declaration' }
TextEditor class >> textEditorMenuOn: aBuilder [
	"Specify the menu used when writing text. Try it with:
	(PragmaMenuBuilder 
		pragmaKeyword: 'textEditorMenu'
		model: nil) menu popUpInWorld"

	<contextMenu>
	<textEditorMenu>
	(aBuilder item: #'Find...' translated)
		keyText: 'f';
		selector: #find;
		iconName: #smallFindIcon.
	(aBuilder item: #'Find again' translated)
		keyText: 'g';
		selector: #findAgain;
		iconName: #smallFindIcon.
	(aBuilder item: #'Set search string' translated)
		keyText: 'h';
		selector: #setSearchString.
	(aBuilder item: #Undo translated)
		keyText: 'z';
		selector: #undo;
		iconName: #smallUndoIcon;
		withSeparatorAfter.
	(aBuilder item: #Copy translated)
		keyText: 'c';
		selector: #copySelection;
		iconName: #smallCopyIcon.
	(aBuilder item: #Cut translated)
		keyText: 'x';
		selector: #cut;
		iconName: #smallCutIcon.
	(aBuilder item: #Paste translated)
		keyText: 'v';
		selector: #paste;
		iconName: #smallPasteIcon.
	(aBuilder item: #'Paste recent' translated)
		selector: #pasteRecent;
		iconName: #smallCopyIcon;
		withSeparatorAfter.
	(aBuilder item: #'Set font...' translated)
		keyText: 'k';
		selector: #offerFontMenu.
	(aBuilder item: #'Set style...' translated)
		keyText: 'K';
		selector: #changeStyle.
	(aBuilder item: #'Set alignment...' translated)
		selector: #chooseAlignment;
		withSeparatorAfter.
	(aBuilder item: #Accept translated)
		keyText: 's';
		selector: #accept;
		iconName: #smallOkIcon.
	(aBuilder item: #Cancel translated)
		keyText: 'l';
		selector: #cancel;
		iconName: #smallCancelIcon
]

{ #category : #'menu declaration' }
TextEditor class >> textEditorShiftedMenuOn: aBuilder [ 
	"Specify the menu used when writing text. Try it with:
	(PragmaMenuBuilder 
		pragmaKeyword: 'textEditorShiftedMenu'
		model: nil) menu popUpInWorld"

	<contextMenu>
	<textEditorShiftedMenu>
	(aBuilder item: #'Set font...' translated) 
		keyText: 'k';
		selector: #offerFontMenu.
	(aBuilder item: #'Set style... (K)' translated) 
		keyText: 'K';
		selector: #changeStyle.
	(aBuilder item: #'Set alignment...' translated) 
		selector: #chooseAlignment.
	(aBuilder item: #'More...' translated) 
		selector: #yellowButtonActivity.

]

{ #category : #settings }
TextEditor class >> useFindReplaceSelection [
	^ UseFindReplaceSelection ifNil: [UseFindReplaceSelection := true]
]

{ #category : #settings }
TextEditor class >> useFindReplaceSelection: aBoolean [
	UseFindReplaceSelection := aBoolean
]

{ #category : #settings }
TextEditor class >> useSecondarySelection [
	^ UseSecondarySelection ifNil: [UseSecondarySelection := true]
]

{ #category : #settings }
TextEditor class >> useSecondarySelection: aBoolean [
	UseSecondarySelection := aBoolean
]

{ #category : #settings }
TextEditor class >> useSelectionBar [
	^ UseSelectionBar ifNil: [UseSelectionBar := true]
]

{ #category : #settings }
TextEditor class >> useSelectionBar: aBoolean [
	UseSelectionBar := aBoolean
]

{ #category : #settings }
TextEditor class >> walkAlongDisplayedLine [
	^ WalkAlongDisplayedLine ifNil: [WalkAlongDisplayedLine := true]
]

{ #category : #settings }
TextEditor class >> walkAlongDisplayedLine: aBoolean [
	WalkAlongDisplayedLine := aBoolean
]

{ #category : #'menu messages' }
TextEditor >> accept [
	"Save the current text of the text being edited as the current acceptable version for purposes of canceling.  Allow my morph to take appropriate action"
	morph canChangeText 
		ifTrue: [morph acceptContents]
]

{ #category : #'menu messages' }
TextEditor >> accept: aKeyboardEvent [ 
	"Save the current text of the text being edited as the current acceptable version for purposes of canceling.  Allow my morph to take appropriate action"
	self accept.
	^ true
]

{ #category : #'typing support' }
TextEditor >> acceptCR: aKeyboardEvent return: return [
	((aKeyboardEvent keyValue = Character cr asciiValue) and: [morph acceptOnCR])
		ifTrue: [
			self closeTypeIn.
			return value: true].
]

{ #category : #'undo-redo private' }
TextEditor >> addDeleteSelectionUndoRecord [
	| undoText redoText |
	undoText := self selection.
	redoText := self nullText.
	self editingState
		redoArray: { morph. #undoTypeIn:interval:.  {redoText. self selectionInterval} } 
		undoArray: {morph. #redoTypeIn:interval:.  {undoText. self selectionInterval first to: self selectionInterval first - 1} }.

]

{ #category : #'typing support' }
TextEditor >> addString: aString [
	"Think of a better name"
	self zapSelectionWith: (Text string: aString attributes: self emphasisHere)
]

{ #category : #'undo-redo private' }
TextEditor >> addTypeInUndoRecord [
	| begin stop undoText redoText |
	begin := self startOfTyping min: self stopIndex. 
	stop := self stopIndex max: self startOfTyping.
	self editingState 
		previousInterval: (begin to: stop - 1) 
		selection: (self text copyFrom: begin to: stop - 1). 
	undoText := self nullText.
	redoText := stop > begin
			ifTrue: [self text copyFrom: begin to: stop - 1]
			ifFalse: [self nullText].
	((undoText isEmpty and: [redoText isEmpty]) and: [self editingState previousInterval size < 1])
			ifFalse: [self editingState
				redoArray: { morph. #redoTypeIn:interval:.  {redoText. begin to: begin + self selection size - 1} } 
				undoArray: {morph. #undoTypeIn:interval:.  {undoText. begin to: stop - 1} }].
	

]

{ #category : #'new selection' }
TextEditor >> afterSelectionInsertAndSelect: aString [

	self insertAndSelect: aString at: self stopIndex 
]

{ #category : #'menu messages' }
TextEditor >> align [
	"Align text according to the next greater alignment value,
	cycling among leftFlush, rightFlush, center, and justified."
	self changeAlignment.
	self recomputeInterval
]

{ #category : #'editing keys' }
TextEditor >> align: aKeyboardEvent [
	"Triggered by Cmd-u;  cycle through alignment alternatives."

	self align.
	^ true
]

{ #category : #constants }
TextEditor >> alignmentChoices [
	"Return the symbols representing the TextAlignment operations to get a text aligned."
	
	^ #(leftFlush centered justified rightFlush)
]

{ #category : #private }
TextEditor >> applyAttribute: aTextAttribute [
	"The user selected aTextAttribute via shortcut, menu or other means.
	If there is a selection, apply the attribute to the selection.
	In any case use the attribute for the user input (emphasisHere)"

	self editingState emphasisHere: (Text addAttribute: aTextAttribute toArray: self emphasisHere).
	self selection
		ifEmpty: [ self paragraph composeAll ]
		ifNotEmpty: [:sel | self replaceSelectionWith: (sel addAttribute: aTextAttribute).
			self paragraph composeAll.
			self recomputeSelection]
]

{ #category : #'typing support' }
TextEditor >> backTo: startIndex [
	"Backspace typing"
	self stopIndex > startIndex ifTrue: [
		self selectFrom: startIndex to: self stopIndex - 1.
		self addDeleteSelectionUndoRecord.
		self zapSelectionWith: self nullText].
	^ false


	
]

{ #category : #'typing/selecting keys' }
TextEditor >> backWord: aKeyboardEvent [
	"If the selection is not a caret, delete it and leave it in the backspace buffer.
	 Else, delete the word before the caret."

	| startIndex |
	self hasCaret ifTrue: [ "a caret, delete at least one character"
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
TextEditor >> backspace: aKeyboardEvent [
	"Backspace over the last character."
	| result startIndex |
	self closeTypeIn.
	result := aKeyboardEvent shiftPressed 
		ifTrue: [self backWord: aKeyboardEvent keyCharacter]
		ifFalse: [self hasSelection
			ifTrue: [self replaceSelectionWith: self nullText]
			ifFalse: [startIndex := self markIndex + (self hasCaret ifTrue: [0] ifFalse: [1]).
				startIndex := 1 max: startIndex - 1.
				self backTo: startIndex].
		false].
	self editingState keystroke: aKeyboardEvent from: morph.
	^ result
]

{ #category : #binding }
TextEditor >> bindingOf: aString [
	^model bindingOf: aString
]

{ #category : #'editing keys' }
TextEditor >> blankParagraph [
	| blankParagraph |
	blankParagraph  := Paragraph new.
	blankParagraph 
		compose:  '' asText 
		style:  TextStyle default copy    
		from: 1
		in:  (0@0 extent: 10@10) .
	^ blankParagraph	
]

{ #category : #parenblinking }
TextEditor >> blinkParen [
	| lastParenLocation |
	(lastParenLocation := self editingState lastParenLocation) ifNotNil: [
		self text string size >= lastParenLocation ifTrue: [
			self text
				addAttribute: TextEmphasis bold
				from: lastParenLocation
				to: lastParenLocation]]
]

{ #category : #parenblinking }
TextEditor >> blinkParenAt: parenLocation [ 
	self text
		addAttribute: TextEmphasis bold
		from: parenLocation
		to: parenLocation.
	self editingState lastParenLocation: parenLocation.
]

{ #category : #parenblinking }
TextEditor >> blinkPrevParen: aCharacter [
	| openDelimiter closeDelimiter level string here hereChar |
	string := self string.
	here := self editingState pointBlock stringIndex.
	openDelimiter := "aKeyboardEvent keyValue." aCharacter.
	closeDelimiter := '([{' at: (')]}' indexOf: openDelimiter).
	level := 1.
	[level > 0 and: [here > 2]]
		whileTrue: [hereChar := string at: (here := here - 1).
			hereChar = closeDelimiter
				ifTrue: [level := level - 1.
					level = 0
						ifTrue: [^ self blinkParenAt: here]]
				ifFalse: [hereChar = openDelimiter
						ifTrue: [level := level + 1]]]
]

{ #category : #'menu messages' }
TextEditor >> cancel [
	"Cancel the changes made so far to this text"
	morph cancelEdits
]

{ #category : #'editing keys' }
TextEditor >> cancel: aKeyboardEvent [
	"Cancel unsubmitted changes."

	self cancel.
	^ true
]

{ #category : #accessing }
TextEditor >> caret [
	"Return the index position of the caret"
	^ self startBlock stringIndex
]

{ #category : #settings }
TextEditor >> caseSensitiveFinds [
	^ self class caseSensitiveFinds
]

{ #category : #'menu messages' }
TextEditor >> changeAlignment [
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
TextEditor >> changeEmphasis [

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
TextEditor >> changeEmphasis: aKeyboardEvent [
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
TextEditor >> changeEmphasisOrAlignment [
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
TextEditor >> changeLfToCr: aKeyboardEvent [
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
TextEditor >> changeStyle [
	"Let user change styles for the current text pane."

	| names reply style current menuList |
	current := TextStyle default copy.
	names := TextStyle actualTextStyles keys.
	menuList := names collect: [ :styleName |
		(styleName = current printString) -> styleName ].
	reply := UIManager default chooseFrom:  menuList values: names.	
	reply ifNotNil: [
		(style := TextStyle named: reply) ifNil: [ ^ true].
		self text style: style.
		self paragraph textStyle: style.
		self paragraph composeAll.
		self recomputeSelection].
	^ true
]

{ #category : #'typing/selecting keys' }
TextEditor >> changeStyle: aKeyboardEvent [ 
	"Put up the style-change menu"

	self closeTypeIn.
	self changeStyle.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> changeTextFont [
	"Present a menu of available fonts, and if one is chosen, apply it to the current selection."
	
	| curFont newFont attr startIndex |
	startIndex := self startIndex.
	curFont := self text fontAt: startIndex.
	newFont := StrikeFont fromUser: curFont.
	newFont ifNil: [ ^self ].
	attr := TextFontReference toFont: newFont.
	self applyAttribute: attr
]

{ #category : #'menu messages' }
TextEditor >> chooseAlignment [
	self changeAlignment
]

{ #category : #'editing keys' }
TextEditor >> chooseColor [
	"Make a new Text Color Attribute, let the user pick a color, and return the attribute"

	| attribute |	
	attribute := TextColor color: Color black "default".
	UIManager default chooseColor
		ifNotNil: [:nc | attribute color: nc].
	^ attribute

]

{ #category : #parenblinking }
TextEditor >> clearParens [
	| lastLocation |
	(lastLocation := self editingState lastParenLocation) 
		ifNil: [^ self].
	self text size >= lastLocation 
		ifTrue: [ self text
			removeAttribute: TextEmphasis bold
			from: lastLocation
			to: lastLocation].
	self editingState lastParenLocation: nil
]

{ #category : #'undo-redo private' }
TextEditor >> clearUndoManager: aKeyboardEvent [
	^ self editingState clearUndoManager: aKeyboardEvent.

]

{ #category : #'menu messages' }
TextEditor >> clipboardText [

	^ Clipboard clipboardText
]

{ #category : #'menu messages' }
TextEditor >> clipboardTextPut: text [

	^ Clipboard clipboardText: text
]

{ #category : #'typing support' }
TextEditor >> closeTypeIn [
	"See comment in openTypeIn. It is important to call
	closeTypeIn before executing any non-typing key, making a new selection, etc. It is
	called automatically for menu commands."
	self startOfTyping 
		ifNotNil: [self addTypeInUndoRecord.
			self doneTyping]
]

{ #category : #settings }
TextEditor >> cmdKeysInText [
	^ self class cmdKeysInText
]

{ #category : #'menu messages' }
TextEditor >> compareToClipboard [
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
TextEditor >> compareToClipboard: aKeyboardEvent [
	"Compare the receiver to the text on the clipboard."

	self compareToClipboard.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> copySelection [
	"Copy the current selection and store it in the paste buffer, unless a caret.  Undoer & Redoer: undoCutCopy"

	self lineSelectAndEmptyCheck: [^ self].
	self clipboardTextPut: self selection.
	self editingState previousInterval: self selectionInterval selection: self selection.

]

{ #category : #'editing keys' }
TextEditor >> copySelection: aKeyboardEvent [
	"Copy the current text selection."

	self copySelection.
	^true
]

{ #category : #'new selection' }
TextEditor >> correctFrom: start to: stop with: aString [
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
TextEditor >> crWithIndent: aKeyboardEvent [
	"Replace the current text selection with CR followed by as many tabs
	as on the current line (+/- bracket count) -- initiated by Shift-Return."
	| char s i tabCount  b |
	self closeTypeIn.
	b := self paragraph characterBlockAtPoint: aKeyboardEvent cursorPoint.
	s := self string.
	i := self stopIndex.
	tabCount := 0.
	[(i := i-1) > 0 and: [(char := s at: i) ~= Character cr]]
		whileTrue:  "Count tabs and brackets (but not a leading bracket)"
		[(char = Character tab and: [i < s size and: [(s at: i+1) ~= $[ ]]) ifTrue: [tabCount := tabCount + 1].
		char = $[ ifTrue: [tabCount := tabCount + 1].
		char = $] ifTrue: [tabCount := tabCount - 1]].
	 "Now inject CR with tabCount tabs"
	self addString: (String streamContents: [ :strm | strm crtab: tabCount ]).
	^ false
]

{ #category : #'typing/selecting keys' }
TextEditor >> crlf: aKeyboardEvent [
	"Append a line feed character to the stream of characters."

	self addString: String crlf.
	^false
]

{ #category : #accessing }
TextEditor >> currentAttributes [
	"Redefined by subclasses that handle TextAttributes"
	^nil
]

{ #category : #'nonediting/nontyping keys' }
TextEditor >> cursorDown: aKeyboardEvent [ 

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
TextEditor >> cursorEnd: aKeyboardEvent [ 

	"Private - Move cursor end of current line."
	| string |
	self closeTypeIn.
	string := self string.
	self
		moveCursor:
			[:position | self walkAlongDisplayedLine
				ifTrue:[| targetLine |
					targetLine := self paragraph lines at: (self paragraph lineIndexOfCharacterIndex: position).
					targetLine = self paragraph lines  last 
						ifTrue:[targetLine last + 1]
						ifFalse:[targetLine last]]
				ifFalse:[
					string
						indexOf: Character cr
						startingAt: position
						ifAbsent:[string size + 1]]]
		forward: true
		specialBlock:[:dummy | string size + 1]
		event: aKeyboardEvent.
	^true
]

{ #category : #'nonediting/nontyping keys' }
TextEditor >> cursorHome: aKeyboardEvent [

	"Private - Move cursor from position in current line to beginning of
	current line. If control key is pressed put cursor at beginning of text"

	| string |
	self closeTypeIn.
	string := self string.
	self
		moveCursor: [ :position | self walkAlongDisplayedLine
				ifTrue: [ (self paragraph lines at:(self paragraph lineIndexOfCharacterIndex: position)) first]
				ifFalse: [(string
						lastIndexOf: Character cr
						startingAt: position - 1
						ifAbsent:[0]) + 1]]
		forward: false
		specialBlock: [:dummy | 1]
		event: aKeyboardEvent.
	^true
]

{ #category : #'nonediting/nontyping keys' }
TextEditor >> cursorLeft: aKeyboardEvent [ 
	"Private - Move cursor left one character if nothing selected, otherwise 
	move cursor to beginning of selection. If the shift key is down, start 
	selecting or extending current selection. Don't allow cursor past 
	beginning of text"

	self closeTypeIn.
	self      
		moveCursor:[:position | 
			self class skipOverMultipleSpaces 
				ifTrue: [ self previousNonBlank: position ]
				ifFalse: [ position - 1 max: 1 ]
			 ]
		forward: false
		specialBlock:[:position | self previousWord: position]
		event: aKeyboardEvent.
	^ true
]

{ #category : #'nonediting/nontyping keys' }
TextEditor >> cursorPageDown: aKeyboardEvent [ 

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
TextEditor >> cursorPageUp: aKeyboardEvent [ 

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
TextEditor >> cursorRight: aKeyboardEvent [ 
	"Private - Move cursor right one character if nothing selected, 
	otherwise move cursor to end of selection. If the shift key is down, 
	start selecting characters or extending already selected characters. 
	Don't allow cursor past end of text"

	self closeTypeIn.
	self
		moveCursor: [:position |
			self class skipOverMultipleSpaces 
				ifTrue: [ self nextNonBlank: position ] 
				ifFalse: [ position + 1 ]
			]
		forward: true
		specialBlock:[:position | self nextWord: position]
		event: aKeyboardEvent.
	^ true
]

{ #category : #'typing/selecting keys' }
TextEditor >> cursorTopHome: aKeyboardEvent [
	"Put cursor at beginning of text -- invoked from cmd-H shortcut, useful for keyboards that have no home key."

	self selectAt: 1.
	^ true
]

{ #category : #'nonediting/nontyping keys' }
TextEditor >> cursorUp: aKeyboardEvent [ 
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
TextEditor >> cut [
	"Cut out the current selection and redisplay the paragraph if necessary.  Undoer & Redoer: undoCutCopy:"

	self lineSelectAndEmptyCheck: [^ self].
	self clipboardTextPut: self selection.
	self replaceSelectionWith: self nullText.

]

{ #category : #'editing keys' }
TextEditor >> cut: aKeyboardEvent [ 
	"Cut out the current text selection."

	self cut.
	^true
]

{ #category : #'find-select' }
TextEditor >> defaultFindReplaceServiceClass [

	^ FindReplaceService
]

{ #category : #'new selection' }
TextEditor >> deselect [
	"If the text selection is visible on the screen, reverse its highlight."
	self selectFrom: 1 to: 0
]

{ #category : #'typing support' }
TextEditor >> dispatchCommandOn: aKeyboardEvent return: return [
	|asciiValue honorCommandKeys|

	asciiValue := aKeyboardEvent keyValue.
	honorCommandKeys := self cmdKeysInText.
	"Special keys overwrite crtl+key combinations - at least on Windows. To resolve this
	conflict, assume that keys other than cursor keys aren't used together with Crtl." 
	((self class specialShiftCmdKeys includes: asciiValue) and: [ asciiValue < 27])
		ifTrue: [
			^ self performCmdActionsWith: aKeyboardEvent 
				shifted: aKeyboardEvent controlKeyPressed
				return: return].

	"backspace, and escape keys (ascii 8 and 27) are command keys"
	((honorCommandKeys and: [aKeyboardEvent commandKeyPressed]) or: [self class specialShiftCmdKeys includes: asciiValue]) 
		ifTrue: [
			^ self performCmdActionsWith: aKeyboardEvent 
				shifted: aKeyboardEvent shiftPressed
				return: return].

	"the control key can be used to invoke shift-cmd shortcuts"
	(honorCommandKeys and: [aKeyboardEvent controlKeyPressed])
		ifTrue: [
			^ self performCmdActionsWith: aKeyboardEvent shifted: true return: return].
			
	^ false

]

{ #category : #'typing support' }
TextEditor >> dispatchEnterOn: aKeyboardEvent return: aBlock [
	aKeyboardEvent keyValue = 13
		 ifFalse: [ ^ false ].
	aKeyboardEvent controlKeyPressed 
		ifTrue: [ aBlock value: (self normalCharacter: aKeyboardEvent) ].
	aKeyboardEvent shiftPressed 
		ifTrue: [  aBlock value:  (self lf: aKeyboardEvent) ].
	aKeyboardEvent commandKeyPressed 
		ifTrue: [  aBlock value:  (self crlf: aKeyboardEvent) ].
	 aBlock value:  (self crWithIndent: aKeyboardEvent)
]

{ #category : #'typing support' }
TextEditor >> dispatchOn: aKeyboardEvent [
	"Carry out the action associated with this character, if any.
	Type-ahead is passed so some routines can flush or use it."
	"TODO rename to dispatch: "
	
	| char return |
 	return := [:val| ^ val].

	self acceptCR: aKeyboardEvent return: return.
	self clearParens.
	self dispatchEnterOn: aKeyboardEvent return: return.
	self dispatchCommandOn: aKeyboardEvent return: return.
			
	char := aKeyboardEvent keyCharacter.
      ( ')]}'  includes: char) 
		ifTrue: [ self blinkPrevParen: char ].
		
       ^ self normalCharacter: aKeyboardEvent.

]

{ #category : #'typing/selecting keys' }
TextEditor >> doAgainMany: aKeyboardEvent [ 
	"Do the previous thing again repeatedly."

	self closeTypeIn.
	^ true
]

{ #category : #'typing support' }
TextEditor >> doneTyping [
	self startOfTyping: nil
]

{ #category : #events }
TextEditor >> doubleClick: evt [

	self selectWord
]

{ #category : #'editing keys' }
TextEditor >> duplicate: aKeyboardEvent [
	"Paste the current selection over the prior selection, if it is non-overlapping and
	 legal.  Undoer & Redoer: undoAndReselect."

	self closeTypeIn.
	(self hasSelection and: [self isDisjointFrom: self editingState previousInterval])
		ifTrue: "Something to duplicate"
			[self replace: self editingState previousInterval with: self selection and:
				[self selectAt: self pointIndex]]
		ifFalse:
			[morph flash].
	^true
]

{ #category : #accessing }
TextEditor >> editingState [
	^ editingState ifNil: [editingState := self editingStateClass new]
]

{ #category : #accessing }
TextEditor >> editingStateClass [
	^ EditingState
]

{ #category : #'menu declaration' }
TextEditor >> editorMenuKeyword [
	^'textEditorMenu'

]

{ #category : #constants }
TextEditor >> emphasisChoices [
	"Return the list of emphasis that are possible to apply on the currently edited text morph"
	
	^  #(normal bold italic narrow underlined struckOut).	
	
]

{ #category : #accessing }
TextEditor >> emphasisHere [
	^ self editingState emphasisHere
]

{ #category : #'editing keys' }
TextEditor >> enclose: aKeyboardEvent [
	"Insert or remove bracket characters around the current selection."

	| left right startIndex stopIndex oldSelection which text |
	self closeTypeIn.
	startIndex := self startIndex.
	stopIndex := self stopIndex.
	oldSelection := self selection.
	which := '([<{"''' indexOf: aKeyboardEvent keyCharacter ifAbsent: [ ^true ].
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

{ #category : #'editing keys' }
TextEditor >> encloseWith: aMatchingPair [
	"Insert or remove bracket characters around the current selection. Provided for protocol compatibility, but not completely sure this is ever called"
	| event |  
	event := KeyboardEvent new.
	event 
		setType: #keystroke
		buttons: nil
		position:  0@0
		keyValue: aMatchingPair key asciiValue 
		charCode: aMatchingPair key asciiValue
		hand: nil 
		stamp: Time now.
	^self enclose: event 
]

{ #category : #private }
TextEditor >> encompassParagraph: anInterval [
	"Return an interval that includes anInterval, and that comprises one or several whole paragraphs in the receiver.
	Answer starts at the position following a cr (or eventually 1) and ends at a cr (or eventually at self size)"
	^ self string encompassParagraph: anInterval

]

{ #category : #'nonediting/nontyping keys' }
TextEditor >> escape [ 
	self morph escapePressed .
	
]

{ #category : #'nonediting/nontyping keys' }
TextEditor >> escape: aKeyboardEvent [
	self morph escapePressed.
	^ false  
]

{ #category : #'do-its' }
TextEditor >> evaluateSelectionAndDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result."
	| result rcvr ctxt |
	self lineSelectAndEmptyCheck: [^ nil].

	(model respondsTo: #doItReceiver) 
		ifTrue: [ rcvr := model doItReceiver.
				ctxt := model doItContext]
		ifFalse: [rcvr := ctxt := nil].
	result := rcvr class compiler
			source: self selectionAsStream;
			context: ctxt;
			receiver: rcvr;
			requestor: self;
			failBlock:  [morph flash. ^ nil];
			evaluate.		
	^aBlock value: result
]

{ #category : #'menu messages' }
TextEditor >> exchange [
	"See comment in exchangeWith:"

	self exchangeWith: self editingState previousInterval
]

{ #category : #'editing keys' }
TextEditor >> exchange: aKeyboardEvent [
	"Exchange the current and prior selections."

	self closeTypeIn.
	self exchange.
	^true
]

{ #category : #private }
TextEditor >> exchangeWith: prior [
	"If the prior selection is non-overlapping and legal, exchange the text of
	 it with the current selection and leave the currently selected text selected
	 in the location of the prior selection (or leave a caret after a non-caret if it was
	 exchanged with a caret).  If both selections are carets, flash & do nothing.
	 Don't affect the paste buffer.  Undoer: itself; Redoer: Undoer."

	| start stop before currSelection priorSelection delta redoArgs altInterval undoArgs |
	start := self startIndex.
	stop := self stopIndex - 1.
	(((prior first <= prior last) or: [ start <= stop]) "Something to exchange" and:
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
			self editingState
				redoArray: { morph. #undoRedoExchange:with:. redoArgs} 
				undoArray: {morph. #undoRedoExchange:with:. undoArgs}]
		ifFalse:
			[morph flash]
]

{ #category : #'undo-redo private' }
TextEditor >> exploreUndoManager: aKeyboardEvent [
	^ self editingState exploreUndoManager: aKeyboardEvent
]

{ #category : #'menu messages' }
TextEditor >> find [
	"Prompt the user for a string to search for, and search the receiver from the current selection onward for it."
	morph openFindDialog
]

{ #category : #'typing/selecting keys' }
TextEditor >> find: aKeyboardEvent [
	"Prompt the user for what to find, then find it, searching from the current selection onward."

	self closeTypeIn.
	self find.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> findAgain [

	"Find the text-to-find again."

	| where |

	where := self findReplaceService
		findNextSubstring: self findReplaceService findString
		inTextMorph: self morph.
	where ifNil: [ self flash ] ifNotNil: [ self selectInterval: where ].
	^ where
]

{ #category : #'typing/selecting keys' }
TextEditor >> findAgain: aKeyboardEvent [ 
	"Find the desired text again."
	self closeTypeIn.
	self findAgain.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> findAgainAndReplace [

	"Find the text-to-find again and eventually replace it with the current replace text."

	| where |

	where := self findAgain.
	where
		ifNotNil: [ self findReplaceService replaceText ifNotEmpty: [ :rt | self replaceSelectionWith: rt ] ]
]

{ #category : #'find-select' }
TextEditor >> findAll: aRegex endingAt: searchIdx [ 
	| ranges |
	ranges := aRegex matchingRangesIn: (self string copyFrom: 1 to: searchIdx).
	^ ranges 
			
]

{ #category : #'find-select' }
TextEditor >> findAll: aRegex startingAt: searchIdx [ 
	| ranges |
	ranges := aRegex matchingRangesIn: (self string copyFrom: searchIdx to: self string size).
	^ ranges collect: [:i | i + searchIdx - 1]
			
]

{ #category : #'find-select' }
TextEditor >> findAndSelect: aRegex startingAt: anIndex searchBackwards: searchBackwards [
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
TextEditor >> findAndSelectNextOccurenceOf: aRegex [

	self
		deprecated: 'Use #findAndSelectPreviousOccurrenceOf: instead'
		transformWith: '`@rec findAndSelectNextOccurenceOf: `@arg'
			-> '`@rec findAndSelectPreviousOccurrenceOf: `@arg'.
	^ self findAndSelectPreviousOccurrenceOf: aRegex
]

{ #category : #'find-select' }
TextEditor >> findAndSelectNextOccurrenceOf: aRegex [
	| where |
	where := self findNext: aRegex startingAt: self stopIndex.
	where ifNotNil: [self selectInterval: where].
	"(morph respondsTo: #editView) ifTrue: [morph editView selectionInterval: self selectionInterval]."
	^ where
]

{ #category : #'find-select' }
TextEditor >> findAndSelectPreviousOccurrenceOf: aRegex [

	| where |

	where := self findPrevious: aRegex startingAt: self startIndex.
	where ifNotNil: [ self selectInterval: where ].
	( morph respondsTo: #editView )
		ifTrue: [ morph editView selectionInterval: self selectionInterval ].
	^ where
]

{ #category : #'find-select' }
TextEditor >> findNext: aRegex startingAt: searchIdx [ 
	| strm match range |
	strm := (self string copyFrom: searchIdx to: self string size) readStream.
	aRegex searchStream: strm.
	match := aRegex subexpression: 1.
	match ifNotNil: [range := (aRegex position + searchIdx - match size) to: (aRegex position + searchIdx - 1)].
	^ range
]

{ #category : #'find-select' }
TextEditor >> findNextString: aSubstring startingAt: searchIdx [ 
	| idx |
	idx := self string findString: aSubstring startingAt: searchIdx.
	^ idx isZero ifFalse: [idx to: idx + aSubstring size - 1]
]

{ #category : #'find-select' }
TextEditor >> findPrevious: aRegex startingAt: searchIdx [ 
	| allRanges |
	allRanges := self findAll: aRegex endingAt: searchIdx.
	^ allRanges notEmpty
		ifTrue: [allRanges last].

]

{ #category : #accessing }
TextEditor >> findRegex [
	^ self findReplaceService findRegex
]

{ #category : #'find-select' }
TextEditor >> findReplaceService [
	^ findReplaceService ifNil: [ self defaultFindReplaceServiceClass newFor: self ]
]

{ #category : #'find-select' }
TextEditor >> findText [
	^ self findReplaceService findText
]

{ #category : #'find-select' }
TextEditor >> findText: aStringOrText [
	self findReplaceService findText: aStringOrText 
]

{ #category : #accessing }
TextEditor >> findText: aString isRegex: aBoolean [
	self findReplaceService findText: aString isRegex: aBoolean.
	self findReplaceService changed: #newFinding

]

{ #category : #private }
TextEditor >> findText: aString isRegex: isRegex caseSensitive: caseSensitive entireWordsOnly: entireWordsOnly [
	self findReplaceService findText: aString isRegex: isRegex caseSensitive: caseSensitive entireWordsOnly: entireWordsOnly

]

{ #category : #private }
TextEditor >> findText: aString isRegex: isRegex entireWordsOnly: entireWordsOnly [
	self findReplaceService findText: aString isRegex: isRegex entireWordsOnly: entireWordsOnly

]

{ #category : #displaying }
TextEditor >> flash [
	^ morph flash
]

{ #category : #events }
TextEditor >> focused: aBoolean [
	self editingState focused: aBoolean from: morph.

]

{ #category : #'typing/selecting keys' }
TextEditor >> forwardDelete: aKeyboardEvent [
	"Delete forward over the next character"
	self closeTypeIn.
	self hasSelection 
		ifFalse: [	| idx1 idx2 |
				idx1 := self startIndex min: self stopIndex.
				idx2 := self stopIndex max: self startIndex.
				aKeyboardEvent shiftPressed
					ifTrue: [idx2 := (self nextWord: idx1)]
					ifFalse: [idx2 := idx2 + 1].
				self selectInvisiblyFrom: idx1 to: idx2 - 1].
	self addDeleteSelectionUndoRecord.
	self zapSelectionWith: self nullText.
	^ false

]

{ #category : #private }
TextEditor >> getPluggableYellowButtonMenu: shiftKeyState [
	| customMenu |
	^ (morph notNil and: [(customMenu := morph getMenu: shiftKeyState) notNil])
		ifTrue: [customMenu]
		ifFalse:
			[shiftKeyState
				ifTrue: [self shiftedYellowButtonMenu]
				ifFalse: [self yellowButtonMenu]]
]

{ #category : #events }
TextEditor >> handleDownOnUnselectedText: event [
	event shiftPressed
		ifTrue: [ ^ self mouseMove: event ].
	event yellowButtonPressed
		ifTrue: [ self yellowButtonDown: event ]
		ifFalse: [ 
			"no right/yellowbutton click just reposoition the cursor"
			self updateSelectionFromEvent: event ]
]

{ #category : #'typing support' }
TextEditor >> handleEditionAction: anAction fromKeyboardEvent: aKeyboardEvent [
	(self editingState handlesKeyboard: aKeyboardEvent from: morph)
		ifFalse: [self handleKeystrokeAction: anAction ].
	self editingState keystroke: aKeyboardEvent from: morph.
]

{ #category : #'typing support' }
TextEditor >> handleKeystrokeAction: aBlock [
	(aBlock value)
			ifTrue: [self doneTyping.
			self storeSelectionInParagraph.
			^self].
	self openTypeIn.
	self hasSelection 
		ifTrue: [ "save highlighted characters"
			self editingState previousInterval: self selectionInterval selection: self selection].
	self editingState unselect.
	self storeSelectionInParagraph
]

{ #category : #'accessing-selection' }
TextEditor >> hasCaret [
	^self editingState markBlock = self editingState pointBlock
]

{ #category : #testing }
TextEditor >> hasError [
	^ false 
]

{ #category : #'accessing-selection' }
TextEditor >> hasSelection [
	^self hasCaret not
]

{ #category : #'editing keys' }
TextEditor >> inOutdent: aKeyboardEvent delta: delta [
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
					morph flash]
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
			[morph flash]
		ifFalse:
			[self selectInvisiblyFrom: start to: stop.
			size = newString size ifFalse: [newString := outStream contents].
			self replaceSelectionWith: newString asText].
	self selectFrom: realStart to: realStop. 	"highlight only the original range"
	^ true
]

{ #category : #'editing keys' }
TextEditor >> indent: aKeyboardEvent [
	"Add a tab at the front of every line occupied by the selection."

	^ self inOutdent: aKeyboardEvent delta: 1
]

{ #category : #private }
TextEditor >> indent: delta fromStream: inStream toStream: outStream [
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

{ #category : #initialization }
TextEditor >> initWithMorph: aMorph [
	morph := aMorph.
	self resetState 
]

{ #category : #'new selection' }
TextEditor >> insertAndSelect: aString at: anInteger [

	self replace: (anInteger to: anInteger - 1)
		with: (Text string: (' ' , aString)
					attributes: self emphasisHere)
		and: [self ]
]

{ #category : #shortcuts }
TextEditor >> installKeymappingsOn: aMorph [
 	aMorph attachKeymapCategory: #TextEditor.
	aMorph attachKeymapCategory: #TextMorph targetting: aMorph textMorph.
	aMorph attachKeymapCategory: #TextMorphTab
]

{ #category : #testing }
TextEditor >> isCaretBehindChar [
	"Return true if the cursor position is after an alphanumeric character, otherwise false."

	| cursorPosition |
	^(cursorPosition := self startIndex) >= 2 and: [
		(self text at: cursorPosition - 1) isAlphaNumeric ]
]

{ #category : #private }
TextEditor >> isDisjointFrom: anInterval [
	"Answer true if anInterval is a caret not touching or within the current
	 interval, or if anInterval is a non-caret that does not overlap the current
	 selection."

	| fudge |
	fudge := anInterval size = 0 ifTrue: [1] ifFalse: [0].
	^(anInterval last + fudge < self startIndex or:
			[anInterval first - fudge >= self stopIndex])

]

{ #category : #testing }
TextEditor >> isSmalltalkEditor [
	^ false 
]

{ #category : #testing }
TextEditor >> isTextEditor [
	^ true 
]

{ #category : #'typing support' }
TextEditor >> keystroke: aKeyboardEvent [
	self handleEditionAction: [ self dispatchOn: aKeyboardEvent ] fromKeyboardEvent: aKeyboardEvent
]

{ #category : #accessing }
TextEditor >> lastFont [	
	"Answer the Font for to be used if positioned at the end of the text"
	| t |	
	t := self text.	
	^ t fontAt: t size + 1
]

{ #category : #'typing/selecting keys' }
TextEditor >> lf: aKeyboardEvent [ 
	"Append a line feed character to the stream of characters."

	self addString: Character lf asString.
	^false
]

{ #category : #'menu messages' }
TextEditor >> lineSelectAndEmptyCheck: returnBlock [
	"If the current selection is an insertion point, expand it to be the entire current line; if after that's done the selection is still empty, then evaluate the returnBlock, which will typically consist of '[^ self]' in the caller -- check senders of this method to understand this."

	self selectLine.  "if current selection is an insertion point, then first select the entire line in which occurs before proceeding"
	self hasSelection ifFalse: [morph flash.  ^ returnBlock value]
]

{ #category : #private }
TextEditor >> lines [
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
TextEditor >> makeCapitalized: aKeyboardEvent [
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
TextEditor >> makeLowercase: aKeyboardEvent [
	"Force the current selection to lowercase.  Triggered by Cmd-X."

	self closeTypeIn.
	self replaceSelectionWith: (Text fromString: (self selection string asLowercase)).
	^ true
]

{ #category : #'editing keys' }
TextEditor >> makeUppercase: aKeyboardEvent [
	"Force the current selection to uppercase.  Triggered by Cmd-Y."

	self closeTypeIn.
	self replaceSelectionWith: (Text fromString: (self selection string asUppercase)).
	^ true
]

{ #category : #'accessing-selection' }
TextEditor >> markBlock [
	^ self editingState markBlock
]

{ #category : #accessing }
TextEditor >> markBlock: aCharacterBlock [ 
	self editingState markBlock:  aCharacterBlock
]

{ #category : #'accessing-selection' }
TextEditor >> markIndex [
	^ self editingState markBlock stringIndex
]

{ #category : #'accessing-selection' }
TextEditor >> markIndex: anIndex [
	self editingState markBlock: (self paragraph characterBlockForIndex: anIndex)

]

{ #category : #accessing }
TextEditor >> model [
	^model
]

{ #category : #accessing }
TextEditor >> model: aModel [ 
	"Controller|model: and Controller|view: are sent by View|controller: in 
	order to coordinate the links between the model, view, and controller. In 
	ordinary usage, the receiver is created and passed as the parameter to 
	View|controller: so that the receiver's model and view links can be set 
	up by the view."

	model := aModel
]

{ #category : #accessing }
TextEditor >> morph [
	^ morph
]

{ #category : #accessing }
TextEditor >> morph: aMorph [
	"Install a link back to the morph being edited (esp for text links)"
	morph := aMorph 
]

{ #category : #events }
TextEditor >> mouseDown: event [
	"An attempt to break up the old processRedButton code into three phases"

	"no matter what, if shift is pressed extend the selection"
	"no right/yellowbutton click just reposoition the cursor"
	(self paragraph selectionContainsPoint: event cursorPoint)
		ifTrue: [ self mouseDownOnSelectedText: event ]
		ifFalse: [ self mouseDownOnUnselectedText: event ]
]

{ #category : #events }
TextEditor >> mouseDownOnSelectedText: event [
	| selectors |
	selectors := Array
		with: #mouseDownOnUnselectedText:
		with: nil
		with: nil
		with:
			(self morph dragEnabled
				ifTrue: [ #startDrag: ]
				ifFalse: [ nil ]).
	event hand
		waitForClicksOrDrag: self
		event: event
		selectors: selectors
		threshold: 10
]

{ #category : #events }
TextEditor >> mouseDownOnUnselectedText: event [
	self editingState mouseDown: event from: morph.
	self closeTypeIn.	"no matter what, if shift is pressed extend the selection"
	"make sure our view knows about selection change"	
	self morph handleInteraction: [ self handleDownOnUnselectedText: event ]
]

{ #category : #events }
TextEditor >> mouseMove: evt [
	"Change the selection in response to mouse-down drag"
	| characterBlock |
	
	characterBlock := self paragraph characterBlockAtPoint: evt cursorPoint.

	self editingState pointBlock: characterBlock.
	self paragraph move: evt for: model controller: self.
	self storeSelectionInParagraph
]

{ #category : #events }
TextEditor >> mouseUp: evt [
	"An attempt to break up the old processRedButton 
	code into three phases"
	| mouseDownInterval |
	
	(mouseDownInterval := self editingState mouseDownInterval)
		ifNil: [^ self]. 
		
	(self paragraph click: evt for: model controller: self ) 
		ifTrue: [
			self updateSelectionFromEvent: evt.
			evt hand releaseKeyboardFocus: self.
			^ self ].

	(evt yellowButtonChanged or: [ evt commandKeyPressed]) 
		ifTrue: [
			(self morph yellowButtonActivity: evt shiftPressed) 
				ifTrue: [ ^ self ]].
		
	(self hasCaret and: [mouseDownInterval = self selectionInterval])
		ifTrue: [self selectWord].
		
	self setEmphasisHereFromText.
	self storeSelectionInParagraph
]

{ #category : #private }
TextEditor >> moveCursor: directionBlock forward: forward specialBlock: specialBlock event: aKeyboardEvent [
	"Private - Move cursor.
	directionBlock is a one argument Block that computes the new Position from a given one.
	specialBlock is a one argumentBlock that computes the new position from a given one under the alternate semantics.
	Note that directionBlock always is evaluated first."
	| shift indices newPosition |
	self morph manageCursor.
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

{ #category : #accessing }
TextEditor >> nextCharacterIfAbsent: aBlock [

	^ self text at: self startIndex ifAbsent: aBlock
]

{ #category : #private }
TextEditor >> nextNonBlank: position [

"if current position is not separator, advance by 1, otherwise advance up until non-separator char found or new line"
	
	| string index |
	string := self string.
	index := position.
	index >= string size ifTrue: [ ^ string size+1 ].
	
	(string at: index) isSeparator ifFalse: [ ^ index + 1 ].
	index := index + 1.
	[ index <= string size and: [(string at: index) isSeparator and: [(string at:index) ~= Character cr]]]
		whileTrue: [index := index + 1].
	^ index
]

{ #category : #private }
TextEditor >> nextWord: position [
	| string index |
	string := self string.
	index := position.
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric]]
		whileTrue: [index := index + 1].
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric not]]
		whileTrue: [index := index + 1].
	^ index
]

{ #category : #'editing keys' }
TextEditor >> noop: aKeyboardEvent [ 
	"Unimplemented keyboard command; just ignore it."

	^ true
]

{ #category : #'typing/selecting keys' }
TextEditor >> normalCharacter: aKeyboardEvent [ 
	"A nonspecial character is to be added to the stream of characters."

	self hasSelection 
		ifTrue: [self addDeleteSelectionUndoRecord].
	self addString: aKeyboardEvent keyCharacter asString.
	^false

]

{ #category : #private }
TextEditor >> nullText [

	^Text string: '' attributes: self emphasisHere
]

{ #category : #'menu messages' }
TextEditor >> offerFontMenu [
	"Present a menu of available fonts, and if one is chosen, apply it to the current selection.  
	Use only names of Fonts of this paragraph  "
	
	^self changeTextFont
]

{ #category : #'editing keys' }
TextEditor >> offerFontMenu: aKeyboardEvent [ 
	"The user typed the command key that requests a font change; Offer the font menu."

	self closeTypeIn.
	self offerFontMenu.
	^ true
]

{ #category : #deprecated }
TextEditor >> offerMenuFromEsc: aKeyboardEvent [
	"The escape key was hit while the receiver has the keyboard focus; take action"
 	morph activeHand lastEvent shiftPressed 
		ifFalse: [ self raiseContextMenu: aKeyboardEvent].
	^ false 	
]

{ #category : #'typing support' }
TextEditor >> openTypeIn [
	"Set up startOfTyping to keep track of the leftmost backspace.
	 You can't undo typing until after closeTypeIn."

	self startOfTyping 
		ifNil: [self editingState previousInterval: (1 to: 0) selection: self nullText.
			self startOfTyping: self startIndex]
]

{ #category : #'editing keys' }
TextEditor >> outdent: aKeyboardEvent [
	"Remove a tab from the front of every line occupied by the selection."

	^ self inOutdent: aKeyboardEvent delta: -1
]

{ #category : #private }
TextEditor >> pageHeight [
	| howManyLines visibleHeight totalHeight ratio |
	howManyLines := self paragraph numberOfLines.
	visibleHeight := self visibleHeight.
	totalHeight := self totalTextHeight.
	ratio := visibleHeight / totalHeight.
	^(ratio * howManyLines) rounded - 2
]

{ #category : #private }
TextEditor >> paragraph [
	^ morph 
		ifNotNil: [morph paragraph]
		ifNil: [self error: 'paragraph is not available']
]

{ #category : #'menu messages' }
TextEditor >> paste [
	"Paste the text from the shared buffer over the current selection and 
	redisplay if necessary.  Undoer & Redoer: undoAndReselect."

	self replace: self selectionInterval with: self clipboardText and:
		[self selectAt: self pointIndex]
]

{ #category : #'editing keys' }
TextEditor >> paste: aKeyboardEvent [ 
	"Replace the current text selection by the text in the shared buffer."

	self closeTypeIn.
	self paste.
	^true
]

{ #category : #'menu messages' }
TextEditor >> pasteRecent [
	"Paste an item chose from RecentClippings."

	| clipping |
	(clipping := Clipboard chooseRecentClipping) ifNil: [^ self].
	Clipboard clipboardText: clipping.
	^ self paste
]

{ #category : #'typing support' }
TextEditor >> performCmdActionsWith: aKeyboardEvent shifted: aBoolean return: return [
	| asciiValue actions action|
	asciiValue := aKeyboardEvent keyValue + 1.
	actions := aBoolean
				ifTrue: [self class shiftCmdActions]
				ifFalse: [self class cmdActions].
	action := (actions at: asciiValue).
	action == #noop: ifTrue: [ ^ false ].
	return value: ( self perform: action with: aKeyboardEvent).
]

{ #category : #'pluggable menus' }
TextEditor >> pluggableYellowButtonActivity: shiftKeyState [

	"Invoke the model's popup menu."

	^ (self getPluggableYellowButtonMenu: shiftKeyState)
		  ifNil: [ false ]
		  ifNotNil: [ true ]
]

{ #category : #'accessing-selection' }
TextEditor >> pointBlock [
	^ self editingState pointBlock
]

{ #category : #'accessing-selection' }
TextEditor >> pointIndex [
	^ self editingState pointBlock stringIndex
]

{ #category : #'accessing-selection' }
TextEditor >> pointIndex: anIndex [
	self editingState pointBlock: (self paragraph characterBlockForIndex: anIndex)

]

{ #category : #accessing }
TextEditor >> previousCharacterIfAbsent: aBlock [

	^ self text at: self startIndex - 1 ifAbsent: aBlock
]

{ #category : #private }
TextEditor >> previousNonBlank: position [
	"decrement position up until any non-blank character found, or end of line"
	| string index |
	position <= 1 ifTrue: [ ^ 1 ].
	
	string := self string.
	index := position.
	index := index -1.
	(string at: index) isSeparator ifFalse: [ ^ index ]. 

	[ index > 1 and: [(string at: index-1) isSeparator and: [(string at:index-1) ~= Character cr]]]
		whileTrue: [index := index - 1].
	^ index
]

{ #category : #private }
TextEditor >> previousWord: position [
	| string index |
	string := self string.
	index := position.
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric not]]
		whileTrue: [index := index - 1].
	[(index between: 1 and: string size) and: [(string at: index) isAlphaNumeric]]
		whileTrue: [index := index - 1].
	^ index + 1
]

{ #category : #'typing support' }
TextEditor >> processKeyStroke: aKeyboardEvent [
	"Key struck on the keyboard. Find out which one and, if special, carry 
	out the associated special action. Otherwise, add the character to the 
	stream of characters.  Undoer & Redoer: see closeTypeIn."
	
	^self handleKeystrokeAction: [self dispatchOn: aKeyboardEvent].
]

{ #category : #'nonediting/nontyping keys' }
TextEditor >> raiseContextMenu: aKeyboardEvent [

	(morph respondsTo: #editView)
		ifTrue: [ ^ morph editView yellowButtonActivity: morph activeHand lastEvent shiftPressed].
	^ true
]

{ #category : #'current selection' }
TextEditor >> recomputeInterval [
	"The same characters are selected but their coordinates may have changed."

	self markIndex: self markIndex; pointIndex: self pointIndex
]

{ #category : #'current selection' }
TextEditor >> recomputeSelection [
	"Redetermine the selection according to the start and stop block indices; 
	do not highlight."

	self recomputeInterval
]

{ #category : #'menu messages' }
TextEditor >> redo [
	"redo previous edit"

	self editingState redo ifFalse: [morph flash]. 

]

{ #category : #'editing keys' }
TextEditor >> redo: aKeyboardEvent [ 
	"Redo the last edit."

	self redo.
	^true
]

{ #category : #'undoers-redoers' }
TextEditor >> redoTypeIn: aText interval: anInterval [
	self selectInterval: anInterval.
	self replace: self selectionInterval with: aText and:
		[self selectInterval: (anInterval first to: anInterval first + aText size - 1)].

]

{ #category : #accessing }
TextEditor >> replace: xoldInterval with: newText and: selectingBlock [ 
	"Replace the text in oldInterval with newText and
	execute selectingBlock to establish the new selection.
	Create an UndoRecord to allow perfect undoing."
	| prevSel currInterval |
	self selectInterval: xoldInterval.
	prevSel := self selection.
	currInterval := self selectionInterval.
	self editingState previousInterval: currInterval selection: self selection.
	self zapSelectionWith: newText.
	selectingBlock value.
	((prevSel isEmpty and: [newText isEmpty]) and: [currInterval size < 1]) 
		ifFalse: [self editingState
			redoArray: {morph. #redoTypeIn:interval:. {newText. currInterval}} 
			undoArray: {morph. #undoTypeIn:interval:. {prevSel. currInterval first to: currInterval first + newText size - 1}}]
]

{ #category : #'find-select' }
TextEditor >> replaceAll: aRegex with: aText [
	| selec ranges |
	self editingState undoManager openRecordGroup.
	selec := self selectionInterval.
	ranges := self findAll: aRegex startingAt: selec first. 
	ranges reverseDo: [:r | self selectInvisiblyFrom: r first to: r last.
		self replaceSelectionWith: aText].
	self selectInterval: selec.
	self editingState undoManager closeRecordGroup.

]

{ #category : #'find-select' }
TextEditor >> replaceAll: aRegex with: aText startingAt: startIdx [
	| selec ranges |
	self editingState undoManager openRecordGroup.
	selec := self selectionInterval.
	ranges := self findAll: aRegex startingAt: startIdx. 
	ranges reverseDo: [:r | self selectInvisiblyFrom: r first to: r last.
		self replaceSelectionWith: aText].
	self selectInterval: selec.
	self editingState undoManager closeRecordGroup.

]

{ #category : #accessing }
TextEditor >> replaceSelectionWith: aText [
	self replace: self selectionInterval with: aText and: []

]

{ #category : #initialization }
TextEditor >> resetState [ 
	"Establish the initial conditions for editing the paragraph: place caret 
	before first character, set the emphasis to that of the first character,
	and save the paragraph for purposes of canceling."
 
	self editingState markBlock: self paragraph defaultCharacterBlock.
	self editingState pointBlock: self editingState markBlock copy.
	self startOfTyping: nil.
	self editingState previousInterval: (1 to: 0) selection: self nullText.
	self setEmphasisHereFromText.
	selectionShowing := true
]

{ #category : #private }
TextEditor >> sameColumn: start newLine: lineBlock forward: isForward [
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
TextEditor >> saveContentsInFile [
	"Save the receiver's contents string to a file, prompting the user for a file-name. Suggest a reasonable file-name."

	| fileName stringToSave labelToUse suggestedName lastIndex |
	stringToSave := self string.
	stringToSave ifEmpty: [ ^ self inform: 'nothing to save.' ].
	labelToUse :=  model dependents detect: [ :dep | dep isKindOf: SystemWindow ] ifFound: [:parentWindow | parentWindow label] ifNone: [ 'Untitled' ].
	suggestedName := nil.
	#(#('Decompressed contents of: ' '.gz'))
		do: [ :leaderTrailer | 
			"can add more here..."
			(labelToUse beginsWith: leaderTrailer first)
				ifTrue: [ suggestedName := labelToUse copyFrom: leaderTrailer first size + 1 to: labelToUse size.
					(labelToUse endsWith: leaderTrailer last)
						ifTrue: [ suggestedName := suggestedName copyFrom: 1 to: suggestedName size - leaderTrailer last size ]
						ifFalse: [ lastIndex := suggestedName lastIndexOf: $. ifAbsent: [ 0 ].
							lastIndex > 1
								ifTrue: [ suggestedName := suggestedName copyFrom: 1 to: lastIndex - 1 ] ] ] ].
	suggestedName ifNil: [ suggestedName := labelToUse , '.text' ].
	fileName := UIManager default request: 'File name?' initialAnswer: suggestedName.
	fileName isEmptyOrNil
		ifFalse: [ fileName asFileReference writeStreamDo: [ :out | out nextPutAll: stringToSave ] ]
]

{ #category : #scrolling }
TextEditor >> scrollBy: ignore [ 
	"Ignore scroll requests."

]

{ #category : #'typing/selecting keys' }
TextEditor >> search: aKeyboardEvent [
	"Invoked by Ctrl-S.  Same as 'again', but always uses the existing findText
	 from current FindReplaceService"

	self closeTypeIn.
	self findAgain.
	^true
]

{ #category : #'current selection' }
TextEditor >> select [
	"If the text selection is visible on the screen, reverse its highlight."
	^'Not doing anything'
	"screw this logic
	selectionShowing ifFalse: [self reverseSelection]"
]

{ #category : #'typing/selecting keys' }
TextEditor >> selectAll [

	self selectFrom: 1 to: self string size
]

{ #category : #'typing/selecting keys' }
TextEditor >> selectAll: aKeyboardEvent [ 
	"select everything"

	self closeTypeIn.
	self selectFrom: 1 to: self string size.
	^ true
]

{ #category : #'new selection' }
TextEditor >> selectAt: characterIndex [ 
	"Place the caret before the character at characterIndex.
	 Be sure it is in view."

	self selectFrom: characterIndex to: characterIndex - 1
]

{ #category : #'nonediting/nontyping keys' }
TextEditor >> selectCurrentTypeIn: aKeyboardEvent [ 
	"Select what would be replaced by an undo (e.g., the last typeIn)."

	self closeTypeIn.
	self selectInterval: self editingState previousInterval.
	^ true
]

{ #category : #'new selection' }
TextEditor >> selectFrom: start to: stop [
	"Select the specified characters inclusive."
	self selectInvisiblyFrom: start to: stop.
	self closeTypeIn.
	self storeSelectionInParagraph.
	"Preserve current emphasis if selection is empty"
	stop > start 
		ifTrue: [self setEmphasisHereFromTextForward: true ]
]

{ #category : #'new selection' }
TextEditor >> selectInterval: anInterval [
	"Select the specified characters inclusive.
	 Be sure the selection is in view."

	self selectFrom: anInterval first to: anInterval last
]

{ #category : #'new selection' }
TextEditor >> selectInvisiblyAt: characterIndex [ 
	"Place the caret before the character at characterIndex.
	 Be sure it is in view but vithout any further action."
	
	self selectInvisiblyFrom: characterIndex to:  characterIndex - 1

]

{ #category : #'new selection' }
TextEditor >> selectInvisiblyFrom: start to: stop [
	"Select the designated characters, inclusive.  Make no visual changes."

	self markIndex: start; pointIndex: stop + 1
]

{ #category : #'new selection' }
TextEditor >> selectInvisiblyMark: mark point: point [
	"Select the designated characters, inclusive.  Make no visual changes."

	self markIndex: mark; pointIndex: point + 1
]

{ #category : #'new selection' }
TextEditor >> selectLine [
	"Make the receiver's selection, if it currently consists of an insertion point only, encompass the current line."
	self hasSelection ifTrue:[^self].
	self selectInterval: (self encompassParagraph: self selectionInterval)
]

{ #category : #'new selection' }
TextEditor >> selectMark: mark point: point [
	"Select the specified characters inclusive.
	 Be sure the selection is in view."

	(mark =  self markIndex and: [point + 1 = self pointIndex]) ifFalse:
		[self deselect.
		self selectInvisiblyMark: mark point: point]
]

{ #category : #'new selection' }
TextEditor >> selectWord [
	"Select delimited text or word--the result of double-clicking."

	| openDelimiter closeDelimiter direction match level leftDelimiters rightDelimiters
	string here hereChar start stop |
	string := self string.
	here := self pointIndex.
	(here between: 2 and: string size)
		ifFalse: ["if at beginning or end, select entire string"
			^self selectFrom: 1 to: string size].
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
	direction > 0
		ifTrue: [self selectFrom: start to: here - 1]
		ifFalse: [self selectFrom: here + 1 to: stop]
]

{ #category : #'nonediting/nontyping keys' }
TextEditor >> selectWord: aKeyboardEvent [

	self closeTypeIn.
	self selectWord.
	^ true
]

{ #category : #'accessing-selection' }
TextEditor >> selection [
	"Answer the text in the paragraph that is currently selected."

	^self text copyFrom: self startIndex to: self stopIndex - 1 
]

{ #category : #'accessing-selection' }
TextEditor >> selectionAsStream [
	"Answer a ReadStream on the text in the paragraph that is currently 
	selected."

	^ReadStream
		on: (self string copyFrom: self startIndex to: self stopIndex - 1)
]

{ #category : #'accessing-selection' }
TextEditor >> selectionInterval [
	"Answer the interval that is currently selected."

	^self startIndex to: self stopIndex - 1 
]

{ #category : #accessing }
TextEditor >> selectionPosition: aString [

	| startIndex |
	startIndex := self startIndex.
	^[
		| bottomLeft topLeft index |
		index := startIndex - aString size.
		self selectInvisiblyFrom: index to: index - 1.
		bottomLeft := self paragraph selectionRects first bottomLeft.
		topLeft := self morph owner submorphBounds topLeft.
		topLeft + bottomLeft ]
			ensure: [ self selectInvisiblyFrom: startIndex to: startIndex - 1 ]
]

{ #category : #private }
TextEditor >> setEmphasisHere [
	self editingState emphasisHere: ((self text attributesAt: (self pointIndex - 1 max: 1) forStyle: self textStyle)
					select: [:att | att mayBeExtended])
]

{ #category : #'typing support' }
TextEditor >> setEmphasisHereFromText [

	self setEmphasisHereFromTextForward: true
]

{ #category : #'typing support' }
TextEditor >> setEmphasisHereFromTextForward: f [

	| i t forward delta prevIsSeparator nextIsSeparator |
	i := self pointIndex.
	t := self text.
	"Try to set emphasisHere correctly after whitespace.
	Most important after a cr, i.e. at the start of a new line"
	t ifEmpty: [ 
		prevIsSeparator := false.
		nextIsSeparator := false ]
	ifNotEmpty: [  
		prevIsSeparator :=  i > 1 and: [ (t at: i-1) isSeparator ].
		nextIsSeparator := i <= t size and: [ (t at: i) isSeparator ]].
	forward := prevIsSeparator = nextIsSeparator
		ifTrue: [ f ]
		ifFalse: [ nextIsSeparator ].
	delta := forward ifTrue: [ 1 ] ifFalse: [ 0 ].
	self editingState emphasisHere: ((t attributesAt: (i - delta max: 1)) select: [:att | att mayBeExtended]).
	
]

{ #category : #private }
TextEditor >> setIndices: shiftPressed forward: forward [
	"Little helper method that sets the moving and fixed indices according to some flags."
	| indices |
	indices := Dictionary new.
	self flag: 'to be reviewed'.
	shiftPressed
		ifTrue: [
			indices at: #moving put: self pointIndex.
			indices at: #fixed put: self markIndex
		] ifFalse: [
			forward
				ifTrue:[
					indices at: #moving put: self stopIndex.
					indices at: #fixed put: self startIndex.
				] ifFalse: [
					indices at: #moving put: self startIndex.
					indices at: #fixed put: self stopIndex.
				]
		].
	^ indices
]

{ #category : #'menu messages' }
TextEditor >> setSearch: aString [
	"Make the current selection, if any, be the current search string."
	self findText: aString isRegex: false.
	^ true
]

{ #category : #'menu messages' }
TextEditor >> setSearchString [
	"Make the current selection, if any, be the current search string."
	self closeTypeIn.
	self setSearch: self selection string.
	^ true
]

{ #category : #'nonediting/nontyping keys' }
TextEditor >> setSearchString: aKeyboardEvent [
	"Establish the current selection as the current search string."
	^ self setSearchString
]

{ #category : #'menu messages' }
TextEditor >> setSelectorSearch: aStringOrText [ 
	"Make the current selection as a selector search in current FindReplaceService."
	| regex |
	regex := aStringOrText asString trimBoth.
	regex := regex copyReplaceAll: '#' with: ''.
	regex := regex copyReplaceAll: ' ' with: ''.
	self findText: regex isRegex: false caseSensitive: true entireWordsOnly: false.
	^ true
]

{ #category : #'menu declaration' }
TextEditor >> shiftedMenuKeyword [
	^ #textEditorShiftedMenu

]

{ #category : #'pluggable menus' }
TextEditor >> shiftedTextPaneMenuRequest [
	"The user chose the more... branch from the text-pane menu."

	^ self pluggableYellowButtonActivity: true
]

{ #category : #'menu declaration' }
TextEditor >> shiftedYellowButtonMenu [
	^ (PragmaMenuBuilder 
			pragmaKeyword: self shiftedMenuKeyword
			model: nil) menu.

]

{ #category : #'accessing-selection' }
TextEditor >> startBlock [
	^ self editingState pointBlock min: self editingState markBlock
]

{ #category : #events }
TextEditor >> startDrag: event [
	
	self morph startDrag: (event translatedBy: self morph editView topLeft)
]

{ #category : #'accessing-selection' }
TextEditor >> startIndex [
	^ self startBlock stringIndex
]

{ #category : #'typing support' }
TextEditor >> startOfTyping [
	^ self editingState startOfTyping  
]

{ #category : #'typing support' }
TextEditor >> startOfTyping: anIntegerIndex [
	self editingState startOfTyping:  anIntegerIndex
]

{ #category : #initialization }
TextEditor >> stateArray [
	^ Array with: self editingState
]

{ #category : #initialization }
TextEditor >> stateArrayPut: stateArray [
	editingState := stateArray at: 1.

]

{ #category : #'accessing-selection' }
TextEditor >> stopBlock [
	^ self editingState pointBlock max: self editingState markBlock
]

{ #category : #'accessing-selection' }
TextEditor >> stopIndex [
	^ self stopBlock stringIndex
]

{ #category : #'mvc compatibility' }
TextEditor >> storeSelectionInParagraph [
	self theme currentSettings haveSelectionTextColor 
		ifTrue: [
			self text removeAttribute: TextSelectionColor primarySelection.
			self text addAttribute: TextSelectionColor primarySelection from: self startIndex to: self stopIndex - 1].
	self paragraph selectionStart: self startBlock selectionStop: self stopBlock
]

{ #category : #accessing }
TextEditor >> string [

	^self text string
]

{ #category : #'editing keys' }
TextEditor >> swapChars: aKeyboardEvent [
	"Triggered byCmd-Y;.  Swap two characters, either those straddling the insertion point, or the two that comprise the selection.  Suggested by Ted Kaehler.  "

	| currentSelection aString chars |
	(chars := self selection) size = 0
		ifTrue:
			[currentSelection := self pointIndex.
			self selectMark: currentSelection - 1 point: currentSelection]
		ifFalse:
			[chars size = 2
				ifFalse:
					[morph flash. ^ true]
				ifTrue:
					[currentSelection := self pointIndex - 1]].
	aString := self selection string.
	self replaceSelectionWith: (Text string: aString reversed attributes: self emphasisHere).
	self selectAt: currentSelection + 1.
	^ true
]

{ #category : #accessing }
TextEditor >> text [
	"Answer the text of the paragraph being edited."

	^self paragraph text
]

{ #category : #accessing }
TextEditor >> textStyle [
	^ self paragraph textStyle
]

{ #category : #accessing }
TextEditor >> theme [
	^ Smalltalk ui theme 
]

{ #category : #accessing }
TextEditor >> totalTextHeight [

	^self paragraph lines last bottom
]

{ #category : #accessing }
TextEditor >> transformFrom: owner [
	^morph transformFrom: owner
]

{ #category : #events }
TextEditor >> transformedFrom: uberMorph [

	^ self morph transformedFrom: uberMorph
]

{ #category : #'menu messages' }
TextEditor >> undo [
	"Undo  previous edit."
	self closeTypeIn.
	self editingState undo ifFalse: [morph flash]. 

]

{ #category : #'editing keys' }
TextEditor >> undo: aKeyboardEvent [ 
	"Undo the last edit."

	self undo.
	^true
]

{ #category : #'undoers-redoers' }
TextEditor >> undoRedoExchange: aninterval with: anotherInterval [
	self selectInvisiblyFrom: aninterval first to: aninterval last.
	self exchangeWith: anotherInterval

]

{ #category : #'undoers-redoers' }
TextEditor >> undoTypeIn: aText interval: anInterval [
	self selectInterval: anInterval.
	self replace: anInterval with: aText and:
		[self selectInterval: (anInterval first to: anInterval first - 1)].

]

{ #category : #'accessing-selection' }
TextEditor >> unselect [
	self markBlock: self pointBlock copy
]

{ #category : #private }
TextEditor >> updateSelectionFromEvent: event [

	| clickPoint b | 

	clickPoint := event cursorPoint.
	b := self paragraph characterBlockAtPoint: clickPoint.
	
	self editingState markBlock: b.
	self editingState pointBlock: b.
	
	self storeSelectionInParagraph
]

{ #category : #accessing }
TextEditor >> userHasEdited [
	"Note that my text is free of user edits."
	morph notNil ifTrue:[ morph hasUnacceptedEdits: true ]
]

{ #category : #accessing }
TextEditor >> visibleHeight [

	^morph owner bounds height

]

{ #category : #settings }
TextEditor >> walkAlongDisplayedLine [
	^ self class walkAlongDisplayedLine
]

{ #category : #accessing }
TextEditor >> wordAtCaret [

	^self paragraph text asString wordBefore: self startIndex - 1

]

{ #category : #'menu messages' }
TextEditor >> yellowButtonActivity [
	"This normally opens a popup menu. Determine the selected
	item and, if one is selected, then send the corresponding message
	to either the model or the receiver."

	^ self pluggableYellowButtonActivity: false
]

{ #category : #events }
TextEditor >> yellowButtonDown: anEvent [
	"special case for right/yellobutton click.
	if clicking outside the current selection select the word."
	(self paragraph selectionContainsPoint: anEvent cursorPoint)
		ifFalse: [
			self mouseMove: anEvent.
			self selectWord ].
]

{ #category : #'menu declaration' }
TextEditor >> yellowButtonMenu [
	^ (PragmaMenuBuilder 
			pragmaKeyword: self editorMenuKeyword
			model: nil) menu.
]

{ #category : #'mvc compatibility' }
TextEditor >> zapSelectionWith: aText [
	| start stop |
	morph canChangeText ifFalse: [^ self].
	start := self startIndex.
	stop := self stopIndex.
	(aText isEmpty and: [stop > start]) ifTrue: [
		"If deleting, then set emphasisHere from 1st character of the deletion"
		self editingState emphasisHere: ((self text attributesAt: start) select: [:att | att mayBeExtended])].
	(start = stop and: [ aText size = 0 ]) ifFalse: [
		self paragraph replaceFrom: start to: stop - 1 with: aText.
		self markIndex: start; pointIndex: start + aText size.
		self editingState previousInterval: self selectionInterval selection: self selection.
		self userHasEdited  " -- note text now dirty" ].

]
