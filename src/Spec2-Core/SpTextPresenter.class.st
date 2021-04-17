"
A presenter to handle basic multi-line text.
"
Class {
	#name : #SpTextPresenter,
	#superclass : #SpAbstractTextPresenter,
	#traits : 'SpTHaveWrappingScrollBars',
	#classTraits : 'SpTHaveWrappingScrollBars classTrait',
	#instVars : [
		'#scrollValue => SpObservableSlot',
		'#editionContextMenu => SpObservableSlot',
		'#editable => SpObservableSlot',
		'#cursorPosition => SpObservableSlot',
		'#wrapWord => SpObservableSlot'
	],
	#category : #'Spec2-Core-Widgets-Text'
}

{ #category : #specs }
SpTextPresenter class >> adapterName [

	^ #TextAdapter
]

{ #category : #commands }
SpTextPresenter class >> buildEditionCommandsGroupFor: presenterInstance [
	| rootCommandGroup |

	rootCommandGroup := CmCommandGroup forSpec beRoot.
	self 
		buildEditionCommandsGroupWith: presenterInstance 
		forRoot: rootCommandGroup.
	
	^ rootCommandGroup
]

{ #category : #commands }
SpTextPresenter class >> buildEditionCommandsGroupWith: presenter forRoot: aCmCommandsGroup [

	aCmCommandsGroup beDisplayedAsGroup.
	aCmCommandsGroup register: (self textSearchCommandsGroupWith: presenter).	
	aCmCommandsGroup register: (self textEditionCommandsGroupWith: presenter).
]

{ #category : #documentation }
SpTextPresenter class >> documentFactoryMethodSelector [

	^ #newText
]

{ #category : #commands }
SpTextPresenter class >> textEditionCommandsGroupWith: aPresenter [
	| group |

	group := (CmCommandGroup named: 'Selection edition commands') asSpecGroup.
	group
		description: 'Edit code selection.';
		beDisplayedAsGroup.
	
	SpTextEditionCommand allOrdered 
		do: [ :commandClass | group register: (commandClass forSpecContext: aPresenter) ].
	
	^ group
]

{ #category : #commands }
SpTextPresenter class >> textSearchCommandsGroupWith: aPresenter [
	| group |

	group := (CmCommandGroup named: 'Search commands') asSpecGroup.
	group
		description: 'Search text.';
		beDisplayedAsGroup.
	
	SpTextSearchCommand allOrdered 
		do: [ :commandClass | group register: (commandClass forSpecContext: aPresenter) ].
	
	^ group
]

{ #category : #specs }
SpTextPresenter class >> title [

	^ 'Text'
]

{ #category : #api }
SpTextPresenter >> beEditable [
	"Allow edition (deny readonly)."

	self editable: true
]

{ #category : #api }
SpTextPresenter >> beNotEditable [
	"Set content text as not editable (readonly)"

	self editable: false
]

{ #category : #api }
SpTextPresenter >> beNotWrapWord [
	"Set component to not wrap words when text does not fit in screen.
	 Instead, the editor will add an horizontal scrollbar."

	self wrapWord: false
]

{ #category : #api }
SpTextPresenter >> beWrapWord [
	"Set component to wrap words to make the text fit in screen."

	self wrapWord: true
]

{ #category : #api }
SpTextPresenter >> cursorPosition [
	"Answer a Point (column, row) with current cursor position"

	^ self withAdapterDo: [ :anAdapter | anAdapter cursorPosition ]
]

{ #category : #commands }
SpTextPresenter >> doTextCopy [

	self withAdapterDo: [ :anAdapter | anAdapter copyText ]
]

{ #category : #commands }
SpTextPresenter >> doTextCut [

	self withAdapterDo: [ :anAdapter | anAdapter cutText ]
]

{ #category : #commands }
SpTextPresenter >> doTextFind [

	self withAdapterDo: [ :anAdapter | anAdapter findText ]
]

{ #category : #commands }
SpTextPresenter >> doTextFindNext [

		self withAdapterDo: [ :anAdapter | anAdapter findNextText ]
]

{ #category : #commands }
SpTextPresenter >> doTextPaste [

		self withAdapterDo: [ :anAdapter | anAdapter pasteText ]
]

{ #category : #commands }
SpTextPresenter >> doTextSelectAndPaste [

	self withAdapterDo: [ :anAdapter | anAdapter selectAndPasteText ]
]

{ #category : #private }
SpTextPresenter >> editable: aBoolean [

	editable := aBoolean
]

{ #category : #private }
SpTextPresenter >> editionCommandsGroup [

	^ SpRecursiveContextSetter 
		visit: (self class buildEditionCommandsGroupFor: self defaultCommandsContext) 
		toSetContext: self defaultCommandsContext
]

{ #category : #private }
SpTextPresenter >> editionContextKeyBindings [

	^ self editionCommandsGroup asKMCategory
]

{ #category : #private }
SpTextPresenter >> editionContextMenu [

	^ self editionCommandsGroup asMenuPresenter
]

{ #category : #'private testing' }
SpTextPresenter >> hasEditionContextMenu [

	^ editionContextMenu
]

{ #category : #initialization }
SpTextPresenter >> initialize [ 

	super initialize.
	self initializeTHaveWrappingScrollBars.
	self flag: #REVIEW. "We really need scrollValue?"
	scrollValue := 0@0.
	self beEditable.
	self beWrapWord.
	self withScrollBars.
	self withEditionContextMenu.
]

{ #category : #testing }
SpTextPresenter >> isEditable [
	"Answer true if edition is allowed (component is NOT readonly)"

	^ editable
]

{ #category : #testing }
SpTextPresenter >> isWrapWord [
	"Answer true if words will be wrapped to make text fit horizontally into component area."

	^ wrapWord
]

{ #category : #initialization }
SpTextPresenter >> registerEvents [

	super registerEvents.
	self whenScrollValueChangedDo: [ :newPosition | 
		self changed: #setScrollValue: with: { newPosition } ]
]

{ #category : #api }
SpTextPresenter >> scrollValue [
	"Return the current scroll position"

	^ scrollValue
]

{ #category : #api }
SpTextPresenter >> scrollValue: aPoint [
	"Set the scroll position"

	^ scrollValue := aPoint
]

{ #category : #'api-events' }
SpTextPresenter >> whenCursorPositionChangedDo: aBlock [
	"Inform when cursorPosition property has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"

	self property: #cursorPosition whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpTextPresenter >> whenEditableChangedDo: aBlock [
	"Inform when editable property has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"

	self property: #editable whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpTextPresenter >> whenScrollValueChangedDo: aBlock [
	"Inform when scrollValue property has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"
	
	self property: #scrollValue whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpTextPresenter >> whenSubmitDo: aBlock [
	"This method will add a 'submit' event to the widget. It will react when user 
	 presses <meta+s> key (this is for historical reasons) and with enter (cr)."

	self 
		bindKeyCombination: $s meta 
		toAction: [ aBlock value: self text ]
]

{ #category : #'api-events' }
SpTextPresenter >> whenWrapWordChangedDo: aBlock [
	"Inform when wordWrap property has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"

	self property: #wrapWord whenChangedDo: aBlock
]

{ #category : #api }
SpTextPresenter >> withEditionContextMenu [
	"Enables edition context menu. When this option is selected, right-clicking in the text area 
	 will show a standard edition menu (copy, cut, copy&paste). 
	 Adding your own context menu (See `SpAbstractTextPresenter>>#contextMenu:`) will make both 
	 menus (edition and your own) to be combined into one single context menu."

	editionContextMenu := true
]

{ #category : #api }
SpTextPresenter >> withoutEditionContextMenu [
	"Disable default edition context menu. 
	 See also `SpTextPresenter>>#withEditionContextMenu`."

	editionContextMenu := false
]

{ #category : #private }
SpTextPresenter >> wrapWord: aBoolean [

	wrapWord := aBoolean
]
