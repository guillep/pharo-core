"
I toggle the stack filtering in the debugger on and off, and I trigger a debugger update.
"
Class {
	#name : #StDebuggerToggleFilterStackCommand,
	#superclass : #CmCommand,
	#category : #'NewTools-Debugger-Commands'
}

{ #category : #default }
StDebuggerToggleFilterStackCommand class >> defaultDescription [
	^'Toggle stack filtering on and off'
]

{ #category : #default }
StDebuggerToggleFilterStackCommand class >> defaultName [ 
	^'Toggle stack filtering'
]

{ #category : #executing }
StDebuggerToggleFilterStackCommand >> execute [
	StDebuggerActionModel shouldFilterStack: StDebuggerActionModel shouldFilterStack not.
	self context updateStep
]
