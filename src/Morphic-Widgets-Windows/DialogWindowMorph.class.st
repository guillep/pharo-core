"
Dialog style window with no window controls (expand, collapse etc). Usually opened modally (the morph that is used to modally open determines the modal scope, use of World implies ""system modal"").
Designed to be subclassed with content.
Supports Escape key for cancel and Enter key for default button.
"
Class {
	#name : #DialogWindowMorph,
	#superclass : #StandardWindow,
	#instVars : [
		'cancelled'
	],
	#category : #'Morphic-Widgets-Windows-Widgets'
}

{ #category : #actions }
DialogWindowMorph >> acceptTextMorphs [
	"Accept any text morphs except for those that have no edits."

	self allMorphs do: [:p |
		((p respondsTo: #accept) and: [
			(p respondsTo: #hasUnacceptedEdits) and: [
				p hasUnacceptedEdits]]) ifTrue: [p accept]]
]

{ #category : #'top window' }
DialogWindowMorph >> activate [
	"Set the default focus for now, will want to
	remember it at some point."
	
	super activate.
	self world ifNil: [^self].
	self rememberedKeyboardFocus
		ifNil: [self defaultFocusMorph ifNotNil: [:m |
				m takeKeyboardFocus]]
]

{ #category : #theme }
DialogWindowMorph >> activeFillStyle [
	"Return the active fillStyle for the receiver."
	
	^self theme dialogWindowActiveFillStyleFor: self
]

{ #category : #actions }
DialogWindowMorph >> addInitialPanel [
	"Add the panel."

	self addMainPanel
]

{ #category : #actions }
DialogWindowMorph >> addMainPanel [
	"Add the main panel."

	self addMorph: self newMainPanel frame: (0@0 corner: 1@1)
]

{ #category : #theme }
DialogWindowMorph >> animateClose [
	"Animate closing."
]

{ #category : #actions }
DialogWindowMorph >> applyChanges [
	"Apply the changes."

	self acceptTextMorphs
]

{ #category : #actions }
DialogWindowMorph >> buttons [
	"Answer the buttons in the button row"

	^self paneMorphs last lastSubmorph submorphs
]

{ #category : #testing }
DialogWindowMorph >> canBeMaximized [
	"Answer whether we are not we can be maximised."

	^self isResizeable
		ifTrue: [super canBeMaximized]
		ifFalse: [false]
]

{ #category : #actions }
DialogWindowMorph >> cancel [
	"Cancel and close."

	self close
]

{ #category : #accessing }
DialogWindowMorph >> cancelled [
	"Answer the value of cancelled"

	^ cancelled
]

{ #category : #accessing }
DialogWindowMorph >> cancelled: anObject [
	"Set the value of cancelled"

	cancelled := anObject
]

{ #category : #actions }
DialogWindowMorph >> close [
	"Close the window."

	self delete
]

{ #category : #keymapping }
DialogWindowMorph >> closeWindowAction [
"closed by keyboard shortcut - act like 'cancel' "
	self cancel
]

{ #category : #actions }
DialogWindowMorph >> defaultButton [
	"Answer the default button."

	^self
		findDeepSubmorphThat: [:m |
			(m isKindOf: PluggableButtonMorph) and: [m isDefault]]
		ifAbsent: [] 
]

{ #category : #'focus handling' }
DialogWindowMorph >> defaultFocusMorph [
	"Answer the morph that should have the keyboard
	focus by default when the dialog is opened."
	
	^self defaultButton
		ifNil: [(self respondsTo: #nextMorphWantingFocus)
					ifTrue: [	self nextMorphWantingFocus]]
		ifNotNil: [:b | b enabled ifTrue: [b]]
]

{ #category : #testing }
DialogWindowMorph >> defaultIsResizeable [

	^ false
]

{ #category : #actions }
DialogWindowMorph >> defaultLabel [
	"Answer the default label for the receiver."

	^'Dialog' translated
]

{ #category : #'event handling' }
DialogWindowMorph >> doubleClick: event [
	"Handle a double click. Maximize/restore the window.
	Not for dialogs if not resizeable..."
	
	self isResizeable ifTrue: [super doubleClick: event]
]

{ #category : #actions }
DialogWindowMorph >> escapePressed [
	"Default is to cancel."

	self cancel
]

{ #category : #'event handling' }
DialogWindowMorph >> handlesKeyboard: evt [
	"Return true if the receiver wishes to handle the given keyboard event"
	
	(super handlesKeyboard: evt) ifTrue: [^true].
	^evt keyCharacter = Character escape or: [
		(self defaultButton notNil and: [
			evt keyCharacter = Character cr])]
	
]

{ #category : #theme }
DialogWindowMorph >> inactiveFillStyle [
	"Return the active fillStyle for the receiver."
	
	^self theme dialogWindowInactiveFillStyleFor: self
]

{ #category : #'open/close' }
DialogWindowMorph >> initialExtent [
	"Answer the default extent for the receiver."

	|rl paneExt ext|
	rl := self getRawLabel.
	paneExt := self mainPanel
		ifNil: [0@0]
		ifNotNil: [:pane | pane minExtent].
	ext := paneExt + (2@ self labelHeight) + (2 * self class borderWidth)
		max: rl extent + 20.
	self isResizeable ifTrue: [
		self title: self title "adjust minimumExtent".
		self minimumExtent: (ext x max: self minimumExtent x)@(ext y max: self minimumExtent y)].
	^ext
]

{ #category : #initialization }
DialogWindowMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		cancelled: true;
		addInitialPanel
]

{ #category : #initialization }
DialogWindowMorph >> initializeLabelArea [
	"Initialize the label area (titlebar) for the window."
	
	super initializeLabelArea.
	self removeBoxes.
	self replaceBoxes
]

{ #category : #'event handling' }
DialogWindowMorph >> keyDown: evt [
	"Check for return and escape keys."

	super keyDown: evt.
	(self defaultButton notNil and: [evt key = KeyboardKey enter or: [evt key = KeyboardKey keypadEnter]]) 
		ifTrue: [self returnPressed. ^true].
	
	evt key = KeyboardKey escape ifTrue: [self escapePressed. ^true].
	^false
]

{ #category : #'event handling' }
DialogWindowMorph >> keyboardFocusChange: aBoolean [
	"Set the focus to the default button."
	super keyboardFocusChange: aBoolean.
	aBoolean ifTrue: [
		self defaultFocusMorph ifNotNil: [:b |
			b takeKeyboardFocus]]
]

{ #category : #actions }
DialogWindowMorph >> mainPanel [
	"Anwer the main panel morph or nil if not yet present."

	^self paneMorphs isEmpty
		ifFalse: [self paneMorphs first]
]

{ #category : #actions }
DialogWindowMorph >> newButtonRow [
	"Answer a new ok/cancel button row."

	|answer buttons e|
	buttons := self newButtons.
	e := 0@0.
	buttons do: [:b | e := e max: b minExtent].
	buttons do: [:b | b extent: e].
	answer := Morph new
		color: Color transparent;
		changeTableLayout;
		cellInset: 8;
		listDirection: #leftToRight;
		listCentering: #bottomRight;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap.
	buttons do: [:b | answer addMorphBack: b].
	^answer
]

{ #category : #actions }
DialogWindowMorph >> newButtons [
	"Answer new buttons as appropriate."

	^{self newOKButton isDefault: true. self newCancelButton}
]

{ #category : #actions }
DialogWindowMorph >> newContentMorph [
	"Answer a new content morph."

	^Morph new
		color: Color transparent;
		hResizing: #spaceFill;
		vResizing: #spaceFill
]

{ #category : #actions }
DialogWindowMorph >> newMainPanel [
	"Answer a new main panel."

	^self newDialogPanel
		addMorphBack: self newContentMorph;
		addMorphBack: self newButtonRow;
		yourself
]

{ #category : #actions }
DialogWindowMorph >> ok [
	"Apply the changes and close."

	self
		cancelled: false;
		applyChanges;
		delete
]

{ #category : #theme }
DialogWindowMorph >> preferredCornerStyle [
	"Answer the preferred corner style."

	^self theme dialogWindowPreferredCornerStyleFor: self
]

{ #category : #actions }
DialogWindowMorph >> returnPressed [
	"Default is to do the default button."

	(self defaultButton ifNil: [^self]) performAction
]

{ #category : #initialization }
DialogWindowMorph >> setFramesForLabelArea [
	"Delegate to theme."
	
	self theme configureDialogWindowLabelAreaFrameFor: self
]

{ #category : #actions }
DialogWindowMorph >> setLabelWidgetAllowance [
	"Set the extra space required, in general, apart from the label.
	No extra needed for dialogs."
	
	^labelWidgetAllowance :=  0
]

{ #category : #controls }
DialogWindowMorph >> title: aString [
	"Set the window title."
	
	super title: aString.
	label fitContents.
	self minimumExtent: (((label width + 20 min: (Display width // 2)) max: self minimumExtent x)@ self minimumExtent y)
]

{ #category : #theme }
DialogWindowMorph >> wantsRoundedCorners [
	"Answer whether rounded corners are wanted."
	
	^(self theme dialogWindowPreferredCornerStyleFor: self) == #rounded
]
