"
I am a morph for a text area which has only one line, like search field
"
Class {
	#name : #RubTextFieldMorph,
	#superclass : #RubScrolledTextMorph,
	#instVars : [
		'hasValidText',
		'acceptOnCR',
		'entryCompletion',
		'maxLength',
		'encrypted'
	],
	#category : #'Rubric-Editing-Widgets'
}

{ #category : #accessing }
RubTextFieldMorph >> acceptOnCR [
	^ acceptOnCR 
]

{ #category : #accessing }
RubTextFieldMorph >> acceptOnCR: aBoolean [
	acceptOnCR := aBoolean
]

{ #category : #'model protocol' }
RubTextFieldMorph >> acceptTextInModel [
	"Inform the model that the receiver's textArea text should be accepted.
	Answer true if the model accepted ok, something else otherwise (sic)"
	| result |
	result := super acceptTextInModel.
	"Yes, we check here with == instead of with #ifTrue:. 
	That's bad but  some models don't return true of false"
	result == true ifTrue: [ self closeChooser ].
	^ result

]

{ #category : #drawing }
RubTextFieldMorph >> adornmentColor [
	"color to Indicate edit status for the given morph."

	self hasValidText
		ifFalse: [ ^ Color red ].
	^ super adornmentColor
]

{ #category : #encryption }
RubTextFieldMorph >> beDecrypted [

	encrypted := false.
	self textMorph font: TextStyle defaultFont.
]

{ #category : #encryption }
RubTextFieldMorph >> beEncrypted [
	
	encrypted := true.
	self textMorph font: (StrikeFont passwordFontSize: self theme textFont pointSize).
]

{ #category : #testing }
RubTextFieldMorph >> chooserHasFocus [
	^ self chooserIsOpened and: [entryCompletion chooser hasKeyboardFocus]
]

{ #category : #testing }
RubTextFieldMorph >> chooserIsOpened [
	^ entryCompletion notNil and: [entryCompletion chooser notNil]
]

{ #category : #accessing }
RubTextFieldMorph >> closeChooser [	
	entryCompletion
		ifNotNil: [entryCompletion closeChooser]
]

{ #category : #accessing }
RubTextFieldMorph >> configureGhostText: aTextArea [

	"Text Input always is in the middle of the text input"

	super configureGhostText: aTextArea.
	aTextArea center: self scrollBounds center.
	aTextArea left: self scrollBounds left 
]

{ #category : #compatibility }
RubTextFieldMorph >> cursorEnd: aKeyboardEvent [ 
	^ self textMorph editor cursorEnd: aKeyboardEvent 
]

{ #category : #defaults }
RubTextFieldMorph >> defaultGhostTextMorph [
	^ super defaultGhostTextMorph beNotWrapped 
]

{ #category : #protocol }
RubTextFieldMorph >> disable [
	self beReadOnly 
]

{ #category : #accessing }
RubTextFieldMorph >> encrypted: aBoolean [

	aBoolean
		ifTrue: [ self beEncrypted ]
		ifFalse: [ self beDecrypted ]
]

{ #category : #accessing }
RubTextFieldMorph >> entryCompletion [ 
	^ entryCompletion 
]

{ #category : #accessing }
RubTextFieldMorph >> entryCompletion: anEntryCompletion [

	entryCompletion := anEntryCompletion.
	entryCompletion
		ifNil: [ self withoutDropListButton ]
		ifNotNil: [ self withDropListButton.
			entryCompletion chooseBlock
				ifNil: [ entryCompletion
						chooseBlock: [ :v | 
							self setText: v.
							self acceptTextInModel
							]
					]
				ifNotNil: [ | blk |

					blk := entryCompletion chooseBlock.
					entryCompletion
						chooseBlock: [ :v | 
							self setText: v.
							self acceptTextInModel.
							blk value: v
							]
					]
			]
]

{ #category : #geometry }
RubTextFieldMorph >> extent: aPoint [
	super extent: aPoint x @ self textFieldHeight
]

{ #category : #focus }
RubTextFieldMorph >> focusChanged [
	(self hasFocus or: [self chooserHasFocus])
		ifFalse: [self closeChooser].
	super focusChanged

]

{ #category : #'accessing text area' }
RubTextFieldMorph >> font: aNewFont [
	
	"As the text field is using a font full of * to show the password.
	Changing the font should preserve it"
	encrypted ifTrue: [ 
		^ super font: (StrikeFont passwordFontSize: aNewFont pointSize). ].

	super font: aNewFont
]

{ #category : #'model protocol' }
RubTextFieldMorph >> hasValidText [
	^ hasValidText
]

{ #category : #'model protocol' }
RubTextFieldMorph >> hasValidText: aBoolean [
	hasValidText := aBoolean
]

{ #category : #initialization }
RubTextFieldMorph >> initialize [
	super initialize.
	hasValidText := true.
	self textArea announcer when: RubReturnEntered  send: #whenReturnEntered: to: self.
	self scrollbarsShowNever.
	self extent: self extent.
	acceptOnCR := true.
	maxLength := 0.
	self beDecrypted
]

{ #category : #focus }
RubTextFieldMorph >> keyboardFocusChange: aBoolean [
	self closeChooser.
	super keyboardFocusChange: aBoolean.

]

{ #category : #defaults }
RubTextFieldMorph >> manageLayoutInBounds: aRectangle [
	super manageLayoutInBounds: aRectangle.
	self closeChooser 
]

{ #category : #accessing }
RubTextFieldMorph >> maxLength [
	
	"Returns the max length of this text field.
	0 meaning unlimited"
	^ maxLength
]

{ #category : #accessing }
RubTextFieldMorph >> maxLength: anInteger [
	"Sets the max length of the text field.
	0 means unlimited"
	maxLength := anInteger.
	maxLength = 0 ifTrue: [ ^ self ].
	
	"If the contents of this textfield exceed the max length, contents are truncated"
	self getText size > maxLength
		ifTrue: [ self setText: (self getText first: maxLength) ]
]

{ #category : #'model protocol' }
RubTextFieldMorph >> on: aModel text: aGetTextSelector accept: aSetTextSelector readSelection: aReadSelectionSelector menu: aGetMenuSelector [
	self getTextSelector: aGetTextSelector.
	self setTextSelector: aSetTextSelector.
	self getSelectionSelector: aReadSelectionSelector.
	aGetMenuSelector
		ifNil: [ self textArea forbidMenu ]
		ifNotNil: [ self menuProvider: aModel selector: aGetMenuSelector ].
	self on: aModel
]

{ #category : #'model protocol' }
RubTextFieldMorph >> on: anObject text: getTextSel accept: setTextSel readSelection: getSelectionSel menu: getMenuSel setSelection: setSelectionSel [
	self
		on: anObject
		text: getTextSel
		accept: setTextSel
		readSelection: getSelectionSel
		menu: getMenuSel.
	setSelectionSelector := setSelectionSel.
	self borderWidth: 1.
	self setText: self getTextFromModel.
	self setSelection: self getSelectionFromModel
]

{ #category : #accessing }
RubTextFieldMorph >> openChooser [	
	entryCompletion
		ifNotNil: [
			entryCompletion openChooserWith: self textArea text string from: self]
]

{ #category : #initialization }
RubTextFieldMorph >> outOfWorld: aWorld [
	self closeChooser.
	super outOfWorld: aWorld
]

{ #category : #private }
RubTextFieldMorph >> resetState [
	hasValidText := true.
	super resetState
]

{ #category : #initialization }
RubTextFieldMorph >> textAreaClass [
	^ RubTextFieldArea
]

{ #category : #'event handling' }
RubTextFieldMorph >> textChanged [
	super textChanged.
	self updateChooser.

]

{ #category : #geometry }
RubTextFieldMorph >> textFieldHeight [
	| vgap |
	vgap := self currentHScrollBarThickness isZero
		ifTrue: [  0 ]
		ifFalse: [ self currentHScrollBarThickness - 1 ].
	^ self textArea height + 1 + (self borderWidth * 2) + vgap
]

{ #category : #'event handling' }
RubTextFieldMorph >> updateChooser [
	entryCompletion
		ifNotNil: [  self openChooser ] 
]

{ #category : #accessing }
RubTextFieldMorph >> wantsFrameAdornments: aBoolean [
	aBoolean ifTrue: [ self withAdornment  ] ifFalse: [ self withoutAdornment ]
]

{ #category : #'event handling' }
RubTextFieldMorph >> whenKeystrokeInTextArea: anAnnouncement [
	super whenKeystrokeInTextArea: anAnnouncement.
	entryCompletion ifNotNil: [entryCompletion keystroke: anAnnouncement event from: self]
]

{ #category : #'event handling' }
RubTextFieldMorph >> whenReturnEntered: anAnnouncement [
	self acceptOnCR
		ifTrue: [
			anAnnouncement accepted: true ].
	self changed
]

{ #category : #initialization }
RubTextFieldMorph >> withDropListButton [
	self withRulerNamed: #dropListButton
]

{ #category : #initialization }
RubTextFieldMorph >> withoutDropListButton [
	self withoutRulerNamed: #dropListButton
]
