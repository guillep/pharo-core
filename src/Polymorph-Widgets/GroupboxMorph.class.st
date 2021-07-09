"
Groupbox with title with a vertical layout. Appears in a lighter colour than the owner's pane colour.
"
Class {
	#name : #GroupboxMorph,
	#superclass : #ModelMorphic,
	#instVars : [
		'contentMorph',
		'labelMorph',
		'getContentSelector'
	],
	#category : #'Polymorph-Widgets-Base'
}

{ #category : #adding }
GroupboxMorph >> addContentMorph: aMorph [
	"Add a morph to the content."

	^self contentMorph addMorphBack: aMorph
]

{ #category : #accessing }
GroupboxMorph >> adoptPaneColor: paneColor [
	"Pass on to the content morph."
	
	|c|
	paneColor ifNil: [^super adoptPaneColor: paneColor].
	c := self theme subgroupColorFrom: paneColor.
	super adoptPaneColor: c.
	self contentMorph borderStyle: (self theme groupPanelBorderStyleFor: self).
	self labelMorph
		color: paneColor blacker muchDarker;
		backgroundColor: c;
		borderStyle: (self theme groupLabelBorderStyleFor: self)
]

{ #category : #'geometry testing' }
GroupboxMorph >> containsPoint: aPoint [
	"Override here to check the label and content instead."
	
	^(super containsPoint: aPoint) and: [
		(self labelMorph containsPoint: aPoint) or: [
		self contentMorph containsPoint: aPoint]]
]

{ #category : #accessing }
GroupboxMorph >> contentFromModel [
	"Answer content from the model."
	
	^self getContentSelector ifNotNil: [:s |
		self model ifNotNil: [:m | m perform: s]]
]

{ #category : #accessing }
GroupboxMorph >> contentMorph [
	"Answer the value of contentMorph"

	^ contentMorph
]

{ #category : #accessing }
GroupboxMorph >> contentMorph: anObject [
	"Set the value of contentMorph"

	contentMorph := anObject
]

{ #category : #rounding }
GroupboxMorph >> cornerStyle: aSymbol [
	"Pass on to list too."

	super cornerStyle: aSymbol.
	self labelMorph cornerStyle: aSymbol.
	self contentMorph cornerStyle: aSymbol
]

{ #category : #accessing }
GroupboxMorph >> font [
	"Answer the label font"

	^self labelMorph font
]

{ #category : #accessing }
GroupboxMorph >> font: aFont [
	"Set the label font"

	self labelMorph font: aFont
]

{ #category : #accessing }
GroupboxMorph >> getContentSelector [

	^ getContentSelector
]

{ #category : #accessing }
GroupboxMorph >> getContentSelector: anObject [

	getContentSelector := anObject
]

{ #category : #initialization }
GroupboxMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		roundedCorners: #(2 3 4);
		borderWidth: 0;
		changeTableLayout;
		cellPositioning: #topLeft;
		cellInset: 0 @ -1;
		reverseTableCells: true;
		labelMorph: self newLabelMorph;
		contentMorph: self newContentMorph;
		addMorphBack: self contentMorph;
		addMorphBack: self labelMorph
]

{ #category : #accessing }
GroupboxMorph >> label [
	"Answer the contents of the label morph."

	^self labelMorph contents
]

{ #category : #accessing }
GroupboxMorph >> label: aString [
	"Set the contents of the label morph."

	aString ifNil: [
		self roundedCorners: #(1 2 3 4).
		self labelMorph delete. ^self].
	self roundedCorners: #(2 3 4).
	self labelMorph owner ifNil: [
		self addMorph: self labelMorph].
	self labelMorph contents: aString
]

{ #category : #accessing }
GroupboxMorph >> labelMorph [
	"Answer the value of labelMorph"

	^ labelMorph
]

{ #category : #accessing }
GroupboxMorph >> labelMorph: anObject [
	"Set the value of labelMorph"

	labelMorph := anObject
]

{ #category : #'geometry testing' }
GroupboxMorph >> minExtent [
	"Answer the minmum extent of the receiver.
	Based on label and rounding."

	^super minExtent max: self labelMorph minExtent + (8@0)
]

{ #category : #'instance creation' }
GroupboxMorph >> newContentMorph [
	"Answer a new content morph"

	|p|
	p := PanelMorph new
		roundedCorners: self roundedCorners;
		changeTableLayout; 
		layoutInset: 4;
		cellInset: 8;
		vResizing: #spaceFill;
		hResizing: #spaceFill.
	p borderStyle: (self theme groupPanelBorderStyleFor: p).
	^p
]

{ #category : #'instance creation' }
GroupboxMorph >> newLabelMorph [
	"Answer a new label morph"

	^TextMorph new
		roundedCorners: #(1 4);
		margins: (Margin left: 2 right: 2 top: 1 bottom: -1);
		contents: 'groupbox';
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		lock
]

{ #category : #accessing }
GroupboxMorph >> paneColorOrNil [
	"Answer the window's pane color or nil otherwise."

	^super paneColorOrNil ifNotNil: [:c | self theme subgroupColorFrom: c]
]

{ #category : #updating }
GroupboxMorph >> replaceContentMorph: aMorph [
	"Replace the content."

	self contentMorph
		removeAllMorphs;
		addMorphBack: aMorph.
	self adoptPaneColor: super paneColorOrNil.
	^aMorph
		
]

{ #category : #accessing }
GroupboxMorph >> roundedCorners: anArray [
	"Set the corners to round."

	super roundedCorners: anArray.
	self contentMorph ifNotNil: [:cm | cm roundedCorners: self roundedCorners]
]

{ #category : #accessing }
GroupboxMorph >> selectedTab [
	"Answer the label morph for compatibility with TabPanelBorder."
	
	^self labelMorph owner
		ifNotNil: [self labelMorph]
]

{ #category : #updating }
GroupboxMorph >> update: aSymbol [
	"Replace the content if appropriate."
	
	super update: aSymbol.
	aSymbol = self getContentSelector ifTrue: [
		self contentFromModel ifNotNil: [:c | self replaceContentMorph: c]]
		
]
