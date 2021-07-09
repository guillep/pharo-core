"
A TickDialogWindow is a modal dialog window which contains a TickList where user can pick a list of items.

See self example
"
Class {
	#name : #TickDialogWindow,
	#superclass : #DialogWindowMorph,
	#instVars : [
		'defaultValue',
		'itemsHeaderName',
		'itemsList',
		'listModel',
		'listMorph',
		'resultStorage',
		'wrapBlockOrSelector'
	],
	#category : #'Polymorph-Widgets-Windows'
}

{ #category : #examples }
TickDialogWindow class >> example [
	
	(self itemsList: Morph methods itemsHeaderName: 'Plop' wrapBlockOrSelector: #selector title: 'Example') choose
]

{ #category : #'instance creation' }
TickDialogWindow class >> itemsList: itemsList itemsHeaderName: aName title: aTitle [

	^ self basicNew
		itemsList: itemsList;
		itemsHeaderName: aName;
		initialize;
		title: aTitle;
		yourself
]

{ #category : #'instance creation' }
TickDialogWindow class >> itemsList: itemsList itemsHeaderName: aName title: aTitle defaultValue: aBoolean [
	^ self basicNew
		itemsList: itemsList;
		itemsHeaderName: aName;
		defaultValue: aBoolean;
		initialize;
		title: aTitle;
		yourself
]

{ #category : #'instance creation' }
TickDialogWindow class >> itemsList: itemsList itemsHeaderName: aName wrapBlockOrSelector: aBlockOrSelector title: aTitle [
	^ self basicNew
		itemsList: itemsList;
		itemsHeaderName: aName;
		wrapBlockOrSelector: aBlockOrSelector;
		initialize;
		title: aTitle;
		yourself
]

{ #category : #'instance creation' }
TickDialogWindow class >> itemsList: itemsList itemsHeaderName: aName wrapBlockOrSelector: aBlockOrSelector title: aTitle defaultValue: aBoolean [
	^ self basicNew
		itemsList: itemsList;
		itemsHeaderName: aName;
		wrapBlockOrSelector: aBlockOrSelector;
		defaultValue: aBoolean;
		initialize;
		title: aTitle;
		yourself
]

{ #category : #actions }
TickDialogWindow >> accept [

	self resultStorage: self listModel selectedItems.
]

{ #category : #display }
TickDialogWindow >> choose [

	^ self chooseFromOwner: self currentWorld
]

{ #category : #display }
TickDialogWindow >> chooseFromOwner: aMorph [

	self openModal.
	^ resultStorage
]

{ #category : #'focus handling' }
TickDialogWindow >> defaultFocusMorph [

	^ self listMorph 
		ifNil: [ super defaultFocusMorph ]
		ifNotNil: [:morph | morph ]
]

{ #category : #accessing }
TickDialogWindow >> defaultValue [

	^ defaultValue ifNil: [defaultValue := false]
]

{ #category : #accessing }
TickDialogWindow >> defaultValue: aBoolean [

	defaultValue := aBoolean
]

{ #category : #compatibility }
TickDialogWindow >> hasUnacceptedEdits [

	^ true
]

{ #category : #display }
TickDialogWindow >> initialExtent [
	
	| width |
	width := (self listMorph allNodeMorphs detectMax: [:e | e width]) width.
	width := width+ 50.
	
	^width@400
]

{ #category : #private }
TickDialogWindow >> isResizeable [

	^ true
]

{ #category : #accessing }
TickDialogWindow >> itemsHeaderName [

	^ itemsHeaderName
]

{ #category : #accessing }
TickDialogWindow >> itemsHeaderName: anObject [
	
	itemsHeaderName := anObject
]

{ #category : #accessing }
TickDialogWindow >> itemsList [

	^ itemsList
]

{ #category : #accessing }
TickDialogWindow >> itemsList: anObject [
	
	itemsList := anObject
]

{ #category : #accessing }
TickDialogWindow >> listModel [

	^ listModel
]

{ #category : #accessing }
TickDialogWindow >> listModel: aModel [

	listModel := aModel
]

{ #category : #accessing }
TickDialogWindow >> listMorph [

	^ listMorph
]

{ #category : #accessing }
TickDialogWindow >> listMorph: anObject [
	
	listMorph := anObject
]

{ #category : #display }
TickDialogWindow >> newContentMorph [

	self listModel: ((self tickListClass 
						itemsList: self itemsList 
						itemsHeaderName: self itemsHeaderName 
						wrapBlockOrSelector: self wrapBlockOrSelector)
						autoMultiSelection: true;
						beCheckList;
						yourself).
	
	self listMorph: (self listModel defaultTreeMorph
								buildContents;
								vResizing: #spaceFill;
								hResizing: #spaceFill).
								
	self defaultValue ifTrue: [ self listMorph selectAll ].							
	^ self listMorph
]

{ #category : #accessing }
TickDialogWindow >> resultStorage [

	^ resultStorage
]

{ #category : #accessing }
TickDialogWindow >> resultStorage: anObject [
	
	resultStorage := anObject
]

{ #category : #accessing }
TickDialogWindow >> selectItems: aCollection [ 
	self listModel selectItems: aCollection
]

{ #category : #accessing }
TickDialogWindow >> selectedItems [ 
	^ self listModel selectedItems
]

{ #category : #private }
TickDialogWindow >> tickListClass [

	^ MorphTreeModel
]

{ #category : #accessing }
TickDialogWindow >> wrapBlockOrSelector [

	^ wrapBlockOrSelector
]

{ #category : #accessing }
TickDialogWindow >> wrapBlockOrSelector: anObject [
	
	wrapBlockOrSelector := anObject
]
