Extension { #name : #Class }

{ #category : #'*NewTools-Spotter-Extensions' }
Class >> spotterClassMethodsFor: aStep [
	<stSpotterOrder: 15>
	aStep listProcessor
			title: 'Class methods';
			allCandidates: [ self classSide methods ];
			itemName: [ :method | method selector ];
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Class >> spotterMethodsFor: aStep [
	<stSpotterOrder: 10>
	aStep listProcessor
			title: 'Instance methods';
			allCandidates: [ self methods ];
			itemName: [ :method | method selector ];
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Class >> spotterReferenceFor: aStep [
	<stSpotterOrder: 30>
	aStep listProcessor
			title: 'References';
			allCandidates: [ (SystemNavigation default allReferencesTo: self binding) collect: [:each | each compiledMethod ] ];
			itemName: [ :method | method displayString ];
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Class >> spotterSuperClassMethodsFor: aStep [
	<stSpotterOrder: 16>
	|superclasses|
	superclasses := self class withAllSuperclasses select: #isMeta.
	aStep listProcessor
			title: 'Super class methods';
			allCandidates: [ self classSide allMethods select: [ :each |(each methodClass = self classSide) not & (superclasses includes: each methodClass) ] ];
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Class >> spotterSuperMethodsFor: aStep [
	<stSpotterOrder: 11>
	aStep listProcessor
			title: 'Super instance methods';
			allCandidates: [ self allMethods reject: [ :each | each methodClass = self ] ];
			filter: GTFilterSubstring
]
