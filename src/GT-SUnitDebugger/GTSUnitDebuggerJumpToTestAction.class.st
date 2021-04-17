"
I implement a debugging action for selecting in the stack the context containing the test  method.
  
I am only valid if the context that triggered the failed assertion is diffferent than the context containing the test method (e.g., the assertion method was called from an utility method of the test)
"
Class {
	#name : #GTSUnitDebuggerJumpToTestAction,
	#superclass : #DebugAction,
	#category : #'GT-SUnitDebugger'
}

{ #category : #actions }
GTSUnitDebuggerJumpToTestAction class >> gtDebuggerActionFor: aDebugger [
	<gtStackDebuggingAction>
	
	^ (self forDebugger: aDebugger)
]

{ #category : #testing }
GTSUnitDebuggerJumpToTestAction >> appliesToDebugger: aDebugger [

	^ aDebugger session class = GTSUnitDebugSession and: [ 
		aDebugger session assertionCallerContext notNil and: [ 
			aDebugger session testContext ~= aDebugger session assertionCallerContext ] ]
]

{ #category : #accessing }
GTSUnitDebuggerJumpToTestAction >> defaultLabel [

	^ 'Jump to test method'
]

{ #category : #accessing }
GTSUnitDebuggerJumpToTestAction >> defaultOrder [

	^ 10
]

{ #category : #actions }
GTSUnitDebuggerJumpToTestAction >> executeAction [
	self debugger stackPresentation selection: self debugger session testContext
]

{ #category : #accessing }
GTSUnitDebuggerJumpToTestAction >> help [
	^ 'Select in the stack the context containing the test method.'
]

{ #category : #accessing }
GTSUnitDebuggerJumpToTestAction >> id [

	^ GTSUnitDebuggerJumpToTestAction name
]

{ #category : #initialization }
GTSUnitDebuggerJumpToTestAction >> initialize [
	super initialize.
	self needsUpdate: false
]
