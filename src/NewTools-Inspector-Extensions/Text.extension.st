Extension { #name : #Text }

{ #category : #'*NewTools-Inspector-Extensions' }
Text >> inspectionText [
	<inspectorPresentationOrder: 0 title: 'Text'>

	^ SpMorphPresenter new 
		morph: (RubScrolledTextMorph new 
			setText: self;
			in: [ :this | this textArea readOnly: true ];
			yourself);
		yourself
]
