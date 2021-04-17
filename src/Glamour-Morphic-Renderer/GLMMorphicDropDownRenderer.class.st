Class {
	#name : #GLMMorphicDropDownRenderer,
	#superclass : #GLMMorphicBrowserRenderer,
	#instVars : [
		'listModel',
		'dropDownMorph'
	],
	#category : #'Glamour-Morphic-Renderer'
}

{ #category : #rendering }
GLMMorphicDropDownRenderer >> actOnContextChanged: ann [ 
	ann property = #selection ifTrue: [ 
		listModel announcer suspendAllWhile: [
			dropDownMorph listSelectionIndex: (listModel glamourPresentation displayValue indexOf: ann value) ] ]
]

{ #category : #rendering }
GLMMorphicDropDownRenderer >> actOnPresentationUpdated: ann [

	listModel resetData.
	dropDownMorph 
		updateList;
		updateListSelectionIndex
	 
]

{ #category : #rendering }
GLMMorphicDropDownRenderer >> render: aDropListPresentation [
	listModel := GLMDropListModel new glamourPresentation: aDropListPresentation.	"When the morph changes, we want to update the glamour model"
	listModel announcer
		when: GLMDropDownListMorphSelectionChanged
		do: [ :ann | 
			aDropListPresentation selectedIndex: ann selectionIndex.
			aDropListPresentation selection: ann selectionValue ].
	listModel selectionIndex: aDropListPresentation selectedIndex.
	dropDownMorph := (MorphDropListMorph
		on: listModel
		list: #list
		selected: #selectionIndex
		changeSelected: #selectionIndex:
		useIndex: true)
		hResizing: #spaceFill;
		vResizing: #shrinkWrap.
	aDropListPresentation when: GLMContextChanged send: #actOnContextChanged: to: self.
	aDropListPresentation when: GLMPresentationUpdated send: #actOnPresentationUpdated: to: self.
	^ dropDownMorph
]
