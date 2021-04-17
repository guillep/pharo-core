Extension { #name : #Exception }

{ #category : #'*NewTools-Debugger-Extensions' }
Exception >> signalContext [

	^ signalContext
]

{ #category : #'*NewTools-Debugger-Extensions' }
Exception >> stDebuggerInspectorNodesFor: aStDebuggerContext [

	^ aStDebuggerContext exceptionNodesFor: self
]
