"
I a a search dialog to select one or multiples items from the queries objects.
I am created by browser and users should call me using following methods: 

	browser searchDialog 
		requestSingleObject: 'Choose package' from: ClyAllPackages sorted.

	browser searchDialog 
		requestMultipleObjects: 'Choose classes' from: ClyAllClasses sorted

I always force semi async execution of given query.

In case when query result include just a couple of items I hide default view filters.

To select items in the list users can use #enter key. To close dialog they can use #esc. 

By default filter is focused. And as soon as dialog openes user can type filter.
If after filter there is only item in the list I will choose it when user submit the dialog.
If there are multiple items I try to find the item with exact same name as filter text.

Internal Representation and Key Implementation Points.

    Instance Variables
	browser:		<ClyBrowser>
	itemsView:		<ClyQueryView>
"
Class {
	#name : #ClyBrowserSearchDialogWindow,
	#superclass : #DialogWindowMorph,
	#instVars : [
		'browser',
		'itemsView'
	],
	#category : #'Calypso-Browser-UI'
}

{ #category : #'instance creation' }
ClyBrowserSearchDialogWindow class >> for: aBrowser [
	^self new 
		browser: aBrowser
]

{ #category : #accessing }
ClyBrowserSearchDialogWindow >> browser [
	^ browser
]

{ #category : #accessing }
ClyBrowserSearchDialogWindow >> browser: anObject [
	browser := anObject
]

{ #category : #controlling }
ClyBrowserSearchDialogWindow >> changeStateBy: aBlock [
	aBlock value
]

{ #category : #controlling }
ClyBrowserSearchDialogWindow >> changeStateOf: aQueryView by: aBlock [
	aBlock value
]

{ #category : #'events handling' }
ClyBrowserSearchDialogWindow >> defaultFocusMorph [

	^itemsView filterField ifNil: [ itemsView dataSource table ]
]

{ #category : #private }
ClyBrowserSearchDialogWindow >> findObjectsSameAsFilter [
	itemsView dataSource numberOfRows = 1 ifTrue: [ 
		"single element means that it was found by filter and we can use it without extra search"
		^ itemsView dataSource allElements collect: [:each | each actualObject] ].
	^ itemsView findItemsSameAsFilter
		ifNotEmpty: [ :foundItems | foundItems collect: [:each | each actualObject] ]
]

{ #category : #controlling }
ClyBrowserSearchDialogWindow >> ignoreNavigationDuring: aBlock [
	aBlock value
]

{ #category : #controlling }
ClyBrowserSearchDialogWindow >> itemsChanged [
]

{ #category : #initialization }
ClyBrowserSearchDialogWindow >> newContentMorph [
	itemsView := ClyQueryViewMorph for: self.
	itemsView width: 250.
		
	itemsView whenDoubleClickDo: [:ann | self ok ].
	itemsView whenEnterKeyPressedDo: [:ann | self ok ].
	itemsView whenEscapeKeyPressedDo: [:ann | self cancel ].
	^itemsView
]

{ #category : #private }
ClyBrowserSearchDialogWindow >> openOn: aQuery selecting: items withTitle: dialogTitle thenDo: resultActionBlock [

	self showItemsOf: aQuery.
	self title: dialogTitle.
	itemsView selection selectItems: (itemsView findItemsWith: items).

	browser window openModal: self.

	^["Following two lines should prevent special condition 
	when filter background process modifies current table data source.
	During this process it first closes existing data source 
	and only after that it sets up new filtered data source"
	itemsView table cleanupFilter. "it ensures that filter process will not affect table anymore" 
	itemsView dataSource isClosed ifTrue: [  
		"This branch is consiquence of corner case when filter logic closes current data source 
		but does not yet set up new filtered data source.
		In that case any query of items from closed data source will fail.
		And to avoid it we simply abort search request"
		CmdCommandAborted signal ].
	
	self cancelled ifTrue: [ CmdCommandAborted signal ].
	resultActionBlock value]	
		ensure: [ itemsView closeDataSource]
]

{ #category : #private }
ClyBrowserSearchDialogWindow >> openOn: aQuery withTitle: dialogTitle thenDo: resultActionBlock [

	^ self openOn: aQuery selecting: #() withTitle: dialogTitle thenDo: resultActionBlock
]

{ #category : #requests }
ClyBrowserSearchDialogWindow >> requestMultipleObjects: dialogTitle from: aQuery [
	
	^ self requestMultipleObjects: dialogTitle from: aQuery selecting: #()
]

{ #category : #requests }
ClyBrowserSearchDialogWindow >> requestMultipleObjects: dialogTitle from: aQuery inScope: aScope [

	aScope bindTo: browser navigationEnvironment.
	
	^self requestMultipleObjects: dialogTitle from: (aScope adoptQuery: aQuery)
]

{ #category : #requests }
ClyBrowserSearchDialogWindow >> requestMultipleObjects: dialogTitle from: aQuery selecting: items [
	
	self 
		openOn: aQuery 
		selecting: items
		withTitle: dialogTitle
		thenDo: [ 
			itemsView selection isEmpty ifTrue: [ ^self findObjectsSameAsFilter ].
			^itemsView selection actualObjects]
]

{ #category : #requests }
ClyBrowserSearchDialogWindow >> requestSingleObject: dialogTitle from: aQuery [
	
	self 
		openOn: aQuery
		withTitle: dialogTitle
		thenDo: [ 
			itemsView selection isEmpty ifTrue: [ 
				^self findObjectsSameAsFilter 
					ifEmpty: [ CmdCommandAborted signal ]
					ifNotEmpty: [ :items | items first]].
	
			^itemsView selection lastSelectedItem actualObject]
]

{ #category : #requests }
ClyBrowserSearchDialogWindow >> requestSingleObject: dialogTitle from: aQuery inScope: aScope [
	
	aScope bindTo: browser navigationEnvironment.

	^self requestSingleObject: dialogTitle from: (aScope adoptQuery: aQuery)
]

{ #category : #private }
ClyBrowserSearchDialogWindow >> showItemsOf: aQuery [

	| actualQuery |
	actualQuery := aQuery isBoundToEnvironment
		ifTrue: [ aQuery ]
		ifFalse: [ aQuery withScope: browser systemScope ]..
	
	itemsView showQuery: actualQuery semiAsync.
	itemsView adoptForDialog
]
