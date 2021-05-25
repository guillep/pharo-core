Class {
	#name : #DebuggingInstructionStreamTest,
	#superclass : #TestCase,
	#category : #'Debugging-Core-Tests'
}

{ #category : #helpers }
DebuggingInstructionStreamTest >> method1 [

	| a |
	a := 1.
	^ 1 + 2
]

{ #category : #helpers }
DebuggingInstructionStreamTest >> methodWithBlock [

	[| a |
	a := 1.
	^ 1 + 2] value
]

{ #category : #helpers }
DebuggingInstructionStreamTest >> methodWithSuper [

	super printString.
	^ 42
]

{ #category : #'tests - structure' }
DebuggingInstructionStreamTest >> testFirstByte [
	|compiledMethod stream|
	compiledMethod := self class >> #method1.
	stream := InstructionStream on: compiledMethod.
	self assert: stream firstByte equals: (compiledMethod at: compiledMethod initialPC)
]

{ #category : #'tests - structure' }
DebuggingInstructionStreamTest >> testFollowingByteAccessByteCodeConstituentByteByByte [

	| compiledMethod stream client |
	compiledMethod := self class >> #methodWithSuper.
	stream := InstructionStream on: compiledMethod.
	client := InstructionClient new.
	
	"Answer the next byte.
	For example for this bytecode 
	<EB 00> superSend 
	<D8> pop
	 If the current byte is EB, the following byte is 00.
	 It is not the following bytecode, that is D8"
 	stream pc: stream pc + 1.	
	self assert: stream followingByte identicalTo: (compiledMethod at: compiledMethod initialPC + 2).
	self deny: stream followingByte identicalTo: stream followingBytecode.
	stream pc: stream pc + 1.
	self assert: stream followingByte identicalTo: (compiledMethod at: compiledMethod initialPC + 3).
	stream pc: stream pc + 1.
	self assert: stream followingByte identicalTo: stream followingBytecode
]

{ #category : #'tests - structure' }
DebuggingInstructionStreamTest >> testFollowingByteWithSuper [

	| compiledMethod stream client |
	compiledMethod := self class >> #methodWithSuper.
	stream := InstructionStream on: compiledMethod.
	client := InstructionClient new.
	stream interpretNextInstructionFor: client.
	self flag: 'improve this test to avoid magic number'.
	self
		assert: stream followingByte
		identicalTo: (compiledMethod at: 43)
]

{ #category : #'tests - interpretation' }
DebuggingInstructionStreamTest >> testInterpretNextInstruction [
	| compiledMethod stream client currentPC |
	compiledMethod := self class >> #method1.
	stream := InstructionStream on: compiledMethod.
	client := InstructionClient new.
	currentPC := stream pc.
	stream interpretNextInstructionFor: client.
	self assert: stream pc equals: (currentPC + (compiledMethod bytecodeSizeForPc: currentPC))
]

{ #category : #'tests - structure' }
DebuggingInstructionStreamTest >> testNextByte [

	| compiledMethod stream client |
	compiledMethod := self class >> #methodWithSuper.
	stream := InstructionStream on: compiledMethod.
	client := InstructionClient new.
	stream interpretNextInstructionFor: client.
	self assert: stream nextByte 
	 		 equals: (compiledMethod at: compiledMethod initialPC + (compiledMethod bytecodeSizeForPc: compiledMethod initialPC))
]

{ #category : #'tests - structure' }
DebuggingInstructionStreamTest >> testNextByteForBlocks [

	| compiledMethod compiledBlock stream client |
	compiledMethod := self class >> #methodWithBlock.
	compiledBlock := compiledMethod literals at: 1.
	stream := InstructionStream on: compiledBlock.
	client := InstructionClient new.
	stream interpretNextInstructionFor: client.
	self assert: stream nextByte 
			 equals: (compiledBlock at: compiledBlock initialPC + (compiledBlock bytecodeSizeForPc: stream pc))
]

{ #category : #'tests - structure' }
DebuggingInstructionStreamTest >> testNextPc [

	| compiledMethod stream bytecode |
	compiledMethod := self class >> #method1.
	stream := InstructionStream on: compiledMethod.
	bytecode := stream firstByte.
	self
		assert: (stream nextPc: bytecode)
		equals: compiledMethod initialPC
			+ (compiledMethod bytecodeSizeForPc: compiledMethod initialPC)
]

{ #category : #'tests - structure' }
DebuggingInstructionStreamTest >> testNextPcOfDifferentSizesBytecodes [

	| compiledMethod stream client stream2 client2 |
	compiledMethod := self class >> #methodWithSuper.
	stream := InstructionStream on: compiledMethod.
	client := InstructionClient new.
	stream interpretNextInstructionFor: client.
	
	stream2 := InstructionStream on: compiledMethod.
	client2 := InstructionClient new.
	stream2 interpretNextInstructionFor: client2.
	stream2 interpretNextInstructionFor: client2.
	
	self
		assert: (stream nextPc: (compiledMethod at: stream pc))
		equals: stream2 pc
]
