Extension { #name : #SettingNode }

{ #category : #'*NewTools-Spotter-Extensions' }
SettingNode >> spotterForSettingsFor: aStep [
	<stSpotterOrder: 0>
	self allChildren isEmpty ifTrue: [ ^ self ].
	aStep listProcessor
		title: 'Children';
		allCandidates: [ self allChildren ];
		itemName: [ :each | each spotterLabel ];
		filter: GTFilterSubstring
]
