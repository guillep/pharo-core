"
I'm a toolbar morph.
I can display toolbar items in left side or right side panels. 

"
Class {
	#name : #SpToolbarMorph,
	#superclass : #Morph,
	#instVars : [
		'leftPanel',
		'rightPanel',
		'displayMode',
		'toolbarItemFont'
	],
	#category : #'Spec2-Adapters-Morphic-Toolbar'
}

{ #category : #accessing }
SpToolbarMorph class >> defaultHeight [
	
	^ self defaultMode height
]

{ #category : #accessing }
SpToolbarMorph class >> defaultItemSeparation [

	^ 0
]

{ #category : #accessing }
SpToolbarMorph class >> defaultItemSize [

	^ 50
]

{ #category : #accessing }
SpToolbarMorph class >> defaultMode [

	^ SpToolbarDisplayMode default
]

{ #category : #accessing }
SpToolbarMorph class >> statusBarHeight [
	
	^ 25
]

{ #category : #accessing }
SpToolbarMorph >> addItem: aToolbarItem [
	
	self addItem: aToolbarItem position: SpToolbarItemPosition left
]

{ #category : #accessing }
SpToolbarMorph >> addItem: aToolbarItem position: aPosition [

	aPosition addItem: aToolbarItem into: self.
	self computeFullBounds.
	self minWidth: self calculateWidth.
	self width: self minWidth.
	self refresh
]

{ #category : #accessing }
SpToolbarMorph >> addItemLeft: aMorph [

	leftPanel addMorphBack: (aMorph
		vResizing: #spaceFill;
		yourself)
]

{ #category : #accessing }
SpToolbarMorph >> addItemRight: aMorph [

	self hasRightPanel
		ifFalse: [ self addMorphBack: rightPanel ]. 

	rightPanel addMorphBack: (aMorph
		vResizing: #spaceFill;
		yourself).
	rightPanel width: (rightPanel submorphs sum: #width)
]

{ #category : #'as yet unclassified' }
SpToolbarMorph >> addItemsFromContext: aContext [
	
	self flag: #TODO.
	"| menu |
	
	menu := CmdMenu activatedBy: ITToolbarActivation.
	menu buildInContext: aContext.
	menu buildToolbarOn: self"

]

{ #category : #private }
SpToolbarMorph >> calculateWidth [

	^ (leftPanel submorphs sum: #width) 
		+ (self hasRightPanel ifTrue: [ rightPanel submorphs sum: #width ] ifFalse: [ 0 ])
]

{ #category : #updating }
SpToolbarMorph >> clearItems [
	
	leftPanel removeAllMorphs.
	rightPanel removeAllMorphs.
]

{ #category : #accessing }
SpToolbarMorph >> color: aColor [
	color := aColor
]

{ #category : #accessing }
SpToolbarMorph >> defaultColor [
	^ Color transparent
]

{ #category : #accessing }
SpToolbarMorph >> displayMode [
	^ displayMode ifNil: [ displayMode := SpToolbarDisplayMode default ]
]

{ #category : #accessing }
SpToolbarMorph >> displayMode: anObject [
	displayMode := anObject
]

{ #category : #private }
SpToolbarMorph >> hasRightPanel [

	^ self submorphs includes: rightPanel
]

{ #category : #initialization }
SpToolbarMorph >> initialize [
	super initialize.

	self
		changeTableLayout;
		listDirection: #leftToRight;
		hResizing: #spaceFill;
		vResizing: #rigid;
		wrapCentering: #center; 
		color: self defaultColor;
		extent: 0@0.
	
	self initializePanels
]

{ #category : #initialization }
SpToolbarMorph >> initializePanels [

	leftPanel := self newPanelMorph.
	rightPanel := self newPanelMorph
		listDirection: #rightToLeft;
		hResizing: #spaceFill.

	self addMorphBack: leftPanel
]

{ #category : #private }
SpToolbarMorph >> leftPanel [
	^ leftPanel
]

{ #category : #private }
SpToolbarMorph >> leftPanel: anObject [
	leftPanel := anObject
]

{ #category : #'private factory' }
SpToolbarMorph >> newPanelMorph [

	^ Morph new
		changeTableLayout;
		listDirection: #leftToRight;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		cellInset: self class defaultItemSeparation@0;
		extent: 0@0;
		color: Color transparent;
		yourself
]

{ #category : #'private factory' }
SpToolbarMorph >> newToolbarItemFont [
	| buttonFont |

	buttonFont := self theme buttonFont.
	^ LogicalFont 
		familyName: buttonFont familyName 
		pointSize: buttonFont pointSize - 3
]

{ #category : #accessing }
SpToolbarMorph >> refresh [

	self flag: #TODO. "Maybe remove?"
]

{ #category : #private }
SpToolbarMorph >> rightPanel [
	^ rightPanel
]

{ #category : #private }
SpToolbarMorph >> rightPanel: anObject [
	rightPanel := anObject
]

{ #category : #accessing }
SpToolbarMorph >> toolbarItemFont [
	^ toolbarItemFont ifNil: [ toolbarItemFont := self newToolbarItemFont ]
]

{ #category : #accessing }
SpToolbarMorph >> toolbarItemFont: anObject [
	toolbarItemFont := anObject
]

{ #category : #accessing }
SpToolbarMorph >> toolbarItemSize [

	^ self displayMode height
]
