Class {
	#name : #StInspectorProtoObjectNode,
	#superclass : #StInspectorNode,
	#instVars : [
		'index',
		'slotName'
	],
	#category : #'NewTools-Inspector-Model'
}

{ #category : #'instance creation' }
StInspectorProtoObjectNode class >> hostObject: anObject index: index slotName: aSlotName [

	^ (self hostObject: anObject)
		index: index slotName: aSlotName;
		yourself
]

{ #category : #accessing }
StInspectorProtoObjectNode >> index: anIndex slotName: aSlotName [

	index := anIndex.
	slotName := aSlotName
]

{ #category : #accessing }
StInspectorProtoObjectNode >> key [

	^ slotName
]

{ #category : #accessing }
StInspectorProtoObjectNode >> rawValue [

	^ thisContext 
		object: self hostObject 
		instVarAt: index
]

{ #category : #accessing }
StInspectorProtoObjectNode >> variableTag [

	^ 'attribute'
]
