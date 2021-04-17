"
I am a base class for method edito tools.

I implement correctly the styling of typed source code. 
Also I add multiple text editing tools to the status bar: 
- wrap mode switch 
- line number=s switch
- format as you read 
- method tags and package editor.

In addition to the superclass abstract methods subclasses should implement following methods: 

- methodClass 
Subclasses should decide what class will accept editing method

- modifiesExtension 
Subclasses should detect that editing method is going to be extension.

Internal Representation and Key Implementation Points.

    Instance Variables
	extendingPackage:		<RPackage>
	methodTags:		<Array of<Symbol>>
"
Class {
	#name : #ClyMethodEditorToolMorph,
	#superclass : #ClyTextEditorToolMorph,
	#instVars : [
		'ast',
		'methodTags',
		'extendingPackage',
		'targetClasses'
	],
	#category : #'Calypso-SystemTools-Core-Editors-Methods'
}

{ #category : #testing }
ClyMethodEditorToolMorph class >> isAbstract [
	^self = ClyMethodEditorToolMorph 
]

{ #category : #accessing }
ClyMethodEditorToolMorph class >> tabOrder [
	^20
]

{ #category : #testing }
ClyMethodEditorToolMorph >> allowsDifferentActivationPriority [
	^false
]

{ #category : #testing }
ClyMethodEditorToolMorph >> belongsToRemovedBrowserContext [
	super belongsToRemovedBrowserContext ifTrue: [ ^true ].
	
	^self methodClass isObsolete
]

{ #category : #building }
ClyMethodEditorToolMorph >> buildTextMorph [
	super buildTextMorph.
	ast := self initializeAST.
	self formatTextIfNeeded.
]

{ #category : #'events handling' }
ClyMethodEditorToolMorph >> changesAreAboutApply [
	| tagsEditor |
	super changesAreAboutApply.
	
	tagsEditor := statusBar findDeeplyA: ClyMethodTagsEditorMorph.
	tagsEditor ifNil: [ ^self ].
	
	tagsEditor acceptTags
]

{ #category : #operations }
ClyMethodEditorToolMorph >> chooseClassForNewMethodIfNone: aBlock [
	
	targetClasses size = 1 ifTrue: [ ^ targetClasses first].

	^[self browser searchDialog 
			requestSingleObject: 'Where install new method?'
			from: (ClyAllClassesQuery as: ClyMethodVisibilityProvider defaultHierarchy asQueryResult) 
			inScope: (ClyClassScope ofAll: targetClasses)]
		on: CmdCommandAborted do: [:err | aBlock value ]
]

{ #category : #'events handling' }
ClyMethodEditorToolMorph >> currentEditedAST [

	^ self methodClass compiler
		  source: self pendingText;
		  options: #( + optionParseErrors + optionSkipSemanticWarnings );
		  parse
]

{ #category : #accessing }
ClyMethodEditorToolMorph >> editingClass [ 
	^self methodClass
]

{ #category : #accessing }
ClyMethodEditorToolMorph >> extendingPackage [
	^ extendingPackage
]

{ #category : #accessing }
ClyMethodEditorToolMorph >> extendingPackage: aPackage [
	extendingPackage := aPackage.
	methodTags := #().
]

{ #category : #building }
ClyMethodEditorToolMorph >> fillStatusBar [
	| position |
	super fillStatusBar.
	
	position := statusBar addContextItem: (ClyCursorPositionLabelMorph of: textMorph).
	position comeToFront.
	statusBar addCommandItem: (ClyTextWrapModeSwitchMorph of: textMorph).
	statusBar addCommandItem: (ClyTextLineNumbersSwitchMorph of: textMorph).
	statusBar addCommandItem: (ClyFormatAsReadSwitchMorph of: textMorph).
	
	statusBar addCommandItem: (ClyMethodTagsAndPackageEditorMorph for: self).
	
	
]

{ #category : #operations }
ClyMethodEditorToolMorph >> formatSourceCode [
	textMorph formatSourceCode 
]

{ #category : #building }
ClyMethodEditorToolMorph >> formatTextIfNeeded [
	RBProgramNode formatterClass formatAsYouReadPolicy ifFalse: [ ^self].
	
	textMorph formatSourceCode. 
	textModel clearUserEdits
]

{ #category : #initialization }
ClyMethodEditorToolMorph >> initialize [
	super initialize.
	
	methodTags := #()
]

{ #category : #initialization }
ClyMethodEditorToolMorph >> initializeAST [
	"subclasses might get it from the method"
	^ self currentEditedAST
]

{ #category : #testing }
ClyMethodEditorToolMorph >> isCommandAvailable: aCommand [ 

	^ aCommand canBeExecutedInMethodEditor: self
]

{ #category : #'rubric interaction model' }
ClyMethodEditorToolMorph >> isForScripting [
	^false
]

{ #category : #accessing }
ClyMethodEditorToolMorph >> methodClass [
	self subclassResponsibility 	
]

{ #category : #accessing }
ClyMethodEditorToolMorph >> methodTags [
	^methodTags
]

{ #category : #accessing }
ClyMethodEditorToolMorph >> methodTags: tagsArray [
	methodTags := tagsArray.
	extendingPackage := nil
]

{ #category : #testing }
ClyMethodEditorToolMorph >> modifiesExtension [
	"it should answer if tool is going to modify extension state of method.
	For example tool ca move method to another package
	ot it can move extension method back to class package"
	self subclassResponsibility 
]

{ #category : #operations }
ClyMethodEditorToolMorph >> packageEditingMethod: aMethod [
	
	self applyChangesBy: [ 
		(extendingPackage notNil and: [aMethod package ~~ extendingPackage]) ifTrue: [
			^(SycMoveMethodsToPackageCommand for: {aMethod} to: extendingPackage) 
				execute].
	
		(extendingPackage isNil and: [ aMethod isExtension ]) ifTrue: [ 
			(SycMoveMethodsToPackageDefiningClassCommand for: {aMethod}) 
				execute]
	]
]

{ #category : #'rubric interaction model' }
ClyMethodEditorToolMorph >> selectedClassOrMetaClass [
	^self methodClass
]

{ #category : #initialization }
ClyMethodEditorToolMorph >> setUpParametersFromModel [
	super setUpParametersFromModel.

	self setUpTargetClasses 
]

{ #category : #initialization }
ClyMethodEditorToolMorph >> setUpTargetClasses [
	self subclassResponsibility 
]

{ #category : #operations }
ClyMethodEditorToolMorph >> tagAndPackageEditingMethod: aMethod [
	self tagEditingMethod: aMethod.
	"Tagging should be performed before package movement 
	because extending package is still based on protocol begining with star. 
	So it should override manual tagging"	
	self packageEditingMethod: aMethod
]

{ #category : #operations }
ClyMethodEditorToolMorph >> tagEditingMethod: aMethod [
	| existingTags removedTags newTags |
	self applyChangesBy: [
		existingTags := aMethod tags reject: [:each | each beginsWith: '*'].
		removedTags := existingTags reject: [ :each | methodTags includes: each ].
		newTags := methodTags reject: [ :each | existingTags includes: each ].
	
		newTags do: [ :each | aMethod tagWith: each asSymbol].
		removedTags do: [ :each | aMethod untagFrom: each asSymbol]
	]
]

{ #category : #accessing }
ClyMethodEditorToolMorph >> tagsAndPackageEditor [
	^(statusBar findDeeplyA: ClyMethodTagsAndPackageEditorMorph) ifNil: [ CmdCommandAborted signal ]
]

{ #category : #'events handling' }
ClyMethodEditorToolMorph >> textChanged: aTextChanged [
	super textChanged: aTextChanged.
	ast := self currentEditedAST.
	textMorph segments copy do: #delete.
	IconStyler new
	   stylerClasses: {ErrorNodeStyler . SemanticMessageIconStyler . SemanticVariableIconStyler }; 
		styleText: textModel withAst: ast.
	^ ast
]

{ #category : #operations }
ClyMethodEditorToolMorph >> toggleExtendingPackage [

	extendingPackage ifNotNil: [ ^extendingPackage := nil ].
	
	extendingPackage := browser searchDialog 
		requestSingleObject: 'Choose package for method' from: ClyAllPackagesQuery sorted
]
