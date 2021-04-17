Class {
	#name : #RBAbstractSelectionPresenter,
	#superclass : #RBItemsSelectionPresenter,
	#instVars : [
		'dropList',
		'dropLabel',
		'acceptBlock'
	],
	#category : #'SystemCommands-RefactoringSupport'
}

{ #category : #specs }
RBAbstractSelectionPresenter class >> defaultSpec [
	^ SpBoxLayout newTopToBottom
		add: #dropLabel withConstraints: [ :c | c height: self labelHeight ];
		add:
			(SpBoxLayout newLeftToRight
				add: #dropList ;
				yourself) withConstraints: [ :c | c height: self toolbarHeight  ];
		add: #label withConstraints: [ :c | c height: self buttonHeight ];
		add:
			(SpBoxLayout newLeftToRight
				add: #table;
				yourself);
		yourself
]

{ #category : #specs }
RBAbstractSelectionPresenter class >> label: aString dropLabel: aString2 withItems: coll1 selecting: coll2 dropItems: coll3 acceptBlock: aBlock [
	^ self new 
		label: aString
		dropLabel: aString2
		withItems: coll1
		selecting: coll2
		dropItems: coll3
		acceptBlock: aBlock;
		openModalWithSpec
]

{ #category : #actions }
RBAbstractSelectionPresenter >> accept [
	acceptBlock value: self selectedItem value: selectedItems
]

{ #category : #initialization }
RBAbstractSelectionPresenter >> initializeDropList [
	dropList := self newDropList.
	dropList
		display: [ :scope | scope name ];
		iconBlock: [ :e | e systemIcon ]
]

{ #category : #initialization }
RBAbstractSelectionPresenter >> initializeWidgets [
	super initializeWidgets .
	dropLabel := self newLabel.
	self initializeDropList.
]

{ #category : #initialization }
RBAbstractSelectionPresenter >> label: aString dropLabel: aString2 withItems: coll1 selecting: coll2 dropItems: coll3 acceptBlock: aBlock [
	self label: aString withItems: coll1 selecting: coll2.
	dropLabel label: aString2.
	dropList items: coll3.
	acceptBlock := aBlock.
	
]

{ #category : #accessing }
RBAbstractSelectionPresenter >> selectedItem [
	^ dropList selectedItem
]
