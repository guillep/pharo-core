"
I am a command to add static breakpoint into particular source node.
"
Class {
	#name : #ClyAddStaticBreakpointCommand,
	#superclass : #ClyAddBreakpointCommand,
	#category : #'Calypso-SystemPlugins-Reflectivity-Browser-Breakpoints'
}

{ #category : #activation }
ClyAddStaticBreakpointCommand class >> methodEditorLeftBarClickActivation [
	<classAnnotation>
	
	^CmdTextLeftBarClickActivation for: ClyMethodSourceCodeContext 
]

{ #category : #execution }
ClyAddStaticBreakpointCommand >> applyBreakpointCondition: aBreakpoint [
	aBreakpoint always
]

{ #category : #accessing }
ClyAddStaticBreakpointCommand >> defaultMenuItemName [ 
	^'Add Breakpoint'
]
