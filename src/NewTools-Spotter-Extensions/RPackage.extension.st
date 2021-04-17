Extension { #name : #RPackage }

{ #category : #'*NewTools-Spotter-Extensions' }
RPackage >> spotterClassesFor: aStep [
	<stSpotterOrder: 20>
	aStep listProcessor
			allCandidates: [ self definedClasses sorted: [ :a :b | a name < b name ] ];
			title: 'Classes';
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
RPackage >> spotterExtensionMethodsFor: aStep [
	<stSpotterOrder: 30>
	aStep listProcessor
			allCandidates: [ self extensionMethods ];
			title: 'Extension Methods';
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
RPackage >> spotterMonticelloPackageFor: aStep [
	<stSpotterOrder: 41>
	aStep listProcessor
		title: 'Monticello Package';
		allCandidates: [ self mcPackage 
			ifNotNil: [ :mcPackage | Array with: mcPackage ] 
			ifNil: [ #() ] ];
		itemIcon: [ Smalltalk ui icons iconNamed: #monticelloPackageIcon ];
		filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
RPackage >> spotterMonticelloWorkingCopyFor: aStep [
	<stSpotterOrder: 42>
	aStep listProcessor
		title: 'Monticello Working Copy';
		allCandidates: [ self mcPackage 
			ifNotNil: [ :mcPackage | Array with: mcPackage workingCopy ] 
			ifNil: [ #() ] ];
		itemIcon: [ Smalltalk ui icons iconNamed: #versionControlIcon ];
		filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
RPackage >> spotterTagsFor: aStep [
	<stSpotterOrder: 20>
	self classTags size <= 1 ifTrue: [ ^ self ].
	aStep listProcessor
			allCandidates: [ self classTags sorted: [ :a :b | a name < b name ] ];
			title: 'Tags';
			itemName: [ :item | item name ];
			filter: GTFilterSubstring
]
