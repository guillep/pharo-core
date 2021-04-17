Extension { #name : #MetacelloVersion }

{ #category : #'*NewTools-Spotter-Extensions' }
MetacelloVersion >> spotterForGroupsFor: aStep [
	<stSpotterOrder: 2>
	aStep listProcessor
		title: 'Groups';
		allCandidates: [ self groups ];
		itemName: [ :item | item name ];
		filter: GTFilterSubstring;
		wantsToDisplayOnEmptyQuery: true
]

{ #category : #'*NewTools-Spotter-Extensions' }
MetacelloVersion >> spotterForPackagesFor: aStep [
	<stSpotterOrder: 3>
	aStep listProcessor
		title: 'Packages';
		allCandidates: [ self packages ];
		itemName: [ :item | item file ];
		filter: GTFilterSubstring;
		wantsToDisplayOnEmptyQuery: true
]
