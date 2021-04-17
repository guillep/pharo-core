"
A DAPackageAnalyzerWindow class is an abstract class.
It represents the UI merging the SpecTreeModel (package dependencies or cycles) and browser.

The main feature is to browse automatically in the browser when you click on a node (package or dependency).

"
Class {
	#name : #DAPackageAnalyzerWindow,
	#superclass : #StandardWindow,
	#instVars : [
		'packageAnalyzerTreeModel',
		'browser'
	],
	#category : #'Tool-DependencyAnalyser-UI-Core'
}

{ #category : #testing }
DAPackageAnalyzerWindow class >> isAbstract [

	^ self == DAPackageAnalyzerWindow
]

{ #category : #'instance creation' }
DAPackageAnalyzerWindow class >> onPackagesNamed: aCollection [
	^ self new 
		initializeWithPackageNames: aCollection;
		yourself
]

{ #category : #accesing }
DAPackageAnalyzerWindow class >> selectedPackagesFrom: aBuilder [
	| target selectedPackages |
	target := aBuilder model.
	selectedPackages := target selectedPackages collect: [ :rpackage | rpackage packageName asString ].
	^ selectedPackages
]

{ #category : #examples }
DAPackageAnalyzerWindow class >> systemPackages [
	^ RPackageOrganizer default packages collect: [ :package | package packageName asString ]
]

{ #category : #adding }
DAPackageAnalyzerWindow >> addAllMorph [
	| browserWindow  windowTreeModel |
	browserWindow := self buildBrowserWindow.	
	windowTreeModel := self buildMorphWindowForTreeModel.
	self
		addMorph: browserWindow frame: (0.4 @ 0 corner: 1 @ 1);
		addMorph:  (self panelMorphFrom: windowTreeModel) frame: (0 @ 0 corner: 0.4 @ 1).
]

{ #category : #building }
DAPackageAnalyzerWindow >> buildBrowserWindow [

	^browser buildWindow
]

{ #category : #building }
DAPackageAnalyzerWindow >> buildMorphWindowForTreeModel [
	| specWindow |
	packageAnalyzerTreeModel
		open;
		delete.
	
	specWindow := self specWindowFrom: packageAnalyzerTreeModel.
	^ specWindow
]

{ #category : #'initialization-filter' }
DAPackageAnalyzerWindow >> buildandAddAllMorph [
	browser := packageAnalyzerTreeModel browser.
	self addAllMorph
]

{ #category : #'morphic ui' }
DAPackageAnalyzerWindow >> defaultLabel [
	^ 'Package Dependencies Analysis'
]

{ #category : #'open/close' }
DAPackageAnalyzerWindow >> delete [
	self packageAnalyzerTreeModel close.
	^ super delete
]

{ #category : #'morphic ui' }
DAPackageAnalyzerWindow >> initialExtent [
	^ (1500@800)
]

{ #category : #accessing }
DAPackageAnalyzerWindow >> open [
	^ self openInWorld.
	
]

{ #category : #accessing }
DAPackageAnalyzerWindow >> packageAnalyzerTreeModel [
	^ packageAnalyzerTreeModel
]

{ #category : #adding }
DAPackageAnalyzerWindow >> panelMorphFrom: aSpecWindow [
	aSpecWindow submorphs
		do: [ :submorph | 
			(submorph isKindOf: PanelMorph)
				ifTrue: [ ^ submorph ] ].
	^ nil
]

{ #category : #building }
DAPackageAnalyzerWindow >> specWindowFrom: aSpec [
	| windowPresenter specWindow |
	windowPresenter := aSpec window.
	specWindow := windowPresenter window.
	^ specWindow
]
