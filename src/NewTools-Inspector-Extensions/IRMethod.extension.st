Extension { #name : #IRMethod }

{ #category : #'*NewTools-Inspector-Extensions' }
IRMethod >> inpectionIr [
	<inspectorPresentationOrder: 40 title: 'Symbolic'>

	^ SpTextPresenter new 
		text: (self ir longPrintString trimmed);
		yourself
]
