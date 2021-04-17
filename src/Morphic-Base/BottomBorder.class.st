"
Description
--------------------

BottomBorder is a border style that will fill only the bottom of the rectangle.

Public API and Key Messages
--------------------
•	#trimSize:  This option allow to trim the bottom border

Examples
--------------------

BottomBorder new
width: 1;
baseColor: Color white;
trimSize: 2;
yourself

Internal Representation and Key Implementation Points.
--------------------

Instance Variables
trimSize:  <anInteger>  An amount of pixel to trim from both side of the bottom border

"
Class {
	#name : #BottomBorder,
	#superclass : #BottomBorderStyle,
	#category : #'Morphic-Base-Borders'
}

{ #category : #testing }
BottomBorder class >> isDeprecated [ 
	^ true
]
