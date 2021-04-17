Extension { #name : #RPackageTag }

{ #category : #'*GT-InspectorExtensions-Core' }
RPackageTag >> gtInspectorDefinedClassesIn: composite [
	<gtInspectorPresentationOrder: 30>
	composite list
		title: 'Classes';
		display: #classes;
		format: #displayString
]
