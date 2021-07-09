"
Common superclass for User Interface themes. Provides methods for creating new morphs in a standard way, various ""services"" like a file dialog, message dialogs etc. and also methods for customising aspects of the appearance of various morphs.
Though conceptually abstract, no code is ""missing"". Subclasses, therefore, should override the aspects they wish to change.
"
Class {
	#name : #UITheme,
	#superclass : #Model,
	#instVars : [
		'settings',
		'forms',
		'soundTheme',
		'focusIndicator',
		'windowActiveDropShadowStyle',
		'useScrollbarThumbShadow'
	],
	#classVars : [
		'Builder',
		'Current'
	],
	#classInstVars : [
		'defaultSettings'
	],
	#category : #'Polymorph-Widgets-Themes'
}

{ #category : #query }
UITheme class >> allThemeClasses [
	"Answer the subclasses of the receiver that are considered to be
	concrete (useable as a theme)."

	^(self allSubclasses reject: [:c | c isAbstract]) asSortedCollection: [:a :b |
		a themeName <= b themeName]
]

{ #category : #accessing }
UITheme class >> baseColor [
	self subclassResponsibility 
]

{ #category : #accessing }
UITheme class >> basePassiveBackgroundColor [ 
	^ self subclassResponsibility 
]

{ #category : #accessing }
UITheme class >> baseSelectionColor [ 
	^ self subclassResponsibility 
]

{ #category : #query }
UITheme class >> beCurrent [
	"Make a new instance of the receiver be the current theme."

	self isAbstract ifTrue: [^self error: self name, ' is abstract, send #beCurrent to a subclass.'].
	self current: self newDefault
]

{ #category : #accessing }
UITheme class >> builder [
	"Answer a morph that has the TEasilyThemed trait."

	^Builder ifNil: [Builder := self newBuilder. Builder]
]

{ #category : #cleanup }
UITheme class >> cleanUp [

	"avoid old references to morphs that should be garbage-collected"
	UITheme current focusIndicator: nil.
]

{ #category : #accessing }
UITheme class >> current [
	"Answer the current ui theme.
	WARNING: Direct access to this method is ill-adviced, use self theme instead."

	^Current ifNil: [
		Current := PharoLightTheme newDefault.
		Current ]
]

{ #category : #accessing }
UITheme class >> current: aUITheme [
	"Set the current ui theme."

	Current := aUITheme.
	SystemProgressMorph reset. "reset to use new fill styles"
	ScrollBarMorph initializeImagesCache. "reset to use new arrows"

	self class environment at: #SHPreferences ifPresent: [ :shPreferences |
		shPreferences setStyleTable: aUITheme shStyleTable ].

	self class environment at: #PolymorphSystemSettings ifPresent: [ :polymorphSystemSettings |
		polymorphSystemSettings desktopColor: aUITheme desktopColor ].
	
	self class environment at: #NECPreferences ifPresent: [ :necPreferences |
		necPreferences backgroundColor: aUITheme windowColor ].

	self class environment at: #Paragraph ifPresent: [ :paragraph |
		paragraph insertionPointColor: aUITheme caretColor ].

	self class environment at: #BalloonMorph ifPresent: [ :balloonMorph |
		balloonMorph setBalloonColorTo: aUITheme balloonBackgroundColor ].

	aUITheme updateWorldDockingBars.
	self currentWorld themeChanged.
	(SystemWindow allSubInstances select:[:e | e owner isNil]) do: [ :each | each themeChanged ].

	SystemAnnouncer uniqueInstance announce: UIThemeChanged
]

{ #category : #accessing }
UITheme class >> currentSettings [
	"Answer the current ui theme settings."

	^ self current settings
]

{ #category : #accessing }
UITheme class >> darkBaseColor [
	self subclassResponsibility 
]

{ #category : #accessing }
UITheme class >> defaultSettings [
	"Answer the default settings for the theme."
	
	^defaultSettings ifNil: [
		self defaultSettings: self newDefaultSettings.
		defaultSettings]
]

{ #category : #accessing }
UITheme class >> defaultSettings: aThemeSettings [
	"Set the default settings for the theme."
	
	defaultSettings := aThemeSettings
]

{ #category : #'initialize-release' }
UITheme class >> initialize [
	"self initialize"
	self current class = UITheme
		ifTrue: [self current: nil
			"due to change to being abstract"].
]

{ #category : #testing }
UITheme class >> isAbstract [
	"Answer whether the receiver is considered to be abstract."

	^true
]

{ #category : #testing }
UITheme class >> isCurrent [
	"Answer whether an instance of the receiver is the current theme."

	^Current class == self
]

{ #category : #accessing }
UITheme class >> lightBaseColor [
	self subclassResponsibility 
]

{ #category : #accessing }
UITheme class >> lightSelectionColor [ 
	^ self subclassResponsibility 
]

{ #category : #accessing }
UITheme class >> newBuilder [
	"Answer a new builder morph."

	^ComposableMorph new
]

{ #category : #accessing }
UITheme class >> newDefault [
	"Answer a new default ui theme."

	^self new
]

{ #category : #accessing }
UITheme class >> newDefaultSettings [
	self setPreferredPreferences.
	
	^ThemeSettings new
		buttonColor: Color gray;
		scrollbarColor: Color gray;
		menuColor: self baseColor;
		menuTitleColor: self baseColor;
		windowColor: self baseColor;
		selectionColor: self lightSelectionColor;
		menuSelectionColor: self baseSelectionColor;
		progressBarColor: self baseColor;
		standardColorsOnly: true;
		autoSelectionColor: false;
		preferRoundCorner: false;
		fadedBackgroundWindows: false;
		flatMenu: true
]

{ #category : #accessing }
UITheme class >> resetAllDefaultSettings [
	"Reset the default settings of all themes"
	"self resetAllDefaultSettings"
	self withAllSubclassesDo: [:cls | cls defaultSettings: nil]
]

{ #category : #'initialize-release' }
UITheme class >> resetBuilder [
	"self resetBuilder"
	
	Builder := nil
]

{ #category : #accessing }
UITheme class >> resetDefaultSettings [
	"Reset the default settings to use the original values."

	self defaultSettings: nil
]

{ #category : #initialization }
UITheme class >> setPreferredPreferences [ 
	self subclassResponsibility 
]

{ #category : #accessing }
UITheme class >> standardThemeClass [
	^ PharoLightTheme 
]

{ #category : #accessing }
UITheme class >> themeName [
	"Answer the friendly name of the theme."

	self subclassResponsibility
]

{ #category : #accessing }
UITheme class >> veryLightSelectionColor [ 
	^ self subclassResponsibility 
]

{ #category : #services }
UITheme >> abortIn: aThemedMorph text: aStringOrText title: aString [
	"Answer the result of an error dialog (true) with the given label and title."

	| window |
	self abortSound play.
	window := (ErrorDialogWindow newWithTheme: aThemedMorph theme)
		textFont: self textFont;
		title: aString;
		text: aStringOrText.
	window openModal.
	^ window cancelled not
]

{ #category : #sounds }
UITheme >> abortSound [
	"Answer the abort sound."

	^self soundTheme abortSound
]

{ #category : #services }
UITheme >> alertIn: aThemedMorph text: aStringOrText title: aString configure: aBlock [
	"Answer the result of an alert dialog (true) with the given label and title."

	|dialog|
	SoundTheme useThemeSounds ifTrue: [self alertSound play].
	dialog := (AlertDialogWindow newWithTheme: aThemedMorph theme)
		textFont: self textFont;
		title: aString;
		text: aStringOrText.
	aBlock value: dialog.
	dialog openModal.
	^dialog cancelled not
]

{ #category : #sounds }
UITheme >> alertSound [
	"Answer the alert sound."

	^self soundTheme alertSound
]

{ #category : #accessing }
UITheme >> animationSettings [
	^ self settings animationSettings
]

{ #category : #accessing }
UITheme >> autoMenuColor [
	^ self settings autoMenuColor
]

{ #category : #'accessing - colors' }
UITheme >> backgroundColor [

	^ Color white
]

{ #category : #'accessing - colors' }
UITheme >> balloonBackgroundColor [

	^self lightBaseColor
]

{ #category : #'accessing - colors' }
UITheme >> balloonTextColor [

	^self textColor
]

{ #category : #'accessing - colors' }
UITheme >> baseColor [
	^ self class baseColor
]

{ #category : #'basic-colors' }
UITheme >> baseColorFor: aWidget [

	^ self class baseColor
]

{ #category : #private }
UITheme >> basePassiveBackgroundColorFor: aButton [
	^ self class basePassiveBackgroundColor
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> baseScrollbarColorFor: aScrollbar [
	"Return the scrollbar last pane colour or that of our settings if unavailable"
	
	^ aScrollbar lastPaneColor 
		ifNil: [ self scrollbarColor ]
]

{ #category : #private }
UITheme >> baseSelectionColorFor: aButton [
	^ self class baseSelectionColor
]

{ #category : #scrollbars }
UITheme >> basicCreateArrowOfDirection: aSymbolDirection size: finalSizeInteger color: aColor [ 
	"PRIVATE - create an arrow with aSymbolDirectionDirection,  
	finalSizeInteger and aColor.
	aSymbolDirectionDirection = #top, #bottom. #left or #right .
	Try with:  
	(UITheme current
		basicCreateArrowOfDirection: #top 
		size: 32 
		color: Color lightGreen) asMorph openInHand. 
	Fixed to work with translucent colours."
	
	|form resizeFactor arrow resizedForm |
	resizeFactor := 4.
	form := Form
		extent: finalSizeInteger asPoint * resizeFactor
		depth: Display depth.
	form fillColor: Color transparent.
	arrow := (self createArrowOfDirection: aSymbolDirection in: form boundingBox)
		borderWidth: 1;
		borderColor: aColor lighter.
	self
		updateScrollBarButtonAspect: arrow
		color: (aColor alphaMixed: 0.7 with: Color black).
	arrow fullDrawOn: form getCanvas.
	resizedForm := form
		magnify: form boundingBox
		by: 1 / resizeFactor
		smoothing: 4.
	^resizedForm trimBordersOfColor: Color transparent
]

{ #category : #'accessing - colors' }
UITheme >> borderColor [ 
	^ Color gray
]

{ #category : #accessing }
UITheme >> borderWidth [
	^ 1 * self displayScaleFactor
]

{ #category : #accessing }
UITheme >> builder [
	^ self class builder
]

{ #category : #'border-styles' }
UITheme >> buttonBorderStyleFor: aButton [
	aButton borderStyle: BorderStyle thinGray
]

{ #category : #'fill-styles' }
UITheme >> buttonBottomLeftForm [
	"Answer the form to use for the bottom left of a button."

	^self forms at: #buttonBottomLeft ifAbsent: [Form extent: 11@11 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonBottomMiddleForm [
	"Answer the form to use for the bottom middle of a button."

	^self forms at: #buttonBottomMiddle ifAbsent: [Form extent: 1@11 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonBottomRightForm [
	"Answer the form to use for the bottom right of a button."

	^self forms at: #buttonBottomRight ifAbsent: [Form extent: 11@11 depth: Display depth]
]

{ #category : #'accessing - colors' }
UITheme >> buttonColor [ 
	^ self settings buttonColor
]

{ #category : #'basic-colors' }
UITheme >> buttonColorFor: aButton [
	"Answer the colour for the given button."

	^self settings standardColorsOnly
		ifTrue: [self buttonColor]
		ifFalse: [ aButton colorToUse ]
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonColouredFillStyleFor: aButton [
	"Return the coloured button fillStyle for the given button."
	
	|round roundCorners tl t tr l m r bl b br|
	round := aButton wantsRoundedCorners.
	roundCorners := aButton roundedCorners.
	tl := (round and: [roundCorners includes: 1]) ifTrue: [self buttonSelectedTopLeftForm] ifFalse: [self buttonSquareSelectedTopLeftForm].
	t := self buttonSelectedTopMiddleForm.
	tr:= (round and: [roundCorners includes: 4]) ifTrue: [self buttonSelectedTopRightForm] ifFalse: [self buttonSquareSelectedTopRightForm].
	l := self buttonSelectedMiddleLeftForm. m := self buttonColouredMiddleColor. r := self buttonSelectedMiddleRightForm.
	bl := (round and: [roundCorners includes: 2]) ifTrue: [self buttonSelectedBottomLeftForm] ifFalse: [self buttonSquareSelectedBottomLeftForm].
	b := self buttonSelectedBottomMiddleForm.
	br := (round and: [roundCorners includes: 3]) ifTrue: [self buttonSelectedBottomRightForm] ifFalse: [self buttonSquareSelectedBottomRightForm].
	^self
		multiFormFillStyleFrom: {tl. t. tr. l. m. r. bl. b. br}
		in: aButton bounds
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonColouredMiddleColor [
	"Return the middle area colour for a coloured button fillStyle."
	
	^Color r: 102 g: 127 b: 168 range: 255
]

{ #category : #'border-styles-buttons' }
UITheme >> buttonCornerStyleIn: aThemedMorph [
	"Allow for themes to override default behaviour."
	
	^ #square
]

{ #category : #'border-styles-buttons' }
UITheme >> buttonDisabledBorderStyleFor: aButton [
	"Return the disabled button borderStyle for the given button."

	^self buttonNormalBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonDisabledFillStyleFor: aButton [
	"Return the disabled button fillStyle for the given color."

	^self buttonNormalFillStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonFocusBoundsFor: aButton [
	"Answer the bounds for drawing the focus indication for the
	given button."

	^aButton bounds
]

{ #category : #defaults }
UITheme >> buttonFocusIndicatorCornerRadiusFor: aButton [
	"Answer the default corner radius preferred for the focus indicator
	for the button for themes that support this."

	^aButton wantsRoundedCorners
		ifTrue: [7]
		ifFalse: [2]
]

{ #category : #defaults }
UITheme >> buttonFont [
	"Answer the button font to use."

	^StandardFonts buttonFont
]

{ #category : #'label-styles' }
UITheme >> buttonLabelFor: aButton [
	"Answer the label to use for the given button."

	|label|
	label := self buttonLabelForText: aButton label.
	label enabled: aButton enabled.
	label font: self buttonFont.
	label extent: label optimalExtent.
	^label
]

{ #category : #'label-styles' }
UITheme >> buttonLabelForText: aTextOrString [
	"Answer the label to use for the given text."
	^aTextOrString isString
		ifTrue: [(LabelMorph contents: aTextOrString) color: self textColor ]
		ifFalse: [|t|
				t := TextMorph new newContents: aTextOrString.
				t
					extent: t optimalExtent;
					margins: (Margin left: 0 right: 0 top: 0 bottom: 1);
					lock]
]

{ #category : #defaults }
UITheme >> buttonLabelInsetFor: aButton [
	"Answer the inset to use for a button's label."

	|left right|
	^aButton wantsRoundedCorners
		ifTrue: [left := ((aButton roundedCorners includesAnyOf: #(1 2)) ifTrue: [8] ifFalse: [4]).
				right := ((aButton roundedCorners includesAnyOf: #(3 4)) ifTrue: [8] ifFalse: [4]).
				Margin left: left top: 2 right: right bottom: 2]		
		ifFalse: [3@2]
]

{ #category : #'fill-styles' }
UITheme >> buttonMiddleLeftForm [
	"Answer the form to use for the middle left of a button."

	^self forms at: #buttonMiddleLeft ifAbsent: [Form extent: 11@1 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonMiddleRightForm [
	"Answer the form to use for the middle right of a button."

	^self forms at: #buttonMiddleRight ifAbsent: [Form extent: 11@1 depth: Display depth]
]

{ #category : #defaults }
UITheme >> buttonMinHeight [
	"Answer the minumum height of a button for this theme."
	
	^ 18 * self displayScaleFactor
]

{ #category : #defaults }
UITheme >> buttonMinWidth [
	"Answer the minumum width of a button for this theme."
	
	^24
]

{ #category : #'border-styles-buttons' }
UITheme >> buttonMouseOverBorderStyleFor: aButton [
	"Return the mouse over button borderStyle for the given button."
	
	^self buttonNormalBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonMouseOverFillStyleFor: aButton [
	"Return the button mouse over fillStyle for the given color."

	^self buttonNormalFillStyleFor: aButton
]

{ #category : #'border-styles-buttons' }
UITheme >> buttonNormalBorderStyleFor: aButton [
	"Return the normal button borderStyle for the given button."

	^BorderStyle simple
		width: 0;
		baseColor: Color transparent
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonNormalFillStyleFor: aButton [
	"Return the normal button fillStyle for the given button."
	
	(aButton valueOfProperty: #noFill ifAbsent: [false]) ifTrue: [^ SolidFillStyle color: Color transparent ].
	^ self normalFillStyleFor: aButton height: aButton height
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonPlainFillStyleFor: aButton [
	"Return the plain button fillStyle for the given button."
	
	|round roundCorners tl t tr l m r bl b br|
	round := aButton wantsRoundedCorners.
	roundCorners := aButton roundedCorners.
	tl := (round and: [roundCorners includes: 1]) ifTrue: [self buttonTopLeftForm] ifFalse: [self buttonSquareTopLeftForm].
	t := self buttonTopMiddleForm.
	tr:= (round and: [roundCorners includes: 4]) ifTrue: [self buttonTopRightForm] ifFalse: [self buttonSquareTopRightForm].
	l := self buttonMiddleLeftForm. m := self buttonPlainMiddleColor. r := self buttonMiddleRightForm.
	bl := (round and: [roundCorners includes: 2]) ifTrue: [self buttonBottomLeftForm] ifFalse: [self buttonSquareBottomLeftForm].
	b := self buttonBottomMiddleForm.
	br := (round and: [roundCorners includes: 3]) ifTrue: [self buttonBottomRightForm] ifFalse: [self buttonSquareBottomRightForm].
	^self
		multiFormFillStyleFrom: {tl. t. tr. l. m. r. bl. b. br}
		in: aButton bounds
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonPlainMiddleColor [
	"Return the middle area colour for a plain button fillStyle."
	
	^Color r: 211 g: 211 b: 211 range: 255
]

{ #category : #'border-styles-buttons' }
UITheme >> buttonPressedBorderStyleFor: aButton [
	"Return the pressed button borderStyle for the given button."

	^self buttonSelectedBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonPressedFillStyleFor: aButton [
	"Return the button pressed fillStyle for the given button."
		
	^self buttonSelectedFillStyleFor: aButton
]

{ #category : #defaults }
UITheme >> buttonPressedLabelInsetFor: aButton [
	"Answer the inset to use for a button's label when pressed."

	^self buttonLabelInsetFor: aButton
]

{ #category : #'border-styles-buttons' }
UITheme >> buttonSelectedBorderStyleFor: aButton [
	"Return the selected button borderStyle for the given button."

	^self buttonNormalBorderStyleFor: aButton
]

{ #category : #'fill-styles' }
UITheme >> buttonSelectedBottomLeftForm [
	"Answer the form to use for the bottom left of a selected button."

	^self forms at: #buttonSelectedBottomLeft ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSelectedBottomMiddleForm [
	"Answer the form to use for the bottom middle of a selected button."

	^self forms at: #buttonSelectedBottomMiddle ifAbsent: [Form extent: 1@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSelectedBottomRightForm [
	"Answer the form to use for the bottom right of a selected button."

	^self forms at: #buttonSelectedBottomRight ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'border-styles-buttons' }
UITheme >> buttonSelectedDisabledBorderStyleFor: aButton [
	"Return the selecteddisabled button borderStyle for the given button."

	^self buttonSelectedBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonSelectedDisabledFillStyleFor: aButton [
	"Return the button selected disabled fillStyle for the given color."
	
	^self buttonSelectedFillStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonSelectedFillStyleFor: aButton [
	"Return the normal button fillStyle for the given button."
	
	^ SolidFillStyle color: (self lightSelectionColorFor: aButton)
	
]

{ #category : #'fill-styles' }
UITheme >> buttonSelectedMiddleLeftForm [
	"Answer the form to use for the middle left of a selected button."

	^self forms at: #buttonSelectedMiddleLeft ifAbsent: [Form extent: 12@1 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSelectedMiddleRightForm [
	"Answer the form to use for the middle right of a selected button."

	^self forms at: #buttonSelectedMiddleRight ifAbsent: [Form extent: 12@1 depth: Display depth]
]

{ #category : #'border-styles-buttons' }
UITheme >> buttonSelectedMouseOverBorderStyleFor: aButton [
	"Return the selected mouse over button borderStyle for the given button."

	^self buttonSelectedBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonSelectedMouseOverFillStyleFor: aButton [
	"Return the button selected mouse over fillStyle for the given color."
	
	^self buttonSelectedFillStyleFor: aButton
]

{ #category : #'border-styles-buttons' }
UITheme >> buttonSelectedPressedBorderStyleFor: aButton [
	"Return the selected pressed button borderStyle for the given button."

	^self buttonNormalBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> buttonSelectedPressedFillStyleFor: aButton [
	"Return the button selected pressed fillStyle for the given color."

	^self buttonNormalFillStyleFor: aButton
]

{ #category : #'fill-styles' }
UITheme >> buttonSelectedTopLeftForm [
	"Answer the form to use for the top left of a selected button."

	^self forms at: #buttonSelectedTopLeft ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSelectedTopMiddleForm [
	"Answer the form to use for the top middle of a selected button."

	^self forms at: #buttonSelectedTopMiddle ifAbsent: [Form extent: 1@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSelectedTopRightForm [
	"Answer the form to use for the top right of a selected button."

	^self forms at: #buttonSelectedTopRight ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSquareBottomLeftForm [
	"Answer the form to use for the bottom left of a square button."

	^self forms at: #buttonSquareBottomLeft ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSquareBottomRightForm [
	"Answer the form to use for the bottom right of a square button."

	^self forms at: #buttonSquareBottomRight ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSquareSelectedBottomLeftForm [
	"Answer the form to use for the bottom left of a selected square button."

	^self forms at: #buttonSquareSelectedBottomLeft ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSquareSelectedBottomRightForm [
	"Answer the form to use for the bottom right of a selected square button."

	^self forms at: #buttonSquareSelectedBottomRight ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSquareSelectedTopLeftForm [
	"Answer the form to use for the top left of a selected square button."

	^self forms at: #buttonSquareSelectedTopLeft ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSquareSelectedTopRightForm [
	"Answer the form to use for the top right of a selected square button."

	^self forms at: #buttonSquareSelectedTopRight ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSquareTopLeftForm [
	"Answer the form to use for the top left of a square button."

	^self forms at: #buttonSquareTopLeft ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonSquareTopRightForm [
	"Answer the form to use for the top right of a square button."

	^self forms at: #buttonSquareTopRight ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonTopLeftForm [
	"Answer the form to use for the top left of a button."

	^self forms at: #buttonTopLeft ifAbsent: [Form extent: 11@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonTopMiddleForm [
	"Answer the form to use for the top middle of a button."

	^self forms at: #buttonTopMiddle ifAbsent: [Form extent: 1@12 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> buttonTopRightForm [
	"Answer the form to use for the top right of a button."

	^self forms at: #buttonTopRight ifAbsent: [Form extent: 11@12 depth: Display depth]
]

{ #category : #'accessing - colors' }
UITheme >> caretColor [
	^ Color blue
]

{ #category : #services }
UITheme >> centeredAlertIn: aThemedMorph text: aStringOrText title: aString configure: aBlock [
	"Answer the result of an alert dialog (true) with the given label and title."

	| dialog |
	SoundTheme useThemeSounds ifTrue: [ self alertSound play ].
	dialog := (AlertDialogWindow newWithTheme: aThemedMorph theme)
		textFont: self textFont;
		title: aString;
		text: aStringOrText.
	aBlock value: dialog.
	dialog left: ((self currentWorld width / 2) - (dialog width /2)).
	dialog top: ((self currentWorld height / 2) - (dialog height /2)).
	dialog openModal.
	^ dialog cancelled not
]

{ #category : #'border-styles-buttons' }
UITheme >> checkboxButtonDisabledBorderStyleFor: aCheckboxButton [
	"Return the disabled checkbox button borderStyle for the given button."

	^self checkboxButtonNormalBorderStyleFor: aCheckboxButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> checkboxButtonDisabledFillStyleFor: aCheckboxButton [
	"Return the disabled checkbox button fillStyle for the given button."
	
	^self checkboxButtonNormalFillStyleFor: aCheckboxButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> checkboxButtonLabelNormalFillStyleFor: aCheckboxButton label: aLabel [
	"Return the selected disabled checkbox button fillStyle for the given button."
	
	^ aLabel color
]

{ #category : #'border-styles-buttons' }
UITheme >> checkboxButtonNormalBorderStyleFor: aChecboxButton [
	"Return the normal checkbox button borderStyle for the given button."

	^BorderStyle simple
		width: 1;
		baseColor: Color transparent
]

{ #category : #'fill-styles-buttons' }
UITheme >> checkboxButtonNormalFillStyleFor: aCheckboxButton [
	"Return the normal checkbox button fillStyle for the given checkbox button."
	
	^(ImageFillStyle form: self checkboxForm) origin: aCheckboxButton topLeft
]

{ #category : #'border-styles-buttons' }
UITheme >> checkboxButtonSelectedBorderStyleFor: aCheckboxButton [
	"Return the selected checkbox button borderStyle for the given button."

	^self checkboxButtonNormalBorderStyleFor: aCheckboxButton
]

{ #category : #'border-styles-buttons' }
UITheme >> checkboxButtonSelectedDisabledBorderStyleFor: aCheckboxButton [
	"Return the selected disabled checkbox button borderStyle for the given button."

	^self checkboxButtonDisabledBorderStyleFor: aCheckboxButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> checkboxButtonSelectedDisabledFillStyleFor: aCheckboxButton [
	"Return the selected disabled checkbox button fillStyle for the given button."
	
	^self checkboxButtonSelectedFillStyleFor:  aCheckboxButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> checkboxButtonSelectedFillStyleFor: aCheckboxButton [
	"Return the selected checkbox button fillStyle for the given checkbox button."
	
	^(ImageFillStyle form: self checkboxSelectedForm) origin: aCheckboxButton topLeft
]

{ #category : #'border-styles-buttons' }
UITheme >> checkboxCornerStyleFor: aCheckbox [
	"Answer the corner style for checkbox buttons."
	
	^#square
]

{ #category : #forms }
UITheme >> checkboxForm [
	"Answer the form to use for a normal checkbox."

	^self  checkboxUnselectedForm
]

{ #category : #'label-styles' }
UITheme >> checkboxLabelFor: aCheckbox [
	"Answer the label to use for the given checkbox."

	|label|
	label := self checkboxLabelForText: aCheckbox label.
	label enabled: aCheckbox enabled.
	label font: self labelFont.
	^label
]

{ #category : #'label-styles' }
UITheme >> checkboxLabelForText: aTextOrString [
	"Answer the label to use for the given text."

	|morph|
	morph := aTextOrString isString
		ifTrue: [(LabelMorph contents: aTextOrString)
				disabledStyle: self disabledItemStyle]
		ifFalse: [|t|
				t := TextMorph new newContents: aTextOrString.
				t extent: t optimalExtent].
	^morph 
		vResizing: #shrinkWrap;
		hResizing: #spaceFill;
		lock
]

{ #category : #'label-styles' }
UITheme >> checkboxMarkerForm [
	"Answer the form to use for a checkbox marker."

	^self forms at: #checkboxMarker ifAbsent: [Form extent: 12@12 depth: Display depth]
]

{ #category : #'fill-styles-buttons' }
UITheme >> checkboxSelectedForm [
	"Answer the form to use for a selected checkbox."

	^ self iconNamed: #checkboxSelectedForm
]

{ #category : #forms }
UITheme >> checkboxUnselectedForm [
	"Answer the form to use for a selected checkbox."

	^ self iconNamed: #checkboxUnselectedForm
]

{ #category : #services }
UITheme >> chooseColorIn: aThemedMorph title: aString color: aColor [
	"Answer the result of a color selector dialog with the given title and initial color."

	|dialog|
	dialog := (ColorSelectorDialogWindow newWithTheme: aThemedMorph theme)
		title: aString;
		selectedColor: aColor.
	dialog openModal.
	^ dialog cancelled ifFalse: [ dialog selectedColor ]
]

{ #category : #services }
UITheme >> chooseColorIn: aThemedMorph title: aString color: aColor for: aBlock [
	"execute block with result of a color selector dialog with the given title and initial color."

	|d newColor|
	d := (ColorSelectorDialogWindow newWithTheme: aThemedMorph theme)
			title: aString;
			selectedColor: aColor.
	d extent: d initialExtent.
	d announcer when: ColorChanged do: [:ann | 
		aBlock value: ann newColor].
	d openModal.
	
	newColor := d  cancelled
		ifTrue: [aColor]
		ifFalse: [d selectedColor].
				
	aBlock value: newColor.
]

{ #category : #services }
UITheme >> chooseDirectoryIn: aThemedMorph title: title path: path [
	"Answer the result of a file dialog with the given title, choosing directories only."

	| dialog |
	dialog := (FileDialogWindow newWithTheme: aThemedMorph theme)
		title: title;
		answerDirectory.
	path ifNotNil: [ dialog selectPath: path ].
	^ dialog openModal answer
]

{ #category : #services }
UITheme >> chooseDropListIn: aThemedMorph text: aStringOrText title: aString list: aList [
	"Answer the result of a drop list chooser with the given label, title and list."

	^((ChooseDropListDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: aStringOrText;
			list: aList) openModal selectedItem
]

{ #category : #services }
UITheme >> chooseExistingFileReferenceIn: aThemedMorph title: title extensions: exts path: path preview: preview [
	"Answer the result of a file name chooser dialog with the given title, extensions
	path and preview type.
	Answer nil or a filename."

	| dialog pathFileReference |
	pathFileReference := path asFileReference.
	dialog := FileDialogWindow basicNew
		basicTheme: aThemedMorph theme;
		previewType: preview;
		fileNameText: pathFileReference basename;
		initialize;
		title: title;
		answerPathName.	
	exts ifNotNil: [ dialog validExtensions: exts ].
	path ifNotNil: [ dialog selectPath: pathFileReference pathString ].
	^ dialog openModal answer ifNotNil: #asFileReference
]

{ #category : #services }
UITheme >> chooseFileIn: aThemedMorph title: title extensions: exts path: path preview: preview [
	"Answer the result of a file open dialog with the given title, extensions path and preview type.
	Answer nil or a filename."

	| dialog |
	dialog := FileDialogWindow basicNew
		basicTheme: aThemedMorph theme;
		previewType: preview;
		initialize;
		title: title;
		answerFileEntry.
	exts ifNotNil: [ dialog validExtensions: exts ].
	path ifNotNil: [ dialog selectPath: path ].
	^ dialog openModal answer
]

{ #category : #services }
UITheme >> chooseFileNameIn: aThemedMorph title: title extensions: exts path: path preview: preview [
	"Answer the result of a file name chooser dialog with the given title, extensions
	path and preview type.
	Answer nil or a filename."
	| dialog |
	self deprecated: 'Use UIManager default chooseExistingFileReference:extensions:path:preview:. instead.' on: '26 October 2018' in: #Pharo7.
	dialog := FileDialogWindow basicNew
		basicTheme: aThemedMorph theme;
		previewType: preview;
		initialize;
		title: title;
		answerFileName.
	exts ifNotNil: [ dialog validExtensions: exts ].
	path ifNotNil: [ dialog selectPath: path ].
	^ dialog openModal answer
]

{ #category : #services }
UITheme >> chooseFontIn: aThemedMorph title: aString font: aFont [
	"Answer the result of a font selector dialog with the given title and initial font."

	| dialog |
	dialog :=  Cursor wait showWhile: [
		self newFontSelector
			basicTheme: aThemedMorph theme;
			title: aString;
			selectedFont: aFont].
	dialog openModal.
	^ dialog cancelled ifFalse: [dialog selectedFont]
]

{ #category : #services }
UITheme >> chooseForSaveFileReferenceIn: aThemedMorph title: title extensions: exts path: path preview: preview [
	"Answer the result of a file name chooser dialog with the given title, extensions
	path and preview type.
	Answer nil or a filename."

	| dialog pathFileReference |
	pathFileReference := path asFileReference.
	dialog := (FileDialogWindow newWithTheme: aThemedMorph theme)
		title: title;
		fileNameText: pathFileReference basename;
		answerSaveFile.
	exts ifNotNil: [ dialog validExtensions: exts ].
	path ifNotNil: [ dialog selectPath: path ].
	^ dialog openModal answer
]

{ #category : #services }
UITheme >> chooseFullFileNameIn: aThemedMorph title: title extensions: exts path: path preview: preview [
	"Answer the result of a file name chooser dialog with the given title, extensions
	path and preview type.
	Answer nil or a full filename."

	| dialog |
	self deprecated: 'Use UIManager default chooseExistingFileReference:extensions:path:preview:. instead.' on: '26 October 2018' in: #Pharo7.
	dialog := FileDialogWindow basicNew
		basicTheme: aThemedMorph theme;
		previewType: preview;
		initialize;
		title: title;
		answerPathName.
	exts ifNotNil: [ dialog validExtensions: exts ].
	path ifNotNil: [ dialog selectPath: path ].
	^ dialog openModal answer
]

{ #category : #services }
UITheme >> chooseFullFileNameIn: aThemedMorph title: title patterns: patterns path: path preview: preview [
	"Answer the result of a file name chooser dialog with the given title, patterns
	path and preview type.
	Answer nil or a filename."

	| dialog |
	dialog := FileDialogWindow basicNew
		basicTheme: aThemedMorph theme;
		previewType: preview;
		initialize;
		title: title;
		answerPathName.
	patterns
		ifNotNil: [ dialog
				fileSelectionBlock: [ :de | 
					(dialog defaultFileSelectionBlock value: de)
						and: [ de isDirectory or: [ patterns anySatisfy: [ :pat | pat match: de name ] ] ] ] ].
	path ifNotNil: [ dialog selectPath: path ].
	^ dialog openModal answer
]

{ #category : #services }
UITheme >> chooseIn: aThemedMorph title: title labels: labels values: values lines: lines [
	"Answer the result of a popup choice with the given title, labels, values and lines."

	| dialog |
	dialog := (PopupChoiceDialogWindow newWithTheme: aThemedMorph theme)
		title: (title isEmpty ifTrue: ['Choose' translated] ifFalse: [title asString]);
		labels: labels;
		lines: (lines ifNil: [#()]);
		model: values.
	^ dialog openModal choice
]

{ #category : #services }
UITheme >> chooseIn: aThemedMorph title: title message: aMessage labels: labels values: values lines: lines [
	"Answer the result of a popup choice with the given title, labels, values and lines."

	|dialog|
	dialog := (PopupChoiceDialogWindowWithMessage newWithTheme: aThemedMorph theme)
		title: (title isEmpty ifTrue: ['Choose' translated] ifFalse: [title asString]);
		textFont: self textFont;
		message: aMessage;
		labels: labels;
		lines: (lines ifNil: [#()]);
		model: values.
	^dialog openModal choice
]

{ #category : #services }
UITheme >> chooseOrRequestIn: aThemedMorph title: title labels: labels values: values lines: lines [
	"Answer the result of a popup choice with the given title, labels, values and lines."

	| dialog choice |
	dialog := (PopupChoiceOrRequestDialogWindow newWithTheme: aThemedMorph theme)
		title: (title ifEmpty: [ 'Choose' translated ] ifNotEmpty: #asString);
		labels: labels;
		lines: (lines ifNil: [ #() ]);
		model: values.
	choice := dialog openModal choice.
	dialog cancelled ifTrue: [ ^ nil ].
	^ choice ifNil: [ dialog filterValue ]
]

{ #category : #'accessing - colors' }
UITheme >> classExtensionColor [
	^ Color gray darker
]

{ #category : #'label-styles' }
UITheme >> configureDialogWindowLabelAreaFrameFor: aWindow [
	"Configure the layout frame for the label area for the given dialog window."

	|frame|
	self configureWindowLabelAreaFrameFor: aWindow.
	aWindow labelArea ifNil: [^ self].	
	frame := aWindow labelArea layoutFrame.
	frame
		leftOffset: 0;
		rightOffset: 0
]

{ #category : #configure }
UITheme >> configureDropListMorph: aMorph [
	"This also uses the fillStyle hack :(
	 check at: #dropListNormalFillStyleFor: for changing style"
]

{ #category : #configure }
UITheme >> configureLabelMorph: aMorph [
]

{ #category : #configure }
UITheme >> configureLazyListMorph: listMorph [ 
	self configureScrollPane: listMorph.
]

{ #category : #configure }
UITheme >> configureMorphTreeMorph: aMorph [
	aMorph preferedPaneColor: Color white.
	aMorph 
		rowColorForEven: Color white
		odd: Color white.
]

{ #category : #configure }
UITheme >> configurePluggableButtonMorph: aMorph [
	"This will not work because it is using the #normalFillStyle hack :(
	 So, go check the #buttonNormalFillStyleFor: method, which is the one that 
	 actually does something (he and his siblings)"
]

{ #category : #configure }
UITheme >> configurePluggableListMorph: listMorph [ 
	self configureScrollPane: listMorph.
]

{ #category : #configure }
UITheme >> configurePluggableTextFieldMorph: textFieldMorph [
]

{ #category : #configure }
UITheme >> configurePluggableTextMorph: textMorph [ 
	textMorph 
		color: Color white;
		borderWidth: 1.
]

{ #category : #configure }
UITheme >> configureScrollPane: aMorph [
	aMorph color: Color white.
]

{ #category : #configure }
UITheme >> configureSystemWindow: aWindow [ 
	aWindow basicBorderColor: Color lightGray.
	aWindow basicBorderWidth: 1.
	aWindow color: Color lightGray lighter lighter lighter.	
	self
		configureWindowBorderFor: aWindow;
		configureWindowDropShadowFor: aWindow.	

]

{ #category : #configure }
UITheme >> configureTextMorph: textMorph [ 
]

{ #category : #'*Polymorph-Widgets-Themes' }
UITheme >> configureWatcherWindowLabelAreaFor: aWindow [
	"Configure the label area for the given Watcher window."

	|padding|
	padding := 0.
	aWindow labelArea
		addMorphBack: (Morph new extent: aWindow class borderWidth @ 0).
	aWindow hasCloseBox ifTrue: [aWindow addCloseBox. padding := padding + 1].
"	aWindow hasCollapseBox ifTrue: [aWindow addCollapseBox. padding := padding + 1].
	aWindow hasExpandBox ifTrue: [aWindow addExpandBox. padding := padding + 1].
	aWindow hasMenuBox ifTrue: [padding := padding - 1].
"	aWindow labelArea
		addMorphBack: (Morph new extent: aWindow class borderWidth @ 0; hResizing: #spaceFill).
	aWindow basicLabel ifNotNil: [:label | aWindow labelArea addMorphBack: label; hResizing: #shrinkWrap].
	aWindow labelArea
		addMorphBack: (Morph new extent: aWindow class borderWidth @ 0; hResizing: #spaceFill).
	padding > 0 ifTrue: [
		aWindow labelArea
			addMorphBack: (Morph new extent: (aWindow boxExtent x * padding) @ 0)].
"	aWindow hasMenuBox ifTrue: [aWindow addMenuControl]."
	aWindow labelArea
		addMorphBack: (Morph new extent: aWindow class borderWidth @ 0)
]

{ #category : #'border-styles' }
UITheme >> configureWindowBorderFor: aWindow [
	"Configure the border for the given window."

	aWindow roundedCorners: #(1 2 3 4).
	aWindow borderStyle: (BorderStyle
		width: 1 color: Color lightGray)
]

{ #category : #'border-styles' }
UITheme >> configureWindowDropShadowFor: aWindow [

	aWindow hasDropShadow: false
]

{ #category : #'label-styles' }
UITheme >> configureWindowLabelAreaFor: aWindow [
	"Configure the label area for the given window."

	|padding|
	padding := 0.
	aWindow labelArea
		addMorphBack: (Morph new extent: aWindow class borderWidth @ 0).
	aWindow hasCloseBox ifTrue: [aWindow addCloseBox. padding := padding + 1].
	aWindow hasCollapseBox ifTrue: [aWindow addCollapseBox. padding := padding + 1].
	aWindow hasExpandBox ifTrue: [aWindow addExpandBox. padding := padding + 1].
	aWindow hasMenuBox ifTrue: [padding := padding - 1].
	aWindow labelArea
		addMorphBack: (Morph new extent: aWindow class borderWidth @ 0; hResizing: #spaceFill).
	aWindow basicLabel ifNotNil: [:label | 
		label color: self textColor.
		aWindow labelArea 
			addMorphBack: label; 
			hResizing: #shrinkWrap ].
	aWindow labelArea
		addMorphBack: (Morph new extent: aWindow class borderWidth @ 0; hResizing: #spaceFill).
	padding > 0 ifTrue: [
		aWindow labelArea
			addMorphBack: (Morph new extent: (aWindow boxExtent x * padding) @ 0)].
	aWindow hasMenuBox ifTrue: [aWindow addMenuControl].
	aWindow labelArea
		addMorphBack: (Morph new extent: aWindow class borderWidth @ 0)
]

{ #category : #'label-styles' }
UITheme >> configureWindowLabelAreaFrameFor: aWindow [
	"Configure the layout frame for the label area for the given window."

	|frame windowBorderWidth|
	aWindow labelArea ifNil: [^ self].	
	windowBorderWidth := aWindow class borderWidth.
	aWindow labelArea
		layoutPolicy: RowLayout new;
		cellPositioning: #topCenter;
		hResizing: #spaceFill;
		wrapCentering: #topLeft;
		layoutInset: (Margin left: 0 top: windowBorderWidth right: 0 bottom: 1).
	frame := LayoutFrame identity bottomFraction: 0 ; topOffset: aWindow labelHeight negated.
	aWindow labelArea layoutFrame: frame
]

{ #category : #'border-styles-buttons' }
UITheme >> controlButtonDisabledBorderStyleFor: aButton [
	"Return the disabled control button borderStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."

	^self buttonDisabledBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> controlButtonDisabledFillStyleFor: aButton [
	"Return the disabled control button fillStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."
	
	^self controlButtonSelectedFillStyleFor: aButton
]

{ #category : #defaults }
UITheme >> controlButtonLabelInsetFor: aButton [
	"Answer the inset to use for a control button's label."

	^2
]

{ #category : #'border-styles-buttons' }
UITheme >> controlButtonMouseOverBorderStyleFor: aButton [
	"Return the mouse over control button borderStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."

	^self buttonMouseOverBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> controlButtonMouseOverFillStyleFor: aButton [
	"Return the mouse over control button fillStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."
	
	^self controlButtonNormalFillStyleFor: aButton
]

{ #category : #'border-styles-buttons' }
UITheme >> controlButtonNormalBorderStyleFor: aButton [
	"Return the normal control button borderStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."

	^self buttonNormalBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> controlButtonNormalFillStyleFor: aButton [
	"Return the normal control button fillStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."
	
	^self buttonSelectedFillStyleFor: aButton
]

{ #category : #'border-styles-buttons' }
UITheme >> controlButtonPressedBorderStyleFor: aButton [
	"Return the pressed control button borderStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."

	^self buttonPressedBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> controlButtonPressedFillStyleFor: aButton [
	"Return the pressed button fillStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."
	
	^self controlButtonSelectedFillStyleFor: aButton
]

{ #category : #'border-styles-buttons' }
UITheme >> controlButtonSelectedDisabledBorderStyleFor: aButton [
	"Return the selected disabled control button borderStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."

	^self buttonSelectedDisabledBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> controlButtonSelectedDisabledFillStyleFor: aButton [
	"Return the selected disabled control button fillStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."
	
	^self controlButtonSelectedFillStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> controlButtonSelectedFillStyleFor: aButton [
	"Return the selected control button fillStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."
	
	^self buttonNormalFillStyleFor: aButton
]

{ #category : #'border-styles-buttons' }
UITheme >> controlButtonSelectedMouseOverBorderStyleFor: aButton [
	"Return the selected mouse over control button borderStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."

	^self buttonSelectedMouseOverBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> controlButtonSelectedMouseOverFillStyleFor: aButton [
	"Return the selected mouse over control button fillStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."
	
	^self controlButtonSelectedFillStyleFor: aButton
]

{ #category : #'border-styles-buttons' }
UITheme >> controlButtonSelectedPressedBorderStyleFor: aButton [
	"Return the selected pressed control button borderStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."

	^self buttonSelectedPressedBorderStyleFor: aButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> controlButtonSelectedPressedFillStyleFor: aButton [
	"Return the selected pressed button fillStyle for the given button.
	Control buttons are generally used for drop-lists and expanders."
	
	^self controlButtonNormalFillStyleFor: aButton
]

{ #category : #scrollbars }
UITheme >> createArrowImagesCache [
	"Creates the cache to store the arrow forms"

	^ LRUCache new
		maximumWeight: 40;
		factory: [ :key |
			self
				scrollbarArrowOfDirection: key first
				size: key second
				color: key third ];
		yourself
]

{ #category : #scrollbars }
UITheme >> createArrowOfDirection: aSymbol in: aRectangle [ 
	"PRIVATE - create an arrow bounded in aRectangle"

	| arrow vertices |
	vertices := self scrollBarButtonArrowVertices: aRectangle.
	""
	arrow := PolygonMorph 
				vertices: vertices
				color: Color transparent
				borderWidth: 0
				borderColor: Color black.
	""
	arrow bounds: (arrow bounds insetBy: (aRectangle width / 6) rounded).
	""
	aSymbol == #right 
		ifTrue: [arrow rotationDegrees: arrow rotationDegrees + 90].
	aSymbol == #bottom 
		ifTrue: [arrow rotationDegrees: arrow rotationDegrees + 180].
	aSymbol == #left 
		ifTrue: [arrow rotationDegrees: arrow rotationDegrees + 270].
	""
	^arrow
]

{ #category : #scrollbars }
UITheme >> createArrowOfDirection: aSymbolDirection size: finalSizeInteger color: aColor [ 
	"Defer to current UITheme if available."
	
	^self
		scrollbarArrowOfDirection: aSymbolDirection
		size: finalSizeInteger
		color: aColor
]

{ #category : #scrollbars }
UITheme >> createBoxImagesCache [
	"Creates the cache to store the arrow forms"
	
	^ LRUCache new
		maximumWeight: 20;
		factory: [ :key |
			self createBoxOfSize: key first color: key second ];
		yourself
]

{ #category : #scrollbars }
UITheme >> createBoxIn: aRectangle [ 
	"PRIVATE - create an box bounded in aRectangle"
	| box |
	box := Morph new.
	box extent: (aRectangle scaleBy: 1 / 2) extent rounded;
		 borderWidth: 0.
	""
	^ box
]

{ #category : #scrollbars }
UITheme >> createBoxOfSize: finalSizeInteger color: aColor [ 
	"PRIVATE - create a box with finalSizeInteger and aColor  
	 
	Try with:  
	(UITheme current createBoxOfSize: 32 color: Color lightGreen) 
          asMorph openInHand.  
	"
	| resizeFactor outerBox innerBox resizedForm |
	resizeFactor := 4.
	outerBox := Morph new.
	outerBox extent: finalSizeInteger asPoint * resizeFactor;
		 color: aColor.
	""
	innerBox := self createBoxIn: outerBox bounds.
	self updateScrollBarButtonAspect: innerBox color: aColor muchDarker.
	outerBox addMorphCentered: innerBox.
	""
	resizedForm := outerBox imageForm
				magnify: outerBox imageForm boundingBox
				by: 1 / resizeFactor
				smoothing: 4.
	""
	^ (resizedForm replaceColor: aColor withColor: Color transparent)
		trimBordersOfColor: Color transparent
]

{ #category : #'label-styles' }
UITheme >> createCloseBoxFor: aSystemWindow [
	"Answer a button for closing the window."
	
	^(self
		newCloseControlIn: aSystemWindow
		for: aSystemWindow
		action: [aSystemWindow closeBoxHit]
		help: 'Close this window' translated)
		extent: aSystemWindow boxExtent
]

{ #category : #'label-styles' }
UITheme >> createCollapseBoxFor: aSystemWindow [
	"Answer a button for minimising the window."
	
	|form msb|
	form := self windowMinimizeForm.
	msb := MultistateButtonMorph new extent: form extent.
	msb activeEnabledNotOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowMinimizePassiveForm.
	msb extent: form extent.
	msb passiveEnabledNotOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowMinimizeOverForm.
	msb extent: form extent.
	msb
		activeEnabledOverUpFillStyle: (ImageFillStyle form: form);
		passiveEnabledOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowMinimizePassiveForm.
	msb
		extent: form extent;
		activeEnabledOverDownFillStyle: (ImageFillStyle form: form);
		passiveEnabledOverDownFillStyle: (ImageFillStyle form: form);
		addUpAction: [aSystemWindow collapseBoxHit];
		setBalloonText: 'Collapse this window' translated;
		extent: aSystemWindow boxExtent.
	^msb
]

{ #category : #'label-styles' }
UITheme >> createExpandBoxFor: aSystemWindow [
	"Answer a button for maximising/restoring the window."
	
	|form msb|
	form := self windowMaximizeForm.
	msb := MultistateButtonMorph new extent: form extent.
	msb activeEnabledNotOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowMaximizePassiveForm.
	msb extent: form extent.
	msb passiveEnabledNotOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowMaximizeOverForm.
	msb extent: form extent.
	msb
		activeEnabledOverUpFillStyle: (ImageFillStyle form: form);
		passiveEnabledOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowMaximizePassiveForm.
	msb
		extent: form extent;
		activeEnabledOverDownFillStyle: (ImageFillStyle form: form);
		passiveEnabledOverDownFillStyle: (ImageFillStyle form: form);
		addUpAction: [aSystemWindow expandBoxHit];
		setBalloonText: 'Expand to full screen' translated;
		extent: aSystemWindow boxExtent.
	^msb
]

{ #category : #'label-styles' }
UITheme >> createMenuBoxFor: aSystemWindow [
	"Answer a button for the window menu."
	
"	^aSystemWindow createBox
		labelGraphic: (self windowMenuIconFor: aSystemWindow);
		extent: aSystemWindow boxExtent;
		actWhen: #buttonDown;
		actionSelector: #offerWindowMenu;
		setBalloonText: 'window menu' translated"
	
	|form msb|
	form := self windowMenuForm.
	msb := MultistateButtonMorph new extent: form extent.
	msb activeEnabledNotOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowMenuPassiveForm.
	msb extent: form extent.
	msb activeDisabledNotOverUpFillStyle: (ImageFillStyle form: form).
	msb passiveEnabledNotOverUpFillStyle: (ImageFillStyle form: form).
	msb passiveDisabledNotOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowMenuForm.
	msb extent: form extent.
	msb
		activeEnabledOverUpFillStyle: (ImageFillStyle form: form);
		passiveEnabledOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowMenuPassiveForm.
	msb
		extent: form extent;
		activeEnabledOverDownFillStyle: (ImageFillStyle form: form);
		passiveEnabledOverDownFillStyle: (ImageFillStyle form: form);
		addUpAction: [aSystemWindow offerWindowMenu];
		setBalloonText: 'window menu' translated;
		extent: aSystemWindow boxExtent.
	^msb
]

{ #category : #accessing }
UITheme >> currentSettings [
	^ self class currentSettings
]

{ #category : #services }
UITheme >> customQuestionIn: aThemedMorph text: labelText yesText: yesText noText: noText cancelText: cancelText default: defaultOption title: aString [
	"Answer the result of a question dialog with the given label, button labels and title.
	defaultOption should be one of true, false or nil to set the default button."

	self questionSound play.
	^((CustomQuestionDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: labelText;
			yesText: yesText help: nil;
			noText: noText help: nil;
			cancelText: cancelText help: nil;
			default: defaultOption) openModal answer
]

{ #category : #services }
UITheme >> customQuestionIn: aThemedMorph text: labelText yesText: yesText noText: noText title: aString [
	"Answer the result of a question dialog with the given label, button labels and title."

	self questionSound play.
	^((CustomQuestionDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: labelText;
			yesText: yesText help: nil;
			noText: noText help: nil) dialog answer
]

{ #category : #'accessing - colors' }
UITheme >> dangerBackgroundColor [
	^ self dangerTextColor darker darker
]

{ #category : #'accessing - colors' }
UITheme >> dangerTextColor [
	^ Color red darker darker
]

{ #category : #'accessing - colors' }
UITheme >> darkBaseColor [
	^ self class darkBaseColor
]

{ #category : #private }
UITheme >> darkBaseColorFor: aButton [
	^ self class darkBaseColor
]

{ #category : #defaults }
UITheme >> defaultButtonBorderColor [
	"Answer the color to use for a 'default' button."

	^self settings selectionColor
]

{ #category : #defaults }
UITheme >> defaultMenuColor [
	"Answer the default color to use for a menu
	in the absence of an override in settings."

	^ self settings fallbackMenuColor 
]

{ #category : #defaults }
UITheme >> defaultMenuTitleColor [
	"Answer the default color to use for a menu title
	in the absence of an override in settings."

	^self settings menuTitleColor
]

{ #category : #initialization }
UITheme >> defaultSettings [
	"Answer the default settings."

	^self class defaultSettings copy
]

{ #category : #initialization }
UITheme >> defaultSoundTheme [
	"Answer the default sound theme.
	Answer the system sound theme by default."

	^SoundTheme current
]

{ #category : #services }
UITheme >> denyIn: aThemedMorph text: aStringOrText title: aString [
	"Answer the result of an deny dialog (true) with the given label and title."

	self denySound play.
	^((DenyDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: aStringOrText) openModal cancelled not
]

{ #category : #sounds }
UITheme >> denySound [
	"Answer the deny sound."

	^self soundTheme denySound
]

{ #category : #'fill-styles' }
UITheme >> desktopColor [

	^(Color r: 240 g: 240 b: 240 range: 255)
]

{ #category : #'fill-styles' }
UITheme >> desktopImageFor: aWorld [
	"Answer the desktop image for the given world.
	Look for an image file with the name of the theme.
	Answer nil for none available."

	|file|
	file := FileSystem disk workingDirectory / self class themeName , 'jpg'.
	^ file exists ifTrue: [
		ImageReadWriter formFromFileNamed: file fullName]
]

{ #category : #'fill-styles' }
UITheme >> desktopImageLayout [
	"Answer the layout symbol for any desktop image.
	See AlphaImageMorph>>layoutSymbols."

	^self settings desktopImageLayout
]

{ #category : #'fill-styles' }
UITheme >> dialogWindowActiveFillStyleFor: aWindow [
	"Return the window active fillStyle for the given window."
	
	^self windowActiveFillStyleFor: aWindow
]

{ #category : #'fill-styles' }
UITheme >> dialogWindowInactiveFillStyleFor: aWindow [
	"Return the window active fillStyle for the given window."
	
	^self windowInactiveFillStyleFor: aWindow
]

{ #category : #defaults }
UITheme >> dialogWindowPreferredCornerStyleFor: aDialogWindow [
	"Answer the preferred corner style for the given dialog."

	^ self windowPreferredCornerStyleFor:aDialogWindow
]

{ #category : #'basic-colors-diffs' }
UITheme >> diffAdditionalLineBackgroundColor [
	"Answer the color used to show additions in a diff view."
	^ Color green alpha: 0.2
]

{ #category : #'basic-colors-diffs' }
UITheme >> diffAdditionalTextInLineBackgroundColor [
	"Answer the color used to show addition highlights in a text line."
	^ self diffAdditionalLineBackgroundColor alpha: 0.4
]

{ #category : #'basic-colors-diffs' }
UITheme >> diffEdgeColor [
	"Answer the color used to show the border of the changes."
	^ Color gray alpha: 0.3
]

{ #category : #'basic-colors-diffs' }
UITheme >> diffJoinColor [
	"Answer the color used for the join bar."
	^ Color paleBlue duller
]

{ #category : #'basic-colors-diffs' }
UITheme >> diffMapColor [
	"Answer the color used for the mapping bar on the left side."
	^ self backgroundColor 
]

{ #category : #'basic-colors-diffs' }
UITheme >> diffModificatedLineBackgroundColor [
	"Answer the color used to show changes."
	^ Color yellow alpha: 0.2
]

{ #category : #'basic-colors-diffs' }
UITheme >> diffRemovalHighlightColor [
	"Answer the color used to show removal highligths."
	^ self diffRemovedLinesBackgroundColor alpha: 0.4
]

{ #category : #'basic-colors-diffs' }
UITheme >> diffRemovedLinesBackgroundColor [
	"Answer the color used to show removals in a diff view."
	^ Color red alpha: 0.2
]

{ #category : #'accessing - colors' }
UITheme >> disabledColor [ 
	^ Color gray
]

{ #category : #'label-styles' }
UITheme >> disabledItemStyle [
	"Answer either #plain or #inset to determine how
	diabled text is drawn."

	^#plain
]

{ #category : #'accessing - colors' }
UITheme >> disabledTextColor [ 
	^ self disabledColor
]

{ #category : #accessing }
UITheme >> displayScaleFactor [
	
	^ self currentWorld displayScaleFactor
]

{ #category : #accessing }
UITheme >> dockingBarBorderWidth [ 
	^ 0
]

{ #category : #'fill-styles' }
UITheme >> dockingBarNormalFillStyleFor: aToolDockingBar [
	^ SolidFillStyle color: Color transparent
]

{ #category : #'border-styles' }
UITheme >> drawTabGroupFinishingFor: aTabGroupMorph on: aCanvas [
	"Patch up any visuals for the selected tab."
]

{ #category : #'border-styles' }
UITheme >> drawTextAdornmentFor: aPluggableTextMorph color: aColor on: aCanvas [
	"Indicate edit status for the given morph."
	
	|bounds size fillStyle|
	bounds := aPluggableTextMorph innerBounds.
	size := 25.
	fillStyle := (GradientFillStyle ramp: {
			0.0->(self backgroundColor alpha: 0.01).
			0.8->aColor.
			1.0->aColor})
		origin: bounds topRight - (size@0);
		direction: (size @ size negated) // 4;
		radial: false.
	aCanvas
		drawPolygon:  {bounds topRight. bounds topRight + (0@size). bounds topRight - (size@0)}
		fillStyle: fillStyle
]

{ #category : #'border-styles' }
UITheme >> drawTextAdornmentsFor: aPluggableTextMorph on: aCanvas [
	"Indicate edit status for the given morph."

	(aPluggableTextMorph hasEditingConflicts or: [ aPluggableTextMorph hasValidText not ])
		ifTrue: [ ^ self drawTextAdornmentFor: aPluggableTextMorph color: Color red on: aCanvas ].
	aPluggableTextMorph hasUnacceptedEdits
		ifTrue: [ aPluggableTextMorph model wantsVisualFeedback
				ifTrue: [ ^ self drawTextAdornmentFor: aPluggableTextMorph color: Color orange on: aCanvas ] ]
]

{ #category : #'border-styles' }
UITheme >> drawWindowActiveDropShadowFor: aSystemWindow on: aCanvas [
	"Draw the active drop shadow for the given window."
	
	
	^self windowActiveDropShadowStyle == #diffuse
		ifTrue: [self drawWindowDiffuseDropShadowFor: aSystemWindow on: aCanvas]
		ifFalse: [self drawWindowPlainDropShadowFor: aSystemWindow on: aCanvas]
]

{ #category : #'border-styles' }
UITheme >> drawWindowDiffuseDropShadowFor: aSystemWindow on: aCanvas [
	"Draw the diffuse drop shadow for the given window."
	
	|or b r o gc|
	or := self windowActiveDropShadowOffsetRectangleFor: aSystemWindow.
	o := or bottom.
	(aSystemWindow roundedCorners includesAnyOf: #(2 3))
		ifTrue: [o := o + 2].
	b := aSystemWindow bounds expandBy: or.
	gc := {Color black alpha: 0.6. Color transparent}.
	r := b topLeft extent: o asPoint.
	aCanvas
		fillRectangle: r
		fillStyle: ((GradientFillStyle colors: gc)
					origin: r bottomRight;
					direction: o@0;
					radial: true).
	r := b topLeft + (o@0) extent: (b width - o - o @ o).
	aCanvas
		fillRectangle: r
		fillStyle: ((GradientFillStyle colors: gc)
					origin: r bottomLeft;
					direction: 0@o negated).
	r := b topRight - (o@0) extent: o asPoint.
	aCanvas
		fillRectangle: r
		fillStyle: ((GradientFillStyle colors: gc)
					origin: r bottomLeft;
					direction: o@0;
					radial: true).
	r := b topRight + (o negated@o) extent: (o @ (b height - o - o)).
	aCanvas
		fillRectangle: r
		fillStyle: ((GradientFillStyle colors: gc)
					origin: r topLeft;
					direction: o@0).
	r := b bottomRight - o asPoint extent: o asPoint.
	aCanvas
		fillRectangle: r
		fillStyle: ((GradientFillStyle colors: gc)
					origin: r topLeft;
					direction: o@0;
					radial: true).
	r := b bottomLeft + (o@o negated) extent: (b width - o - o @ o).
	aCanvas
		fillRectangle: r
		fillStyle: ((GradientFillStyle colors: gc)
					origin: r topLeft;
					direction: 0@o).
	r := b bottomLeft - (0@o) extent: o asPoint.
	aCanvas
		fillRectangle: r
		fillStyle: ((GradientFillStyle colors: gc)
					origin: r topRight;
					direction: o@0;
					radial: true).
	r := b topLeft + (0@o) extent: (o @ (b height - o - o)).
	aCanvas
		fillRectangle: r
		fillStyle: ((GradientFillStyle colors: gc)
					origin: r topRight;
					direction: o negated@0)

]

{ #category : #'border-styles' }
UITheme >> drawWindowInactiveDropShadowFor: aSystemWindow on: aCanvas [
	"Draw the inactive drop shadow for the given window."
	
	self drawWindowPlainDropShadowFor: aSystemWindow on: aCanvas
]

{ #category : #'border-styles' }
UITheme >> drawWindowPlainDropShadowFor: aSystemWindow on: aCanvas [
	"Draw the plain drop shadow for the given window."
	
	|blOffset brOffset trOffset|
	(aSystemWindow owner notNil and: [aSystemWindow owner isHandMorph])
		ifTrue: [^self]. "skip if being dragged"
	blOffset := (aSystemWindow wantsRoundedCorners and: [aSystemWindow roundedCorners includes: 2])	
		ifTrue: [7] ifFalse: [1].
	brOffset := (aSystemWindow wantsRoundedCorners and: [aSystemWindow roundedCorners includes: 3])	
		ifTrue: [7] ifFalse: [1].
	trOffset := (aSystemWindow wantsRoundedCorners and: [aSystemWindow roundedCorners includes: 4])	
		ifTrue: [7] ifFalse: [1].
	aCanvas
		fillRectangle: (aSystemWindow bounds bottomLeft + (blOffset @ 0)
						corner: aSystemWindow bounds bottomRight - (brOffset @ -1))
		fillStyle: aSystemWindow shadowColor;
		fillRectangle: (aSystemWindow bounds topRight + (0 @ trOffset)
						corner: aSystemWindow bounds bottomRight + (1 @ brOffset negated))
		fillStyle: aSystemWindow shadowColor.
	aCanvas
		clipBy: (aSystemWindow bounds bottomRight - brOffset
			corner: aSystemWindow bounds bottomRight + (1@1))
			during: [:c | ((RoundedBorderStyle new
							baseColor: aSystemWindow shadowColor;
							width: 1) cornerRadius: brOffset - 1)
							frameRectangle: (aSystemWindow bounds translateBy: 1)
							on: c]
]

{ #category : #'label-styles' }
UITheme >> dropListButtonLabelFor: aDropList [
	"Answer the label for the button of the given drop list."

	^AlphaImageMorph new
		image: (ScrollBarMorph
			arrowOfDirection: #bottom
			size: aDropList buttonWidth - 3
			color: aDropList paneColor darker);
		enabled: aDropList enabled
]

{ #category : #'border-styles-buttons' }
UITheme >> dropListControlButtonWidth [
	"Answer the width of a drop list control button for this theme."
	
	^ 18
]

{ #category : #'border-styles' }
UITheme >> dropListDisabledBorderStyleFor: aDropList [
	"Return the disabled borderStyle for the given drop list."

	^self dropListNormalBorderStyleFor: aDropList
]

{ #category : #'fill-styles' }
UITheme >> dropListDisabledFillStyleFor: aDropList [
	"Return the disabled fillStyle for the given drop list."
	
	^ self textEditorDisabledFillStyleFor: aDropList
]

{ #category : #'fill-styles-buttons' }
UITheme >> dropListFocusBoundsFor: aDropList [
	"Answer the bounds for drawing the focus indication for the
	given drop list."

	^aDropList bounds
]

{ #category : #defaults }
UITheme >> dropListFocusIndicatorCornerRadiusFor: aDropList [
	"Answer the default corner radius preferred for the focus indicator
	for the drop list for themes that support this."

	^aDropList wantsRoundedCorners
		ifTrue: [7]
		ifFalse: [2]
]

{ #category : #defaults }
UITheme >> dropListFont [
	"Answer the drop list font to use."

	^self textFont
]

{ #category : #defaults }
UITheme >> dropListInsetFor: aDropList [
	"Answer the inset to use for drop-list layout."
	
	^ Margin left: 6 top: 0 right: 0 bottom: 0
	
]

{ #category : #'border-styles' }
UITheme >> dropListNormalBorderStyleFor: aDropList [
	"Return the normal borderStyle for the given drop list"

	^ self buttonNormalBorderStyleFor: aDropList
]

{ #category : #'fill-styles' }
UITheme >> dropListNormalFillStyleFor: aDropList [
	"Return the normal fillStyle for the given drop list."
	
	^ SolidFillStyle color: Color white
]

{ #category : #'border-styles' }
UITheme >> dropListNormalListBorderStyleFor: aDropList [
	"Return the normal borderStyle for the list of the given given drop list"

	^BorderStyle inset
		width: 1;
		baseColor: aDropList paneColor
]

{ #category : #'fill-styles' }
UITheme >> dropListNormalListFillStyleFor: aDropList [
	"Return the normal fillStyle for the list of the given drop list."
	
	^Color white
]

{ #category : #defaults }
UITheme >> editableDropListMargins [
	"Answer the text margins for an editable drop list for this theme."
	^ Margin left: 0 top: 3 right: 2 bottom: 1
	
]

{ #category : #'accessing - colors' }
UITheme >> enabledColor [

	^ Color black
]

{ #category : #services }
UITheme >> enterOrRequestIn: aThemedMorph title: title labels: labels values: values lines: lines [
	"Answer the result of a popup choice with the given title, labels, values and lines."

	| dialog choice |
	dialog := (PopupChoiceOrRequestDialogWindow newWithTheme: aThemedMorph theme)
		title: (title isEmpty ifTrue: ['Choose' translated] ifFalse: [title asString]);
		labels: labels;
		lines: (lines ifNil: [#()]);
		model: values.
	choice := dialog openModal choice.
	dialog cancelled ifTrue: [ ^nil ].
	^ choice
		ifNotNil: [ choice ]
		ifNil: [ dialog filterValue ]
]

{ #category : #'basic-colors' }
UITheme >> errorPopperBackgroundColor [
	^ Color paleRed
]

{ #category : #'border-styles-buttons' }
UITheme >> expanderTitleControlButtonWidth [
	"Answer the width of an expander title control button for this theme."
	
	^20
]

{ #category : #defaults }
UITheme >> expanderTitleInsetFor: aDropList [
	"Answer the inset to use for expander title layout."

	^0
]

{ #category : #'fill-styles' }
UITheme >> expanderTitleNormalFillStyleFor: anExpanderTitle [
	"Return the normal expander title fillStyle for the given expander title."
	
	^ self buttonNormalFillStyleFor: anExpanderTitle
]

{ #category : #'fill-styles-buttons' }
UITheme >> fadeCheckboxWhenDisabled [
	"Answer whether a checkbox should fade its appearance when disabled.
	If false, assumed that is covered by the relevant disabled fill styles."

	^true
]

{ #category : #accessing }
UITheme >> fadedBackgroundWindows [
	^ self settings fadedBackgroundWindows
]

{ #category : #accessing }
UITheme >> flatMenu [
	^ self settings flatMenu
]

{ #category : #accessing }
UITheme >> focusIndicator [
	"Answer the value of focusIndicator"

	^ focusIndicator
]

{ #category : #accessing }
UITheme >> focusIndicator: anObject [
	"Set the value of focusIndicator"

	focusIndicator := anObject
]

{ #category : #defaults }
UITheme >> focusIndicatorCornerRadiusFor: aMorph [
	"Answer the default corner radius preferred for the focus indicator
	for the morph for themes that support this."

	^aMorph wantsRoundedCorners
		ifTrue: [6]
		ifFalse: [2]
]

{ #category : #'morph creation' }
UITheme >> focusIndicatorMorphFor: aMorph [
	"Answer a (cached) focus indicator for the given morph."

	(self focusIndicator isNil or: [
			self focusIndicator isMorph
				ifTrue: [self focusIndicator ~~ aMorph]
				ifFalse: [self focusIndicator key ~~ aMorph]])
		ifTrue: [self focusIndicator: aMorph ->(self newFocusIndicatorMorphFor: aMorph)].
	^self focusIndicator value 
		privateBounds: aMorph focusBounds
]

{ #category : #accessing }
UITheme >> forms [
	"Answer the value of forms"

	^ forms
]

{ #category : #accessing }
UITheme >> forms: anObject [
	"Set the value of forms"

	forms := anObject
]

{ #category : #'accessing - colors' }
UITheme >> ghostTextColor [

	^ Color lightGray
]

{ #category : #'border-styles' }
UITheme >> groupLabelBorderStyleFor: aGroupPanel [
	"Answer the normal border style for a group label."

	^BorderStyle simple
		width: 0;
		baseColor: Color transparent
]

{ #category : #'border-styles' }
UITheme >> groupPanelBorderStyleFor: aGroupPanel [
	"Answer the normal border style for a group panel."

	^ SimpleBorderStyle new
		width: 1;
		baseColor: ((self baseColorFor: aGroupPanel))
]

{ #category : #'border-styles' }
UITheme >> handlesWindowDropShadowInHandFor: aSystemWindow [
	"Answer whether the receiver will handle drop shadow drawing
	for a window when picked up in the hand. We will when diffuse."

	^self windowActiveDropShadowStyle == #diffuse and: [
		aSystemWindow isActive]
]

{ #category : #'icons-utilities' }
UITheme >> icons [
	^ Smalltalk ui icons
]

{ #category : #initialization }
UITheme >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		initializeForms;
		settings: self defaultSettings.
	self windowActiveDropShadowStyle: #diffuse
]

{ #category : #initialization }
UITheme >> initializeForms [
	"Initialize the receiver's image forms."

	self forms: Dictionary new.
	self forms
		at: #checkboxMarker put: self newCheckboxMarkerForm;
		at: #radioButtonMarker put: self newRadioButtonMarkerForm;
		at: #treeExpanded put: self newTreeExpandedForm;
		at: #treeUnexpanded put: self newTreeUnexpandedForm;
		at: #windowClose put: self newWindowCloseForm;
		at: #windowMinimize put: self newWindowMinimizeForm;
		at: #windowMaximize put: self newWindowMaximizeForm;
		at: #windowMenu put: self newWindowMenuForm;
		at: #windowCloseOver put: self newWindowCloseOverForm;
		at: #windowMinimizeOver put: self newWindowMinimizeOverForm;
		at: #windowMaximizeOver put: self newWindowMaximizeOverForm;
		at: #sbHThumbLeft put: self newScrollbarThumbLeftForm;
		at: #sbHThumbMiddle put: self newScrollbarThumbHorizontalMiddleForm;
		at: #sbHThumbRight put: self newScrollbarThumbRightForm;
		at: #sbVThumbTop put: self newScrollbarThumbTopForm;
		at: #sbVThumbMiddle put: self newScrollbarThumbVerticalMiddleForm;
		at: #sbVThumbBottom put: self newScrollbarThumbBottomForm;
		at: #buttonTopLeft put: self newButtonTopLeftForm;
		at: #buttonTopMiddle put: self newButtonTopMiddleForm;
		at: #buttonTopRight put: self newButtonTopRightForm;
		at: #buttonMiddleLeft put: self newButtonMiddleLeftForm;
		at: #buttonMiddleRight put: self newButtonMiddleRightForm;
		at: #buttonBottomLeft put: self newButtonBottomLeftForm;
		at: #buttonBottomMiddle put: self newButtonBottomMiddleForm;
		at: #buttonBottomRight put: self newButtonBottomRightForm;
		at: #buttonSquareTopLeft put: self newButtonSquareTopLeftForm;
		at: #buttonSquareTopRight put: self newButtonSquareTopRightForm;
		at: #buttonSquareBottomLeft put: self newButtonSquareBottomLeftForm;
		at: #buttonSquareBottomRight put: self newButtonSquareBottomRightForm;
		at: #buttonSelectedTopLeft put: self newButtonSelectedTopLeftForm;
		at: #buttonSelectedTopMiddle put: self newButtonSelectedTopMiddleForm;
		at: #buttonSelectedTopRight put: self newButtonSelectedTopRightForm;
		at: #buttonSelectedMiddleLeft put: self newButtonSelectedMiddleLeftForm;
		at: #buttonSelectedMiddleRight put: self newButtonSelectedMiddleRightForm;
		at: #buttonSelectedBottomLeft put: self newButtonSelectedBottomLeftForm;
		at: #buttonSelectedBottomMiddle put: self newButtonSelectedBottomMiddleForm;
		at: #buttonSelectedBottomRight put: self newButtonSelectedBottomRightForm;
		at: #buttonSquareSelectedTopLeft put: self newButtonSquareSelectedTopLeftForm;
		at: #buttonSquareSelectedTopRight put: self newButtonSquareSelectedTopRightForm;
		at: #buttonSquareSelectedBottomLeft put: self newButtonSquareSelectedBottomLeftForm;
		at: #buttonSquareSelectedBottomRight put: self newButtonSquareSelectedBottomRightForm;
		at: #radioButton put: self newRadioButtonForm;
		at: #radioButtonSelected put: self newRadioButtonSelectedForm;
		at: #checkbox put: self newCheckboxForm;
		at: #checkboxSelected put: self newCheckboxSelectedForm;
		at: #windowClosePassive put: self newWindowInactiveControlForm;
		at: #windowMinimizePassive put: self newWindowInactiveControlForm;
		at: #windowMaximizePassive put: self newWindowInactiveControlForm;
		at: #windowMenuPassive put: self newWindowMenuPassiveForm;
		at: #windowMenuOver put: self newWindowMenuOverForm

]

{ #category : #'label-styles' }
UITheme >> labelDisabledColorFor: aLabel [
	"Answer the color to use for a label when disabled."

	^aLabel owner
		ifNil: [aLabel paneColor muchDarker]
		ifNotNil: [aLabel owner color isTransparent
					ifTrue: [aLabel owner paneColor muchDarker]
					ifFalse: [aLabel owner color muchDarker]].
			
]

{ #category : #defaults }
UITheme >> labelFont [
	"Answer the label font to use."

	^self textFont
]

{ #category : #accessing }
UITheme >> lessConspicuousColorFrom: aColor [

	^	aColor alphaMixed: 0.5 with: Color white
]

{ #category : #'accessing - colors' }
UITheme >> lightBackgroundColor [ 
	^ Color veryLightGray muchLighter
]

{ #category : #'accessing - colors' }
UITheme >> lightBaseColor [

	^ self class lightBaseColor
]

{ #category : #private }
UITheme >> lightColorFor: aButton [
	^ self class lightBaseColor
]

{ #category : #private }
UITheme >> lightSelectionColorFor: aMorph [
	^ self class lightSelectionColor
]

{ #category : #'accessing - colors' }
UITheme >> lineNumberColor [ 
	^ Color gray muchDarker
]

{ #category : #'accessing - colors' }
UITheme >> listBackgroundColor [
	^ self backgroundColor
]

{ #category : #'border-styles' }
UITheme >> listDisabledBorderStyleFor: aList [
	"Return the disabled borderStyle for the given list."

	^self listNormalBorderStyleFor: aList
]

{ #category : #'fill-styles' }
UITheme >> listDisabledFillStyleFor: aList [
	"Return the disabled fillStyle for the given list."
	
	^ self textEditorDisabledFillStyleFor: aList
]

{ #category : #'border-styles' }
UITheme >> listFocusBoundsFor: aListMorph [
	"Answer the bounds for drawing the focus indication."

	^aListMorph bounds
]

{ #category : #defaults }
UITheme >> listFont [
	"Answer the list font to use."

	^StandardFonts listFont
]

{ #category : #'border-styles' }
UITheme >> listNormalBorderStyleFor: aList [
	"Return the normal borderStyle for the given list"

	^BorderStyle simple
		width: 1;
		baseColor: aList paneColor
]

{ #category : #'fill-styles' }
UITheme >> listNormalFillStyleFor: aList [
	"Return the normal fillStyle for the given list."
	
	^Color white
]

{ #category : #'accessing - colors' }
UITheme >> listTextColor [
	"Answer the list text color to use."

	^Color black
]

{ #category : #services }
UITheme >> longMessageIn: aThemedMorph text: aStringOrText title: aString [
	"Answer the result of a (potentially long) message dialog (true) with the given label and title."

	self messageSound play.
	^((LongMessageDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: aStringOrText) openModal cancelled not
]

{ #category : #defaults }
UITheme >> menuBarFont [
	"Answer the menu bar font to use."

	^self textFont
]

{ #category : #'accessing - colors' }
UITheme >> menuBorderColor [
	^  self settings menuBorderColor
]

{ #category : #accessing }
UITheme >> menuBorderWidth [ 
	^  self settings menuBorderWidth * self displayScaleFactor
]

{ #category : #'label-styles' }
UITheme >> menuCloseForm [
	"Answer the form to use for the close button of a menu."

	^self windowCloseForm
]

{ #category : #'accessing - colors' }
UITheme >> menuColor [
	"Answer the menu color to use."

	^self settings menuColor
]

{ #category : #'fill-styles' }
UITheme >> menuColorFor: aThemedMorph [

	"Answer the menu color to use."

	| w |

	^ self menuColor
		ifNil: [ aThemedMorph ifNil: [ ^ self defaultMenuColor ].
			w := aThemedMorph isSystemWindow
				ifTrue: [ aThemedMorph ]
				ifFalse: [ aThemedMorph ownerThatIsA: SystemWindow ].
			w
				ifNil: [ self defaultMenuColor ]
				ifNotNil: [ ( w valueOfProperty: #paneColor ) ifNil: [ self defaultMenuColor ] ]
			]
]

{ #category : #'fill-styles' }
UITheme >> menuFillStyleFor: aMenu [
	"Return the fillStyle for the given menu."
	
	| bc fill |
	bc := aMenu valueOfProperty: #basicColor ifAbsent: [self settings derivedMenuColor].
	fill := GradientFillStyle ramp: {0.0 -> (bc alphaMixed: 0.2 with: Color white). 1.0 -> bc}.
	fill
		radial: false;
		origin: aMenu topLeft;
		direction: 0 @ aMenu height.
	^ fill.
]

{ #category : #defaults }
UITheme >> menuFont [
	"Answer the menu font to use."

	^StandardFonts menuFont
]

{ #category : #defaults }
UITheme >> menuItemDisabledTextColorFor: aMenuItem [
	"Answer the color to use for disabled menu item text."

	^((aMenuItem color luminance - aMenuItem owner color luminance) abs < 0.3)
		ifTrue: [aMenuItem owner color contrastingBlackAndWhiteColor muchDarker]
		ifFalse: [aMenuItem owner color muchDarker]
]

{ #category : #'border-styles-buttons' }
UITheme >> menuItemInDockingBarSelectedBorderStyleFor: aMenuItem [
	"Return the selected menu item borderStyle when in a docking bar for the given menu item."

	^self menuItemSelectedBorderStyleFor: aMenuItem
]

{ #category : #'fill-styles-buttons' }
UITheme >> menuItemInDockingBarSelectedFillStyleFor: aMenuItem [
	"Answer the selected fill style to use for the given menu item that is in a docking bar."
	^ self buttonSelectedFillStyleFor: aMenuItem
]

{ #category : #defaults }
UITheme >> menuItemNormalTextColorFor: aMenuItem [
	"Answer the color to use for normal menu item text."

	^((aMenuItem color luminance - aMenuItem owner paneColor luminance) abs < 0.3)
		ifTrue: [aMenuItem owner paneColor contrastingBlackAndWhiteColor]
		ifFalse: [aMenuItem color]
]

{ #category : #'border-styles-buttons' }
UITheme >> menuItemSelectedBorderStyleFor: aMenuItem [
	"Return the selected menu item borderStyle for the given menu item."

	^BorderStyle simple
		width: 0
]

{ #category : #'fill-styles-buttons' }
UITheme >> menuItemSelectedFillStyleFor: aMenuItem [

	"Answer the selected fill style to use for the given menu item."

	| fill baseColor preferenced |

	Display depth <= 2
		ifTrue: [ ^ Color gray ].
	preferenced := self menuSelectionColor.
	baseColor := preferenced ifNil: [ aMenuItem owner color negated ] ifNotNil: [ preferenced ].
	self preferGradientFill
		ifFalse: [ ^ baseColor ].
	fill := GradientFillStyle
		ramp:
			{( 0.0 -> baseColor twiceLighter ).
			( 1 -> baseColor twiceDarker )}.
	fill
		origin: aMenuItem topLeft;
		direction: 0 @ aMenuItem height.
	^ fill
]

{ #category : #defaults }
UITheme >> menuItemSelectedTextColorFor: aMenuItem [
	"Answer the color to use for selected menu item text."

	^ self settings menuSelectionTextColor
]

{ #category : #'accessing - colors' }
UITheme >> menuKeyboardFocusColor [
	^ self settings menuKeyboardFocusColor
]

{ #category : #'label-styles' }
UITheme >> menuPinForm [
	"Answer the form to use for the pin button of a menu."

	^ self iconNamed: #menuPinForm
]

{ #category : #'accessing - colors' }
UITheme >> menuSelectionColor [
	^ self settings menuSelectionColor
]

{ #category : #'accessing - colors' }
UITheme >> menuShadowColor [
	^ self settings menuShadowColor
]

{ #category : #'accessing - colors' }
UITheme >> menuTitleColor [
	"Answer the menu title color to use."
	^self settings menuTitleColor
]

{ #category : #'fill-styles' }
UITheme >> menuTitleColorFor: aThemedMorph [

	"Answer the menu titlecolor to use."

	| w |

	^ self menuTitleColor
		ifNil: [ aThemedMorph ifNil: [ ^ self defaultMenuTitleColor ].
			w := aThemedMorph isSystemWindow
				ifTrue: [ aThemedMorph ]
				ifFalse: [ aThemedMorph ownerThatIsA: SystemWindow ].
			w
				ifNil: [ self defaultMenuTitleColor ]
				ifNotNil: [ ( w valueOfProperty: #paneColor ) darker ifNil: [ self defaultMenuTitleColor ] ]
			]
]

{ #category : #'fill-styles' }
UITheme >> menuTitleFillStyleFor: aMenuTitle [
	"Return the fillStyle for the given title menu."
	| fill |

	fill := GradientFillStyle ramp: {0.0 -> aMenuTitle color twiceLighter. 1 -> aMenuTitle color twiceDarker}.
	fill
		origin: aMenuTitle topLeft;
		direction: aMenuTitle width @ 0.
	^ fill
]

{ #category : #'border-style-menubar' }
UITheme >> menubarBorderWidthFor: aMenubar [
	^ 0
]

{ #category : #'fill-styles-menubar' }
UITheme >> menubarFillStyleFor: aMenubar [
	^ self taskbarFillStyleFor: aMenubar
]

{ #category : #'fill-styles-menubar' }
UITheme >> menubarItemSelectionFillStyleFor: aMenubarItem [
	^ self menuSelectionColor
]

{ #category : #'fill-styles-menubar' }
UITheme >> menubarItemSelectionTextColorFor: aMenubarItem [
	^ self settings menuSelectionTextColor
]

{ #category : #services }
UITheme >> messageIn: aThemedMorph text: aStringOrText title: aString [
	"Answer the result of a message dialog (true) with the given label and title."

	self messageSound play.
	^((MessageDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: aStringOrText) openModal cancelled not
]

{ #category : #sounds }
UITheme >> messageSound [
	"Answer the message sound."

	^self soundTheme messageSound
]

{ #category : #'border-styles' }
UITheme >> morphTreeColumnBorderStyleFor: aMorph [
	^ self buttonNormalBorderStyleFor: aMorph
]

{ #category : #'fill-styles' }
UITheme >> morphTreeColumnFillStyleFor: aMorph [
	^ self buttonNormalFillStyleFor: aMorph 
]

{ #category : #'fill-styles' }
UITheme >> morphTreeSplitterNormalFillStyleFor: aSplitter [	
	^ self splitterNormalFillStyleFor: aSplitter
]

{ #category : #'fill-styles' }
UITheme >> morphTreeSplitterPressedFillStyleFor: aSplitter [
	"Return the pressed splitter fillStyle for the given splitter."
	
	|aColor|
	aColor := aSplitter paneColor twiceDarker.
	^(GradientFillStyle ramp: {
			0.0->Color white. 0.4-> aColor twiceLighter.
			1.0->aColor darker duller})
		origin: aSplitter topLeft;
		direction: (aSplitter splitsTopAndBottom
			ifTrue: [0 @ aSplitter height]
			ifFalse: [aSplitter width @ 0]);
		radial: false
]

{ #category : #'fill-styles' }
UITheme >> multiFormFillStyleFrom: anArray cornerWidths: widthArray in: aRectangle [
	"Answer a composite fill style from the given forms and central colour
	in the given bounds. Use the widths specified for the portion of the
	corner forms to display."
	
	|tl tm tr ml mr bl bm br c tlw trw blw brw|
	tl := anArray first. tlw:= widthArray first.
	tm := anArray second.
	tr := anArray third. trw := widthArray second.
	ml  := anArray fourth.
	c := anArray fifth.
	mr  := anArray sixth.
	bl := anArray seventh. blw := widthArray third.
	bm := anArray eighth.
	br := anArray ninth. brw := widthArray fourth.
	^CompositeFillStyle fillStyles: {
		(ImageFillStyle form: tl)
			origin: aRectangle topLeft;
			extent: tlw@tl height.
		(AlphaInfiniteForm with: tm)
			origin: aRectangle topLeft + (tlw@0);
			extent: (aRectangle width - trw - tlw)@tm height.
		(ImageFillStyle form: tr)
			origin: aRectangle topRight - (tr width@0);
			extent: trw@tr height;
			offset: (tr width - trw)@0.
		(AlphaInfiniteForm with: ml)
			origin: aRectangle topLeft + (0@tl height);
			extent: ml width@(aRectangle height - tl height - bl height).
		(ColorFillStyle color: c)
			origin: aRectangle topLeft + (tlw@tl height);
			extent: aRectangle extent - (tlw@tl height) - (brw@br height).
		(AlphaInfiniteForm with: mr)
			origin: aRectangle topRight + (trw negated@tr height);
			extent: mr width@(aRectangle height - tr height - br height).
		(ImageFillStyle form: bl)
			origin: aRectangle bottomLeft - (0@bl height);
			extent: blw@bl height.
		(AlphaInfiniteForm with: bm)
			origin: aRectangle bottomLeft - (blw negated@bl height);
			extent: (aRectangle width - blw - brw)@bm height.
		(ImageFillStyle form: br)
			origin: aRectangle bottomRight - br extent;
			extent: brw@br height;
			offset: (br width - brw)@0}
]

{ #category : #'fill-styles' }
UITheme >> multiFormFillStyleFrom: anArray in: aRectangle [
	"Answer a composite fill style from the given forms and central colour
	in the given bounds."
	
	|tl tm tr ml mr bl bm br c|
	tl := anArray first.
	tm := anArray second.
	tr := anArray third.
	ml  := anArray fourth.
	c := anArray fifth.
	mr  := anArray sixth.
	bl := anArray seventh.
	bm := anArray eighth.
	br := anArray ninth.
	^CompositeFillStyle fillStyles: {
		(ImageFillStyle form: tl) origin: aRectangle topLeft.
		(AlphaInfiniteForm with: tm)
			origin: aRectangle topLeft + (tl width@0);
			extent: (aRectangle width - tl width - tr width)@tm height.
		(ImageFillStyle form: tr)
			origin: aRectangle topRight - (tr width@0).
		(AlphaInfiniteForm with: ml)
			origin: aRectangle topLeft + (0@tl height);
			extent: ml width@(aRectangle height - tl height - bl height).
		(ColorFillStyle color: c)
			origin: aRectangle topLeft + tl extent;
			extent: aRectangle extent - tl extent - br extent.
		(AlphaInfiniteForm with: mr)
			origin: aRectangle topRight + (tr width negated@tr height);
			extent: mr width@(aRectangle height - tr height - br height).
		(ImageFillStyle form: bl) origin: aRectangle bottomLeft - (0@bl height).
		(AlphaInfiniteForm with: bm)
			origin: aRectangle bottomLeft - (bl width negated@bl height);
			extent: (aRectangle width - bl width - br width)@bm height.
		(ImageFillStyle form: br)
			origin: aRectangle bottomRight - br extent}
]

{ #category : #'fill-styles' }
UITheme >> multiFormTopFillStyleFrom: anArray in: aRectangle [
	"Answer a composite fill style from the given forms and central colour
	in the given bounds. Only top and middle sections are considered."
	
	|tl tm tr ml mr c|
	tl := anArray first.
	tm := anArray second.
	tr := anArray third.
	ml  := anArray fourth.
	c := anArray fifth.
	mr  := anArray sixth.
	^CompositeFillStyle fillStyles: {
		(ImageFillStyle form: tl) origin: aRectangle topLeft.
		(AlphaInfiniteForm with: tm)
			origin: aRectangle topLeft + (tl width@0);
			extent: (aRectangle width - tl width - tr width)@tm height.
		(ImageFillStyle form: tr)
			origin: aRectangle topRight - (tr width@0).
		(AlphaInfiniteForm with: ml)
			origin: aRectangle topLeft + (0@tr height);
			extent: ml width@(aRectangle height - tl height).
		(ColorFillStyle color: c)
			origin: aRectangle topLeft + tl extent;
			extent: aRectangle extent - tl extent - (mr width @0).
		(AlphaInfiniteForm with: mr)
			origin: aRectangle topRight + (tr width negated@tr height);
			extent: mr width@(aRectangle height - tr height)}
]

{ #category : #'morph creation' }
UITheme >> newAlphaImageIn: aThemedMorph image: aForm help: helpText [
	"Answer an alpha image morph."
	
	|answer|
	answer := AlphaImageMorph new
		hResizing: #rigid;
		vResizing: #rigid;
		setBalloonText: helpText.
	aForm ifNotNil: [answer image: aForm].
	^answer
]

{ #category : #'morph creation' }
UITheme >> newAlphaSelectorIn: aThemedMorph for: aModel getAlpha: getSel setAlpha: setSel help: helpText [
	"Answer an alpha selector ."

	^(AColorSelectorMorph
			on: aModel
			getValue: getSel
			setValue: setSel)
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newAutoAcceptTextEntryIn: aThemedMorph for: aModel get: getSel set: setSel class: aClass getEnabled: enabledSel font: aFont help: helpText [ 
	"Answer a text entry for the given model.
	Object conversion will be automatic based on the class of
	object returned after performing the get selector, aClass
	is provided in case of initial nil returns."
	^ self
		newAutoAcceptTextEntryIn: aThemedMorph
		for: aModel
		get: getSel
		set: setSel
		class: aClass 
		getEnabled: enabledSel
		font: aFont
		help: helpText
		entryCompletion: nil
]

{ #category : #'morph creation' }
UITheme >> newAutoAcceptTextEntryIn: aThemedMorph for: aModel  get: getSel set: setSel class: aClass getEnabled: enabledSel font: aFont help: helpText entryCompletion: anEntryCompletion [
	"Answer a text entry for the given model.
	Object conversion will be automatic based on the class of
	object returned after performing the get selector, aClass
	is provided in case of initial nil returns."

	|pt|
	pt := RubPluggableTextFieldMorph new
		autoAccept: true;
		alwaysAccept: true;
		convertTo: aClass;
		on: aModel
		text: getSel
		accept: setSel
		readSelection: nil
		menu: nil;
		acceptOnCR: true;
		getEnabledSelector: enabledSel;
		font: aFont;
		cornerStyle: (self textEntryCornerStyleIn: aThemedMorph);
		hResizing: #spaceFill;
		vResizing: #rigid;
		borderStyle: (BorderStyle inset width: 1);
		setBalloonText: helpText;
		entryCompletion: anEntryCompletion.
	^pt

]

{ #category : #'morph creation' }
UITheme >> newAutoAcceptTextEntryIn: aThemedMorph for: aModel get: getSel set: setSel class: aClass getEnabled: enabledSel help: helpText [ 
	"Answer a text entry for the given model.
	Object conversion will be automatic based on the class of
	object returned after performing the get selector, aClass
	is provided in case of initial nil returns."
	^ self
		newAutoAcceptTextEntryIn: aThemedMorph
		for: aModel
		get: getSel
		set: setSel
		class: aClass
		getEnabled: enabledSel
		help: helpText
		entryCompletion: nil 
]

{ #category : #'morph creation' }
UITheme >> newAutoAcceptTextEntryIn: aThemedMorph for: aModel  get: getSel set: setSel class: aClass getEnabled: enabledSel help: helpText entryCompletion: anEntryCompletion [
	"Answer a text entry for the given model.
	Object conversion will be automatic based on the class of
	object returned after performing the get selector, aClass
	is provided in case of initial nil returns."

	^self
		newAutoAcceptTextEntryIn: aThemedMorph
		for: aModel
		get: getSel
		set: setSel
		class: aClass
		getEnabled: enabledSel
		font: self textFont
		help: helpText
		entryCompletion: anEntryCompletion
]

{ #category : #'morph creation' }
UITheme >> newBalloonHelpIn: aThemedMorph contents: aTextStringOrMorph for: aMorph corner: cornerSymbol [
	"Answer a new balloon help morph with the given text
	and positioning for aMorph."
	
	^SimpleBalloonMorph
		string: aTextStringOrMorph
		for: aMorph
		corner: cornerSymbol
]

{ #category : #'morph creation' }
UITheme >> newBracketSliderIn: aThemedMorph for: aModel getValue: getSel setValue: setSel min: minValue max: maxValue quantum: quantum getEnabled: enabledSel help: helpText [
	"Answer a bracket slider."

	^(BracketSliderMorph
			on: aModel
			getValue: getSel
			setValue: setSel
			min: minValue
			max: maxValue
			quantum: quantum)
		getEnabledSelector: enabledSel;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		setBalloonText: helpText
]

{ #category : #initialization }
UITheme >> newButtonBottomLeftForm [
	"Answer the form for the bottom left of a button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 3716317826 4291743438 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 2842718320 4290953922 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 1784635231 4255886251 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 978802519 4170157967 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 374427985 3815599469 4291611852 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 41975936 1699499084 4168973693 4293190884 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 0 154745145 2891010385 4271873951 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 0 16777216 675299392 3764280926 4290098613 4293980400 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 0 0 33554432 1295332661 3595850836 4253583496 4292993505 4294309365 4294309365 4294309365 4294309365 4294309365 0 0 0 33554432 640626479 2688433726 4083574374 4289835441 4293125091 4294506744 4294572537 4294572537 0 0 0 0 16777216 138428480 1546267178 3510780482 3981989976 4184895600 4270360712 4288651167 0 0 0 0 0 0 33554432 338044454 941629472 1511989023 2268016431 3124575549)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonBottomMiddleForm [
	"Answer the form for the bottom middle of a button."

	^(Form
	extent: 1@12
	depth: 32
	fromArray: #( 4292072403 4292401368 4292664540 4292927712 4293190884 4293454056 4293717228 4294046193 4294309365 4294572537 4289506476 3443342653)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonBottomRightForm [
	"Answer the form for the bottom right of a button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4291282887 3548216701 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4290230199 2607574124 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4238187933 1616731485 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4119365768 962156889 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4290756543 3697895785 374427985 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4292730333 4118378873 1666010445 41975936 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4254175633 2790215503 154745145 0 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 4293848814 4289177511 3663288665 675299392 16777216 0 4294309365 4294309365 4294309365 4294309365 4294309365 4292467161 4253188738 3545453395 1295332661 33554432 0 0 4294572537 4294572537 4294440951 4292861919 4289309097 4066797158 2655010880 640626479 33554432 0 0 0 4288519581 4270294919 4168052591 3965081174 3477291843 1546267178 138428480 16777216 0 0 0 0 3107864126 2268016431 1511989023 941629472 338044454 33554432 0 0 0 0 0 0)
	offset: 0@0)
]

{ #category : #'morph creation' }
UITheme >> newButtonIn: aThemedMorph for: aModel getState: stateSel action: actionSel arguments: args getEnabled: enabledSel getLabel: labelSel help: helpText [
	"Answer a new button."

	|b|
	b := PluggableButtonMorph
			on: aModel
			getState: stateSel
			action: actionSel
			label: labelSel.
	b
		theme: self;
		label: ' ' font: self buttonFont;
		update: labelSel;
		arguments: (args ifNil: [{b}]);
		getEnabledSelector: enabledSel;
		cornerStyle: (self buttonCornerStyleIn: aThemedMorph);
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		setBalloonText: helpText;
		extent: b minExtent;
		removeProperty: #theme.
	^b
]

{ #category : #'morph creation' }
UITheme >> newButtonIn: aThemedMorph for: aModel getState: stateSel action: actionSel arguments: args getEnabled: enabledSel label: label help: helpText [
	"Answer a new button."

	| button |
	^ (button := PluggableButtonMorph on: aModel getState: stateSel action: actionSel)
		theme: self;
		arguments: (args ifNil: [ {button} ]);
		cornerStyle: (self buttonCornerStyleIn: aThemedMorph);
		label: label font: self buttonFont;
		getEnabledSelector: enabledSel;
		setBalloonText: helpText;
		extent: button minExtent;
		hResizing: #rigid;
		vResizing: #rigid;
		removeProperty: #theme;
		yourself
]

{ #category : #'morph creation' }
UITheme >> newButtonLabelIn: aThemedMorph for: aModel label: aString getEnabled: enabledSel [
	"Answer a new button text label."

	^(self buttonLabelForText: aString)
		model: aModel;
		getEnabledSelector: enabledSel
]

{ #category : #initialization }
UITheme >> newButtonMiddleLeftForm [
	"Answer the form for the middle left of a button."

	^(Form
	extent: 12@1
	depth: 32
	fromArray: #( 3968305031 4292138196 4292138196 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonMiddleRightForm [
	"Answer the form for the middle right of a button."

	^(Form
	extent: 12@1
	depth: 32
	fromArray: #( 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 3934750599)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSelectedBottomLeftForm [
	"Answer the form for the bottom left of a selected button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 3713688967 4284841382 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 2840812155 4284841122 4285170861 4285170861 4285170861 4285170861 4285170861 4285170861 4285170861 4285170861 4285170861 4285170861 1783452780 4251022487 4285499826 4285499826 4285499826 4285499826 4285499826 4285499826 4285499826 4285499826 4285499826 4285499826 977750885 4166608772 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 373704285 3813365101 4285499564 4286092476 4286092476 4286092476 4286092476 4286092476 4286092476 4286092476 4286092476 4286092476 33554560 1698382676 4166082166 4286224317 4286356160 4286356160 4286356160 4286356160 4286356160 4286356160 4286356160 4286356160 0 154745173 2889761365 4267668108 4286685125 4286685125 4286685125 4286685125 4286685125 4286685125 4286685125 4286685125 0 16777216 674444102 3762375258 4285103772 4286948554 4286948554 4286948554 4286948554 4286948554 4286948554 4286948554 0 0 33554432 1294675516 3594273360 4250231929 4286619071 4287277775 4287277775 4287277775 4287277775 4287277775 0 0 0 33554432 640165935 2687513663 4081274461 4285169818 4286882243 4287606740 4287606740 4287606740 0 0 0 0 16777216 134234176 1545872426 3509597758 3980150095 4182267235 4267009399 4284642698 0 0 0 0 0 0 33554432 338044454 941629472 1511791647 2267424813 3123524408)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSelectedBottomMiddleForm [
	"Answer the form for the bottom middle of a selected button."

	^(Form
	extent: 1@12
	depth: 32
	fromArray: #( 4284907432 4285171117 4285500082 4285763767 4286092732 4286356417 4286685381 4286948810 4287278031 4287606996 4285038229 3442226232)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSelectedBottomRightForm [
	"Answer the form for the bottom right of a selected button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284775331 3545850757 4285170861 4285170861 4285170861 4285170861 4285170861 4285170861 4285170861 4285170861 4285170861 4285170861 4284643228 2605931385 4285499826 4285499826 4285499826 4285499826 4285499826 4285499826 4285499826 4285499826 4285499826 4285499826 4233915791 1615745901 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4116079488 961039463 4286092476 4286092476 4286092476 4286092476 4286092476 4286092476 4286092476 4286092476 4286092476 4285169827 3695858538 373704285 4286356160 4286356160 4286356160 4286356160 4286356160 4286356160 4286356160 4286356160 4286092472 4115618674 1664828245 33554560 4286685125 4286685125 4286685125 4286685125 4286685125 4286685125 4286685125 4286685125 4250495363 2789098069 154745173 0 4286948554 4286948554 4286948554 4286948554 4286948554 4286948554 4286882504 4284642962 3661580376 674444102 16777216 0 4287277775 4287277775 4287277775 4287277775 4287277775 4286421177 4250034292 3543876175 1294675516 33554432 0 0 4287606740 4287606740 4287540947 4286750399 4284906131 4064496988 2654025280 640165935 33554432 0 0 0 4284445576 4266943863 4165424226 3963307086 3476109119 1545872426 134234176 16777216 0 0 0 0 3106812728 2267424813 1511791647 941629472 338044454 33554432 0 0 0 0 0 0)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSelectedMiddleLeftForm [
	"Answer the form for the middle left of a selected button."

	^(Form
	extent: 12@1
	depth: 32
	fromArray: #( 3965347464 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSelectedMiddleRightForm [
	"Answer the form for the middle right of a selected button."

	^(Form
	extent: 12@1
	depth: 32
	fromArray: #( 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 3931727240)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSelectedTopLeftForm [
	"Answer the form for the top left of a selected button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 0 0 0 0 0 0 33554431 362719975 1268031205 2541850575 3279521477 3765271736 0 0 0 0 0 111848191 2407633100 4049957547 4266548622 4284838039 4287271854 4290099916 0 0 0 16777471 814060743 3581116602 4266877583 4288982209 4292730856 4292994026 4292994026 4292994026 0 0 16777471 1903987394 4099960739 4285430685 4291349978 4292270819 4292270819 4292270819 4292270819 4292270819 0 0 713067455 4083709352 4288259003 4291547356 4291547356 4291547356 4291547356 4291547356 4291547356 4291547356 0 75464703 3580787373 4287535542 4290889943 4290889943 4290889943 4290889943 4290889943 4290889943 4290889943 4290889943 33554431 2389802158 4251744930 4290297809 4290297809 4290297809 4290297809 4290297809 4290297809 4290297809 4290297809 4290297809 258373546 4016337568 4286878386 4289706189 4289706189 4289706189 4289706189 4289706189 4289706189 4289706189 4289706189 4289706189 1097823911 4200558234 4287207349 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 2070376603 4284182168 4286155693 4288654276 4288654276 4288654276 4288654276 4288654276 4288654276 4288654276 4288654276 4288654276 3160435603 4284314525 4284577696 4287668413 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 3780930190 4284578211 4284578211 4285301417 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSelectedTopMiddleForm [
	"Answer the form for the top middle of a selected button."

	^(Form
	extent: 1@12
	depth: 32
	fromArray: #( 3966269361 4291941599 4292994026 4292205027 4291547356 4290889943 4290297809 4289640652 4289114568 4288588740 4288128705 4286353587)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSelectedTopRightForm [
	"Answer the form for the top right of a selected button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 3748625849 3262810310 2441121744 1184342758 295085538 33554431 0 0 0 0 0 0 4290099916 4287271854 4284904087 4266680208 4016534958 2156237519 75464703 0 0 0 0 0 4292994026 4292994026 4292994026 4292730856 4288981953 4250297491 3463873727 646616786 16777471 0 0 0 4292270819 4292270819 4292270819 4292270819 4292270819 4291284185 4285233565 4066800809 1551994565 16777471 0 0 4291547356 4291547356 4291547356 4291547356 4291547356 4291547356 4291547356 4287929784 4016798124 545033153 0 0 4290889943 4290889943 4290889943 4290889943 4290889943 4290889943 4290889943 4290889943 4287009457 3379658160 61516543 0 4290297809 4290297809 4290297809 4290297809 4290297809 4290297809 4290297809 4290297809 4290166480 4234639009 2003992240 33554431 4289706189 4289706189 4289706189 4289706189 4289706189 4289706189 4289706189 4289706189 4289706189 4286286508 3949425826 258373546 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 4286747057 4167135387 896300710 4288654276 4288654276 4288654276 4288654276 4288654276 4288654276 4288654276 4288654276 4288654276 4285760937 4250693017 1785229980 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 4287471035 4284446367 4284314268 2841668498 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587 4285038503 4284578211 4284578211 3663554701)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSquareBottomLeftForm [
	"Answer the form for the bottom left of a square button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 3968305031 4292138196 4292138196 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 3967976066 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 3967778687 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 3967449722 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 3967252343 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 3966923378 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 3966660206 4293783021 4293783021 4293783021 4293783021 4293783021 4293783021 4293783021 4293783021 4293717228 4293717228 4293717228 3966397034 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 3966133862 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 3830929239 4293783021 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 2502963248 4252596601 4289309097 4289506476 4289506476 4289506476 4289506476 4289506476 4289506476 4289506476 4289506476 4289506476 622599196 2352034097 3409854014 3443342653 3443342653 3443342653 3443342653 3443342653 3443342653 3443342653 3443342653 3443342653)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSquareBottomRightForm [
	"Answer the form for the bottom right of a square button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 4292072403 3934750599 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292401368 4292335575 3934421634 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 3934158462 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 3933895290 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 3933632118 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 4293454056 3933368946 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 3933039981 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 4294046193 3932776809 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 3932447844 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4294572537 4293388263 3780400212 4289506476 4289506476 4289506476 4289506476 4289506476 4289506476 4289506476 4289506476 4289506476 4289243304 4235556213 2452565807 3443342653 3443342653 3443342653 3443342653 3443342653 3443342653 3443342653 3443342653 3443342653 3393076798 2352034097 622599196)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSquareSelectedBottomLeftForm [
	"Answer the form for the bottom left of a selected square button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 3965347464 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 3965215874 4285171117 4285171117 4285171117 4285171117 4285171117 4285171117 4285171117 4285171117 4285171117 4285171117 4285171117 3964952703 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 3964821113 4285763767 4285763767 4285763767 4285763767 4285763767 4285763767 4285763767 4285763767 4285763767 4285763767 4285763767 3964623476 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 3964426350 4286421953 4286421953 4286421953 4286421953 4286356417 4286356417 4286356417 4286356417 4286356417 4286356417 4286356417 3964294248 4286685382 4286685382 4286685382 4286685382 4286685382 4286685382 4286685382 4286685382 4286685381 4286685381 4286685381 3964097124 4287014602 4287014602 4287014602 4287014346 4287014346 4287014346 4287014346 4287014346 4287014346 4287014346 4287014346 3963833950 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 3829154896 4287211978 4287607252 4287606996 4287606996 4287606996 4287606996 4287606996 4287606996 4287606996 4287606996 4287606996 2502502958 4249705579 4284972435 4285038229 4285038229 4285038229 4285038229 4285038229 4285038229 4285038229 4285038229 4285038229 622599196 2351311407 3408802615 3442226232 3442226232 3442226232 3442226232 3442226232 3442226232 3442226232 3442226232 3442226232)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSquareSelectedBottomRightForm [
	"Answer the form for the bottom right of a selected square button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 4284907432 3931727240 4285171117 4285171117 4285171117 4285171117 4285171117 4285171117 4285171117 4285171117 4285171117 4285171117 4285170861 3931595651 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 3931464061 4285763767 4285763767 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 4285763511 3931200888 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 3931003251 4286356417 4286356160 4286356160 4286356160 4286356160 4286356160 4286356160 4286356160 4286356160 4286356160 4286356160 3930871661 4286685381 4286685381 4286685381 4286685381 4286685381 4286685381 4286685381 4286685381 4286685381 4286685381 4286685381 3930674280 4286948810 4286948810 4286948810 4286948810 4286948810 4286948810 4286948810 4286948810 4286948810 4286948810 4286948810 3930476899 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 3930345054 4287606996 4287606996 4287606996 4287606996 4287606996 4287606996 4287606996 4287541460 4287541460 4287541460 4286948549 3778691918 4285038229 4285038229 4285038229 4285038485 4285038485 4285038485 4285038485 4285038485 4285038485 4284841105 4232796519 2452040237 3442226232 3442226232 3442226232 3442226232 3442226232 3442226232 3442226232 3442226232 3442226232 3392025400 2351311407 622599196)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSquareSelectedTopLeftForm [
	"Answer the form for the top left of a selected square button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 630892779 3329853638 3949492146 3966269361 3966269361 3966269361 3966269361 3966269361 3966269361 3966269361 3966269361 3966269361 3028455632 4282141565 4285561500 4291744478 4291876062 4291876062 4291876062 4291876062 4291876062 4291876062 4291876062 4291876062 3916792766 4281944439 4289771209 4292928234 4292928234 4292928234 4292928234 4292928234 4292994026 4292994026 4292994026 4292994026 3966992312 4282207868 4289705673 4292139234 4292205027 4292205027 4292205027 4292205027 4292205027 4292205027 4292205027 4292205027 3966860723 4282537089 4289311174 4291481564 4291481564 4291481564 4291481564 4291481564 4291481564 4291547356 4291547356 4291547356 3966598062 4282800518 4288785346 4290889686 4290889686 4290889686 4290889686 4290889686 4290889686 4290889686 4290889686 4290889686 3966334888 4283129739 4288456639 4290232273 4290232273 4290232273 4290232273 4290232273 4290297809 4290297809 4290297809 4290297809 3966268835 4283393168 4288062397 4289640396 4289640652 4289640652 4289640652 4289640652 4289640652 4289640652 4289640652 4289640652 3966071197 4283722133 4287799227 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 3965874072 4283985818 4287405242 4288523204 4288523204 4288588740 4288588740 4288588740 4288588740 4288588740 4288588740 4288588740 3965741971 4284314782 4287208120 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 3965544845 4284578467 4285893551 4286288050 4286288050 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSquareSelectedTopRightForm [
	"Answer the form for the top right of a selected square button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 3966269361 3966269361 3966269361 3966269361 3966269361 3966269105 3966269105 3966269105 3966269105 3949492146 3246098890 547072752 4291941599 4291941599 4291941599 4291941599 4291941599 4291941599 4291941599 4291941599 4291810270 4285298585 4282338943 2927923665 4292994026 4292994026 4292994026 4292994026 4292994026 4292994283 4292994283 4292994283 4292994283 4289442502 4281878647 3883238334 4292205027 4292270819 4292270819 4292270819 4292270819 4292270819 4292270819 4292270819 4292270819 4289442758 4282207868 3933503928 4291547356 4291547356 4291547356 4291547356 4291547356 4291547356 4291612893 4291612893 4291612893 4289048003 4282471297 3933240756 4290889943 4290889943 4290889943 4290889943 4290889943 4290889943 4290889943 4290889943 4290889943 4288653760 4282800518 3933043629 4290297809 4290297809 4290297809 4290297809 4290297809 4290298066 4290298066 4290298066 4290298066 4288325054 4283063947 3932911528 4289640652 4289706189 4289706189 4289706189 4289706189 4289706189 4289706189 4289706189 4289706189 4287930812 4283393168 3932714660 4289114568 4289114568 4289114568 4289114568 4289114568 4289114568 4289180360 4289180360 4289180360 4287602105 4283656596 3932516765 4288588740 4288588740 4288654532 4288654532 4288654532 4288654532 4288654532 4288654532 4288654532 4287339448 4283985817 3932319385 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 4288128705 4288194497 4288194497 4287142327 4284314782 3932187795 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587 4286353587 4285827758 4284578467 3931924878)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSquareTopLeftForm [
	"Answer the form for the top left of a square button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 633520834 3333994680 3954422707 3971199923 3971199923 3971199923 3971199923 3971199923 3971199923 3971199923 3971199923 3971199923 3032004792 4289243304 4290822336 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 3920736689 4289374890 4292730333 4294111986 4294111986 4294111986 4294111986 4294111986 4294111986 4294111986 4294111986 4294111986 3970805165 4289638062 4292796126 4293783021 4293848814 4293848814 4293848814 4293848814 4293848814 4293848814 4293848814 4293848814 3970476200 4289901234 4292664540 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 3970278821 4290164406 4292532954 4293322470 4293322470 4293322470 4293322470 4293322470 4293322470 4293322470 4293322470 4293322470 3970015649 4290493371 4292532954 4293190884 4293190884 4293190884 4293125091 4293125091 4293190884 4293190884 4293190884 4293190884 3969686684 4290756543 4292467161 4292993505 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 3969423512 4291019715 4292467161 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 3969160340 4291282887 4292467161 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 3968831375 4291546059 4292467161 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 3968568203 4291809231 4292203989 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonSquareTopRightForm [
	"Answer the form for the top right of a square button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 3971199923 3971199923 3971199923 3971199923 3971199923 3971199923 3971199923 3971199923 3971199923 3954422707 3250240186 549042617 4293651435 4293651435 4293651435 4293651435 4293651435 4293651435 4293651435 4293651435 4293585642 4290690750 4289243304 2931341496 4294111986 4294111986 4294111986 4294111986 4294111986 4294111986 4294111986 4294111986 4294111986 4292598747 4289374890 3887182257 4293848814 4293848814 4293848814 4293848814 4293848814 4293848814 4293848814 4293848814 4293848814 4292664540 4289638062 3937184940 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4292532954 4289901234 3936987561 4293388263 4293388263 4293388263 4293388263 4293388263 4293388263 4293388263 4293388263 4293388263 4292467161 4290164406 3936658596 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4292401368 4290427578 3936329631 4293059298 4293059298 4293059298 4293059298 4293059298 4292993505 4292993505 4292993505 4292993505 4292335575 4290690750 3936132252 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292401368 4291019715 3935803287 4292796126 4292796126 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292401368 4291282887 3935540115 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292467161 4291546059 3935276943 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4292203989 4291809231 3935013771)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonTopLeftForm [
	"Answer the form for the top left of a button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 0 0 0 0 0 0 33554431 365151171 1270791870 2545662907 3283663032 3770004917 0 0 0 0 0 111848106 2411247800 4054954417 4272729260 4290427578 4291546059 4292796126 0 0 0 33554431 817083315 3585192369 4273058225 4292401368 4293980400 4294111986 4294111986 4294111986 0 0 33554431 1907076011 4105022893 4290953922 4293454056 4293848814 4293848814 4293848814 4293848814 4293848814 0 0 715696296 4088179884 4292269782 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 0 79675327 3584402853 4291940817 4293388263 4293388263 4293388263 4293388263 4293388263 4293388263 4293388263 4293388263 33554431 2392628380 4256938939 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 261724569 4020281504 4292006610 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 1099795853 4205488810 4292269782 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 2072413830 4290361785 4292006610 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 3163196042 4291217094 4291611852 4292664540 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 3784150413 4291809231 4291809231 4292006610 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonTopMiddleForm [
	"Answer the form for the top middle of a button."

	^(Form
	extent: 1@12
	depth: 32
	fromArray: #( 3971199923 4293585642 4294111986 4293848814 4293585642 4293322470 4293190884 4293059298 4292927712 4292796126 4292796126 4292335575)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newButtonTopRightForm [
	"Answer the form for the top right of a button."

	^(Form
	extent: 12@12
	depth: 32
	fromArray: #( 3753227701 3266885816 2445065404 1187103169 298042307 33554431 0 0 0 0 0 0 4292796126 4291546059 4290427578 4272729260 4021334192 2159655353 75464575 0 0 0 0 0 4294111986 4294111986 4294111986 4293980400 4292401368 4256346802 3467817650 649113776 33554431 0 0 0 4293848814 4293848814 4293848814 4293848814 4293848814 4293388263 4290822336 4071534254 1554886061 33554431 0 0 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4292072403 4020873641 548055722 0 0 4293388263 4293388263 4293388263 4293388263 4293388263 4293388263 4293388263 4293388263 4291611852 3382944675 67108863 0 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293125091 4239701172 2006686619 33554431 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4291809231 3953041054 261724569 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292927712 4292072403 4171473827 898206089 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4291875024 4256215216 1787069572 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292796126 4292532954 4291611852 4290822336 2843968387 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4292335575 4291940817 4291809231 4291677645 3666380936)
	offset: 0@0)
]

{ #category : #'morph creation' }
UITheme >> newCancelButtonIn: aThemedMorph for: aModel [
	"Answer a new cancel button."

	^self
		newButtonIn: aThemedMorph
		for: aModel
		getState: nil
		action: #cancel
		arguments: nil
		getEnabled: nil
		label: 'Cancel' translated
		help: 'Cancel changes and close the window' translated
]

{ #category : #initialization }
UITheme >> newCheckboxForm [
	"Answer the form for a normal checkbox."

	^(Form
	extent: 14@14
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 594242411 3918960278 4138774704 4138774704 4138774704 4138774704 4138774704 4138774704 4138774704 4138774704 4138774704 4138774704 3919026071 594242411 2575072380 4292467161 4294177779 4294177779 4294177779 4294177779 4294177779 4294177779 4294177779 4294177779 4294177779 4294177779 4292467161 2524806525 2658695288 4292664540 4293651435 4293651435 4293651435 4293651435 4293651435 4293651435 4293651435 4293651435 4293651435 4293651435 4292664540 2608429433 2658432116 4292532954 4293322470 4293322470 4293322470 4293322470 4293322470 4293322470 4293322470 4293322470 4293322470 4293322470 4292532954 2608232054 2658366323 4292467161 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4293059298 4292467161 2608100468 2658037358 4292532954 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292532954 2607771503 2657839979 4292138196 4292138196 4292138196 4292138196 4292138196 4292138196 4292138196 4292138196 4292138196 4292138196 4292138196 4292138196 2607639917 2657642600 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 2607442538 2657313635 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 4293190884 2607113573 2657116256 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 4293717228 2606850401 2606455643 4294046193 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294309365 4294046193 2556255581 1311978291 4237003659 4289967027 4289967027 4289967027 4289967027 4289967027 4289967027 4289967027 4289967027 4289967027 4289967027 4237003659 1278555445 50331648 1210986030 1647917369 1647917369 1647917369 1647917369 1647917369 1647917369 1647917369 1647917369 1647917369 1647917369 1210986030 50331648)
	offset: 0@0)
]

{ #category : #'morph creation' }
UITheme >> newCheckboxIn: aThemedMorph for: aModel getSelected: getSel setSelected: setSel getEnabled: enabledSel getLabel: labelSel help: helpText [
	"Answer a checkbox with the given label ."

	| answer |
	answer := CheckboxMorph
			on: aModel selected: getSel changeSelected: setSel.
	answer
		getEnabledSelector: enabledSel;
		getLabelSelector: labelSel;
		labelMorph: (self checkboxLabelFor: answer);
		font: self labelFont;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		setBalloonText: helpText.
	^answer
]

{ #category : #'morph creation' }
UITheme >> newCheckboxIn: aThemedMorph for: aModel getSelected: getSel setSelected: setSel getEnabled: enabledSel label: label help: helpText [
	"Answer a checkbox with the given label ."

	| answer |
	answer := CheckboxMorph
			on: aModel selected: getSel changeSelected: setSel.
	answer
		getEnabledSelector: enabledSel;
		label: label;
		labelMorph: (self checkboxLabelFor: answer);
		font: self labelFont;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		setBalloonText: helpText.
	^answer
]

{ #category : #initialization }
UITheme >> newCheckboxMarkerForm [
	"Answer a new checkbox marker form."

	^ self iconNamed: #checkboxMarkerForm
]

{ #category : #initialization }
UITheme >> newCheckboxSelectedForm [
	"Answer the form for a selected checkbox."

	^(Form
	extent: 14@14
	depth: 32
	fromArray: #( 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215 591416973 3914425236 4134435746 4134435746 4134435746 4134435746 4134435746 4134435746 4134435746 4134435746 4134435746 4134435746 3914425236 591416973 2571195527 4289245124 4293125612 4293125612 4293125612 4293125612 4293125612 4293125612 4293125612 4293125612 4293125612 4293125612 4289245124 2520929417 2655015551 4289114053 4291744479 4291744479 4291744479 4291744479 4291744479 4291744479 4291744479 4291744479 4291744479 4291744479 4289114053 2604684160 2654949242 4288456640 4290560980 4290560980 4290560980 4290560980 4290560980 4290560980 4290560980 4290560980 4290560980 4290560980 4288456640 2604748668 2654817654 4287799485 4289443276 4289443276 4289443276 4289443276 4289443276 4289443276 4289443276 4289443276 4289443276 4289443276 4287799485 2604486007 2654686063 4287273914 4288457669 4288457669 4288457669 4288457669 4288457669 4288457669 4288457669 4288457669 4288457669 4288457669 4287273914 2604420207 2654816618 4284907433 4284907433 4284907433 4284907433 4284907433 4284907433 4284907433 4284907433 4284907433 4284907433 4284907433 4284907433 2604484971 2654619492 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 2604353637 2654684509 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 4286092732 2604352863 2654487128 4286685382 4286685382 4286685382 4286685382 4286685382 4286685382 4286685382 4286685382 4286685382 4286685382 4286685382 4286685382 2604221017 2603892560 4287146187 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287278031 4287146187 2553626706 1310531626 4232599666 4284512149 4284512149 4284512149 4284512149 4284512149 4284512149 4284512149 4284512149 4284512149 4284512149 4232599666 1276977451 50331648 1210064935 1646208047 1646208047 1646208047 1646208047 1646208047 1646208047 1646208047 1646208047 1646208047 1646208047 1210064935 50331648)
	offset: 0@0)
]

{ #category : #'morph creation' }
UITheme >> newCloseButtonIn: aThemedMorph for: aModel [
	"Answer a new close button."

	^self
		newButtonIn: aThemedMorph
		for: aModel
		getState: nil
		action: #close
		arguments: nil
		getEnabled: nil
		label: 'Close' translated
		help: 'Close the window' translated
]

{ #category : #'morph creation' }
UITheme >> newCloseControlIn: aThemedMorph for: aModel action: aValuable help: helpText [
	"Answer a button for closing things."
	
	|form msb|
	form := self windowCloseForm.
	msb := MultistateButtonMorph new extent: form extent.
	msb activeEnabledNotOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowClosePassiveForm.
	msb extent: form extent.
	msb activeDisabledNotOverUpFillStyle: (ImageFillStyle form: form).
	msb passiveEnabledNotOverUpFillStyle: (ImageFillStyle form: form).
	msb passiveDisabledNotOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowCloseOverForm.
	msb extent: form extent.
	msb
		activeEnabledOverUpFillStyle: (ImageFillStyle form: form);
		passiveEnabledOverUpFillStyle: (ImageFillStyle form: form).
	form := self windowClosePassiveForm.
	msb
		extent: form extent;
		activeEnabledOverDownFillStyle: (ImageFillStyle form: form);
		passiveEnabledOverDownFillStyle: (ImageFillStyle form: form);
		addUpAction: aValuable;
		setBalloonText: helpText.
	^msb
]

{ #category : #'morph creation' }
UITheme >> newColorChooserIn: aThemedMorph for: aModel getColor: getSel setColor: setSel getEnabled: enabledSel help: helpText [
	"Answer a color chooser ."

	^(ColorChooserMorph
			on: aModel color: getSel changeColor: setSel)
		getEnabledSelector: enabledSel;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newColorPresenterIn: aThemedMorph for: aModel getColor: getSel help: helpText [
	"Answer a color presenter."

	^(ColorPresenterMorph
			on: aModel color: getSel)
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newColumnIn: aThemedMorph for: controls [
	"Answer a morph laid out with a column of controls."

	|answer|
	answer := PanelMorph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		fillStyle: Color transparent; "non pane color tracking"
		changeTableLayout;
		cellInset: 8;
		cellPositioning: #leftCenter.
	controls do: [:m | answer addMorphBack: m].
	^answer
			
]

{ #category : #'morph creation' }
UITheme >> newDialogPanelIn: aThemedMorph [
	"Answer a new (main) dialog panel."

	^(self newPanelIn: aThemedMorph)
		fillStyle: (SolidFillStyle color: Color transparent) "no pane colour tracking"
]

{ #category : #'morph creation' }
UITheme >> newDropListIn: aThemedMorph for: aModel list: listSel getSelected: getSel setSelected: setSel getEnabled: enabledSel useIndex: useIndex help: helpText [
	"Answer a drop list for the given model."

	^(EditableDropListMorph basicNew
		basicTheme: self;
			initialize;
			useSelectionIndex: useIndex;
			on: aModel
			list: listSel
			selected: getSel
			changeSelected: setSel)
		selectionColor: self selectionColor;
		getEnabledSelector: enabledSel;
		font: self dropListFont;
		listFont: self listFont;
		cornerStyle: aThemedMorph preferredCornerStyle;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		setBalloonText: helpText;
		basicTheme: nil;
		beReadOnly;
		yourself
]

{ #category : #'morph creation' }
UITheme >> newEditableDropListIn: aThemedMorph for: aModel list: listSel getSelected: getSel setSelected: setSel addToList: addSel class: aClass default: defaultValue ghostText: ghostText getEnabled: enabledSel useIndex: useIndex help: helpText [
	"Answer an editable drop list for the given model."

	^(EditableDropListMorph
			on: aModel
			list: listSel
			selected: getSel
			changeSelected: setSel
			useIndex: useIndex
			addToList: addSel
			class: aClass
			getEnabled: enabledSel
			default: defaultValue)
		ghostText: ghostText;
		selectionColor: self selectionColor;
		font: self dropListFont;
		cornerStyle: aThemedMorph preferredCornerStyle;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newEmbeddedMenuIn: aThemedMorph for: aModel [
	"Answer a new menu."

	^EmbeddedMenuMorph new
		defaultTarget: aModel;
		color: (self menuColorFor: aThemedMorph)
]

{ #category : #'morph creation' }
UITheme >> newExpanderIn: aThemedMorph label: aString forAll: controls [
	"Answer an expander with the given label and controls."

	|answer|
	answer := ExpanderMorph basicNew
		basicTheme: self;
		initialize;
		font: self menuFont;
		titleText: aString;
		basicTheme: nil.
	controls do: [:m |
		answer addMorphBack: m].
	^answer
]

{ #category : #'morph creation' }
UITheme >> newFocusIndicatorMorphFor: aMorph [
	"Answer a new focus indicator for the given morph."

	^ BorderedMorph new
		fillStyle: Color transparent;
		borderStyle: (SimpleBorderStyle new
			 width: 1;
			baseColor: (self baseSelectionColorFor: aMorph));
		bounds: aMorph focusBounds
]

{ #category : #'morph creation' }
UITheme >> newFontSelector [
	"Answer a new font selector dialog"
		^FreeTypeFontSelectorDialogWindow new
	
]

{ #category : #'morph creation' }
UITheme >> newFuzzyLabelIn: aThemedMorph for: aModel label: aString offset: offset alpha: alpha getEnabled: enabledSel [
	"Answer a new fuzzy label."

	^(FuzzyLabelMorph contents: aString font: self labelFont)
		offset: offset;
		alpha: alpha;
		model: aModel;
		getEnabledSelector: enabledSel	
]

{ #category : #'morph creation' }
UITheme >> newGroupboxIn: aThemedMorph [
	"Answer a plain groupbox."

	^PlainGroupboxMorph new
		cornerStyle: aThemedMorph preferredCornerStyle;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself
]

{ #category : #'morph creation' }
UITheme >> newGroupboxIn: aThemedMorph for: control [
	"Answer a plain groupbox."

	^(self newGroupboxIn: aThemedMorph)
		addMorph: control
]

{ #category : #'morph creation' }
UITheme >> newGroupboxIn: aThemedMorph forAll: controls [
	"Answer a plain groupbox."

	^self
		newGroupboxIn: aThemedMorph
		for: (self newColumnIn: aThemedMorph for: controls)
]

{ #category : #'morph creation' }
UITheme >> newGroupboxIn: aThemedMorph label: aString [
	"Answer a groupbox with the given label."

	^GroupboxMorph new
		font: self labelFont;
		cornerStyle: aThemedMorph preferredCornerStyle;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		label: aString;
		yourself
]

{ #category : #'morph creation' }
UITheme >> newGroupboxIn: aThemedMorph label: aString for: control [
	"Answer a groupbox with the given label and control."

	^(self newGroupboxIn: aThemedMorph label: aString)
		addContentMorph: control;
		yourself
]

{ #category : #'morph creation' }
UITheme >> newGroupboxIn: aThemedMorph label: aString forAll: controls [
	"Answer a groupbox with the given label and controls."

	^(self newGroupboxIn: aThemedMorph label: aString)
		addContentMorph: (self newColumnIn: aThemedMorph for: controls);
		yourself
]

{ #category : #'morph creation' }
UITheme >> newHSVASelectorIn: aThemedMorph color: aColor help: helpText [
	"Answer a hue-saturation-volume-alpha selector."

	^HSVAColorSelectorMorph new
		selectedColor: aColor;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newHSVSelectorIn: aThemedMorph color: aColor help: helpText [
	"Answer a hue-saturation-volume selector."

	^HSVColorSelectorMorph new
		selectedColor: aColor;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newHueSelectorIn: aThemedMorph for: aModel getHue: getSel setHue: setSel help: helpText [
	"Answer a hue selector ."

	^(HColorSelectorMorph
			on: aModel
			getValue: getSel
			setValue: setSel)
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newImageIn: aThemedMorph for: aModel get: getSel help: helpText [
	"Answer a new image morph."

	^AlphaImageMorph new
		model: aModel;
		borderStyle: (BorderStyle inset width: 0);
		getImageSelector: getSel;
		setBalloonText: helpText;
		updateImage
]

{ #category : #'morph creation' }
UITheme >> newImageIn: aThemedMorph form: aForm [
	"Answer a new text label."

	^self
		newImageIn: aThemedMorph
		form: aForm
		size: aForm extent
]

{ #category : #'morph creation' }
UITheme >> newImageIn: aThemedMorph form: aForm size: aPoint [
	"Answer a new image morph."

	^AlphaImageMorph new
		borderStyle: (BorderStyle inset width: 0);
		image: aForm size: aPoint
]

{ #category : #'morph creation' }
UITheme >> newIncrementalSliderIn: aThemedMorph for: aModel getValue: getSel setValue: setSel min: min max: max quantum: quantum getEnabled: enabledSel help: helpText [
	"Answer a slider inrement/decrement buttons."

	^(IncrementalSliderMorph
			on: aModel
			getValue: getSel
			setValue: setSel
			min: min
			max: max
			quantum: quantum)
		getEnabledSelector: enabledSel;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newLabelGroupIn: aThemedMorph for: labelsAndControls [
	"Answer a morph laid out with a column of labels and a column of associated controls.
	The vResizing for each row will be #spaceFill if the control for that row specifies
	this, otherwise #shrinkWrap."

	| labels labelWidth lc |
	lc := labelsAndControls collect: [:a |
		(a key isMorph
			ifTrue: [a key]
			ifFalse: [a key ifNotNil: [self newLabelIn: aThemedMorph label: a key asString]])
			-> a value].
	labels := Morph new
		hResizing: #shrinkWrap;
		vResizing: #spaceFill;
		changeTableLayout.
	lc do: [:a |
		a key ifNotNil: [labels addMorphBack: a key]].
	labelWidth := labels minExtent x.
	^self newColumnIn: aThemedMorph for: (lc collect: [:a | | row |
		a key ifNotNil: [a key hResizing: #rigid; extent: labelWidth@ a key height].
		row := self newRowIn: aThemedMorph for: (a key ifNil: [{a value}] ifNotNil: [{a key. a value}]).
		row vResizing: (a value vResizing = #spaceFill ifTrue: [#spaceFill] ifFalse: [#shrinkWrap]).
		row])
]

{ #category : #'morph creation' }
UITheme >> newLabelGroupIn: aThemedMorph for: labelsAndControls font: aFont labelColor: aColor [
	"Answer a morph laid out with a column of labels and a column of associated controls.
	If spaceFill is tru then each row will share available space to pad."

	| labels labelWidth lc|
	lc := labelsAndControls collect: [:a |
		(a key isMorph
			ifTrue: [a key]
			ifFalse: [(self newLabelIn: aThemedMorph label: (a key ifNil: ['']) asString)
						font: aFont;
						color: aColor])
			-> a value].
	labels := Morph new
		hResizing: #shrinkWrap;
		vResizing: #spaceFill;
		changeTableLayout.
	lc do: [:a |
		labels addMorphBack: a key].
	labelWidth := labels minExtent x.
	^self newColumnIn: aThemedMorph for: (lc collect: [:a | | row |
		a key hResizing: #rigid; extent: labelWidth@ a key height.
		row := self newRowIn: aThemedMorph for: {a key. a value}.
		row vResizing: (a value vResizing = #spaceFill ifTrue: [#spaceFill] ifFalse: [#shrinkWrap]).
		row])
]

{ #category : #'morph creation' }
UITheme >> newLabelIn: aThemedMorph for: aModel getLabel: labelSel getEnabled: enabledSel [
	"Answer a new text label."

	^(LabelMorph contents: '' font: self labelFont)
		model: aModel;
		getEnabledSelector: enabledSel;
		getTextSelector: labelSel
]

{ #category : #'morph creation' }
UITheme >> newLabelIn: aThemedMorph for: aModel label: aString getEnabled: enabledSel [
	"Answer a new text label."

	^(LabelMorph contents: aString font: self labelFont)
		model: aModel;
		getEnabledSelector: enabledSel
]

{ #category : #'morph creation' }
UITheme >> newLabelIn: aThemedMorph label: aString [
	"Answer a new text label."

	^self
		newLabelIn: aThemedMorph
		for: nil
		label: aString
		getEnabled: nil
]

{ #category : #'morph creation' }
UITheme >> newListIn: aThemedMorph for: aModel list: listSelector selected: getSelector changeSelected: setSelector getEnabled: enabledSel help: helpText [
	"Answer a list for the given model."

	^PluggableListMorph new
		selectionColor: self selectionColor;
		textColor: self listTextColor;
		font: self listFont;
		on: aModel
		list: listSelector
		selected: getSelector
		changeSelected: setSelector
		menu: nil
		keystroke: nil;
		autoDeselect: false;
		cornerStyle: aThemedMorph preferredCornerStyle;
		color: Color white;
		borderStyle: (BorderStyle inset width: 1);
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		getEnabledSelector: enabledSel;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newListIn: aThemedMorph for: aModel list: listSelector selected: getSelector changeSelected: setSelector icon: iconSelector getEnabled: enabledSel help: helpText [
	"Answer an icon list for the given model."

	^PluggableIconListMorph new
		selectionColor: self selectionColor;
		textColor: self listTextColor;
		font: self listFont;
		on: aModel
		list: listSelector
		selected: getSelector
		changeSelected: setSelector
		menu: nil
		keystroke: nil;
		autoDeselect: false;
		cornerStyle: aThemedMorph preferredCornerStyle;
		color: Color white;
		borderStyle: (BorderStyle inset width: 1);
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		getIconSelector: iconSelector;
		getEnabledSelector: enabledSel;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newMenuIn: aThemedMorph for: aModel [
	"Answer a new menu."

	^MenuMorph new
		defaultTarget: aModel;
		color: (self menuColorFor: aThemedMorph)
]

{ #category : #'morph creation' }
UITheme >> newMorphDropListIn: aThemedMorph for: aModel list: listSel getSelected: getSel setSelected: setSel getEnabled: enabledSel help: helpText [
	"Answer a morph drop list for the given model."

	^self
		newMorphDropListIn: aThemedMorph
		for: aModel
		list: listSel
		getSelected: getSel
		setSelected: setSel
		getEnabled: enabledSel
		useIndex: true
		help: helpText
]

{ #category : #'morph creation' }
UITheme >> newMorphDropListIn: aThemedMorph for: aModel list: listSel getSelected: getSel setSelected: setSel getEnabled: enabledSel useIndex: useIndex help: helpText [
	"Answer a morph drop list for the given model."

	^(MorphDropListMorph
			on: aModel
			list: listSel
			selected: getSel
			changeSelected: setSel
			useIndex: useIndex)
		selectionColor: self selectionColor;
		getEnabledSelector: enabledSel;
		cornerStyle: aThemedMorph preferredCornerStyle;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newMorphListIn: aThemedMorph for: aModel list: listSelector getSelected: getSelector setSelected: setSelector getEnabled: enabledSel help: helpText [
	"Answer a morph list for the given model."

	^(PluggableMorphListMorph
			on: aModel
			list: listSelector
			selected: getSelector
			changeSelected: setSelector
			menu: nil
			keystroke: nil)
		selectionColor: self selectionColor;
		autoDeselect: false;
		cornerStyle: aThemedMorph preferredCornerStyle;
		color: Color white;
		borderStyle: (BorderStyle inset width: 1);
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		getEnabledSelector: enabledSel;
		setBalloonText: helpText
		
]

{ #category : #'morph creation' }
UITheme >> newMultistateButtonIn: aThemedMorph [
	"Answer a new multistate button morph."

	^MultistateButtonMorph new
]

{ #category : #'morph creation' }
UITheme >> newNoButtonIn: aThemedMorph for: aModel [
	"Answer a new No button."

	^(self
			newButtonIn: aThemedMorph
			for: aModel
			getState: nil
			action: #no
			arguments: nil
			getEnabled: nil
			label: 'No' translated
			help: 'Answer no and close the window' translated)
		hResizing: #rigid;
		vResizing: #rigid
]

{ #category : #'morph creation' }
UITheme >> newOKButtonIn: aThemedMorph for: aModel getEnabled: enabledSel [
	"Answer a new OK button."

	^self
		newButtonIn: aThemedMorph
		for: aModel
		getState: nil
		action: #ok
		arguments: nil
		getEnabled: enabledSel
		label: 'OK' translated
		help: 'Apply changes and close the window' translated
]

{ #category : #'morph creation' }
UITheme >> newOverflowRowIn: aThemedMorph forAll: aCollectionOfMorphs [
	"Answer a new overflow row morph with the given contents."

	^OverflowRowMorph new
		baseMorphs: aCollectionOfMorphs;
		yourself
]

{ #category : #'morph creation' }
UITheme >> newPanelIn: aThemedMorph [
	"Answer a new panel."

	^PanelMorph new
		changeTableLayout;
		layoutInset: 4;
		cellInset: 8;
		cornerStyle: aThemedMorph preferredCornerStyle;
		yourself
]

{ #category : #'morph creation' }
UITheme >> newPluggableDialogWindowIn: aThemedMorph title: title for: contentMorph [
	"Answer a new pluggable dialog panel with the given content."

	|answer|
	answer := PluggableDialogWindow new
		setWindowColor: aThemedMorph paneColor;
		title: title;
		contentMorph: contentMorph.
	contentMorph ifNotNil: [answer model: nil].
	^answer
]

{ #category : #initialization }
UITheme >> newRadioButtonForm [
	"Answer the form for a normal radio button."

	^(Form
	extent: 14@14
	depth: 32
	fromArray: #( 16777215 16777215 16777215 198234320 2645865652 3568415153 4072521149 4055875519 3551637937 2578756788 164021958 16777215 16777215 16777215 16777215 16777215 1437906100 4038506166 4292598747 4293914607 4294111986 4294111986 4293914607 4292598747 4021728950 1303556786 16777215 16777215 16777215 1386916522 4257465283 4293388263 4293651435 4293651435 4293651435 4293651435 4293651435 4293651435 4293388263 4240556481 1219144362 16777215 195207842 4038177201 4293125091 4293256677 4293256677 4293256677 4293256677 4293256677 4293256677 4293256677 4293256677 4293059298 3987713967 144678815 2627640990 4291875024 4292993505 4292993505 4292993505 4292993505 4292993505 4292993505 4292993505 4292993505 4292993505 4292993505 4291743438 2459803037 3584139681 4292072403 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292861919 4292006610 3500056222 3970476200 4291809231 4292467161 4292532954 4292532954 4292532954 4292532954 4292532954 4292532954 4292532954 4292532954 4292467161 4291809231 3919947173 3919749794 4292203989 4292203989 4292203989 4292203989 4292203989 4292203989 4292203989 4292203989 4292203989 4292203989 4292203989 4292203989 3869154974 3515846543 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 4292664540 3431697291 2289333364 4291480266 4293125091 4293125091 4293125091 4293125091 4293125091 4293125091 4293125091 4293125091 4293125091 4293125091 4291151301 2154918257 189154886 3817178501 4293256677 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293585642 4293059298 3766583681 189154886 16777215 960906822 4120221077 4293322470 4294111986 4294111986 4294111986 4294111986 4294111986 4294111986 4293256677 4103180689 927549769 16777215 16777215 16777215 910048830 3682039671 4290756543 4293256677 4294572537 4294506744 4293190884 4273847741 3648287860 893337407 16777215 16777215 16777215 16777215 16777215 169482778 1799570243 3042202708 3681710706 3664867697 3025359699 1799636036 169482778 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'morph creation' }
UITheme >> newRadioButtonIn: aThemedMorph for: aModel getSelected: getSel setSelected: setSel getEnabled: enabledSel label: label help: helpText [
	"Answer a checkbox (radio button appearance) with the given label ."

	| answer |
	answer := CheckboxMorph
			on: aModel selected: getSel changeSelected: setSel.
	answer
		getEnabledSelector: enabledSel;
		label: label;
		labelMorph: (self checkboxLabelFor: answer);
		font: self labelFont;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		setBalloonText: helpText;
		beRadioButton.
	^answer
]

{ #category : #initialization }
UITheme >> newRadioButtonMarkerForm [
	"Answer a new radio button marker form. We make it empty because we already have the selected radio button take care of the state."

	^ self iconNamed: #radioButtonMarkerForm
]

{ #category : #initialization }
UITheme >> newRadioButtonSelectedForm [
	"Answer the form for a selected radio button."

	^(Form
	extent: 14@14
	depth: 32
	fromArray: #( 16777215 16777215 16777215 195273727 2641329849 3563221416 4067918510 4051207088 3546444457 2574352313 160337634 16777215 16777215 16777215 16777215 16777215 1433764797 4033509543 4289442502 4292467941 4292928234 4292928234 4292467941 4289442502 4016797863 1299613120 16777215 16777215 16777215 1383498170 4252665514 4291152600 4291744478 4291744478 4291744478 4291744478 4291744478 4291744478 4291087064 4235822507 1216120505 16777215 192187321 4033181089 4290232016 4290560980 4290560980 4290560980 4290560980 4290560980 4290560980 4290560980 4290560980 4290100687 3982914979 140541887 2623959968 4286746800 4289574859 4289574859 4289574859 4289574859 4289574859 4289574859 4289574859 4289574859 4289574859 4289574859 4286549679 2456319395 3579801242 4286353071 4288654533 4288654533 4288654533 4288654533 4288654533 4288654533 4288654533 4288654533 4288654533 4288654533 4286089901 3495980954 3965612183 4284709539 4286944951 4287011000 4287011000 4287011000 4287011000 4287011000 4287011000 4287011000 4287011000 4286813622 4284643746 3915280279 3915345555 4284973226 4284973226 4284973226 4284973226 4284973226 4284973226 4284973226 4284973226 4284973226 4284973226 4284973226 4284973226 3864947858 3512362887 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 4285500082 3428345476 2286835828 4285433514 4286026683 4286026683 4286026683 4286026683 4286026683 4286026683 4286026683 4286026683 4286026683 4286026683 4285235879 2152552048 187582022 3813958010 4286421439 4286553283 4286553283 4286553283 4286553283 4286553283 4286553283 4286553283 4286553283 4286355645 3763494776 187582022 16777215 959790667 4116343939 4286685122 4287014603 4287014603 4287014603 4287014603 4287014603 4287014603 4286619329 4099500930 926039117 16777215 16777215 16777215 908735550 3679148137 4285630628 4286882500 4287541204 4287541204 4286816707 4268787875 3645527655 892024127 16777215 16777215 16777215 16777215 16777215 169482778 1798387264 3040494156 3679082084 3662239075 3023716940 1798452800 169482778 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'morph creation' }
UITheme >> newRowIn: aThemedMorph for: controls [
	"Answer a morph laid out with a row of controls."

	|answer|
	answer := PanelMorph new
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		fillStyle: Color transparent; "non pane color tracking"
		changeTableLayout;
		listDirection: #leftToRight;
		cellInset: 8;
		cellPositioning: #center.
	controls do: [:m | answer addMorphBack: m].
	^answer
			
]

{ #category : #'morph creation' }
UITheme >> newSVSelectorIn: aThemedMorph color: aColor help: helpText [
	"Answer a saturation-volume selector."

	^SVColorSelectorMorph new
		color: aColor;
		selectedColor: aColor;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		setBalloonText: helpText
]

{ #category : #'morph creation' }
UITheme >> newScrollBarDownButtonFor: aScrollbar [
	^ BorderedMorph newBounds: (self scrollBarDownButtonBoundsFor: aScrollbar)
]

{ #category : #'morph creation' }
UITheme >> newScrollBarUpButtonFor: aScrollbar [
	^ BorderedMorph newBounds: (self scrollBarUpButtonBoundsFor: aScrollbar)
]

{ #category : #'morph creation' }
UITheme >> newScrollPaneIn: aThemedMorph for: aMorph [
	"Answer a new GeneralScrollPane with given content morph."

	^GeneralScrollPaneMorph new
		scrollTarget: aMorph;
		yourself
]

{ #category : #initialization }
UITheme >> newScrollbarThumbBottomForm [
	"Answer the form for the bottom of a scrollbar thumb."

	^(Form
	extent: 13@7
	depth: 32
	fromArray: #( 4284182411 4287142063 4287931577 4287602613 4287208113 4286879149 4286484649 4286155685 4285761185 4285432221 4285103257 4284577427 4282669690 4284182411 4286287012 4287931577 4287602613 4287208113 4286879149 4286484649 4286155685 4285761185 4285432221 4285103257 4284182670 4282669690 2906411633 4284445326 4287536820 4287602613 4287208113 4286879149 4286484649 4286155685 4285761185 4285432221 4285103257 4283261825 3023720303 2033601901 4284182411 4285037205 4287339698 4287208113 4286879149 4286484649 4286155685 4285761185 4285432221 4283919242 4282801275 2503363949 1149473452 2755548019 4284050825 4284248204 4285958562 4286681770 4286484649 4286155685 4285037464 4283656069 4282998397 3023720559 1262704758 0 422725477 2083867754 2671004523 4283787654 4283656068 4283656325 4283392897 4283195776 3023786609 2688176497 926700403 73298833 0 0 0 1345735788 1999981163 2671004523 2671004523 2671004523 2167753578 1580616556 171134054 0 0)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newScrollbarThumbHorizontalMiddleForm [
	"Answer the form for the middle of a horizontal scrollbar thumb."

	^(Form
	extent: 1@13
	depth: 32
	fromArray: #( 4284182411 4288326078 4287931577 4287602613 4287208113 4286879149 4286484649 4286155685 4285761185 4285432221 4285103257 4284709013 4282669690)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newScrollbarThumbLeftForm [
	"Answer the form for the left hand side of a scrollbar thumb."

	^(Form
	extent: 7@13
	depth: 32
	fromArray: #( 0 0 1149473452 2033601901 2906411633 4284182411 4284182411 0 422725477 2755548019 4284182411 4284445326 4286287012 4287142063 0 2083867754 4284050825 4285037205 4287536820 4287931577 4287931577 1345735788 2671004523 4284248204 4287339698 4287602613 4287602613 4287602613 1999981163 4283787654 4285958562 4287208113 4287208113 4287208113 4287208113 2671004523 4283656068 4286681770 4286879149 4286879149 4286879149 4286879149 2671004523 4283656325 4286484649 4286484649 4286484649 4286484649 4286484649 2671004523 4283392897 4286155685 4286155685 4286155685 4286155685 4286155685 2167753578 4283195776 4285037464 4285761185 4285761185 4285761185 4285761185 1580616556 3023786609 4283656069 4285432221 4285432221 4285432221 4285432221 171134054 2688176497 4282998397 4283919242 4285103257 4285103257 4285103257 0 926700403 3023720559 4282801275 4283261825 4284182670 4284577427 0 73298833 1262704758 2503363949 3023720303 4282669690 4282669690)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newScrollbarThumbRightForm [
	"Answer the form for the right hand side of a scrollbar thumb."

	^(Form
	extent: 7@13
	depth: 32
	fromArray: #( 4284182411 4284182411 2587118699 1396330353 211462590 0 0 4287010734 4285629341 4284182411 4284182411 2033601901 0 0 4287931577 4287931577 4286682026 4284313740 4284050825 1261587049 0 4287602613 4287602613 4287602613 4286418855 4283919239 2587118699 422725477 4287208113 4287208113 4287208113 4287208113 4284971669 4283787654 1345735788 4286879149 4286879149 4286879149 4286879149 4285629597 4283656068 1832209003 4286484649 4286484649 4286484649 4286484649 4285695391 4283458947 1999981163 4286155685 4286155685 4286155685 4286155685 4285169048 4283392897 1916095595 4285761185 4285761185 4285761185 4285761185 4284379535 4283195776 1345735788 4285432221 4285432221 4285432221 4285037464 4283195775 2671004523 758270315 4285103257 4285103257 4284905878 4283327362 4282998397 1664502380 0 4284380048 4283853961 4282932861 4282801275 2419477869 171134054 0 4282669690 4282669690 2755021932 2436846708 322261099 0 0)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newScrollbarThumbTopForm [
	"Answer the form for the top of a scrollbar thumb."

	^(Form
	extent: 13@7
	depth: 32
	fromArray: #( 0 0 0 422725477 1345735788 1832209003 1999981163 1916095595 1345735788 758270315 0 0 0 0 0 1261587049 2587118699 4283787654 4283656068 4283458947 4283392897 4283195776 2671004523 1664502380 171134054 0 211462590 2033601901 4284050825 4283919239 4284971669 4285629597 4285695391 4285169048 4284379535 4283195775 4282998397 2419477869 322261099 1396330353 4284182411 4284313740 4286418855 4287208113 4286879149 4286484649 4286155685 4285761185 4285037464 4283327362 4282801275 2436846708 2587118699 4284182411 4286682026 4287602613 4287208113 4286879149 4286484649 4286155685 4285761185 4285432221 4284905878 4282932861 2755021932 4284182411 4285629341 4287931577 4287602613 4287208113 4286879149 4286484649 4286155685 4285761185 4285432221 4285103257 4283853961 4282669690 4284182411 4287010734 4287931577 4287602613 4287208113 4286879149 4286484649 4286155685 4285761185 4285432221 4285103257 4284380048 4282669690)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newScrollbarThumbVerticalMiddleForm [
	"Answer the form for the middle of a vertical scrollbar thumb."

	^(Form
	extent: 13@1
	depth: 32
	fromArray: #( 4284182411 4288326078 4287931577 4287602613 4287208113 4286879149 4286484649 4286155685 4285761185 4285432221 4285103257 4284709013 4282669690)
	offset: 0@0)
]

{ #category : #'morph creation' }
UITheme >> newSeparatorIn: aThemedMorph [
	"Answer a new horizontal separator."

	^SeparatorMorph new
		fillStyle: Color transparent;
		borderStyle: (BorderStyle inset baseColor: Color blue; width: 1);
		extent: 2@2;
		hResizing: #spaceFill
]

{ #category : #'morph creation' }
UITheme >> newSliderIn: aThemedMorph for: aModel getValue: getSel setValue: setSel min: min max: max quantum: quantum getEnabled: enabledSel help: helpText [
	"Answer a slider. Resizing set for horizontal usage by default."

	^(PluggableSliderMorph
			on: aModel
			getValue: getSel
			setValue: setSel
			min: min
			max: max
			quantum: quantum)
		getEnabledSelector: enabledSel;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		setBalloonText: helpText;
		minHeight: 16
]

{ #category : #'morph creation' }
UITheme >> newStackIn: aThemedMorph for: controls [
	"Answer a morph laid out with a stack of controls."

	|answer|
	answer := PanelMorph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		fillStyle: Color transparent; "non pane color tracking"
		layoutPolicy: StackLayout new.
	controls do: [:m | answer addMorphBack: m].
	^answer
			
]

{ #category : #'morph creation' }
UITheme >> newStringIn: aThemedMorph label: aStringOrText font: aFont style: aStyle [
	"Answer a new string/text morph."

	^(EmbossedStringMorph contents: aStringOrText font: aFont)
		style: aStyle
]

{ #category : #'morph creation' }
UITheme >> newTabGroupIn: aThemedMorph for: labelsAndControls [
	"Answer a tab group morph with the given tab labels and associated pages."

	^(TabGroupMorph new
		font: self labelFont;
		cornerStyle: (self tabGroupCornerStyleIn: aThemedMorph);
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		labelsAndPages: labelsAndControls)
		selectedPageIndex: (labelsAndControls isEmpty ifTrue: [0] ifFalse: [1])
]

{ #category : #'morph creation' }
UITheme >> newTaskListButtonIn: aTasklist for: aTask [
	"Answer a tasklist button morph for the given task."
	
	|lm lab button |
	lab := (self buttonLabelForText: (aTask label contractTo: 40)).
	aTask isActive
		ifTrue: [ lab emphasis: 1 "1 -> bold" ].
	lm := self
		newRowIn: aTasklist
		for: {(aTask icon ifNil: [self smallWindowIcon]) asMorph. lab}.
	button := self
		newButtonIn: aTasklist
		for: aTask morph
		getState: #isActive
		action: #buttonClickedForTaskList:
		arguments: {aTasklist}
		getEnabled: nil
		label: lm
		help: nil.
	button
		useSquareCorners;
		onColor: (self taskbarMinimizedButtonColorFor: button)
		offColor: (aTask isActive
				ifTrue: [self taskbarActiveButtonColorFor: button]
				ifFalse: [self taskbarButtonColorFor: button]);
		hResizing: #spaceFill.
	lab color: (self taskbarButtonLabelColorFor: button).
	button model: aTask.
	^button
]

{ #category : #'morph creation' }
UITheme >> newTaskbarButtonIn: aTaskbar for: aWindow [
	"Answer a taskbar button morph for the given window."

	^ (TaskbarItemMorph on: aWindow getState: #isActive action: #taskbarButtonClicked)
		initializeFor: aTaskbar;
		yourself
]

{ #category : #'morph creation' }
UITheme >> newTaskbarThumbnailIn: aThemedMorph for: aWindow [
	"Answer a taskbar thumbnail morph for the given window."

	|answer thumb|
	thumb := aWindow taskbarThumbnail.
	answer := PanelMorph new
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		changeTableLayout;
		layoutInset: 8;
		cellInset: 4;
		addMorphBack: thumb;
		addMorphBack: ((self
			buttonLabelForText: (aWindow labelString truncateWithElipsisTo: 50))
				color: Color white).
	answer
		extent: answer minExtent;
		fillStyle: (self taskListFillStyleFor: answer);
		borderStyle: (self taskbarThumbnailNormalBorderStyleFor: aWindow);
		cornerStyle: (self taskbarThumbnailCornerStyleFor: answer).
	^answer
			
]

{ #category : #'morph creation' }
UITheme >> newTextEditorIn: aThemedMorph for: aModel getText: getSel setText: setSel getEnabled: enabledSel menu: aMenuSelector [
	"Answer a text (Smalltalk code) editor for the given model."

	^ RubPluggableTextMorph new
		on: aModel
		text: getSel
		accept: setSel
		readSelection: nil
		menu: aMenuSelector;
		theme: self;
		getEnabledSelector: enabledSel;
		font: self textFont;
		cornerStyle: aThemedMorph preferredCornerStyle;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		borderStyle: (BorderStyle inset width: 1);
		removeProperty: #theme
]

{ #category : #'morph creation' }
UITheme >> newTextEntryIn: aThemedMorph for: aModel get: getSel set: setSel class: aClass getEnabled: enabledSel help: helpText [
	"Answer a text entry for the given model."

	|pt|
	pt := RubPluggableTextFieldMorph new
		convertTo: aClass;
		alwaysAccept: true;
		on: aModel
		text: getSel
		accept: setSel
		readSelection: nil
		menu: nil;
		acceptOnCR: true;
		getEnabledSelector: enabledSel;
		font: self textFont;
		cornerStyle: (self textEntryCornerStyleIn: aThemedMorph);
		hResizing: #spaceFill;
		vResizing: #rigid;
		setBalloonText: helpText.
	^pt
]

{ #category : #'morph creation' }
UITheme >> newTextEntryIn: aThemedMorph for: aModel get: getSel set: setSel class: aClass getEnabled: enabledSel help: helpText entryCompletion: anEntryCompletion [
	"Answer a text entry for the given model."

	|pt|
	pt := RubPluggableTextFieldMorph new
		convertTo: aClass;
		alwaysAccept: true;
		on: aModel
		text: getSel
		accept: setSel
		readSelection: nil
		menu: nil;
		acceptOnCR: true;
		getEnabledSelector: enabledSel;
		font: self textFont;
		cornerStyle: (self textEntryCornerStyleIn: aThemedMorph);
		hResizing: #spaceFill;
		vResizing: #rigid;
		setBalloonText: helpText;
		entryCompletion: anEntryCompletion.
	^pt
]

{ #category : #'morph creation' }
UITheme >> newTextIn: aThemedMorph text: aStringOrText [
	"Answer a new text."

	^TextMorph new
		wrapFlag: true;
		contents: aStringOrText;
		font: self textFont;
		autoFit: true;
		lock;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap
]

{ #category : #'morph creation' }
UITheme >> newTitleIn: aThemedMorph label: aString for: control [
	"Answer a morph laid out with a column with the title and control aligned to the left."

	^(self newColumnIn: aThemedMorph for: {
		self newLabelIn: aThemedMorph label: aString.
		control})
		cellPositioning: #leftCenter;
		cellInset: 2
]

{ #category : #'morph creation' }
UITheme >> newToolDockingBarIn: aThemedMorph [
	"Answer a new tool docking bar."

	^ToolDockingBarMorph new
		borderWidth: 0;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		clipSubmorphs: true
]

{ #category : #'morph creation' }
UITheme >> newToolSpacerIn: aThemedMorph [
	"Answer a new tool spacer."

	^Morph new
		borderWidth: 0;
		color: Color transparent;
		extent: 3@3
]

{ #category : #'morph creation' }
UITheme >> newToolbarHandleIn: aThemedMorph [
	"Answer a new toolbar handle."

	^PanelMorph new
		fillStyle: Color transparent; "non pane color tracking"
		borderStyle: (BorderStyle raised baseColor: Color blue; width: 1);
		extent: 4@3;
		vResizing: #spaceFill
]

{ #category : #'morph creation' }
UITheme >> newToolbarIn: aThemedMorph [
	"Answer a new toolbar."

	|bar|
	bar := PanelMorph new
		changeTableLayout;
		layoutInset: 0@1;
		listDirection: #leftToRight;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.
	"bar
		addMorphBack: (self newToolSpacerIn: aThemedMorph);
		addMorphBack: (self newToolbarHandleIn: aThemedMorph);
		addMorphBack: (self newToolSpacerIn: aThemedMorph)."
	^bar
]

{ #category : #'morph creation' }
UITheme >> newToolbarIn: aThemedMorph for: controls [
	"Answer a new toolbar with the given controls."

	|answer|
	answer := self newToolbarIn: aThemedMorph.
	controls do: [:m | answer addMorphBack: m].
	^answer
]

{ #category : #initialization }
UITheme >> newTreeExpandedForm [
	"Answer a new form for an expanded tree item."

	^(Form
	extent: 9@9
	depth: 32
	fromArray: #( 1049135240 2290649224 2290649224 2290649224 2290649224 2290649224 2290649224 2290649224 1200130184 478709896 4169697416 4287137928 4287137928 4287137928 4287137928 4287137928 4236806280 646482056 16777215 2508753032 4287137928 4287137928 4287137928 4287137928 4287137928 2726856840 16777215 16777215 495487112 4186474632 4287137928 4287137928 4287137928 4236806280 612927624 16777215 16777215 16777215 2542307464 4287137928 4287137928 4287137928 2676525192 16777215 16777215 16777215 16777215 478709896 4169697416 4287137928 4220029064 579373192 16777215 16777215 16777215 16777215 16777215 2424866952 4287137928 2626193544 16777215 16777215 16777215 16777215 16777215 16777215 394823816 4018702472 529041544 16777215 16777215 16777215 16777215 16777215 16777215 16777215 864585864 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'morph creation' }
UITheme >> newTreeIn: aThemedMorph for: aModel list: listSelector selected: getSelector changeSelected: setSelector [
	"Answer a new tree morph."
	
	^TreeListMorph new
		selectionColor: self selectionColor;
		font: self listFont;
		on: aModel
		list: listSelector
		selected: getSelector
		changeSelected: setSelector
		menu: nil
		keystroke: nil;
		cornerStyle: aThemedMorph preferredCornerStyle;
		"color: Color white;"
		borderStyle: (BorderStyle inset width: 1);
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		autoDeselect: false;
		yourself
		
]

{ #category : #initialization }
UITheme >> newTreeUnexpandedForm [
	"Answer a new form for an unexpanded tree item."

	^(Form
	extent: 9@9
	depth: 32
	fromArray: #( 1049135240 461932680 16777215 16777215 16777215 16777215 16777215 16777215 16777215 2324203656 4152920200 2458421384 428378248 16777215 16777215 16777215 16777215 16777215 2357758088 4287137928 4287137928 4152920200 2408089736 394823816 16777215 16777215 16777215 2391312520 4287137928 4287137928 4287137928 4287137928 4119365768 2324203656 344492168 16777215 2408089736 4287137928 4287137928 4287137928 4287137928 4287137928 4287137928 3968370824 780699784 2391312520 4287137928 4287137928 4287137928 4287137928 4236806280 2659747976 529041544 16777215 2357758088 4287137928 4287137928 4253583496 2810742920 646482056 16777215 16777215 16777215 2324203656 4253583496 2777188488 696813704 16777215 16777215 16777215 16777215 16777215 1200130184 663259272 16777215 16777215 16777215 16777215 16777215 16777215 16777215)
	offset: 0@0)
]

{ #category : #'morph creation' }
UITheme >> newVerticalSeparatorIn: aThemedMorph [
	"Answer a new vertical separator."

	^SeparatorMorph new
		fillStyle: Color transparent;
		borderStyle: (BorderStyle inset baseColor: Color blue; width: 1);
		extent: 2@2;
		vResizing: #spaceFill
]

{ #category : #initialization }
UITheme >> newWindowCloseForm [
	"Answer a new form for a window close box."

	^ self iconNamed: #windowCloseForm
]

{ #category : #initialization }
UITheme >> newWindowCloseOverForm [
	"Answer a new form for a window menu box."

	^ self newWindowCloseForm
]

{ #category : #'morph creation' }
UITheme >> newWindowHeaderFor: aWindow [

	^ (AlignmentMorph newSpacer: Color transparent)
			vResizing: #spaceFill;
			layoutPolicy: ProportionalLayout new
]

{ #category : #'morph creation' }
UITheme >> newWindowIn: aThemedMorph for: aModel title: titleString [
	"Answer a new StandardWindow with given model and title."

	^StandardWindow new
		title: titleString;
		model: aModel;
		yourself
]

{ #category : #initialization }
UITheme >> newWindowInactiveControlForm [
	"Answer a new form for an inactive window control box."

	^(Form
	extent: 16@16
	depth: 32
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4291677645 4288585374 4286085240 4284243036 4284243036 4286085240 4288585374 4291677645 0 0 0 0 0 0 0 4289572269 4285756275 4286479998 4288716960 4289835441 4289835441 4288716960 4286479998 4285756275 4289572269 0 0 0 0 0 4289506476 4284835173 4287335307 4290559164 4292598747 4293322470 4293322470 4292598747 4290559164 4287335307 4284703587 4289506476 0 0 0 4291546059 4285493103 4286414205 4288980132 4291217094 4292335575 4292598747 4292598747 4292335575 4291282887 4288980132 4286282619 4285493103 4291546059 0 0 4288980132 4285361517 4287466893 4288782753 4289835441 4290295992 4290295992 4290427578 4290164406 4289835441 4288782753 4287466893 4285361517 4288980132 0 0 4286282619 4286611584 4288059030 4288716960 4289177511 4289572269 4289835441 4289835441 4289703855 4289374890 4288782753 4288059030 4286611584 4286282619 0 0 4285164138 4287664272 4288782753 4289374890 4289835441 4290427578 4290624957 4290624957 4290559164 4290032820 4289374890 4288914339 4287664272 4285164138 0 0 4285361517 4288322202 4289703855 4290295992 4290822336 4291414473 4291677645 4291677645 4291414473 4291085508 4290427578 4289703855 4288453788 4285624689 0 0 4287072135 4288716960 4290427578 4291217094 4291677645 4292203989 4292598747 4292598747 4292335575 4291809231 4291217094 4290427578 4288716960 4287203721 0 0 4288980132 4288256409 4290624957 4291677645 4292335575 4292927712 4293256677 4293256677 4293059298 4292598747 4291809231 4290822336 4288256409 4289177511 0 0 4291677645 4287664272 4290295992 4292006610 4293059298 4293454056 4293585642 4293585642 4293454056 4293125091 4292203989 4290427578 4287730065 4291677645 0 0 4293256677 4290032820 4288124823 4291217094 4292796126 4293322470 4293717228 4293717228 4293454056 4292927712 4291677645 4288256409 4290032820 4293256677 0 0 0 4293454056 4290032820 4288322202 4289967027 4291546059 4292598747 4292664540 4291677645 4290295992 4288716960 4290032820 4293454056 0 0 0 0 0 4293322470 4292203989 4289835441 4288782753 4288322202 4288453788 4288980132 4289835441 4292335575 4293322470 0 0 0 0 0 0 0 4293059298 4293585642 4293717228 4293585642 4293585642 4293585642 4293585642 4293059298 0 0 0 0)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newWindowMaximizeForm [
	"Answer a new form for a window maximize box."

	^ self iconNamed: #windowMaximizeForm
]

{ #category : #initialization }
UITheme >> newWindowMaximizeOverForm [
	"Answer a new form for a window menu box."

	^ self newWindowMaximizeForm
]

{ #category : #initialization }
UITheme >> newWindowMenuForm [
	"Answer a new form for a window menu box."

	^ self iconNamed: #windowMenuForm
]

{ #category : #initialization }
UITheme >> newWindowMenuOverForm [
	"Answer a new form for a window menu box when the mouse is over it."

	^(Form
	extent: 24@16
	depth: 32
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4293257970 4287735753 4284054189 4281884573 4281490073 4281555866 4281555866 4281555866 4281555866 4281555866 4281555866 4281555866 4281555866 4281490073 4281884573 4284054189 4287735753 4293257970 0 0 0 0 0 4293192178 4286026172 4283462312 4287538375 4289970905 4290759648 4291088354 4291022817 4291022817 4291088354 4291088354 4291022817 4291022817 4291088354 4290759648 4289970905 4287538375 4283462312 4286026172 4293192178 0 0 0 0 4287735753 4283265191 4288721616 4292074729 4293060849 4293455092 4293652469 4293652469 4293652469 4293652469 4293652469 4293652469 4293652469 4293652469 4293455092 4293060849 4292074729 4288721616 4283265191 4287801545 0 0 0 0 4284185518 4286420927 4290233820 4291877352 4292468972 4292535021 4292535021 4292535021 4292534765 4292534765 4292534765 4292534765 4292535021 4292535021 4292535021 4292468972 4291877352 4290233820 4286420927 4284185518 0 0 0 0 4282476193 4288261581 4290759648 4291351268 4291680231 4291746023 4291811559 4291811559 4291746023 4291680231 4291680231 4291746023 4291811559 4291811559 4291746023 4291680231 4291351268 4290759648 4288261581 4282476193 0 0 0 0 4282673314 4289116371 4291614438 4292403180 4292797935 4292929264 4293060849 4292929264 4292995056 4293060849 4293060849 4292995056 4292929264 4293060849 4292929264 4292797935 4292403180 4291614438 4289116371 4282607522 0 0 0 0 4284645809 4288655823 4291746023 4293323763 4294244090 4294638589 4294507004 4294638589 4294572796 4294638589 4294638589 4294572796 4294638589 4294507004 4294638589 4294244090 4293323763 4291746023 4288655823 4284645809 0 0 0 0 4287669960 4284514224 4290891232 4293323763 4294704381 4294835710 4294901503 4294901503 4294901503 4294901503 4294901503 4294901503 4294901503 4294901503 4294835710 4294704381 4293323763 4290891232 4284514224 4287669960 0 0 0 0 4292600558 4286880962 4283988397 4288392910 4291285731 4292468972 4292600558 4292600558 4292600558 4292600558 4292600558 4292600558 4292600558 4292600558 4292732143 4291811559 4288392910 4283988397 4286880962 4292600558 0 0 0 0 4292535021 4292600558 4288524495 4284777138 4281884573 4281029782 4281161367 4281161367 4281161367 4281161367 4281161367 4281161367 4281161367 4281161367 4281029782 4282015902 4284777138 4288524495 4292600558 4292535021 0 0 0 0 0 4292403180 4292403180 4292534765 4292535021 4293060849 4293060849 4293060849 4293060849 4293060849 4293060849 4293060849 4293060849 4293060849 4292797935 4292535021 4292534765 4292468972 4292403180 0 0 0 0 0 0 0 4292206058 4292535021 4292600558 4292863472 4292863472 4292863472 4292863472 4292863472 4292863472 4292863472 4292863472 4292863472 4292929264 4292600558 4292535021 4292206058 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	offset: 0@0)
]

{ #category : #initialization }
UITheme >> newWindowMenuPassiveForm [
	"Answer a new form for a window menu box."

	^ self iconNamed: #windowMenuInactiveForm
]

{ #category : #initialization }
UITheme >> newWindowMinimizeForm [
	"Answer a new form for a window minimize box."

	^ self iconNamed: #windowMinimizeForm
]

{ #category : #initialization }
UITheme >> newWindowMinimizeOverForm [
	"Answer a new form for a window menu box."

	^ self newWindowMinimizeForm
]

{ #category : #'morph creation' }
UITheme >> newYesButtonIn: aThemedMorph for: aModel [
	"Answer a new Yes button."

	^(self
			newButtonIn: aThemedMorph
			for: aModel
			getState: nil
			action: #yes
			arguments: nil
			getEnabled: nil
			label: 'Yes' translated
			help: 'Answer yes and close the window' translated)
		hResizing: #rigid;
		vResizing: #rigid
]

{ #category : #private }
UITheme >> normalFillStyleFor: aMorph height: anInteger [
	"Return the normal button fillStyle for the given button."

	^ SolidFillStyle color: (self lightColorFor: aMorph)
]

{ #category : #private }
UITheme >> normalFillStyleWithBaseColor: aColor for: aMorph height: anInteger [	
	| top bottom |
	top := aColor darker.
	bottom := aColor.
	^(GradientFillStyle ramp: {
			0.0->top.
			0.7->bottom.})
		origin: aMorph bounds origin;
		direction: 0 @ anInteger;
		radial: false
]

{ #category : #accessing }
UITheme >> numberOfStepsForAnimations [
	^ self animationSettings numberOfSteps
]

{ #category : #cursor }
UITheme >> overTextCursorFor: aTextMorph [
	"Answer the pointer cursor when over an active text 
	(answer nil if no particular cursor is wanted)."

	^ Cursor overEditableText
]

{ #category : #'fill-styles' }
UITheme >> paneColorFor: aWindow [
	"Answer the pane color that should be used."

	^ (self fadedBackgroundWindows
		ifTrue: [ aWindow fillStyleToUse ]
		ifFalse: [ self windowActiveFillStyleFor: aWindow ]) asColor
]

{ #category : #services }
UITheme >> passwordEntryIn: aThemedMorph text: aStringOrText title: aString entryText: defaultEntryText [
	"Answer the result of a password entry dialog (a string or nil if cancelled)
	with the given label and title."

	^((PasswordDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: aStringOrText;
			entryText: defaultEntryText) openModal entryText
]

{ #category : #'basic-colors' }
UITheme >> patchworkUIThemeColorFor: aWindowOrModel [
	"Answer the colour for the given window."
	^ self settings windowColor
]

{ #category : #'border-styles' }
UITheme >> plainGroupPanelBorderStyleFor: aGroupPanel [
	"Answer the normal border style for a plain group panel."

	^SimpleBorderStyle new
		width: 1;
		baseColor: Color transparent
]

{ #category : #copying }
UITheme >> postCopy [
	"Copy the settings too."
	
	super postCopy.
	self settings: self settings copy
]

{ #category : #'fill-styles' }
UITheme >> preferGradientFill [
	^ self settings preferGradientFill
]

{ #category : #services }
UITheme >> proceedIn: aThemedMorph text: aStringOrText title: aString [
	"Answer the result of a proceed dialog with the given label and title."

	self questionSound play.
	^((ProceedDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: aStringOrText) openModal cancelled not
]

{ #category : #'border-styles' }
UITheme >> progressBarBorderStyleFor: aProgressBar [
	"Return the progress bar borderStyle for the given progress bar."

	|c|
	c := self progressBarColorFor: aProgressBar.
	^BorderStyle simple
		width: 1;
		baseColor: c darker
]

{ #category : #'basic-colors' }
UITheme >> progressBarColorFor: aProgressBar [
	"Answer the colour for the given progress bar."

	^self settings progressBarColor
]

{ #category : #'fill-styles' }
UITheme >> progressBarFillStyleFor: aProgressBar [
	^ self basePassiveBackgroundColorFor: aProgressBar
]

{ #category : #'basic-colors' }
UITheme >> progressBarProgressColorFor: aProgressBar [
	"Answer the colour for the progress part of the given progress bar."

	^self settings progressBarProgressColor
]

{ #category : #'fill-styles' }
UITheme >> progressBarProgressFillStyleFor: aProgressBar [
	^ (self lightSelectionColorFor: aProgressBar)
]

{ #category : #'fill-styles' }
UITheme >> progressFillStyleFor: aProgress [
	"Return the progress fillStyle for the given progress morph."
	^ self windowActiveFillStyleFor: aProgress  
]

{ #category : #services }
UITheme >> questionIn: aThemedMorph text: aStringOrText title: aString [
	"Answer the result of a question dialog with the given label and title."

	self questionSound play.
	^((QuestionDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: aStringOrText) openModal answer
]

{ #category : #sounds }
UITheme >> questionSound [
	"Answer the question sound."

	^self soundTheme questionSound
]

{ #category : #services }
UITheme >> questionWithoutCancelIn: aThemedMorph text: aStringOrText title: aString [
	"Answer the result of a question dialog with the given label and title."

	self questionSound play.
	^((QuestionWithoutCancelDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: aStringOrText) openModal answer
]

{ #category : #'border-styles-buttons' }
UITheme >> radioButtonCornerStyleFor: aRadioButton [
	"Answer the corner style for radio buttons.
	Answer square when not disabled since the form is rounded."
	
	^aRadioButton enabled
		ifTrue: [#square]
		ifFalse: [#rounded]
]

{ #category : #'border-styles-buttons' }
UITheme >> radioButtonDisabledBorderStyleFor: aRadioButton [
	"Return the disabled radio button borderStyle for the given button."

	^self checkboxButtonDisabledBorderStyleFor: aRadioButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> radioButtonDisabledFillStyleFor: aRadioButton [
	"Return the disabled radio button fillStyle for the given button."
	
	^self radioButtonNormalFillStyleFor: aRadioButton
]

{ #category : #'fill-styles' }
UITheme >> radioButtonForm [
	"Answer the form to use for a normal radio button."

	^ self iconNamed: #radioButtonUnselectedForm
]

{ #category : #'label-styles' }
UITheme >> radioButtonMarkerForm [
	"Answer the form to use for a radio button marker."

	^(self forms at: #radioButtonMarker ifAbsent: [Form extent: 12@12 depth: Display depth]) scaledByDisplayScaleFactor
]

{ #category : #'border-styles-buttons' }
UITheme >> radioButtonNormalBorderStyleFor: aRadioButton [
	"Return the disabled radio button borderStyle for the given button."

	^self checkboxButtonNormalBorderStyleFor: aRadioButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> radioButtonNormalFillStyleFor: aRadioButton [
	"Return the normal radio button fillStyle for the given button."
	
	^(ImageFillStyle form: self radioButtonForm) origin: aRadioButton topLeft
]

{ #category : #'border-styles-buttons' }
UITheme >> radioButtonSelectedBorderStyleFor: aRadioButton [
	"Return the selected radio button borderStyle for the given button."

	^self radioButtonNormalBorderStyleFor: aRadioButton
]

{ #category : #'border-styles-buttons' }
UITheme >> radioButtonSelectedDisabledBorderStyleFor: aRadioButton [
	"Return the selecteddisabled radio button borderStyle for the given button."

	^self radioButtonDisabledBorderStyleFor: aRadioButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> radioButtonSelectedDisabledFillStyleFor: aRadioButton [
	"Return the selected disabled radio button fillStyle for the given button."
	
	^self radioButtonNormalFillStyleFor: aRadioButton
]

{ #category : #'fill-styles-buttons' }
UITheme >> radioButtonSelectedFillStyleFor: aRadioButton [
	"Return the selected radio button fillStyle for the given button."
	
	^(ImageFillStyle form: self radioButtonSelectedForm) origin: aRadioButton topLeft
]

{ #category : #'fill-styles' }
UITheme >> radioButtonSelectedForm [
	"Answer the form to use for a selected radio button."

	^ self iconNamed: #radioButtonSelectedForm
]

{ #category : #'fill-styles' }
UITheme >> resizerGripNormalFillStyleFor: aResizer [
	"Return the normal fillStyle for the given resizer.
	For the moment, answer a transparent colour for no drawing,
	non transparent to draw as normal."
	
	^Color transparent
]

{ #category : #scrollbars }
UITheme >> scrollBarButtonArrowVertices: aRectangle [ 
	^ self verticesForComplexArrow: aRectangle
]

{ #category : #'morph creation' }
UITheme >> scrollBarDownButtonBoundsFor: aScrollbar [
	
	| extent position |
	
	extent := aScrollbar buttonExtent.
	position := aScrollbar innerBounds bottomRight - extent.	

	^ position extent: extent
]

{ #category : #'morph creation' }
UITheme >> scrollBarUpButtonBoundsFor: aScrollbar [
	^ aScrollbar innerBounds topLeft extent: aScrollbar buttonExtent
]

{ #category : #'border-styles' }
UITheme >> scrollPaneDisabledBorderStyleFor: aScrollPane [
	"Return the disabled borderStyle for the given scroll pane."

	^self scrollPaneNormalBorderStyleFor: aScrollPane
]

{ #category : #'border-styles' }
UITheme >> scrollPaneNormalBorderStyleFor: aScrollPane [
	"Return the normal borderStyle for the given scroll pane."

	^BorderStyle simple
		width: 1;
		baseColor: aScrollPane paneColor
]

{ #category : #'label-styles' }
UITheme >> scrollbarArrowOfDirection: aSymbol size: finalSizeInteger color: aColor [
	"Answer a new scrollbar arrow form (normally cached by Scrollbar)."
	
	^self basicCreateArrowOfDirection: aSymbol size: finalSizeInteger color: aColor
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarButtonCornerStyleIn: aThemedMorph [
	"Allow for themes to override default behaviour."
	
	^#square
]

{ #category : #'accessing - colors' }
UITheme >> scrollbarColor [
	^ self settings scrollbarColor
]

{ #category : #'basic-colors' }
UITheme >> scrollbarColorFor: aScrollbar [
	"Answer the colour for the given scrollbar."

	^self settings standardColorsOnly
		ifTrue: [self settings scrollbarColor]
		ifFalse: [aScrollbar lastPaneColor
					 ifNil: [Color white]]
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarImageColorFor: aScrollbar [
	"Return the scrollbar image colour (on buttons) for the given scrollbar."
	
	^(self baseScrollbarColorFor: aScrollbar) darker
]

{ #category : #defaults }
UITheme >> scrollbarMinimumThumbThickness [
	"Answer the minumum width or height of a scrollbar thumb 
	as appropriate to its orientation."
	
	^15 * self displayScaleFactor
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarMouseOverBarButtonBorderStyleFor: aScrollbar [
	"Return the button borderStyle for the given scrollbar when
	the mouse is over the bar."

	^self scrollbarNormalButtonBorderStyleFor: aScrollbar
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarMouseOverBarButtonFillStyleFor: aScrollbar [
	"Return the button fillStyle for the given scrollbar when
	the mouse is over the bar."

	^self scrollbarNormalButtonFillStyleFor: aScrollbar
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarMouseOverBarThumbBorderStyleFor: aScrollbar [
	"Return the thumb borderStyle for the given scrollbar when
	the mouse is over the bar."

	^self scrollbarNormalThumbBorderStyleFor: aScrollbar
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarMouseOverBarThumbFillStyleFor: aScrollbar [
	"Return the thumb fillStyle for the given scrollbar when
	the mouse is over the bar."

	^self scrollbarNormalThumbFillStyleFor: aScrollbar
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarMouseOverBorderStyleFor: aScrollbar [
	"Return the mouse over borderStyle for the given scrollbar."

	^self scrollbarNormalBorderStyleFor: aScrollbar
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarMouseOverButtonBorderStyleFor: aScrollbar [
	"Return the mouse over button borderStyle for the given scrollbar."

	^self scrollbarNormalButtonBorderStyleFor: aScrollbar
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarMouseOverButtonFillStyleFor: aScrollbar [
	"Return the scrollbar mouse over button fillStyle for the given color."

	^self scrollbarNormalButtonFillStyleFor: aScrollbar
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarMouseOverFillStyleFor: aScrollbar [
	"Return the scrollbar mouse over fillStyle for the given color."

	^self scrollbarNormalFillStyleFor: aScrollbar
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarMouseOverThumbBorderStyleFor: aScrollbar [
	"Return the mouse over thumb borderStyle for the given scrollbar."

	^self scrollbarNormalThumbBorderStyleFor: aScrollbar
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarMouseOverThumbButtonBorderStyleFor: aScrollbar [
	"Return the button borderStyle for the given scrollbar when
	the mouse is over the thumb."

	^self scrollbarMouseOverBarButtonBorderStyleFor: aScrollbar
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarMouseOverThumbButtonFillStyleFor: aScrollbar [
	"Return the button fillStyle for the given scrollbar when
	the mouse is over the thumb."

	^self scrollbarMouseOverBarButtonFillStyleFor: aScrollbar
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarMouseOverThumbFillStyleFor: aScrollbar [
	"Return the scrollbar mouse over thumb fillStyle for the given color."

	^self scrollbarNormalThumbFillStyleFor: aScrollbar
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarNormalBorderStyleFor: aScrollbar [
	"Return the normal button borderStyle for the given scrollbar."

	^BorderStyle simple
		width: 0;
		baseColor: Color transparent
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarNormalButtonBorderStyleFor: aScrollbar [
	"Return the normal button borderStyle for the given scrollbar."

	^BorderStyle simple
		width: 0
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarNormalButtonFillStyleFor: aScrollbar [
	"Return the normal scrollbar button fillStyle for the given scrollbar."
	
	^ self scrollbarNormalThumbFillStyleFor: aScrollbar
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarNormalFillStyleFor: aScrollbar [
	"Return the normal scrollbar fillStyle for the given scrollbar."
	
	^ "(self glamorousBaseColorFor: aScrollbar) muchLighter"
	Color r: 245 g: 245 b: 245 range: 255
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarNormalHorizontalThumbFillStyleFor: aScrollbar [
	"Return the normal scrollbar horizontal thumb fillStyle for the given scrollbar."
	
	|s l m r|
	s := aScrollbar slider.
	l := self scrollbarThumbLeftForm.
	m := self scrollbarThumbHorizontalMiddleForm.
	r := self scrollbarThumbRightForm.
	^CompositeFillStyle fillStyles: {
		(ImageFillStyle form: l) origin: s topLeft.
		(AlphaInfiniteForm with: m)
			origin: s topLeft + (l width@0);
			extent: (s width - l width - r width)@m height.
		(ImageFillStyle form: r)
			origin: s topRight - (r width@0)}
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarNormalThumbBorderStyleFor: aScrollbar [
	"Return the normal thumb borderStyle for the given scrollbar."

	^ BorderStyle simple
		width: 1;
		baseColor: Color transparent
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarNormalThumbFillStyleFor: aScrollbar [
	"Return the normal scrollbar fillStyle for the given scrollbar."
	^ self normalFillStyleFor: aScrollbar height: aScrollbar height
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarNormalVerticalThumbFillStyleFor: aScrollbar [
	"Return the normal scrollbar vertical thumb fillStyle for the given scrollbar."
	
	|s t m b|
	s := aScrollbar slider.
	t := self scrollbarThumbTopForm.
	m := self scrollbarThumbVerticalMiddleForm.
	b := self scrollbarThumbBottomForm.
	^CompositeFillStyle fillStyles: {
		(ImageFillStyle form: t) origin: s topLeft.
		(AlphaInfiniteForm with: m)
			origin: s topLeft + (0@t height);
			extent: m width@(s height - t height - b height).
		(ImageFillStyle form: b)
			origin: s bottomLeft - (0@b height)}
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarPagingAreaCornerStyleIn: aThemedMorph [	
	^#square
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarPressedBorderStyleFor: aScrollbar [
	"Return the pressed borderStyle for the given scrollbar."

	^self scrollbarNormalBorderStyleFor: aScrollbar
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarPressedButtonBorderStyleFor: aScrollbar [
	"Return the pressed button borderStyle for the given scrollbar."
	^ self scrollbarNormalButtonBorderStyleFor: aScrollbar
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarPressedButtonFillStyleFor: aScrollbar [
	"Return the pressed scrollbar button fillStyle for the given scrollbar."
	
	^self scrollbarPressedThumbFillStyleFor: aScrollbar
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarPressedFillStyleFor: aScrollbar [
	"Return the pressed scrollbar fillStyle for the given scrollbar."
	
	^self scrollbarNormalFillStyleFor: aScrollbar 
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarPressedThumbBorderStyleFor: aScrollbar [
	"Return the pressed thumb borderStyle for the given scrollbar."

	^self scrollbarNormalThumbBorderStyleFor: aScrollbar
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> scrollbarPressedThumbFillStyleFor: aScrollbar [
	"Return the pressed scrollbar thumb fillStyle for the given scrollbar."
	
	^self scrollbarNormalThumbFillStyleFor: aScrollbar
]

{ #category : #defaults }
UITheme >> scrollbarThickness [
	"Answer the width or height of a scrollbar as appropriate to
	its orientation."
	
	^13 * self displayScaleFactor
]

{ #category : #'fill-styles' }
UITheme >> scrollbarThumbBottomForm [
	"Answer the form to use for the bottom of a vertical scrollbar."

	^self forms at: #sbVThumbBottom ifAbsent: [Form extent: 13@7 depth: Display depth]
]

{ #category : #'border-styles-scrollbars' }
UITheme >> scrollbarThumbCornerStyleIn: aThemedMorph [
	"Allow for themes to override default behaviour."
	
	^#square
]

{ #category : #'fill-styles' }
UITheme >> scrollbarThumbHorizontalMiddleForm [
	"Answer the form to use for the middle of a horizontal scrollbar."

	^self forms at: #sbHThumbMiddle ifAbsent: [Form extent: 1@13 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> scrollbarThumbLeftForm [
	"Answer the form to use for the left of a horizontal scrollbar."

	^self forms at: #sbHThumbLeft ifAbsent: [Form extent: 7@13 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> scrollbarThumbRightForm [
	"Answer the form to use for the right of a horizontal scrollbar."

	^self forms at: #sbHThumbRight ifAbsent: [Form extent: 7@13 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> scrollbarThumbTopForm [
	"Answer the form to use for the top of a vertical scrollbar."

	^self forms at: #sbVThumbTop ifAbsent: [Form extent: 13@7 depth: Display depth]
]

{ #category : #'fill-styles' }
UITheme >> scrollbarThumbVerticalMiddleForm [
	"Answer the form to use for the middle of a vertical scrollbar."

	^self forms at: #sbVThumbMiddle ifAbsent: [Form extent: 13@1 depth: Display depth]
]

{ #category : #'accessing - colors' }
UITheme >> secondarySelectionColor [
	^ Color r: 0.927 g: 0.962 b: 0.995 alpha: 1.0
]

{ #category : #private }
UITheme >> selectedFillStyleFor: aMorph height: anInteger [
	

	^ SolidFillStyle color: (self lightSelectionColorFor:  aMorph)

]

{ #category : #'accessing - colors' }
UITheme >> selectedItemListTextColor [
	"Answer the color for the selected item in a list text."

	^ self textColor
]

{ #category : #'accessing - colors' }
UITheme >> selectionBarColor [

	^ self settings selectionBarColor


]

{ #category : #'accessing - colors' }
UITheme >> selectionColor [
	"Answer the selection color to use.."

	^ self settings selectionColor
]

{ #category : #defaults }
UITheme >> selectionColorForFrame: frame [ 

	^ self selectionColor
]

{ #category : #'accessing - colors' }
UITheme >> selectionTextColor [
 ^ self settings selectionTextColor
]

{ #category : #'fill-styles' }
UITheme >> separatorFillStyleFor: aSeparator [
	"Return the separator fillStyle for the given separator."
	
	^ SolidFillStyle color: (self baseColorFor: aSeparator) darker
]

{ #category : #defaults }
UITheme >> setSystemProgressMorphDefaultParameters: aProgressMorph [
	"Set up the given progress morph."
	aProgressMorph color: self settings derivedMenuColor.
	self settings preferRoundCorner
		ifTrue: [aProgressMorph useRoundedCorners].
	aProgressMorph borderWidth: self menuBorderWidth * self displayScaleFactor.
	aProgressMorph borderColor: self menuBorderColor.
	aProgressMorph updateColor.
]

{ #category : #accessing }
UITheme >> settings [
	"Answer the value of settings"

	^ settings
]

{ #category : #accessing }
UITheme >> settings: anObject [
	"Set the value of settings"

	settings := anObject
]

{ #category : #accessing }
UITheme >> shStyleTable [

	"Styling depends on shout. If it is not present, means there is no style 
	 table to apply"
	^ (self class environment classNamed: #SHRBTextStyler)
		ifNotNil: [ :aClass | aClass perform: self shStyleTableName ]
		ifNil: [ #() ]

]

{ #category : #accessing }
UITheme >> shStyleTableName [

	^ #blueStyleTable
]

{ #category : #testing }
UITheme >> shouldUseAnimations [
	^ self animationSettings useAnimation
]

{ #category : #'border-styles' }
UITheme >> sliderDisabledBorderStyleFor: aSlider [
	"Return the disabled slider borderStyle for the given text editor."

	^self sliderNormalBorderStyleFor: aSlider
]

{ #category : #'fill-styles' }
UITheme >> sliderDisabledFillStyleFor: aSlider [
	"Return the disabled fillStyle for the given slider."
	
	^ self textEditorDisabledFillStyleFor: aSlider
]

{ #category : #'border-styles' }
UITheme >> sliderNormalBorderStyleFor: aSlider [
	"Return the normal slider borderStyle for the given text editor."

	^BorderStyle inset
		width: 1;
		baseColor: aSlider paneColor twiceDarker
]

{ #category : #'fill-styles' }
UITheme >> sliderNormalFillStyleFor: aSlider [
	"Return the normal fillStyle for the given slider."
	
	^ SolidFillStyle color: Color white
]

{ #category : #accessing }
UITheme >> soundTheme [
	"Answer the sound theme to use, if not specified
	use the default sound theme."

	^soundTheme ifNil: [self defaultSoundTheme]
]

{ #category : #accessing }
UITheme >> soundTheme: anObject [
	"Set the sound theme specific to this instance of ui theme,"

	soundTheme := anObject
]

{ #category : #'fill-styles' }
UITheme >> splitterNormalFillStyleFor: aSplitter [
	"Return the normal splitter fillStyle for the given splitter."
	
	^ SolidFillStyle color: Color transparent
]

{ #category : #'fill-styles' }
UITheme >> splitterPressedFillStyleFor: aSplitter [
	"Return the pressed splitter fillStyle for the given splitter."
	
	|aColor|
	aColor := self baseColorFor: aSplitter.
	^ (GradientFillStyle ramp: {0.0->aColor lighter. 0.9-> aColor})
		origin: aSplitter topLeft;
		direction: (aSplitter splitsTopAndBottom
			ifTrue: [0 @ aSplitter height]
			ifFalse: [aSplitter width @ 0]);
		radial: false
]

{ #category : #'accessing - colors' }
UITheme >> spotlightWindowColor [ 
	^ self selectionColor muchDarker
]

{ #category : #defaults }
UITheme >> statusFont [
	"Answer the status font to use."

	^((TextStyle named: #BitstreamVeraSansMono) ifNil: [TextStyle default])
		fontOfPointSize: 8
]

{ #category : #'basic-colors' }
UITheme >> subgroupColorFrom: paneColor [
	"Answer the colour for a subgroup given the pane colour."

	^ self lightColorFor: paneColor" self class baseColor"
]

{ #category : #'accessing - colors' }
UITheme >> successBackgroundColor [
	^ self successTextColor lighter lighter
]

{ #category : #'accessing - colors' }
UITheme >> successTextColor [
	^ Color r: 0 g: 0.5 b: 0
]

{ #category : #'border-styles' }
UITheme >> tabGroupCornerStyleIn: aThemedMorph [
	"Allow for themes to override default behaviour."
	
	^aThemedMorph
		ifNil: [#square]
		ifNotNil: [:tm | tm preferredCornerStyle]
]

{ #category : #defaults }
UITheme >> tabLabelInsetFor: aButton [
	"Answer the inset to use for a tab label."
	^ Margin left: 8 top: 2 right: 8 bottom: 2

]

{ #category : #'border-styles' }
UITheme >> tabLabelNormalBorderStyleFor: aTabLabel [
"	^SimpleBorder new
		width: 0;
		baseColor: (self buttonBaseColorFor: aTabLabel) darker
"	^ self buttonNormalBorderStyleFor: aTabLabel
]

{ #category : #'fill-styles-buttons' }
UITheme >> tabLabelNormalFillStyleFor: aTabLabel [
	^ self buttonNormalFillStyleFor: aTabLabel 
]

{ #category : #'border-styles' }
UITheme >> tabLabelSelectedBorderStyleFor: aTabLabel [
	"Answer the selected border style for a tab label."

	^self tabLabelNormalBorderStyleFor: aTabLabel
]

{ #category : #'fill-styles-buttons' }
UITheme >> tabLabelSelectedFillStyleFor: aTabLabel [
	^ self buttonSelectedFillStyleFor: aTabLabel 
]

{ #category : #'border-styles' }
UITheme >> tabPanelBorderStyleFor: aTabGroup [
	^ Pharo3TabPanelBorderStyle new 
		width: 1;
		baseColor: ((self darkBaseColorFor: aTabGroup));
		tabSelector: aTabGroup tabSelectorMorph
]

{ #category : #defaults }
UITheme >> tabSelectorCellInsetFor: aTabSelector [
	"Answer the cell inset to use for the given tab selector."

	^0
]

{ #category : #defaults }
UITheme >> tabSelectorMorphMinExtentFor: aTabSelectorMorph [
	"Answer the min extent of the given tab selector."
	
	^aTabSelectorMorph basicMinExtent + (8 @ 1)
]

{ #category : #'fill-styles' }
UITheme >> taskListFillStyleFor: aTasklist [
	
	| aColor result |
	aColor := aTasklist color.
	result := GradientFillStyle ramp: {
			0.0->aColor whiter whiter. 0.2->aColor lighter.
			0.8->aColor darker. 1.0->aColor blacker}.
	^ result		
		origin: aTasklist topLeft;
		direction: 0 @ aTasklist height;
		radial: false;
		yourself.
]

{ #category : #'basic-colors' }
UITheme >> taskbarActiveButtonColorFor: aButton [
	"Answer the colour for the given active taskbar button."

	^self scrollbarColor alphaMixed: 0.7 with: Color white
]

{ #category : #'basic-colors' }
UITheme >> taskbarButtonColorFor: aButton [
	"Answer the colour for the given taskbar button." 
	^ self windowColorFor: aButton model
]

{ #category : #'basic-colors' }
UITheme >> taskbarButtonLabelColorFor: aButton [
	"Answer the colour for the label of the given taskbar button."

	^aButton model
		ifNil: [super taskbarButtonLabelColorFor: aButton]
		ifNotNil: [:win |
			win isActive
				ifTrue: [Color black]
				ifFalse: [Color gray darker]]
]

{ #category : #'fill-styles-taskbar' }
UITheme >> taskbarFillStyleFor: aTaskbar [
	^ SolidFillStyle color: Color transparent 
]

{ #category : #'border-styles-taskbar' }
UITheme >> taskbarItemDisabledBorderStyleFor: aButton [
	"Return the disabled taskbar item borderStyle for the given button."

	^ self buttonDisabledBorderStyleFor: aButton
]

{ #category : #'fill-styles-taskbar' }
UITheme >> taskbarItemDisabledFillStyleFor: aButton [
	"Return the disabled taskbar item fillStyle for the given color."

	^ self buttonDisabledFillStyleFor: aButton
]

{ #category : #'basic-colors' }
UITheme >> taskbarItemLabelColorForCollapsed: aButton [
	"Answer the colour for the label of the given taskbar button, given that the corresponding window is collapsed."
	
	^Color darkGray
]

{ #category : #'basic-colors' }
UITheme >> taskbarItemLabelColorForExpanded: aButton [
	"Answer the colour for the label of the given taskbar button, given that the corresponding window is collapsed."
	
	^ Color black
]

{ #category : #'border-styles-taskbar' }
UITheme >> taskbarItemMouseOverBorderStyleFor: aButton [
	"Return the mouse over taskbar item borderStyle for the given button."
	
	^ self buttonMouseOverBorderStyleFor: aButton
]

{ #category : #'fill-styles-taskbar' }
UITheme >> taskbarItemMouseOverFillStyleFor: aButton [
	"Return the taskbar item mouse over fillStyle for the given color."

	^ self buttonMouseOverFillStyleFor: aButton
]

{ #category : #'border-styles-taskbar' }
UITheme >> taskbarItemNormalBorderStyleFor: aButton [
	"Return the normal taskbar item borderStyle for the given button."

	^ self buttonNormalBorderStyleFor: aButton
]

{ #category : #'fill-styles-taskbar' }
UITheme >> taskbarItemNormalFillStyleFor: aButton [
	"Return the normal taskbar item fillStyle for the given button."
	
	^ self buttonNormalFillStyleFor: aButton
]

{ #category : #'border-styles-taskbar' }
UITheme >> taskbarItemPressedBorderStyleFor: aButton [
	"Return the pressed taskbar item borderStyle for the given button."

	^ self buttonPressedBorderStyleFor: aButton
]

{ #category : #'fill-styles-taskbar' }
UITheme >> taskbarItemPressedFillStyleFor: aButton [
	"Return the taskbar item pressed fillStyle for the given button."
		
	^ self buttonPressedFillStyleFor: aButton
]

{ #category : #'border-styles-taskbar' }
UITheme >> taskbarItemSelectedBorderStyleFor: aButton [
	"Return the selected taskbar item borderStyle for the given button."

	^ self buttonSelectedBorderStyleFor: aButton
]

{ #category : #'border-styles-taskbar' }
UITheme >> taskbarItemSelectedDisabledBorderStyleFor: aButton [
	"Return the selecteddisabled taskbar item borderStyle for the given button."

	^ self buttonSelectedDisabledBorderStyleFor: aButton
]

{ #category : #'fill-styles-taskbar' }
UITheme >> taskbarItemSelectedDisabledFillStyleFor: aButton [
	"Return the taskbar item selected disabled fillStyle for the given color."
	
	^ self buttonSelectedDisabledFillStyleFor: aButton
]

{ #category : #'fill-styles-taskbar' }
UITheme >> taskbarItemSelectedFillStyleFor: aButton [
	"Return the taskbar item button fillStyle for the given button."
	
	^ self buttonSelectedFillStyleFor: aButton
]

{ #category : #'border-styles-taskbar' }
UITheme >> taskbarItemSelectedMouseOverBorderStyleFor: aButton [
	"Return the selected mouse over taskbar item borderStyle for the given button."

	^ self buttonSelectedMouseOverBorderStyleFor: aButton
]

{ #category : #'fill-styles-taskbar' }
UITheme >> taskbarItemSelectedMouseOverFillStyleFor: aButton [
	"Return the taskbar item selected mouse over fillStyle for the given color."
	
	^ self buttonSelectedMouseOverFillStyleFor: aButton
]

{ #category : #'border-styles-taskbar' }
UITheme >> taskbarItemSelectedPressedBorderStyleFor: aButton [
	"Return the selected pressed taskbar item borderStyle for the given button."

	^ self buttonSelectedPressedBorderStyleFor: aButton
]

{ #category : #'fill-styles-taskbar' }
UITheme >> taskbarItemSelectedPressedFillStyleFor: aButton [
	"Return the taskbar item selected pressed fillStyle for the given color."

	^ self buttonSelectedPressedFillStyleFor: aButton
]

{ #category : #'basic-colors' }
UITheme >> taskbarMinimizedButtonColorFor: aButton [
	"Answer the colour for the given minimized taskbar button."

	^Color transparent
]

{ #category : #'border-styles' }
UITheme >> taskbarThumbnailCornerStyleFor: aMorph [
	"Answer the corner style for the taskbar thumbnail/tasklist."
	
	^#square
]

{ #category : #'border-styles' }
UITheme >> taskbarThumbnailNormalBorderStyleFor: aWindow [
	^ self buttonNormalBorderStyleFor: aWindow
]

{ #category : #'accessing - colors' }
UITheme >> textColor [ 
	^ Color black
]

{ #category : #'accessing - colors' }
UITheme >> textColorForNonStandardBackground [
	^ self textColor
]

{ #category : #'border-styles' }
UITheme >> textEditorDisabledBorderStyleFor: aTextEditor [
	"Return the disabled text editor borderStyle for the given text editor."

	^self textEditorNormalBorderStyleFor: aTextEditor
]

{ #category : #'fill-styles' }
UITheme >> textEditorDisabledFillStyleFor: aTextEditor [
	"Return the disabled fillStyle for the given text editor."
	
	^self basePassiveBackgroundColorFor: aTextEditor
]

{ #category : #services }
UITheme >> textEditorIn: aThemedMorph text: aStringOrText title: aString entryText: defaultEntryText [
	"Answer the result of a text editor (multiline) dialog ( a string or nil if cancelled)
	with the given label and title."

	^self
		textEditorIn: aThemedMorph
		text: aStringOrText
		title: aString
		entryText: defaultEntryText
		entryHeight: 64
]

{ #category : #services }
UITheme >> textEditorIn: aThemedMorph text: aStringOrText title: aString entryText: defaultEntryText entryHeight: entryHeight [
	"Answer the result of a text editor (multiline) dialog ( a string or nil if cancelled)
	with the given label and title."

	self questionSound play.
	^((TextEditorDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: aStringOrText;
			entryText: defaultEntryText;
			entryHeight: entryHeight) openModal entryText
]

{ #category : #'border-styles' }
UITheme >> textEditorNormalBorderStyleFor: aTextEditor [
	"Return the normal text editor borderStyle for the given text editor."

	^self buttonNormalBorderStyleFor: aTextEditor
]

{ #category : #'fill-styles' }
UITheme >> textEditorNormalFillStyleFor: aTextEditor [
	"Return the normal fillStyle for the given text editor."
	
	^Color white
]

{ #category : #'border-styles-buttons' }
UITheme >> textEntryCornerStyleIn: aThemedMorph [
	"Answer the corner style to use for text entry morphs."
	
	^#square
]

{ #category : #services }
UITheme >> textEntryIn: aThemedMorph text: aStringOrText title: aString entryText: defaultEntryText [
	"Answer the result of a text entry dialog ( a string or nil if cancelled)
	with the given label and title."

	self questionSound play.
	^(TextEntryDialogWindow new
			textFont: self textFont;
			title: aString;
			text: aStringOrText;
			entryText: defaultEntryText) openModal entryText
]

{ #category : #services }
UITheme >> textEntryIn: aThemedMorph text: aStringOrText title: aString entryText: defaultEntryText entryCompletion: anEntryCompletion [
	"Answer the result of a text entry dialog ( a string or nil if cancelled)
	with the given label and title."

	self questionSound play.
	^((TextEntryDialogWindow newWithTheme: aThemedMorph theme)
			textFont: self textFont;
			title: aString;
			text: aStringOrText;
			entryText: defaultEntryText;
			entryCompletion: anEntryCompletion) openModal entryText
]

{ #category : #'border-styles' }
UITheme >> textFieldDisabledBorderStyleFor: aTextField [
	"Return the disabled text field borderStyle for the given text field."

	^self textEditorDisabledBorderStyleFor: aTextField
]

{ #category : #'fill-styles' }
UITheme >> textFieldDisabledFillStyleFor: aTextField [
	"Return the disabled fillStyle for the given text field."
	
	^self textEditorDisabledFillStyleFor: aTextField
]

{ #category : #'border-styles' }
UITheme >> textFieldNormalBorderStyleFor: aTextField [
	"Return the normal text field borderStyle for the given text field."

	^self textEditorNormalBorderStyleFor: aTextField
]

{ #category : #'fill-styles' }
UITheme >> textFieldNormalFillStyleFor: aTextField [
	"Return the normal fillStyle for the given text field."
	
	^ Color white
]

{ #category : #'border-styles' }
UITheme >> textFocusBoundsFor: aPluggableTextMorph [
	"Answer the bounds for drawing the focus indication."

	^aPluggableTextMorph bounds
]

{ #category : #defaults }
UITheme >> textFont [
	"Answer the text font to use."

	^StandardFonts defaultFont
]

{ #category : #'label-styles' }
UITheme >> treeExpandedForm [
	"Answer the form to use for an expanded tree item."

	^(self forms at: #treeExpanded ifAbsent: [Form extent: 10@9 depth: Display depth]) scaledByDisplayScaleFactor
]

{ #category : #'basic-colors' }
UITheme >> treeLineColorsFrom: aColor [
	"Answer the colours to use for the tree lines.
	The given colour is the preferred colour."

	^{aColor. Color transparent}
]

{ #category : #'basic-colors' }
UITheme >> treeLineDashes [
	"Answer the dash lengths to use for the tree lines."

	^#(1 1)
]

{ #category : #defaults }
UITheme >> treeLineWidth [
	"Answer the width of the tree lines."

	^0
]

{ #category : #'label-styles' }
UITheme >> treeUnexpandedForm [
	"Answer the form to use for an unexpanded tree item."

	^(self forms at: #treeUnexpanded ifAbsent: [Form extent: 10@9 depth: Display depth]) scaledByDisplayScaleFactor
]

{ #category : #'accessing - colors' }
UITheme >> unfocusedSelectionColor [
	^ self settings unfocusedSelectionColor
]

{ #category : #scrollbars }
UITheme >> updateScrollBarButtonAspect: aMorph color: aColor [

	"update aMorph with aColor"

	aMorph ifNil: [ ^ self ].
	aMorph color: aColor
]

{ #category : #scrollbars }
UITheme >> updateScrollBarButtonsAspect: aCollection color: aColor [ 
	"update aCollection of morphs with aColor"
	
	
	aCollection
		do: [:each | self updateScrollBarButtonAspect: each color: aColor]
]

{ #category : #initialization }
UITheme >> updateWorldDockingBars [
	"Update the world docking bar gradients."
	
	self currentWorld mainDockingBars do: [:d |
		d
			color: (self worldMainDockingBarColorFor: d);
			gradientRamp: (self class current
				worldMainDockingBarNormalFillStyleFor: d) colorRamp;
			borderStyle: (self worldMainDockingBarBorderStyleFor: d)]
]

{ #category : #'accessing - colors' }
UITheme >> urlColor [
	^ Color fromHexString: '03A9F4'
]

{ #category : #accessing }
UITheme >> useAnimation: aBoolean [
	^ self animationSettings useAnimation: aBoolean
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> useScrollbarThumbShadow [
	"Answer whether a shadow morph should be displayed when
	dragging a scrollbar thumb."
	
	"If for some reason it's nil, reinitialice to 'false'."
	
	useScrollbarThumbShadow ifNil:[useScrollbarThumbShadow:=false].

	^useScrollbarThumbShadow
]

{ #category : #'fill-styles-scrollbars' }
UITheme >> useScrollbarThumbShadow: aBoolean [
	"Sets whether the scrollbar must show a shadow of the original position before dragging."

	useScrollbarThumbShadow := aBoolean.
]

{ #category : #scrollbars }
UITheme >> verticesForComplexArrow: aRectangle [ 
	"PRIVATE - answer a collection of vertices to draw a complex arrow"

	|r vertices aux b c|
	r := aRectangle origin extent: aRectangle width asPoint.
	aux := (r width / 5) rounded.
	b := (aux * aux * 2) sqrt.
	c := (b * b * 2) sqrt rounded.
	vertices := OrderedCollection new.
	vertices add: r bottomLeft - (0 @ aux).
	vertices add: r topCenter + (0 @ aux).
	vertices add: r bottomRight - (0 @ aux).
	vertices add: r bottomRight - (aux @ 0).
	vertices add: r topCenter + (0 @ (aux + c)).
	vertices add: r bottomLeft + (aux @ 0).
	^vertices
]

{ #category : #scrollbars }
UITheme >> verticesForSimpleArrow: aRectangle [ 
	"PRIVATE - answer a collection of vertices to draw a simple arrow"
	| vertices |
	vertices := OrderedCollection new.
	""
	vertices add: aRectangle bottomLeft.
	vertices add: aRectangle center x @ (aRectangle top + (aRectangle width / 8)).
	vertices add: aRectangle bottomRight.
	vertices add: aRectangle bottomRight + (0@0.01).
	""
	^ vertices
]

{ #category : #private }
UITheme >> veryLightFillStyleFor: aMorph height: anInteger [
	"Return the very light button fillStyle for the given button."
	
	^ SolidFillStyle color: (self veryLightSelectionColorFor: aMorph)
]

{ #category : #private }
UITheme >> veryLightSelectionColorFor: aMorph [
	^ self class veryLightSelectionColor
]

{ #category : #'accessing - colors' }
UITheme >> warningBackgroundColor [
	^ Color yellow
]

{ #category : #'accessing - colors' }
UITheme >> warningTextColor [
	^ Color yellow muchDarker
]

{ #category : #'*Polymorph-Widgets-Themes' }
UITheme >> watcherWindowActiveFillStyleFor: aWindow [

	^ SolidFillStyle color: (Color veryVeryLightGray alpha: 0.6)
]

{ #category : #'*Polymorph-Widgets-Themes' }
UITheme >> watcherWindowInactiveFillStyleFor: aWindow [

	^ SolidFillStyle color: (Color veryVeryLightGray alpha: 0.6)
]

{ #category : #'label-styles' }
UITheme >> whiteTreeExpandedForm [
	"Answer the form to use for an expanded tree item when a contrasting one is needed."

	^ self forms 
		at: #whiteTreeExpanded 
		ifAbsent: [ | f |
			f := self treeExpandedForm deepCopy.
			f replaceColor: Color white withColor: Color transparent.
			(f colorsUsed reject: [:c | c isTransparent]) do: [:c | f replaceColor:  c withColor: c whiter whiter whiter whiter whiter whiter].
			self forms at: #whiteTreeExpanded put: f.
			self whiteTreeExpandedForm]
]

{ #category : #'label-styles' }
UITheme >> whiteTreeUnexpandedForm [
	"Answer the form to use for an unexpanded tree item when a contrasting one is needed."

	^ self forms 
		at: #whiteTreeUnexpanded
		ifAbsent: [ | f |
			f := self treeUnexpandedForm deepCopy.
			f replaceColor: Color white withColor: Color transparent.
			(f colorsUsed reject: [:c | c isTransparent]) do: [:c | f replaceColor:  c withColor: c whiter whiter whiter whiter whiter whiter].
			self forms at: #whiteTreeUnexpanded put: f.
			self whiteTreeUnexpandedForm]
]

{ #category : #'border-styles' }
UITheme >> windowActiveDropShadowOffsetRectangleFor: aSystemWindow [
	"Answer a rectangle describing the offsets for each corner
	of the the active window bounds for the drop shadow area."
	
	^self windowActiveDropShadowStyle == #diffuse
		ifTrue: [self windowDiffuseDropShadowOffsetRectangleFor: aSystemWindow]
		ifFalse: [self windowPlainDropShadowOffsetRectangleFor: aSystemWindow]
]

{ #category : #accessing }
UITheme >> windowActiveDropShadowStyle [
	"Answer the style of drop shadow to use for active windows."
	
	^windowActiveDropShadowStyle
]

{ #category : #accessing }
UITheme >> windowActiveDropShadowStyle: anObject [
	"Set the value of windowActiveDropShadowStyle"

	windowActiveDropShadowStyle := anObject
]

{ #category : #'fill-styles' }
UITheme >> windowActiveFillStyleFor: aWindow [
	"We do not want the lighting effect when the window goes inactive"
	^SolidFillStyle color: self class baseColor
]

{ #category : #'fill-styles' }
UITheme >> windowActiveLabelFillStyleFor: aWindow [
	"Return the window active label fillStyle for the given window."
	
	^Color black
]

{ #category : #'fill-styles' }
UITheme >> windowActiveTitleFillStyleFor: aWindow [
	^ SolidFillStyle color: Color transparent
]

{ #category : #defaults }
UITheme >> windowBorderWidthFor: aWindow [

	^ 4 * self displayScaleFactor
]

{ #category : #defaults }
UITheme >> windowBottomOffset [

	^ 0
]

{ #category : #'label-styles' }
UITheme >> windowCloseForm [
	"Answer the form to use for the close button of a window."

	^(self forms at: #windowClose ifAbsent: [Form extent: 10@10 depth: Display depth]) scaledByDisplayScaleFactor
]

{ #category : #'label-styles' }
UITheme >> windowCloseOverForm [
	"Answer the form to use for mouse over window close buttons"

	^(self forms at: #windowCloseOver ifAbsent: [Form extent: 16@16 depth: Display depth]) scaledByDisplayScaleFactor
]

{ #category : #'label-styles' }
UITheme >> windowClosePassiveForm [
	"Answer the form to use for passive (background) window close buttons"

	^ self iconNamed: #windowCloseInactiveForm
]

{ #category : #sounds }
UITheme >> windowCloseSound [
	"Answer the window close sound."

	^self soundTheme windowCloseSound
]

{ #category : #'morph creation' }
UITheme >> windowCollapseBoxLayoutFor: aWindow [

	^ LayoutFrame new 
		leftFraction: 1; 
		leftOffset: aWindow boxExtent x negated;
		yourself
]

{ #category : #'accessing - colors' }
UITheme >> windowColor [
	"Answer the window color to use."

	^self settings windowColor
]

{ #category : #'basic-colors' }
UITheme >> windowColorFor: aWindowOrModel [ 
	"Answer the colour for the given window."

	^ self settings windowColor
]

{ #category : #'border-styles' }
UITheme >> windowDiffuseDropShadowOffsetRectangleFor: aSystemWindow [
	"Answer a rectangle describing the offsets for each corner
	of the the active window bounds for the drop shadow area
	when the difuse style is used."
	
	^8@4 corner: 8@10
]

{ #category : #'fill-styles' }
UITheme >> windowEdgeNormalFillStyleFor: anEdgeGrip [
	"Return the normal window edge fillStyle for the given edge grip."
	
	^Color transparent
]

{ #category : #'fill-styles' }
UITheme >> windowEdgePressedFillStyleFor: anEdgeGrip [
	"Return the pressed window edge fillStyle for the given edge grip."
	
	^self windowEdgeNormalFillStyleFor: anEdgeGrip
]

{ #category : #'fill-styles' }
UITheme >> windowExtentChangedFor: aWindow [
	"Update any extent related visuals."

]

{ #category : #'border-styles' }
UITheme >> windowInactiveDropShadowOffsetRectangleFor: aSystemWindow [
	"Answer a rectangle describing the offsets for each corner
	of the the inactive window bounds for the drop shadow area."
	
	^self windowPlainDropShadowOffsetRectangleFor: aSystemWindow
]

{ #category : #'fill-styles' }
UITheme >> windowInactiveFillStyleFor: aWindow [
	"We do not want the lighting effect when the window goes inactive"
	^self windowActiveFillStyleFor: aWindow
]

{ #category : #'fill-styles' }
UITheme >> windowInactiveLabelFillStyleFor: aWindow [
	"Return the window inactive label fillStyle for the given window."
	
	^ self fadedBackgroundWindows
		ifTrue: [ aWindow paneColorToUse alphaMixed: 0.6 with: Color black ]
		ifFalse: [ self windowActiveLabelFillStyleFor: aWindow ]
]

{ #category : #'fill-styles' }
UITheme >> windowInactiveTitleFillStyleFor: aWindow [
	"We do not want the lighting effect when the window goes inactive"
	^ SolidFillStyle color: Color transparent
]

{ #category : #'label-styles' }
UITheme >> windowLabelFor: aWindow [
	"Answer the label to use for the given window."

	^self windowLabelForText: aWindow labelString
]

{ #category : #'label-styles' }
UITheme >> windowLabelForText: aTextOrString [
	"Answer the window label to use for the given text."
	^ LabelMorph new
		contents: aTextOrString;
		font: StandardFonts windowTitleFont emphasis: 0
]

{ #category : #defaults }
UITheme >> windowLeftOffset [

	^ 0
]

{ #category : #'label-styles' }
UITheme >> windowMaximizeForm [
	"Answer the form to use for the maximize button of a window."

	^(self forms at: #windowMaximize ifAbsent: [Form extent: 10@10 depth: Display depth]) scaledByDisplayScaleFactor
]

{ #category : #'label-styles' }
UITheme >> windowMaximizeOverForm [
	"Answer the form to use for mouse over window maximize buttons"

	^(self forms at: #windowMaximizeOver ifAbsent: [Form extent: 16@16 depth: Display depth]) scaledByDisplayScaleFactor
]

{ #category : #'label-styles' }
UITheme >> windowMaximizePassiveForm [
	"Answer the form to use for passive (background) window maximize/restore buttons"

	^ self iconNamed: #windowMaximizeInactiveForm
]

{ #category : #sounds }
UITheme >> windowMaximizeSound [
	"Answer the window maximize sound."

	^self soundTheme windowMaximizeSound
]

{ #category : #'label-styles' }
UITheme >> windowMenuForm [
	"Answer the form to use for the menu button of a window."

	^(self forms at: #windowMenu ifAbsent: [Form extent: 10@10 depth: Display depth]) scaledByDisplayScaleFactor
]

{ #category : #'label-styles' }
UITheme >> windowMenuIconFor: aWindow [
	"Answer the menu icon for the given window."
	
	^ self windowMenuForm
]

{ #category : #'label-styles' }
UITheme >> windowMenuOverForm [
	"Answer the form to use for mouse over window menu buttons"

	^(self forms at: #windowMenuOver ifAbsent: [Form extent: 16@16 depth: Display depth]) scaledByDisplayScaleFactor
]

{ #category : #'label-styles' }
UITheme >> windowMenuPassiveForm [
	"Answer the form to use for passive (background) window menu buttons"

	^self newWindowMenuPassiveForm
]

{ #category : #'label-styles' }
UITheme >> windowMinimizeForm [
	"Answer the form to use for the minimize button of a window."

	^(self forms at: #windowMinimize ifAbsent: [Form extent: 10@10 depth: Display depth]) scaledByDisplayScaleFactor
]

{ #category : #'label-styles' }
UITheme >> windowMinimizeOverForm [
	"Answer the form to use for mouse over window minimize buttons"

	^(self forms at: #windowMinimizeOver ifAbsent: [Form extent: 16@16 depth: Display depth]) scaledByDisplayScaleFactor
]

{ #category : #'label-styles' }
UITheme >> windowMinimizePassiveForm [
	"Answer the form to use for passive (background) window minimize buttons"

	^ self iconNamed: #windowMinimizeInactiveForm
]

{ #category : #sounds }
UITheme >> windowMinimizeSound [
	"Answer the window minimize sound."

	^self soundTheme windowMinimizeSound
]

{ #category : #sounds }
UITheme >> windowOpenSound [
	"Answer the window open sound."

	^self soundTheme windowOpenSound
]

{ #category : #'border-styles' }
UITheme >> windowPaneBorderStyleFor: aMorph in: aSystemWindow [
	"Answer the border style for a morph that is to be added
	as a pane in the given system window,"

	^BorderStyle simple
		color: aSystemWindow paneColor;
		width: (aMorph borderWidth = 0 ifTrue: [0] ifFalse: [1])
]

{ #category : #'border-styles' }
UITheme >> windowPlainDropShadowOffsetRectangleFor: aSystemWindow [
	"Answer a rectangle describing the offsets for each corner
	of the the active window bounds for the drop shadow area
	when the plain style is used."
	
	^aSystemWindow shadowOffset negated corner: aSystemWindow shadowOffset
]

{ #category : #defaults }
UITheme >> windowPreferredCornerStyleFor: aWindow [
	"Answer the preferred corner style for the given window."

	aWindow isEmbedded ifTrue: [^#square].
	^(self settings preferRoundCorner  or: [
			aWindow cornerStyle == #rounded])
		ifTrue: [#rounded]
		ifFalse: [#square]
]

{ #category : #sounds }
UITheme >> windowRestoreDownSound [
	"Answer the window restore down sound."

	^self soundTheme windowRestoreDownSound
]

{ #category : #sounds }
UITheme >> windowRestoreUpSound [
	"Answer the window restore up sound."

	^self soundTheme windowRestoreUpSound
]

{ #category : #defaults }
UITheme >> windowRightOffset [

	^ 0
]

{ #category : #'accessing - colors' }
UITheme >> windowShadowColor [
	"Answer the window shadow color to use."

	^ Color gray
]

{ #category : #defaults }
UITheme >> windowTopOffset [

	^ 0
]

{ #category : #'border-styles' }
UITheme >> worldMainDockingBarBorderStyleFor: aDockingBar [
	"Return the world main docking bar borderStyle for the given docking bar."

	^BorderStyle simple
		width: 0;
		color: Color transparent
]

{ #category : #'basic-colors' }
UITheme >> worldMainDockingBarColorFor: aDockingBar [
	"Answer the base colour to use for a world main docking bar in this theme."

	^self settings derivedMenuColor 
]

{ #category : #'fill-styles' }
UITheme >> worldMainDockingBarNormalFillStyleFor: aDockingBar [
	"Return the world main docking bar fillStyle for the given docking bar."
	
	|aColor|
	aColor := aDockingBar originalColor alpha: 0.7.
	^(GradientFillStyle ramp: {
			0.0->(aColor alphaMixed: 0.3 with: (Color white alpha: aColor alpha)).
			0.8->aColor darker.
			1.0->aColor darker duller})
		origin: aDockingBar topLeft;
		direction: (aDockingBar isVertical
			ifTrue: [aDockingBar width @ 0]
			ifFalse: [0 @ aDockingBar height]);
		radial: false
]
