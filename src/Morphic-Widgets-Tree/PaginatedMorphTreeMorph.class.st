"
A paginated tree morph
"
Class {
	#name : #PaginatedMorphTreeMorph,
	#superclass : #MorphTreeMorph,
	#instVars : [
		'pager'
	],
	#category : #'Morphic-Widgets-Tree-Pagination'
}

{ #category : #'pager managing' }
PaginatedMorphTreeMorph >> addNavigationPane: aNavigPane [
	pager := aNavigPane.
	self addMorph: pager.
	pager buildPanel.
	self updatePager.
	self changed
]

{ #category : #'accessing - colors' }
PaginatedMorphTreeMorph >> adoptPaneColor: paneColor [
	"Pass on to the selection, the border and on the eventual pager too."
	
	super adoptPaneColor: paneColor.
	paneColor ifNil: [^self].
	self pager ifNotNil: [:p | p color: self pagerColor]
]

{ #category : #updating }
PaginatedMorphTreeMorph >> buildContents [
	super buildContents.
	self updatePager
]

{ #category : #'pager managing' }
PaginatedMorphTreeMorph >> chunkSize: aPageSize [ 
	self pager
		ifNil: [aPageSize ifNotNil: [self addNavigationPane: (TreeChunkPagerMorph on: self pageSize: aPageSize)]]
		ifNotNil: [aPageSize 
			ifNil: [self removePager]
			ifNotNil: [self pager changePageSize: aPageSize]]
]

{ #category : #accessing }
PaginatedMorphTreeMorph >> currentNodelist [
	"The nodeList currently viewed (not the full node list if a pager is used)"
	^ self pager
		ifNil: [super nodeList]
		ifNotNil: [self pager currentNodelist]
]

{ #category : #'expanding-collapsing' }
PaginatedMorphTreeMorph >> expandItemPath: anItemPath [
	| rest |
	rest := anItemPath asOrderedCollection.
	[ rest notEmpty ]
		whileTrue: [ 
			| res |
			res := (1 to: self nodeList size) select: [ :li | (self nodeList at: li) item = rest first ].
			res isEmpty
				ifTrue: [ ^ self ].
			self pager nextPage: res first.
			(self allNodeMorphs at: 1 ifAbsent: [ ^ self ]) openItemPath: {(rest first)}.
			rest := rest copyWithoutFirst ].
	^ self
]

{ #category : #geometry }
PaginatedMorphTreeMorph >> extent: newExtent [
	self extent = newExtent ifTrue: [^ self].
	super extent: newExtent.
	self updatePager.

]

{ #category : #geometry }
PaginatedMorphTreeMorph >> hResizeScrollBar [
	super hResizeScrollBar.
	hScrollBar bounds: ((hScrollBar bounds withTop: (hScrollBar top - self pagerHeight)) withBottom: (hScrollBar bottom - self pagerHeight))
]

{ #category : #geometry }
PaginatedMorphTreeMorph >> innerBounds [
	| inner |
	inner := super innerBounds.
	inner := inner withBottom: inner bottom - self pagerHeight.
	^ inner
]

{ #category : #'pager managing' }
PaginatedMorphTreeMorph >> pageSize: aPageSize [ 
	self pager
		ifNil: [aPageSize ifNotNil: [self addNavigationPane: (TreePagerMorph on: self pageSize: aPageSize)]]
		ifNotNil: [aPageSize 
			ifNil: [self removePager]
			ifNotNil: [self pager changePageSize: aPageSize]]
]

{ #category : #'pager managing' }
PaginatedMorphTreeMorph >> pager [
	^ pager
	
]

{ #category : #'pager managing' }
PaginatedMorphTreeMorph >> pagerColor [
	^ self color darker alpha: 0.6
]

{ #category : #'pager managing' }
PaginatedMorphTreeMorph >> pagerHeight [
	^ self pager
		ifNil: [0]
		ifNotNil: [pager computedHeight]
]

{ #category : #'pager managing' }
PaginatedMorphTreeMorph >> removePager [
	self pager ifNotNil: [
		self removeMorph: self pager.
		pager := nil.
		self updateList.
		self resizerChanged].

]

{ #category : #updating }
PaginatedMorphTreeMorph >> updateContentsWithPreviouslyExpanded: aNodeList [
	super updateContentsWithPreviouslyExpanded: aNodeList.
	self updatePager
]

{ #category : #'pager managing' }
PaginatedMorphTreeMorph >> updatePager [
	self pager
		ifNotNil: [self pager buildPanel]
]

{ #category : #geometry }
PaginatedMorphTreeMorph >> vScrollBarHeight [
	^ super vScrollBarHeight - self pagerHeight
]

{ #category : #scrolling }
PaginatedMorphTreeMorph >> vScrollBarValue: scrollValue [
	super vScrollBarValue: scrollValue.
	self pager ifNotNil: [:p | p vScrollBarValue: scrollValue]
]
