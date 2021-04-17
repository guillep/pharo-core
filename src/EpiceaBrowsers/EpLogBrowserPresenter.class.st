"
I am a Spec browser for an EpLog.

For example, open with:

self open

"
Class {
	#name : #EpLogBrowserPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'log',
		'andFilter',
		'selectionDeferrer',
		'cachedLogEntries',
		'commentsLog',
		'cachedItems',
		'showEntryItemMenu',
		'entryContentPresenter',
		'itemsPresenter',
		'toolbarPresenter'
	],
	#category : #'EpiceaBrowsers-UI-Log'
}

{ #category : #accessing }
EpLogBrowserPresenter class >> defaultLog [

	^ EpMonitor current log
]

{ #category : #specs }
EpLogBrowserPresenter class >> defaultSpec [
	^ SpPanedLayout newVertical
		position: 0.6;
		add: #itemsPresenter;
		add:
			(SpBoxLayout newVertical
				add: #toolbarPresenter expand: false fill: false padding: 2;
				add: #entryContentPresenter expand: true fill: true padding: 2;
				yourself);
		yourself
]

{ #category : #'instance creation' }
EpLogBrowserPresenter class >> newWithLog: aLog [

	^ self new
		theLog: aLog;
		yourself
]

{ #category : #'instance creation' }
EpLogBrowserPresenter class >> open [
	<script>
	^ self openWithLog: self defaultLog
]

{ #category : #'instance creation' }
EpLogBrowserPresenter class >> openWithLog: aLog [
	^ (self newWithLog: aLog)
		refresh;
		openWithSpec;
		yourself
]

{ #category : #private }
EpLogBrowserPresenter >> addFilter: aFilter [

	(andFilter subFilters includes: aFilter) ifTrue: [ ^self ].
	
	andFilter := EpAndFilter withAll: (andFilter subFilters copyWith: aFilter).
	self refresh.
]

{ #category : #menu }
EpLogBrowserPresenter >> addMenuItemsForSelectedItemsIn: aMenu [

	aMenu addGroup: [ :aGroup | 
		self menuActionsForSelectedItems do: [ :oldStyleMenuItemArray | 
			aGroup addItem: [ :anItem | 
				anItem
					name: oldStyleMenuItemArray first;
					description: oldStyleMenuItemArray third;
					icon: (self iconNamed: oldStyleMenuItemArray fourth);
					action: [ self perform: oldStyleMenuItemArray second ] ] ] ].

	aMenu addGroup: [ :aGroup | 
		aGroup addItem: [ :anItem | 
			anItem
				name: 'Filters';
				icon: (self iconNamed: #smallFindIcon);
				subMenu: self filtersSubMenu ] ].

	aMenu addGroup: [ :aGroup | 
		aGroup addItem: [ :anItem | 
			anItem
				name: 'Write Ombu file';
				description: 'Write selected entries to an Ombu file';
				icon: (self iconNamed: #smallSaveAsIcon);
				action: [ self ombuFileSaveSelection ] ] ].

]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> applyAllChangesAndCloseWindow [

	self applyChangesIn: self entriesWithCodeChanges.
	self window close.

]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> applyChangesIn: entries [
	
	entries ifEmpty: [ ^ self inform: 'No code changes to apply' ].

	EpLogBrowserOperationFactory new
		logBrowserModel: self;
		entries: entries;
		errorHandlerBlock: self operationsErrorHandlerBlock;
		applyCodeChanges.

]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> applyCompleteRefactoringInSelection [

	| entries |
	entries := self selectedEntries.
	entries size = 1 ifFalse: [ 
		^ self inform: 'Please select one refactoring' ]. "Only implemented for one"
	
	EpLogBrowserOperationFactory new
		logBrowserModel: self;
		entries: entries;
		errorHandlerBlock: self operationsErrorHandlerBlock;	
		applyCompleteRefactoring.

]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> applyPropagateRefactoringInSelection [

	| entries |
	entries := self selectedEntries.
	entries size = 1 ifFalse: [ 
		^ self inform: 'Please select one refactoring' ]. "Only implemented for one"
	
	EpLogBrowserOperationFactory new
		logBrowserModel: self;
		entries: entries;
		errorHandlerBlock: self operationsErrorHandlerBlock;
		applyPropagateRefactoring.

]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> applySelectedChanges [

	self applyChangesIn: self selectedCodeChanges

]

{ #category : #modes }
EpLogBrowserPresenter >> beApplyMode [
	self withWindowDo: [ :window | window title: 'Epicea - Apply Changes' ].
	toolbarPresenter beApplyMode.
	showEntryItemMenu := false
]

{ #category : #modes }
EpLogBrowserPresenter >> beHistoryMode [
	self withWindowDo: [ :window | window title: 'Epicea - Log Browser' ].
	toolbarPresenter beHistoryMode.
	showEntryItemMenu := true
]

{ #category : #modes }
EpLogBrowserPresenter >> beRevertMode [
	self withWindowDo: [ :window | window title: 'Epicea - Revert Changes' ].
	toolbarPresenter beRevertMode.
	showEntryItemMenu := false
]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> browseSelection [

	| selectionSize |
	selectionSize := self selectedEntryReferences size.	
	selectionSize > 3 ifTrue: [
		(self confirm: 'Do you want to open a browser for each code changes? (', selectionSize asString, ' items selected)')
			ifFalse: [ ^self ] ].

	self selectedEntryItems 
		select: [ :each | each entry content isCodeChange ] 
		thenDo: [ :each | each browseItem ]
]

{ #category : #private }
EpLogBrowserPresenter >> cachedItems [

	^ cachedItems ifNil: [ cachedItems := WeakValueDictionary new ]
]

{ #category : #accessing }
EpLogBrowserPresenter >> cachedLogEntries [
	"Answer log entries.
	Check size since the log might be current Monitor's, so it can grow."

	^ (cachedLogEntries isNotNil and: [ cachedLogEntries size = log entriesCount ])
		ifTrue: [ cachedLogEntries ]
		ifFalse: [
			'Reading log'
				displayProgressFrom: 0 to: 1 
				during: [ cachedLogEntries := log entries ]
			]

]

{ #category : #refreshing }
EpLogBrowserPresenter >> cleanEntryContent [
	self refreshEntryContentWith: #()
]

{ #category : #menu }
EpLogBrowserPresenter >> codeChangesMenuActions [

	^ { 
		{ 'Apply...'.
		#openPreviewToApplySelectedChanges.
		'Preview the application of selected code changes (open a new window to show the effect of re-applying the changes in current image)'.
		#smallRedoIcon.
		$p command }.
		{ 'Revert...'.
		#openPreviewToRevertSelectedChanges.
		'Preview the reversion of selected code changes (open a new window to show the effect of reverting the changes in current image)'.
		#smallUndoIcon.
		$r command }.
		{ 'Browse current'.
		#browseSelection.
		'Browse working copy of entity affected in the selected event(s)'.
		#nautilusIcon.
		$b command }.
	}

]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> commentSelection [

	| items newCommentOrNil oldComment entryReferences |
	items := self selectedEntryItems.
	entryReferences := items collect: [:each | each reference].
	oldComment := items anyOne oldComment.
		
	newCommentOrNil := UIManager default
		multiLineRequest: 'Enter a comment for the selection' 
		initialAnswer: oldComment
		answerHeight: 250.

	newCommentOrNil ifNil: [ ^ self ].
	
	self logOffEvent:
		(EpLogEntriesComment 
			entryReferences: entryReferences 
			oldComment: oldComment 
			newComment: newCommentOrNil)
]

{ #category : #accessing }
EpLogBrowserPresenter >> commentsLog [
	
	^ commentsLog ifNil: [ self monitor log ]
]

{ #category : #accessing }
EpLogBrowserPresenter >> commentsLog: anEpLog [
	
	commentsLog := anEpLog
]

{ #category : #accessing }
EpLogBrowserPresenter >> entries [

	^ log entryReferences collect: [:each | log entryFor: each ]

]

{ #category : #accessing }
EpLogBrowserPresenter >> entriesWithCodeChanges [

	^ self entries select: [:each | each content isCodeChange ]
]

{ #category : #accessing }
EpLogBrowserPresenter >> entryItems [

	^ log entryReferences collect: [:each |
		self itemForEntryReference: each ]
]

{ #category : #menu }
EpLogBrowserPresenter >> eventsMenuActions [ 

	^ {
		{ 'Comment'. 
		#commentSelection.
		'Edit comment of selected entries'.
		#announcementIcon. 
		$c command }.
	}

]

{ #category : #'menu - filters' }
EpLogBrowserPresenter >> filterAfter [

	self selectedEntryItems ifNotEmpty: [ :items |
		| time |
		time := items first entry tags at: EpLog timeKey.
		self addFilter: (EpPluggableFilter after: time) ]
]

{ #category : #'menu - filters' }
EpLogBrowserPresenter >> filterAllChangesToSelection [

	| changes |
	changes := (self selectedEntryItems collect: [ :each | each entry content ]).

	changes size = 1 ifFalse: [ ^ self inform: 'Should select a single method change' ]. 
	changes anyOne isEpMethodChange ifFalse: [ ^ self inform: 'Should select a method' ]. 

	self addFilter: (EpPluggableFilter isMethod: changes anyOne methodAffected).
]

{ #category : #'menu - filters' }
EpLogBrowserPresenter >> filterAllChangesToSelectionBehavior [

	| changes |
	changes := self selectedEntryItems collect: [ :each | each entry content ].

	changes size = 1 ifFalse: [ ^ self inform: 'Should select a single change, either to a class or a trait' ]. 
	changes anyOne isEpMethodChange ifFalse: [ ^ self inform: 'Should select a method' ]. 

	self addFilter: (EpPluggableFilter isBehaviorNamed: changes anyOne behaviorAffectedName).
]

{ #category : #'menu - filters' }
EpLogBrowserPresenter >> filterAllChangesToSelectionPackage [

	| changes |
	changes := (self selectedEntryItems collect: [ :each | each entry content ]).

	changes size = 1 ifFalse: [ ^ self inform: 'Should select a single change' ]. 

	self addFilter: (EpPluggableFilter isPackageNamed: changes anyOne affectedPackageName).
]

{ #category : #'menu - filters' }
EpLogBrowserPresenter >> filterBefore [

	self selectedEntryItems ifNotEmpty: [ :items |
		| time |
		time := items last entry tags at: EpLog timeKey.
		self addFilter: (EpPluggableFilter before: time) ]
]

{ #category : #'menu - filters' }
EpLogBrowserPresenter >> filterImpactCodeChanges [

	self addFilter: (EpImpactCodeChangeFilter new environment: self class environment; yourself)
]

{ #category : #'menu - filters' }
EpLogBrowserPresenter >> filterLatestCodeChanges [

	self addFilter: (EpLatestCodeChangeFilter new logBrowserModel: self; yourself)
]

{ #category : #'menu - filters' }
EpLogBrowserPresenter >> filterSelection [

	| references |
	references := self selectedEntryReferences.

	references ifEmpty: [ ^self inform: 'Selection is empty' ].

	self addFilter: (EpEntryReferencesFilter new
		theLog: log; 
		rejectedEntryReferences: references; 
		yourself).

]

{ #category : #'menu - filters' }
EpLogBrowserPresenter >> filterToday [

	self addFilter: EpPluggableFilter todayFilter
]

{ #category : #accessing }
EpLogBrowserPresenter >> filteredEntries [
	
	^ self filteredEntryReferences collect: [:each | log entryFor: each ]
]

{ #category : #accessing }
EpLogBrowserPresenter >> filteredEntriesCount [

	^ self filteredEntryReferences size

]

{ #category : #accessing }
EpLogBrowserPresenter >> filteredEntryReferences [

	^ andFilter subFilters 
		ifEmpty: [ log entryReferences ]
		ifNotEmpty: [
			self cachedLogEntries
				select: [:each | andFilter accepts: each ]
				thenCollect: [:each | log referenceTo: each ] ].

]

{ #category : #accessing }
EpLogBrowserPresenter >> filters [

	^ andFilter subFilters
]

{ #category : #menu }
EpLogBrowserPresenter >> filtersSubMenu [
	
	| aMenu |
	aMenu := SpMenuPresenter new.
	
	aMenu addGroup: [ :aGroup |
		aGroup addItem: [ :anItem |
			anItem
				name: 'Clean filters (', self filters size asString, ' active)';
				icon: (self iconNamed: #smallDelete);
				action: [ self removeAllFilters ] ].
		].

	aMenu addGroup: [ :aGroup |

		aGroup addItem: [ :anItem |
			anItem 
				name: EpLatestCodeChangeFilter title;
				description: EpLatestCodeChangeFilter comment;
				icon: (self iconNamed: #smallFind);
				action: [ self filterLatestCodeChanges ] ].

		aGroup addItem: [ :anItem |
			anItem 
				name: EpImpactCodeChangeFilter title;
				description: EpImpactCodeChangeFilter comment;
				icon: (self iconNamed: #smallFind);
				action: [ self filterImpactCodeChanges ] ].
	].

	aMenu addGroup: [ :aGroup |

		aGroup addItem: [ :anItem |
			anItem 
				name: EpEntryReferencesFilter title;
				icon: (self iconNamed: #smallFind);
				action: [ self filterSelection ] 
			].
		
		aGroup addItem: [ :anItem |
			anItem 
				name: 'Show only changes to this method';
				description: 'Show only additions, modifications or removals of this method.';
				icon: (self iconNamed: #smallFind);
				action: [ self filterAllChangesToSelection ] ].

		aGroup addItem: [ :anItem |
			anItem 
				name: 'Show only changes to this class or trait';
				description: 'Show only changes in the scope of this class or trait.';
				icon: (self iconNamed: #smallFind);
				action: [ self filterAllChangesToSelectionBehavior ]
			].
				
		aGroup addItem: [ :anItem |
			anItem 
				name: 'Show only changes in this package';
				description: 'Show only additions, modifications or removals of this package.';
				icon: (self iconNamed: #smallFind);
				action: [ self filterAllChangesToSelectionPackage ]
			].
	].


	aMenu addGroup: [ :aGroup |

		aGroup addItem: [ :anItem |
			anItem 
				name: 'Show only if done today';
				icon: (self iconNamed: #calendar);
				action: [ self filterToday ] ].

		aGroup addItem: [ :anItem |
			anItem 
				name: 'Hide events done after';
				icon: (self iconNamed: #calendar);
				action: [ self filterBefore ] ].

		aGroup addItem: [ :anItem |
			anItem 
				name: 'Hide events done before';
				icon: (self iconNamed: #calendar);
				action: [ self filterAfter ] ].
	].

	aMenu addGroup: [ :aGroup |
		EpPluggableFilter allFilters do: [ :aFilter |
			aGroup addItem: [ :anItem |
				anItem 
					name: aFilter title;
					icon: (self iconNamed: #smallFind);
					description: aFilter title;
					action: [ self addFilter: aFilter ] ] ]
		].

	^ aMenu
]

{ #category : #initialization }
EpLogBrowserPresenter >> initialize [
	super initialize.

	andFilter := EpAndFilter withAll: #()
]

{ #category : #initialization }
EpLogBrowserPresenter >> initializePresenters [

	itemsPresenter := self newList.
	itemsPresenter
		beMultipleSelection;
		display: [ :entryReference | self morphForItemAt: entryReference ];
		whenSelectionChangedDo: [ self refreshEntryContentDeferrer schedule ];
		contextMenu: [ self menuMorphForSelectedItems ].

	toolbarPresenter := self instantiate: EpLogBrowserToolbarPresenter.
	toolbarPresenter logBrowserPresenter: self.

	entryContentPresenter := self newDiff.
	entryContentPresenter showOptions: false.

	self beHistoryMode.
]

{ #category : #initialization }
EpLogBrowserPresenter >> initializeWindow: aWindowPresenter [
	aWindowPresenter initialExtent: 550 @ 700
]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> inspectSelection [

	self selectedEntryItems do: #inspect
]

{ #category : #private }
EpLogBrowserPresenter >> itemForEntryReference: entryReference [

	^ self cachedItems
		at: entryReference
		ifPresent: [:item | item ]
		ifAbsentOrNil: [ 
			| newItem |
			newItem := self newItemForEntryReference: entryReference.
			self cachedItems at: entryReference put: newItem.
			newItem ]
]

{ #category : #accessing }
EpLogBrowserPresenter >> itemsPresenter [
	^ itemsPresenter
]

{ #category : #accessing }
EpLogBrowserPresenter >> log [
	^ log
]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> logOffEvent: anEvent [

	self commentsLog 
		addEntryWith: anEvent
		tags: [ :tags |
			tags at: EpLog authorKey put: self monitor author.
			tags at: EpLog timeKey put: self monitor time ].
]

{ #category : #menu }
EpLogBrowserPresenter >> menuActionsForSelectedItems [

	| selectedReferences |
	selectedReferences := self selectedEntryReferences.

	selectedReferences isEmpty ifTrue: [ ^#() ].
	
	selectedReferences size = 1 ifTrue: [
		| event |
		event := (self itemForEntryReference: selectedReferences anyOne) event.
		(event isEpRefactoring and: [ event canBuildRBRefactoring ])
			ifTrue: [ ^ self refactoringMenuActions, self eventsMenuActions ]].

	^ self codeChangesMenuActions, self eventsMenuActions

]

{ #category : #menu }
EpLogBrowserPresenter >> menuMorphForSelectedItems [
	| aMenu |
	aMenu := self newMenu.

	showEntryItemMenu ifTrue: [ self addMenuItemsForSelectedItemsIn: aMenu ].

	^ aMenu
]

{ #category : #accessing }
EpLogBrowserPresenter >> monitor [
	
	^ EpMonitor current
]

{ #category : #private }
EpLogBrowserPresenter >> morphForItemAt: entryReference [

	^ [ (self itemForEntryReference: entryReference) asMorph ]
			on: NotFound do: [:error | error asString asMorph ] "Enforce... remove it?"
]

{ #category : #private }
EpLogBrowserPresenter >> newItemForEntryReference: entryReference [

	| entry triggers|
	entry := log entryFor: entryReference.
	
	triggers := [ self triggerItemsFor: entry ] 
		on: NotFound 
		do: [ #() ]. "Just hide it... not an esential information"
	
	^ EpEntryItem new
		browser: self;
		entry: entry;
		triggerItems: triggers;
		yourself
]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> ombuFileSaveSelection [

	| entries |
	entries := self selectedEntryItems collect: [ :each | each entry ].
	
	EpOmbuExporter askFileNameAndFileOut: entries in: FileLocator workingDirectory.
]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> openPreviewToApplySelectedChanges [

	| entries previewLog |
	entries := self selectedCodeChanges.
	entries ifEmpty: [ ^ self inform: 'No changes to preview apply' ].

	previewLog := EpLogBrowserOperationFactory new
		logBrowserModel: self;
		entries: entries;
		errorHandlerBlock: self operationsErrorHandlerBlock;
		newApplyPreviewLog.

	previewLog isEmpty
		ifTrue: [ self inform: 'Preview is empty (no changes to apply in current image)' ]
		ifFalse: [ previewLog browseEvents beApplyMode ]
]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> openPreviewToRevertSelectedChanges [

	| entries previewLog |
	entries := self selectedCodeChanges.
	entries ifEmpty: [ ^ self inform: 'No changes to preview revert' ].

	previewLog := EpLogBrowserOperationFactory new
		logBrowserModel: self;
		entries: entries;
		errorHandlerBlock: self operationsErrorHandlerBlock;
		newRevertPreviewLog.

	previewLog isEmpty
		ifTrue: [ self inform: 'Preview is empty (no changes to revert in current image)' ]
		ifFalse: [ previewLog browseEvents beRevertMode ]
]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> operationsErrorHandlerBlock [

	^ [ :error | | message |
		message := self title, ' error on operation: ', error asString.
		message traceCr.
		self inform: message. ]
]

{ #category : #menu }
EpLogBrowserPresenter >> refactoringMenuActions [

	^ {
		{ 'Apply refactoring'.
		#applyCompleteRefactoringInSelection.
		'Apply selected refactoring'.
		#smallRedoIcon.
		$y command }.
		{ 'Apply secondary effects of refactoring'.
		#applyPropagateRefactoringInSelection.
		'Apply only the secondary effects of the selected refactoring'.
		#smallRedoIcon.
		$s command }
	}
]

{ #category : #refreshing }
EpLogBrowserPresenter >> refresh [
	"Refresh log"

	itemsPresenter items: self filteredEntryReferences reversed.
	toolbarPresenter refresh
]

{ #category : #refreshing }
EpLogBrowserPresenter >> refreshEntryContent [
	self refreshEntryContentWith: self selectedEntryItems
]

{ #category : #refreshing }
EpLogBrowserPresenter >> refreshEntryContentDeferrer [
		
	^ selectionDeferrer ifNil: [
		selectionDeferrer := OmDeferrer 
			send: #refreshEntryContent
			to: self
			after: 150 milliSeconds ]
]

{ #category : #refreshing }
EpLogBrowserPresenter >> refreshEntryContentWith: selectedItems [
	selectedItems size = 1
		ifTrue: [ | item |
			item := selectedItems anyOne.
			entryContentPresenter
				showOnlyDestination: item oldStateString isEmptyOrNil;
				showOnlySource: item newStateString isEmptyOrNil;
				leftText: item oldStateString;
				rightText: item newStateString ]
		ifFalse: [ entryContentPresenter
				leftText: '';
				rightText: '';
				showOnlyDestination: true ]
]

{ #category : #accessing }
EpLogBrowserPresenter >> removeAllFilters [

	andFilter := EpAndFilter withAll: #().
	self refresh.
]

{ #category : #accessing }
EpLogBrowserPresenter >> removeFilter: aFilter [

	andFilter := EpAndFilter withAll: (andFilter subFilters copyWithout: aFilter).
	self refresh.
]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> revertAllChangesAndCloseWindow [

	self revertChangesIn: self entriesWithCodeChanges.
	self window close.

]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> revertChangesIn: entries [

	entries ifEmpty: [ ^ self inform: 'No code changes to revert' ].

	EpLogBrowserOperationFactory new
		logBrowserModel: self;
		entries: entries;
		errorHandlerBlock: self operationsErrorHandlerBlock;
		revertCodeChangesInPreviewMode.

]

{ #category : #'menu - operations' }
EpLogBrowserPresenter >> revertSelectedChanges [

	self revertChangesIn: self selectedCodeChanges

]

{ #category : #'menu - accessing' }
EpLogBrowserPresenter >> selectedCodeChanges [

	^ self selectedEntryItems 
		select: [ :each | each entry content isCodeChange ]
		thenCollect: [ :each | each entry ]
]

{ #category : #'menu - accessing' }
EpLogBrowserPresenter >> selectedEntries [

	^ self selectedEntryItems collect: [:each | each entry]
]

{ #category : #'menu - accessing' }
EpLogBrowserPresenter >> selectedEntryItems [

	^ self selectedEntryReferences collect: [:each |
		self itemForEntryReference: each ]
]

{ #category : #'menu - accessing' }
EpLogBrowserPresenter >> selectedEntryReferences [
	"Before there was a workaround here to reject nils because it used a FastTablePresenter instead of a list presenter. I have the impression that the workaround is not needed with ListPresenter and I removed the workaround. In case you find a bug were we get nils here, just report it and we will add back the workaround to reject nils with a better comment."

	^ self itemsPresenter selectedItemsSorted reversed
]

{ #category : #accessing }
EpLogBrowserPresenter >> theLog [
	^ log
]

{ #category : #accessing }
EpLogBrowserPresenter >> theLog: aLog [

	cachedItems := nil.
	cachedLogEntries := nil.
	log := aLog.
]

{ #category : #accessing }
EpLogBrowserPresenter >> totalEntriesCount [

	^ self theLog entriesCount
]

{ #category : #private }
EpLogBrowserPresenter >> triggerItemsFor: anEntry [

	^ self log 
		triggererReferenceOf: anEntry 
		ifPresent: [ :triggerEntryReference | 
			| triggerItem |
			triggerItem := self itemForEntryReference: triggerEntryReference.
			triggerItem triggerItems, { triggerItem } ]
		ifAbsent: [ #() ]

]
