Extension { #name : #MessageNotUnderstood }

{ #category : #'*NewTools-Debugger-Extensions' }
MessageNotUnderstood >> stDebuggerInspectorNodesFor: aStDebuggerContext [

	^ aStDebuggerContext doesNotUnderstandNodesFor: self
]
