"
Specialized border for TabGroup. Does not draw border beneath the selectd tab and only draws on top.
"
Class {
	#name : #Pharo3TabPanelBorderStyle,
	#superclass : #TabPanelBorderStyle,
	#category : #'Polymorph-Widgets-Themes'
}

{ #category : #drawing }
Pharo3TabPanelBorderStyle >> frameRectangle: aRectangle on: aCanvas [
	"Draw the border taking the currently selected tab into account.
	Only works for top-positioned tabs for the moment."
	
	|w h r tab|
	w := self width.
	w isPoint ifTrue: [h := w y. w := w x] ifFalse:[h := w].
	tab := self selectedTab.
	tab ifNil: [	
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
