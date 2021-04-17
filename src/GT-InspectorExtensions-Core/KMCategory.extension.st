Extension { #name : #KMCategory }

{ #category : #'*GT-InspectorExtensions-Core' }
KMCategory >> gtDisplayOn: stream [
	super displayStringOn: stream.
	^ stream
		nextPut: $(;
		nextPutAll: self name asString;
		nextPut: $)
]

{ #category : #'*GT-InspectorExtensions-Core' }
KMCategory >> gtInspectorMappingsIn: composite [
	<gtInspectorPresentationOrder: 40>
	composite list
		title: 'Keys';
		display: [ self allEntries keymaps ];
		filterOn: [ :text :each | each displayString includesSubstring: text caseSensitive: false ];
		format: #displayString;
		when: [ self allEntries keymaps notEmpty ]
]
