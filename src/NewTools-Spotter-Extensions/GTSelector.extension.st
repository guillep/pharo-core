Extension { #name : #GTSelector }

{ #category : #'*NewTools-Spotter-Extensions' }
GTSelector >> spotterImplementorsFor: aStep [
	<stSpotterOrder: 40>
	^ aStep listProcessor
		title: 'Implementors';
		filter: GTFilterSubstring item: [ :filter :context | self implementors do: filter ];
		keyBinding: $m meta
]

{ #category : #'*NewTools-Spotter-Extensions' }
GTSelector >> spotterUsersFor: aStep [
	<stSpotterOrder: 50>
	^ aStep listProcessor
		title: 'Senders';
		filter: GTFilterSubstring item: [ :filter :context | 
			self senders do: [ :sender | 
				filter value: sender compiledMethod ] ];
		keyBinding: $n meta
]
