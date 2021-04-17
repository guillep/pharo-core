Extension { #name : #KMKeymap }

{ #category : #'*GT-InspectorExtensions-Core' }
KMKeymap >> gtDisplayOn: aStream [
	aStream 
		nextPutAll: self name displayString;
		nextPutAll: ' on ';
		nextPutAll: self shortcut displayString;
		nextPutAll: ' do ' ;
		nextPutAll: self action displayString
]

{ #category : #'*GT-InspectorExtensions-Core' }
KMKeymap >> gtInspectorSourceCodeIn: composite [
	<gtInspectorPresentationOrder: 30> 

	^ self action gtInspectorSourceCodeIn: composite
]
