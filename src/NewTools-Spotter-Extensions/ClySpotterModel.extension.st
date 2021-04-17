Extension { #name : #ClySpotterModel }

{ #category : #'*NewTools-Spotter-Extensions' }
ClySpotterModel >> spotterForCommandsFor: aStep [
	<stSpotterOrder: 20>

	browser allContextsDo: [ :each | 
		self commandListProcessorForContext: each step: aStep]
]

{ #category : #'*NewTools-Spotter-Extensions' }
ClySpotterModel >> spotterForGoToFor: aStep [
	<stSpotterOrder: 10>

	aStep listProcessor
		title: 'Go to';
		allCandidates: [ self collectGoToCandidates ];
		itemName: #name;
		itemIcon: #icon;
		candidatesLimit: 10;
		filter: GTFilterSubstring;
		actLogic: [ :assoc :step | 
			step exit. 
			assoc activate ]
]
