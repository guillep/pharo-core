Class {
	#name : #SpMorphicComponentListAdapter,
	#superclass : #SpAbstractMorphicAdapter,
	#category : #'Spec2-Adapters-Morphic-List'
}

{ #category : #initialization }
SpMorphicComponentListAdapter >> addActivationKeyBindings: aWidget [

	self 
		bindKeyCombination: Character cr asKeyCombination
		toAction: [ self triggerActivationAction ]
]

{ #category : #initialization }
SpMorphicComponentListAdapter >> addKeyBindingsTo: aWidget [

	super addKeyBindingsTo: aWidget.
	self addContextMenuKeyBindings: aWidget.
	self addActivationKeyBindings: aWidget
]

{ #category : #factory }
SpMorphicComponentListAdapter >> buildWidget [

	widget := SpFTTableMorph new
		beRowNotHomogeneous;
		dataSource: self newDataSource;
		setMultipleSelection: self presenter isMultipleSelection;
		hideColumnHeaders;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		setBalloonText: self help;
		onAnnouncement: FTSelectionChanged send: #selectionChanged: to: self;
		onAnnouncement: FTStrongSelectionChanged send: #strongSelectionChanged: to: self;
		yourself.
		
	self presenter whenPresentersChangedDo: [ self refreshList ].
	self refreshWidgetSelection.
	self presenter whenSelectionChangedDo: [ self refreshWidgetSelection ].
	
	^ widget
]

{ #category : #accessing }
SpMorphicComponentListAdapter >> children [

	^ self rows collect: [ :row | | cell | 
		cell := row submorphs first.
		cell submorphs first ]
]

{ #category : #accessing }
SpMorphicComponentListAdapter >> elementAt: index [ 
	
	^ self widget dataSource elementAt: index
]

{ #category : #testing }
SpMorphicComponentListAdapter >> isNonEditableRow: aRow column: aColumn [ 
	"no rows are directly editable in a component list (they can be 
	 if defined like that in the inner presenters, but it is handled different)"
	^ true
]

{ #category : #factory }
SpMorphicComponentListAdapter >> newDataSource [
	
	^ SpComponentListDataSource new
		model: self presenter;
		yourself
]

{ #category : #updating }
SpMorphicComponentListAdapter >> refreshList [

	^ self widget refresh
]

{ #category : #factory }
SpMorphicComponentListAdapter >> refreshWidgetSelection [
	| rowIndexes |

	rowIndexes := self presenter selection selectedIndexes.
	rowIndexes = self widget selectedIndexes ifTrue: [ ^ self ].
	rowIndexes isEmpty
		ifTrue: [ self widget basicSelectIndexes: #() ]
		ifFalse: [ self widget basicSelectIndexes: rowIndexes ].
	self refreshList
]

{ #category : #accessing }
SpMorphicComponentListAdapter >> rows [
	| tableContainer |

	tableContainer := self widget submorphs first.
	^ tableContainer submorphs
]

{ #category : #accessing }
SpMorphicComponentListAdapter >> selectIndex: aNumber [ 
	
	(aNumber = 0 and: [ widget selectedIndexes isEmpty ]) ifTrue: [ ^ self ].	
	(widget selectedIndexes includes: aNumber) ifTrue: [ ^ self ].
	widget selectIndex: aNumber
]

{ #category : #accessing }
SpMorphicComponentListAdapter >> selectedIndexes [

	^ widget selectedIndexes
]

{ #category : #'event handling' }
SpMorphicComponentListAdapter >> selectionChanged: ann [
	| diff |
	
	self presenter selection isMultipleSelection ifTrue: [ 
		self presenter selection selectIndexes: (ann newSelectedIndexes reject: [ :e | e = 0 ]) ].
	self presenter selection isMultipleSelection ifFalse: [ 
		self presenter selection selectIndex: (ann newSelectedIndexes
			ifNotEmpty: [ :indexes | indexes first ]
			ifEmpty: [ 0 ]) ].
	diff := ann newSelectedIndexes difference: ann oldSelectedIndexes.
	(diff notEmpty and: [ self presenter activatesOnSingleClick ])
		ifTrue: [ self presenter doActivateAtIndex: diff last ].
	
	ann newSelectedIndexes ifNotEmpty: [ ^ self ].
	self presenter selection unselectAll
]

{ #category : #emulating }
SpMorphicComponentListAdapter >> sendRightClickEvent [
	| evt |

	evt := MouseButtonEvent new 
		setType: nil 
		position: widget center 
		which: MouseButtonEvent yellowButton 
		buttons: MouseButtonEvent yellowButton 
		hand: nil 
		stamp: nil.
	
	self widget click: evt
]

{ #category : #private }
SpMorphicComponentListAdapter >> showContextMenu [

	self widgetDo: [ :w |
		w showMenuForIndex: { self presenter selection selectedIndex. 1 } ]
]

{ #category : #factory }
SpMorphicComponentListAdapter >> strongSelectionChanged: aFTStrongSelectionChanged [
	
	self presenter activatesOnDoubleClick ifFalse: [ ^ self ]. 	
	self presenter doubleClickAtIndex: aFTStrongSelectionChanged selectedIndex
]

{ #category : #private }
SpMorphicComponentListAdapter >> triggerActivationAction [

	self presenter doActivateAtIndex: self presenter selection selectedIndex
]
