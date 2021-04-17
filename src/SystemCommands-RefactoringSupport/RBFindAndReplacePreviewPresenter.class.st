"
I am a preview of find and replace refactoring (tool). I can select the methods of class (or subclasses) to find ocurrences in them. 

EXAMPLES
-------------------------------------------------

RBFindAndReplacePreview method: (RBRefactoring >> #convertMethod:for:using: )

Instance Variables
-------------------------------------------------

changeList:           <TablePresenter> A table to display the possible methods to push down
label:                <LabelPresenter> Title of table
dropList:             <DropListPresenter> A selector to select the search type
selectedRefactorings: <OrderedCollection> A list with elements to search
method:               <CompiledMethod> A method to find ocurrences
refactoring:          <RBRefactoring> A subclass of RBRefactoring 


"
Class {
	#name : #RBFindAndReplacePreviewPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'changeList',
		'label',
		'dropList',
		'selectedRefactorings',
		'method',
		'refactoring'
	],
	#category : #'SystemCommands-RefactoringSupport'
}

{ #category : #specs }
RBFindAndReplacePreviewPresenter class >> defaultSpec [
	^ SpBoxLayout newTopToBottom
		add: #label withConstraints: [ :c | c height: self labelHeight ];
		add:
			(SpBoxLayout newLeftToRight
				add: #changeList;
				yourself);
		add: #dropList withConstraints: [ :constraints | constraints height: self toolbarHeight ];
		yourself.
]

{ #category : #specs }
RBFindAndReplacePreviewPresenter class >> example [
	<script>
	^ (self method: (RBRefactoring >> #convertMethod:for:using: )) 
]

{ #category : #specs }
RBFindAndReplacePreviewPresenter class >> method: aMethod [
	|temp|
	temp := self new method: aMethod.
	^ temp openModalWithSpec
]

{ #category : #specs }
RBFindAndReplacePreviewPresenter class >> method: aMethod refactoring: aRef [
	|temp|
	temp := self new method: aMethod; refactoring: aRef.
	^ temp openModalWithSpec
]

{ #category : #specs }
RBFindAndReplacePreviewPresenter class >> title [
	^ 'Find and replace'
]

{ #category : #initialization }
RBFindAndReplacePreviewPresenter >> initializeChangeList [
	changeList
		addColumn:
			((SpCheckBoxTableColumn title: ' ' evaluated: [ :x | 
				selectedRefactorings includes: x ])
				onActivation: [ :class |  selectedRefactorings add: class ];
				onDeactivation: [ :class | selectedRefactorings remove: class ];
				width: 20;
				yourself);
		addColumn: (SpStringTableColumn title: 'Name' evaluated: #selector);
		beResizable.
]

{ #category : #initialization }
RBFindAndReplacePreviewPresenter >> initializeDialogWindow: aModalPresenter [
	aModalPresenter
		addButton: 'Find' do: [ :presenter |
			refactoring listToFindMatches: selectedRefactorings .
			presenter
				beOk;
				close];
		addButton: 'Cancel' do: [ :presenter | 
			presenter
				beCancel;
				close ]
]

{ #category : #initialization }
RBFindAndReplacePreviewPresenter >> initializeDropList [
	dropList addItemLabeled: 'Current class'
			do: [ method ifNotNil: [|items|
				items := method origin methods select: [:each | each ~= method].
				selectedRefactorings := OrderedCollection newFrom: items.
				changeList columns last evaluated: #selector.
				changeList items: items ]];
			addItemLabeled: 'Current class and subclasses'
			do: [  method ifNotNil: [|items|
				items := method origin allSubclasses.
				selectedRefactorings := items.
				changeList columns last evaluated: #name.
				changeList items: items ]]
]

{ #category : #initialization }
RBFindAndReplacePreviewPresenter >> initializePresenter [
	super initializePresenter.
	
]

{ #category : #initialization }
RBFindAndReplacePreviewPresenter >> initializeWidgets [
	changeList := self newTable.
	label := (self newLabel)label: 'Find in:' .
	dropList := self newDropList.
	selectedRefactorings := OrderedCollection new.
	self initializeDropList.
	self initializeChangeList.
	
]

{ #category : #initialization }
RBFindAndReplacePreviewPresenter >> method: aMethod [
	method := aMethod.
	
	selectedRefactorings := OrderedCollection newFrom: 
		(method origin methods select: [:each | each ~= method]).
	changeList items: selectedRefactorings.
	
]

{ #category : #initialization }
RBFindAndReplacePreviewPresenter >> refactoring: ref [
	refactoring := ref
]
