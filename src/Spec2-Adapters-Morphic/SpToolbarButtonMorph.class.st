"
A button morph typically used on a toolbar. The button can have a badge.
"
Class {
	#name : #SpToolbarButtonMorph,
	#superclass : #PluggableButtonMorph,
	#instVars : [
		'badgeFont',
		'badgeSelector'
	],
	#category : #'Spec2-Adapters-Morphic-Toolbar'
}

{ #category : #accessing }
SpToolbarButtonMorph >> badge [
	badgeSelector ifNil: [ ^ nil ].
	^ self model perform: badgeSelector
]

{ #category : #accessing }
SpToolbarButtonMorph >> badgeColor [
	^ self theme badgeColor
]

{ #category : #accessing }
SpToolbarButtonMorph >> badgeFont [
	^ badgeFont ifNil: [ badgeFont := self newBadgeFont ]
]

{ #category : #accessing }
SpToolbarButtonMorph >> badgeSelector: aSymbol [
	badgeSelector := aSymbol
]

{ #category : #accessing }
SpToolbarButtonMorph >> badgeTextColor [
	^ self theme badgeTextColor
]

{ #category : #configuring }
SpToolbarButtonMorph >> configureWith: displayModel item: itemPresenter [
	displayModel configureButton: self item: itemPresenter
]

{ #category : #accessing }
SpToolbarButtonMorph >> drawBadgeOn: aCanvas [
	| badgeString badgeBounds textBounds textWidth textHeight width |
	
	badgeString := self badge asString.
	textWidth := self badgeFont widthOfString: badgeString.
	textHeight := self badgeFont height.
	width := 14 max: textWidth + 2. 
	badgeBounds := ((bounds right - width - 2)@(bounds top + 2) extent: width@14).
	aCanvas 
		fillOval: badgeBounds
		fillStyle: self badgeColor.
		
	textBounds := 
		(badgeBounds center - ((textWidth@textHeight) / 2.0)) + (1@0) 
		extent: textWidth@textHeight. 
	aCanvas 
		drawString: badgeString
		in: textBounds
		font: self badgeFont 
		color: self badgeTextColor
]

{ #category : #accessing }
SpToolbarButtonMorph >> drawOn: aCanvas [
	super drawOn: aCanvas.
	self hasBadge
		ifTrue: [ self drawBadgeOn: aCanvas ]
]

{ #category : #accessing }
SpToolbarButtonMorph >> getIconSelector [

	^ getIconSelector
]

{ #category : #accessing }
SpToolbarButtonMorph >> getIconSelector: aSelector [

	getIconSelector := aSelector.
	self update: getIconSelector
]

{ #category : #accessing }
SpToolbarButtonMorph >> getLabelSelector [

	^ getLabelSelector
]

{ #category : #accessing }
SpToolbarButtonMorph >> getLabelSelector: aSelector [

	getLabelSelector := aSelector.
	self update: getLabelSelector
]

{ #category : #accessing }
SpToolbarButtonMorph >> hasBadge [
	^ self badge notNil
]

{ #category : #style }
SpToolbarButtonMorph >> mouseOverBorderStyle [

	^ self normalBorderStyle
]

{ #category : #accessing }
SpToolbarButtonMorph >> newBadgeFont [
	| baseBadgeFont |
	baseBadgeFont := StandardFonts codeFont.
 	^ (LogicalFont 
		familyName: baseBadgeFont familyName 
		pointSize: baseBadgeFont pointSize - 3)
			weightValue: 700
]

{ #category : #style }
SpToolbarButtonMorph >> normalBorderStyle [

	^ BorderStyle width: 0 color: Color transparent
]

{ #category : #style }
SpToolbarButtonMorph >> normalFillStyle [

	^ Color transparent
]

{ #category : #style }
SpToolbarButtonMorph >> pressedBorderStyle [
	"Return the pressed borderStyle of the receiver."

	^ self normalBorderStyle
]
