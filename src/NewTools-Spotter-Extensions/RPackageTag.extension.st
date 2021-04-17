Extension { #name : #RPackageTag }

{ #category : #'*NewTools-Spotter-Extensions' }
RPackageTag >> spotterClassesFor: aStep [
	<stSpotterOrder: 20>
	aStep listProcessor
			allCandidates: [ self classes sorted: [ :a :b | a name < b name ] ];
			title: 'Classes';
			filter: GTFilterSubstring
]
