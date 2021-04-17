Extension { #name : #Collection }

{ #category : #'*NewTools-Spotter-Extensions' }
Collection >> spotterItemsFor: aStep [
	<stSpotterOrder: 10>
	| processor |

	(self isEmpty or: [ self size > self gtCollectionSizeThreshold ]) ifTrue: [ ^ self ].
	processor := aStep previousProcessorFrom: self.
	^ aStep listProcessor
		title: processor title;
		candidatesLimit: 100;
		items: [ self collect: [ :each | each asStSpotterCandidateLink value ] as: OrderedCollection ];
		itemName: processor itemName;
		itemIcon: processor itemIcon;
		actLogic: processor actLogic; 
		filter: processor filter gtListFilter;
		wantsToDisplayOnEmptyQuery: true
]
