Class {
	#name : #GLMDropDownMorphicTest,
	#superclass : #GLMMorphicTest,
	#category : #'Glamour-Tests-Morphic'
}

{ #category : #tests }
GLMDropDownMorphicTest >> testSelectionTriggeredOnSelectedIndex [
	| browser dropdown text dropdownMorph textMorph |
	browser := GLMTabulator new.
 	browser row: #one; row: #two.
 	browser transmit to: #one; andShow: [:a |
 		a dropDownList
 			display: [:x | (1 to: x) + 10 ];
 			selectedIndex: 2 ].
 	browser transmit from: #one; to: #two; andShow: [:a |
 		a text].
 	window := browser openOn: 5.
	dropdown := browser panes first presentations first.
	"Because #selectedIndex: must trigger a transmission, we should get the text presentation in #two"
	self assert: browser panes second presentations size equals: 1.
	text := browser panes second presentations first.
	dropdownMorph := self findWherePresentationIs: dropdown in: window.
	textMorph := self findWherePresentationIs: text in: window.
	self assert: dropdownMorph selectedItem contents equals: '12'.
	self assert: textMorph text asString equals: '12'
]
