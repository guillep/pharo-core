Extension { #name : #GTSpotterPragmaBasedProcessor }

{ #category : #'*GT-Spotter-UI' }
GTSpotterPragmaBasedProcessor >> render: anObject [
	^ GTSpotterItemBrick new
		icon: (nil);
		text: (anObject displayString)
]
