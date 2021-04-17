Trait {
	#name : #SpTMorphicTableDataSourceCommons,
	#instVars : [
		'model',
		'headersByColumn'
	],
	#category : #'Spec2-Adapters-Morphic-Table'
}

{ #category : #accessing }
SpTMorphicTableDataSourceCommons >> headerColumn: column [

	(column id isNil and: [ self model isShowingColumnHeaders not ]) ifTrue: [ ^ nil ].
	^ self headerForColumn: column
]

{ #category : #accessing }
SpTMorphicTableDataSourceCommons >> headerForColumn: aColumn [

	^ self headersByColumn 
		at: aColumn 
		ifAbsentPut: [ self newHeaderColumn: aColumn ]
]

{ #category : #accessing }
SpTMorphicTableDataSourceCommons >> headersByColumn [ 

	^ headersByColumn ifNil: [ headersByColumn := SmallDictionary new ]	
]

{ #category : #accessing }
SpTMorphicTableDataSourceCommons >> menuColumn: column row: rowIndex [
	| menuPresenter |

	menuPresenter := self model contextMenu.
	menuPresenter ifNil: [ ^ nil ].
	^ SpBindings
		value: self model application adapterBindings
		during: [ menuPresenter value buildWithSpec ]
]

{ #category : #accessing }
SpTMorphicTableDataSourceCommons >> model [

	^ model
]

{ #category : #accessing }
SpTMorphicTableDataSourceCommons >> model: aTablePresenter [

	model := aTablePresenter
]

{ #category : #'private factory' }
SpTMorphicTableDataSourceCommons >> newHeaderColumn: column [
	| headerMorph |
	
	headerMorph := SpHeaderCellMorph new 
		addMorph: (column id ifNil: [ '' ]) asMorph asReadOnlyMorph;
		yourself.
		
	column isSortable ifTrue: [ 
		headerMorph eventHandler: (MorphicEventHandler new 
			on: #click 
			send: #sortByColumn:event:morph:
			to: self
			withValue: column).
	column sortingIcon ifNotNil: [ :icon | headerMorph addMorph: icon ] ].

	^ headerMorph
]

{ #category : #private }
SpTMorphicTableDataSourceCommons >> setHeaderColumnLazyProperties: column [
	"Some properties of a header just acquire value after rendering cells. This method makes sure 
	 properties are set, but is responsibility of the user to actually call it (usually after create 
	 a cell). See senders of this method too see where it goes."
	| headerMorph |
	
	column isExpandable ifTrue: [ ^ self ].  
	
	headerMorph := self headerForColumn: column.
	headerMorph hResizing = #rigid 
		ifFalse: [ headerMorph hResizing: #rigid ].
	headerMorph width = column model width ifFalse: [ 
		headerMorph width: (column model width ifNil: [ 0 ]). ]
]

{ #category : #sorting }
SpTMorphicTableDataSourceCommons >> sortByColumn: aColumn [

	aColumn sortDataSource: self.
	self model selection unselectAll.
]

{ #category : #sorting }
SpTMorphicTableDataSourceCommons >> sortByColumn: aColumn event: anEvent morph: aMorph [

	self sortByColumn: aColumn
]
