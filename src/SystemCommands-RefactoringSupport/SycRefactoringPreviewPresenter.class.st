"
I am a GUI used to preview the impact of a refactoring and select the changes to apply.

Examples

	scopePackage := ClyPackageScope of: 'Stage' asPackage in: ClyNavigationEnvironment currentImage.
	scopeClass := ClyClassScope of: 'SycRefactoringPreview' in: ClyNavigationEnvironment currentImage.
	
	SycRefactoringPreview2 for:  scope: { scopePackage . scopeClass } 



Instance Variables
	changes:						<ArrayOfRBRefactroring>	The collection of changes that can be applied with the refactoring.
	scopeDropList:				<DropListPresenter>		A drop list to let the user chose the scope of the refactoring to apply. (All image, current package, current class...)				
	selectedRefactorings:		<Dictionary>					A dictionary remembering for all refactorings if they should be applied.	
	table:							<TablePresenter>			A table to display the possible refactorings.
	diffPresenter				<DiffPresenter>				A diff presenter to show the users the consequences of the refactorings.
	
"
Class {
	#name : #SycRefactoringPreviewPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'changes',
		'scopeDropList',
		'table',
		'command',
		'selectedRefactorings',
		'diffPresenter',
		'existsChanges'
	],
	#category : #'SystemCommands-RefactoringSupport'
}

{ #category : #specs }
SycRefactoringPreviewPresenter class >> defaultSpec [
	^ SpBoxLayout newTopToBottom
		add: #table;
		add: #scopeDropList withConstraints: [ :constraints | constraints height: 30 ];
		add: #diffPresenter;
		yourself
]

{ #category : #'instance creation' }
SycRefactoringPreviewPresenter class >> for: aCommand scopes: scopes [
	^ self new
		command: aCommand;
		scopes: scopes
]

{ #category : #specs }
SycRefactoringPreviewPresenter class >> title [
	^ 'Refactoring changes'
]

{ #category : #controlling }
SycRefactoringPreviewPresenter >> accept [
	self okToChange ifFalse: [ ^ self ].
	[ self pickedChanges do: [ :change | 
		RBRefactoryChangeManager instance 
			performChange: change; 
			addUndoPointer: (RBRefactoryChangeManager nextCounter) ] ] asJob
		title: 'Refactoring';
		run
]

{ #category : #accessing }
SycRefactoringPreviewPresenter >> activeRBEnvironment [
	^ self activeScope asRBEnvironment
]

{ #category : #accessing }
SycRefactoringPreviewPresenter >> activeScope [
	^ scopeDropList selectedItem
]

{ #category : #services }
SycRefactoringPreviewPresenter >> alert: aString [
	"Display a message for the user to read and then dismiss."

	aString isEmptyOrNil
		ifFalse: [ UIManager default alert: aString ]
]

{ #category : #'epicea support' }
SycRefactoringPreviewPresenter >> asEpiceaEvent [
	"thanks to this method epicia know that is a refactoring"
	
	self flag: #todo. "This is a workaround for a problem found by RewriteTool"
	(changes allSatisfy: [ :each | each respondsTo: #asEpiceaEvent ])
		ifFalse: [ ^ EpCompositeRefactoring withAll: #() ].

	^ changes size > 1
		ifTrue: [ EpCompositeRefactoring withAll: changes ]
		ifFalse: [ changes anyOne asEpiceaEvent ].
]

{ #category : #private }
SycRefactoringPreviewPresenter >> buildDiffFor: aChange [
	^ diffPresenter
		leftText: aChange oldVersionTextToDisplay;
		rightText: aChange textToDisplay
]

{ #category : #accessing }
SycRefactoringPreviewPresenter >> changes [
	^ changes
]

{ #category : #accessing }
SycRefactoringPreviewPresenter >> changes: aCollection [
	changes := aCollection.
	self generateChanges 
]

{ #category : #accessing }
SycRefactoringPreviewPresenter >> command: aCommand [
	command := aCommand
]

{ #category : #accessing }
SycRefactoringPreviewPresenter >> existChanges [
	^ existsChanges ifNil: [ existsChanges := false ]
]

{ #category : #update }
SycRefactoringPreviewPresenter >> generateChanges [

	| rbEnvironment |
	changes := command asRefactorings.
	rbEnvironment := changes first model environment.
	changes do: [ :each | 
		each model environment: rbEnvironment.
		each primitiveExecute ]
]

{ #category : #initialization }
SycRefactoringPreviewPresenter >> initializeDialogWindow: aDialogWindowPresenter [
	aDialogWindowPresenter
		title: self title;
		initialExtent: 500 @ 500;
		addButton: 'Apply'
			do: [ :presenter | 
			self accept.
			presenter close ];
		addButton: 'Cancel' do: [ :presenter | presenter close ]
]

{ #category : #initialization }
SycRefactoringPreviewPresenter >> initializePresenter [
	super initializePresenter.
	table
		whenSelectionChangedDo: [ :selection | 
			selection selectedItem ifNotNil: [ 
				self buildDiffFor: selection selectedItem ] ].
	table
		whenActivatedDo: [ :selectedElement | 
			self toggleSelectionOf: selectedElement widget selection selectedItem.
			self rebuild ].
	scopeDropList
		whenSelectedItemChangedDo: [ :scope | self updateChanges ]
]

{ #category : #initialization }
SycRefactoringPreviewPresenter >> initializeWidgets [
	table := self newTable.
	diffPresenter := self newDiff.
	scopeDropList := self newDropList.

	table
		addColumn:
			((SpCheckBoxTableColumn evaluated: [ :x | selectedRefactorings at: x ])
				onActivation: [ :class | self toggleSelectionOf: class ];
				onDeactivation: [ :class | self toggleSelectionOf: class ];
				width: 20);
		addColumn: (SpStringTableColumn evaluated: #name);
		hideColumnHeaders.

	diffPresenter disable.
	scopeDropList display: [ :scope | scope description capitalized ].

	self
		selectectAllCheckBox;
		setShortcuts;
		setFocus
]

{ #category : #'epicea support' }
SycRefactoringPreviewPresenter >> isEpiceaInterestingJobOwner [

	^ true
]

{ #category : #accessing }
SycRefactoringPreviewPresenter >> pickedChanges [
	^ table items select: [ :item | selectedRefactorings at: item ]
]

{ #category : #update }
SycRefactoringPreviewPresenter >> rebuild [
	self needRebuild: false.
	self buildWithSpec
]

{ #category : #accessing }
SycRefactoringPreviewPresenter >> scopeDropList [
	^ scopeDropList
]

{ #category : #accessing }
SycRefactoringPreviewPresenter >> scopes: aCollectionOfScopes [
	scopeDropList items: aCollectionOfScopes "It also sets up first item as selection"
]

{ #category : #update }
SycRefactoringPreviewPresenter >> selectectAllCheckBox [
	selectedRefactorings := Dictionary new.
	table items do: [ :refactoring | selectedRefactorings at: refactoring put: true ]
]

{ #category : #initialization }
SycRefactoringPreviewPresenter >> setFocus [
	self focusOrder
		add: table;
		add: scopeDropList;
		add: diffPresenter
]

{ #category : #initialization }
SycRefactoringPreviewPresenter >> setShortcuts [
	self
		bindKeyCombination: PharoShortcuts current acceptShortcut toAction: [ self accept ];
		bindKeyCombination: Character escape toAction: [ self close ]
]

{ #category : #accessing }
SycRefactoringPreviewPresenter >> table [
	^ table
]

{ #category : #accessing }
SycRefactoringPreviewPresenter >> title [
	^ self class title
]

{ #category : #private }
SycRefactoringPreviewPresenter >> toggleSelectionOf: aRefactoring [
	"it's normal it's impossible that anItem dosn't store in dictionary because at initialize i fill the dictionary and at each scope change"

	selectedRefactorings at: aRefactoring put: (selectedRefactorings at: aRefactoring) not
]

{ #category : #update }
SycRefactoringPreviewPresenter >> updateChanges [
	self generateChanges.
	self updateTablePresenter.
	self selectectAllCheckBox
]

{ #category : #update }
SycRefactoringPreviewPresenter >> updateTablePresenter [
	| aCompositeChange anEnvironment |
	"We get the environment to apply the changes from any element in the changes instance variable"
	anEnvironment := changes
		ifEmpty: [ nil ]
		ifNotEmpty: [ changes anyOne model environment ].
	aCompositeChange := RBCompositeRefactoryChange new onSystemDictionary: anEnvironment.
	changes do: [ :each | aCompositeChange addChange: each ].
	table items: (aCompositeChange whatToDisplayIn: self).
	table items
		ifNotEmpty: [ table selectIndex: 1.
			existsChanges := true ]
]
