Extension { #name : #MetacelloProject }

{ #category : #'*NewTools-Spotter-Extensions' }
MetacelloProject >> spotterForVersionsFor: aStep [
	<stSpotterOrder: 1>
	self flag: #maybeRewriteForDirectStreaming.
	aStep listProcessor
		title: 'Versions';
		allCandidates: [
			(#( stableVersion currentVersion bleedingEdge development ) 
				collect: [ :each | [ self perform: each ] on: Error do: [  nil ] ]) 
				reject: [ :each | each isNil ] ];
		itemName: [ :version | version versionString ];
		filter: GTFilterSubstring;
		wantsToDisplayOnEmptyQuery: true
]
