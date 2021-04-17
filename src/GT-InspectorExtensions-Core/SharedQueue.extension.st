Extension { #name : #SharedQueue }

{ #category : #'*GT-InspectorExtensions-Core' }
SharedQueue >> gtInspectorItemsIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite fastList
		title: 'Items';
		display: [ items copy ];
		format: [ :each | each displayString ]
]
