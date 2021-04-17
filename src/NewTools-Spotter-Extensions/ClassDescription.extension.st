Extension { #name : #ClassDescription }

{ #category : #'*NewTools-Spotter-Extensions' }
ClassDescription >> spotterPackageFor: aStep [
	<stSpotterOrder: 50>
	aStep listProcessor
			title: 'Package';
			allCandidates: [ {self package} ];
			itemName: [ :item | item packageName ];
			itemIcon: #systemIcon;
			filter: GTFilterSubstring
]
