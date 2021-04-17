Extension { #name : #MCWorkingCopy }

{ #category : #'*NewTools-Spotter-Extensions' }
MCWorkingCopy >> spotterAllRepositoriesFor: aStep [
	<stSpotterOrder: 20>
	aStep listProcessor
		title: 'All other repositories';
		allCandidates: [ MCRepositoryGroup default repositories \ self repositoryGroup repositories ];
		itemName: [ :item | item description ];
		actLogic: [ :item :step | 
			step exit.
			self spotterCommit: self in: item ];
		filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
MCWorkingCopy >> spotterAncestorsFor: aStep [
	<stSpotterOrder: 2>
	self flag: #maybeRewriteForDirectStreaming.
	aStep listProcessor
		title: 'Ancestors';
		allCandidates: [ self allAncestors ];
		filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
MCWorkingCopy >> spotterMonticelloPackageFor: aStep [
	<stSpotterOrder: 21>
	aStep listProcessor
		title: 'Monticello Package';
		allCandidates: [ Array with: self package ];
		itemIcon: [ Smalltalk ui icons iconNamed: #monticelloPackageIcon ];
		filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
MCWorkingCopy >> spotterPackageFor: aStep [
	<stSpotterOrder: 21>
	self flag: #maybeRewriteForDirectStreaming.
	aStep listProcessor
		title: 'Packages';
		allCandidates: [ self package correspondingRPackage 
			ifNotNil: [ :rpackage | { rpackage } ] 
			ifNil: [ { } ] ];
		itemName: [ :item | item name ];
		itemIcon: [ Smalltalk ui icons iconNamed: #packageIcon ];
		filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
MCWorkingCopy >> spotterPackageRepositoriesFor: aStep [
	<stSpotterOrder: 10>
	aStep listProcessor
		title: 'Package repositories';
		allCandidates: [ self repositoryGroup repositories ];
		itemName: [ :item | item description ];
		actLogic: [ :item :step |
			step exit.
			self spotterCommit: self in: item ];
		filter: GTFilterSubstring
]
