"
A find/replace dialog window for editors
"
Class {
	#name : #EditorFindReplaceDialogWindow,
	#superclass : #DialogWindowMorph,
	#instVars : [
		'state',
		'textFieldMorph'
	],
	#classVars : [
		'Finds',
		'Replacements',
		'Singleton'
	],
	#classInstVars : [
		'defaultFindReplaceServiceClass'
	],
	#category : #'Text-Edition-UI'
}

{ #category : #initializing }
EditorFindReplaceDialogWindow class >> cleanUp [
	Singleton ifNotNil: [ 
			Singleton close.
			Singleton := nil ]
]

{ #category : #accessing }
EditorFindReplaceDialogWindow class >> defaultFindReplaceServiceClass [

	^ defaultFindReplaceServiceClass ifNil: [ FindReplaceService ]
]

{ #category : #accessing }
EditorFindReplaceDialogWindow class >> finds [
	^ Finds ifNil: [Finds := OrderedCollection new]
]

{ #category : #initializing }
EditorFindReplaceDialogWindow class >> initialize [
	"EditorFindReplaceDialogWindow initialize"
	Singleton := nil.
]

{ #category : #accessing }
EditorFindReplaceDialogWindow class >> maxPreviousListSize [
	^ 15
]

{ #category : #'instance creation' }
EditorFindReplaceDialogWindow class >> on: aTextView [
	^ self singleton on: aTextView
]

{ #category : #accessing }
EditorFindReplaceDialogWindow class >> replacements [
	^ Replacements ifNil: [Replacements := OrderedCollection new]
]

{ #category : #'instance creation' }
EditorFindReplaceDialogWindow class >> singleton [ 
	^ Singleton ifNil: [Singleton := self new].

]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> buildWindowMenu [
	"Build and answer the window menu."

	| aMenu |
	aMenu := self theme newMenuIn: self for: self.
	aMenu
		addToggle: 'Close' translated
		target: self
		selector: #closeBoxHit
		getStateSelector: nil
		enablementSelector: #allowedToClose.
	aMenu lastItem icon: self theme windowCloseForm.
	aMenu addLine.
	aMenu add: 'About' selector: #showAbout.
	aMenu lastItem icon: (self iconNamed: #smallHelpIcon).
	^ aMenu
]

{ #category : #action }
EditorFindReplaceDialogWindow >> cancel [
	self state findText: ''.
	super cancel
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> caseSensitive [
	^ self state caseSensitive
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> caseSensitive: aBoolean [
	self state caseSensitive: aBoolean.

]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> defaultButton [
	"Answer the default button."
	^self
		findDeepSubmorphThat: [:m |
			(m isKindOf: PluggableButtonMorph) and: [m actionSelector = #find]]
		ifAbsent: [] 
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> defaultFindReplaceServiceClass [

	^ self class defaultFindReplaceServiceClass
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> defaultFocusMorph [
	^ self findTextFieldMorph textMorph
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> entireWordsOnly [
	^ self state entireWordsOnly
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> entireWordsOnly: aBoolean [
	self state entireWordsOnly: aBoolean.

]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> extent: anExtent [
	^ super extent: anExtent x @ self initialExtent y
]

{ #category : #action }
EditorFindReplaceDialogWindow >> find [
	self newFinding.
	^ self state findInTextMorph: self model
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> findEnabled [
	^ self findString isEmptyOrNil not 
]

{ #category : #updating }
EditorFindReplaceDialogWindow >> findPolicyChanged [
	self changed: #findText.
	self findTextFieldMorph textColor: Color  black.
	self changed: #caseSensitive.
	self changed: #isRegex.
	self changed: #entireWordsOnly.
	self changed: #findEnabled.
	self changed: #replaceText.
	self changed: #replaceEnabled.
	self changed: #replaceAllEnabled.
	self model ifNotNil: [self model selectionChanged].

]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> findString [
	^ self state findString
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> findText [
	^ self state findText
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> findText: aStringOrText [
	self state findText: aStringOrText.
	^ true

]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> findTextFieldMorph [
	^ textFieldMorph
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> initialExtent [ 
	^ 400 @ super initialExtent y
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> isRegex [
	^ self state isRegex
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> isRegex: aBoolean [
	self state isRegex: aBoolean.

]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> isResizeable [
	"Answer whether we are not we can be resized."

	^true
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> maxPreviousListSize [
	^ self class maxPreviousListSize
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> newButtons [
	"Answer new buttons as appropriate."

	^{self newFindButton isDefault: true. self newReplaceButton. self newReplaceAllButton. self newCancelButton}
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> newContentMorph [
	^(self newColumn: {	
			(self newGroupbox: nil for: 
				(self newColumn: {
					self newFindTextEntryMorph.
					(self newRow: {
						(self newColumn: {
							(self newCheckboxFor: self getSelected: #isRegex setSelected: #isRegex: getEnabled: nil label: 'Regular expression' translated help: nil).
							(self newCheckboxFor: self getSelected: #caseSensitive setSelected: #caseSensitive: getEnabled: nil label: 'Case sensitive' translated help: nil).
							(self newCheckboxFor: self getSelected: #entireWordsOnly setSelected: #entireWordsOnly: getEnabled: nil label: 'Entire words only'  translated help: nil) }
						).
						(self newColumn: {
							(self newCheckboxFor: self getSelected: #searchBackwards setSelected: #searchBackwards: getEnabled: nil label: 'Search backwards'  translated help: nil).
							(self newCheckboxFor: self getSelected: #wrapAround setSelected: #wrapAround: getEnabled: nil label: 'Wrap around'  translated help: nil) }
						) }	
					) }
				)
			).
			(self newLabelGroup: {'Replace with: ' translated -> self newReplaceTextEntryMorph}) vResizing: #shrinkWrap}
		) 


]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> newFindButton [
	^(self theme
			newButtonIn: self
			for: self
			getState: nil
			action: #find
			arguments: nil
			getEnabled: #findEnabled
			label: 'Find' translated
			help: 'Find the next occurrence' translated)
		hResizing: #rigid;
		vResizing: #rigid
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> newFindTextEntryMorph [
	| entryCompletion pt |
	entryCompletion := EntryCompletion new
				dataSourceBlock: [:currText | self prevFinds ];
				filterBlock: [:currApplicant :currText | currText size = 0
						or: [currApplicant asUppercase includesSubstring: currText asString asUppercase]].
	pt := (self newAutoAcceptTextEntryFor: self
			get: #findText
			set: #findText:
			class: String 
			getEnabled: nil
			help: 'Enter the text to find' translated
			entryCompletion: entryCompletion) 
		acceptOnCR: false;
		ghostText: 'Text to find';
		withDropListButton;
		crAction: [:t | self find];
		yourself.
	textFieldMorph := pt. 
	^ pt

]

{ #category : #updating }
EditorFindReplaceDialogWindow >> newFinding [
	| t |
	(t := self findText asString) ifEmpty: [^ self ].
	(self prevFinds includes: t)
		ifFalse: [self prevFinds addFirst: t].
	self prevFinds size > self maxPreviousListSize
		ifTrue: [self prevFinds removeLast]
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> newReplaceAllButton [
	^ (self theme
		newButtonIn: self
		for: self
		getState: nil
		action: #replaceAll
		arguments: nil
		getEnabled: #replaceAllEnabled
		label: 'Replace all' translated
		help: 'Replace all occurrences' translated) hResizing: #rigid;
		 vResizing: #rigid
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> newReplaceButton [
	^ (self theme
		newButtonIn: self
		for: self
		getState: nil
		action: #replace 
		arguments: nil
		getEnabled: #replaceEnabled
		label: 'Replace' translated
		help: 'Replace the next occurrence' translated) hResizing: #rigid;
		 vResizing: #rigid
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> newReplaceTextEntryMorph [
	| entryCompletion pt |
	entryCompletion := EntryCompletion new
				dataSourceBlock: [:currText | self prevReplacements ];
				filterBlock: [:currApplicant :currText | currText size = 0
						or: [currApplicant asUppercase includesSubstring: currText asString asUppercase]].

	pt := (self
		newAutoAcceptTextEntryFor: self
		get: #replaceText
		set: #replaceText:
		class: String
		getEnabled: nil
		help: 'Enter the replacement text' translated
		entryCompletion: entryCompletion)
			acceptOnCR: true;
			crAction: [:t | self replace];
			withDropListButton;
			yourself.
	^ pt

]

{ #category : #updating }
EditorFindReplaceDialogWindow >> newReplacement [
	| t |
	(t := self replaceText asString) ifEmpty: [^ self ].
	(self prevReplacements includes: t)
		ifFalse: [self prevReplacements addFirst: t].
	self prevReplacements size > self maxPreviousListSize
		ifTrue: [self prevReplacements removeLast]
]

{ #category : #updating }
EditorFindReplaceDialogWindow >> on: aTextView [
	(model isNil or: [model  ~= aTextView])
		ifTrue: [self findText: self findText.
			self model: aTextView.
			self changed: #findText.
			self changed: #caseSensitive.
			self changed: #replaceEnabled.
			self owner ifNotNil: [self findText: self findText]].

]

{ #category : #action }
EditorFindReplaceDialogWindow >> open [
	self openInWorld.
	self extent: self extent.
	self activate

]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> prevFinds [
	^ self class finds
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> prevReplacements [
	^ self class replacements
]

{ #category : #action }
EditorFindReplaceDialogWindow >> replace [
	self newReplacement.
	self state replaceInTextMorph: self model.
	self find
]

{ #category : #action }
EditorFindReplaceDialogWindow >> replaceAll [
	self model takeKeyboardFocus.
	self state replaceAllInTextMorph: self model
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> replaceAllEnabled [
	^ self model notNil
		and: [self findText notEmpty]
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> replaceEnabled [
	^ self model notNil
		and: [self findText notEmpty]
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> replaceText [
	^ self state replaceText
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> replaceText: aStringOrText [
	self state replaceText: aStringOrText asString.
	^ true


]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> searchBackwards [
	^ self state searchBackwards
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> searchBackwards: aBoolean [
	self searchBackwards = aBoolean
		ifFalse: [self state searchBackwards: aBoolean.
			self state updateFindStartIndexForTextMorph: self model]
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> state [
	^ state ifNil: [self state: (self defaultFindReplaceServiceClass newFor: self)]
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> state: aFindReplaceService [
	state ifNotNil: [state removeDependent: self].
	state := aFindReplaceService.
	state ifNotNil: [state addDependent: self].

]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> taskbarButtonFor: aTaskBar [
	"No taskbar button because always on top"
	^nil
]

{ #category : #icons }
EditorFindReplaceDialogWindow >> taskbarIcon [
	^ self iconNamed: #smallFindIcon
]

{ #category : #'user-interface' }
EditorFindReplaceDialogWindow >> title [
	^ 'Find & Replace' translated.

]

{ #category : #updating }
EditorFindReplaceDialogWindow >> update: aSymbol [
	 
	model ifNotNil: [
		aSymbol = #regexError
				ifTrue: [self findTextFieldMorph textColor: Color  red].
		aSymbol = #newFinding
				ifTrue: [^ self newFinding].
		aSymbol = #findPolicy
			ifTrue: [self findPolicyChanged].
		aSymbol = #findReplaceSelection 
			ifTrue: [self changed: #replaceEnabled.
				self state updateFindStartIndexForTextMorph: self model]].
	super update: aSymbol
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> wrapAround [
	^ self state wrapAround 
]

{ #category : #accessing }
EditorFindReplaceDialogWindow >> wrapAround: aBoolean [
	self state wrapAround: aBoolean.

]
