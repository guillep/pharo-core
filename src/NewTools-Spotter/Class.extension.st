Extension { #name : #Class }

{ #category : #'*NewTools-Spotter-Extensions' }
Class >> spotterPreview: aBuilder [

	^ aBuilder newCode
		beForScripting;
		beNotEditable;
		text: self definitionString;
		yourself
]
