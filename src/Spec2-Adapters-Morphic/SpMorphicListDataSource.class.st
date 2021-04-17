Class {
	#name : #SpMorphicListDataSource,
	#superclass : #FTDataSource,
	#instVars : [
		'model'
	],
	#category : #'Spec2-Adapters-Morphic-List'
}

{ #category : #accessing }
SpMorphicListDataSource >> cellColumn: column row: rowIndex [
	| displayValue cell item |
	
	item := self model itemAt: rowIndex.
	displayValue := column readObject: item.
	cell := FTCellMorph new
		cellInset: 5;
		yourself.
	self model hasIcons ifTrue: [ 
		(self model iconFor: item) ifNotNil: [ :icon | cell addMorphBack: icon asMorph ] ].
	cell addMorphBack: displayValue asMorph asReadOnlyMorph.
	
	^ cell
]

{ #category : #accessing }
SpMorphicListDataSource >> elementAt: rowIndex [

	^ self listModel at: rowIndex
]

{ #category : #accessing }
SpMorphicListDataSource >> elements [

	^ self model items
]

{ #category : #testing }
SpMorphicListDataSource >> hasElementAt: index [ 
	
	^ self model model hasElementAt: index
]

{ #category : #accessing }
SpMorphicListDataSource >> headerColumn: column [

	column id ifNil: [ ^ nil ]. 
	^ FTCellMorph new 
		listCentering: #left;
		addMorph: column id asMorph asReadOnlyMorph;
		yourself
]

{ #category : #accessing }
SpMorphicListDataSource >> listModel [

	^ model model
]

{ #category : #accessing }
SpMorphicListDataSource >> menuColumn: column row: rowIndex [
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
SpMorphicListDataSource >> model [
	^ model
]

{ #category : #accessing }
SpMorphicListDataSource >> model: anObject [
	model := anObject
]

{ #category : #accessing }
SpMorphicListDataSource >> newDataSourceMatching: aFTFilter [
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
SpMorphicListDataSource >> numberOfRows [
	^ model
		ifNil: [ 0 ]
		ifNotNil: [ self listModel size ]
]

{ #category : #accessing }
SpMorphicListDataSource >> searchText: aString [
	| search |

	aString isEmptyOrNil ifTrue: [ ^ #() ].
	search := aString trimBoth asLowercase.
	^ Array streamContents: [ :stream |
		self elements withIndexDo: [ :each :rowIndex | 
			(self model performSearch: each matching: search) 
				ifTrue: [ stream nextPut: rowIndex ] ] ]
]

{ #category : #'drag and drop' }
SpMorphicListDataSource >> transferFor: passenger from: aMorph [

	^ (self model adapter 
		transferFor: passenger 
		from: self table) 
		buildWithSpec
		  dragHand: aMorph currentHand;
		  yourself
]
