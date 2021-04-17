"
I am a simple wrapper holding the current context and the current debug session in a debugger.
My purpose is only to display context and debug session related information in the debugger inspector.
"
Class {
	#name : #StDebuggerContext,
	#superclass : #Object,
	#instVars : [
		'context',
		'exception'
	],
	#category : #'NewTools-Debugger-Model'
}

{ #category : #'instance creation' }
StDebuggerContext class >> context: aContext [

	^ self new
		  context: aContext;
		  yourself
]

{ #category : #accessing }
StDebuggerContext >> buildInspectorNodes [

	| nodes argsNodes tempsNodes tempsAndArgs |
	nodes := OrderedCollection new.
	tempsAndArgs := self temporaryVariablesNodes.
	argsNodes := tempsAndArgs select: [ :tempNode | tempNode tempVariable isArgumentVariable ].
	tempsNodes := tempsAndArgs select: [ :tempNode | tempNode tempVariable isTempVariable ].
	nodes add: self selfNode.
	nodes addAll: argsNodes.
	nodes addAll: tempsNodes.
	nodes addAll: self receiverNodes.
	nodes add: self stackTopNode.
	nodes add: self thisContextNode.
	nodes addAll: self exceptionNodes.
	^ nodes
]

{ #category : #accessing }
StDebuggerContext >> context [

	^ context ifNil: [ context := [] asContext ]
]

{ #category : #accessing }
StDebuggerContext >> context: anObject [
	context := anObject
]

{ #category : #building }
StDebuggerContext >> doesNotUnderstandNodesFor: anException [

	^ (self exceptionNodesFor: anException)
		  add: (StInspectorDynamicNode
				   hostObject: anException receiver
				   label: 'DNU receiver'
				   value: anException receiver);
		  yourself
]

{ #category : #accessing }
StDebuggerContext >> exception [
	^ exception ifNil:[exception := OupsNullException new]
]

{ #category : #accessing }
StDebuggerContext >> exception: anException [
	exception := anException 
]

{ #category : #nodes }
StDebuggerContext >> exceptionNodes [

	^ self exception stDebuggerInspectorNodesFor: self
]

{ #category : #building }
StDebuggerContext >> exceptionNodesFor: anException [

	^ OrderedCollection new
		  add: (StInspectorDynamicNode
				   hostObject: anException
				   label: 'Exception'
				   value: anException);
		  yourself
]

{ #category : #building }
StDebuggerContext >> nullExceptionNodesFor: anException [

	^ #(  )
]

{ #category : #printing }
StDebuggerContext >> printOn: aStream [
	aStream nextPutAll: context asString 
]

{ #category : #nodes }
StDebuggerContext >> receiverNodes [

	^ self context receiver allInspectorNodes reject: [ :node | 
		  node label = 'self' ]
]

{ #category : #nodes }
StDebuggerContext >> selfNode [

	^ StInspectorSelfNode hostObject: self context receiver
]

{ #category : #nodes }
StDebuggerContext >> stackTopNode [
	^StInspectorStackTopNode hostObject: self context
]

{ #category : #nodes }
StDebuggerContext >> temporaryVariablesNodes [

	^ self context astScope allTemps collect: [ :temp | 
		  (StInspectorTempNode hostObject: self context) tempVariable: temp ]
]

{ #category : #nodes }
StDebuggerContext >> thisContextNode [ 
	^StInspectorThisContextNode hostObject: self context
]
