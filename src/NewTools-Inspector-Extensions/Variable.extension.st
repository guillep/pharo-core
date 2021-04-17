Extension { #name : #Variable }

{ #category : #'*NewTools-Inspector-Extensions' }
Variable >> inspectionUsingMethods [
	<inspectorPresentationOrder: 920 title: 'Using Methods'>
	
	| usingMethods |
	usingMethods := self usingMethods sort: [ :x :y | x name < y name ].

	^ SpTreeTablePresenter new
		  roots: usingMethods;
		  addColumn: (SpStringTableColumn title: 'Using Methods' evaluated: #name)
]
