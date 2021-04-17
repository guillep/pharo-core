Extension { #name : #Object }

{ #category : #'*NewTools-Inspector-Extensions' }
Object >> asInspectorModel [

	^ StInspectorModel on: self
]

{ #category : #'*NewTools-Inspector-Extensions' }
Object >> defaultObjectInspectorClass [

	^ StObjectInspectorPresenter
]

{ #category : #'*NewTools-Inspector-Extensions' }
Object >> inspectionMeta [
	<inspectorPresentationOrder: 999 title: 'Meta'>

	^ StMetaBrowser on: self
]

{ #category : #'*NewTools-Inspector-Extensions' }
Object >> inspectionMetaContext: aContext [

	aContext withoutEvaluator
]

{ #category : #'*NewTools-Inspector-Extensions' }
Object >> inspectorNodes [
	"Answer a list of attributes as nodes"
	
	^ (StNodeCollector for: self) collectNodes
]

{ #category : #'*NewTools-Inspector-Extensions' }
Object >> stDisplayString [

	[ self displayString linesDo: [ :each | ^ each contractTo: 200 ] ]
		on: Error
		do: [ :err | ^ err stDisplayString ].

	^ ''
]

{ #category : #'*NewTools-Inspector-Extensions' }
Object >> stInspect [
	"Temporary to experiment, should be replaced by inspect later"

	^ StInspector inspect: self
]
