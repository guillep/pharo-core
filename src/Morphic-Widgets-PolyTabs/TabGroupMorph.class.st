"
Organises a set of pages sharing the same space and selected through the use of tabs along the top.
"
Class {
	#name : #TabGroupMorph,
	#superclass : #ModelMorphic,
	#instVars : [
		'tabSelectorMorph',
		'contentMorph',
		'pageMorphs'
	],
	#category : #'Morphic-Widgets-PolyTabs'
}

{ #category : #examples }
TabGroupMorph class >> example [
	| builder window page1 page2 label1 label2 tabs content okButton cancelButton |
	builder := self theme builder.
	okButton := builder newOKButton.
	cancelButton := builder newCancelButton.
	page1 := (builder
		newStack:
		{((builder
		newAlphaImage: (self iconNamed: #warningIcon)
		help: nil) alpha: 0.5).
	(CircleMorph new
		hResizing: #spaceFill;
		vResizing: #spaceFill)})
		fillStyle: Color red;
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	page2 := builder newPanel
		fillStyle: Color green;
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	label1 := builder
		newRow:
			{(builder newButtonLabel: 'First page').
			(builder
				newCloseControlFor: nil
				action: [ tabs removePage: page1 ]
				help: 'Close this tab')}.
	label2 := builder
		newRow:
			{(builder newButtonLabel: 'Second page').
			(builder
				newCloseControlFor: nil
				action: [ tabs removePage: page2 ]
				help: 'Close this tab')}.
	label1 cellInset: 0.
	label2 cellInset: 0.
	tabs := builder
		newTabGroup:
			{(label1 -> page1).
			(label2 -> page2)}.
	content := builder
		newColumn:
			{tabs.
			((builder
				newRow:
					{okButton.
					cancelButton}) listCentering: #bottomRight)}.
	window := content
		extent: 250 @ 300;
		openInWindow.
	okButton
		model: window;
		action: #delete.
	cancelButton
		model: window;
		action: #delete
]

{ #category : #adding }
TabGroupMorph >> addPage: aMorph label: aStringOrMorph [
	"Add a page and its tab."

	aMorph
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	self pages add: aMorph.
	self tabSelectorMorph addTab: aStringOrMorph
]

{ #category : #adding }
TabGroupMorph >> addPage: aMorph label: aStringOrMorph selected: selectedStringOrMorph [
	"Add a page and its tab with alternate label when selected."

	aMorph
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	self pages add: aMorph.
	self tabSelectorMorph addTab: aStringOrMorph selected: selectedStringOrMorph
]

{ #category : #accessing }
TabGroupMorph >> adoptPaneColor: paneColor [
	"Pass on to the content morph a little lighter."
	
	paneColor ifNil: [^super adoptPaneColor: paneColor].
	super adoptPaneColor: (self theme subgroupColorFrom: paneColor).
	self contentMorph borderStyle: (self theme tabPanelBorderStyleFor: self)
]

{ #category : #accessing }
TabGroupMorph >> contentMorph [
	"Answer the value of contentMorph"

	^ contentMorph
]

{ #category : #accessing }
TabGroupMorph >> contentMorph: anObject [
	"Set the value of contentMorph"

	contentMorph := anObject
]

{ #category : #rounding }
TabGroupMorph >> cornerStyle: aSymbol [
	"Pass on to selector and content too."

	super cornerStyle: aSymbol.
	self tabSelectorMorph cornerStyle: aSymbol.
	self contentMorph cornerStyle: aSymbol
]

{ #category : #accessing }
TabGroupMorph >> font [
	"Answer the label font"

	^self tabSelectorMorph font
]

{ #category : #accessing }
TabGroupMorph >> font: aFont [
	"Set the label font"

	self tabSelectorMorph font: aFont
]

{ #category : #drawing }
TabGroupMorph >> fullDrawOn: aCanvas [
	"Patch up the selected tab visuals if required."
	
	super fullDrawOn: aCanvas.
	self theme drawTabGroupFinishingFor: self on: aCanvas
]

{ #category : #initialization }
TabGroupMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		borderWidth: 0;
		changeTableLayout;
		cellPositioning: #topLeft;
		cellInset: 0 @ -1;
		reverseTableCells: true;
		pageMorphs: OrderedCollection new;
		tabSelectorMorph: self newTabSelectorMorph;
		contentMorph: self newContentMorph;
		addMorph: self tabSelectorMorph;
		addMorph: self contentMorph.
	self tabSelectorMorph addDependent: self
]

{ #category : #page }
TabGroupMorph >> labelsAndPages: assocs [
	"Replace the tabs and the associated pages."

	self contentMorph removeAllMorphs.
	self tabSelectorMorph removeAllMorphs.
	assocs do: [:a | self addPage: a value label: a key]
]

{ #category : #drawing }
TabGroupMorph >> minExtent [
	"Calculate the min extent of the receiver based on all pages."

	|extra|
	self page ifNil: [^super minExtent max: self tabSelectorMorph minExtent].
	extra := 0@(self tabSelectorMorph minExtent y) + (self contentMorph borderWidth * 2).
	extra := extra + (self contentMorph layoutInset * 2).
	^super minExtent max: (((self pages inject: 0 @ 0 into: [:mw :pm | mw max: pm minExtent]) + extra)
		max: self tabSelectorMorph minExtent)
]

{ #category : #building }
TabGroupMorph >> newContentMorph [
	"Answer a new content morph"

	|p|
	p := PanelMorph new
		roundedCorners: #(2 3 4);
		changeTableLayout; 
		layoutInset: 4;
		cellInset: 8;
		vResizing: #spaceFill;
		hResizing: #spaceFill.
	p borderStyle: (self theme tabPanelBorderStyleFor: self).
	^p
]

{ #category : #building }
TabGroupMorph >> newTabSelectorMorph [
	"Answer a new tab selector morph"

	^TabSelectorMorph new
		vResizing: #shrinkWrap;
		hResizing: #spaceFill
]

{ #category : #accessing }
TabGroupMorph >> page [
	"Answer the current page morph if any."

	^self pageMorph
]

{ #category : #accessing }
TabGroupMorph >> page: aMorph [
	"Select the give page."

	self selectedPageIndex: (self pages indexOf: aMorph)
]

{ #category : #accessing }
TabGroupMorph >> pageMorph [
	"Answer the current page morph if any."

	^self contentMorph hasSubmorphs
		ifTrue: [self contentMorph submorphs first]
]

{ #category : #accessing }
TabGroupMorph >> pageMorphs [
	"Answer the value of pageMorphs"

	^ pageMorphs
]

{ #category : #accessing }
TabGroupMorph >> pageMorphs: anObject [
	"Set the value of pageMorphs"

	pageMorphs := anObject
]

{ #category : #accessing }
TabGroupMorph >> pages [
	"Answer the pages."

	^self pageMorphs
]

{ #category : #accessing }
TabGroupMorph >> paneColorOrNil [
	"Answer the window's pane color or nil otherwise."

	^super paneColorOrNil ifNotNil: [:c | self theme subgroupColorFrom: c]
]

{ #category : #page }
TabGroupMorph >> relabelPage: aMorph with: aStringOrMorph [
	"Relabel the tab associated with the given page and
	update tabs."

	self tabSelectorMorph
		relabelTab: (self tabOfPage: aMorph) with: aStringOrMorph
]

{ #category : #adding }
TabGroupMorph >> removePage: aMorph [
	"Remove the given page and its tab."

	|index|
	index := self pages indexOf: aMorph.
	self pages remove: aMorph.
	self tabSelectorMorph removeTabIndex: index
]

{ #category : #page }
TabGroupMorph >> removePageIndex: anInteger [
	"Remove the page at index anInteger page and its tab."

	self pages removeAt: anInteger.
	self tabSelectorMorph removeTabIndex: anInteger
]

{ #category : #page }
TabGroupMorph >> selectedPageIndex [
	"Answer the selected page index."

	^self tabSelectorMorph selectedIndex
]

{ #category : #page }
TabGroupMorph >> selectedPageIndex: index [
	"Set the selected page index."

	self tabSelectorMorph selectedIndex: index
]

{ #category : #accessing }
TabGroupMorph >> selectedTab [
	"Answer the tab of the selected page."
	
 	^self tabSelectorMorph selectedTab
]

{ #category : #page }
TabGroupMorph >> tabOfPage: aMorph [
	"Answer the tab associated with the given page."

	^self tabSelectorMorph tabs at: (self pages indexOf: aMorph)
]

{ #category : #accessing }
TabGroupMorph >> tabSelectorMorph [
	"Answer the value of tabSelectorMorph"

	^ tabSelectorMorph
]

{ #category : #accessing }
TabGroupMorph >> tabSelectorMorph: anObject [
	"Set the value of tabSelectorMorph"

	tabSelectorMorph := anObject
]

{ #category : #updating }
TabGroupMorph >> update: aSymbol with: anObject [
	"Handle tab changes."

	super update: aSymbol with: anObject.
	aSymbol == #selectedIndex ifTrue: [
			anObject > 0 & (anObject <= self pages size) 
				ifTrue: [ "the old selected page is available"					
					self updatePageIndex: self selectedPageIndex oldIndex: anObject]
				ifFalse: [ self updatePageIndex: self selectedPageIndex ]]
]

{ #category : #page }
TabGroupMorph >> updatePageIndex: index [
	"Change to the given page index."

	self pageMorph ifNotNil: [:p | self contentMorph removeMorph: p].
	index > 0 ifTrue: [self contentMorph addMorph: (self pages at: index)].
	self pageMorph ifNotNil: [:pm | pm layoutChanged].
	self adoptPaneColor: self paneColor
]

{ #category : #page }
TabGroupMorph >> updatePageIndex: index oldIndex: oldSelectedIndex [ 
	self updatePageIndex: index
]
