Extension { #name : #InstructionStream }

{ #category : #'*Debugging-Core' }
InstructionStream >> addSelectorTo: set [ 
	"If this instruction is a send, add its selector to set."

	| selectorOrSelf |
	(selectorOrSelf := self selectorToSendOrSelf) == self ifFalse:
		[set add: selectorOrSelf]
]

{ #category : #'*Debugging-Core' }
InstructionStream >> advanceToFollowingPc [
	"Advance the PC to the next valid PC in the instruction stream.
	Take into account that the current instruction may have a variable size and occupy more than a single byte."

	pc := self followingPc
]

{ #category : #'*Debugging-Core' }
InstructionStream >> atEnd [

	^ pc > self method endPC
]

{ #category : #'*Debugging-Core' }
InstructionStream >> debuggerMap [
	^self method debuggerMap
]

{ #category : #'*Debugging-Core' }
InstructionStream >> decodeNextInstruction [
	"Return the next bytecode instruction as a message that an InstructionClient would understand.  This advances the pc by one instruction."

	^ self interpretNextInstructionFor: MessageCatcher new
]

{ #category : #'*Debugging-Core' }
InstructionStream >> followingBytecode [
	"Answer the bytecode of the following bytecode (different to nextByte)."

	^self method at: self followingPc
]

{ #category : #'*Debugging-Core' }
InstructionStream >> followingPc [
	"Answer the pc of the following bytecode."

	^self nextPc: (self method at: pc)
]

{ #category : #'*Debugging-Core' }
InstructionStream >> interpret [
	"Interpret / evaluate the current method in the current context until the end.
	Use the context as client of the interpretation as well as the decoder of instructions.
	The context is a client that evaluates instructions"
	self interpretWithClient: self
]

{ #category : #'*Debugging-Core' }
InstructionStream >> interpretWithClient: aClient [
	| endPC |
	endPC := self method endPC.
	[pc > endPC] whileFalse: [self interpretNextInstructionFor: aClient]
]

{ #category : #'*Debugging-Core' }
InstructionStream >> nextPc: currentByte [
	"Answer the pc of the next bytecode following the current one, given the current bytecode.
	 Skips the extension bytecodes."
	
	^ pc + (self method encoderClass bytecodeSize: currentByte)
]

{ #category : #'*Debugging-Core' }
InstructionStream >> peekByte [
	"Answer the first byte of the current bytecode."

	^self method at: pc
]

{ #category : #'*Debugging-Core' }
InstructionStream >> previousPc [

	"Return the PC of the instruction preceding the current one"
	^self method pcPreviousTo: pc
]

{ #category : #'*Debugging-Core' }
InstructionStream >> scanFor: scanBlock [
	"Check all bytecode instructions with scanBlock, answer true if scanBlock answers true.
	This can be used to, e.g., check whether a method contains 'push closure' bytecodes like this:
	aMethod scanFor: [ :b | b = 143 ]"

	| method encoderClass end byte |
	method := self method.
	end := method endPC.
	encoderClass := method encoderClass.
	[pc <= end] whileTrue: 
		[(scanBlock value: (byte := method at: pc)) ifTrue:
			[^true].
		 pc := pc + (encoderClass bytecodeSize: byte)].
	^false
]

{ #category : #'*Debugging-Core' }
InstructionStream >> secondByte [
	"Answer the second byte of the current bytecode."

	^self method at: pc + 1
]

{ #category : #'*Debugging-Core' }
InstructionStream >> selectorToSendOrSelf [
	"If this instruction is a send, answer the selector, otherwise answer self."
 
	^ self method encoderClass selectorToSendOrItselfFor: self in: self method at: pc 
]

{ #category : #'*Debugging-Core' }
InstructionStream >> thirdByte [
	"Answer the third byte of the current bytecode."

	^self method at: pc + 2
]

{ #category : #'*Debugging-Core' }
InstructionStream >> willCreateBlock [
	"next bytecode is a block creation"

	^ (self method encoderClass isCreateBlockAt: pc in: self method) or: 
		[ self method encoderClass isCreateFullBlockAt: pc in: self method]
]

{ #category : #'*Debugging-Core' }
InstructionStream >> willJumpIfFalse [
	"Answer whether the next bytecode is a jump-if-false."

	^ self method encoderClass isBranchIfFalseAt: pc in: self method
]

{ #category : #'*Debugging-Core' }
InstructionStream >> willJustPop [

	^ self method encoderClass isJustPopAt: pc in: self method
]

{ #category : #'*Debugging-Core' }
InstructionStream >> willReturn [
	"Answer whether the next bytecode is a return."

	^ self method encoderClass isReturnAt: pc in: self method
]

{ #category : #'*Debugging-Core' }
InstructionStream >> willSend [
	"Answer whether the next bytecode is a message-send."

	^ self method encoderClass isSendAt: pc in: self method
]

{ #category : #'*Debugging-Core' }
InstructionStream >> willStore [
	"Answer whether the next bytecode is a store or store-pop"

	^ self method encoderClass isStoreAt: pc in: self method
]
