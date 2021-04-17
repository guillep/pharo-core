"
I'm an abstract superclass for Morphic text adapters
"
Class {
	#name : #SpMorphicBaseTextAdapter,
	#superclass : #SpAbstractMorphicAdapter,
	#traits : 'TViewModel',
	#classTraits : 'TViewModel classTrait',
	#instVars : [
		'selection'
	],
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #testing }
SpMorphicBaseTextAdapter class >> isAbstract [

	^ self name = #SpMorphicBaseTextAdapter
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> accept: aString notifying: aNotifyier [

	self presenter text: aString.
	"Raise an announcement"
	self presenter changed: #clearUserEdits.

	^ true
]

{ #category : #accessing }
SpMorphicBaseTextAdapter >> acceptAllowed [

	^ self widget editingMode acceptAllowed
]

{ #category : #initialization }
SpMorphicBaseTextAdapter >> addKeyBindingsTo: aMorph [

	super addKeyBindingsTo: aMorph.
	self 
		bindKeyCombination: Character escape asKeyCombination 
			toAction: [ :target :morph :event | self bubbleUpEvent: event ];
		bindKeyCombination: $t meta 
			toAction: [ self showContextMenu ]
]

{ #category : #accessing }
SpMorphicBaseTextAdapter >> announcer [

	^ self model announcer
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> askBeforeDiscardingEdits [

	^ self model askBeforeDiscardingEdits
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> askBeforeDiscardingEdits: aBoolean [

	self widget askBeforeDiscardingEdits: aBoolean
]

{ #category : #private }
SpMorphicBaseTextAdapter >> bubbleUpEvent: anEvent [

	anEvent wasHandled: false.
	self presenter window adapter widget handleEvent: anEvent
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> canChangeText [

	^ self widget textArea canChangeText
]

{ #category : #'undo-redo' }
SpMorphicBaseTextAdapter >> clearUndoManager [

	self widget textArea editingState clearUndoManager: nil
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> clearUserEditFlag [

	self model text: self getText.
	self changed: #clearUserEdits
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> codePaneMenu: aMenu shifted: shifted [

	| menuPresenter |
	menuPresenter := self model contextMenu.
	menuPresenter ifNil: [ ^ nil ].
	^ SpBindings
		  value: self model application adapterBindings
		  during: [ menuPresenter value buildWithSpec ]
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> cursorPositionIndex [

	self widgetDo: [ :w | ^ w textArea editor pointIndex ]
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> cursorPositionIndex: index [ 

	self subclassResponsibility
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> font: aFont [

	self widgetDo: [ :w | w font: aFont ]
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> getText [

	^ self model text
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> hasEditingConflicts: aBoolean [
 
	self widgetDo: [ :w | w hasEditingConflicts: aBoolean ]
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> hasUnacceptedEdits: aBoolean [

	self model hasUnacceptedEdits: aBoolean
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> insert: aString at: positionIndex [

	| text |
	text := self getText.
	text := String streamContents: [ :stream | 
		        stream << (text copyFrom: 1 to: positionIndex).
		        stream << aString.
		        text size > positionIndex ifTrue: [ 
			        stream << (text copyFrom: positionIndex + 1 to: text size) ] ].

	self presenter text: text
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> notify: errorMessage at: position in: sourceCode [

	self widgetDo: [ :w | 
		w notify: errorMessage at: position in: sourceCode ]
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> pendingText [

	^ self widgetDo: [ :w | w text ]
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> pendingText: aText [

	self widgetDo: [ :w | 
		w 
			setText: aText;
			hasUnacceptedEdits: true ]
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> placeholder [

	^ self model placeholder
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> placeholder: aText [

	^ self model placeholder: aText
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> readSelection [

	^ self model readSelection
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> scrollValueChanged: aValue [

	self model scrollValue: aValue step
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> selectAll [

	self widgetDo: [ :w | w selectAll ]
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> selectFrom: nodeStart to: nodeStop [

	self widget selectFrom: nodeStart to: nodeStop
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> selectLine [

	self widgetDo: [ :w | w textArea editor selectLine ]
]

{ #category : #accessing }
SpMorphicBaseTextAdapter >> selection [

	^ selection
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> selectionInterval [

	^ self widget selectionInterval
]

{ #category : #private }
SpMorphicBaseTextAdapter >> selectionInterval: anInterval [

	self widgetDo: [ :w | 
		w textArea editor selectFrom: anInterval first to: anInterval last ]
]

{ #category : #private }
SpMorphicBaseTextAdapter >> setEditingModeFor: textArea [

	textArea beForPlainText
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> setHasUnacceptedEdits: aBoolean [

	self widgetDo: [ :w | w basicHasUnacceptedEdits: aBoolean ]
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> setScrollValue: aValue [

	self widgetDo: [ :w | 
		w scrollPane
			hScrollbarValue: aValue x;
			vScrollbarValue: aValue y;
			updateScrollbars ]
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> setSelection: interval [

	selection := interval
]

{ #category : #'spec protocol' }
SpMorphicBaseTextAdapter >> setSelectionFromModel: aSelection [

	self widget ifNotNil: [ :w | w setSelection: aSelection ]
]

{ #category : #initialization }
SpMorphicBaseTextAdapter >> showContextMenu [

	self widgetDo: [ :w | 
		(w textArea getMenu: false) ifNotNil: [ :menu | 
			menu
				invokeAt: w position + w textArea cursor center
				in: self currentWorld ] ]
]

{ #category : #'widget API' }
SpMorphicBaseTextAdapter >> wantsVisualFeedback [

	^ self model wantsVisualFeedback
]
