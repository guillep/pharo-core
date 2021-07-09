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
	#name : #FTFilterFunctionWithAction,
	#superclass : #FTWithActionFilterFunction,
	#category : #'Morphic-Widgets-FastTable-Functions'
}

{ #category : #testing }
FTFilterFunctionWithAction class >> isDeprecated [ 
	^ true
]
