Extension { #name : #SettingTree }

{ #category : #'*NewTools-Spotter-Extensions' }
SettingTree >> spotterForSettingsFor: aStep [
	<stSpotterOrder: 0>
	aStep listProcessor
		title: 'Settings';
		allCandidates: [ self nodeList ];
		itemName: [ :each | each spotterLabel ];
		filter: GTFilterSubstring
]
