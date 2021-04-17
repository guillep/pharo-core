"
I am status bar tool for method editors to select method tags or extending package for the editing method.

While system only support tags when method is not extension I do not show both elements.
So I provide checkbox for extension status.
When it is active I should extending package in the label.
When it is not active I show method tag (protocol) in the label.

When user toggle checkbox I request either package or protocol depending on requested mode of method.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	editButton:		<Morph>
	extensionCheckbox:		<Morph>
	label:		<StringMorph>

"
Class {
	#name : #ClyMethodTagsAndPackageEditorMorph,
	#superclass : #ClyStatusBarItemMorph,
	#instVars : [
		'extensionCheckbox',
		'editButton',
		'label',
		'resetButton'
	],
	#category : #'Calypso-SystemTools-Core-Editors-Methods'
}

{ #category : #building }
ClyMethodTagsAndPackageEditorMorph >> build [	
	self buildResetButton.
	self addMorphBack: resetButton.
	
	self buildEditButton.
	self addMorphBack: editButton.
	
	self buildLabel.
	self addMorphBack: label.
	
	self buildExtensionCheckBoxButton.
	self addMorphBack: extensionCheckbox.
	
	self update
]

{ #category : #building }
ClyMethodTagsAndPackageEditorMorph >> buildEditButton [
	editButton := IconicButtonMorph new
		target: self;
		actionSelector: #openEditor;
		arguments: #();
		labelGraphic: (self iconNamed: #edit);
		color: Color transparent;
		borderWidth: 0
]

{ #category : #building }
ClyMethodTagsAndPackageEditorMorph >> buildExtensionCheckBoxButton [
	extensionCheckbox := self theme 
		newCheckboxIn: self 
		for: self 
		getSelected: #isExtensionActive 
		setSelected: #toggleExtension
		getEnabled: nil 
		label: 'extension'
		help: 'toggle check box to choose/reset package of method'.
	extensionCheckbox
		changeTableLayout;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap
]

{ #category : #building }
ClyMethodTagsAndPackageEditorMorph >> buildLabel [

	label := self theme newLabelIn: self label: self printMethodTagsOrPackage.
	label on: #click send: #openEditor to: self
]

{ #category : #building }
ClyMethodTagsAndPackageEditorMorph >> buildResetButton [

	resetButton := IconicButtonMorph new
		target: self;
		actionSelector: #resetTagsAndPackage;
		arguments: #();
		labelGraphic: (self iconNamed: #glamorousClose);
		color: Color transparent;
		borderWidth: 0;
		hResizing: #shinkWrap;
		layoutInset: 4@0
]

{ #category : #initialization }
ClyMethodTagsAndPackageEditorMorph >> initialize [
	super initialize.	
	self cellInset: 2@2
]

{ #category : #testing }
ClyMethodTagsAndPackageEditorMorph >> isExtensionActive [

	^ownerTool extendingPackage notNil
]

{ #category : #operations }
ClyMethodTagsAndPackageEditorMorph >> openEditor [

	self requestChangeBy: [
		self isExtensionActive 
			ifTrue: [ self requestPackage]
			ifFalse: [ self requestTag ]
	]
]

{ #category : #accessing }
ClyMethodTagsAndPackageEditorMorph >> ownerTool: anObject [

	super ownerTool: anObject
]

{ #category : #printing }
ClyMethodTagsAndPackageEditorMorph >> printMethodTags [

	^ownerTool methodTags 
		ifEmpty: [ 'as yet unclassified' asText makeAllColor: Color red ]
		ifNotEmpty: [ :tags | tags joinUsing: ', ' ]
]

{ #category : #printing }
ClyMethodTagsAndPackageEditorMorph >> printMethodTagsOrPackage [

	^self isExtensionActive 
		ifTrue: [ ownerTool extendingPackage name]
		ifFalse: [ self printMethodTags ]
]

{ #category : #operations }
ClyMethodTagsAndPackageEditorMorph >> requestChangeBy: aBlock [
	
	aBlock on: CmdCommandAborted do: [ :err ].
	
	self update
]

{ #category : #operations }
ClyMethodTagsAndPackageEditorMorph >> requestPackage [

	| extendingPackage |
	extendingPackage := ownerTool context requestSinglePackage: 'Choose package for method'.
		
	ownerTool extendingPackage: extendingPackage
]

{ #category : #operations }
ClyMethodTagsAndPackageEditorMorph >> requestTag [

	| selectedTag existingTag |
	existingTag := ownerTool methodTags 
		ifEmpty: [ '' ] ifNotEmpty: [ :tags | tags anyOne ].

	selectedTag := self ownerTool context
		requestSingleMethodTag: 'New protocol name' suggesting: existingTag.
	selectedTag = existingTag ifTrue: [ ^CmdCommandAborted signal ].
	
	ownerTool methodTags: { selectedTag asSymbol }
]

{ #category : #operations }
ClyMethodTagsAndPackageEditorMorph >> resetTagsAndPackage [
	ownerTool methodTags: #().
	self update
]

{ #category : #operations }
ClyMethodTagsAndPackageEditorMorph >> toggleExtension [

	self requestChangeBy: [ 
		self isExtensionActive 
			ifTrue: [ self requestTag ]
			ifFalse: [ self requestPackage]
	]
]

{ #category : #building }
ClyMethodTagsAndPackageEditorMorph >> update [
	label color: label defaultColor.
	label contents: self printMethodTagsOrPackage.
	self isExtensionActive 
		ifTrue: [ editButton helpText: 'Choose package for method']
		ifFalse: [ editButton helpText: 'Classify method']
]
