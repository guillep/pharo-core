"
My subclasses represent the navigation context of the browser, the browser state. They describe the concrete type of selected items together with items itself.

My tool is always the browser. And I provide the #browser method to use this fact explicitly.

I provide default implementations of how to work with selected items in the Calypso browser model:
- selectedItems, returns the actually selected items.
- selectedObjects , returns the actual object of selected items.
- lastSelectedItem
- lastSelectedObject
- lastSelectedObjectIn: items, encapsulates the knowledge of what is the last item in the selection.
- firstSelectedObjectIn: items
- hasSelecteditems

Users can retrieve actual system which browser navigate:
	context system

There are several operation with browser which can be performed using me:
- updateBrowser, it will force the browser to perform full update of navigation data sources
- restoreBrowserState, it should be implemented by subclasses whey they should recover browser state which is described by context instance
"
Class {
	#name : #ClyBrowserContext,
	#superclass : #CmdToolContext,
	#instVars : [
		'selectedItems'
	],
	#category : #'Calypso-Browser-Contexts'
}

{ #category : #'instance creation' }
ClyBrowserContext class >> of: selectedItems for: aBrowser [
	^(self for: aBrowser)
		selectedItems: selectedItems
]

{ #category : #'instance creation' }
ClyBrowserContext class >> ofSelection: aSelection for: aBrowser [
	^self of: aSelection detachedItems for: aBrowser
]

{ #category : #accessing }
ClyBrowserContext >> activeQueryView [

	^self browser navigationViews detect: [ :each |
		each createSelectionContext class = self class ]
]

{ #category : #helpers }
ClyBrowserContext >> actualSelectionFrom: browserItemCollection [
	^browserItemCollection collect: [ :each | each actualObject ]
]

{ #category : #'drag and drop' }
ClyBrowserContext >> asDraggableMorph [
	^(String streamContents: [ :s| 
		selectedItems 
			do: [ :each | s nextPutAll: each name ]
			separatedBy: [ s space ]]) asStringMorph
]

{ #category : #accessing }
ClyBrowserContext >> browser [
	^tool
]

{ #category : #copying }
ClyBrowserContext >> copyForBrowserStateSnapshot [

	^self copy 
		initializeForBrowserStateSnapshot;
		yourself
]

{ #category : #'accessing context' }
ClyBrowserContext >> currentMetaLevelOf: aClass [
	"we do not model class side vs instance side"
	^aClass
]

{ #category : #helpers }
ClyBrowserContext >> firstSelectedObjectIn: selectedObjects [
	^selectedObjects last
]

{ #category : #testing }
ClyBrowserContext >> hasSelectedItems [
	^selectedItems notEmpty
]

{ #category : #initialization }
ClyBrowserContext >> initialize [
	super initialize.
	selectedItems := #()
]

{ #category : #copying }
ClyBrowserContext >> initializeForBrowserStateSnapshot [

	selectedItems := selectedItems collect: [ :each | each copyForBrowserStateSnapshot ].
	selectedItems do: [ :each | each ownerDataSource parentItem: nil ].
	tool := nil
]

{ #category : #testing }
ClyBrowserContext >> isAboutBrowserItemType: itemTypeClass [

	^selectedItems anySatisfy: [ :each | 
		each type isCalypsoItemType: itemTypeClass ]
]

{ #category : #testing }
ClyBrowserContext >> isAboutSelectedItem: aDataSourceItem [
	"It can be just last line: #isEqualTo:. 
	But in remote scenario it could lead to few messages to underlying remote objects. 
	It is nice to avoid such interaction.
	So here we first try simplified comparison. And then complete version is used"
	(selectedItems anySatisfy: [ :each | each actualObject == aDataSourceItem actualObject])
		ifTrue: [ ^true ].
	(selectedItems anySatisfy: [ :each | each name = aDataSourceItem name]) 
		ifFalse: [ ^false ].
	^selectedItems anySatisfy: [ :each | each isEqualTo: aDataSourceItem  ]
]

{ #category : #testing }
ClyBrowserContext >> isSimilarTo: anotherBrowserContext [
	self class = anotherBrowserContext class ifFalse: [ ^false ].
	
	(selectedItems size = anotherBrowserContext selectedItems size)
		ifFalse: [ ^false ].
		
	^selectedItems allSatisfy: [ :each |
		anotherBrowserContext isAboutSelectedItem: each]
]

{ #category : #helpers }
ClyBrowserContext >> lastSelectedItem [
	^selectedItems first
]

{ #category : #helpers }
ClyBrowserContext >> lastSelectedObject [
	^self lastSelectedItem actualObject
]

{ #category : #helpers }
ClyBrowserContext >> lastSelectedObjectIn: selectedObjects [
	^selectedObjects first
	
]

{ #category : #accessing }
ClyBrowserContext >> navigationEnvironment [
	^self browser navigationEnvironment
]

{ #category : #'browser state' }
ClyBrowserContext >> restoreBrowserState [
	self subclassResponsibility 
]

{ #category : #accessing }
ClyBrowserContext >> selectedItems [
	^ selectedItems
]

{ #category : #accessing }
ClyBrowserContext >> selectedItems: anObject [
	selectedItems := anObject
]

{ #category : #helpers }
ClyBrowserContext >> selectedObjects [
	^self actualSelectionFrom: selectedItems
]

{ #category : #accessing }
ClyBrowserContext >> system [
	^tool system
]

{ #category : #'browser state' }
ClyBrowserContext >> updateBrowser [
	self browser update
]
