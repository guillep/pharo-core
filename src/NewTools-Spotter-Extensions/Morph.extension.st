Extension { #name : #Morph }

{ #category : #'*NewTools-Spotter-Extensions' }
Morph >> spotterForKeysFor: aStep [
	<stSpotterOrder: 15>
	(self hasProperty: #kmDispatcher) ifFalse: [^self].
	self kmDispatcher spotterForKeysFor: aStep
]

{ #category : #'*NewTools-Spotter-Extensions' }
Morph >> spotterForSubmorphsFor: aStep [
	<stSpotterOrder: 10>
	self submorphs ifNil: [ ^ self ].
	
	aStep listProcessor
			title: 'Submorphs';
			allCandidates: [ self submorphs ];
			candidatesLimit: 5;
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Morph >> spotterPreview: aBuilder [

	^ aBuilder newImage 
		image: (self asFormOfSize: 300@300);
		yourself
]
