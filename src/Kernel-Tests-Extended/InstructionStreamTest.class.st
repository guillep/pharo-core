Class {
	#name : #InstructionStreamTest,
	#superclass : #TestCase,
	#instVars : [
		'operations'
	],
	#category : #'Kernel-Tests-Extended-Methods'
}

{ #category : #helpers }
InstructionStreamTest >> blockReturnTop [
	
		operations add: { #blockReturnTop }
]

{ #category : #helpers }
InstructionStreamTest >> classUnderTest [ 

	^ ClassUsedInInstructionStreamTest
]

{ #category : #helpers }
InstructionStreamTest >> directedSuperSend: aString numArgs: anInteger [ 
	
	operations add: { #directSuperSend:numArgs:. aString. anInteger }
]

{ #category : #helpers }
InstructionStreamTest >> pushConstant: anInteger [ 

	operations add: { #pushConstant. anInteger }
]

{ #category : #helpers }
InstructionStreamTest >> pushLiteralVariable: aLiteralVariable [ 

	operations add: { #pushConstant. aLiteralVariable }
]

{ #category : #helpers }
InstructionStreamTest >> pushReceiver [
	
	operations add: {#pushReceiver}
]

{ #category : #helpers }
InstructionStreamTest >> send: aString super: aBoolean numArgs: anInteger [ 

	operations add: { #send:super:numArgs:. aString. aBoolean. anInteger }
]

{ #category : #running }
InstructionStreamTest >> setUp [ 

	super setUp.
	operations := OrderedCollection new
]

{ #category : #tests }
InstructionStreamTest >> testBlockWithASuperSendHasCorrectNumberOfArguments [

	| aMethod aCompiledBlock aStream |
	aMethod := self classUnderTest >> #methodWithASuperBlock.
	aCompiledBlock := aMethod literals at:1.
	
	self assert: aCompiledBlock isCompiledBlock.
	
	aStream := InstructionStream on: aCompiledBlock.

	aStream interpretWithClient: self.
		
	self assert: operations fifth equals: { #directSuperSend:numArgs:. #aSuperMethod:with:. 2 }
]

{ #category : #tests }
InstructionStreamTest >> testBlockWithASuperWithoutArgumentsSendHasCorrectNumberOfArguments [

	| aMethod aCompiledBlock aStream |
	aMethod := self classUnderTest >> #methodWithASuperBlockWithoutArguments.
	aCompiledBlock := aMethod literals at:1.
	
	self assert: aCompiledBlock isCompiledBlock.
	
	aStream := InstructionStream on: aCompiledBlock.

	aStream interpretWithClient: self.
		
	self assert: operations third equals: { #directSuperSend:numArgs:. #yourself. 0 }
]

{ #category : #'tests - example' }
InstructionStreamTest >> testSimulatedTerminationOfProcessDoNotCorruptTheContext [

	| initialContext aContext receiver semaphore process suspendedProcess return errorThatHappen |
	
	receiver := self classUnderTest new.
	semaphore := Semaphore new.
	process := [ semaphore wait ] forkAt: Processor activePriority + 1.
	receiver process: process.
	suspendedProcess := [ receiver callingAMethodSuspendedBeforeTheTerminateOfAnotherProcess ] forkAt: Processor activePriority + 1.

	initialContext := aContext := suspendedProcess suspendedContext.
	[ initialContext method = (self classUnderTest >> #callingAMethodSuspendedBeforeTheTerminateOfAnotherProcess) ] 
		whileFalse: [ initialContext := initialContext sender].
	
	[return := suspendedProcess stepToHome: initialContext] 
		on: Exception do: [:e | errorThatHappen := e ].

	self assert: errorThatHappen isNil.
	self assert: receiver expectedValue equals: 42
]

{ #category : #'tests - example' }
InstructionStreamTest >> testSimulatingAMethodWithHaltHasCorrectContext [

	| initialContext aContext receiver suspendedProcess return |
	
	receiver := self classUnderTest new.
	suspendedProcess := [ receiver callingAMethodWithHalt ] forkAt: Processor activePriority + 1.

	initialContext := aContext := suspendedProcess suspendedContext.
	[ initialContext method = (self classUnderTest >> #callingAMethodWithHalt) ] 
		whileFalse: [ initialContext := initialContext sender].
	
	return := suspendedProcess stepToHome: initialContext.
	
	"Suspended process should stop in the exception"	
	self assert: return method equals: (Object >> #halt).
	self assert: return size equals: 1.
]

{ #category : #'tests - example' }
InstructionStreamTest >> testStepThroughInAMethodWithMNU [

	| initialContext aContext receiver suspendedProcess return |
	
	receiver := self classUnderTest new.
	suspendedProcess := [ receiver callingAMethodWithMNU ] forkAt: Processor activePriority + 1.

	initialContext := aContext := suspendedProcess suspendedContext.
	[ initialContext method = (self classUnderTest >> #callingAMethodWithMNU) ] 
		whileFalse: [ initialContext := initialContext sender].
	
	return := suspendedProcess stepToHome: initialContext.
	
	"Suspended process should stop in the exception"	
	self assert: return method equals: (self classUnderTest lookupSelector: #doesNotUnderstand:).

]

{ #category : #'tests - example' }
InstructionStreamTest >> testStepThroughInAMethodWithMNUInMustBeBoolean [

	| initialContext aContext receiver suspendedProcess return |
	
	receiver := self classUnderTest new.
	suspendedProcess := [ receiver callingAMethodWithMustBeBooleanMNU ] forkAt: Processor activePriority + 1.

	initialContext := aContext := suspendedProcess suspendedContext.
	[ initialContext method = (self classUnderTest >> #callingAMethodWithMustBeBooleanMNU) ] 
		whileFalse: [ initialContext := initialContext sender].
	
	return := suspendedProcess stepToHome: initialContext.
	
	"Suspended process should stop in the exception"	
	self assert: return method equals: (self classUnderTest lookupSelector: #doesNotUnderstand:).
]

{ #category : #'tests - example' }
InstructionStreamTest >> testStepThroughInAMethodWithoutError [

	| initialContext aContext receiver suspendedProcess return |
	
	receiver := self classUnderTest new.
	suspendedProcess := [ receiver callingAMethodWithSuspendAndReturnANumber ] forkAt: Processor activePriority + 1.

	initialContext := aContext := suspendedProcess suspendedContext.
	[ initialContext method = (self classUnderTest >> #callingAMethodWithSuspendAndReturnANumber) ] 
		whileFalse: [ initialContext := initialContext sender].
	
	return := suspendedProcess stepToHome: initialContext.
	
	"Suspended process should stop in the exception"	
	self assert: return method equals: (self classUnderTest >> #callingAMethodWithSuspendAndReturnANumber).
	self assert: return top equals: 42.
]

{ #category : #'tests - example' }
InstructionStreamTest >> testSteppingSendsDirectSend [

	| initialContext aContext receiver |
	
	receiver := self classUnderTest new.
	
	initialContext := Context 
		sender: nil receiver: receiver 
		method: self classUnderTest >> #valueOfBlockWithSupersend 
		arguments: #().

	aContext := initialContext.

	[aContext = nil] 
		whileFalse: [aContext := aContext step].
		
	self assert: receiver expectedValue equals: 42
]
