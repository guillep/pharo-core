Extension { #name : #SimpleBorderStyle }

{ #category : #'*Athens-Morphic' }
SimpleBorderStyle >> asAthensPaintOn: anAthensCanvas [
	^ self topLeftColor = self bottomRightColor
		ifTrue: [ super asAthensPaintOn: anAthensCanvas ]
		ifFalse: [ self asTwoColorStrokePaintOn: anAthensCanvas ]
]

{ #category : #'*Athens-Morphic' }
SimpleBorderStyle >> asTwoColorStrokePaintOn: anAthensCanvas [
	^ AthensBorderStrokePaint
		topLeftColor: self topLeftColor
		bottomRightColor: self bottomRightColor
		width: self width
		on: anAthensCanvas
]
