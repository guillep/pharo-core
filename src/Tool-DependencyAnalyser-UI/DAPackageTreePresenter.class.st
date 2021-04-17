"
A DAPackageTreeModel is an abstract class. It's a the superclass of the two tree model vizualisations (package dependency and cycle detection).
"
Class {
	#name : #DAPackageTreePresenter,
	#superclass : #ComposablePresenter,
	#instVars : [
		'tree',
		'buttonRefresh',
		'open',
		'browser'
	],
	#category : #'Tool-DependencyAnalyser-UI-Core'
}

{ #category : #testing }
DAPackageTreePresenter class >> isAbstract [

	^self == DAPackageTreePresenter
]

{ #category : #private }
DAPackageTreePresenter >> actionOnRefresh [
	buttonRefresh action: [ self refresh ]
]

{ #category : #actions }
DAPackageTreePresenter >> addDependenciesOptionsFor: selectedNodes on: menuGroup [
	| namesOfSelected |
	(self areClassToDependencyNodes: selectedNodes)
		ifTrue: [ 
			namesOfSelected := selectedNodes collect: [ :package | package content theClass ].
			menuGroup
				addMenuItem:
					(MenuItemPresenter new
						name: 'Browse dependencies from class';
						action: [ self openTreeFor: namesOfSelected ]) ]
]

{ #category : #actions }
DAPackageTreePresenter >> addPackageOptionsFor: selectedNodes on: menuGroup [
	| selectedPackageNames |
	(self arePackageNodes: selectedNodes)
		ifTrue: [ 
			selectedPackageNames := selectedNodes collect: [ :packageNode | packageNode packageName ].
			menuGroup
				addMenuItem:
					(MenuItemPresenter new
						name: 'Browse scoped dependencies';
						action: [ (DAPackageAnalyzerPackageDependenciesWindow onPackagesNamed: selectedPackageNames) open ]).
			selectedNodes size > 1
				ifTrue: [ 
					menuGroup
						addMenuItem:
							(MenuItemPresenter new
								name: 'Find cycles among packages';
								action: [ (DAPackageAnalyzerCycleDetectionWindow onPackagesNamed: selectedPackageNames) open ]) ] ]
]

{ #category : #testing }
DAPackageTreePresenter >> areClassToDependencyNodes: aCollectionOfItem [
	^ aCollectionOfItem allSatisfy: [ :node |  node isClassToDependencyNode ].
]

{ #category : #testing }
DAPackageTreePresenter >> arePackageNodes: aCollectionOfItem [
	^ aCollectionOfItem allSatisfy: [ :node |  node isPackageNode ].
]

{ #category : #initialization }
DAPackageTreePresenter >> browseReference [
	self selectedItemFromTree isReferenceNode ifTrue: [ 
			self selectedItemFromTree browseReference
		 ]
]

{ #category : #accessing }
DAPackageTreePresenter >> browser [
	^ browser
]

{ #category : #private }
DAPackageTreePresenter >> buildRoots [
	self subclassResponsibility.
]

{ #category : #accessing }
DAPackageTreePresenter >> buttonRefresh [
	^ buttonRefresh
]

{ #category : #actions }
DAPackageTreePresenter >> close [
	open := false.
	browser windowIsClosing
]

{ #category : #protocol }
DAPackageTreePresenter >> defaultFormat [
	^ #png
]

{ #category : #testing }
DAPackageTreePresenter >> ifGraphVizAbsent: aBlock [
	Smalltalk at: #GVGraphViz ifAbsent: aBlock
]

{ #category : #initialization }
DAPackageTreePresenter >> initializePresenter [
	self actionOnRefresh
]

{ #category : #initialization }
DAPackageTreePresenter >> initializeWidgets [
	tree := self newTree
		multiSelection: true;
		bindKeyCombination: $b meta toAction: [ self selectedItemFromTree spawnNewBrowser ];
		columns: {(TreeColumnPresenter new displayBlock: [ :node | node label ])};
		yourself.
	buttonRefresh := self newButton
		icon: (self iconNamed: #refreshIcon);
		help: 'Refresh the TreePresenter';
		label: 'Refresh';
		yourself.
	browser := Smalltalk tools browser onDefaultEnvironment
]

{ #category : #testing }
DAPackageTreePresenter >> isOpen [
	^ open
]

{ #category : #actions }
DAPackageTreePresenter >> loadMenuFor: item in: aMenu [
	| menuGroup selectedNodes |
	selectedNodes := self selectedItemsFromTree.
	menuGroup := MenuGroupPresenter new.
	self addPackageOptionsFor: selectedNodes on: menuGroup.
	self addDependenciesOptionsFor: selectedNodes asSet on: menuGroup.
	(selectedNodes size = 1)
		ifTrue: [ selectedNodes first addMenuEntriesOn: menuGroup ].
	
	aMenu addMenuGroup: menuGroup.
	^ aMenu
]

{ #category : #'instance creation' }
DAPackageTreePresenter >> open [
	open := true.
	^ self openWithSpec 
]

{ #category : #actions }
DAPackageTreePresenter >> openTreeFor: namesOfSelected [
	| treeToOpen relationGraph |
	treeToOpen := TreePresenter new.
	relationGraph := self tree owner relationGraph.
	^ treeToOpen
		roots: namesOfSelected;
		whenBuiltDo: [ 
					treeToOpen
						rootNodeHolder: [ :item | 
							DAClassToDependencyNode new
								content: item;
								package: (relationGraph pdPackageFrom: item) ] ];
		title: 'Class dependencies';
		extent: 700 @ 500;
		openWithSpec
]

{ #category : #actions }
DAPackageTreePresenter >> refresh [
	self subclassResponsibility 
]

{ #category : #protocol }
DAPackageTreePresenter >> saveGraphAndOpenWith: graphvizGenerator [
	graphvizGenerator saveDotFileAndGenerateForType: self defaultFormat.
	^ graphvizGenerator openWith: self defaultFormat
]

{ #category : #actions }
DAPackageTreePresenter >> selectedItemFromTree [
	^ self tree selectedItem
]

{ #category : #accessing }
DAPackageTreePresenter >> selectedItemsFromTree [
	^ self tree selectedItems
]

{ #category : #accessing }
DAPackageTreePresenter >> tree [
	^ tree
]
