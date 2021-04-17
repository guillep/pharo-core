Extension { #name : #RPackage }

{ #category : #'*GT-InspectorExtensions-Core' }
RPackage >> gtInspectorDefinedClassesIn: composite [
	<gtInspectorPresentationOrder: 30>
	composite list
		title: 'Classes';
		display: #classes;
		format: #displayString;
		tags: [ :each | each category ]
]

{ #category : #'*GT-InspectorExtensions-Core' }
RPackage >> gtInspectorTagsIn: composite [
	<gtInspectorPresentationOrder: 40>
	composite list
		title: 'Tags';
		display: #classTags;
		format: #displayString;
		when: [ self classTags notEmpty ]
]
