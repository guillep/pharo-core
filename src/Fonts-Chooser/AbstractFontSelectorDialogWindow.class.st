"
Dialog based font chooser with preview.
"
Class {
	#name : #AbstractFontSelectorDialogWindow,
	#superclass : #DialogWindowMorph,
	#instVars : [
		'fontFamilies',
		'selectedFont',
		'textPreviewMorph',
		'fontFamilyIndex',
		'fontSizeIndex',
		'isBold',
		'isItalic',
		'isUnderlined',
		'isStruckOut',
		'previewText'
	],
	#category : #'Fonts-Chooser'
}

{ #category : #testing }
AbstractFontSelectorDialogWindow class >> isAbstract [

	^self == AbstractFontSelectorDialogWindow
]

{ #category : #icons }
AbstractFontSelectorDialogWindow class >> taskbarIconName [
	"Answer the icon for the receiver in a task bar."

	^ #smallFontsIcon
]

{ #category : #defaults }
AbstractFontSelectorDialogWindow >> defaultFontFamilies [
	"Answer the set of available fonts families that are supported in the font that they represent."
	
	self subclassResponsibility
]

{ #category : #defaults }
AbstractFontSelectorDialogWindow >> defaultPreviewText [
	"Answer the default text to use for the preview of the font."

	^(33 to: 127) asByteArray asString
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> familyName [
	"Answer the selected family name or nil if none."

	(self fontFamilyIndex between: 1 and: self fontFamilies size)
		ifFalse: [^nil].
	^(self fontFamilies at: self fontFamilyIndex) asString
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> fontFamilies [
	"Answer the set of available fonts families that are supported as Text objects
	in the font that they represent."
	
	^fontFamilies ifNil: [
		self fontFamilies: self defaultFontFamilies.
		fontFamilies]
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> fontFamilies: anObject [
	"Set the value of fontFamilies"

	fontFamilies := anObject
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> fontFamilyIndex [
	"Answer the value of fontFamilyIndex"

	^ fontFamilyIndex
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> fontFamilyIndex: anObject [
	"Set the value of fontFamilyIndex"

	fontFamilyIndex := anObject.
	self updateSelectedFont
]

{ #category : #'font description' }
AbstractFontSelectorDialogWindow >> fontSize [
	"Answer the selected font size or nil if none."

	(self fontSizeIndex between: 1 and: self fontSizes size)
		ifFalse: [^nil].
	^self fontSizes at: self fontSizeIndex
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> fontSizeIndex [
	"Answer the value of fontSizeIndex"

	^ fontSizeIndex
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> fontSizeIndex: anObject [
	"Set the value of fontSizeIndex"

	fontSizeIndex := anObject.
	self updateSelectedFont
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> fontSizes [
	"Answer the set of available fonts sizes that are supported."

	^#(6 7 8 9 10 11 12 13 14 15 16 18 20 21 22 24 26 28 32 36 48)
]

{ #category : #initialization }
AbstractFontSelectorDialogWindow >> initialize [
	"Initialize the receiver."

	self
		isBold: false;
		isItalic: false;
		isUnderlined: false;
		isStruckOut: false;
		previewText: self defaultPreviewText;
		fontFamilyIndex: 0;
		fontSizeIndex: 0.
	super initialize
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> isBold [
	"Answer the value of isBold"

	^ isBold
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> isBold: anObject [
	"Set the value of isBold"

	isBold := anObject.
	self changed: #isBold
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> isItalic [
	"Answer the value of isItalic"

	^ isItalic
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> isItalic: anObject [
	"Set the value of isItalic"

	isItalic := anObject.
	self changed: #isItalic
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> isStruckOut [
	"Answer the value of isStruckOut"

	^ isStruckOut
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> isStruckOut: anObject [
	"Set the value of isStruckOut"

	isStruckOut := anObject.
	self changed: #isStruckOut
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> isUnderlined [
	"Answer the value of isUnderlined"

	^ isUnderlined
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> isUnderlined: anObject [
	"Set the value of isUnderlined"

	isUnderlined := anObject.
	self changed: #isUnderlined
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> matchingFont [
	"Answer the font that matches the selections."

	self subclassResponsibility
]

{ #category : #'instance creation' }
AbstractFontSelectorDialogWindow >> newBoldButtonMorph [
	"Answer a button for the boldness of the font."

	^ self
		newButtonFor: self
		getState: #isBold
		action: #toggleBold
		arguments: nil
		getEnabled: nil
		labelForm: (self iconNamed: #smallBoldIcon)
		help: 'Toggle bold font' translated
]

{ #category : #actions }
AbstractFontSelectorDialogWindow >> newContentMorph [
	"Answer a new content morph."

	self textPreviewMorph: self newTextPreviewMorph.
	^(self newColumn: {
		(self newRow: {
			self newGroupbox: 'Family' translated for:
				self newFontFamilyMorph.
			(self newColumn: {
				(self newGroupbox: 'Style' translated for: 
					self newFontStyleButtonRowMorph)
					vResizing: #shrinkWrap.
				self newGroupbox: 'Point size' translated for:
					self newFontSizeMorph})
				hResizing: #shrinkWrap})
			vResizing: #spaceFill.
		(self newGroupbox: 'Preview' translated for:
			self textPreviewMorph)
			vResizing: #shrinkWrap})
		minWidth: 350;
		minHeight: 400
]

{ #category : #'instance creation' }
AbstractFontSelectorDialogWindow >> newFontFamilyMorph [
	"Answer a list for the font family of the font."

	|highestFont|
	highestFont := self fontFamilies first fontAt: 1 withStyle: TextStyle default.
	self fontFamilies do: [:ff | |f|
		f := ff fontAt: 1 withStyle: TextStyle default.
		f height > highestFont height
			ifTrue: [highestFont := f]].
	^(self
		newListFor: self
		list: #fontFamilies
		selected: #fontFamilyIndex
		changeSelected: #fontFamilyIndex:
		help: nil)
		font: highestFont
]

{ #category : #'instance creation' }
AbstractFontSelectorDialogWindow >> newFontSizeMorph [
	"Answer a list for the font size of the font."

	^self
		newListFor: self
		list: #fontSizes
		selected: #fontSizeIndex
		changeSelected: #fontSizeIndex:
		help: nil
]

{ #category : #'instance creation' }
AbstractFontSelectorDialogWindow >> newFontStyleButtonRowMorph [
	"Answer a new font style button row morph."

	^self newRow: {
		self newBoldButtonMorph.
		self newItalicButtonMorph.
		self newUnderlinedButtonMorph.
		self newStruckOutButtonMorph}
]

{ #category : #'instance creation' }
AbstractFontSelectorDialogWindow >> newItalicButtonMorph [
	"Answer a button for the italic emphasis of the font."

	^ self
		newButtonFor: self
		getState: #isItalic
		action: #toggleItalic
		arguments: nil
		getEnabled: nil
		labelForm: (self iconNamed: #smallItalicIcon)
		help: 'Toggle italic font' translated
]

{ #category : #'instance creation' }
AbstractFontSelectorDialogWindow >> newStruckOutButtonMorph [
	"Answer a button for the struck out emphasis of the font."

	^ self
		newButtonFor: self
		getState: #isStruckOut
		action: #toggleStruckOut
		arguments: nil
		getEnabled: nil
		labelForm: (self iconNamed: #smallStrikeOutIcon)
		help: 'Toggle struck-out font' translated
]

{ #category : #'instance creation' }
AbstractFontSelectorDialogWindow >> newTextPreviewMorph [
	"Answer a text entry morph for the preview of the font."

	^(self
		newTextEditorFor: self
		getText: #previewText 
		setText: nil
		getEnabled: nil)
		vResizing: #rigid;
		enabled: false;
		extent: 20@90
]

{ #category : #'instance creation' }
AbstractFontSelectorDialogWindow >> newUnderlinedButtonMorph [
	"Answer a button for the italic emphasis of the font."

	^ self
		newButtonFor: self
		getState: #isUnderlined
		action: #toggleUnderlined
		arguments: nil
		getEnabled: nil
		labelForm: (self iconNamed: #smallUnderlineIcon)
		help: 'Toggle underlined font' translated
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> previewText [
	"Answer the value of previewText"

	^previewText asText addAttribute: (TextEmphasis new emphasisCode: self textEmphasisCode)
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> previewText: anObject [
	"Set the value of previewText"

	previewText := anObject.
	self changed: #previewText
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> selectedFont [
	"Answer the value of selectedFont"

	^ selectedFont
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> selectedFont: anObject [
	"Set the value of selectedFont"

	selectedFont := anObject ifNil: [TextStyle defaultFont].
	self updateFromSelectedFont
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> textEmphasisCode [
	"Answer the current bitmask for the text emphasis."

	^(((self isBold ifTrue: [1] ifFalse: [0]) bitOr:
		(self isItalic ifTrue: [2] ifFalse: [0])) bitOr:
		(self isUnderlined ifTrue: [4] ifFalse: [0])) bitOr:
		(self isStruckOut ifTrue: [16] ifFalse: [0])
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> textPreviewMorph [
	"Answer the value of textPreviewMorph"

	^ textPreviewMorph
]

{ #category : #accessing }
AbstractFontSelectorDialogWindow >> textPreviewMorph: anObject [
	"Set the value of textPreviewMorph"

	textPreviewMorph := anObject
]

{ #category : #actions }
AbstractFontSelectorDialogWindow >> toggleBold [
	"Toggle the font bold emphasis."

	self isBold: self isBold not.
	self updateSelectedFont
]

{ #category : #actions }
AbstractFontSelectorDialogWindow >> toggleItalic [
	"Toggle the font italic emphasis."

	self isItalic: self isItalic not.
	self updateSelectedFont
]

{ #category : #actions }
AbstractFontSelectorDialogWindow >> toggleStruckOut [
	"Toggle the font struck out emphasis."

	self isStruckOut: self isStruckOut not.
	self updateSelectedFont
]

{ #category : #actions }
AbstractFontSelectorDialogWindow >> toggleUnderlined [
	"Toggle the font underlined emphasis."

	self isUnderlined: self isUnderlined not.
	self updateSelectedFont
]

{ #category : #updating }
AbstractFontSelectorDialogWindow >> updateFromSelectedFont [
	"Update our state based on the selected font."

	self subclassResponsibility
]

{ #category : #updating }
AbstractFontSelectorDialogWindow >> updateSelectedFont [
	"Update the selected font to reflect the choices."

	self selectedFont: self matchingFont
]
