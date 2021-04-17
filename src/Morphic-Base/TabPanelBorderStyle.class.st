"
Specialist border for a TabGroup panel. Does not draw border beneath selected tab.
"
Class {
	#name : #TabPanelBorderStyle,
	#superclass : #SimpleBorderStyle,
	#instVars : [
		'tabSelector'
	],
	#category : #'Morphic-Base-Borders'
}

{ #category : #drawing }
TabPanelBorderStyle >> frameRectangle: aRectangle on: aCanvas [
	"Draw the border taking the currently selected tab into account.
	Only works for top-positioned tabs for the moment."
	
	|w h r tab|
	w := self width.
	w isPoint ifTrue: [h := w y. w := w x] ifFalse:[h := w].
	r := aRectangle topLeft extent: w@aRectangle height.
	aCanvas fillRectangle: r color: self color. "left"
	r := aRectangle topRight - (w@0) extent: w@aRectangle height.
	aCanvas fillRectangle: r color: self color. "right"
	r := aRectangle bottomLeft + (w@h negated) extent: aRectangle width - w - w@h.
	aCanvas fillRectangle: r color: self color. "bottom"
	tab := self selectedTab.
	(tab isNil or: [tab owner isNil]) ifTrue: [	
		r := aRectangle topLeft + (w@0) corner: aRectangle topRight - (w@h negated).
		aCanvas fillRectangle: r color: self color.
		^self]. "top"
	r := aRectangle topLeft + (w@0) corner: tab bounds left + w@(aRectangle top + h).
	aCanvas fillRectangle: r color: self color. "top 1"
	r := tab bounds left + w@ aRectangle top corner: tab bounds right - w@(aRectangle top + h).
	aCanvas fillRectangle: r color: tab paneColor. "top 2"
	r :=  tab bounds right - w@ aRectangle top corner: aRectangle topRight - (w@h negated).
	aCanvas fillRectangle: r color: self color. "top 3"
]

{ #category : #accessing }
TabPanelBorderStyle >> selectedTab [
	"Answer the currently selected tab."
	
	^(self tabSelector ifNil: [^nil]) selectedTab
]

{ #category : #accessing }
TabPanelBorderStyle >> style [
	"Answer #tabbed."
	
	^#tabbed
]

{ #category : #accessing }
TabPanelBorderStyle >> tabSelector [
	"Answer the value of tabSelector"

	^ tabSelector
]

{ #category : #accessing }
TabPanelBorderStyle >> tabSelector: anObject [
	"Set the value of tabSelector"

	tabSelector := anObject
]
