"
I am an editor of class definition.
I allow to modify class properties (package, tags and variables) using text editor.

And in addition I allow to create new classes by typing new class name
"
Class {
	#name : #ClyClassDefinitionEditorToolMorph,
	#superclass : #ClyClassEditorToolMorph,
	#category : #'Calypso-SystemTools-Core-Editors-Classes'
}

{ #category : #building }
ClyClassDefinitionEditorToolMorph >> applyChanges [

	| text |
	text := self pendingText copy.
	^ self applyChangesAsClassDefinition or: [ 
		  self pendingText: text.
		  self applyChangesAsMethodDefinition ]
]

{ #category : #building }
ClyClassDefinitionEditorToolMorph >> applyChangesAsClassDefinition [

	| newClass oldText |
	oldText := self pendingText copy.
	newClass := browser
		            compileANewClassFrom: self pendingText asString
		            notifying: textMorph
		            startingFrom: editingClass.
	
	"This was indeed a class, however, there is a syntax error somewhere"
	textMorph text = oldText ifFalse: [ ^ true ].
	
	newClass ifNil: [ ^ false ].

	editingClass == newClass ifFalse: [ self removeFromBrowser ].
	browser selectClass: newClass.
	^ true
]

{ #category : #building }
ClyClassDefinitionEditorToolMorph >> applyChangesAsMethodDefinition [

	| newMethod selector selectedClass |
	selectedClass := self editingClass.

	selector := selectedClass
		            compile: self pendingText asString
		            notifying: textMorph.

	selector ifNil: [ ^ false ].
	newMethod := selectedClass >> selector.
	MethodClassifier classify: newMethod.

	self removeFromBrowser.
	browser tabManager desiredSelection: { ClyMethodCodeEditorToolMorph }.
	browser selectMethod: newMethod.
	^ true
]

{ #category : #'to sort' }
ClyClassDefinitionEditorToolMorph >> createTextContext [
	^self selectedSourceNode
		ifNil: [ super createTextContext ]
		ifNotNil: [ :astNode | ClyClassDefinitionContext for: self selectedNode: astNode]
]

{ #category : #building }
ClyClassDefinitionEditorToolMorph >> decorateContainerTab [
	| title |
	super decorateContainerTab.
	title := editingClass name.

	editingClass isClassSide 
		ifTrue: [ title := title asText allBold ].

	containerTab label: title
]

{ #category : #initialization }
ClyClassDefinitionEditorToolMorph >> defaultIconName [
	^#classIcon
]

{ #category : #'to sort' }
ClyClassDefinitionEditorToolMorph >> editingText [
	
	^ editingClass definitionString
]

{ #category : #building }
ClyClassDefinitionEditorToolMorph >> fillStatusBar [ 
	super fillStatusBar.
	statusBar addCommandItem: (ClyFluidClassDefinitionSwitchMorph for: self)
]

{ #category : #testing }
ClyClassDefinitionEditorToolMorph >> isCommandAvailable: aCommand [ 

	^ aCommand canBeExecutedInClassEditor: self
]

{ #category : #'to sort' }
ClyClassDefinitionEditorToolMorph >> parseClassDefinition [

	self editingClass needsSlotClassDefinition 
		ifTrue: [ ^ ClassDefinitionPrinter fluid classDefinitionParserClass parse: self editingText].
	^ ClassDefinitionPrinter new classDefinitionParserClass parse: self editingText
]

{ #category : #'selecting text' }
ClyClassDefinitionEditorToolMorph >> selectSourceNode: aCDNode [ 
	textMorph setSelection: aCDNode sourceInterval
]

{ #category : #'selecting text' }
ClyClassDefinitionEditorToolMorph >> selectVariableNamed: aString [ 
	| classDefinition varNode |
	classDefinition := self parseClassDefinition.
	varNode := classDefinition children 
		detect: [ :each | each isVariable and: [each name = aString]]
		ifNone: [ ^self ].
	self selectSourceNode: varNode
]

{ #category : #accessing }
ClyClassDefinitionEditorToolMorph >> selectedSourceNode [
	| selectedInterval definitionNode |
	selectedInterval := self selectedTextInterval.
	definitionNode := self parseClassDefinition.
	
	^(definitionNode bestNodeFor: selectedInterval)
		ifNil: [ definitionNode ]
]

{ #category : #initialization }
ClyClassDefinitionEditorToolMorph >> setUpModelFromContext [

	super setUpModelFromContext.
	editingClass := context selectedClassSide
]
