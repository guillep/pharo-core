Class {
	#name : #StepThroughTest,
	#superclass : #DebuggerTest,
	#category : #'Debugger-Model-Tests-Core'
}

{ #category : #helper }
StepThroughTest >> evalBlockThenReturnOne: aBlock [
	aBlock value.
	^1.
]

{ #category : #helper }
StepThroughTest >> stepA1 [
	self evalBlockThenReturnOne: [ self stepA2 ]
]

{ #category : #helper }
StepThroughTest >> stepA2 [
	^ 2+2
]

{ #category : #helper }
StepThroughTest >> stepB1 [
	self stepB2.
	self stepB3.
]

{ #category : #helper }
StepThroughTest >> stepB2 [
	^ 42
]

{ #category : #helper }
StepThroughTest >> stepB3 [
	^ 43
]

{ #category : #tests }
StepThroughTest >> testStepThrough [
	"In a context c, define a block b, send a message to another method to get b evaluated.
	Testing that a step through on this message send moves the execution to the point where the block b is about to be evaluated."
	| node expectedMethod |
	self settingUpSessionAndProcessAndContextForBlock: [ self stepA1 ].
	session stepInto.
	session stepInto.
	"Reached node 'self evalBlockThenReturnOne: [self stepA2]' of method stepA1"
	"Checking that the execution is indeed at this node"
	self assert: (session interruptedContext method) equals: (self class>>#stepA1).
	node := self class>>#stepA1 sourceNodeForPC: session interruptedContext pc.
	self assert: node isMessage.
	self assert: node receiver isSelfVariable.
	self assert: node selector equals: #evalBlockThenReturnOne:.
	session stepThrough.

	"With fullblocks the method of the suspended context is a compiledBlock, not the method having it"
	expectedMethod := (self class >> #stepA1) encoderClass = EncoderForV3PlusClosures
		ifTrue: [ self class >> #stepA1 ]
		ifFalse: [ (self class >> #stepA1) literalAt: 1 ].

	"Checking that after the step through, the execution is at the 'self stepA2' node of the stepA1 method"
	self assert: (session interruptedContext method) equals: expectedMethod.
	node := expectedMethod sourceNodeForPC: session interruptedContext pc.
	self assert: node isMessage.
	self assert: node receiver isSelfVariable.
	self assert: node selector equals: #stepA2.
	
]

{ #category : #tests }
StepThroughTest >> testStepThroughDoesTheSameThingAsStepOverWhenNoBlockIsInvolved [
	"Testing that when no block is involved, a step through moves the execution to the same point a step over would"
	| node |

	self settingUpSessionAndProcessAndContextForBlock: [ self stepB1 ].
	[session interruptedContext method == (self class>>#stepB1)] 
		whileFalse: [ session stepInto ].

	"Reached node 'self stepB2' of method stepB1"
	self assert: session interruptedContext method equals: self class>>#stepB1.
	session stepOver.
	self assert: (session interruptedContext method) equals: (self class>>#stepB1).
	"Checking that after the step over, we reached the node 'self stepB3' of method stepB1"
	node := self class>>#stepB1 sourceNodeForPC: session interruptedContext pc.
	self assert: node isMessage.
	self assert: node receiver isSelfVariable.
	self assert: node selector equals: #stepB3.
	
	"Set up the debugged execution again"
	self settingUpSessionAndProcessAndContextForBlock: [ self stepB1 ].
	[session interruptedContext method == (self class>>#stepB1)] 
		whileFalse: [ session stepInto ].

	"Reached node 'self stepB2' of method stepB1"
	self assert: session interruptedContext method equals: self class>>#stepB1.
	session stepThrough.
	"Checking that after the step through, we reached the node 'self stepB3' of method stepB1 (the same node that was reached with the step over"
	node := self class>>#stepB1 sourceNodeForPC: session interruptedContext pc.
	self assert: node isMessage.
	self assert: node receiver isSelfVariable.
	self assert: node selector equals: #stepB3.
]

{ #category : #tests }
StepThroughTest >> testStepThroughUntilTermination [ 
	"Stepping over a message node brings the execution to the next node in the same method."
	self settingUpSessionAndProcessAndContextForBlock: [ self stepA1 ].

	[ session interruptedProcess isTerminated ] whileFalse: [ session stepThrough ].

	self assert: session interruptedProcess isTerminated
]
