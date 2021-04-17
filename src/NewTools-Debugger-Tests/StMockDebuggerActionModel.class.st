"
I'm used to mock certain aspects of the `StDebuggerActionModel` class for testing.
"
Class {
	#name : #StMockDebuggerActionModel,
	#superclass : #StDebuggerActionModel,
	#instVars : [
		'tag',
		'interruptedContext'
	],
	#category : #'NewTools-Debugger-Tests-Utils'
}

{ #category : #'debug - session' }
StMockDebuggerActionModel >> autoClassifyMessage: aMessage inClass: aClass [
]

{ #category : #context }
StMockDebuggerActionModel >> computeInitialTopContext [
]

{ #category : #initialize }
StMockDebuggerActionModel >> initialize [
	super initialize.
	self interruptedContext: (Context
			 sender: nil
			 receiver: nil
			 method: Object >> #doesNotUnderstand:
			 arguments: #( #message ))
]

{ #category : #accessing }
StMockDebuggerActionModel >> interruptedContext: anObject [

	interruptedContext := anObject.
	topContext := anObject
]

{ #category : #accessing }
StMockDebuggerActionModel >> session [
	^StMockSession new
]

{ #category : #accessing }
StMockDebuggerActionModel >> tag [
	^tag
	
]

{ #category : #'debug - stepping' }
StMockDebuggerActionModel >> updateTopContext [
	tag :=  #updateTopContext
	
]
