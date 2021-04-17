"
I am a method source code editor.

I am opened in the browser when method is selected.

I am subscribed on the system changes related to my editing method.

Internal Representation and Key Implementation Points.

    Instance Variables
	editingMethod:		<CompiledMethod>
"
Class {
	#name : #ClyMethodCodeEditorToolMorph,
	#superclass : #ClyMethodEditorToolMorph,
	#instVars : [
		'editingMethod'
	],
	#category : #'Calypso-SystemTools-Core-Editors-Methods'
}

{ #category : #activation }
ClyMethodCodeEditorToolMorph class >> browserTabActivation [
	"This declaration specifies that in any browser when methods are selected, a method editor will be available in a tab."
	
	<classAnnotation>
	^ClyTabActivationStrategy for: ClyMethod asCalypsoItemContext
]

{ #category : #testing }
ClyMethodCodeEditorToolMorph class >> shouldBeActivatedInContext: aBrowserContext [
	^aBrowserContext isMethodSelected
]

{ #category : #operations }
ClyMethodCodeEditorToolMorph >> applyChanges [
	| selector methodClass currentMethod |
	methodClass := self chooseClassForNewMethodIfNone: [^false].
	selector := methodClass compile: self pendingText classified: editingMethod protocol notifying: textMorph.
	selector ifNil: [^false ].
	currentMethod := methodClass >> selector.
	self tagAndPackageEditingMethod: currentMethod.
	self switchToMethod: currentMethod.
	"update the AST to the just compiled method. This clears breakpoints. To be improved"
	ast := self initializeAST.
	^true
]

{ #category : #building }
ClyMethodCodeEditorToolMorph >> applyDecorations [
	| hasEdits |
	
	hasEdits := textMorph hasUnacceptedEdits.
	textMorph segments copy do: #delete.	
	"literal methods do not need ot be stylized and this is an operation that can take 
	 a lot of time, we will skip it when it is the case"
	editingMethod isLiteralMethod ifFalse: [ 
		IconStyler withStaticStylers  
			styleText: textModel withAst: ast ].	
	textMorph hasUnacceptedEdits: hasEdits.
	
	super applyDecorations.
	
	browser decorateMethodEditor: self
]

{ #category : #controlling }
ClyMethodCodeEditorToolMorph >> attachToSystem [

	browser system 
		when: (ClyMethodChange of: self editingMethod)
		send: #triggerUpdate
		to: self
]

{ #category : #testing }
ClyMethodCodeEditorToolMorph >> belongsToCurrentBrowserContext [
	^browser methodSelection isEmpty 
		ifTrue: [ browser isClassSelected: self editingMethod origin ]
		ifFalse: [ browser isMethodSelected: self editingMethod]
]

{ #category : #testing }
ClyMethodCodeEditorToolMorph >> belongsToRemovedBrowserContext [
	| actualMethod |
	super belongsToRemovedBrowserContext ifTrue: [ ^true ].
	
	actualMethod := editingMethod origin 
		localMethodNamed: editingMethod selector ifAbsent: [^true].
		
	self editingMethod: actualMethod.
	^false
]

{ #category : #building }
ClyMethodCodeEditorToolMorph >> buildLeftSideBar [
	super buildLeftSideBar.

	self leftSideBar enableMouseCommands: CmdTextLeftBarClickActivation withContextFrom: self
]

{ #category : #operations }
ClyMethodCodeEditorToolMorph >> cancelChanges [
	self updateMethodTagsAndPackage.
	
	super cancelChanges
]

{ #category : #contexts }
ClyMethodCodeEditorToolMorph >> createCommandContextForCursorAt: aCursorPoint [

	| sourceNode |
	sourceNode := self findSourceNodeAt: aCursorPoint.
	
	^ClyMethodSourceCodeContext for: self selectedNode: sourceNode
]

{ #category : #contexts }
ClyMethodCodeEditorToolMorph >> createTextContext [
	^self selectedSourceNode
		ifNil: [super createTextContext]
		ifNotNil: [ :astNode | ClyMethodSourceCodeContext for: self selectedNode: astNode]
]

{ #category : #building }
ClyMethodCodeEditorToolMorph >> decorateContainerTab [
	| title |
	super decorateContainerTab.
	title := editingMethod selector.

	editingMethod origin isClassSide ifTrue: [ 
		title := title asText allBold ].

	containerTab label: title
]

{ #category : #initialization }
ClyMethodCodeEditorToolMorph >> defaultIconName [
	^#scriptManagerIcon
]

{ #category : #controlling }
ClyMethodCodeEditorToolMorph >> detachFromSystem [

	browser system unsubscribe: self
]

{ #category : #accessing }
ClyMethodCodeEditorToolMorph >> editingMethod [
	^editingMethod 
]

{ #category : #accessing }
ClyMethodCodeEditorToolMorph >> editingMethod: aMethod [
	editingMethod := aMethod
]

{ #category : #accessing }
ClyMethodCodeEditorToolMorph >> editingText [
	^editingMethod sourceCode
]

{ #category : #accessing }
ClyMethodCodeEditorToolMorph >> extendingPackage: aPackage [
	super extendingPackage: aPackage.
	
	self hasUnacceptedEdits ifFalse: [self packageEditingMethod: editingMethod]
]

{ #category : #'selecting text' }
ClyMethodCodeEditorToolMorph >> findAnySelectorInSourceCode: selectors [

	| foundSelector foundNode positions |
	foundNode := ast sendNodes 
		detect: [:each | selectors includes: (foundSelector := each selector) ] 
		ifNone: [ 
			ast allChildren
				detect: [:each | each isLiteralNode and: [ selectors includes: each value ]]
				ifFound: [:literal | ^ literal sourceInterval ].
			^0 to: -1].
		
	positions := foundNode keywordsPositions.
	^positions first to: positions last + foundSelector keywords last size - 1.
]

{ #category : #'selecting text' }
ClyMethodCodeEditorToolMorph >> findAnyVariableInSourceCode: varNames [
	| foundNode |
	
	foundNode := editingMethod variableNodes 
		detect: [ :each | varNames includes: each name ] ifNone: [ ^0 to: -1 ].
		
	^foundNode start to: foundNode stop
]

{ #category : #contexts }
ClyMethodCodeEditorToolMorph >> findSourceNodeAt: aCursorPoint [
	| startPosition endPosition line lineIndex  selection |
	lineIndex := self leftSideBar lineIndexForPoint: aCursorPoint. "strangely we can't ask text morph about it"
	line := textMorph paragraph lines at: lineIndex.	
	startPosition := line first.
	endPosition := line last.

	selection := self selectedTextInterval.
	selection ifNotNil: [ 
		selection first >= startPosition & (selection last <= endPosition) ifTrue: [ 
			startPosition := selection first max: 1.
			endPosition := selection last min: self editingText size]].

	^(ast bestNodeFor: (startPosition to: endPosition))
		ifNil: [ ast ]
]

{ #category : #initialization }
ClyMethodCodeEditorToolMorph >> initializeAST [
	"When the editor is created, we get the AST from the method"
	^ editingMethod ast
]

{ #category : #testing }
ClyMethodCodeEditorToolMorph >> isCommandAvailable: aCommand [ 

	^ aCommand canBeExecutedInCodeMethodEditor: self
]

{ #category : #testing }
ClyMethodCodeEditorToolMorph >> isSimilarTo: anotherBrowserTool [
	(super isSimilarTo: anotherBrowserTool) ifFalse: [ ^false ].
	
	^editingMethod == anotherBrowserTool editingMethod or: 
		[ editingMethod selector == anotherBrowserTool editingMethod selector
			and: [ editingMethod origin == anotherBrowserTool editingMethod origin ] ]
]

{ #category : #accessing }
ClyMethodCodeEditorToolMorph >> methodClass [

	self belongsToCurrentBrowserContext ifFalse: [ ^editingMethod origin ].
	
	^browser chooseClassForEditorOfMethod: editingMethod
]

{ #category : #accessing }
ClyMethodCodeEditorToolMorph >> methodTags: tagsArray [
	super methodTags: tagsArray.
	
	self hasUnacceptedEdits ifFalse: [ self tagEditingMethod: editingMethod]
]

{ #category : #testing }
ClyMethodCodeEditorToolMorph >> modifiesExtension [
	^editingMethod isExtension 
		ifTrue: [ extendingPackage ~~ editingMethod package  ]
		ifFalse: [ extendingPackage notNil and: [extendingPackage ~~ self methodClass package] ]
]

{ #category : #printing }
ClyMethodCodeEditorToolMorph >> printContext [
	^self editingMethod printSystemPath
]

{ #category : #'selecting text' }
ClyMethodCodeEditorToolMorph >> selectAnySelector: selectors [

	textMorph setSelection: (self findAnySelectorInSourceCode: selectors)
]

{ #category : #'selecting text' }
ClyMethodCodeEditorToolMorph >> selectAnyVariable: varNames [

	textMorph setSelection: (self findAnyVariableInSourceCode: varNames)
]

{ #category : #'selecting text' }
ClyMethodCodeEditorToolMorph >> selectSourceNode: anASTNode [

	textMorph setSelection: anASTNode sourceInterval
]

{ #category : #'selecting text' }
ClyMethodCodeEditorToolMorph >> selectVariableNamed: varName [

	self selectAnyVariable: { varName }
]

{ #category : #accessing }
ClyMethodCodeEditorToolMorph >> selectedSourceNode [

	| selectedInterval selectedNode |
	selectedInterval := self selectedTextInterval.
	
	selectedNode := selectedInterval isEmpty 
		ifTrue: [ ast bestNodeForPosition: selectedInterval first ]
		ifFalse: [ ast bestNodeFor: selectedInterval ].
	
	^ selectedNode ifNil: [ ast ]
]

{ #category : #initialization }
ClyMethodCodeEditorToolMorph >> setUpModelFromContext [
	super setUpModelFromContext.

	editingMethod := context lastSelectedMethod
]

{ #category : #initialization }
ClyMethodCodeEditorToolMorph >> setUpParametersFromModel [
	super setUpParametersFromModel.

	self updateMethodTagsAndPackage
]

{ #category : #initialization }
ClyMethodCodeEditorToolMorph >> setUpTargetClasses [

	targetClasses := browser chooseClassesForNewMethod: editingMethod
]

{ #category : #operations }
ClyMethodCodeEditorToolMorph >> switchToMethod: aMethod [
	self detachFromSystem.
	editingMethod := aMethod.
	self attachToSystem.	
	browser selectMethod: editingMethod.
	self update.
]

{ #category : #operations }
ClyMethodCodeEditorToolMorph >> toggleExtendingPackage [
	super toggleExtendingPackage.
	
	self hasUnacceptedEdits ifFalse: [self packageEditingMethod: editingMethod]
]

{ #category : #updating }
ClyMethodCodeEditorToolMorph >> update [

	editingMethod := editingMethod origin 
		localMethodNamed: editingMethod selector ifAbsent: [^self].
	
	super update.
	
	self formatTextIfNeeded.
	
]

{ #category : #updating }
ClyMethodCodeEditorToolMorph >> updateMethodTagsAndPackage [
	
	methodTags := editingMethod tags reject: [ :each | each beginsWith: '*' ].	
	extendingPackage := editingMethod isExtension ifTrue: [ editingMethod package ] ifFalse: [ nil ].
]
