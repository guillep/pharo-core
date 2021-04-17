Class {
	#name : #SpComponentListDataSource,
	#superclass : #FTDataSource,
	#instVars : [
		'model'
	],
	#category : #'Spec2-Adapters-Morphic-List'
}

{ #category : #accessing }
SpComponentListDataSource >> cellColumn: column row: rowIndex [
	| cell item |
	
	item := self elementAt: rowIndex.
	cell := FTCellMorph new
		cellInset: 5;
		yourself.
	cell addMorphBack: (self widgetFor: item).
	
	^ cell
]

{ #category : #accessing }
SpComponentListDataSource >> elementAt: rowIndex [

	^ self presenters at: rowIndex
]

{ #category : #accessing }
SpComponentListDataSource >> elements [

	^ self presenters
]

{ #category : #accessing }
SpComponentListDataSource >> headerColumn: column [

	column id ifNil: [ ^ nil ]. 
	^ FTCellMorph new 
		listCentering: #left;
		addMorph: column id asMorph asReadOnlyMorph;
		yourself
]

{ #category : #accessing }
SpComponentListDataSource >> menuColumn: column row: rowIndex [
	| menuPresenter |

	menuPresenter := self model contextMenu.
	menuPresenter ifNil: [ ^ nil ].
	^ SpBindings
		value: self model application adapterBindings
		during: [ 
			| m |
			m := menuPresenter value.
			m isMorph 
				ifTrue: [ m ]
				ifFalse: [ m buildWithSpec ] ]
]

{ #category : #accessing }
SpComponentListDataSource >> model [
	^ model
]

{ #category : #accessing }
SpComponentListDataSource >> model: anObject [
	model := anObject
]

{ #category : #accessing }
SpComponentListDataSource >> newDataSourceMatching: aFTFilter [
	| newElements wrappedItem text newDataSource modelCopy |
	
	newElements := self elements select: [ :each | 
		wrappedItem := self model displayValueFor: each.
		table columns anySatisfy: [ :column | 
			text := column transform: wrappedItem.
			aFTFilter matches: text]].
	
	newDataSource := self copy.
	modelCopy := self model copy.
	modelCopy prepareForFilteredDataSourceWith: newElements.
	newDataSource model: modelCopy.
	
	^newDataSource
]

{ #category : #accessing }
SpComponentListDataSource >> numberOfRows [

	^ model
		ifNil: [ 0 ]
		ifNotNil: [ self presenters size ]
]

{ #category : #accessing }
SpComponentListDataSource >> presenters [

	^ self model presenters
]

{ #category : #accessing }
SpComponentListDataSource >> rowHeight: rowIndex [

	rowIndex = 0 ifTrue: [ ^ super rowHeight: rowIndex ].
	^ (self widgetFor: (self elementAt: rowIndex)) height
]

{ #category : #accessing }
SpComponentListDataSource >> searchText: aString [
	"do nothing for the moment"
	^ #()
]

{ #category : #'drag and drop' }
SpComponentListDataSource >> transferFor: passenger from: aMorph [

	^ (self model adapter 
		transferFor: passenger 
		from: self table) 
		buildWithSpec
]

{ #category : #private }
SpComponentListDataSource >> widgetFor: aPresenter [
	| widget |

	aPresenter adapter ifNotNil: [ :adapter | ^ adapter widget ].
	widget := aPresenter buildWithSpec
		vResizing: #shrinkWrap;
		yourself.
	aPresenter adapter applyStyle: widget. 
		
	^ widget
]
