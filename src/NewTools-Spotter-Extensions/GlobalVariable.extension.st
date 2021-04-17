Extension { #name : #GlobalVariable }

{ #category : #'*NewTools-Spotter-Extensions' }
GlobalVariable >> spotterClassFor: aStep [
	<stSpotterOrder: 50>
	aStep listProcessor
			title: 'Class';
			allCandidates: [ { self value class }];
			itemIcon: #systemIcon;
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
GlobalVariable >> spotterForReferencesFor: aStep [
	<stSpotterOrder: 130>
	aStep listProcessor
			title: 'References';
			allCandidates: [ (SystemNavigation default allReferencesTo: self) collect: [:each | each compiledMethod] ];
			itemName: [ :method | method displayString ];
			filter: GTFilterSubstring
]
