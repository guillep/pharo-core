"
unselectedItems is the original list to search in

selectItems is the list of the selected items
"
Class {
	#name : #DialogItemsChooserUI,
	#superclass : #DialogWindowMorph,
	#instVars : [
		'dialogItemsChooser',
		'selectedItems',
		'unselectedItems',
		'unselectedItemsSearchingString',
		'selectedItemsSearchingString',
		'selectedSelectionIndex',
		'selectedSelectionList',
		'unselectedSelectionList',
		'unselectedSelectionIndex'
	],
	#category : #'Tool-Finder-UI'
}

{ #category : #'instance creation' }
DialogItemsChooserUI class >> on: aDialogItemsChooser [
	^self basicNew 
		unselectedItems: aDialogItemsChooser unselectedItems;
		selectedItems: aDialogItemsChooser selectedItems;
		dialogItemsChooser: aDialogItemsChooser;
		initialize.
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> addAllButtonAction [
	self addAllItems
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> addAllButtonLabel [
	^'>>'
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> addAllButtonState [
	^false
]

{ #category : #'buttons behavior' }
DialogItemsChooserUI >> addAllItems [

	| selection |
	selection := self unselectedItemsProbablyRestricted.
	selection ifEmpty: [^self].
	self unselectedItems removeAll: selection.
	self selectedItems addAll: selection.
	unselectedSelectionList removeAll.
	self unselectedSelectionIndex: 0.
	self
		changed: #selectedItemsProbablyRestricted;
		changed: #hasSelectedItems;
		changed: #unselectedItemsProbablyRestricted;
		changed: #hasUnselectedItems;
		changed: #hasUnselectedSelections
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> addButtonAction [
	self addSelectedItems
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> addButtonLabel [
	^'>'
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> addButtonState [
	^false
]

{ #category : #'buttons behavior' }
DialogItemsChooserUI >> addSelectedItems [

	| selection |
	selection := self unselectedSelectionItems.
	selection ifEmpty: [^self].
	self unselectedItems removeAll: selection.
	self selectedItems addAll: selection.
	unselectedSelectionList removeAll.
	self unselectedSelectionIndex: 0.
	self
		changed: #selectedItemsProbablyRestricted;
		changed: #hasSelectedItems;
		changed: #unselectedItemsProbablyRestricted;
		changed: #hasUnselectedItems;
		changed: #hasUnselectedSelections
]

{ #category : #private }
DialogItemsChooserUI >> applyChanges [
	self valid
]

{ #category : #'build items' }
DialogItemsChooserUI >> buildAddAllButton [
	"Answer a new button for removing all items
	form the unslected list and adding to the selected list."
	
	^(self
		newButtonFor: self
		getState: #addAllButtonState
		action: #addAllButtonAction 
		arguments: nil
		getEnabled: #hasUnselectedItems
		getLabel: #addAllButtonLabel
		help: nil)
		hResizing: #spaceFill
]

{ #category : #'build items' }
DialogItemsChooserUI >> buildAddButton [
	"Answer a new button for removing selected items
	from the unselected list and adding to the selected list."
	
	^(self
		newButtonFor: self
		getState: #addButtonState
		action: #addButtonAction 
		arguments: nil
		getEnabled: #hasUnselectedSelections
		getLabel: #addButtonLabel
		help: nil)
		hResizing: #spaceFill
]

{ #category : #'build items' }
DialogItemsChooserUI >> buildRemoveAllButton [
	"Answer a new button for removing all items from the
	selected list and adding to the unselected list."
	
	^(self
		newButtonFor: self
		getState: #removeAllButtonState
		action: #removeAllButtonAction
		arguments: nil
		getEnabled: #hasSelectedItems
		getLabel: #removeAllButtonLabel
		help: nil)
		hResizing: #spaceFill
]

{ #category : #'build items' }
DialogItemsChooserUI >> buildRemoveButton [
	"Answer a new button for removing selected items
	from the selected list and adding to the unselected list."
	
	^(self
		newButtonFor: self
		getState: #removeButtonState
		action: #removeButtonAction 
		arguments: nil
		getEnabled: #hasSelectedSelections
		getLabel: #removeButtonLabel
		help: nil)
		hResizing: #spaceFill
]

{ #category : #'build items' }
DialogItemsChooserUI >> buildSelectedItemsList [

	^(PluggableListMorph
		on: self 
		list: #selectedItemsProbablyRestricted 
		primarySelection: #selectedSelectionIndex
		changePrimarySelection: #selectedSelectionIndex:
		listSelection: #selectedSelectionAt:
		changeListSelection: #selectedSelectionAt:put:
		menu: nil)
			hResizing: #spaceFill;
			vResizing: #spaceFill
]

{ #category : #'build items' }
DialogItemsChooserUI >> buildSelectedItemsSearchingTextArea: aWindow [

	^aWindow
		newAutoAcceptTextEntryFor: self
		get: #selectedItemsSearchingString
		set: #selectedItemsSearchingString:
		class: String
		getEnabled: nil
		help: 'Enter the name of a package' translated
]

{ #category : #'build items' }
DialogItemsChooserUI >> buildUnselectedItemsList [

	^(PluggableListMorph
		on: self 
		list: #unselectedItemsProbablyRestricted 
		primarySelection: #unselectedSelectionIndex
		changePrimarySelection: #unselectedSelectionIndex:
		listSelection: #unselectedSelectionAt:
		changeListSelection: #unselectedSelectionAt:put:
		menu: nil)
			hResizing: #spaceFill;
			vResizing: #spaceFill
]

{ #category : #'build items' }
DialogItemsChooserUI >> buildUnselectedItemsSearchingTextArea: aWindow [

	^aWindow
		newAutoAcceptTextEntryFor: self
		get: #unselectedItemsSearchingString
		set: #unselectedItemsSearchingString:
		class: String
		getEnabled: nil
		help: 'Enter the name of a package' translated
]

{ #category : #display }
DialogItemsChooserUI >> centering [

	self left: ((ActiveWorld width / 2) - (self width /2)) rounded.
	self top: ((ActiveWorld height / 2) - (self height /2)) rounded
]

{ #category : #accessing }
DialogItemsChooserUI >> dialogItemsChooser [
	^ dialogItemsChooser
]

{ #category : #accessing }
DialogItemsChooserUI >> dialogItemsChooser: aDialogItemsChooser [
	dialogItemsChooser := aDialogItemsChooser
]

{ #category : #selectedList }
DialogItemsChooserUI >> hasSelectedItems [
	"Answer whether the selected list has items."

	^self selectedItems notEmpty
]

{ #category : #selectedList }
DialogItemsChooserUI >> hasSelectedSelections [
	"Answer whether the selected list has selected items."

	^selectedSelectionList anySatisfy: [:selected | selected]
]

{ #category : #unselectedList }
DialogItemsChooserUI >> hasUnselectedItems [
	"Answer whether the unselected list has items."

	^self unselectedItems notEmpty
]

{ #category : #unselectedList }
DialogItemsChooserUI >> hasUnselectedSelections [
	"Answer whether the unselected list has selected items."

	^unselectedSelectionList anySatisfy: [:selected | selected ]
]

{ #category : #initialization }
DialogItemsChooserUI >> initialize [

	unselectedItemsSearchingString := String new.
	selectedItemsSearchingString := String new.
	selectedSelectionList := Dictionary new.
	unselectedSelectionList := Dictionary new.
	
	super initialize.
	
	self vResizing: #shrinkWrap.
	self hResizing: #shrinkWrap
]

{ #category : #display }
DialogItemsChooserUI >> isResizeable [
	^true
]

{ #category : #actions }
DialogItemsChooserUI >> newContentMorph [
	| trees unselectedItemsCol selectedItemsCol buttons |
	buttons := (self newGroupboxFor: (
		(self newColumn: {
			self buildAddAllButton.
			self buildAddButton.
			self buildRemoveButton.
			self buildRemoveAllButton})
			vResizing: #shrinkWrap))
		vResizing: #shrinkWrap.
	
	unselectedItemsCol := self newGroupbox: self unselectedLabel for: (self newColumn: {
							self buildUnselectedItemsSearchingTextArea: self.
							self buildUnselectedItemsList.}).
	selectedItemsCol := self newGroupbox: self selectedLabel for: (self newColumn: {
							self buildSelectedItemsSearchingTextArea: self.
							self buildSelectedItemsList.}).
	trees := self newRow: {
					unselectedItemsCol.
					"self newGroupboxFor: self buildUnselectedItemsTree."
					buttons hResizing: #shrinkWrap.
					selectedItemsCol}.
	^trees vResizing: #spaceFill

]

{ #category : #opening }
DialogItemsChooserUI >> preOpenInWorld: aWorld [

	self width: 500.
	self height: 400.
	self centering
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> removeAllButtonAction [
	self removeAllItems
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> removeAllButtonLabel [
	^'<<'
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> removeAllButtonState [
	^false
]

{ #category : #'buttons behavior' }
DialogItemsChooserUI >> removeAllItems [

	| selection |
	selection := self selectedItemsProbablyRestricted.
	selection ifEmpty: [^self].
	self selectedItems removeAll: selection.
	self unselectedItems addAll: selection.
	selectedSelectionList removeAll.
	self selectedSelectionIndex: 0.
	self
		changed: #selectedItemsProbablyRestricted;
		changed: #hasSelectedItems;
		changed: #hasSelectedSelections;
		changed: #unselectedItemsProbablyRestricted;
		changed: #hasUnselectedItems
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> removeButtonAction [
	self removeSelectedItems
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> removeButtonLabel [
	^ '<'
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> removeButtonState [
	^ false
]

{ #category : #'buttons behavior' }
DialogItemsChooserUI >> removeSelectedItems [

	| selection |
	selection := self selectedSelectionItems.
	selection ifEmpty: [^self].
	self selectedItems removeAll: selection.
	self unselectedItems addAll: selection.
	selectedSelectionList removeAll.
	self selectedSelectionIndex: 0.
	self
		changed: #selectedItemsProbablyRestricted;
		changed: #hasSelectedItems;
		changed: #hasSelectedSelections;
		changed: #unselectedItemsProbablyRestricted;
		changed: #hasUnselectedItems
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> searchButtonLabel [
	^'Search'
]

{ #category : #'buttons creations' }
DialogItemsChooserUI >> searchButtonState [
	^ false
]

{ #category : #accessing }
DialogItemsChooserUI >> selectedItems [
	^ selectedItems
]

{ #category : #accessing }
DialogItemsChooserUI >> selectedItems: aList [
	selectedItems := aList.
]

{ #category : #private }
DialogItemsChooserUI >> selectedItemsProbablyRestricted [

	| matcher string |
	string := self selectedItemsSearchingString.
	matcher := string
					ifEmpty: ['*']
					ifNotEmpty: [
						(string last = $*) 
							ifTrue: [string]
							ifFalse:[string, '*']].
	^self selectedItems select: [:each | matcher asString match: each].
]

{ #category : #accessing }
DialogItemsChooserUI >> selectedItemsSearchingString [

	^ selectedItemsSearchingString
]

{ #category : #accessing }
DialogItemsChooserUI >> selectedItemsSearchingString: anObject [

	selectedItemsSearchingString := anObject.
	selectedSelectionList removeAll.
	self selectedSelectionIndex: 0.
	self
		changed: #selectedItemsProbablyRestricted;
		changed: #selectedSelectionAt:;
		changed: #selectedSelectionIndex;
		changed: #hasSelectedSelections
]

{ #category : #accessing }
DialogItemsChooserUI >> selectedLabel [

	^ self dialogItemsChooser
		ifNil: [ 'Selected Items' translated ]
		ifNotNil: [ self dialogItemsChooser selectedLabel ]
]

{ #category : #selectedList }
DialogItemsChooserUI >> selectedSelectionAt: index [

	^selectedSelectionList at: index ifAbsent: [false]
]

{ #category : #selectedList }
DialogItemsChooserUI >> selectedSelectionAt: index put: aBoolean [
	"Mark the item as selected or not."
	
	selectedSelectionList at: index put: aBoolean.
	self changed: #hasSelectedSelections
]

{ #category : #selectedList }
DialogItemsChooserUI >> selectedSelectionIndex [
	^ selectedSelectionIndex ifNil: [selectedSelectionIndex := 0]
]

{ #category : #selectedList }
DialogItemsChooserUI >> selectedSelectionIndex: anObject [

	selectedSelectionIndex := anObject.
	self changed: #selectedSelectionIndex
]

{ #category : #'buttons behavior' }
DialogItemsChooserUI >> selectedSelectionItems [

	| result |
	result := OrderedCollection new.
	self selectedItemsProbablyRestricted doWithIndex: [:item :index |
		(self selectedSelectionAt: index)
			ifTrue: [result add: item]].
	^result
]

{ #category : #accessing }
DialogItemsChooserUI >> unselectedItems [
	^unselectedItems
]

{ #category : #accessing }
DialogItemsChooserUI >> unselectedItems: anOrderedCollection [ 
	
	unselectedItems := anOrderedCollection.
]

{ #category : #private }
DialogItemsChooserUI >> unselectedItemsProbablyRestricted [

	| matcher string |
	string := self unselectedItemsSearchingString.
	matcher := string
					ifEmpty: ['*']
					ifNotEmpty: [
						(string last = $*) 
							ifTrue: [string]
							ifFalse:[string, '*']].
	^self unselectedItems select: [:each | matcher match: each].
]

{ #category : #accessing }
DialogItemsChooserUI >> unselectedItemsSearchingString [

	^ unselectedItemsSearchingString
]

{ #category : #accessing }
DialogItemsChooserUI >> unselectedItemsSearchingString: anObject [

	unselectedItemsSearchingString := anObject.
	unselectedSelectionList removeAll.
	self unselectedSelectionIndex: 0.
	self
		changed: #unselectedItemsProbablyRestricted;
		changed: #unselectedSelectionAt:;
		changed: #unselectedSelectionIndex;
		changed: #hasUnselectedSelections
]

{ #category : #accessing }
DialogItemsChooserUI >> unselectedLabel [

	^ self dialogItemsChooser
		ifNil: [ 'Unselected Items' translated ]
		ifNotNil: [ self dialogItemsChooser unselectedLabel ]
]

{ #category : #unselectedList }
DialogItemsChooserUI >> unselectedSelectionAt: index [

	^unselectedSelectionList at: index ifAbsent: [false]
]

{ #category : #unselectedList }
DialogItemsChooserUI >> unselectedSelectionAt: index put: aBoolean [
	"Mark the item as selected or not."
	
	unselectedSelectionList at: index put: aBoolean.
	self changed: #hasUnselectedSelections
]

{ #category : #unselectedList }
DialogItemsChooserUI >> unselectedSelectionIndex [
	^unselectedSelectionIndex ifNil: [unselectedSelectionIndex := 0]
]

{ #category : #unselectedList }
DialogItemsChooserUI >> unselectedSelectionIndex: anObject [

	unselectedSelectionIndex := anObject.
	self changed: #unselectedSelectionIndex
]

{ #category : #'buttons behavior' }
DialogItemsChooserUI >> unselectedSelectionItems [

	| result |
	result := OrderedCollection new.
	self unselectedItemsProbablyRestricted doWithIndex: [:item :index |
		(self unselectedSelectionAt: index)
			ifTrue: [result add: item]].
	^result
]

{ #category : #private }
DialogItemsChooserUI >> valid [
	self dialogItemsChooser sendSelection
]
