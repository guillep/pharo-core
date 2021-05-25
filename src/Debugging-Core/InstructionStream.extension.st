Extension { #name : #InstructionStream }

{ #category : #'*Debugging-Core' }
InstructionStream >> addSelectorTo: set [ 
	"If this instruction is a send, add its selector to set."

	| selectorOrSelf |
	(selectorOrSelf := self selectorToSendOrSelf) == self ifFalse:
		[set add: selectorOrSelf]
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
InstructionStream >> firstByte [
	"Answer the first byte of the current bytecode."

	^self method at: self method initialPC
]

{ #category : #'*Debugging-Core' }
InstructionStream >> followingByte [
	"Answer the next byte.
	For example for this bytecode 
	<EB 00> superSend 
	<D8> pop
	 If the current byte is EB, the following byte is 00.
	 It is not the following bytecode, that is D8"

	^self method at: pc + 1
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
	| endPC |
	endPC := self method endPC.
	[pc > endPC] whileFalse: [self interpretNextInstructionFor: self]
]

{ #category : #'*Debugging-Core' }
InstructionStream >> interpretJump [
	^ self method encoderClass interpretJumpIn: self

]

{ #category : #'*Debugging-Core' }
InstructionStream >> interpretJumpIfCond [
	^ self method encoderClass interpretJumpIfCondIn: self

]

{ #category : #'*Debugging-Core' }
InstructionStream >> interpretNextInstruction [
	"Return the next bytecode instruction as a message that an InstructionClient would understand.  This advances the pc by one instruction."

	^ self interpretNextInstructionFor: MessageCatcher new
]

{ #category : #'*Debugging-Core' }
InstructionStream >> interpretSistaV1Jump [
	"If the instruction at pc is an unconditional jump, interpret it, advancing
	the pc,
	and answering the jump distance. Otherwise answer nil."
	"176-183	10110 iii				Jump iii + 1 (i.e., 1 through 8)
	*	225/16rE1	11100001	sbbbbbbb	Extend B (Ext B = Ext B prev *
	256 + Ext B)
	*	237		11101101	iiiiiiii		Jump #iiiiiiii (+ Extend B * 256, where
	bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	| method byte nextpc extB |
	method := self method.
	"consume and compute any extension first."
	extB := 0.
	nextpc := pc.
	"must not advance pc unless this is a jump."
	[byte := self method at: nextpc.
	nextpc := nextpc + 1.
	byte = 225]
		whileTrue: [| extByte |
			extByte := self method at: nextpc.
			nextpc := nextpc + 1.
			extB := (extB = 0
							and: [extByte > 127])
						ifTrue: [extByte - 256]
						ifFalse: [(extB bitShift: 8)
								+ extByte]].
	(byte between: 176 and: 183)
		ifTrue: [pc := nextpc.
			^ byte - 191].
	byte = 237
		ifTrue: [byte := method at: nextpc.
			pc := nextpc + 1.
			^ (extB bitShift: 8)
				+ byte].
	^ nil

]

{ #category : #'*Debugging-Core' }
InstructionStream >> interpretSistaV1JumpIfCond [
	"If the instruction at pc is a conditional jump, interpret it, advancing
	the pc,
	and answering the jump distance. Otherwise answer nil."
	"184-191	10111 iii				Pop and Jump 0n True iii +1 (i.e., 1 through 8)
	192-199	11000 iii				Pop and Jump 0n False iii +1 (i.e., 1 through 8)
	*	225/E1		11100001	sbbbbbbb	Extend B (Ext B = Ext B prev * 256
	+ Ext B)
	*	238		11101110	iiiiiiii		Pop and Jump 0n True #iiiiiiii (+ Extend B *
	256, where Extend B >= 0)
	*	239		11101111	iiiiiiii		Pop and Jump 0n False #iiiiiiii (+ Extend B *
	256, where Extend B >= 0)"
	| method byte nextpc extB |
	method := self method.
	"consume and compute any extension first."
	extB := 0.
	nextpc := pc.
	"must not advance pc unless this is a jump."
	[byte := self method at: nextpc.
	nextpc := nextpc + 1.
	byte = 225]
		whileTrue: [| extByte |
			extByte := self method at: nextpc.
			nextpc := nextpc + 1.
			extB := (extB = 0
							and: [extByte > 127])
						ifTrue: [extByte - 256]
						ifFalse: [(extB bitShift: 8)
								+ extByte]].
	(byte between: 184 and: 199)
		ifTrue: [pc := nextpc.
			^ (byte bitAnd: 7)
				+ 1].
	(byte between: 238 and: 239)
		ifTrue: [byte := method at: nextpc.
			pc := nextpc + 1.
			^ (extB bitShift: 8)
				+ byte].
	^ nil

]

{ #category : #'*Debugging-Core' }
InstructionStream >> interpretV3ClosuresExtension: offset in: method for: client [
	| type offset2 byte2 byte3 byte4 |
	offset <= 6 ifTrue: 
		["Extended op codes 128-134"
		byte2 := method at: pc. pc := pc + 1.
		offset <= 2 ifTrue:
			["128-130:  extended pushes and pops"
			type := byte2 // 64.
			offset2 := byte2 \\ 64.
			offset = 0 ifTrue: 
				[type = 0 ifTrue: [^client pushReceiverVariable: offset2].
				type = 1 ifTrue: [^client pushTemporaryVariable: offset2].
				type = 2  ifTrue: [^client pushConstant: (method literalAt: offset2 + 1)].
				type = 3 ifTrue: [^client pushLiteralVariable: (method literalAt: offset2 + 1)]].
			offset = 1 ifTrue: 
				[type = 0 ifTrue: [^client storeIntoReceiverVariable: offset2].
				type = 1 ifTrue: [^client storeIntoTemporaryVariable: offset2].
				type = 2 ifTrue: [self error: 'illegalStore'].
				type = 3 ifTrue: [^client storeIntoLiteralVariable: (method literalAt: offset2 + 1)]].
			offset = 2 ifTrue: 
				[type = 0 ifTrue: [^client popIntoReceiverVariable: offset2].
				type = 1 ifTrue: [^client popIntoTemporaryVariable: offset2].
				type = 2 ifTrue: [self error: 'illegalStore'].
				type = 3  ifTrue: [^client popIntoLiteralVariable: (method literalAt: offset2 + 1)]]].
		"131-134: extended sends"
		offset = 3 ifTrue:  "Single extended send"
			[^client send: (method literalAt: byte2 \\ 32 + 1)
					super: false numArgs: byte2 // 32].
		offset = 4 ifTrue:    "Double extended do-anything"
			[byte3 := method at: pc. pc := pc + 1.
			type := byte2 // 32.
			type = 0 ifTrue: [^client send: (method literalAt: byte3 + 1)
									super: false numArgs: byte2 \\ 32].
			type = 1 ifTrue: [^client send: (method literalAt: byte3 + 1)
									super: true numArgs: byte2 \\ 32].
			type = 2 ifTrue: [^client pushReceiverVariable: byte3].
			type = 3 ifTrue: [^client pushConstant: (method literalAt: byte3 + 1)].
			type = 4 ifTrue: [^client pushLiteralVariable: (method literalAt: byte3 + 1)].
			type = 5 ifTrue: [^client storeIntoReceiverVariable: byte3].
			type = 6 ifTrue: [^client popIntoReceiverVariable: byte3].
			type = 7 ifTrue: [^client storeIntoLiteralVariable: (method literalAt: byte3 + 1)]].
		offset = 5 ifTrue:  "Single extended send to super"
			[^client send: (method literalAt: byte2 \\ 32 + 1)
					super: true
					numArgs: byte2 // 32].
		offset = 6 ifTrue:   "Second extended send"
			[^client send: (method literalAt: byte2 \\ 64 + 1)
					super: false
					numArgs: byte2 // 64]].
	offset = 7 ifTrue: [^client doPop].
	offset = 8 ifTrue: [^client doDup].
	offset = 9 ifTrue: [^client pushActiveContext].
	byte2 := method at: pc. pc := pc + 1.
	offset = 10 ifTrue:
		[^byte2 < 128
			ifTrue: [client pushNewArrayOfSize: byte2]
			ifFalse: [client pushConsArrayWithElements: byte2 - 128]].
	byte3 := method at: pc.  pc := pc + 1.
	offset = 11 ifTrue: [^client callPrimitive: byte2 + (byte3 bitShift: 8)].
	offset = 12 ifTrue: [^client pushRemoteTemp: byte2 inVectorAt: byte3].
	offset = 13 ifTrue: [^client storeIntoRemoteTemp: byte2 inVectorAt: byte3].
	offset = 14 ifTrue: [^client popIntoRemoteTemp: byte2 inVectorAt: byte3].
	"offset = 15"
	byte4 := method at: pc.  pc := pc + 1.
	^client
		pushClosureCopyNumCopiedValues: (byte2 bitShift: -4)
		numArgs: (byte2 bitAnd: 16rF)
		blockSize: (byte3 * 256) + byte4
]

{ #category : #'*Debugging-Core' }
InstructionStream >> interpretV3PlusClosureJump [

	| byte |
	byte := self method at: pc.
	(byte between: 144 and: 151) ifTrue:
		[pc := pc + 1. ^byte - 143].
	(byte between: 160 and: 167) ifTrue:
		[pc := pc + 2. ^(byte - 164) * 256 + (self method at: pc - 1)].
	^nil
]

{ #category : #'*Debugging-Core' }
InstructionStream >> interpretV3PlusClosureJumpIfCond [

	| byte |
	byte := self method at: pc.
	(byte between: 152 and: 159) ifTrue:
		[pc := pc + 1. ^byte - 151].
	(byte between: 168 and: 175) ifTrue:
		[pc := pc + 2. ^(byte bitAnd: 3) * 256 + (self method at: pc - 1)].
	^nil
]

{ #category : #'*Debugging-Core' }
InstructionStream >> nextByte [
	"Answer the next bytecode"
	self flag: 'Should this method be renamed nextBytecode? Is it possible thta it returns only a byte?'.

	^self method at: pc
]

{ #category : #'*Debugging-Core' }
InstructionStream >> nextPc: currentByte [
	"Answer the pc of the bytecode following the bytecode currentByte.
	 Skips the extension bytecodes."
	
	^ pc + (self method encoderClass bytecodeSize: currentByte)
]

{ #category : #'*Debugging-Core' }
InstructionStream >> previousPc [

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
InstructionStream >> selectorToSendOrSelf [
	"If this instruction is a send, answer the selector, otherwise answer self."
 
	^ self method encoderClass selectorToSendOrItselfFor: self in: self method at: pc 
]

{ #category : #'*Debugging-Core' }
InstructionStream >> skipBackBeforeJump [
	"Assuming that the receiver is positioned just after a jump, skip back one or two bytes,
	 depending on the size of the previous jump instruction."
	| scanner client prevPc |
	scanner := InstructionStream on: self method.
	client := InstructionClient new.
	[scanner pc < pc] whileTrue:
		[prevPc := scanner pc.
		 scanner interpretNextInstructionFor: client].
	scanner pc: prevPc.
	(scanner willJumpIfTrue or: [scanner willJumpIfFalse]) ifFalse:
		[self error: 'Where''s the jump??'].
	self jump: prevPc - pc
]

{ #category : #'*Debugging-Core' }
InstructionStream >> thirdByte [
	"Answer the third byte of the current bytecode."

	^self method at: pc + 2
]

{ #category : #'*Debugging-Core' }
InstructionStream >> unusedBytecode: client at: startPC [
	^ client unusedBytecode
]

{ #category : #'*Debugging-Core' }
InstructionStream >> willBlockReturn [

	^ self method encoderClass isBlockReturnAt: pc in: self method
]

{ #category : #'*Debugging-Core' }
InstructionStream >> willCreateBlock [
	"next bytecode is a block creation"

	^ (self method encoderClass isCreateBlockAt: pc in: self method) or: 
		[ self method encoderClass isCreateFullBlockAt: pc in: self method]
]

{ #category : #'*Debugging-Core' }
InstructionStream >> willJump [
	"unconditionally"

	^ self method encoderClass isJumpAt: pc in: self method
	
]

{ #category : #'*Debugging-Core' }
InstructionStream >> willJumpIfFalse [
	"Answer whether the next bytecode is a jump-if-false."

	^ self method encoderClass isBranchIfFalseAt: pc in: self method
]

{ #category : #'*Debugging-Core' }
InstructionStream >> willJumpIfTrue [ 
	"Answer whether the next bytecode is a jump-if-true."
 
	^ self method encoderClass isBranchIfTrueAt: pc in: self method
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

{ #category : #'*Debugging-Core' }
InstructionStream >> willStorePop [
	"Answer whether the next bytecode is a store-pop."

	^ self method encoderClass isStorePopAt: pc in: self method
]
