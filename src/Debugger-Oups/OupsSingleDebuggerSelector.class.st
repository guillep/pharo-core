"
I select the first available debugger in the system and try to open a debug session with that debugger.
I do not care about the possible existence of any other debugger.

I am equivalent to the debugger selection strategy encoded in MorphicUIManager prior to the integration of DebuggerSelector.
"
Class {
	#name : #OupsSingleDebuggerSelector,
	#superclass : #OupsDebuggerSelectionStrategy,
	#category : #'Debugger-Oups-Strategies'
}

{ #category : #initialization }
OupsSingleDebuggerSelector >> initialize [
	super initialize.
	handled := true
]

{ #category : #iterating }
OupsSingleDebuggerSelector >> nextDebugger [
	^ debuggers first
]

{ #category : #debuggers }
OupsSingleDebuggerSelector >> openDebuggerForSession: aDebugSession [

	[ self nextDebugger debugSession: aDebugSession ]
		on: Exception
		do: [ :err | 
			error := err.
			handled := false.
			self signalErrorHandlingErrorForSession: aDebugSession ]
]
