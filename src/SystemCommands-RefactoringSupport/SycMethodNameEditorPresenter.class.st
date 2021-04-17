"
I am an UI used to rename methods.

HOW TO RUN

SycMethodNameEditor
		openOn:
			(RBMethodName
				selector: (UseOnlyForTest >> #bug:) selector
				arguments: ((UseOnlyForTest >> #bug:) ast arguments collect: #name))
				

My jobs is to:
	- display a preview of your future method name or '(invalid)' when the name is incorrect  (with a LabelPresenter previewResult an instance variable)
	- display the arguments list of your method and let you modified the order 

Public API and Key Messages

See class side 'example' script to know how to use me.
  
Internal Representation and Key Implementation Points.

    Instance Variables
	selectorInput: 		<TextInputFieldPresenter>	An input field containing the new name of the method.
	argumentsList: 		<ListPresenter>					A list containing the arguments of the method.
	previewResult: 		<LabelPresenter>				A label to preview the new name of the method with the arguments.
	upButton: 			<ButtonPresenter>				A button update the order of the arguments.
	downButton: 			<ButtonPresenter>  			A button update the order of the arguments.
	methodName 		 	<RBMethod>						A RBMethodName to ensure the validity of the new name.
"
Class {
	#name : #SycMethodNameEditorPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'selectorInput',
		'argumentsList',
		'previewResult',
		'upButton',
		'downButton',
		'methodName',
		'editParameter',
		'okEdit',
		'editerArgumentList',
		'refactoring',
		'newArgs',
		'args',
		'isEditable'
	],
	#category : #'SystemCommands-RefactoringSupport'
}

{ #category : #specs }
SycMethodNameEditorPresenter class >> defaultEditableSpec [
	<spec>
	^ SpBoxLayout newTopToBottom
		add:
			(SpBoxLayout newLeftToRight
				add: 'Selector'
					withConstraints: [ :aConstraints | aConstraints width: 80 ];
				add: #selectorInput;
				yourself);
		add:
			(SpBoxLayout newLeftToRight
				add: 'Arguments'
					withConstraints: [ :aConstraints | aConstraints width: 80 ];
				add: #argumentsList;
				add:
					(SpBoxLayout newTopToBottom
						add: #upButton
							withConstraints: [ :aConstraints | aConstraints height: 30 ];
						add: #downButton
							withConstraints: [ :aConstraints | aConstraints height: 30 ];
						yourself)
					withConstraints: [ :aConstraints | aConstraints width: 30 ];
				yourself);
		add:
			(SpBoxLayout newLeftToRight
				add: 'Edit'
					withConstraints: [ :aConstraints | aConstraints width: 80 ];
				add: #editParameter; 
				add:
					(SpBoxLayout newTopToBottom
						add: #okEdit
							withConstraints: [ :aConstraints | aConstraints height: 20 ];
						yourself)
					withConstraints: [ :aConstraints | aConstraints width: 30 ];
				yourself);
		add:
			(SpBoxLayout newLeftToRight
				add: 'Preview'
					withConstraints: [ :aConstraints | aConstraints width: 80 ];
				add: #previewResult yourself);
		yourself
]

{ #category : #specs }
SycMethodNameEditorPresenter class >> defaultSpec [
	^ SpBoxLayout newTopToBottom
		add:
			(SpBoxLayout newLeftToRight
				add: 'Selector'
					withConstraints: [ :aConstraints | aConstraints width: 80 ];
				add: #selectorInput;
				yourself);
		add:
			(SpBoxLayout newLeftToRight
				add: 'Arguments'
					withConstraints: [ :aConstraints | aConstraints width: 80 ];
				add: #argumentsList;
				add:
					(SpBoxLayout newTopToBottom
						add: #upButton
							withConstraints: [ :aConstraints | aConstraints height: 30 ];
						add: #downButton
							withConstraints: [ :aConstraints | aConstraints height: 30 ];
						yourself)
					withConstraints: [ :aConstraints | aConstraints width: 30 ];
				yourself);
		add:
			(SpBoxLayout newLeftToRight
				add: 'Preview'
					withConstraints: [ :aConstraints | aConstraints width: 80 ];
				add: #previewResult yourself);
		yourself
]

{ #category : #example }
SycMethodNameEditorPresenter class >> example2 [
	<script>
	self
		openOn:
			(RBMethodName
				selector: (RBExtractMethodRefactoring >> #validateRenameOf:to:) selector
				arguments: ((RBExtractMethodRefactoring >> #validateRenameOf:to:) ast arguments collect: [:each | each name]))
]

{ #category : #specs }
SycMethodNameEditorPresenter class >> openOn: aMethod [
	"I take a RBMethodName as parameter and open the refactoring UI in a modal to rename it."
	|temp|
	temp := (self on: aMethod).
	temp isEditable: false.
	temp initializeEditerArgumentList.
	^ temp openModalWithSpec
]

{ #category : #specs }
SycMethodNameEditorPresenter class >> openOn: aMethod withRefactoring: refactoring [
	|temp|
	temp := (self on: aMethod).
	temp refactoring: refactoring.
	temp isEditable: true.
	temp initializeEditerArgumentList.
	^ temp openModalWithSpec
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> addArgumentAfter: anItem [
	| newArg argValue |
	newArg := self newArgName asSymbol.
	argValue := UIManager default
		request: 'Enter default value for argument' initialAnswer: 'nil'.
	self newArgs at: newArg put: argValue.
	argumentsList items: (argumentsList items copyUpThrough: anItem), {newArg}, (argumentsList items copyAfter: anItem).
	self updateLabel
]

{ #category : #services }
SycMethodNameEditorPresenter >> alert: aString [
	"Display a message for the user to read and then dismiss."

	aString isEmptyOrNil
		ifFalse: [ UIManager default alert: aString ]
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> argumentsList [
	^ argumentsList
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> argumentsListMenu [
	^ self newMenu
		addGroup: [ :aGroup | 
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Add';
						iconName: #add;
						action: [ self addArgumentAfter: argumentsList selectedItem ] ];
				addItem: [ :anItem | 
					anItem
						name: 'Remove';
						shortcut: $x meta;
						iconName: #remove;
						description: 'Remove argument';
						action: [ self removeArgument: argumentsList selectedItem ] ] ]
]

{ #category : #action }
SycMethodNameEditorPresenter >> computePermutation [
	^ argumentsList items collect: [ :e |
		args indexOf: e ifAbsent: [ (newArgs indexOfKey: e ifAbsent: [ 0 ]) * -1 ]
	 ]
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> defaultParameterPlaceholderString [
	"the placeholder string to be used in parameter inputs"
	^ 'aParameterName'
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> downButton [
	^ downButton
]

{ #category : #services }
SycMethodNameEditorPresenter >> editParameter [
	| selected newName|
	newName := editParameter text asSymbol.
	selected := argumentsList items at: (argumentsList selection selectedIndex).
	newName = selected ifTrue: [ ^ self ].
	refactoring parameterMap: editerArgumentList;
		   		   validateRenameOf: selected to: newName.
	editerArgumentList at: (self getKeyOf: selected) put: newName.
	self updateItem: selected to: newName.
	self updateLabel
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> editParameterInput [
	
	^ editParameter
]

{ #category : #services }
SycMethodNameEditorPresenter >> getKeyOf: aValue [
	|keyOfValue|
	editerArgumentList keysAndValuesDo: [ :key :value | 
		aValue = value ifTrue: [ keyOfValue := key ] ].
	^ keyOfValue
]

{ #category : #services }
SycMethodNameEditorPresenter >> getParametersOrder [
	^ argumentsList items collect: [ :each | self getKeyOf: each ]
	
]

{ #category : #initialization }
SycMethodNameEditorPresenter >> initializeDialogWindow: aModalPresenter [
	aModalPresenter
		closeOnBackdropClick: true;
		addButton: 'Rename' do: [ :presenter | self renameMethodAndClose: presenter ];
		addButton: 'Cancel' do: [ :presenter | presenter beCancel; close ];
		initialExtent: 600 @ 300 ;
		title: 'Method name editor'
]

{ #category : #services }
SycMethodNameEditorPresenter >> initializeEditerArgumentList [
	editerArgumentList := Dictionary new.
	methodName arguments do: [ :each | 
		editerArgumentList at: each put: each ]
]

{ #category : #initialization }
SycMethodNameEditorPresenter >> initializePresenter [
	selectorInput whenTextChangedDo: [ :text | self updateLabel ].
	upButton action: [ self pushUpSelectedArgument ].
	downButton action: [ self pushDownSelectedArgument ].

	argumentsList
		whenModelChangedDo: [ :model | 
			model
				ifEmpty: [ upButton disable.
					downButton disable ] ].

	argumentsList items: methodName arguments;
		contextMenu: self argumentsListMenu.
	self updateEditArgumentInput.
	
	argumentsList whenSelectionChangedDo: [ self updateEditArgumentInput ].
	okEdit action: [ self validateEditParameter ]

]

{ #category : #initialization }
SycMethodNameEditorPresenter >> initializeWidgets [
	selectorInput := self instantiate: SpTextInputFieldPresenter.
	argumentsList := self newList.
	previewResult := self newLabel.
	upButton := self newButton.
	downButton := self newButton.
	
	selectorInput autoAccept: true.
	upButton label: 'Up'.
	downButton label: 'Dn'.
	selectorInput text: methodName selector.
	previewResult label: methodName methodName.
	editParameter := (self instantiate: SpTextInputFieldPresenter) autoAccept: true.
	editParameter placeholder: self defaultParameterPlaceholderString.
	okEdit := self newButton.
	
	okEdit label: 'Ok'.
	okEdit enabled: false.
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> isEditable: aBoolean [ 
	isEditable := aBoolean .
	
	isEditable ifTrue: [ self buildWithSpecLayout: self class defaultEditableSpec ]
	ifFalse: [ self buildWithSpecLayout: self class defaultSpec ]
	
]

{ #category : #'instance creation' }
SycMethodNameEditorPresenter >> newArgName [
	| baseString index newString |
	newString := baseString := 'arg'.
	index := 0.
	
	[ args includes: newString ] 
			whileTrue: 
				[index := index + 1.
				newString := baseString , index printString].
	^newString
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> newArgs [
	^ newArgs ifNil: [ newArgs := OrderedDictionary new ]
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> okButton [
	
	^ okEdit
]

{ #category : #services }
SycMethodNameEditorPresenter >> okEdit [
	^ okEdit
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> previewResult [
	^ previewResult
]

{ #category : #action }
SycMethodNameEditorPresenter >> pushDownSelectedArgument [
	| selectedIndex |
	selectedIndex := argumentsList selection selectedIndex.
	selectedIndex = argumentsList items size
		ifTrue: [ ^ self inform: 'The argument is already the last of the list.' ].
	argumentsList items swap: selectedIndex with: selectedIndex + 1.
	argumentsList selectIndex: selectedIndex + 1.
	self updateLabel
]

{ #category : #action }
SycMethodNameEditorPresenter >> pushUpSelectedArgument [
	| selectedIndex |
	selectedIndex := argumentsList selection selectedIndex.
	selectedIndex = 1
		ifTrue: [ ^ self inform: 'The argument is already the first of the list.' ].
	argumentsList items swap: selectedIndex with: selectedIndex - 1.
	argumentsList selectIndex: selectedIndex - 1.
	self updateLabel
]

{ #category : #services }
SycMethodNameEditorPresenter >> refactoring [
	^ refactoring
]

{ #category : #services }
SycMethodNameEditorPresenter >> refactoring: anObject [
	refactoring := anObject 
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> removeArgument: anItem [
	self newArgs removeKey: anItem ifAbsent: [  ].
	argumentsList items: (argumentsList items copyUpTo: anItem), (argumentsList items copyAfter: anItem).
	self updateLabel
]

{ #category : #action }
SycMethodNameEditorPresenter >> renameMethodAndClose: presenter [
	^ self previewResult label = '(invalid)'
		ifTrue: [ self inform: 'Invalid method name' ]
		ifFalse: [
			refactoring ifNotNil: [ refactoring parameterMap: editerArgumentList].
			methodName
				arguments: self getParametersOrder;
				selector: selectorInput text;
				newArgs: self newArgs;
				permutation: self computePermutation.
			presenter
				beOk;
				close ]
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> selectorInput [
	^ selectorInput
]

{ #category : #'accessing model' }
SycMethodNameEditorPresenter >> setModelBeforeInitialization: aRBMethodName [
	methodName := aRBMethodName.
	args := methodName arguments copy
]

{ #category : #accessing }
SycMethodNameEditorPresenter >> upButton [
	^ upButton
]

{ #category : #services }
SycMethodNameEditorPresenter >> updateEditArgumentInput [
	(argumentsList listSize > 0) ifTrue: [ argumentsList selectIndex: 1].
	argumentsList selection isEmpty
		ifTrue: [ 
			editParameter
				text: '';
				enabled: false.
			okEdit enabled: false.
			^ self ].

	okEdit enabled: true.
	editParameter
		enabled: true;
		text: argumentsList selection selectedItem
]

{ #category : #services }
SycMethodNameEditorPresenter >> updateItem: selected to: newName [
	argumentsList items doWithIndex: [ :each :index | 
		each = selected ifTrue: [ argumentsList items at: index put: newName  ] ]
]

{ #category : #action }
SycMethodNameEditorPresenter >> updateLabel [
	"Update the new method name to display to the user when the user change its name or order of the arguments."

	previewResult
		label:
			(RBMethodName
				selector: self selectorInput text
				arguments: argumentsList items) methodName
]

{ #category : #services }
SycMethodNameEditorPresenter >> validateEditParameter [
	self previewResult label = '(invalid)'
		ifTrue: [ self alert: 'You can not rename parameters if you have an invalid method name' ]
		ifFalse: [ [ self editParameter  ]
 			on: RBRefactoringError 
			do: [:ex | self alert: ex messageText] 
	]
]
