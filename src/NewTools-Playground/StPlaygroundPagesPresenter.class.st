"
I am a presenter to show saved pages from a playground. 
A playground saves (or tries to save) everything you will put in a playground and it will store in the playground cache to make it available later (or even outside the image).

I show a list and a preview of a page content, to allow users to chose a page to load.
"
Class {
	#name : #StPlaygroundPagesPresenter,
	#superclass : #StPresenter,
	#instVars : [
		'parent',
		'pageList',
		'pagePreview',
		'pageListPanel',
		'pagePreviewPanel'
	],
	#category : #'NewTools-Playground-View'
}

{ #category : #accessing }
StPlaygroundPagesPresenter class >> defaultExtent [

	^ 700@400
]

{ #category : #specs }
StPlaygroundPagesPresenter class >> defaultSpec [

	^ SpPanedLayout newHorizontal
		position: 30 percent;
		add: #pageListPanel;
		add: #pagePreviewPanel;
		yourself
]

{ #category : #accessing }
StPlaygroundPagesPresenter class >> defaultTitle [

	^ 'Pages'
]

{ #category : #accessing }
StPlaygroundPagesPresenter class >> emptyMessage [

	^ 'There are no pages to list.'
]

{ #category : #accessing }
StPlaygroundPagesPresenter class >> pages [

	
]

{ #category : #accessing }
StPlaygroundPagesPresenter class >> unselectedMessage [

	^ 'Select a page to preview it.'
]

{ #category : #actions }
StPlaygroundPagesPresenter >> doLoadPage [
	
	self loadSelectedPage
]

{ #category : #actions }
StPlaygroundPagesPresenter >> doLoadPageOnNewPlayground [
	| playground |
	
	(playground := StPlayground new) 
		loadPage: self selectedPage;
		openWithSpec.
	self window close.
	playground takeKeyboardFocus 		
]

{ #category : #initialization }
StPlaygroundPagesPresenter >> initializeDialogWindow: aDialogWindowPresenter [

	aDialogWindowPresenter 
		centeredRelativeToTopWindow;
		addButton: 'Close' do: [ :presenter |
			presenter triggerOkAction.
			presenter close ]
]

{ #category : #initialization }
StPlaygroundPagesPresenter >> initializePresenters [

	(pageListPanel := self instantiate: StHeaderPanel)		
		number: 1;
		label: 'Pages';
		presenter: (pageList := self newComponentList
			presenters: self pagesAsPresenters;
			contextMenu: [ self pagesActions asMenuPresenter ];
			whenActivatedDo: [ self loadSelectedPage ];
			bindKeyCombination: Character cr asKeyCombination toAction: [ self loadSelectedPage ];
			yourself).
		
	(pagePreviewPanel := self instantiate: StHeaderPanel)
		number: 2;
		label: 'Preview';
		presenter: (pagePreview := self newPresenterSelector
			when: [ :aPage | aPage notNil ] show: [ :aPage | 
				self newCode 
					editable: false;
					text: aPage contents ];
			when: [ :aPage | aPage isNil ] show: [ 
				pageList items
					ifNotEmpty: [ self class unselectedMessage asPresenter ]
					ifEmpty: [ self class emptyMessage asPresenter ] ];
			yourself).
	
	pageList transmitTo: pagePreview.
	
	pageList items 
		ifNotEmpty: [ pageList selectIndex: 1 ]
		ifEmpty: [ pagePreview updatePresenter ]
]

{ #category : #initialization }
StPlaygroundPagesPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter 
		title: self class defaultTitle;
		initialExtent: self class defaultExtent;
		whenOpenedDo: [ pageList takeKeyboardFocus ]
]

{ #category : #actions }
StPlaygroundPagesPresenter >> loadPage: aPage [

	parent loadPage: aPage.
	self window close.
	parent takeKeyboardFocus 
]

{ #category : #actions }
StPlaygroundPagesPresenter >> loadSelectedPage [

	self loadPage: self selectedPage
]

{ #category : #accessing }
StPlaygroundPagesPresenter >> pages [
	
	^ (StPlayground cacheDirectory allChildrenMatching: '*.ph')
		sorted: [ :a :b | a creationTime > b creationTime ]
]

{ #category : #private }
StPlaygroundPagesPresenter >> pagesActions [

	^ CmCommandGroup forSpec
		beRoot;
		register: (StPlaygroundLoadPageCommand forSpecContext: self);
		register: (StPlaygroundLoadPageOnNewPlaygroundCommand forSpecContext: self);
		yourself
]

{ #category : #initialization }
StPlaygroundPagesPresenter >> pagesAsPresenters [

	^ self pages collect: [ :each | 
		self 
			instantiate: StPlaygroundPageSummaryPresenter
			on: each  ]
]

{ #category : #accessing }
StPlaygroundPagesPresenter >> selectedPage [

	^ pageList selection selectedItem page
]

{ #category : #'accessing model' }
StPlaygroundPagesPresenter >> setModelBeforeInitialization: aPlayground [

	parent := aPlayground
]
