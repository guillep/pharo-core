Extension { #name : #CompositeBorderStyle }

{ #category : #'*Athens-Morphic' }
CompositeBorderStyle >> asAthensPaintOn: anAthensCanvas [
	^ AthensCompositeStrokePaint new fromBorderStyles: borders on: anAthensCanvas
]
