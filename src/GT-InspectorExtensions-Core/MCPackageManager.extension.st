Extension { #name : #MCPackageManager }

{ #category : #'*GT-InspectorExtensions-Core' }
MCPackageManager >> gtDisplayOn: stream [
	stream nextPutAll: self package name
]

{ #category : #'*GT-InspectorExtensions-Core' }
MCPackageManager class >> gtInspectorManagersIn: composite [
	<gtInspectorPresentationOrder: 40>
	composite list
		title: 'Managers';
		display: [ self allManagers sorted: [ :x :y | x packageName < y packageName ] ];
		format: #packageName;
		filterOn: [ :text :each | each displayString includesSubstring: text caseSensitive: false ]
]
