Extension { #name : #OupsNullException }

{ #category : #'*NewTools-Debugger-Extensions' }
OupsNullException >> stDebuggerInspectorNodesFor: aStDebuggerContext [

	^ aStDebuggerContext nullExceptionNodesFor: self
]
