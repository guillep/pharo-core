Extension { #name : #MetacelloAbstractPackageSpec }

{ #category : #'*NewTools-Spotter-Extensions' }
MetacelloAbstractPackageSpec >> spotterForIncludesFor: aStep [
	<stSpotterOrder: 1>
	aStep listProcessor
		title: 'Includes';
		allCandidates: [ self includes ];
		itemName: [ :item | item name ];
		filter: GTFilterSubstring;
		wantsToDisplayOnEmptyQuery: true
]

{ #category : #'*NewTools-Spotter-Extensions' }
MetacelloAbstractPackageSpec >> spotterForRequiresFor: aStep [
	<stSpotterOrder: 2>
	aStep listProcessor
		title: 'Requires';
		allCandidates: [ self requires ];
		itemName: [ :item | item name ];
		filter: GTFilterSubstring;
		wantsToDisplayOnEmptyQuery: true
]
