"
I am a command to add once breakpoint into particular source node.
"
Class {
	#name : #ClyAddOnceBreakpointCommand,
	#superclass : #ClyAddBreakpointCommand,
	#category : #'Calypso-SystemPlugins-Reflectivity-Browser-Breakpoints'
}

{ #category : #execution }
ClyAddOnceBreakpointCommand >> applyBreakpointCondition: aBreakpoint [
	aBreakpoint once
]

{ #category : #accessing }
ClyAddOnceBreakpointCommand >> defaultMenuItemName [ 
	^'Add Breakpoint once'
]
