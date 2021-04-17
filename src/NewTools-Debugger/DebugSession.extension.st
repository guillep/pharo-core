Extension { #name : #DebugSession }

{ #category : #'*NewTools-Debugger' }
DebugSession >> application [

	^ nil
]

{ #category : #'*NewTools-Debugger' }
DebugSession >> application: anApplication [
]

{ #category : #'*NewTools-Debugger' }
DebugSession >> spanNewSession [

	^ (self class 
		named: self name 
		on: self interruptedProcess 
		startedAt: self interruptedContext)
			errorWasInUIProcess: self errorWasInUIProcess;
			yourself
]
