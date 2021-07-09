"
I am an abstract class. My subclasses are some functions for a FastTable that need a field when they are use explicitely.

Description
-------------------------------------------------
I act as my superclass but I manage a field. When the user type in the field an Announcement will call #update:

Public API and Key Messages
-------------------------------------------------

- #update: anAnnoucement
	is call when the user type something into the field
	
Example (Should only be create by a FTTableMorph)
-------------------------------------------------

FTFunctionWithField table: (FTTableMorph with: (1 to: 200))

Internal Representation and Key Implementation Points.
-------------------------------------------------

    Instance Variables
	field:		I am the field to display at the bottom of the FTTableMorph
"
Class {
	#name : #FTFunctionWithField,
	#superclass : #FTWithFieldFunction,
	#category : #'Morphic-Widgets-FastTable-Functions'
}

{ #category : #testing }
FTFunctionWithField class >> isDeprecated [ 
	^ true
]
