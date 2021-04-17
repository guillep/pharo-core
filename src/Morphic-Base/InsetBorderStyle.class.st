"
see BorderedMorph
"
Class {
	#name : #InsetBorderStyle,
	#superclass : #SimpleBorderStyle,
	#category : #'Morphic-Base-Borders'
}

{ #category : #accessing }
InsetBorderStyle >> bottomRightColor [
	"Changed from direct access to color since, if nil,
	self color is transparent."
	
	^width = 1 
		ifTrue: [self color twiceLighter]
		ifFalse: [self color lighter]
]

{ #category : #accessing }
InsetBorderStyle >> colorsAtCorners [
	| c c14 c23 |
	c := self color.
	c14 := c lighter. c23 := c darker.
	^Array with: c23 with: c14 with: c14 with: c23.
]

{ #category : #accessing }
InsetBorderStyle >> style [
	^#inset
]

{ #category : #accessing }
InsetBorderStyle >> topLeftColor [
	"Changed from direct access to color since, if nil,
	self color is transparent."
	
	^width = 1 
		ifTrue: [self color twiceDarker]
		ifFalse: [self color darker]
]

{ #category : #'color tracking' }
InsetBorderStyle >> trackColorFrom: aMorph [
	baseColor ifNil:[self color: aMorph insetColor].
]
