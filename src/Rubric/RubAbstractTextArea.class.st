"
I am a re-implementation of TextMorph. I'm intended as a temporary solution. Soon, I will be replaced by, or integrated with, TxText, a beautiful new text toolkit.

About the contextual menu
By default, the menu is given by the editingMode.
The model can implement a #menu method to impose a specific menu.
To change the way the menu is looked-up, one can also change the getMenuPolicy.
This menu retrieving algorithm is implemented by a dedicated objet, hold by the RubAbstractTextArea>>#getMenuPolicy instance variable. This dedicated object implements a #lookupMenu method for this.
By default, it is the textArea itself (see RubAbstractTextArea>>defaultGetMenuPolicy). 
The policy can be changed with RubAbstractTextArea>>#getMenuPolicy:, by passing whatever object that answer to #lookupMenu.

Instance Variables
	editingMode:		<Object>
	editingState:		<Object>
	editor:		<Object>
	hasFocus:		<Object>
	holder:		<Object>
	margins:		<Object>
	menuAllowed:		<Object>
	model:		<Object>
	paragraph:		<Object>
	readOnly:		<Object>
	scrollPivot:		<Object>
	text:		<Object>
	textColor:		<Object>
	textStyle:		<Object>
	wrapped:		<Object>

editingMode
	- xxxxx

editingState
	- xxxxx

editor
	- xxxxx

hasFocus
	- xxxxx

holder
	- xxxxx

margins
	- xxxxx

menuAllowed
	- xxxxx

model
	- xxxxx

paragraph
	- xxxxx

readOnly
	- xxxxx

scrollPivot
	- xxxxx

text
	- xxxxx

textColor
	- xxxxx

textStyle
	- xxxxx

wrapped
	- xxxxx



"
Class {
	#name : #RubAbstractTextArea,
	#superclass : #Morph,
	#instVars : [
		'model',
		'paragraph',
		'editor',
		'scrollPane',
		'editingState',
		'textStyle',
		'textColor',
		'margins',
		'readOnly',
		'menuAllowed',
		'editingMode',
		'cursor',
		'segments',
		'getMenuPolicy',
		'mouseDownPoint',
		'completionEngine',
		'maxLength',
		'findReplaceService'
	],
	#classVars : [
		'BackgroundColor',
		'CaseSensitiveFinds',
		'DefaultTextColor',
		'HighlightMessageSend',
		'LineNumbersBackgroundColor',
		'LineNumbersFont',
		'LineNumbersTextColor',
		'WalkAlongDisplayedLine'
	],
	#classInstVars : [
		'defaultFindReplaceServiceClass'
	],
	#category : #'Rubric-Editing-Core'
}

{ #category : #settings }
RubAbstractTextArea class >> backgroundColor [
	^ BackgroundColor ifNil: [ self theme backgroundColor ]
]

{ #category : #settings }
RubAbstractTextArea class >> backgroundColor: aColor [
	BackgroundColor := aColor
]

{ #category : #settings }
RubAbstractTextArea class >> caseSensitiveFinds [
	^ CaseSensitiveFinds ifNil: [CaseSensitiveFinds := false] 
]

{ #category : #settings }
RubAbstractTextArea class >> caseSensitiveFinds: aBoolean [
	CaseSensitiveFinds := aBoolean
]

{ #category : #accessing }
RubAbstractTextArea class >> defaultFindReplaceServiceClass [

	^ defaultFindReplaceServiceClass ifNil: [ RubFindReplaceService ]
]

{ #category : #accessing }
RubAbstractTextArea class >> defaultFindReplaceServiceClass: aClass [

	^ defaultFindReplaceServiceClass := aClass
]

{ #category : #settings }
RubAbstractTextArea class >> defaultMaxExtent [

	"Return default large enough size of an infinite area. SmallInteger maxVal on 32-bit systems."
	
	^ 16r3FFFFFFF

]

{ #category : #settings }
RubAbstractTextArea class >> editorFont [
	^ StandardFonts defaultFont
]

{ #category : #'shortcut examples' }
RubAbstractTextArea class >> examplesOfEditorShortcutsOn: aBuilder [
	"No Keymap here, by default, the editor rely on a builtin keymapping engine (see TextEditor and SmallEditor)
	Here are some example on how to declare them if you want to setup different shortcuts
	
	<keymap>

	(aBuilder shortcut: #accept)
		category: #RubTextEditor
		default: $s ctrl win | $s ctrl unix | $s command mac
		do: [ :morph | morph acceptContents ]. 
		
	(aBuilder shortcut: #selectAll) 
		category: #RubTextEditor
		shortcut: $a ctrl win | $a ctrl unix | $a command mac
		do: [ :target | target handleKeymapEdition: [:editor | editor selectAll ] ].

	(aBuilder shortcut: #copySelection) 
		category: #RubTextEditor
		default: $c ctrl win | $c ctrl unix | $c command mac
		do: [ :target | target editor copySelection ].
		
	(aBuilder shortcut: #paste) 
		category: #RubTextEditor
		default: $v ctrl win | $v ctrl unix | $v command mac
		do: [ :target | target handleKeymapEdition: [:editor | editor paste]].
		
	(aBuilder shortcut: #cut) 
		category: #RubTextEditor
		default: $x ctrl win | $x ctrl unix | $x command mac
		do: [ :target :event | target handleKeymapEdition: [:editor | editor cut]  ].
				
	(aBuilder shortcut: #find) 
		category: #RubTextEditor
		default: $f ctrl win | $f ctrl unix | $f command mac
		do: [ :target | target find ].
		
	(aBuilder shortcut: #findAgain) 
		category: #RubTextEditor
		default: $g ctrl win | $g ctrl unix | $g command mac
		do: [ :target | target handleKeymapEdition: [:editor | editor findAgain ] ].
		
	(aBuilder shortcut: #exchange) 
		category: #RubTextEditor
		default: $e ctrl win | $e ctrl unix | $e command mac
		do: [ :target | target handleKeymapEdition: [:editor | editor exchange ] ].
		
	(aBuilder shortcut: #backWord)  
		category: #RubTextEditor
		default: $w ctrl win | $w ctrl unix | $w command mac
		do: [ :target |  target handleKeymapEdition: [:editor | editor backWord ] ].
		
	(aBuilder shortcut: #backWord) 
		category: #RubTextEditor
		default: Character backspace  asShortcut win | Character backspace asShortcut unix | Character backspace asShortcut mac
		do: [ :target :morph :event |  target handleKeymapEdition: [:editor | editor backspace: event ] ].
		
	(aBuilder shortcut: #(swapChars)) 
		category: #RubTextEditor
		default: $y ctrl win | $y ctrl unix | $y command mac
		do: [ :target |  target handleKeymapEdition: [:editor | editor swapChars ] ].

	(aBuilder shortcut: #setSearchString)
		category: #RubTextEditor
		default: $h ctrl win | $h ctrl unix | $h command mac
		do: [ :target | target editor setSearchString ].
		
	(aBuilder shortcut: #cancel) 
		category: #RubTextEditor
		default: $l ctrl win | $l ctrl unix | $l command mac
		do: [ :target | target editor cancel ].
		
	(aBuilder shortcut: #undo) 
		category: #RubTextEditor
		default: $z ctrl win | $z ctrl unix | $z command mac
		do: [ :target | target editor undo ].
		
	(aBuilder shortcut: #redo) 
		category: #RubTextEditor
		default: $j ctrl shift win | $j ctrl shift unix | $j command shift mac
		do: [ :target | target editor redo ].
	
	(aBuilder shortcut: #cursorHome)
		category: #RubTextEditor
		default: Character home ctrl win | Character home ctrl unix | Character home command mac
		do: [ :target :morph :event | target editor cursorHome: event ].
	
	(aBuilder shortcut: #cursorEnd)
		category: #RubTextEditor
		default: Character end ctrl win | Character end ctrl unix | Character end command mac
		do: [ :target :morph :event | target editor cursorEnd: event ].

	(aBuilder shortcut: #cursorHome)
		category: #RubTextEditor
		default: Character home asShortcut win | Character home asShortcut unix | Character home asShortcut mac
		do: [ :target :morph :event | target editor cursorHome: event ].
	
	(aBuilder shortcut: #cursorEnd)
		category: #RubTextEditor
		default: Character end asShortcut win | Character end asShortcut unix | Character end asShortcut mac
		do: [ :target :morph :event | target editor cursorEnd: event ].
	"
]

{ #category : #'shortcut examples' }
RubAbstractTextArea class >> examplesOfSmalltalkEditorShortcutsOn: aBuilder [
	"No Keymap here, by default, the editor rely on a builtin keymapping engine (see TextEditor and SmallEditor)
	Here are some example on how to declare them if you want to setup different shortcuts

	<keymap>
	(aBuilder shortcut: #browseIt)
		category: #RubSmalltalkEditor
		default: $b command mac | $b ctrl win | $b ctrl unix
		do: [ :morph | morph editor browseIt ].
					
	(aBuilder shortcut: #doIt) 
		category: #RubSmalltalkEditor
		default: $d command mac | $d ctrl win | $d ctrl unix
		do: [ :morph | morph doIt ].
			
	(aBuilder shortcut: #inspectIt) 
		category: #RubSmalltalkEditor
		default: $i command mac | $i ctrl win | $i ctrl unix
		do: [ :morph | morph inspectIt ].
		
	(aBuilder shortcut: #implementorsOfIt) 
		category: #RubSmalltalkEditor
		default: $m command mac | $m ctrl win | $m ctrl unix
		do: [ :morph | morph implementorsOfIt ].
		
	(aBuilder shortcut: #sendersOfIt)
		category: #RubSmalltalkEditor
		default: $n command mac | $n ctrl win | $n ctrl unix
		do: [ :morph | morph sendersOfIt ].
		
	(aBuilder shortcut: #printIt) 
		category: #RubSmalltalkEditor
		default: $p command mac | $p ctrl win | $p ctrl unix
		do: [ :morph | morph printIt ].
		"
]

{ #category : #settings }
RubAbstractTextArea class >> highlightMessageSend [
	^ HighlightMessageSend ifNil: [ HighlightMessageSend := false ] 
]

{ #category : #settings }
RubAbstractTextArea class >> highlightMessageSend: aBoolean [
	HighlightMessageSend := aBoolean
]

{ #category : #settings }
RubAbstractTextArea class >> lineNumbersBackgroundColor [
	^ LineNumbersBackgroundColor ifNil: [ LineNumbersBackgroundColor := self theme backgroundColor darker] 
]

{ #category : #settings }
RubAbstractTextArea class >> lineNumbersBackgroundColor: aColor [
	 LineNumbersBackgroundColor := aColor
]

{ #category : #settings }
RubAbstractTextArea class >> lineNumbersFont [
	^ LineNumbersFont ifNil: [ LineNumbersFont := TextStyle default fontOfPointSize: 7] 
]

{ #category : #settings }
RubAbstractTextArea class >> lineNumbersFont: aFont [
	LineNumbersFont := aFont
]

{ #category : #settings }
RubAbstractTextArea class >> lineNumbersTextColor [
	^ LineNumbersTextColor ifNil: [ LineNumbersTextColor := self theme lineNumberColor ]
]

{ #category : #settings }
RubAbstractTextArea class >> lineNumbersTextColor: aColor [
	LineNumbersTextColor := aColor
]

{ #category : #settings }
RubAbstractTextArea class >> rubricSettingsOn: aBuilder [
	<systemsettings>
	(aBuilder group: #Rubric)
		label: 'Rubric editor';
		parent: #codeEditing;
		with: [ (aBuilder setting: #backgroundColor)
				target: self;
				default: Color white;
				description: 'The default editor background color';
				label: 'Background'.
			(aBuilder setting: #textColor)
				target: self;
				description: 'The default editor text color';
				default: Color black;
				label: 'Text color'.
			(aBuilder group: #LineNumbers)
				target: self;
				label: 'Line numbers';
				description: 'line numbers settings';
				with: [ (aBuilder setting: #lineNumbersFont)
						target: self;
						default: (TextStyle default fontOfPointSize: 7);
						description: 'Font used for line numbers';
						label: 'Line numbers font'.
					(aBuilder setting: #lineNumbersTextColor)
						target: self;
						default: Color veryDarkGray;
						description: 'Color used for line numbers';
						label: 'Line numbers color'.
					(aBuilder setting: #lineNumbersBackgroundColor)
						target: self;
						default: (Color r: 0.9198435972629521 g: 0.9198435972629521 b: 0.9198435972629521 alpha: 1.0);
						description: 'Color used for line numbers background';
						label: 'Line numbers background color' ].
			(aBuilder setting: #highlightMessageSend)
				target: self;
				default: true;
				description: 'In a Smalltalk text editor, highlight message sends on mouse over with shift key pressed.';
				label: 'Highlight Message Send' ]
]

{ #category : #settings }
RubAbstractTextArea class >> textColor [
	^ DefaultTextColor ifNil: [ DefaultTextColor := self theme textColor ]  
]

{ #category : #settings }
RubAbstractTextArea class >> textColor: aColor [
	DefaultTextColor := aColor
]

{ #category : #settings }
RubAbstractTextArea class >> walkAlongDisplayedLine [
	^ WalkAlongDisplayedLine ifNil: [WalkAlongDisplayedLine := true] 
]

{ #category : #settings }
RubAbstractTextArea class >> walkAlongDisplayedLine: aBoolean [
	WalkAlongDisplayedLine := aBoolean
]

{ #category : #'dropping/grabbing' }
RubAbstractTextArea >> aboutToBeGrabbedBy: aHand [
	self grabbedAllowed
		ifTrue: [ ^ super aboutToBeGrabbedBy: aHand ].
	^ nil
]

{ #category : #'accessing editor' }
RubAbstractTextArea >> acceptAllowed [

	^ editingMode acceptAllowed
]

{ #category : #editing }
RubAbstractTextArea >> acceptContents [
	"The message is sent when the user hits enter or Cmd-S.
	Accept the current contents and endediting"
	self editingMode acceptAllowed ifFalse: [ ^self ].
	self announce: (RubTextAcceptRequest morph: self).
	self changed
]

{ #category : #layout }
RubAbstractTextArea >> acceptDroppingMorph: aMorph event: evt [
	"This message is sent when a morph is dropped onto me."
	self addMorphFront: aMorph fromWorldPosition: aMorph position.
		"Make a TextAnchor and install it in a run."
]

{ #category : #'accessing text' }
RubAbstractTextArea >> addAttribute: anAttribute [
	self text addAttribute: anAttribute 
]

{ #category : #'accessing cursor' }
RubAbstractTextArea >> addCursor [
	self cursor ifNil: [ self addMorph: (cursor := self newCursor) ]
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> addPrimarySelection [
	self addMorph: self newPrimarySelection.

]

{ #category : #'accessing segments' }
RubAbstractTextArea >> addSegment: aRubTextSegmentMorph [
	| seg |
	seg := aRubTextSegmentMorph inTextArea: self.
	self segments add: seg.
	self addMorphBack: seg.
	^ seg

]

{ #category : #'public accessing' }
RubAbstractTextArea >> allowMenu [
	self menuAllowed: true
]

{ #category : #private }
RubAbstractTextArea >> announce: anAnnouncement [ 
	self announcer announce: anAnnouncement 
]

{ #category : #'accessing text' }
RubAbstractTextArea >> appendText: aStringOrText [
	self
		handleEdit:
			[ self
				beEditableWhile:
					[ self selectInvisiblyFrom: self text size + 1 to: self text size.
					self editor replaceSelectionWith: aStringOrText.
					self selectInvisiblyFrom: self text size + 1 to: self text size ] ]
]

{ #category : #accessing }
RubAbstractTextArea >> backgroundColor [
	^ self color
]

{ #category : #accessing }
RubAbstractTextArea >> backgroundColor: newColor [
	self color: newColor
]

{ #category : #'public accessing' }
RubAbstractTextArea >> beEditable [
	self readOnly
		ifTrue: [ self readOnly: false ]
]

{ #category : #'public accessing' }
RubAbstractTextArea >> beEditableWhile: aBlock [
	| wasEditable |
	wasEditable := self readOnly.
	self readOnly: false.
	aBlock ensure: [ self readOnly:  wasEditable]

]

{ #category : #'public accessing' }
RubAbstractTextArea >> beReadOnly [
	self readOnly
		ifFalse: [ self readOnly: true ]
]

{ #category : #accessing }
RubAbstractTextArea >> borderWidth: newWidth [
	"No border allowed"
	super borderWidth: 0
]

{ #category : #geometry }
RubAbstractTextArea >> bounds [
	^ super bounds ifNil: [ self defaultBounds ]
]

{ #category : #testing }
RubAbstractTextArea >> canChangeText [
	^ self enabled and: [ self readOnly not ]
]

{ #category : #editing }
RubAbstractTextArea >> cancelEdits [
	"The message is sent when the user hits enter or Cmd-L.
	Cancel the current contents and end editing.
	This default implementation does nothing."
	self announce: (RubCancelEditRequested morph: self)

]

{ #category : #settings }
RubAbstractTextArea >> caseSensitiveFinds [
	^ self class caseSensitiveFinds
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> classOfDecoratorNamed: aKey [
	^ RubParagraphDecorator classOfDecoratorNamed: aKey
]

{ #category : #'event handling' }
RubAbstractTextArea >> click: anEvent [
	self
		handleEdit: [ 
			self editor click: anEvent.
			self scrollSelectionIntoView: nil ]
]

{ #category : #'accessing editor' }
RubAbstractTextArea >> closingDelimiters [
	^ self editor closingDelimiters

]

{ #category : #completion }
RubAbstractTextArea >> completionEngine [
	
	^ completionEngine 
	
]

{ #category : #completion }
RubAbstractTextArea >> completionPostAction [
	
	self hasCompletionEngine 
		ifTrue: [ completionEngine closeMenu ]

]

{ #category : #composing }
RubAbstractTextArea >> compose [

	self prepareParagraphToCompose.
	self paragraph compose.
	self markBackgroundColors
]

{ #category : #composing }
RubAbstractTextArea >> compositionRectangle [
	^ scrollPane ifNil: [ self innerBounds ] ifNotNil: [ self innerBounds topLeft extent: scrollPane scrollBounds extent ]
]

{ #category : #copying }
RubAbstractTextArea >> copy [
	^ super copy
		text: self text copy
		textStyle: textStyle copy
		color: color
		textColor: textColor 
]

{ #category : #'interactive error protocol' }
RubAbstractTextArea >> correctFrom: start to: stop with: aString [
	self editor correctFrom: start to: stop with: aString
]

{ #category : #'accessing cursor' }
RubAbstractTextArea >> cursor [
	^ cursor

]

{ #category : #'accessing cursor' }
RubAbstractTextArea >> cursorClass [
	^ RubCursor
]

{ #category : #accessing }
RubAbstractTextArea >> cursorWidth [
	^ self cursorClass defaultWidth 
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> decoratorNamed: aKey [
	^self paragraph decoratorNamed: aKey
]

{ #category : #defaults }
RubAbstractTextArea >> defaultBounds [ 
	^ super defaultBounds topLeft corner: self minimumExtent
]

{ #category : #defaults }
RubAbstractTextArea >> defaultColor [
	"Answer the default color/fill style for the receiver. If the settings has been used then honor it, else returns the theme color"

  	^ self class backgroundColor

]

{ #category : #'event handling' }
RubAbstractTextArea >> defaultFindReplaceServiceClass [

	^ self class defaultFindReplaceServiceClass
]

{ #category : #menu }
RubAbstractTextArea >> defaultGetMenuPolicy [
	^ self
]

{ #category : #defaults }
RubAbstractTextArea >> defaultMargins [

	^ Margin left: 6 right: 6 top: 6 bottom: 6
]

{ #category : #defaults }
RubAbstractTextArea >> defaultMenuAllowed [
	^ true
]

{ #category : #defaults }
RubAbstractTextArea >> defaultReadOnly [

	^ false
]

{ #category : #defaults }
RubAbstractTextArea >> defaultTextColor [
	"answer the default color/fill style for the receiver"
	^ self class textColor
]

{ #category : #defaults }
RubAbstractTextArea >> defaultTextStyle [
	| ts f |
	f := self class editorFont.
	ts := f textStyle copy ifNil: [ TextStyle fontArray: { f } ].
	ts defaultFontIndex: (ts fontIndexOf: f).
	^ ts
]

{ #category : #defaults }
RubAbstractTextArea >> defaultYellowButtonMenuEnabled [
	^ self defaultMenuAllowed 
]

{ #category : #'submorphs-add/remove' }
RubAbstractTextArea >> delete [
	self hasFocus
		ifTrue: [ self currentHand newKeyboardFocus: nil ].
	super delete
]

{ #category : #'interactive error protocol' }
RubAbstractTextArea >> deselect [
	self selectFrom: 1 to: 0
]

{ #category : #'event handling' }
RubAbstractTextArea >> doubleClick: anEvent [
	^ self handleEdit: [ self editor doubleClick: anEvent ]
]

{ #category : #drawing }
RubAbstractTextArea >> drawSubmorphsOn: aCanvas [
	"Draw the focus here since we are using inset bounds
	for the focus rectangle."

	super drawSubmorphsOn: aCanvas.
	aCanvas rubParagraph: self paragraph bounds: self drawingBounds color: self textColor.
	(scrollPane isNil and: [ self readOnly not and: [ self hasKeyboardFocus or: [ self hasFindReplaceFocus ] ] ])
		ifTrue: [self drawKeyboardFocusOn: aCanvas ]
]

{ #category : #drawing }
RubAbstractTextArea >> drawSubmorphsOnAthensCanvas: aCanvas [
	"Draw the focus here since we are using inset bounds
	for the focus rectangle."

	super drawSubmorphsOnAthensCanvas: aCanvas.
	self paragraph drawOnAthensCanvas: aCanvas bounds: self drawingBounds color: self textColor.
	(scrollPane isNil and: [ self readOnly not and: [ self hasKeyboardFocus or: [ self hasFindReplaceFocus ] ] ])
		ifTrue: [  self drawKeyboardFocusOnAthensCanvas: aCanvas ]
]

{ #category : #drawing }
RubAbstractTextArea >> drawingBounds [
	^ (self scrollPane isNil or: [ self wrapped ])
		ifTrue: [self innerBounds]
		ifFalse: [ self innerBounds topLeft extent: self class defaultMaxExtent @ self class defaultMaxExtent ]
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> editPrimarySelectionSeparately [
	| view |
	view := self primarySelection readWriteView.
	(view embeddedInMorphicWindowLabeled: 'Selection editing') openInHand.
]

{ #category : #'accessing editing mode' }
RubAbstractTextArea >> editingMode [
	^ editingMode
		ifNil: [ 
			self editingMode: RubPlainTextMode new.
			editingMode ]
]

{ #category : #'accessing editing mode' }
RubAbstractTextArea >> editingMode: anEditingMode [
	editingMode unplug.
	editingMode := anEditingMode.
	editingMode plugin: self.
 
]

{ #category : #'accessing editing state' }
RubAbstractTextArea >> editingState [
	^ editingState ifNil: [editingState := self newEditingState]
]

{ #category : #'accessing editing state' }
RubAbstractTextArea >> editingStateClass [
	^ RubEditingState
]

{ #category : #'accessing editor' }
RubAbstractTextArea >> editor [
	"Return my current editor, or install a new one."
	^ editor ifNil: [ editor := self newEditor ]
]

{ #category : #'accessing editor' }
RubAbstractTextArea >> editorClass [
	"Answer the class used to create the receiver's editor"

	^ RubTextEditor
]

{ #category : #'accessing editing state' }
RubAbstractTextArea >> emphasisHere [
	^ self editingState emphasisHere

]

{ #category : #'accessing editing state' }
RubAbstractTextArea >> emphasisHere: aListOfAttributes [
	self editingState emphasisHere: aListOfAttributes

]

{ #category : #'mock for spec' }
RubAbstractTextArea >> enabled: aBoolean [
]

{ #category : #'event handling' }
RubAbstractTextArea >> escapePressed [
	"do nothing. do not simulate a right click
	because Esc is too useful as a shortcut for other purposes
	to be used for popping a menu"
	"^ self yellowButtonActivity: false"

]

{ #category : #geometry }
RubAbstractTextArea >> extent: aPoint [
	self
		handleBoundsChange: [ 
			self wrapped
				ifTrue: [ 
					(bounds notNil and: [ bounds width = aPoint x ])
						ifTrue: [ ^ self ].
					super extent: ((self paragraph withoutDecorator extentFromClientBottomRight: aPoint) max: self minimumExtent).
					self recomputeSelection ]
				ifFalse: [ super extent: aPoint ] ]
]

{ #category : #'find-replace' }
RubAbstractTextArea >> findAndSelect: aRegex startingAt: anIndex searchBackwards: searchBackwards [
	| where |
	self
		handleEdit: [
			where := self editor
				findAndSelect: aRegex
				startingAt: anIndex
				searchBackwards: searchBackwards.
			self scrollSelectionIntoView: nil].
	^ where
]

{ #category : #'find-replace' }
RubAbstractTextArea >> findNextString: aSubstring startingAt: searchIdx [
	| where |
	self
		handleEdit: [where := self editor findNextString: aSubstring startingAt: searchIdx].
	^ where

]

{ #category : #'find-replace' }
RubAbstractTextArea >> findRegex [
	^ self editor findRegex
]

{ #category : #'event handling' }
RubAbstractTextArea >> findReplaceService [
	^ findReplaceService ifNil: [
		findReplaceService := self defaultFindReplaceServiceClass newFor: self].
]

{ #category : #'find-replace' }
RubAbstractTextArea >> findText [
	^ self editor findText
]

{ #category : #'event handling' }
RubAbstractTextArea >> focusChanged [ 
	super focusChanged.
	self editor focusChanged.
	self changed.

	

]

{ #category : #'accessing text' }
RubAbstractTextArea >> font [
	"Answer the probable font"
	^ self textStyle fonts at: self textStyle defaultFontIndex

]

{ #category : #'accessing text' }
RubAbstractTextArea >> font: aFont [
	| newTextStyle |
	newTextStyle := aFont textStyle copy ifNil: [ TextStyle fontArray: { aFont } ].
	newTextStyle defaultFontIndex: (newTextStyle fontIndexOf: aFont).
	self textStyle: newTextStyle

]

{ #category : #'public accessing' }
RubAbstractTextArea >> forbidMenu [
	self menuAllowed: false
]

{ #category : #composing }
RubAbstractTextArea >> forceCompose [

	self prepareParagraphToCompose.
	self paragraph forceCompose 
]

{ #category : #'accessing cursor' }
RubAbstractTextArea >> forceCursorVisibleWhile: aBlock [
	self cursor
		ifNotNil: [ :cur | 
			| prev |
			prev := cur stayVisible.
			cur stayVisible: true.
			aBlock
				ensure: [ cur stayVisible: prev ] ]
]

{ #category : #'paragraph feedbacks' }
RubAbstractTextArea >> forceExtentTo: aPoint [
	super extent: aPoint
]

{ #category : #'event handling' }
RubAbstractTextArea >> getMenu: shiftKeyState [
	"Ask the getMenuPolicy to lookup the menu to popup if any"

	^ shiftKeyState
		ifTrue: [ self getMenuPolicy lookupShiftMenu ]
		ifFalse: [ self getMenuPolicy lookupMenu ]
]

{ #category : #menu }
RubAbstractTextArea >> getMenuPolicy [
	^ getMenuPolicy ifNil: [ getMenuPolicy := self defaultGetMenuPolicy ]
]

{ #category : #menu }
RubAbstractTextArea >> getMenuPolicy: aGetMenuPolicy [
	getMenuPolicy := aGetMenuPolicy
]

{ #category : #'dropping/grabbing' }
RubAbstractTextArea >> grabbedAllowed [
	^ scrollPane isNil
]

{ #category : #geometry }
RubAbstractTextArea >> handleBoundsChange: aBlock [
	| oldBounds |
	oldBounds := self bounds copy.
	aBlock value.
	oldBounds topLeft ~= self bounds topLeft
		ifTrue: [ self announce: ((RubPositionChanged morph: self) previousBounds: oldBounds)].
	oldBounds extent ~= self bounds extent
		ifTrue: [ 
			self scrollPane ifNotNil: [ :sp | sp textAreaExtentChanged ].
			self announce: ((RubExtentChanged morph: self) previousBounds: oldBounds) ].

]

{ #category : #editing }
RubAbstractTextArea >> handleEdit: editBlock [
	"Ensure that changed areas get suitably redrawn"

	editBlock value.
	self selectionChanged	"Note new selection"
]

{ #category : #'event handling' }
RubAbstractTextArea >> handleKeystroke: anEvent [ 
	"System level event handling."

	anEvent wasHandled
		ifTrue: [^ self].
	(self handlesKeyStroke: anEvent)
		ifFalse: [^ self].
	self keyStroke: anEvent.
	anEvent wasHandled: true.
]

{ #category : #'event handling' }
RubAbstractTextArea >> handleMouseMove: anEvent [
	"Re-implemented to allow for mouse-up move events"

	anEvent wasHandled
		ifTrue: [ ^ self ].	"not interested"
	anEvent hand hasSubmorphs
		ifTrue: [ ^ self ].
	anEvent wasHandled: true.
	self mouseMove: anEvent.
	(anEvent anyButtonPressed and: [ anEvent hand mouseFocus == self ])
		ifFalse: [ ^ self ].
	super handleMouseMove: anEvent
	
]

{ #category : #composing }
RubAbstractTextArea >> handleParagraphChange: aBlock [
	aBlock value.
	self compose.
	self changed
]

{ #category : #private }
RubAbstractTextArea >> handleReturnKey [
	| answer |
	answer := RubReturnEntered morph: self.
	self announce: answer.
	answer accepted
		ifTrue: [ self editor textWasAccepted ].
	^ answer accepted
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> handleSelectionChange: aBlock [
	| prevMarkBlock prevPointBlock |
	self flag: #pharoFixMe. "hack here because text segments are not well designed regarding text editing".
	self primarySelection ifNil: [ self addPrimarySelection  ].
	prevMarkBlock := self markBlock.
	prevPointBlock := self pointBlock.
	aBlock value.

	(prevMarkBlock ~= self markBlock or: [ prevPointBlock ~= self pointBlock ]) ifFalse: [ ^ self ].
	
	"have to invalidate the full surface because of the selection"
	self invalidRect: (self expandFullBoundsForDropShadow: self drawingBounds).
	self scrollPane ifNotNil: [ :sp | sp selectionChanged ].
	self announce: (RubSelectionChanged from: self previousMarkBlock: prevMarkBlock previousPointBlock: prevPointBlock)
]

{ #category : #'event handling' }
RubAbstractTextArea >> handlesKeyboard: evt [
	^true
]

{ #category : #'event handling' }
RubAbstractTextArea >> handlesMouseDown: evt [
	^ self innerBounds containsPoint: evt cursorPoint
]

{ #category : #'event handling' }
RubAbstractTextArea >> handlesMouseOver: evt [ 
	"Do I want to receive mouseEnter: and mouseLeave: when the button is up and the hand is empty?"
	^ self enabled
]

{ #category : #completion }
RubAbstractTextArea >> hasCompletionEngine [
	
	^ completionEngine isNil not
	
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> hasDecorator: aDecorator [
	^ self paragraph hasDecorator: aDecorator
	
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> hasDecoratorNamed: aKey [
	^ self paragraph hasDecoratorNamed: aKey
	
]

{ #category : #'find-replace' }
RubAbstractTextArea >> hasFindReplaceFocus [
	^ self findReplaceService dialogIsActiveFor: self
]

{ #category : #'accessing editing state' }
RubAbstractTextArea >> hasFocus [
	^ ( editingState ifNil: [^ false ] ) hasFocus
]

{ #category : #'accessing editing state' }
RubAbstractTextArea >> hasFocus: aBoolean [
	^ self editingState hasFocus: aBoolean 
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> hasSelection [
	^ self editor hasSelection 
]

{ #category : #'event handling' }
RubAbstractTextArea >> hideOverEditableTextCursor [  
	self currentHand showTemporaryCursor: nil
	
]

{ #category : #accessing }
RubAbstractTextArea >> highlightMessageSend [
	^ self class highlightMessageSend
]

{ #category : #initialization }
RubAbstractTextArea >> initialize [
	super initialize.
	self compose.
	self addCursor.
	self plugFindReplace.
	DefaultTextColor := self theme textColor
]

{ #category : #keymapping }
RubAbstractTextArea >> initializeShortcuts: aKMDispatcher [
	"we delegate the creation of default shortcuts to the editor
	because it is the one that knows more details about the goal of editing"
	super initializeShortcuts: aKMDispatcher.
	self editor initializeShortcuts: aKMDispatcher
]

{ #category : #accessing }
RubAbstractTextArea >> interactive [
	^ self editingMode interactive
]

{ #category : #testing }
RubAbstractTextArea >> isReadOnly [
	^ self readOnly
]

{ #category : #'event handling' }
RubAbstractTextArea >> keyDown: anEvent [
	"Handle a keystroke event."
	anEvent key = KeyboardKey enter
		ifTrue: [ self handleReturnKey
				ifTrue: [ ^ self ] ].

	anEvent hand anyButtonPressed
		ifTrue: [ ^ self ].
	self scrollPane
		ifNotNil: [ :sp | 
			(sp scrollByKeyboard: anEvent)
				ifTrue: [ ^ self ] ].
	anEvent isUserInterrupt
		ifTrue: [ ^ self ].
	self handleEdit: [ self editor keyDown: anEvent ].
]

{ #category : #'event handling' }
RubAbstractTextArea >> keyStroke: anEvent [
	"Handle a keystroke event."
	anEvent hand anyButtonPressed
		ifTrue: [ ^ self ].
	self handleEdit: [ self editor keystroke: anEvent ].
	self scrollSelectionIntoView: nil
]

{ #category : #'event handling' }
RubAbstractTextArea >> keyboardFocusChange: aBoolean [
	aBoolean
		ifTrue: [
			self hasFocus: true.
			self showOverEditableTextCursor ]
		ifFalse: [ 
			self hasFocus: false.
			self hideOverEditableTextCursor ].
	super keyboardFocusChange: aBoolean.
	self focusChanged.

]

{ #category : #accessing }
RubAbstractTextArea >> lineNumbersBackgroundColor [
	^ self class lineNumbersBackgroundColor
]

{ #category : #accessing }
RubAbstractTextArea >> lineNumbersTextColor [
	^ self class lineNumbersTextColor 

]

{ #category : #'accessing paragraph' }
RubAbstractTextArea >> lines [
	^ self paragraph lines
]

{ #category : #menu }
RubAbstractTextArea >> lookupMenu [
	"default implementation of the algorithm that lookup the menu"

	^ self model 
		ifNil: [ self editingMode menu ] 
		ifNotNil: [ :m | m menu ifNil: [ self editingMode menu ] ]
]

{ #category : #menu }
RubAbstractTextArea >> lookupShiftMenu [
	"default implementation of the algorithm that lookup the menu"

	| default |
	default := [ self editingMode shiftMenu ].
	^ self model 
		ifNil: [ default value ] 
		ifNotNil: [ :m | m shiftMenu ifNil: [ default value ] ]
]

{ #category : #accessing }
RubAbstractTextArea >> margins [
	^  margins ifNil: [margins := self defaultMargins ]
]

{ #category : #accessing }
RubAbstractTextArea >> margins: aMargin [
	"Adjust margin to always be able to display a cursor to right of text bounds"
	| m |
	(m := aMargin asMargin) right < self cursorWidth
		ifTrue: [ m
				setTop: m top
				left: m left
				bottom: m bottom
				right: self cursorWidth ].
	margins := m
]

{ #category : #composing }
RubAbstractTextArea >> markBackgroundColors [
	"Scan through text to find spans of TextBackgroundColor, and mark them using TextBackgroundColorSegmentMorph."

	self text runs
		withStartStopAndValueDo: [ :start :stop :value | 
			value do: [ :v | 
					(v isKindOf: TextBackgroundColor)
						ifTrue: [ self addSegment: 
							(RubTextBackgroundColorSegmentMorph
								color: v color
								from: start
								to: stop+1) ] ] ] 
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> markBlock [
	^ self editingState markBlock
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> markBlock: aCharacterBlock [
	self handleSelectionChange: [ self editingState markBlock:  aCharacterBlock]
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> markBlock: markCharacterBlock pointBlock: pointCharacterBlock [
	self handleSelectionChange: [ self editingState markBlock: markCharacterBlock pointBlock: pointCharacterBlock ]
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> markIndex [
	^ self editingState markIndex

]

{ #category : #'accessing selection' }
RubAbstractTextArea >> markIndex: markIndex pointIndex: pointIndex [
	self handleSelectionChange: [ self editingState markIndex: markIndex pointIndex: pointIndex ]
]

{ #category : #accessing }
RubAbstractTextArea >> maxLength [
	"Answer the maximum number of characters that may be typed."

	^ maxLength 
]

{ #category : #accessing }
RubAbstractTextArea >> maxLength: anInteger [
	"Set the maximum number of characters that may be typed."

	maxLength := anInteger max: 0
]

{ #category : #accessing }
RubAbstractTextArea >> menuAllowed [
	^ menuAllowed ifNil: [ menuAllowed := self defaultMenuAllowed  ]
]

{ #category : #accessing }
RubAbstractTextArea >> menuAllowed: aBoolean [
	menuAllowed := aBoolean
]

{ #category : #geometry }
RubAbstractTextArea >> minExtent [
	| minH |
	minH := scrollPane ifNil: [ 0 ] ifNotNil: [ 60 ].
	^ ((self textStyle defaultFont widthOfString: 'XXX') + self margins left + self margins right)
		@ (self textStyle lineGrid + self margins top + self margins bottom)
]

{ #category : #geometry }
RubAbstractTextArea >> minimumExtent [
	^ self minExtent
]

{ #category : #accessing }
RubAbstractTextArea >> model [ 
	^model
]

{ #category : #accessing }
RubAbstractTextArea >> model: aModel [
	model := aModel
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> modifySelection: aCharacterBlock [
	"the aCharacterBlock becomes always the new point block. Whether the old point block or
	the old mark block becomes the new mark block, depends on the distance. If the new character block
	is near the old point block, we leave the old mark block unchaned."

	(self pointBlock distance: aCharacterBlock) < (self markBlock distance: aCharacterBlock)
		ifTrue: [ self pointBlock: aCharacterBlock ]
		ifFalse: [ self markBlock: self pointBlock pointBlock: aCharacterBlock ]
]

{ #category : #'event handling' }
RubAbstractTextArea >> mouseDown: evt [
	"Make this TextMorph be the keyboard input focus, if it isn't  
	already, and repond to the text selection gesture.
	Changed to not take keyboard focus if an owner is a
	PluggableTextMorph that doesn't want focus."

	self doAnnounce: (MorphClosePopups morph: self).

	(evt yellowButtonPressed and: [ evt commandKeyPressed not ])
		ifTrue: [ ^ self yellowButtonActivity: evt shiftPressed ].	"First check for option (menu) click"
	(self paragraph click: evt for: self model controller: self)
		ifTrue: [ self click: evt.
			evt hand releaseKeyboardFocus: self.
			^ self ].
	(evt yellowButtonChanged or: [ evt commandKeyPressed ])
		ifTrue: [ (self yellowButtonActivity: evt shiftPressed)
				ifTrue: [ ^ self ] ].
	"no matter what, if shift is pressed extend the selection"
	evt shiftPressed
		ifTrue: [ ^ self mouseMove: evt ].
	mouseDownPoint := evt cursorPoint.
	(self hasFocus or: [ self editor hasSelection not ])
		ifTrue:
			[ | selectors |
			self scrollPivot: evt hand position.
			selectors := Array
				with: #click:
				with: #doubleClick:
				with: nil
				with: nil.
			evt hand
				waitForClicksOrDrag: self
				event: evt
				selectors: selectors
				threshold: 5 ].
	self hasKeyboardFocus
		ifFalse: [ self takeKeyboardFocus ]
]

{ #category : #'event handling' }
RubAbstractTextArea >> mouseEnter: evt [
	"Handle a mouseEnter event, meaning the mouse just entered my bounds with no button pressed."
	super mouseEnter: evt.
	self showOverEditableTextCursor
	
]

{ #category : #'event handling' }
RubAbstractTextArea >> mouseLeave: evt [
	"Handle a mouseLeave event, meaning the mouse just left my bounds with no button pressed."
	super mouseLeave: evt.
	self hideOverEditableTextCursor
	
]

{ #category : #'event handling' }
RubAbstractTextArea >> mouseMove: evt [
   self paragraph move: evt for: model controller: self editor.
	evt redButtonPressed
		ifFalse: [ ^ self ].
	evt shiftPressed
		ifTrue: [ self modifySelection: (self paragraph characterBlockAtPoint: evt cursorPoint) ]
		ifFalse: [ mouseDownPoint
				ifNotNil: [ self markBlock: (self paragraph characterBlockAtPoint: mouseDownPoint) pointBlock: (self paragraph characterBlockAtPoint: evt cursorPoint) ]
				ifNil: [ self markBlock: (self paragraph characterBlockAtPoint: evt cursorPoint) ] ].
	self editor storeSelectionInText.

]

{ #category : #'event handling' }
RubAbstractTextArea >> mouseUp: evt [
	self scrollPivot: nil.
	(self boundsInWorld containsPoint: self currentHand position)
		ifFalse: [ self hideOverEditableTextCursor ].
	mouseDownPoint := nil
]

{ #category : #'accessing cursor' }
RubAbstractTextArea >> newCursor [
	^ self cursorClass new
]

{ #category : #'accessing editing state' }
RubAbstractTextArea >> newEditingState [
	^ self editingStateClass new textArea: self
]

{ #category : #accessing }
RubAbstractTextArea >> newEditor [
	"Return my current editor, or install a new one."
	^ self editorClass forTextArea: self
]

{ #category : #private }
RubAbstractTextArea >> newParagraph [
	| newParagraph |
	newParagraph := RubOpeningClosingDelimiterDecorator next: RubParagraph new.
	newParagraph textArea: self.
	newParagraph container: self compositionRectangle.
	^ newParagraph
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> newPrimarySelection [
	^ RubPrimarySelectionMorph inTextArea: self from: self markIndex to: self pointIndex.

]

{ #category : #editing }
RubAbstractTextArea >> newSizeAfterUpdateFrom: start to: stop with: aText [
	" compute and return my text new size avec an insertion/replacement with aText.
	the receiver is not update "

	| replSize |
	" replSize is the additional size"
	replSize := aText size - (stop - start + 1).
	^ self text size + replSize
]

{ #category : #'interactive error protocol' }
RubAbstractTextArea >> nextTokenFrom: start direction: dir [
	^ self editor nextTokenFrom: start direction: dir
]

{ #category : #accessing }
RubAbstractTextArea >> notificationStrategy: aStrategy [
	self editor notificationStrategy: aStrategy
]

{ #category : #'interactive error protocol' }
RubAbstractTextArea >> notify: aString at: anInteger in: aStream [
	^ self editor notify: aString at: anInteger in: aStream
]

{ #category : #composing }
RubAbstractTextArea >> offset [
	^ scrollPane
		ifNil: [ 0@0 ]
		ifNotNil: [ :h | scrollPane offset ]
]

{ #category : #'find-replace' }
RubAbstractTextArea >> openFindDialog [
	self sharesFindReplace 
		ifTrue: [ self announce: RubFindReplaceWindowRequired ]
		ifFalse: [self flash]
]

{ #category : #'accessing editor' }
RubAbstractTextArea >> openingDelimiters [
	^ self editor openingDelimiters

]

{ #category : #private }
RubAbstractTextArea >> paragraph [
	"Paragraph instantiation is lazy -- create it only when needed"

	paragraph
		ifNil: [
			paragraph := self newParagraph.
			self compose.
			self selectAll].
	^ paragraph 
]

{ #category : #'paragraph feedbacks' }
RubAbstractTextArea >> paragraphReplacedTextFrom: start to: stop with: aText [
	"A text change has taken place in my paragraph, as a result of editing and I must be updated"
	self
		handleBoundsChange: [ 
			self wrapped
				ifTrue: [ self updateBottomFromParagraph ]
				ifFalse: [ self updateExtentFromParagraph ] ].
	self scrollPane ifNotNil: [ :sp | sp textChanged ].
	self announce: (RubTextChanged from: start to: stop with: aText).
	self markBackgroundColors .

]

{ #category : #'paragraph feedbacks' }
RubAbstractTextArea >> paragraphWasComposedFrom: startIndex to: stopIndex [
	self
		handleBoundsChange: [ 
			self wrapped
				ifTrue: [ self updateBottomFromParagraph ]
				ifFalse: [ self updateExtentFromParagraph ] ]
]

{ #category : #initialization }
RubAbstractTextArea >> plugFindReplace [
	self announcer 
		when:  MorphGotFocus send: #whenTextAreaGotFocus: to: self findReplaceService;
	 	when:  MorphLostFocus send: #whenTextAreaLostFocus: to: self findReplaceService;	
		when:  RubSelectionChanged send: #whenTextAreaSelectionChanged: to: self findReplaceService
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> pointBlock [
	^ self editingState pointBlock
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> pointBlock: aCharacterBlock [
	self handleSelectionChange: [ self editingState pointBlock: aCharacterBlock ]
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> pointIndex [
	^ self editingState pointIndex
]

{ #category : #composing }
RubAbstractTextArea >> prepareParagraphToCompose [
	self paragraph container: self compositionRectangle.

]

{ #category : #'accessing selection' }
RubAbstractTextArea >> primarySelection [
	^ self submorphThat: [ :sm | sm isKindOf: RubPrimarySelectionMorph ] ifNone:  [ ]

]

{ #category : #'accessing selection' }
RubAbstractTextArea >> primarySelectionBounds [
	^ self primarySelection bounds
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> primarySelectionColor [
	^ self primarySelection ifNil: [ Color transparent] ifNotNil: [:ps | ps color ]
]

{ #category : #geometry }
RubAbstractTextArea >> privateMoveBy: delta [
	self
		handleBoundsChange: [ 
			self paragraph moveBy: delta truncated.
			super privateMoveBy: delta truncated ]
]

{ #category : #editing }
RubAbstractTextArea >> privateReplaceFrom: start to: stop with: aText [
	self maxLength
		ifNotNil: [ | newSize |
			newSize := self newSizeAfterUpdateFrom: start to: stop with: aText.
			newSize > self maxLength
				ifTrue: [ | t |
					t := self text.
					t replaceFrom: start to: stop with: aText.
					self paragraph
						replaceFrom: 1
						to: self text size
						with: (t copyFrom: 1 to: maxLength).
					^ self ] ].
	self paragraph replaceFrom: start to: stop with: aText
]

{ #category : #private }
RubAbstractTextArea >> privateSetParagraph: aParagraph [
	paragraph := aParagraph
]

{ #category : #private }
RubAbstractTextArea >> privateSetTextStyle: aTextStyle [
	textStyle := aTextStyle
]

{ #category : #'accessing text' }
RubAbstractTextArea >> privateText: stringOrText [
	"Accept new text contents."

	| fontNumber |
	stringOrText isText
		ifTrue: [ self paragraph text: stringOrText ]
		ifFalse: [ 
			fontNumber := self textStyle defaultFontIndex.
			self paragraph text: (Text string: stringOrText asString attributes: {(TextFontChange fontNumber: fontNumber)}) ]
]

{ #category : #private }
RubAbstractTextArea >> privateTextStyle: aTextStyle [
	textStyle := aTextStyle
]

{ #category : #accessing }
RubAbstractTextArea >> readOnly [
	^readOnly ifNil: [ readOnly := self defaultReadOnly ]
]

{ #category : #accessing }
RubAbstractTextArea >> readOnly: aBoolean [
	 readOnly := aBoolean
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> recomputeSelection [
	"The same characters are selected but their coordinates may have changed.
	Redetermine the selection according to the start and stop block indices; 
	do not highlight."

	self markIndex: self markIndex pointIndex: self pointIndex
]

{ #category : #'multi level undo' }
RubAbstractTextArea >> redoTypeIn: aText interval: anInterval [ 
	self handleEdit: [self editor redoTypeIn: aText interval: anInterval]
]

{ #category : #caching }
RubAbstractTextArea >> releaseCachedState [
	super releaseCachedState.
	self releaseParagraph
]

{ #category : #'accessing editing state' }
RubAbstractTextArea >> releaseEditingState [
	editingState ifNotNil: [ 
		editingState unplug.
		editingState := nil]
]

{ #category : #'accessing editor' }
RubAbstractTextArea >> releaseEditor [
	"Release the editor for my paragraph."

	editor
		ifNotNil: [ 
			editor unplug.
			editor := nil ]
]

{ #category : #private }
RubAbstractTextArea >> releaseParagraph [
	paragraph
		ifNotNil: [ 
			self withoutAnyDecorator.
			paragraph unplug.
			paragraph := nil ].

]

{ #category : #'accessing cursor' }
RubAbstractTextArea >> removeCursor [
	self cursor ifNotNil: [ :c | 
		self cursor aboutToBeRemoved.
		self removeMorph: c ].
	cursor := nil
]

{ #category : #'accessing segments' }
RubAbstractTextArea >> removeSegment: aRubTextSegmentMorph [
	self announcer unsubscribe: aRubTextSegmentMorph.
	self segments remove: aRubTextSegmentMorph ifAbsent: [].

]

{ #category : #'find-replace' }
RubAbstractTextArea >> replaceAll: aRegex with: aText [
	self
		handleEdit: [self editor replaceAll: aRegex with: aText].

]

{ #category : #'find-replace' }
RubAbstractTextArea >> replaceAll: aRegex with: aText startingAt: startIdx [
	self
		handleEdit: [self editor replaceAll: aRegex with: aText startingAt: startIdx].

]

{ #category : #editing }
RubAbstractTextArea >> replaceFrom: start to: stop with: aText [
	self
		handleEdit: [ self editor replaceTextFrom: start to: stop with: aText ]

]

{ #category : #'find-replace' }
RubAbstractTextArea >> replaceSelectionWith: aText [
	self
		handleEdit: [self editor replaceSelectionWith: aText]
]

{ #category : #'dropping/grabbing' }
RubAbstractTextArea >> resistsRemoval [
	^ self grabbedAllowed not
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> restoreSelectionIndexesAfter: aBlock [
	| prevStart prevStop |
	prevStart := self markIndex min: self pointIndex.
	prevStop := self pointIndex max: self markIndex.
	aBlock value.
	self selectFrom: prevStart to: prevStop - 1
]

{ #category : #composing }
RubAbstractTextArea >> scrollBounds [
	^ scrollPane
		ifNil: [ self innerBounds  ]
		ifNotNil: [ :h | scrollPane scrollBounds ]
]

{ #category : #accessing }
RubAbstractTextArea >> scrollPane [
	^ scrollPane
]

{ #category : #accessing }
RubAbstractTextArea >> scrollPane: aScrollPane [
	scrollPane := aScrollPane.
	self color: Color transparent
]

{ #category : #'accessing editing state' }
RubAbstractTextArea >> scrollPivot [
	^self editingState scrollPivot
]

{ #category : #'accessing editing state' }
RubAbstractTextArea >> scrollPivot: aPoint [
	^self editingState scrollPivot: aPoint
]

{ #category : #'event handling' }
RubAbstractTextArea >> scrollSelectionIntoView: evt [ 
	scrollPane ifNotNil: [ scrollPane scrollSelectionIntoView: evt ]	

]

{ #category : #'accessing segments' }
RubAbstractTextArea >> segments [
	^ segments ifNil: [ segments := OrderedCollection new ]

]

{ #category : #'accessing segments' }
RubAbstractTextArea >> segmentsAtLine: aLineNumber [
	^ self segments select: [ :s | s firstLineIndex = aLineNumber ]
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> select [
	self editor select
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> selectAll [
	self editor selectAll
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> selectFrom: a to: b [
	self editor selectFrom: a to: b
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> selectInvisiblyFrom: start to: stop [
	self editor selectInvisiblyFrom: start to: stop
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> selection [
	^ self editor selection
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> selectionChanged [
	"Invalidate all the selection rectangles. 
	Make sure that any drop shadow is accounted for too."
	paragraph ifNil: [ ^ self ].
	self recomputeSelection.

]

{ #category : #'accessing selection' }
RubAbstractTextArea >> selectionInterval [
	^self editor selectionInterval 
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> selectionRects [
	^ Array
		streamContents: [ :strm | 
			strm nextPutAll: self paragraph selectionRects.
			self cursor ifNotNil: [ strm nextPut: self cursor bounds ] ]
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> selectionStart [
	^ self editingState selectionStart
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> selectionStop [
	^ self editingState selectionStop
]

{ #category : #completion }
RubAbstractTextArea >> setCompletionEngine: anEngine [

	completionEngine := anEngine
]

{ #category : #private }
RubAbstractTextArea >> setEmphasisHere [
	self editor setEmphasisHere
]

{ #category : #'public accessing' }
RubAbstractTextArea >> setTextWith: stringOrText [
	"Accept new text contents."

	self handleParagraphChange: [ self privateText: (self validateTextFrom: stringOrText) ]
]

{ #category : #'find-replace' }
RubAbstractTextArea >> sharesFindReplace [
	^ true
]

{ #category : #'event handling' }
RubAbstractTextArea >> showOverEditableTextCursor [

	| o |

	owner ifNil: [ ^ self ].
	o := owner isWorldMorph
		ifTrue: [ self ]
		ifFalse: [ owner ].
	( o boundsInWorld containsPoint: self currentHand position )
		ifTrue: [ self currentHand showTemporaryCursor: ( self theme overTextCursorFor: self ) ]
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> startIndex [
	^ self selectionStart stringIndex
]

{ #category : #'accessing selection' }
RubAbstractTextArea >> stopIndex [
	^ self selectionStop stringIndex
]

{ #category : #'accessing text' }
RubAbstractTextArea >> string [
	"obtain a string value from the receiver"

	^ self text string
]

{ #category : #'accessing text' }
RubAbstractTextArea >> tabWidth [
	^ self paragraph tabWidth
]

{ #category : #'accessing text' }
RubAbstractTextArea >> tabWidth: anInteger [
	self paragraph tabWidth: anInteger
]

{ #category : #'event handling' }
RubAbstractTextArea >> takeKeyboardFocus [
	"Answer whether the receiver can normally take keyboard focus."
	self takesKeyboardFocus ifFalse: [ ^self ].
	^ super takeKeyboardFocus 
]

{ #category : #testing }
RubAbstractTextArea >> takesKeyboardFocus [
	"Answer whether the receiver can normally take keyboard focus."

	^true
]

{ #category : #'accessing text' }
RubAbstractTextArea >> text [
	^ self paragraph text
]

{ #category : #private }
RubAbstractTextArea >> text: t textStyle: s color: c textColor: tc [
	"Private -- for use only in morphic duplication"	
	self releaseParagraph.
	super text: t textStyle: s color: c textColor: tc.

]

{ #category : #'accessing text' }
RubAbstractTextArea >> textColor [
	^ textColor ifNil: [ textColor := self defaultTextColor ]
]

{ #category : #'accessing text' }
RubAbstractTextArea >> textColor: newColor [
	textColor := newColor.
	self addAttribute: (TextColor color: newColor).
	self changed.
]

{ #category : #'accessing text' }
RubAbstractTextArea >> textFont: aFont [
	self addAttribute: (TextFontReference toFont: aFont).
	self paragraph compose.
	self recomputeSelection.
	self  announce: (RubTextStyleChanged morph: self).

]

{ #category : #'accessing text' }
RubAbstractTextArea >> textStyle [
	^textStyle ifNil: [ textStyle := self defaultTextStyle  ]
]

{ #category : #'accessing text' }
RubAbstractTextArea >> textStyle: aTextStyle [
	self privateTextStyle: aTextStyle.
	self addAttribute: (TextFontChange fontNumber: (textStyle defaultFontIndex)).
	self paragraph compose.
	self recomputeSelection.
	self  announce: (RubTextStyleChanged morph: self).

]

{ #category : #updating }
RubAbstractTextArea >> themeChanged [
	
	(self decoratorNamed: #shoutStyler) ifNotNil: [ :styler | 
		styler refreshStyling 
	].

	super themeChanged
]

{ #category : #structure }
RubAbstractTextArea >> topRendererOrSelf [

	^ scrollPane 
		ifNil: [ super topRendererOrSelf ]
		ifNotNil: [ scrollPane topRendererOrSelf ]
]

{ #category : #'multi level undo' }
RubAbstractTextArea >> undoRedoExchange: aninterval with: anotherInterval [
	self handleEdit: [self editor undoRedoExchange: aninterval with: anotherInterval]
]

{ #category : #'multi level undo' }
RubAbstractTextArea >> undoTypeIn: aText interval: anInterval [ 
	self handleEdit: [self editor undoTypeIn: aText interval: anInterval]
]

{ #category : #private }
RubAbstractTextArea >> unplug [
	self unplugFindReplace.
	self releaseEditingState.
	self releaseParagraph.
	self releaseEditor.
	super unplug
	
]

{ #category : #initialization }
RubAbstractTextArea >> unplugFindReplace [
	self announcer unsubscribe: self findReplaceService

]

{ #category : #'accessing selection' }
RubAbstractTextArea >> unselect [
	self handleSelectionChange: [ self editingState unselect ]
]

{ #category : #'paragraph feedbacks' }
RubAbstractTextArea >> updateBottomFromParagraph [
	paragraph
		ifNotNil: [ 
			| newExtent |
			newExtent := self paragraph extent max: self paragraph minimumExtent.
			self forceExtentTo: self extent x @ newExtent y]
]

{ #category : #'paragraph feedbacks' }
RubAbstractTextArea >> updateExtentFromParagraph [
	(paragraph notNil and: [ bounds notNil ])
		ifTrue: [ 
			| newExtent |
			newExtent := self paragraph extent max: self minimumExtent.
			self forceExtentTo: (newExtent x + self margins right) @ newExtent y]
]

{ #category : #'public accessing' }
RubAbstractTextArea >> updateMarginsWith: aMargin [
	self handleParagraphChange: [self margins: aMargin ]
]

{ #category : #'accessing text' }
RubAbstractTextArea >> updateTextWith: aStringOrText [
	self
		handleEdit: [ self
				beEditableWhile: [ 
					| s |
					s := self validateTextFrom: aStringOrText.
					s = self text
						ifFalse: [ self selectAll.
							self editor replaceSelectionWith: s.
							self deselect ] ] ]
]

{ #category : #'accessing text' }
RubAbstractTextArea >> userString [
	"Do I have a text string to be searched on?"

	^ self text string
]

{ #category : #'accessing text' }
RubAbstractTextArea >> validateTextFrom: aStringOrText [
	^ self maxLength
		ifNil: [ aStringOrText ]
		ifNotNil: [ aStringOrText size <= self maxLength
				ifFalse: [ aStringOrText copyFrom: 1 to: self maxLength ]
				ifTrue: [ aStringOrText ] ]
]

{ #category : #copying }
RubAbstractTextArea >> veryDeepInner: deepCopier [ 
	"Copy all of my instance variables. Some need to be not copied at all, but shared.
	Warning!! Every instance variable defined in this class must be handled.
	We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	textStyle := textStyle veryDeepCopyWith: deepCopier.
	paragraph := paragraph veryDeepCopyWith: deepCopier.
	textColor := textColor veryDeepCopyWith: deepCopier.
	editor := editor veryDeepCopyWith: deepCopier.

]

{ #category : #menu }
RubAbstractTextArea >> wantsYellowButtonMenu [
	^ self menuAllowed 
]

{ #category : #'event handling' }
RubAbstractTextArea >> whenFindTextChanged: anAnnouncement [ 
	self changed
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> withDecorator: aDecorator [
	(self hasDecoratorNamed: aDecorator key)
		ifTrue: [ ^ self ].
	paragraph := aDecorator next: paragraph.
	self compose
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> withDecoratorNamed: aKey [
	(self hasDecoratorNamed: aKey)
		ifTrue: [ ^ self ].
	(self classOfDecoratorNamed: aKey)
		ifNotNil: [ :cls | self withDecorator: cls new ]
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> withDecoratorsNamed: aCollection [
	aCollection do: [ :m | self withDecoratorNamed: m ]
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> withFindReplaceSelection [
	self withDecoratorNamed: #findReplaceSelection
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> withOpeningClosingDelimitersHighlight [
	self withDecoratorNamed: #openingClosingDelimitersHighlight
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> withoutAnyDecorator [
	[ self paragraph key notNil ] whileTrue: [ self withoutDecorator: paragraph ]
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> withoutDecorator: aDecorator [
	| n p |
	(self hasDecorator: aDecorator)
		ifFalse: [ ^ self ].
	n := paragraph.
	[ n notNil and: [ n ~= aDecorator ] ]
		whileTrue: [ 
			p := n.
			n := p next ].
	n ifNil: [ ^ self ].
	p ifNil: [ paragraph := aDecorator next ] ifNotNil: [ p next: aDecorator next ].
	aDecorator aboutToBeUnplugged.
	aDecorator next: nil.
	aDecorator unplug.
	self changed
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> withoutDecoratorNamed: aKey [
	(self decoratorNamed: aKey)
		ifNotNil: [ :m | self withoutDecorator: m ].
	self changed
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> withoutDecoratorsNamed: aCollection [
	aCollection do: [ :m | self withoutDecoratorNamed: m ]
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> withoutFindReplaceSelection [
	self withoutDecoratorNamed: #findReplaceSelection
]

{ #category : #'accessing decorators' }
RubAbstractTextArea >> withoutSecondarySelection [
	self withoutDecoratorNamed: #secondarySelection
]

{ #category : #'event handling' }
RubAbstractTextArea >> wouldAcceptKeyboardFocusUponTab [
	"Answer whether the receiver might accept keyboard focus if 
	tab were hit in some container playfield"
	^ true
]

{ #category : #accessing }
RubAbstractTextArea >> wrapped [
	^ false
]

{ #category : #'event handling' }
RubAbstractTextArea >> yellowButtonActivity: shiftKeyState [ 
	"Invoke the text-editing menu.
	Check if required first!"
	self wantsYellowButtonMenu
		ifFalse: [ ^ false ].	
	(self getMenu: shiftKeyState)
		ifNotNil: [ :menu|
			menu privateOwner: self.
			menu setInvokingView: self editor.
			menu invokeModal. 
			self changed.
			^ true].
		
	^ true
]
