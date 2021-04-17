"
I am an abstract class to select items from a list. 
My subclasses should implement 3 methods:

	- Class side
		- title
	- Instance side
		- columnName
		- columnSelector

Instance Variables
-------------------------------------------------

table:                   <TablePresenter> A table to display the possible methods to push down
label:                   <LabelPresenter> Title of table
items:                   <OrderedCollection> A list to select 
selectedItems:           <OrderedCollection> A list with selected items
"
Class {
	#name : #RBItemsSelectionPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'table',
		'label',
		'selectedItems'
	],
	#category : #'SystemCommands-RefactoringSupport'
}

{ #category : #specs }
RBItemsSelectionPresenter class >> defaultSpec [
	^ SpBoxLayout newTopToBottom
		add: #label withConstraints: [ :c | c height: self buttonHeight ];
		add:
			(SpBoxLayout newLeftToRight
				add: #table;
				yourself);
		yourself
]

{ #category : #specs }
RBItemsSelectionPresenter class >> label: aString withItems: coll1 selecting: coll2 [
	^ self new 
		label: aString withItems: coll1 selecting: coll2;
		openModalWithSpec 
]

{ #category : #actions }
RBItemsSelectionPresenter >> accept [
	"refactoring selectors: (selectedMethods collect: #selector)"
]

{ #category : #actions }
RBItemsSelectionPresenter >> accept: presenter [
	self accept.
	presenter
				beOk;
				close
]

{ #category : #attributes }
RBItemsSelectionPresenter >> columnName [
	self shouldBeImplemented
]

{ #category : #attributes }
RBItemsSelectionPresenter >> columnSelector [ 
	self shouldBeImplemented 
]

{ #category : #initialization }
RBItemsSelectionPresenter >> initializeChangesTree [
	table addColumn:
		((SpCheckBoxTableColumn title: ' ' evaluated: [ :aClass | 
	selectedItems includes: aClass ])
				onActivation: [ :aClass | selectedItems add: aClass ];
				onDeactivation: [ :aClass | selectedItems remove: aClass ];
				width: 20;
				yourself);
			addColumn: (SpStringTableColumn 
				title: self columnName 
				evaluated: self columnSelector );
			beResizable.
]

{ #category : #initialization }
RBItemsSelectionPresenter >> initializeDialogWindow: aModalPresenter [
	aModalPresenter
		addButton: 'Refactor' do: [ :presenter | self accept: presenter ];
		addButton: 'Cancel' do: [ :presenter | 
			presenter
				beCancel;
				close ]        
]

{ #category : #initialization }
RBItemsSelectionPresenter >> initializeWidgets [
	table := self newTable.
	label := self newLabel.
	
	self initializeChangesTree.
]

{ #category : #initialization }
RBItemsSelectionPresenter >> label: aString withItems: coll1 selecting: coll2 [
	label label: aString.
	selectedItems := coll2.
	
	table items: coll1
]

{ #category : #accessing }
RBItemsSelectionPresenter >> selectedItems [
	^ selectedItems 
]
