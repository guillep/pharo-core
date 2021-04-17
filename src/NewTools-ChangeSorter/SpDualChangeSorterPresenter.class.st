"
A `SpDualChangeSorterPresenter is a dual change sorter. It manages two sets of changes so that we can cherry pick and creates new changes. 

`SpDualChangeSorterPresenter` shares the model between its two subcomponents that are instances of  `SpChangeSorterPresenter`. The class `ChangeSorterModel` defines the application logic.

"
Class {
	#name : #SpDualChangeSorterPresenter,
	#superclass : #StPresenter,
	#instVars : [
		'model',
		'changeSorterLeft',
		'changeSorterRight',
		'isRefreshing'
	],
	#category : #'NewTools-ChangeSorter'
}

{ #category : #specs }
SpDualChangeSorterPresenter class >> defaultSpec [
	<spec>
	^ SpPanedLayout newHorizontal
		add: #changeSorterLeft;
		add: #changeSorterRight;
		yourself
]

{ #category : #menu }
SpDualChangeSorterPresenter class >> menuCommandOn: aBuilder [
	<worldMenu>
	
	(aBuilder group: #SystemChanges)
		parent: #Tools;
		order: 410;
		with: [ 
			(aBuilder item: #'Change Sorter')
				action: [ self open ];
				help: 'Examine the different change set of the image.';
				icon: self taskbarIcon ].
	aBuilder withSeparatorAfter
]

{ #category : #opening }
SpDualChangeSorterPresenter class >> open [
	<script>
	
	self new openWithSpec
]

{ #category : #'tools-registry' }
SpDualChangeSorterPresenter class >> registerToolsOn: registry [
	"Add ourselves to registry. See [Smalltalk tools]"

	registry register: self as: #changeSorter
]

{ #category : #icons }
SpDualChangeSorterPresenter class >> taskbarIconName [
	^ #changeSorterIcon
]

{ #category : #accessing }
SpDualChangeSorterPresenter class >> title [
	^ 'Dual Change Sorter'
]

{ #category : #menu }
SpDualChangeSorterPresenter >> changeSetMenuFrom: sourcePanel to: destinationPanel [
	"Fill aMenu with items appropriate for the changes list"

	^ sourcePanel changeSetMenu
		addGroup: [ :aGroup | 
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Copy all to the other change set';
						shortcut: $s meta;
						action: [ self copyAllFrom: sourcePanel to: destinationPanel ] ];
				addItem: [ :anItem | 
					anItem
						name: 'Submerge into the other change set';
						action: [ self submerge: sourcePanel into: destinationPanel ] ];
				addItem: [ :anItem | 
					anItem
						name: 'Subtract the other change set';
						shortcut: $- meta;
						action: [ self subtractFrom: sourcePanel to: destinationPanel ] ] ];
		yourself
]

{ #category : #accessing }
SpDualChangeSorterPresenter >> changeSorterLeft [

	^ changeSorterLeft
]

{ #category : #accessing }
SpDualChangeSorterPresenter >> changeSorterRight [

	^ changeSorterRight
]

{ #category : #'menu - change set' }
SpDualChangeSorterPresenter >> checkThatSidesDiffer: escapeBlock [
	"If the change sets on both sides of the dual sorter are the same, put up an error message and escape via escapeBlock, else proceed happily"

	changeSorterLeft selectedChangeSet == changeSorterRight selectedChangeSet
		ifFalse: [ ^ self ].
	self
		inform:
			'This command requires that the
change sets selected on the two
sides of the change sorter *not*
be the same.'.
	^ escapeBlock value
]

{ #category : #menu }
SpDualChangeSorterPresenter >> classMenuFrom: sourcePanel to: destinationPanel [
	"Fill aMenu with items appropriate for the class list"

	^ sourcePanel classMenu
		addGroup: [ :aGroup | 
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Copy class to the other change set';
						action: [ self copyClassFrom: sourcePanel to: destinationPanel ] ];
				addItem: [ :anItem | 
					anItem
						name: 'Move class to the other change set';
						action: [ self moveClassFrom: sourcePanel to: destinationPanel ] ] ];
		yourself
]

{ #category : #initialization }
SpDualChangeSorterPresenter >> connectPresenters [

	changeSorterLeft 	whenChangesListChanges: [ self refeshedChangeSet: changeSorterRight ].
	changeSorterRight	whenChangesListChanges: [ self refeshedChangeSet: changeSorterLeft ].


]

{ #category : #'menu - change set' }
SpDualChangeSorterPresenter >> copyAllFrom: src to: dest [

	self checkThatSidesDiffer: [ ^ self ].
	self model copyAllChangesFrom: (src selectedChangeSet) to: (dest selectedChangeSet).
	dest updateClassesList.
]

{ #category : #'menu - class' }
SpDualChangeSorterPresenter >> copyClassFrom: src to: dest [
	"Place these changes in the other changeSet also"

	| otherChangeSet |
	self checkThatSidesDiffer: [ ^ self ].
	self okToChange ifFalse: [ ^ self inform: 'Can''t discard edits.' ].
	src selectedClass ifNil: [ ^ self inform: 'Selected class is nil.' ].
	otherChangeSet := dest selectedChangeSet.
	
	self model copyClass: src selectedClass from: src selectedChangeSet to: otherChangeSet.
	
	dest setSelectedChangeSet: otherChangeSet.
]

{ #category : #'menu - method' }
SpDualChangeSorterPresenter >> copyMethodFrom: src to: dest [
	"Place this change in the other changeSet also"	
	| other |
	
	self checkThatSidesDiffer: [^ self].
	other := dest selectedChangeSet.
	
	src selectedSelector ifNotNil: [:selector || class |
		class := src selectedClass.
		
		self model 
			copySelector: selector 
			inClass: class 
			from: src selectedChangeSet 
			to: other.
			
		dest updateClassesListAndMessagesList ].
]

{ #category : #initialization }
SpDualChangeSorterPresenter >> initialize [

	super initialize.
	model := ChangeSorterModel new.
	isRefreshing := false.
	SystemAnnouncer uniqueInstance weak 
		when: CurrentChangeSetChanged 
		send: #updateTitle 
		to: self 
]

{ #category : #initialization }
SpDualChangeSorterPresenter >> initializePresenters [

	changeSorterLeft := self instantiate: SpChangeSorterPresenter.
	changeSorterRight := self instantiate: SpChangeSorterPresenter.
		
	self menusRegistration.
	self shortcutsRegistration.
	self setFocusOrder
]

{ #category : #initialization }
SpDualChangeSorterPresenter >> initializeWindow: aWindowPresenter [
	aWindowPresenter initialExtent: 900 @ 530.
	aWindowPresenter title: self title
]

{ #category : #initialization }
SpDualChangeSorterPresenter >> menusRegistration [

	self menusRegistrationFrom: changeSorterLeft to: changeSorterRight.
	self menusRegistrationFrom: changeSorterRight to: changeSorterLeft
]

{ #category : #menu }
SpDualChangeSorterPresenter >> menusRegistrationFrom: src to: dest [
	src changesMenu: (self changeSetMenuFrom: src to: dest).
	src classesMenu: (self classMenuFrom: src to: dest).
	src methodsMenu: (self messageMenuFrom: src to: dest)
]

{ #category : #menu }
SpDualChangeSorterPresenter >> messageMenuFrom: sourcePanel to: destinationPanel [
	"Fill aMenu with items appropriate for the message list; could be for a single or double changeSorter"

	^ sourcePanel messageMenu
		addGroup: [ :aGroup | 
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Copy method to the other change set';
						action: [ self copyMethodFrom: sourcePanel to: destinationPanel ] ];
				addItem: [ :anItem | 
					anItem
						name: 'Move method to the other change set';
						action: [ self moveMethodFrom: sourcePanel to: destinationPanel ] ] ];
		yourself
]

{ #category : #accessing }
SpDualChangeSorterPresenter >> model [

	^ model
]

{ #category : #'menu - class' }
SpDualChangeSorterPresenter >> moveClassFrom: src to: dest [

	self checkThatSidesDiffer: [^ self].
	(self okToChange and: [ src selectedClass notNil]) ifFalse: [ ^ self ].

	self copyClassFrom: src to: dest.
	src forgetClass
]

{ #category : #'menu - method' }
SpDualChangeSorterPresenter >> moveMethodFrom: src to: dest [

	self copyMethodFrom: src to: dest.
	src forgetMessage.
	src updateClassesListAndMessagesList.
]

{ #category : #event }
SpDualChangeSorterPresenter >> refeshedChangeSet: changeSet [
	isRefreshing
		ifTrue: [ ^ self ].
	isRefreshing := true.
	changeSet updateChangesList.
	isRefreshing := false
]

{ #category : #initialization }
SpDualChangeSorterPresenter >> setFocusOrder [

	self focusOrder
		add: changeSorterLeft;
		add: changeSorterRight.
]

{ #category : #initialization }
SpDualChangeSorterPresenter >> shortcutsRegistration [

	self shortcutsRegistrationFrom: changeSorterLeft to: changeSorterRight.
	self shortcutsRegistrationFrom: changeSorterRight to: changeSorterLeft.
]

{ #category : #initialization }
SpDualChangeSorterPresenter >> shortcutsRegistrationFrom: src to: dest [
	
	src changesPresenterOn: $c meta do: [ self copyAllFrom: src to: dest ].
	src changesPresenterOn: $- meta do: [ self subtractFrom: src to: dest ]. 
]

{ #category : #'menu - change set' }
SpDualChangeSorterPresenter >> submergeFrom: src into: dest [
	"Copy the contents of the receiver to the other side, then remove the receiver -- all after checking that all is well."
	| source destination index |

	source := src selectedChangeSet.
	destination := dest selectedChangeSet.
	index := src selectedChangeSetIndex.

	(self model submerge: source into: destination) ifFalse: [ ^ self ].
	
	src updateChangesList.
	src setSelectedChangeSetIndex: index.
]

{ #category : #'menu - change set' }
SpDualChangeSorterPresenter >> subtractFrom: src to: dest [
	"Subtract the changes found on the other side from the requesting side."
	| source destination |
	source := src selectedChangeSet.
	destination := dest selectedChangeSet.
	
	self checkThatSidesDiffer: [^ self].
	
	self model subtractFrom: source to: destination.
	
	changeSorterRight setSelectedChangeSet: source.
]

{ #category : #'api-window' }
SpDualChangeSorterPresenter >> title [
	^ String streamContents: [ :stream | stream << self class title << ' on: ' << self model currentChangeSet name ]
]

{ #category : #api }
SpDualChangeSorterPresenter >> updateTitle [
	self window title: self title
]
