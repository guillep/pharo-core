"
Instances of this class accept, via #baseMorph:, a morph that is expected to be row-like containing submorphs.
Based on the receiver's layout, the base morphs that are able to fit within the receiver (subject to minExtents) are layed out along with, if necessary, a button to pop-up a column of any remaining, unfittable, base morphs.
Handy for button bars etc.

Example:

(OverflowRowMorph new
	baseMorph: (UITheme builder newRow: ((1 to: 6) collect: [:i | |label|
		label := 'Button ', i asString.
		(UITheme builder
			newButtonFor: Transcript
			getState: nil
			action: #show:
			arguments: {label}
			getEnabled: nil
			label: label
			help: nil)
			hResizing: #spaceFill]))) openInWindow
		
	
"
Class {
	#name : #OverflowRowMorph,
	#superclass : #PanelMorph,
	#instVars : [
		'baseMorphs',
		'moreButton',
		'moreMorph'
	],
	#category : #'Polymorph-Widgets-Base'
}

{ #category : #accessing }
OverflowRowMorph >> adoptPaneColor: paneColor [
	"Pass on to the list morph and border too."
	
	super adoptPaneColor: paneColor.
	paneColor ifNil: [^self].
	self moreButton cornerStyle: self cornerStyle.
	self changed: #moreButtonLabel.
	self moreMorphs do: [:m |
		m adoptPaneColor: paneColor]
]

{ #category : #accessing }
OverflowRowMorph >> baseMorph: aRowMorph [
	"Configure the receiver to match the specifications for the given morph and
	store the given morph's submorphs for later reallocation."
	
	self baseMorphs: aRowMorph submorphs.
	self
		cellInset: aRowMorph cellInset;
		layoutInset: aRowMorph layoutInset;
		height: aRowMorph minExtent y;
		minHeight: self height.
	self fitBaseMorphs
]

{ #category : #accessing }
OverflowRowMorph >> baseMorphs [
	"Answer the value of baseMorphs"

	^ baseMorphs
]

{ #category : #accessing }
OverflowRowMorph >> baseMorphs: anObject [
	"Set the value of baseMorphs"

	baseMorphs := anObject
]

{ #category : #private }
OverflowRowMorph >> buttonWidth [
	"Answer the width for the more button."

	^self theme scrollbarThickness + 3
]

{ #category : #accessing }
OverflowRowMorph >> desiredMoreMorphPosition [
	"Answer the position the more morph should be placed."

	^self moreButton boundsInWorld bottom + self moreMorph height > self world height
		ifTrue: [self moreButton boundsInWorld topRight - (self moreMorph width@self moreMorph height)]
		ifFalse: [self moreButton boundsInWorld bottomRight - (self moreMorph width@0)]
]

{ #category : #geometry }
OverflowRowMorph >> extent: aPoint [
	"Refit the base morphs and potential 'more' button'"

	super extent: aPoint.
	self fitBaseMorphs.
	self defer: [self layoutChanged]
		"since possibly changing actual submorphs during layout processing"
]

{ #category : #geometry }
OverflowRowMorph >> fitBaseMorphs [
	"Replace the receiver's submorphs with the base morphs that
	can fit in the receiver's bounds. Critically, morphs must be replaced in
	one go to avoid #extent: recursion."

	|proposed|
	self hideMore.
	proposed := self newPotentialMorph.
	[proposed width <= self width or: [proposed submorphCount = 0]] whileFalse: [
		proposed
			removeMorph: proposed lastSubmorph;
			extent: proposed minExtent].
	proposed submorphCount < self baseMorphs size ifTrue: [
		self moreButton hResizing: #shrinkWrap.
		proposed
			addMorphBack: self moreButton;
			extent: proposed minExtent].
	[proposed width > self width and: [proposed submorphCount > 1]] whileTrue: [
		proposed
			removeMorph: (proposed submorphs at: proposed submorphs size - 1);
			extent: proposed minExtent].
	(proposed submorphCount = 1 and: [self moreButton owner notNil]) ifTrue: [
		self moreButton hResizing: #spaceFill].
	self
		removeAllMorphs;
		addAllMorphs: proposed submorphs
	
]

{ #category : #showing }
OverflowRowMorph >> hideMore [
	"Hide the morphs that don't fit."

	self moreVisible ifTrue: [
		self moreMorph delete.
		self defer: [self world ifNotNil: [:w |
				w invalidRect: self moreMorph bounds]]]
]

{ #category : #initialization }
OverflowRowMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		baseMorphs: #();
		moreButton: self newMoreButton;
		changeTableLayout;
		listDirection: #leftToRight;
		vResizing: #shrinkWrap
]

{ #category : #accessing }
OverflowRowMorph >> moreButton [
	"Answer the value of moreButton"

	^ moreButton
]

{ #category : #accessing }
OverflowRowMorph >> moreButton: anObject [
	"Set the value of moreButton"

	moreButton := anObject
]

{ #category : #accessing }
OverflowRowMorph >> moreButtonLabel [
	"Answer the label for the more button."

	^AlphaImageMorph new image: (
		ScrollBar
			arrowOfDirection: #right
			size: self buttonWidth
			color: self paneColor darker)
]

{ #category : #accessing }
OverflowRowMorph >> moreMorph [
	"Answer the value of moreMorph"

	^ moreMorph
]

{ #category : #accessing }
OverflowRowMorph >> moreMorph: anObject [
	"Set the value of moreMorph"

	moreMorph := anObject
]

{ #category : #accessing }
OverflowRowMorph >> moreMorphs [
	"Answer those base morphs that are not currently part of the
	receiver's submorphs."

	^self baseMorphs
		ifEmpty: [#()]
		ifNotEmpty: [self baseMorphs copyFrom: self submorphs size to: self baseMorphs size]
]

{ #category : #accessing }
OverflowRowMorph >> moreVisible [
	"Answer whether the more column is visible."

	^(self moreMorph ifNil: [^false]) owner notNil
]

{ #category : #'instance creation' }
OverflowRowMorph >> newMoreButton [
	"Answer a new button for popping up the base morphs that are currently
	unable to fit in the allotted space."

	^(ControlButtonMorph
			on: self
			getState: nil
			action: #popMore
			label: #moreButtonLabel)
		hResizing: #rigid;
		vResizing: #spaceFill;
		cornerStyle: #square;
		extent: self buttonWidth asPoint
]

{ #category : #'instance creation' }
OverflowRowMorph >> newPotentialMorph [
	"Answer a morph for trialing potential layout."

	|potential|
	potential := self theme builder newRow: self baseMorphs.
	potential extent: potential minExtent.
	^potential
]

{ #category : #initialize }
OverflowRowMorph >> outOfWorld: aWorld [
	"Get rid of the more column if visible."

	self hideMore.
	^super outOfWorld: aWorld
]

{ #category : #accessing }
OverflowRowMorph >> popMore [
	"Hide / show the unshown base morphs."

	(self moreMorph isNil or: [self moreMorph owner isNil])
		ifTrue: [self showMore]
		ifFalse: [self hideMore]
]

{ #category : #accessing }
OverflowRowMorph >> recreateMoreMorph [
	"Answer a new morph showing the undisplayed base morphs.
	Assign to moreMorph."

	self moreMorph: (self theme builder newColumn: self moreMorphs).
	self moreMorph
		setProperty: #morphicLayerNumber toValue: 6;
		layoutInset: 4;
		borderStyle: (self theme taskbarThumbnailNormalBorderStyleFor: self moreMorph);
		extent: self moreMorph minExtent;
		position: self desiredMoreMorphPosition;
		paneColor: self paneColor;
		color: self paneColor.
	^self moreMorph
]

{ #category : #showing }
OverflowRowMorph >> showMore [
	"Show the morphs that don't fit."

	self hideMore.
	self recreateMoreMorph.
	self world addMorphInLayer: self moreMorph
]

{ #category : #stepping }
OverflowRowMorph >> step [
	"Move the more column if it is showing."

	self moreVisible ifTrue: [
		self window ifNotNil: [:w |
			w isActive ifFalse: [self hideMore]].
		self moreMorph position = self desiredMoreMorphPosition
			ifFalse: [self hideMore]]
]

{ #category : #stepping }
OverflowRowMorph >> stepTime [
	"Answer the desired time between steps in milliseconds."

	^100
]
