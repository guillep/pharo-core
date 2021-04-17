"
Rounded corner border supporting radii of 1-4 pixels. Slower but more flexible than CornerRounder.
"
Class {
	#name : #RoundedBorderStyle,
	#superclass : #SimpleBorderStyle,
	#instVars : [
		'cornerRadius'
	],
	#category : #'Morphic-Base-Borders'
}

{ #category : #accessing }
RoundedBorderStyle >> cornerRadius [
	"Answer the value of cornerRadius"

	^ cornerRadius
]

{ #category : #accessing }
RoundedBorderStyle >> cornerRadius: anObject [
	"Set the value of cornerRadius"

	cornerRadius := anObject
]

{ #category : #drawing }
RoundedBorderStyle >> frameRectangle0: aRectangle on: aCanvas [
	"Draw the border for a corner radius of 0."

	aCanvas
		frameAndFillRectangle: aRectangle
		fillColor: Color transparent
		borderWidth: self width
		borderColor: self color
]

{ #category : #drawing }
RoundedBorderStyle >> frameRectangle1: aRectangle on: aCanvas [
	"Draw the border for a corner radius of 1."

	|r|
	r := aRectangle insetBy: self width // 2.	
	self width odd ifTrue: [r := r insetBy: (0@0 corner: 1@1)].
	aCanvas
		line: r topLeft + (1@0) to: r topRight - (1@0) width: self width color: self color;
		line: r topRight + (0@1) to: r bottomRight - (0@1) width: self width color: self color;
		line: r bottomRight - (1@0) to: r bottomLeft + (1@0) width: self width color: self color;
		line: r bottomLeft - (0@1) to: r topLeft + (0@1) width: self width color: self color
]

{ #category : #drawing }
RoundedBorderStyle >> frameRectangle2: aRectangle on: aCanvas [
	"Draw the border for a corner radius of 2."

	|r|
	r := aRectangle insetBy: self width // 2.	
	self width odd ifTrue: [r := r insetBy: (0@0 corner: 1@1)].
	aCanvas
		line: r topLeft + (2@0) to: r topRight - (2@0) width: self width color: self color;
		line: r topRight + (-1@1) to: r topRight + (-1@1) width: self width color: self color;
		line: r topRight + (0@2) to: r bottomRight - (0@2) width: self width color: self color;
		line: r bottomRight - (1@1) to: r bottomRight - (1@1) width: self width color: self color;
		line: r bottomRight - (2@0) to: r bottomLeft + (2@0) width: self width color: self color;
		line: r bottomLeft - (-1@1) to: r bottomLeft - (-1@1) width: self width color: self color;
		line: r bottomLeft - (0@2) to: r topLeft + (0@2) width: self width color: self color;
		line: r topLeft + (1@1) to: r topLeft + (1@1) width: self width color: self color
]

{ #category : #drawing }
RoundedBorderStyle >> frameRectangle3: aRectangle on: aCanvas [
	"Draw the border for a corner radius of 3."

	|r|
	r := aRectangle insetBy: self width // 2.	
	self width odd ifTrue: [r := r insetBy: (0@0 corner: 1@1)].
	aCanvas
		line: r topLeft + (3@0) to: r topRight - (3@0) width: self width color: self color;
		line: r topRight + (-2@1) to: r topRight + (-1@1) width: self width color: self color;
		line: r topRight + (-1@1) to: r topRight + (-1@2) width: self width color: self color;
		line: r topRight + (0@3) to: r bottomRight - (0@3) width: self width color: self color;
		line: r bottomRight - (1@2) to: r bottomRight - (1@1) width: self width color: self color;
		line: r bottomRight - (1@1) to: r bottomRight - (2@1) width: self width color: self color;
		line: r bottomRight - (3@0) to: r bottomLeft + (3@0) width: self width color: self color;
		line: r bottomLeft - (-2@1) to: r bottomLeft - (-1@1) width: self width color: self color;
		line: r bottomLeft - (-1@1) to: r bottomLeft - (-1@2) width: self width color: self color;
		line: r bottomLeft - (0@3) to: r topLeft + (0@3) width: self width color: self color;
		line: r topLeft + (1@2) to: r topLeft + (1@1) width: self width color: self color;
		line: r topLeft + (1@1) to: r topLeft + (2@1) width: self width color: self color
]

{ #category : #drawing }
RoundedBorderStyle >> frameRectangle4: aRectangle on: aCanvas [
	"Draw the border for a corner radius of 4."

	|r|
	r := aRectangle insetBy: self width // 2.	
	self width odd ifTrue: [r := r insetBy: (0@0 corner: 1@1)].
	aCanvas
		line: r topLeft + (4@0) to: r topRight - (4@0) width: self width color: self color;
		line: r topRight + (-3@1) to: r topRight + (-1@2) width: self width color: self color;
		line: r topRight + (-1@2) to: r topRight + (-1@3) width: self width color: self color;
		line: r topRight + (0@4) to: r bottomRight - (0@4) width: self width color: self color;
		line: r bottomRight - (1@3) to: r bottomRight - (1@2) width: self width color: self color;
		line: r bottomRight - (2@1) to: r bottomRight - (3@1) width: self width color: self color;
		line: r bottomRight - (4@0) to: r bottomLeft + (4@0) width: self width color: self color;
		line: r bottomLeft - (-3@1) to: r bottomLeft - (-2@1) width: self width color: self color;
		line: r bottomLeft - (-1@2) to: r bottomLeft - (-1@3) width: self width color: self color;
		line: r bottomLeft - (0@4) to: r topLeft + (0@4) width: self width color: self color;
		line: r topLeft + (1@3) to: r topLeft + (1@2) width: self width color: self color;
		line: r topLeft + (2@1) to: r topLeft + (3@1) width: self width color: self color
]

{ #category : #drawing }
RoundedBorderStyle >> frameRectangle5: aRectangle on: aCanvas [
	"Draw the border for a corner radius of 5."

	|r|
	r := aRectangle insetBy: self width // 2.	
	self width odd ifTrue: [r := r insetBy: (0@0 corner: 1@1)].
	aCanvas
		line: r topLeft + (5@0) to: r topRight - (5@0) width: self width color: self color;
		line: r topRight + (-4@1) to: r topRight + (-2@2) width: self width color: self color;
		line: r topRight + (-1@3) to: r topRight + (-1@4) width: self width color: self color;
		line: r topRight + (0@5) to: r bottomRight - (0@5) width: self width color: self color;
		line: r bottomRight - (1@4) to: r bottomRight - (2@2) width: self width color: self color;
		line: r bottomRight - (3@1) to: r bottomRight - (4@1) width: self width color: self color;
		line: r bottomRight - (5@0) to: r bottomLeft + (5@0) width: self width color: self color;
		line: r bottomLeft - (-4@1) to: r bottomLeft - (-3@1) width: self width color: self color;
		line: r bottomLeft - (-2@2) to: r bottomLeft - (-1@4) width: self width color: self color;
		line: r bottomLeft - (0@5) to: r topLeft + (0@5) width: self width color: self color;
		line: r topLeft + (1@4) to: r topLeft + (1@3) width: self width color: self color;
		line: r topLeft + (2@2) to: r topLeft + (4@1) width: self width color: self color
]

{ #category : #drawing }
RoundedBorderStyle >> frameRectangle6: aRectangle on: aCanvas [
	"Draw the border for a corner radius of 6."

	|r|
	r := aRectangle insetBy: self width // 2.	
	self width odd ifTrue: [r := r insetBy: (0@0 corner: 1@1)].
	aCanvas
		line: r topLeft + (6@0) to: r topRight - (6@0) width: self width color: self color;
		line: r topRight + (-5@1) to: r topRight + (-3@2) width: self width color: self color;
		line: r topRight + (-2@3) to: r topRight + (-2@3) width: self width color: self color;
		line: r topRight + (-1@4) to: r topRight + (-1@5) width: self width color: self color;
		line: r topRight + (0@6) to: r bottomRight - (0@6) width: self width color: self color;
		line: r bottomRight - (1@5) to: r bottomRight - (2@3) width: self width color: self color;
		line: r bottomRight - (3@2) to: r bottomRight - (4@1) width: self width color: self color;
		line: r bottomRight - (5@1) to: r bottomRight - (6@0) width: self width color: self color;
		line: r bottomRight - (7@0) to: r bottomLeft + (6@0) width: self width color: self color;
		line: r bottomLeft - (-5@1) to: r bottomLeft - (-4@1) width: self width color: self color;
		line: r bottomLeft - (-3@2) to: r bottomLeft - (-3@2) width: self width color: self color;
		line: r bottomLeft - (-2@3) to: r bottomLeft - (-1@5) width: self width color: self color;
		line: r bottomLeft - (0@6) to: r topLeft + (0@6) width: self width color: self color;
		line: r topLeft + (1@5) to: r topLeft + (1@4) width: self width color: self color;
		line: r topLeft + (2@3) to: r topLeft + (2@3) width: self width color: self color;
		line: r topLeft + (3@2) to: r topLeft + (5@1) width: self width color: self color
]

{ #category : #drawing }
RoundedBorderStyle >> frameRectangle7: aRectangle on: aCanvas [
	"Draw the border for a corner radius of 7."

	|r|
	r := aRectangle insetBy: self width // 2.	
	self width odd ifTrue: [r := r insetBy: (0@0 corner: 1@1)].
	aCanvas
		line: r topLeft + (7@0) to: r topRight - (7@0) width: self width color: self color;
		line: r topRight + (-6@1) to: r topRight + (-5@1) width: self width color: self color;
		line: r topRight + (-4@2) to: r topRight + (-2@4) width: self width color: self color;
		line: r topRight + (-1@5) to: r topRight + (-1@6) width: self width color: self color;
		line: r topRight + (0@7) to: r bottomRight - (0@7) width: self width color: self color;
		line: r bottomRight - (1@6) to: r bottomRight - (1@5) width: self width color: self color;
		line: r bottomRight - (2@4) to: r bottomRight - (4@2) width: self width color: self color;
		line: r bottomRight - (5@1) to: r bottomRight - (6@1) width: self width color: self color;
		line: r bottomRight - (7@0) to: r bottomLeft + (7@0) width: self width color: self color;
		line: r bottomLeft - (-6@1) to: r bottomLeft - (-5@1) width: self width color: self color;
		line: r bottomLeft - (-4@2) to: r bottomLeft - (-2@4) width: self width color: self color;
		line: r bottomLeft - (-1@5) to: r bottomLeft - (-1@6) width: self width color: self color;
		line: r bottomLeft - (0@7) to: r topLeft + (0@7) width: self width color: self color;
		line: r topLeft + (1@6) to: r topLeft + (1@5) width: self width color: self color;
		line: r topLeft + (2@4) to: r topLeft + (4@2) width: self width color: self color;
		line: r topLeft + (5@1) to: r topLeft + (6@1) width: self width color: self color
]

{ #category : #drawing }
RoundedBorderStyle >> frameRectangle8: aRectangle on: aCanvas [
	"Draw the border for a corner radius of 8."

	|r|
	r := aRectangle insetBy: self width // 2.	
	self width odd ifTrue: [r := r insetBy: (0@0 corner: 1@1)].
	aCanvas
		line: r topLeft + (8@0) to: r topRight - (8@0) width: self width color: self color;
		line: r topRight + (-7@1) to: r topRight + (-6@1) width: self width color: self color;
		line: r topRight + (-5@2) to: r topRight + (-2@5) width: self width color: self color;
		line: r topRight + (-1@6) to: r topRight + (-1@7) width: self width color: self color;
		line: r topRight + (0@8) to: r bottomRight - (0@8) width: self width color: self color;
		line: r bottomRight - (1@7) to: r bottomRight - (1@6) width: self width color: self color;
		line: r bottomRight - (2@5) to: r bottomRight - (5@2) width: self width color: self color;
		line: r bottomRight - (6@1) to: r bottomRight - (7@1) width: self width color: self color;
		line: r bottomRight - (8@0) to: r bottomLeft + (8@0) width: self width color: self color;
		line: r bottomLeft - (-7@1) to: r bottomLeft - (-6@1) width: self width color: self color;
		line: r bottomLeft - (-5@2) to: r bottomLeft - (-2@5) width: self width color: self color;
		line: r bottomLeft - (-1@6) to: r bottomLeft - (-1@7) width: self width color: self color;
		line: r bottomLeft - (0@8) to: r topLeft + (0@8) width: self width color: self color;
		line: r topLeft + (1@7) to: r topLeft + (1@6) width: self width color: self color;
		line: r topLeft + (2@5) to: r topLeft + (5@2) width: self width color: self color;
		line: r topLeft + (6@1) to: r topLeft + (7@1) width: self width color: self color
]

{ #category : #drawing }
RoundedBorderStyle >> frameRectangle: aRectangle on: aCanvas [
	"Draw the border. Radius is the x/y offset not width 'around the corner'."
	
	self cornerRadius = 0 ifTrue: [^self frameRectangle0: aRectangle on: aCanvas].
	self cornerRadius = 1 ifTrue: [^self frameRectangle1: aRectangle on: aCanvas].
	self cornerRadius = 2 ifTrue: [^self frameRectangle2: aRectangle on: aCanvas].
	self cornerRadius = 3 ifTrue: [^self frameRectangle3: aRectangle on: aCanvas].
	self cornerRadius = 4 ifTrue: [^self frameRectangle4: aRectangle on: aCanvas].
	self cornerRadius = 5 ifTrue: [^self frameRectangle5: aRectangle on: aCanvas].
	self cornerRadius = 6 ifTrue: [^self frameRectangle6: aRectangle on: aCanvas].
	self cornerRadius = 7 ifTrue: [^self frameRectangle7: aRectangle on: aCanvas].
	self cornerRadius = 8 ifTrue: [^self frameRectangle8: aRectangle on: aCanvas].
	^super frameRectangle: aRectangle on: aCanvas.
]

{ #category : #initialization }
RoundedBorderStyle >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		cornerRadius: 0
]
