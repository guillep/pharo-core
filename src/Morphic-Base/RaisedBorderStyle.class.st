"
see BorderedMorph
"
Class {
	#name : #RaisedBorderStyle,
	#superclass : #SimpleBorderStyle,
	#category : #'Morphic-Base-Borders'
}

{ #category : #accessing }
RaisedBorderStyle >> bottomRightColor [
	"Changed from direct access to color since, if nil,
	self color is transparent."
	
	^width = 1 
		ifTrue: [self color twiceDarker]
		ifFalse: [self color darker]
]

{ #category : #accessing }
RaisedBorderStyle >> colorsAtCorners [
	| c c14 c23 |
	c := self color.
	c14 := c lighter. c23 := c darker.
	^Array with: c14 with: c23 with: c23 with: c14
]

{ #category : #accessing }
RaisedBorderStyle >> style [
	^#raised
]

{ #category : #accessing }
RaisedBorderStyle >> topLeftColor [
	"Changed from direct access to color since, if nil,
	self color is transparent."

	^width = 1 
		ifTrue: [self color twiceLighter]
		ifFalse: [self color lighter]
]

{ #category : #'color tracking' }
RaisedBorderStyle >> trackColorFrom: aMorph [
	baseColor ifNil:[self color: aMorph raisedColor].
]
