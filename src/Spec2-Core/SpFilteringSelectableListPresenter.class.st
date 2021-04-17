"
A presenter to show a list that can be filter, and which elements are selectable.
"
Class {
	#name : #SpFilteringSelectableListPresenter,
	#superclass : #SpFilteringListPresenter,
	#instVars : [
		'selectColumn',
		'displayBlock',
		'displayIconBlock',
		'selectedItems',
		'previousSelectedIndex'
	],
	#category : #'Spec2-Core-Widgets-Advanced'
}

{ #category : #api }
SpFilteringSelectableListPresenter >> display [

	^ displayBlock
]

{ #category : #api }
SpFilteringSelectableListPresenter >> display: aBlock [

	displayBlock := aBlock.
	listPresenter columns: self listColumns
]

{ #category : #api }
SpFilteringSelectableListPresenter >> displayIcon: aBlock [

	displayIconBlock := aBlock.
	listPresenter columns: self listColumns
]

{ #category : #initialization }
SpFilteringSelectableListPresenter >> initialize [

	selectedItems := Set new.
	displayBlock := [ :anObject | anObject asString ].
	super initialize
]

{ #category : #initialization }
SpFilteringSelectableListPresenter >> initializePresenters [

	super initializePresenters.
	listPresenter 
		bindKeyCombination: Character space 
		toAction: [ self toggleSelection ].
		
	listPresenter selection whenSelectedIndexChangedDo: [ :newIndex :prevIndex | 
		previousSelectedIndex := prevIndex ]. 
		
	listPresenter eventHandler whenMouseDownDo: [ :event | 
		event shiftPressed
			ifTrue: [ 
				self 
					selectFrom: previousSelectedIndex
					to: listPresenter selection selectedIndex ]
			ifFalse: [ 
				self toggleSelection ] ].
		
	listPresenter
  		bindKeyCombination: $a meta toAction: [ self selectItems: self items ]
]

{ #category : #private }
SpFilteringSelectableListPresenter >> listColumns [
	| column |

	column := SpCompositeTableColumn new.
	column addColumn: (selectColumn := (SpCheckBoxTableColumn new
		evaluated: [ :anObject | selectedItems includes: anObject ];
		onActivation: [ :anObject | selectedItems add: anObject ];
		onDeactivation: [ :anObject | selectedItems remove: anObject ];
		beNotExpandable)).
	displayIconBlock ifNotNil: [
		column addColumn: (SpImageTableColumn evaluated: displayIconBlock) beNotExpandable ].
	column addColumn: (SpStringTableColumn evaluated: self display).

	^ { column }
]

{ #category : #initialization }
SpFilteringSelectableListPresenter >> newListToFilter [
	| table |
	
	table := self newTable. 
	table hideColumnHeaders.
	table columns: self listColumns.
	^ table
]

{ #category : #private }
SpFilteringSelectableListPresenter >> selectFrom: fromIndex to: toIndex [

	selectedItems addAll: (fromIndex < toIndex
		ifTrue: [ listPresenter items copyFrom: fromIndex to: toIndex ]
		ifFalse:[ listPresenter items copyFrom: toIndex to: fromIndex ]).
	listPresenter refresh
]

{ #category : #api }
SpFilteringSelectableListPresenter >> selectItem: anObject [

	self selectItems: (self selectedItems copyWith: anObject)
]

{ #category : #api }
SpFilteringSelectableListPresenter >> selectItems: aCollection [

	selectedItems := aCollection asSet.
	listPresenter selectItems: selectedItems asOrderedCollection
]

{ #category : #api }
SpFilteringSelectableListPresenter >> selectedItems [

	^ selectedItems sorted: [ :a :b | (self items indexOf: a) < (self items indexOf: b) ]
]

{ #category : #private }
SpFilteringSelectableListPresenter >> toggleSelection [
	| selectedItem |

	selectedItem := listPresenter selectedItem.
	(selectedItems includes: selectedItem)
		ifTrue: [ selectedItems remove: selectedItem ]
		ifFalse: [ selectedItems add: selectedItem ].
	listPresenter refresh
]
