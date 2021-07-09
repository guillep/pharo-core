"
I am a Filter widget that also have an action button.

Description
-------------------------------------------------
I am use as a FilterFunction but I also have a Button. I am use by FTTableMorph.

Public API and Key Messages
-------------------------------------------------

- #table: aTableMorph action: aBlock named: aString
	is my constructor. The block is the action to be executed by the button and the string is the name of the button.
	

Internal Representation and Key Implementation Points.
-------------------------------------------------

    Instance Variables
	actionBlock:		I am a block that need to be executed when the user press the button
	actionButton:		I am the button of the widget

The action block can takes 3 parameters:
- The filtered data source
- The pattern on the filter field 
- The selected element on the table
"
Class {
	#name : #FTWithActionFilterFunction,
	#superclass : #FTFilterFunction,
	#instVars : [
		'actionButton',
		'actionBlock'
	],
	#category : #'Morphic-Widgets-FastTable-Functions'
}

{ #category : #'instance creation' }
FTWithActionFilterFunction class >> table: aFTTableMorph action: aBlockClosure named: aString [
	^ (self table: aFTTableMorph)
		action: aBlockClosure named: aString;
		yourself
]

{ #category : #option }
FTWithActionFilterFunction >> action: aBlockClosure named: aString [
	actionBlock := aBlockClosure.
	self initializeActionButtonNamed: aString 
]

{ #category : #accessing }
FTWithActionFilterFunction >> beExplicit [
	super beExplicit.
	table addMorph: actionButton.
	table selectedIndex = 0
		ifTrue: [ table selectIndex: 1 ]
]

{ #category : #execute }
FTWithActionFilterFunction >> execute [
	actionBlock
		cull: table dataSource
		cull: field getTextFromModel asString
		cull:
			(table selectedIndex = 0
				ifFalse: [ table dataSource realElementAt: table selectedIndex ]
				ifTrue: [ nil ])
]

{ #category : #initialization }
FTWithActionFilterFunction >> initializeActionButtonNamed: aString [
	actionButton := PluggableButtonMorph
		newButtonFor: self
		action: #execute
		label: aString
		help: nil
]

{ #category : #private }
FTWithActionFilterFunction >> resizeButton [
	| topLeft bottomRight |
	self flag: #pharoTodo.	"Maybe it could be cool to let the user choose if the field need to be at the top or the bottom."
	bottomRight := (table bounds right - table verticalScrollBarWidth) @ (table bottom - table horizontalScrollBarHeight).
	topLeft := (bottomRight x - actionButton width) @ (table bounds bottom - self fieldHeigh - table horizontalScrollBarHeight).
	actionButton bounds: (topLeft corner: bottomRight)
]

{ #category : #private }
FTWithActionFilterFunction >> resizeField [
	| topLeft bottomRight |
	self flag: #pharoTodo.	"Maybe it could be cool to let the user choose if the field need to be at the top or the bottom."
	topLeft := table bounds left @ (table bounds bottom - self fieldHeigh - table horizontalScrollBarHeight).
	bottomRight := (table bounds right - table verticalScrollBarWidth - (actionButton width + 5))
		@ (table bottom - table horizontalScrollBarHeight).
	field bounds: (topLeft corner: bottomRight)
]

{ #category : #private }
FTWithActionFilterFunction >> resizeWidget [
	self resizeField.
	self resizeButton
]

{ #category : #accessing }
FTWithActionFilterFunction >> showWidget [
	super showWidget.
	table addMorph: actionButton.
	table selectedIndex = 0 ifTrue: [ table selectIndex: 1 ]
]
