Extension { #name : #String }

{ #category : #'*NewTools-Spotter' }
String >> spotterPreview: aBuilder [

	^ aBuilder newText
		beNotEditable;
		text: self;
		yourself
]
