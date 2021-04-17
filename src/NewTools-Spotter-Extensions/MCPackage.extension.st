Extension { #name : #MCPackage }

{ #category : #'*NewTools-Spotter-Extensions' }
MCPackage >> spotterForPackageFor: aStep [
	<stSpotterOrder: 2>
	aStep listProcessor
		title: 'Packages';
		allCandidates: [ Array with: self correspondingRPackage ];
		itemName: [ :package | package name ];
		itemIcon: [ Smalltalk ui icons iconNamed: #packageIcon ];
		filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
MCPackage >> spotterMonticelloWorkingCopyFor: aStep [
	<stSpotterOrder: 1>
	aStep listProcessor
		title: 'Monticello Working Copy';
		allCandidates: [ Array with: self workingCopy ];
		itemIcon: [ Smalltalk ui icons iconNamed: #versionControlIcon ];
		filter: GTFilterSubstring
]
