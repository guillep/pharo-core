Extension { #name : #Dictionary }

{ #category : #'*NewTools-Spotter-Extensions' }
Dictionary >> spotterForKeysFor: aStep [
	<stSpotterOrder: 15>
	aStep listProcessor
			title: 'Keys';
			allCandidates: [ self keys ];
			candidatesLimit: 5;
			filter: GTFilterSubstring
]
