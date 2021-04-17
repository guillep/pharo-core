Extension { #name : #Pragma }

{ #category : #'*GT-InspectorExtensions-Core' }
Pragma >> gtDisplayOn: stream [
	self method displayStringOn: stream.
	stream space.
	self printOn: stream
]

{ #category : #'*GT-InspectorExtensions-Core' }
Pragma class >> gtInspectorAnnotatedMethodsIn: composite [
	<gtInspectorPresentationOrder: 30> 
	composite table 
		title: 'All';
		showOnly: 50;
		withSmalltalkSearch;
		display: [:anObject | 
			| pragmas |
			pragmas := OrderedCollection new.
			Object withAllSubclassesDo: [:each |
				 each pragmasDo: [:p |
					pragmas add: p]].
			(pragmas groupedBy: #selector) associations sorted: [ :a :b | 
				a key < b key ]
		];
		column: 'Keyword' evaluated: [ :each | each key ];
		column: 'Instances' evaluated: [ :each | each value size asString ];
		send: #value
]

{ #category : #'*GT-InspectorExtensions-Core' }
Pragma >> gtInspectorSourceIn: composite [
	<gtInspectorPresentationOrder: 30> 
	self method gtInspectorSourceIn: composite
]
