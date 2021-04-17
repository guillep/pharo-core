Extension { #name : #GTSpotter }

{ #category : #'*NewTools-Spotter-Extensions' }
GTSpotter class >> spotterExtensionsFor: aStep [
	<stSpotterOrder: 50>
	aStep listProcessor
			allCandidates: [ self spotterExtendingMethods ];
			title: 'Extensions';
			itemName:[ :each | each displayString ];
			filter: GTFilterSubstring;
			wantsToDisplayOnEmptyQuery: true
]
