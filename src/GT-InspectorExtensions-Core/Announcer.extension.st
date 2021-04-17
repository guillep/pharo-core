Extension { #name : #Announcer }

{ #category : #'*GT-InspectorExtensions-Core' }
Announcer >> gtInspectorAnnouncementsIn: composite context: aGTContext [
	<gtInspectorPresentationOrder: 40>
	| recordedAnnouncements messageSend |
	
	recordedAnnouncements := CollectionValueHolder value: OrderedCollection new.
	messageSend := MessageSend receiver: recordedAnnouncements selector: #addAnnouncementFirst:.
	self
		when: Announcement
		send: #cull:
		to: messageSend.
	aGTContext when: GLMBrowserClosing do: [ self unsubscribe: messageSend ].
	composite table
		title: 'Announcements';
		display: [ recordedAnnouncements value ];
		column: 'Time' evaluated: #key;
		column: 'Announcement' evaluated: #value;
		send: #value;
		showOnly: 50;
		format: #displayString;
		filterOn: [:text :each | Smalltalk compiler receiver: each; evaluate: '| date each | date := self key. each := self value. ', text ];
		updateOn: Announcement from: recordedAnnouncements gtAnnouncer;
		act: [ :table | 
			recordedAnnouncements removeAll.
			table update ] 
			icon: GLMUIThemeExtraIcons glamorousCancel 
			entitled: 'Reset'
]

{ #category : #'*GT-InspectorExtensions-Core' }
Announcer >> gtInspectorSubscriptionsIn: composite [
	<gtInspectorPresentationOrder: 30>
	composite table
		title: [ 'Subscriptions' translated ];
		display: [ self subscriptions subscriptions ];
		when: [ self numberOfSubscriptions isZero not ];
		beMultiple;
		column: 'Subscriber' evaluated: [ :each | each subscriber asString ];
		column: 'Announcement' evaluated: [ :each | each announcementClass printString ];
		column: 'Kind' evaluated: [ :each | each class name ];
		addAction: (GLMGenericAction new
				action: [ :table | self subscriptions reset. table update ]; 
				iconName: #glamorousCancel;
				title: 'Reset All(!)' translated;
				shouldShowTitle: true);
		selectionAct: [ :table | 
				table selection do: [ :eachSelection | 
					self subscriptions remove: eachSelection ].
				table update ] 
			iconName: #glamorousCancel
			entitled: 'Reset subscription(s)' translated
]
