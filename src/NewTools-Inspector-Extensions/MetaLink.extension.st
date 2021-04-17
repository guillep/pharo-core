Extension { #name : #MetaLink }

{ #category : #'*NewTools-Inspector-Extensions' }
MetaLink >> inpectionDefiniton [
	<inspectorPresentationOrder: 920 title: 'Definition'>
	^ SpTextPresenter new 
		text: (self definitionString);
		yourself
]
