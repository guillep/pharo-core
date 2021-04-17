"
I provide the ability to: 
* select a plugin to create/run tests
* select sets of items to analyze
* obtain a detailed log of the results 

UI Description 
___________ 

The droplist contains all the plugins available to start the analysis. 

My left-most pane lists all of the categories that contain items (could subclasses of TestCase, executable comments, etc.); Once items are selected, the items that can be analyzed appear in the pane to right.
The right-most pane shows the results in different groups, depends the plugin's analysis. 

Run and browse buttons behaviour are defined by the current plugin selected.


"
Class {
	#name : #DrTests,
	#superclass : #AbstractDrTestsPresenter,
	#instVars : [
		'pluginsDropList',
		'packagesList',
		'resultsList',
		'statusLabel',
		'plugins',
		'itemsList',
		'resultViewsDropList',
		'resultLabel'
	],
	#category : #'DrTests-Spec'
}

{ #category : #'tools registry' }
DrTests class >> beDefaultTestRunner [
	<script>
	
	self registerToolsOn: Smalltalk tools
]

{ #category : #commands }
DrTests class >> buildCommandsGroupWith: presenterInstance forRoot: rootCommandGroup [

	rootCommandGroup
		register: (self buildContextualPackageGroupWith: presenterInstance);
		register: (self buildItemsListGroupWith: presenterInstance);
		register: (self buildResultGroupWith: presenterInstance)
]

{ #category : #'private - commands' }
DrTests class >> buildContextualPackageGroupWith: presenterInstance [

	^ (CmCommandGroup named: 'Package menu') asSpecGroup
		register: (self buildPackageGroupWith: presenterInstance);
		yourself
]

{ #category : #'private - commands' }
DrTests class >> buildItemsListGroupWith: presenterInstance [

	^ (CmCommandGroup named: 'List items menu') asSpecGroup
		register: (DTBrowseSelectedItemCommand forSpec context: presenterInstance);
		yourself
]

{ #category : #'private - commands' }
DrTests class >> buildPackageGroupWith: presenterInstance [

	|group|
	group := (CmCommandGroup named: 'Package tools') asSpecGroup.
	group description: 'Commands related to packages list.'.
	
	DTPackagesCommand allSubclasses do: [:each | 
		group register: (each forSpec context: presenterInstance) ].
	
	^group 
		beDisplayedAsGroup;
		yourself 
		
		
]

{ #category : #'private - commands' }
DrTests class >> buildResultGroupWith: presenterInstance [

	| commandGroup pluginCommands |
	commandGroup := (CmCommandGroup named: 'Results tools') asSpecGroup
		description: 'Commands related to result.';
		register:
			(DTResultBrowseCommand forSpec context: presenterInstance)
				beHiddenWhenCantBeRun;
		yourself.
	pluginCommands := presenterInstance currentPlugin
		buildContextualMenuGroupWith: presenterInstance.
	pluginCommands entries ifEmpty: [ ^ commandGroup ].
	^ commandGroup
		register: pluginCommands beDisplayedAsGroup;
		yourself
]

{ #category : #specs }
DrTests class >> defaultSpec [

	^ SpBoxLayout newVertical
		add:
			(SpBoxLayout newHorizontal
				add: #pluginsDropList;
				add: #switchButton
					withConstraints: [ :constraints | constraints width: self buttonWidth * 2 ];
				yourself)
			withConstraints: [ :constraints | 
				constraints
					expand: false;
					height: self toolbarHeight ];
		add:
			(SpPanedLayout newHorizontal
				add:
					(SpPanedLayout newHorizontal
						add:
							(SpBoxLayout newVertical
								add: #packagesList;
								yourself);
						add:
							(SpBoxLayout newVertical
								add: #itemsList;
								yourself);
						yourself);
				add:
					(SpBoxLayout newVertical
						add: #resultViewsDropList
							withConstraints: [ :constraints | constraints expand: false ];
						add: #resultLabel
							withConstraints: [ :constraints | constraints height: self labelHeight ];
						add: #resultsList;
						yourself);
				yourself);
		add: #startButton
			withConstraints: [ :constraints | constraints width: self buttonWidth ];
		yourself
]

{ #category : #'world menu' }
DrTests class >> menuCommandOn: aBuilder [
	<worldMenu>
	
	(aBuilder item: #'Dr Test (Preview)')
		parent: #Testing;
		action: [ self open ];
		order: 2;
		"keyText: 'o, u';" "Note: Removed the shortcut to not clash with SUnitRunner keybinding."
		help: '(Preview) Let you run and debug SUnit tests.';
		icon: self taskbarIcon;
		withSeparatorAfter	
]

{ #category : #api }
DrTests class >> open [
	<script>
	
	^ self new
		openWithSpec;
		yourself
]

{ #category : #'tools registry' }
DrTests class >> registerToolsOn: registry [
	"Note: For now, DrTests is only available for preview, thus the following code is commented."
	
	"Add DrTests to registry to replace the old test runner." 
	"registry register: self as: #testRunner"
]

{ #category : #'instance creation' }
DrTests class >> reloadConfiguration: aDTPluginConfiguration withResults: aDTPluginResult andPlugin: aDTPlugin [

	self open
		updateStatus: 'Tests finished.';
		currentPlugin: aDTPlugin;
		testsConfiguration: aDTPluginConfiguration;
		updateWithPluginResult: aDTPluginResult
]

{ #category : #actions }
DrTests >> browseSelectedItem [
	"Because of DTBrowseSelectedItem>>#canBeExecuted, we know there is a single item in the selection.
	 Thus, we take the first one and browse it.
	"
	
	self selectedItems first drTestsBrowse
]

{ #category : #actions }
DrTests >> browseSelectedResult [

	self resultSelected drTestsBrowse
]

{ #category : #utilities }
DrTests >> buildLabelString: nameOfItems numberOfItemsSelected: aInt [
	^ String
		streamContents: [ :s | 
			s
				<< nameOfItems;
				nextPut: $(;
				<< aInt asString;
				<< ' selected):' ]
]

{ #category : #accessing }
DrTests >> currentPlugin: anObject [

	super currentPlugin: anObject.
	pluginResult := nil

]

{ #category : #private }
DrTests >> dateAndTimeString [

	^ DateAndTime now asStringYMDHM
]

{ #category : #'private - initialization' }
DrTests >> initializeButtons [

	super initializeButtons.
	switchButton
		label: 'Minimize';
		disable.
]

{ #category : #'private - initialization' }
DrTests >> initializeItemsListAndLabel [

	itemsList := self newFilterableListPresenter.
	itemsList
		help: 'Select the classes to analyze. Cmd+A or Ctrl+A to select all classes.';
		sortingBlock: #name ascending;
		displayBlock: [ :item | item name ];
		whenSelectionChangedDo: [ self whenItemsSelectionChanged: self selectedItems ];
		beMultipleSelection;
		contextMenu: [ (self rootCommandsGroup / 'List items menu') beRoot asMenuPresenter ].
	packagesList
		whenSelectionChangedDo: [ self whenPackagesSelectionChanged: self packagesSelected ]
]

{ #category : #'private - initialization' }
DrTests >> initializePackagesListAndLabel [

	packagesList := self newFilterableListPresenter.
	packagesList
		help: 'Select the packages to analyze. Cmd+A or Ctrl+A to select all packages.';
		sortingBlock: #name ascending;
		displayBlock: [ :package | package name ];
		beMultipleSelection;
		contextMenu: [ (self rootCommandsGroup / 'Package menu') beRoot asMenuPresenter ]
]

{ #category : #'private - initialization' }
DrTests >> initializePluginsDropList [

	pluginsDropList := self newDropList.
	self pluginsDropList
		help: 'Select the plugin used by Dr Tests UI.';
		items: self plugins;
		display: [ :pluginClass | pluginClass pluginName ];
		iconBlock: [ :pluginClass | pluginClass pluginIcon ];
		whenSelectedItemChangedDo: [ :pluginClass | self currentPlugin: pluginClass new ]
]

{ #category : #initialization }
DrTests >> initializePresenter [

	super initializePresenter.
	self resultViewsDropList
		whenSelectedItemChangedDo: [ :resultTreeViewOrNil | 
			resultTreeViewOrNil
				ifNotNil: [ resultsList
						roots: (resultTreeViewOrNil resultTreeFor: pluginResult) subResults ] ].
	self pluginsDropList selectIndex: 1
]

{ #category : #'private - initialization' }
DrTests >> initializeResultViewsDropList [

	resultViewsDropList := self newDropList.
	self resultViewsDropList
		help: 'Select the different views for results';
		display: [ :resultTreeView | resultTreeView name ]
]

{ #category : #'private - initialization' }
DrTests >> initializeResultsTreeAndLabel [

	resultLabel := self newLabel label: 'Results:'.
	resultsList := self newTreeTable.
	resultsList
		addColumn: (SpStringTableColumn evaluated: #drTestsName);
		children: [ :node | node subResults ];
		contextMenu: [ (self rootCommandsGroup / 'Results tools') beRoot asMenuPresenter ]
]

{ #category : #'private - initialization' }
DrTests >> initializeStatusLabel [

	statusLabel := self newLabel
]

{ #category : #initialization }
DrTests >> initializeWidgets [

	super initializeWidgets.
		
	self
		initializeStatusLabel;
		initializePluginsDropList;
		initializePackagesListAndLabel;
		initializeItemsListAndLabel;
		initializeResultsTreeAndLabel;
		initializeResultViewsDropList
]

{ #category : #initialization }
DrTests >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title:  self title;
		initialExtent: 700 @ 500;
		statusBar: statusLabel
]

{ #category : #'accessing - subwidgets' }
DrTests >> itemsList [

	^ itemsList
]

{ #category : #private }
DrTests >> menuForSelectedResult: menu [

	self resultSelected ifNil: [ ^ self ].
	self resultSelected content drTestsBuildContextMenu: menu
]

{ #category : #widgets }
DrTests >> newFilterableListPresenter [

	^ self instantiate: DTFilterableListPresenter
]

{ #category : #'accessing - subwidgets' }
DrTests >> packagesList [

	^ packagesList
]

{ #category : #private }
DrTests >> packagesSelected [

	^ self packagesList ifNil: [ #(  ) ] ifNotNil: #selectedItems
]

{ #category : #accessing }
DrTests >> plugins [

	^ plugins ifNil: [ DrTestsPlugin availablePlugins ]
]

{ #category : #'accessing - subwidgets' }
DrTests >> pluginsDropList [

	^ pluginsDropList
]

{ #category : #accessing }
DrTests >> resultSelected [

	^ self resultsList selectedItem
]

{ #category : #api }
DrTests >> resultTree: aResultGroup [

	aResultGroup
		ifNotNil: [ self resultsList roots: aResultGroup subResults ]
]

{ #category : #'accessing - subwidgets' }
DrTests >> resultViewsDropList [

	^ resultViewsDropList
]

{ #category : #'accessing - subwidgets' }
DrTests >> resultsList [
	^ resultsList
]

{ #category : #api }
DrTests >> selectAllInPackageList [

	packagesList selectAll
]

{ #category : #api }
DrTests >> selectNoneInPackageList [

	packagesList unselectAll
]

{ #category : #accessing }
DrTests >> selectedItems [

	^ self itemsList selectedItems
]

{ #category : #'accessing model' }
DrTests >> setModelBeforeInitialization: aDomainObject [

	plugins := aDomainObject
]

{ #category : #'accessing - subwidgets' }
DrTests >> statusLabel [

	^ statusLabel
]

{ #category : #'api - locking' }
DrTests >> subwidgetsToLock [

	^ { self packagesList. self itemsList. self resultsList. self startButton }
]

{ #category : #'private - actions' }
DrTests >> switchToMiniDrTest [

	(MiniDrTests new
		testsConfiguration: self testsConfiguration;
		currentPlugin: self currentPlugin;
		updateWithPluginResult:self pluginResult ;
		yourself) openWithSpec
]

{ #category : #actions }
DrTests >> switchUI [

	super switchUI.
	self switchToMiniDrTest
]

{ #category : #accessing }
DrTests >> testsConfiguration [

	testsConfiguration := self currentPlugin buildConfigurationFrom: self.
	^ testsConfiguration
]

{ #category : #accessing }
DrTests >> testsConfiguration: aDTTestsConfiguration [

	self packagesList selectItems: aDTTestsConfiguration packagesSelected.
	self itemsList selectItems: aDTTestsConfiguration items
]

{ #category : #accessing }
DrTests >> title [

	^ 'Dr Tests - ' , currentPlugin pluginName
]

{ #category : #'private - updating' }
DrTests >> updateItemsListLabel [

	self itemsList
		label:
			(self
				buildLabelString: self currentPlugin secondListLabel
				numberOfItemsSelected: self selectedItems size)
]

{ #category : #'private - updating' }
DrTests >> updatePackagesList [
	packagesList unselectAll.
	itemsList beEmpty.
	packagesList items: currentPlugin packagesAvailableForAnalysis.
	packagesList label: currentPlugin firstListLabel.
	itemsList label: currentPlugin secondListLabel.
	currentPlugin setSelectionModeOfPackageList: packagesList.
	currentPlugin setSelectionModeOfItemsList: itemsList
]

{ #category : #'private - updating' }
DrTests >> updatePackagesListLabel [
	self packagesList
		label:
			(self
				buildLabelString: self currentPlugin firstListLabel
				numberOfItemsSelected: self packagesSelected size)
]

{ #category : #updating }
DrTests >> updateResultLabel [
	resultLabel
		label: 'Results: ■';
		color: pluginResult backgroundColor
]

{ #category : #updating }
DrTests >> updateResultViewsDropList [
	| newPragmas |
	newPragmas := self currentPlugin resultTreeViews.
	(self resultViewsDropList listItems = newPragmas
		and: [ newPragmas isNotEmpty ])
		ifTrue: [ self resultViewsDropList
				selectedIndex: self resultViewsDropList selectedIndex.	"Trigger action attached to selection change."
			^ self ].
	self resultViewsDropList selectedItem
		ifNotNil: [ self resultViewsDropList resetSelection ].
	self resultViewsDropList items: newPragmas.
	newPragmas isNotEmpty
		ifTrue: [ self resultViewsDropList selectIndex: 1 ]
]

{ #category : #updating }
DrTests >> updateStatus: aString [
	self statusLabel
		label: ('{1}: {2}' format: { self dateAndTimeString . aString }).

]

{ #category : #updating }
DrTests >> updateSwitchButton: itemsSelected [
	currentPlugin allowMiniDrTests
		ifTrue: [ switchButton enabled: itemsSelected isNotEmpty ]
		ifFalse: switchButton disable
]

{ #category : #updating }
DrTests >> updateUI [
	super updateUI.
	self packagesList resetFilter.
	self updatePackagesList.
	self resultTree: DTTreeNode empty.
	self packagesList resetFilter.
	self itemsList resetFilter.
	self updateResultViewsDropList
]

{ #category : #updating }
DrTests >> updateWithPluginResult: aPluginResult [

	aPluginResult ifNotNil: [ self updateWithResults: aPluginResult ]
]

{ #category : #updating }
DrTests >> updateWithResults: results [
	pluginResult := results.
	self resultTree: pluginResult buildTreeForUI.
	self updateResultViewsDropList.
	self updateResultLabel.
	resultsList
		contextMenu: [ (self rootCommandsGroup / 'Results tools') beRoot asMenuPresenter ]
]

{ #category : #private }
DrTests >> whenItemsSelectionChanged: itemsSelected [
	
	self
		updateItemsListLabel;
		updateSwitchButton: itemsSelected
]

{ #category : #private }
DrTests >> whenPackagesSelectionChanged: packagesSelected [

	itemsList
		items: (currentPlugin itemsToBeAnalysedFor: packagesSelected);
		selectAll.
	self updatePackagesListLabel
]
