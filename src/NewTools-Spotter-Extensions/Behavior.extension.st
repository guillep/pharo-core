Extension { #name : #Behavior }

{ #category : #'*NewTools-Spotter-Extensions' }
Behavior >> spotterClassInstanceVariablesFor: aStep [
	<stSpotterOrder: 25>
	self isTrait
		ifTrue: [ ^ self ].
	aStep listProcessor
		title: 'Class instance variables';
		allCandidates: [ self class classLayout allSlots ];
		itemName: [ :each | each name asString ];
		filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Behavior >> spotterCompositionFor: aStep [
	<stSpotterOrder: 25>
	aStep listProcessor
			title: 'Composing traits';
			allCandidates: [ self allTraits ];
			itemIcon: #systemIcon;
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Behavior >> spotterInstanceVariablesFor: aStep [
	<stSpotterOrder: 20>
	self isTrait
		ifTrue: [ ^ self ].
	aStep listProcessor
		title: 'Instance variables';
		allCandidates: [ self classLayout allSlots ];
		itemName: [ :each | each name asString ];
		filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Behavior >> spotterSubclassesFor: aStep [
	<stSpotterOrder: 50>
	aStep listProcessor
			title: 'All subclasses';
			allCandidates: [ self allSubclasses ];
			itemIcon: #systemIcon;
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Behavior >> spotterSuperclassesFor: aStep [
	<stSpotterOrder: 40>
	aStep listProcessor
			title: 'All superclasses';
			allCandidates: [ self allSuperclasses ];
			itemIcon: #systemIcon;
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Behavior >> spotterTraitUsersFor: aStep [
	<stSpotterOrder: 20>
	self isTrait ifFalse: [ ^ self ].
	aStep listProcessor
			title: 'Users';
			allCandidates: [ self traitUsers asArray ];
			itemIcon: #systemIcon;
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Behavior >> spotterUsedSlotsFor: aStep [
	<stSpotterOrder: 70>
	aStep listProcessor
			title: 'Full Definition Slots';
			allCandidates: [ self slots select: [ :slot | slot needsFullDefinition ] ];
			itemName: [ :item | item definitionString ];
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
Behavior >> spotterUsedTraitsFor: aStep [
	<stSpotterOrder: 60>
	aStep listProcessor
			title: 'Uses Traits';
			allCandidates: [ self traits asArray ];
			itemIcon: #systemIcon;
			filter: GTFilterSubstring
]
