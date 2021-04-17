Extension { #name : #HelpTopic }

{ #category : #'*NewTools-Spotter-Extensions' }
HelpTopic >> spotterForHelpTopicFor: aStep [
	<stSpotterOrder: 200>
	self flag: 'filter for multiple items like #title + #contents (combined by OR)'.
	self flag: #specialFilter.
	aStep listProcessor 
		title: 'Help contents';
		items: [ self subtopics ];
		itemName: [ :helpTopic | helpTopic title ];
		itemIcon: [ :helpTopic | helpTopic gtTopicIcon ];
		filter: GTFilterSubstrings;
		wantsToDisplayOnEmptyQuery: true
]
