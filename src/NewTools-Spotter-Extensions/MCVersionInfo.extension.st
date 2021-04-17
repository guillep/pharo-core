Extension { #name : #MCVersionInfo }

{ #category : #'*NewTools-Spotter-Extensions' }
MCVersionInfo >> spotterAncestorsFor: aStep [
	<stSpotterOrder: 1>
	self flag: 'rewrite for direct streaming - get rid of recursion'.
	aStep listProcessor
		title: 'Ancestors';
		allCandidates: [ self allAncestors ];
		filter: GTFilterSubstring
]
