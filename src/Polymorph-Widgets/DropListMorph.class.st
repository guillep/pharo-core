"
Displays a selected item and a drop button. When pressed will popup a list to enable changing of the selection. Supports enablement.
"
Class {
	#name : #DropListMorph,
	#superclass : #ModelMorphic,
	#traits : 'TEnableOnHaloMenu',
	#classTraits : 'TEnableOnHaloMenu classTrait',
	#instVars : [
		'contentMorph',
		'listMorph',
		'buttonMorph',
		'list',
		'listSelectionIndex',
		'getListSelector',
		'getIndexSelector',
		'setIndexSelector',
		'getEnabledSelector',
		'enabled',
		'useSelectionIndex',
		'wrapSelector'
	],
	#category : #'Polymorph-Widgets-Base'
}

{ #category : #'instance creation' }
DropListMorph class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel [
	"Answer a new instance of the receiver on the given model using
	the given selectors as the interface."

	^self new
		on: anObject 
		list: getListSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
]

{ #category : #'instance creation' }
DropListMorph class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel useIndex: useIndex [
	"Answer a new instance of the receiver on the given model using
	the given selectors as the interface."

	^self new
		useSelectionIndex: useIndex;
		on: anObject 
		list: getListSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
]

{ #category : #accessing }
DropListMorph >> adoptPaneColor: paneColor [
	"Pass on to the list morph and border too."
	
	super adoptPaneColor: paneColor.
	paneColor ifNil: [^self].
	self fillStyle: self fillStyleToUse.
	self borderWidth > 0 ifTrue: [
		self borderStyle: self borderStyleToUse].
	self buttonMorph cornerStyle: self cornerStyle.
	self updateContentColor: paneColor.
	self listPaneColor: paneColor.
	self changed: #buttonLabel
]

{ #category : #accessing }
DropListMorph >> allowKeyboardFocus [
	"Answer whether or not keyboard focus will be allowed."

	^self valueOfProperty: #allowKeyboardFocus ifAbsent: [true]
]

{ #category : #accessing }
DropListMorph >> allowKeyboardFocus: aBoolean [
	"Set whether or not keyboard focus will be allowed."

	self setProperty: #allowKeyboardFocus toValue: aBoolean
]

{ #category : #private }
DropListMorph >> borderStyleToUse [
	"Answer the borderStyle that should be used for the receiver."
	
	^self enabled
		ifTrue: [self theme dropListNormalBorderStyleFor: self]
		ifFalse: [self theme dropListDisabledBorderStyleFor: self]
]

{ #category : #private }
DropListMorph >> buttonExtent [
	"Answer based on theme and preferences."
	
	^self buttonWidth @ self buttonHeight
]

{ #category : #private }
DropListMorph >> buttonHeight [
	"Answer based on theme."
	
	^self theme buttonMinHeight
]

{ #category : #private }
DropListMorph >> buttonLabel [
	"Answer the label for the button."

	^self theme dropListButtonLabelFor: self
]

{ #category : #accessing }
DropListMorph >> buttonMorph [
	"Answer the value of buttonMorph"

	^ buttonMorph
]

{ #category : #accessing }
DropListMorph >> buttonMorph: anObject [
	"Set the value of buttonMorph"

	buttonMorph := anObject
]

{ #category : #private }
DropListMorph >> buttonWidth [
	"Answer based on scrollbar size."
	
	^ (self theme scrollbarThickness + 3)
		max: self theme dropListControlButtonWidth
]

{ #category : #accessing }
DropListMorph >> contentMorph [
	"Answer the value of contentMorph"

	^ contentMorph
]

{ #category : #accessing }
DropListMorph >> contentMorph: anObject [
	"Set the value of contentMorph"

	contentMorph := anObject
]

{ #category : #rounding }
DropListMorph >> cornerStyle: aSymbol [
	"Update the layout inset too."

	super cornerStyle: aSymbol.
	self layoutInset: self layoutInsetToUse.
	self buttonMorph cornerStyle: self cornerStyle.
	self fillStyle: self fillStyleToUse
]

{ #category : #initialization }
DropListMorph >> defaultColor [
	"Answer the default color of the receiver."

	^ self theme backgroundColor
]

{ #category : #private }
DropListMorph >> defaultContents [
	"needs nothing to activate the ghostText"
	^ ''
]

{ #category : #protocol }
DropListMorph >> disable [
	"Disable the receiver."
	
	self enabled: false
]

{ #category : #drawing }
DropListMorph >> drawSubmorphsOn: aCanvas [ 
	"Display submorphs back to front.
	Draw the focus here since we are using inset bounds
	for the focus rectangle."

	super drawSubmorphsOn: aCanvas.
	self hasKeyboardFocus ifTrue: [
		self drawKeyboardFocusOn: aCanvas]
]

{ #category : #protocol }
DropListMorph >> enable [
	"Enable the receiver."
	
	self enabled: true
]

{ #category : #accessing }
DropListMorph >> enabled [
	"Answer the value of enabled"

	^ enabled
]

{ #category : #accessing }
DropListMorph >> enabled: anObject [
	"Set the value of enabled"

	enabled = anObject ifTrue: [^self].
	enabled := anObject.
	anObject ifFalse: [self hideList].
	self changed: #enabled.
	self
		adoptPaneColor: self paneColor;
		changed
]

{ #category : #geometry }
DropListMorph >> extent: newExtent [
	"Update the gradient."
	
	super extent: newExtent.
	(self fillStyle notNil and: [self fillStyle isSolidFill not])
		ifTrue: [self fillStyle: self fillStyleToUse]
]

{ #category : #private }
DropListMorph >> fillStyleToUse [
	"Answer the fillStyle that should be used for the receiver."
	
	^self enabled
		ifTrue: [self theme dropListNormalFillStyleFor: self]
		ifFalse: [self theme dropListDisabledFillStyleFor: self]
]

{ #category : #accessing }
DropListMorph >> focusBounds [
	"Answer the bounds for drawing the focus indication."

	^self theme dropListFocusBoundsFor: self
]

{ #category : #accessing }
DropListMorph >> focusIndicatorCornerRadius [
	"Answer the corner radius preferred for the focus indicator
	for the receiver for themes that support this."

	^self theme dropListFocusIndicatorCornerRadiusFor: self 
]

{ #category : #accessing }
DropListMorph >> font [
	"Answer the content font"

	^self contentMorph font
]

{ #category : #accessing }
DropListMorph >> font: aFont [
	"Set the content font"

	self contentMorph font: aFont
]

{ #category : #protocol }
DropListMorph >> getCurrentSelection [
	"Answer the current selection from the model."

	^(self model notNil and: [self getIndexSelector notNil])
		ifTrue: [|mySelection|
			mySelection := self model perform: self getIndexSelector.
			(self list includes: mySelection)
				ifTrue: [mySelection]]
]

{ #category : #protocol }
DropListMorph >> getCurrentSelectionIndex [
	"Answer the index of the current selection."

	self getIndexSelector ifNil: [^0].
	^self model perform: self getIndexSelector
]

{ #category : #accessing }
DropListMorph >> getEnabledSelector [
	"Answer the value of getEnabledSelector"

	^ getEnabledSelector
]

{ #category : #accessing }
DropListMorph >> getEnabledSelector: anObject [
	"Set the value of getEnabledSelector"

	getEnabledSelector := anObject.
	self updateEnabled
]

{ #category : #accessing }
DropListMorph >> getIndexSelector [
	"Answer the value of getIndexSelector"

	^ getIndexSelector
]

{ #category : #accessing }
DropListMorph >> getIndexSelector: anObject [
	"Set the value of getIndexSelector"

	getIndexSelector := anObject
]

{ #category : #accessing }
DropListMorph >> getListSelector [
	"Answer the value of getListSelector"

	^ getListSelector
]

{ #category : #accessing }
DropListMorph >> getListSelector: anObject [
	"Set the value of getListSelector"

	getListSelector := anObject
]

{ #category : #protocol }
DropListMorph >> ghostText: aStringOrText [
	self contentMorph ghostText: aStringOrText
]

{ #category : #'event handling' }
DropListMorph >> handlesKeyboard: evt [
	"Return true if the receiver wishes to handle the given keyboard event."
	
	^true
]

{ #category : #protocol }
DropListMorph >> hideList [
	"Hide the list."

	self listMorph ifNil: [^self].
	self listVisible ifFalse: [^self].
	self listMorph delete.
	self roundedCorners: #(1 2 3 4).
	(self buttonMorph ifNil: [^self]) roundedCorners: (self roundedCorners copyWithoutAll: #(1 2)).
	self fillStyle: self fillStyleToUse.
	self wantsKeyboardFocus
		ifTrue: [self takeKeyboardFocus]
]

{ #category : #initialization }
DropListMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	listSelectionIndex := 0.
	enabled := true.
	list := #().
	self
		useSelectionIndex: true;
		clipSubmorphs: true;
		layoutPolicy: RowLayout new;
		layoutInset: self layoutInsetToUse;
		cellPositioning: #center;
		listMorph: self newListMorph;
		contentMorph: self newContentMorph;
		buttonMorph: self newButtonMorph;
		fillStyle: self fillStyleToUse;
		borderStyle: self borderStyleToUse;
		addMorphBack: self contentMorph;
		addMorphBack: (self addDependent: self buttonMorph);
		on: #mouseDown send: #popList to: self;
		vResizing: #rigid;
		hResizing: #spaceFill;
		height: self font height + 10.
	self listMorph fillStyle: (self theme dropListNormalListFillStyleFor: self)
]

{ #category : #'event handling' }
DropListMorph >> keyDown: event [
	
	event keyCharacter = Character escape ifTrue: [ self hideList ].
	(self navigationKey: event) ifTrue: [^self].
	
	event keyCharacter == Character cr
		ifTrue: [ ^ self listSelectionIndex: self listSelectionIndex ].

	^ false
]

{ #category : #'event handling' }
DropListMorph >> keyStroke: event [
	"Pass on to the list."
	| indexToSelect |
	indexToSelect := self listMorph keyStroke: event.
	
	"If the returned value is not an integer, do not handle it"
	indexToSelect isInteger ifFalse: [ ^ self ].
	
	"If nothing found, do nothing"
	indexToSelect == 0 ifTrue: [ ^ self ].
	
	self listSelectionIndex: indexToSelect
]

{ #category : #'event handling' }
DropListMorph >> keyboardFocusChange: aBoolean [
	"The message is sent to a morph when its keyboard focus changes.
	Update for focus feedback."
	super keyboardFocusChange: aBoolean.
	self focusChanged
]

{ #category : #private }
DropListMorph >> layoutInsetToUse [
	"Answer the layout inset that should be used."

	^self theme dropListInsetFor: self
]

{ #category : #accessing }
DropListMorph >> list [
	"Answer the list contents."
	^list
]

{ #category : #accessing }
DropListMorph >> list: aCollection [
	"Set the list contents."

	list := aCollection.
	self changed: #list
]

{ #category : #'font accessing' }
DropListMorph >> listFont [
	"Answer the list font"

	^self listMorph font
]

{ #category : #'font creation' }
DropListMorph >> listFont: aFont [
	"Set the list font"

	self listMorph font: aFont
]

{ #category : #private }
DropListMorph >> listHeight [
	"Answer the height for the list."

	^(self listMorph listMorph height + 6 max: 38) min: (15 * self listFont height)
]

{ #category : #accessing }
DropListMorph >> listMorph [
	"Answer the value of listMorph"

	^ listMorph
]

{ #category : #accessing }
DropListMorph >> listMorph: anObject [
	"Set the value of listMorph"

	listMorph := anObject.
	anObject 
			on: #keyStroke 
			send: #keyStroke: 
			to: self.
]

{ #category : #private }
DropListMorph >> listMorphClass [
	"Answer the class for a new list morph"

	^PluggableListMorph
]

{ #category : #'event handling' }
DropListMorph >> listMouseDown: evt [
	"Click outside the list."

	(self listMorph fullContainsPoint: evt position)
		ifTrue: [ self listMorph changeModelSelection: (self listMorph rowAtLocation: evt position) ].
	self hideList
]

{ #category : #drawing }
DropListMorph >> listPaneColor: paneColor [
	"Set the pane color for the list."
	
	self listMorph ifNil: [^self].
	self listMorph
		adoptPaneColor: paneColor;
		fillStyle: (self theme dropListNormalListFillStyleFor: self);
		borderStyle: (self theme dropListNormalListBorderStyleFor: self)
]

{ #category : #accessing }
DropListMorph >> listSelectionIndex [
	"Answer the list selection."

	^listSelectionIndex
]

{ #category : #accessing }
DropListMorph >> listSelectionIndex: anInteger [
	"Set the list selection."

	self hideList.
	anInteger = 0 ifTrue: [^self].
	listSelectionIndex := anInteger.
	self
		changed: #listSelectionIndex;
		updateContents;
		triggerEvent: #selectionIndex with: anInteger.
	self model ifNotNil: [:m | 
		self setIndexSelector ifNotNil: [:s |
			self useSelectionIndex
				ifTrue: [m perform: s with: anInteger]
				ifFalse: [m perform: s with: self selectedItem]]]
]

{ #category : #private }
DropListMorph >> listVisible [
	"Answer whether the list is visible."

	^self listMorph owner notNil
]

{ #category : #'wiw support' }
DropListMorph >> morphicLayerNumber [
	"Answer the layer number."

	^self listVisible ifTrue: [10] ifFalse: [super morphicLayerNumber]
]

{ #category : #drawing }
DropListMorph >> newButtonMorph [
	"Answer a new button morph"

	^(ControlButtonMorph
		on: self
		getState: nil
		action: #popList
		label: #buttonLabel)
			roundedCorners: #(3 4);
			getEnabledSelector: #enabled;
			label: self buttonLabel; 
			vResizing: #spaceFill;
			hResizing: #rigid;
			extent: self buttonExtent;
			setProperty: #wantsKeyboardFocusNavigation toValue: false;
			cornerStyle: self cornerStyle.
]

{ #category : #drawing }
DropListMorph >> newContentMorph [
	"Answer a new content morph"

	^ RubTextFieldArea new
		vResizing: #shrinkWrap;
		hResizing: #spaceFill;
		beReadOnly;
		lock;
		yourself
		
		
]

{ #category : #drawing }
DropListMorph >> newListMorph [
	"Answer a new list morph"

	|m|
	m := (self listMorphClass
		on: self
		list: #list
		selected: #listSelectionIndex
		changeSelected: #listSelectionIndex:
		menu: nil
		keystroke: nil)
			autoDeselect: false;
			wrapSelector: #wrapItem:index:;
			roundedCorners: #(2 3);
			setProperty: #morphicLayerNumber toValue: 5;
			"color: self color;"
			borderStyle: (self theme dropListNormalListBorderStyleFor: self);
			on: #mouseDown send: #listMouseDown: to: self.
	^m
]

{ #category : #protocol }
DropListMorph >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel [
	"Set the receiver to the given model parameterized by the given message selectors."

	getListSel isSymbol
		ifTrue: [self  getListSelector: getListSel]
		ifFalse: [self list: getListSel]. "allow direct list"
	self
		model: anObject;
		getIndexSelector: getSelectionSel;
		setIndexSelector: setSelectionSel;
		updateList;
		updateListSelectionIndex;
		updateContents
]

{ #category : #initialize }
DropListMorph >> outOfWorld: aWorld [
	"Get rid of the list if visible."

	self hideList.
	^super outOfWorld: aWorld
]

{ #category : #protocol }
DropListMorph >> popList [

	"Hide / show the list."

	self enabled
		ifFalse: [ ^ self ].
	self listMorph owner ifNil: [ self showList ] ifNotNil: [ self hideList ]
]

{ #category : #private }
DropListMorph >> positionList [
	"Position the list morph to fit on the display."

	|height topSpace bottomSpace pos|
	height := self listHeight.
	topSpace := self boundsInWorld top - self world top.
	bottomSpace := self world bottom - self boundsInWorld bottom.
	pos := height <= bottomSpace
		ifTrue: [#below]
		ifFalse: [height <= topSpace
			ifTrue: [#above]
			ifFalse: [bottomSpace >= topSpace
				ifTrue: [height := bottomSpace. #below]
				ifFalse: [height := topSpace. #above]]].
	pos = #above
		ifTrue: [self buttonMorph roundedCorners: (self roundedCorners copyWithoutAll: #(1 4)).
				self roundedCorners: (self roundedCorners copyWithoutAll: #(1 4)).
				self listMorph
					bounds: (self boundsInWorld topLeft - (0 @ height) extent: self width @ height)]
		ifFalse: [self buttonMorph roundedCorners: (self roundedCorners copyWithoutAll: #(1 2 3)).
				self roundedCorners: (self roundedCorners copyWithoutAll: #(2 3)).
				self listMorph
					bounds: (self boundsInWorld bottomLeft extent: self width @ height)]
]

{ #category : #accessing }
DropListMorph >> roundedCorners: anArray [
	"Set the corners to round."

	super roundedCorners: anArray.
	self buttonMorph ifNotNil: [:b |
		b roundedCorners: (anArray copyWithoutAll: #(1 2))]
]

{ #category : #protocol }
DropListMorph >> selectedItem [
	"Answer the selected list item."

	^(self listSelectionIndex between: 1 and: self list size) ifTrue: [
		self list at: self listSelectionIndex]
]

{ #category : #accessing }
DropListMorph >> selectionColor [
	"Answer the selection color for the receiver."

	^self listMorph selectionColor
]

{ #category : #accessing }
DropListMorph >> selectionColor: aColor [
	"Set the selection color for the receiver."

	self listMorph selectionColor: aColor
]

{ #category : #accessing }
DropListMorph >> setIndexSelector [
	"Answer the value of setIndexSelector"

	^ setIndexSelector
]

{ #category : #accessing }
DropListMorph >> setIndexSelector: anObject [
	"Set the value of setIndexSelector"

	setIndexSelector := anObject
]

{ #category : #protocol }
DropListMorph >> showList [

	"Show the list."

	self listMorph owner
		ifNil: [ self positionList.
			self
				fillStyle: self fillStyleToUse;
				listPaneColor: self paneColor.
			self listMorph theme: self theme.
			self world addMorphInLayer: self listMorph.
			self listMorph wantsKeyboardFocus
				ifTrue: [ self listMorph takeKeyboardFocus ].
			self activeHand newMouseFocus: self listMorph
			]
]

{ #category : #stepping }
DropListMorph >> step [
	"Reset mouse focus to the list if it is showing."
	self listVisible ifTrue: [
		self activeHand mouseFocus ifNil: [
			 self listMorph wantsKeyboardFocus ifTrue: [
				self listMorph takeKeyboardFocus].
			self activeHand newMouseFocus: self listMorph]]
]

{ #category : #stepping }
DropListMorph >> stepTime [
	"Answer the desired time between steps in milliseconds."

	^100
]

{ #category : #protocol }
DropListMorph >> takesKeyboardFocus [
	"Answer whether the receiver can normally take keyboard focus."

	^true
]

{ #category : #updating }
DropListMorph >> themeChanged [
	"Update the selection colour."
	
	self color: self defaultColor.
	self selectionColor ifNotNil: [
		self selectionColor: self theme selectionColor].
	self layoutInset: self layoutInsetToUse.
	self buttonMorph extent: self buttonExtent.
	self buttonMorph cornerStyle: self cornerStyle.
	self buttonMorph label: self buttonLabel.
	self updateContentColor: nil.
	self listMorph themeChanged.
	super themeChanged.	
	
]

{ #category : #updating }
DropListMorph >> update: aSymbol [ 
	"Refer to the comment in View|update:."

	aSymbol == getListSelector ifTrue: 
		[self updateList.
		^ self].
	aSymbol == getIndexSelector ifTrue:
		[self updateListSelectionIndex.
		^ self].
	aSymbol == getEnabledSelector ifTrue:
		[self updateEnabled.
		^ self].

]

{ #category : #updating }
DropListMorph >> updateContentColor: paneColor [
	"Change the content text color."
	
	self enabled
		ifTrue: [self contentMorph textColor: self theme textColor ]
		ifFalse: [self contentMorph textColor: self theme disabledColor ]
]

{ #category : #private }
DropListMorph >> updateContentMorphWith: aString [

	self contentMorph setTextWith: aString asString
]

{ #category : #testing }
DropListMorph >> updateContents [
	"Update the contents."

	self updateContentMorphWith:
		(self listSelectionIndex > 0
			ifTrue: [self listMorph wrapItem: (self list at: self listSelectionIndex) index: self listSelectionIndex ]
			ifFalse: [ '' ]) 
]

{ #category : #updating }
DropListMorph >> updateEnabled [
	"Update the enablement state."

	self model ifNotNil: [
		self getEnabledSelector ifNotNil: [
			self enabled: (self model perform: self getEnabledSelector)]]
]

{ #category : #updating }
DropListMorph >> updateList [
	"Refresh the list."

	self getListSelector isSymbol ifTrue: [
		self list: (self model perform: self getListSelector).
		listSelectionIndex := 0]
]

{ #category : #updating }
DropListMorph >> updateListSelectionIndex [

	"Update the list selection."

	| i |

	self useSelectionIndex
		ifTrue: [ i := self getCurrentSelectionIndex.
			listSelectionIndex = i
				ifTrue: [ ^ self ].
			listSelectionIndex := i
			]
		ifFalse: [ i := self getCurrentSelection.
			listSelectionIndex := i ifNil: [ 0 ] ifNotNil: [ self list indexOf: i ]
			].
	self
		changed: #listSelectionIndex;
		updateContents;
		triggerEvent: #selectionIndex with: i
]

{ #category : #protocol }
DropListMorph >> useIndex [
	"Use the model as returning the selected index rather than item."

	self useSelectionIndex: true
]

{ #category : #protocol }
DropListMorph >> useSelection [
	"Use the model as returning the selected item rather than index."

	self useSelectionIndex: false
]

{ #category : #accessing }
DropListMorph >> useSelectionIndex [
	"Answer the value of useSelectionIndex"

	^ useSelectionIndex
]

{ #category : #accessing }
DropListMorph >> useSelectionIndex: anObject [
	"Set the value of useSelectionIndex"

	useSelectionIndex := anObject
]

{ #category : #testing }
DropListMorph >> wantsKeyboardFocus [
	"Answer whether the receiver would like keyboard focus
	in the general case (mouse action normally)."

	^super wantsKeyboardFocus and: [
		self allowKeyboardFocus]
]

{ #category : #stepping }
DropListMorph >> wantsSteps [
	"Step is very very time consuming..."
	^ false
]

{ #category : #wrapping }
DropListMorph >> wrapItem: anItem index: index [

	^ wrapSelector
		ifNil: [ anItem asString ]
		ifNotNil: [ 
			wrapSelector numArgs = 0
				ifTrue: [ anItem perform: wrapSelector ]
				ifFalse: [ self model 
								perform: wrapSelector 
								withEnoughArguments: {anItem. index. self.} ]]
]

{ #category : #wrapping }
DropListMorph >> wrapSelector [
	
	^ wrapSelector
]

{ #category : #wrapping }
DropListMorph >> wrapSelector: aSymbol [
	
	wrapSelector := aSymbol.

	self updateList.
	self updateContents
]
