Extension { #name : #BlockClosure }

{ #category : #'*NewTools-Inspector-Extensions' }
BlockClosure >> inspectionSourceCode [
	<inspectorPresentationOrder: 30 title: 'Source code'>

	^ self sourceNode inspectionSourceCode
]
