"
The titlebar area for and ExpanderMorph. Includes title label and expand/collapse button.
"
Class {
	#name : #ExpanderTitleMorph,
	#superclass : #PanelMorph,
	#instVars : [
		'labelMorph',
		'buttonMorph',
		'expanded'
	],
	#category : #'Polymorph-Widgets-Base'
}

{ #category : #accessing }
ExpanderTitleMorph >> adoptPaneColor: paneColor [
	"Update the fill styles, corner styles, label colour
	and expansion button indicator."
	
	super adoptPaneColor: paneColor.
	paneColor ifNil: [^self].
	self fillStyle: self normalFillStyle.
	self borderStyle baseColor: paneColor twiceDarker.
	self buttonMorph cornerStyle: self cornerStyle.
	self labelMorph color: paneColor contrastingBlackAndWhiteColor.
	self changed: #expandLabel
]

{ #category : #accessing }
ExpanderTitleMorph >> buttonMorph [
	"Answer the value of buttonMorph"

	^ buttonMorph
]

{ #category : #accessing }
ExpanderTitleMorph >> buttonMorph: anObject [
	"Set the value of buttonMorph"

	buttonMorph := anObject
]

{ #category : #private }
ExpanderTitleMorph >> buttonWidth [
	"Answer based on scrollbar size."
	
	^(self theme scrollbarThickness + 3)
		max: self theme expanderTitleControlButtonWidth
]

{ #category : #accessing }
ExpanderTitleMorph >> defaultBorderStyle [
	"Answer the default border style for the receiver."

	^BorderStyle raised width: 1
]

{ #category : #operations }
ExpanderTitleMorph >> expandLabel [
	"Answer the label for the expand button."

	^AlphaImageMorph new image: (
		ScrollBarMorph
			arrowOfDirection: (self expanded ifTrue: [#top] ifFalse: [#bottom])
			size: self buttonWidth - 3
			color: self paneColor darker)
]

{ #category : #accessing }
ExpanderTitleMorph >> expanded [
	"Answer the value of expanded"

	^ expanded
]

{ #category : #accessing }
ExpanderTitleMorph >> expanded: aBoolean [
	"Set the value of expanded"

	expanded := aBoolean.
	self
		changed: #expanded;
		changed: #expandLabel
]

{ #category : #geometry }
ExpanderTitleMorph >> extent: aPoint [ 
	"Set the receiver's extent to value provided.
	Update the gradient fills."

	|answer|
	aPoint = self extent ifTrue: [^super extent: aPoint].
	answer := super extent: aPoint.
	self fillStyle isOrientedFill
		ifTrue: [self fillStyle: self normalFillStyle].
	^answer
]

{ #category : #accessing }
ExpanderTitleMorph >> font [
	"Answer the label font"

	^((self labelMorph isKindOf: StringMorph) or: [self labelMorph isTextMorph])
		ifTrue: [self labelMorph font]
]

{ #category : #accessing }
ExpanderTitleMorph >> font: aFont [
	"Set the label font"

	((self labelMorph isKindOf: StringMorph) or: [self labelMorph isTextMorph])
		ifTrue: [self labelMorph font: aFont]
]

{ #category : #initialization }
ExpanderTitleMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		expanded: false;
		changeTableLayout;
		borderStyle: self defaultBorderStyle;
		layoutInset: (self theme expanderTitleInsetFor: self);
		listDirection: #leftToRight;
		listCentering: #center;
		wrapCentering: #center;
		buttonMorph: self newExpandButtonMorph;
		addMorph: self buttonMorph;
		labelMorph: self newLabelMorph;
		on: #mouseUp send: #toggleExpanded to: self
]

{ #category : #accessing }
ExpanderTitleMorph >> labelMorph [
	"Answer the value of labelMorph"

	^ labelMorph
]

{ #category : #accessing }
ExpanderTitleMorph >> labelMorph: anObject [
	"Set the value of labelMorph.
	need to wrap to provide clipping!"

	labelMorph ifNotNil: [self removeMorph: labelMorph owner].
	labelMorph := anObject.
	labelMorph ifNotNil: [self addMorph: (
		Morph new
			color: Color transparent;
			changeTableLayout;
			layoutInset: 4 @ 0;
			listDirection: #leftToRight;
			listCentering: #center;
			hResizing: #spaceFill;
			vResizing: #shrinkWrap;
			clipSubmorphs: true;
			addMorph: labelMorph)]
]

{ #category : #'instance creation' }
ExpanderTitleMorph >> newExpandButtonMorph [
	"Answer a new expand button."

	^(ControlButtonMorph
			on: self
			getState: nil
			action: #toggleExpanded
			label: #expandLabel)
		hResizing: #rigid;
		vResizing: #spaceFill;
		cornerStyle: self cornerStyle;
		extent: self buttonWidth asPoint
]

{ #category : #'instance creation' }
ExpanderTitleMorph >> newLabelMorph [
	"Answer a new label morph for the receiver."

	^LabelMorph new
		hResizing: #spaceFill;
		vResizing: #shrinkWrap
]

{ #category : #style }
ExpanderTitleMorph >> normalFillStyle [
	"Return the normal fillStyle of the receiver."
	
	^self theme expanderTitleNormalFillStyleFor: self
]

{ #category : #style }
ExpanderTitleMorph >> themeChanged [
	"Update the button corner style from default
	to match the receiver."
	
	super themeChanged.
	self buttonMorph cornerStyle: self cornerStyle
]

{ #category : #protocol }
ExpanderTitleMorph >> titleText [
	"Answer the text if the title morph is capable."

	^((self labelMorph isKindOf: StringMorph) or: [self labelMorph isTextMorph])
		ifTrue: [self labelMorph contents]
		ifFalse: ['']
]

{ #category : #operations }
ExpanderTitleMorph >> titleText: aStringOrText [
	"Set the text if the title morph is capable."

	((self labelMorph isKindOf: StringMorph) or: [self labelMorph isTextMorph])
		ifTrue: [self labelMorph contents: aStringOrText]
]

{ #category : #operations }
ExpanderTitleMorph >> toggleExpanded [
	"Toggle the expanded state."

	self expanded: self expanded not
]
