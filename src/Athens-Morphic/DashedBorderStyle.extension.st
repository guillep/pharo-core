Extension { #name : #DashedBorderStyle }

{ #category : #'*Athens-Morphic' }
DashedBorderStyle >> asAthensPaintOn: anAthensCanvas [
	^ AthensCompositeStrokePaint new fromDashedBorderStyle: self on: anAthensCanvas
]
