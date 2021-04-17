Extension { #name : #GTInspector }

{ #category : #'*NewTools-Spotter-Extensions' }
GTInspector class >> spotterExtensionsFor: aStep [
	<stSpotterOrder: 50>
	aStep listProcessor
			allCandidates: [ self inspectorExtendingMethods ];
			title: 'Extensions';
			itemName:[ :each | each displayString ];
			filter: GTFilterSubstring;
			wantsToDisplayOnEmptyQuery: true
]
