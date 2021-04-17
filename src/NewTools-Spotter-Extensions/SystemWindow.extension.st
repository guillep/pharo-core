Extension { #name : #SystemWindow }

{ #category : #'*NewTools-Spotter-Extensions' }
SystemWindow >> spotterWindowsFor: aStep [
	<stSpotterOrder: 100>

	aStep listProcessor
			title: 'Windows';
			allCandidates: [ self class allSubInstances ];
			itemName: [ :window | '**', window label, '**' ];
			filter: GTFilterSubstring
]
