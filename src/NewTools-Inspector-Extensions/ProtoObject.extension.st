Extension { #name : #ProtoObject }

{ #category : #'*NewTools-Inspector-Extensions' }
ProtoObject >> allInspectorNodes [
	"Answer a list of attributes as nodes"

	^ { StInspectorSelfNode hostObject: self }, 
		self inspectorNodes
]

{ #category : #'*NewTools-Inspector-Extensions' }
ProtoObject >> inspectionContexts [
	"This is a utility method that collects all presentations for the current object.
	By default, it simply looks for the #gtInspectorPresentationOrder: pragma.
	The inspector can decice whether or not a presentation should be dispayed.
	Subclasses might want to override it for more special behavior."

	^ (StInspectionCollector on: self) collectInspectionContexts
]

{ #category : #'*NewTools-Inspector-Extensions' }
ProtoObject >> inspectionRaw [
	"This is the most basic presentation showing the state of the object"
	<inspectorPresentationOrder: 900 title: 'Raw'>

	^ StRawInspection on: self
]

{ #category : #'*NewTools-Inspector-Extensions' }
ProtoObject >> inspectorNodes [

	^ (self class allInstVarNames 
		collectWithIndex: [ :ivName :index | 
			StInspectorProtoObjectNode 
				hostObject: self index: index 
				slotName: ivName ]) 
		sort: [ :aNode :anotherNode | aNode label < anotherNode label ]
]

{ #category : #'*NewTools-Inspector-Extensions' }
ProtoObject >> inspectorPerform: aSymbol [
	"This method is required by the inspector infrastructure (in order to inspect properly 
	 ProtoObject and its direct decendants). 
	 DO NOT USE IT!"
	
	<primitive: 83>
	^ self primitiveFailed
]

{ #category : #'*NewTools-Inspector-Extensions' }
ProtoObject >> inspectorPerform: aSymbol with: anObject [
	"This method is required by the inspector infrastructure (in order to inspect properly 
	 ProtoObject and its direct decendants). 
	 DO NOT USE IT!"
	
	<primitive: 83>
	^ self primitiveFailed
]
