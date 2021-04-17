"
I am the adapter used to bridge a TextPresenter and a RubScrolledTextMorph for regular text
"
Class {
	#name : #SpMorphicTextAdapter,
	#superclass : #SpMorphicBaseTextAdapter,
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #initialization }
SpMorphicTextAdapter >> addFocusRotationKeyBindings [
	"Text areas needs to be able to process tab. Cancel the binding."
]

{ #category : #'protocol-shortcuts' }
SpMorphicTextAdapter >> bindKeyCombination: aShortcut toAction: aBlock [ 

	self widgetDo: [ :w | 
		w textArea
			bindKeyCombination: aShortcut 
			toAction: aBlock ]
]

{ #category : #factory }
SpMorphicTextAdapter >> buildWidget [
	| newWidget |
	
	newWidget := (SpRubScrolledTextMorph on: self)
		getTextSelector: #getText;
		setTextSelector: #accept:notifying:;
		getSelectionSelector: #readSelection;
		menuProvider: self selector: #codePaneMenu:shifted:;
		setSelectionSelector: #setSelection:;
		ghostText: self placeholder;
		beWrapped;
		enabled: self enabled;
		askBeforeDiscardingEdits: self askBeforeDiscardingEdits;
		autoAccept: true;
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		setBalloonText: self help;
		dragEnabled: self dragEnabled;
		dropEnabled: self dropEnabled;
		registerScrollChanges: #scrollValueChanged:;
		hScrollbarShowWhenNeeded;
		yourself.
	
	self setEditable: self presenter isEditable to: newWidget.
	self setEditingModeFor: newWidget.
	self setText: self presenter text to: newWidget.

	self setWrapWord: self presenter isWrapWord to: newWidget.	
	self presenter whenTextChangedDo: [ :text | 
		self setText: text to: newWidget ].
	self presenter whenSelectionChangedDo: [ :selectionInterval | 
		self selectionInterval: selectionInterval ].
	self presenter whenPlaceholderChangedDo: [ :text | 
		self setGhostText: text to: newWidget ].
	self presenter whenEditableChangedDo: [ :value | 
		self setEditable: value to: newWidget ].
	self presenter whenWrapWordChangedDo: [ :value | 
		self setWrapWord: value to: newWidget ].
	
	^ newWidget
]

{ #category : #'widget API' }
SpMorphicTextAdapter >> codePaneMenu: aMenu shifted: shifted [

	| menuPresenter |
	menuPresenter := self model contextMenu value
		                 ifNotNil: [ :contextMenu | contextMenu ]
		                 ifNil: [ SpMenuPresenter new ].
	self presenter hasEditionContextMenu ifTrue: [ 
		self presenter editionContextMenu menuGroups do: [ :each | 
			menuPresenter addMenuGroup: each ] ].
	^ SpBindings
		  value: self model application adapterBindings
		  during: [ menuPresenter value buildWithSpec ]
]

{ #category : #commands }
SpMorphicTextAdapter >> copyText [

	self editor copySelection
]

{ #category : #'widget API' }
SpMorphicTextAdapter >> cursorPosition [

	^ self widgetDo: [ :w |
		w textArea selectionStart
			ifNotNil: [ :sel | self linePositionOf: sel ] ]
]

{ #category : #'widget API' }
SpMorphicTextAdapter >> cursorPositionIndex: index [ 

	self widgetDo: [ :w | ^ w textArea editor pointIndex: index ]
]

{ #category : #commands }
SpMorphicTextAdapter >> cutText [

	self editor cut
]

{ #category : #private }
SpMorphicTextAdapter >> editor [

	^ widget textArea editor
]

{ #category : #private }
SpMorphicTextAdapter >> eventHandlerReceiver: aWidget [

	^ aWidget textArea
]

{ #category : #commands }
SpMorphicTextAdapter >> findNextText [

	self editor findAgain
]

{ #category : #commands }
SpMorphicTextAdapter >> findText [

	self editor find
]

{ #category : #private }
SpMorphicTextAdapter >> linePositionOf: sel [

	| textLine linePosition |
	textLine := sel textLine.
	linePosition := sel stringIndex - textLine first + 1.
	^ linePosition @ textLine lineNumber
]

{ #category : #commands }
SpMorphicTextAdapter >> pasteText [

	self editor paste
]

{ #category : #styling }
SpMorphicTextAdapter >> presenterStyles [
	"The presenters in the style"

	^ self presenter scrollBarStyles, self presenter styles 
]

{ #category : #commands }
SpMorphicTextAdapter >> selectAndPasteText [

	self editor pasteRecent
]

{ #category : #private }
SpMorphicTextAdapter >> setEditable: aBoolean to: aWidget [

	aWidget textArea readOnly: aBoolean not
]

{ #category : #private }
SpMorphicTextAdapter >> setGhostText: text to: aWidget [

	aWidget ghostText: text
]

{ #category : #private }
SpMorphicTextAdapter >> setText: text to: aWidget [

	aWidget setText: text.
	self updateExtentPropagationOf: text on: aWidget

]

{ #category : #private }
SpMorphicTextAdapter >> setWrapWord: aBoolean to: aWidget [

	aBoolean 
		ifTrue: [ aWidget beWrapped ]
		ifFalse: [ aWidget beNotWrapped ]
]

{ #category : #private }
SpMorphicTextAdapter >> updateExtentPropagationOf: string on: aWidget [
	| stringMorph width height |

	(self presenter isPropagateNaturalWidth 
		or: [ self presenter isPropagateNaturalHeight ])
		ifFalse: [ ^ self ].

	"This is an incredible ugly hack because what should be the correct way of doing it: 
	 Font>>widthOfString: does not works (because it fails to take into account kerning).
	 Why it works on the Editing area is a mystery. 
	 BUT! It does not work for monospaced fonts! (again, no idea why)"
	stringMorph := RubEditingArea new 
		font: aWidget font;
		updateTextWith: string asString.

	width := stringMorph width + 12" min: self currentWorld width / 3".
	self presenter isPropagateNaturalWidth 
		ifTrue: [ aWidget width: width ].

	self presenter isPropagateNaturalHeight 
		ifTrue: [ 
			height := ((stringMorph
				beWrapped;
				width: width;
				yourself) height + 2)"min: self currentWorld height / 3". 
			aWidget height: height ]
]
