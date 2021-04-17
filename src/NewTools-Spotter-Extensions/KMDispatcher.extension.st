Extension { #name : #KMDispatcher }

{ #category : #'*NewTools-Spotter-Extensions' }
KMDispatcher >> spotterForKeysFor: aStep [
	<stSpotterOrder: 15>
		
	aStep listProcessor
			title: 'Keys';
			allCandidates: [ (self gtAllKeyCategoryPairs collect: [:each | each key]) asOrderedCollection ];
			itemName: [ :aKeymap | 
				aKeymap shortcut displayString, 
				(aKeymap name ifNil: [ '' ] ifNotNil: [ ' [', aKeymap name,']' ]) ];
			candidatesLimit: 5;
			filter: GTFilterSubstrings
]
