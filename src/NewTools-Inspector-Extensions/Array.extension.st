Extension { #name : #Array }

{ #category : #'*NewTools-Inspector-Extensions' }
Array >> displayString [

	^ super displayString contractTo: 200
]
