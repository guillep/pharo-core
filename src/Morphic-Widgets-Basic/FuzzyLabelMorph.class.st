"
A label that underdraws to the top-left, top-right, bottom-right and bottom left by a specifed offset in a contrasting colour to the receiver's with a specified alpha value.
"
Class {
	#name : #FuzzyLabelMorph,
	#superclass : #LabelMorph,
	#instVars : [
		'offset',
		'alpha'
	],
	#category : #'Morphic-Widgets-Basic'
}

{ #category : #accessing }
FuzzyLabelMorph >> alpha [
	"Answer the value of alpha"

	^ alpha
]

{ #category : #accessing }
FuzzyLabelMorph >> alpha: anObject [
	"Set the value of alpha"

	alpha := anObject.
	self changed
]

{ #category : #drawing }
FuzzyLabelMorph >> drawOn: aCanvas [
	"Draw based on enablement."
	
	|pc fuzzColor labelColor|
	pc := self paneColor.
	labelColor := self enabled
		ifTrue: [self color]
		ifFalse: [pc twiceDarker].
	fuzzColor := self enabled
		ifTrue: [labelColor twiceDarker darker contrastingBlackAndWhiteColor alpha: self 
alpha]
		ifFalse: [Color transparent].
	aCanvas depth < 8 ifTrue: [fuzzColor := Color transparent alpha: 0.001].
	fuzzColor isTransparent ifFalse: [
		aCanvas
			drawString: self contents
			in: (self bounds translateBy: 0 @ -1)
			font: self fontToUse
			color: fuzzColor;
			drawString: self contents
			in: (self bounds translateBy: (self offset * 2) @ -1)
			font: self fontToUse
			color: fuzzColor;
			drawString: self contents
			in: (self bounds translateBy: (self offset * 2) @ (self offset 
* 2 - 1))
			font: self fontToUse
			color: fuzzColor;
			drawString: self contents
			in: (self bounds translateBy: 0 @ (self offset * 2 - 1))
			font: self fontToUse
			color: fuzzColor].
	aCanvas
		drawString: self contents
		in: (self bounds translateBy: self offset @ (self offset - 1))
		font: self fontToUse
		color: labelColor
]

{ #category : #initialization }
FuzzyLabelMorph >> initWithContents: aString font: aFont emphasis: emphasisCode [
	"Grrr, why do they do basicNew?"
	
	offset := 1.
	alpha := 0.5.
	super initWithContents: aString font: aFont emphasis: emphasisCode
]

{ #category : #initialization }
FuzzyLabelMorph >> initialize [
	"Initialize the receiver."

	offset := 1.
	alpha := 0.5.
	super initialize
]

{ #category : #accessing }
FuzzyLabelMorph >> measureContents [
	"Add 2 times offset."
	
	^super measureContents ceiling + (self offset * 2) asPoint
]

{ #category : #accessing }
FuzzyLabelMorph >> offset [
	"Answer the value of offset"

	^ offset
]

{ #category : #accessing }
FuzzyLabelMorph >> offset: anObject [
	"Set the value of offset"

	offset := anObject.
	self fitContents
]

{ #category : #accessing }
FuzzyLabelMorph >> setWidth: width [
	"Set the width/extent."
	
	self extent: width @ (self fontToUse height ceiling + (2 * self offset))
]
