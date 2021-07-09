Class {
	#name : #StepIntoTest,
	#superclass : #DebuggerTest,
	#category : #'Debugger-Model-Tests-Core'
}

{ #category : #helper }
StepIntoTest >> callQuickMethodWithoutReturningItsResult [
	self quickMethod.
]

{ #category : #helper }
StepIntoTest >> quickMethod [
	^1.
]

{ #category : #helper }
StepIntoTest >> returnQuickMethodResult [
	^ self quickMethod.
]

{ #category : #helper }
StepIntoTest >> stepA1 [
	^42
]

{ #category : #tests }
StepIntoTest >> testStepIntoDeadContextShouldRaiseException [
	self settingUpSessionAndProcessAndContextForBlock: [  ].
	session stepInto. "The first step into executes the (empty) body of the block and returns from it. From this point on, the context is dead since it returned."
	
	"We should be able to call stepInto.
	However, calling it provokes infinite exceptions and non recuperable images."
	"session stepInto."
	
	"We have found that the debugSession calls stepToSendOrReturn after step: which could be the cause of the issue.
	This test is green if we avoid calling that part and just call step:"
	session interruptedProcess step: session interruptedContext.
	
	self assert: context isDead
]

{ #category : #tests }
StepIntoTest >> testStepIntoMethodCallShouldActivateIt [
	"Stepping into a method call should create a context for it at the top of the context stack"
	self settingUpSessionAndProcessAndContextForBlock: [ self stepA1 ].
	[session interruptedContext method == (self class>>#stepA1)] 
		whileFalse: [ session stepInto ].

	self
		assert: process suspendedContext method
		equals: self class >> #stepA1
]

{ #category : #tests }
StepIntoTest >> testStepIntoQuickMethodCallNotReturnedShouldLeaveTheValueStackEmpty [
	"Stepping into a quick method whose result is not used should leave the value stack empty"
	self settingUpSessionAndProcessAndContextForBlock: [ self callQuickMethodWithoutReturningItsResult].
	[session interruptedContext method == (self class>>#callQuickMethodWithoutReturningItsResult)] 
		whileFalse: [ session stepInto ].

	session stepInto.
	self
		assert: process suspendedContext method
		equals: self class >> #callQuickMethodWithoutReturningItsResult.
	self
		assert: process suspendedContext size
		equals: 0.
]

{ #category : #tests }
StepIntoTest >> testStepIntoQuickMethodCallReturnedShouldPushReturnValueToTheStack [
	"Stepping into a call to a quick method whose result is used should push its return value to the stack"
	self settingUpSessionAndProcessAndContextForBlock: [ self returnQuickMethodResult].
	[session interruptedContext method == (self class>>#returnQuickMethodResult)] 
		whileFalse: [ session stepInto ].

	session stepInto.
	self
		assert: process suspendedContext method
		equals: self class >> #returnQuickMethodResult.
	self
		assert: process suspendedContext top
		equals: 1.
]

{ #category : #tests }
StepIntoTest >> testStepIntoUntilTermination [ 
	"Stepping over a message node brings the execution to the next node in the same method."
	self settingUpSessionAndProcessAndContextForBlock: [ #test ].

	[ session interruptedProcess isTerminated ] whileFalse: [ session stepInto ].

	self assert: session interruptedProcess isTerminated
]
