"
Instance variables:
	sender: <Context|nil> context that invoked this context
	pc: <SmallInteger> (pc = program counter) offset of the bytecode instruction currently executed

My instances can interpret the byte-encoded Smalltalk instruction set. They maintain a program counter (pc) for streaming through CompiledMethods. My subclasses are Contexts, which inherit this capability. They store the return pointer in the instance variable sender, and the current position in their method in the instance variable pc. For other users, sender can hold a method to be similarly interpreted. The unclean re-use of sender to hold the method was to avoid a trivial subclass for the stand-alone scanning function.
"
Class {
	#name : #InstructionStream,
	#superclass : #Object,
	#instVars : [
		'sender',
		'pc'
	],
	#classVars : [
		'SpecialConstants'
	],
	#category : #'Kernel-Methods'
}

{ #category : #'class initialization' }
InstructionStream class >> initialize [
	"Initialize an array of special constants returned by single-bytecode returns."

	SpecialConstants := 
		(Array with: true with: false with: nil)
			, (Array with: -1 with: 0 with: 1 with: 2)	
	"InstructionStream initialize."

]

{ #category : #'instance creation' }
InstructionStream class >> on: method [ 
	"Answer an instance of me on the argument, method."

	^self on: method pc: method initialPC
]

{ #category : #'instance creation' }
InstructionStream class >> on: method pc: aPC [
	"Answer an instance of me on the argument, method."

	^self new method: method pc: aPC
]

{ #category : #accessing }
InstructionStream >> compiledCode [
	^self method
]

{ #category : #interpreting }
InstructionStream >> interpretNext2ByteSistaV1Instruction: bytecode for: client extA: extA extB: extB startPC: startPC [
	"Send to the argument, client, a message that specifies the next instruction.
	 This method handles the two-byte codes.
	 For a table of the bytecode set, see EncoderForV1's class comment."

	| byte method |
	method := self compiledCode.
	byte := self compiledCode at: pc.
	pc := pc + 1.
	"We do an inline quasi-binary search on bytecode"
	bytecode < 234 ifTrue: "pushes"
		[bytecode < 231 ifTrue:
			[bytecode < 229 ifTrue:
				[| literal |
				 bytecode = 226 ifTrue:
					[^client pushReceiverVariable: (extA bitShift: 8) + byte].
				 literal := method literalAt: (extA bitShift: 8) + byte + 1.
				 bytecode = 227 ifTrue:
					[^client pushLiteralVariable: literal].
				 ^client pushConstant: literal].
			bytecode = 229 ifTrue:
				[^client pushTemporaryVariable: byte]. 
			^client pushClosureTemps: byte]. 
		bytecode = 231 ifTrue:
			[^byte < 128
				ifTrue: [client pushNewArrayOfSize: byte]
				ifFalse: [client pushConsArrayWithElements: byte - 128]].
		bytecode = 232 ifTrue:
			[^client pushConstant: (extB bitShift: 8) + byte].
		^client pushConstant: (Character value: (extB bitShift: 8) + byte)].
	bytecode < 240 ifTrue: "sends, trap and jump"
		[bytecode < 236 "sends" 
			ifTrue: [
			"The 64 is used as a mark to tell if the send is a direct super send"
			extB >= 64 
				ifTrue: [ | fixedExtB |
					fixedExtB := extB - 64.
					^ client 
						 directedSuperSend: (method literalAt: (extA bitShift: 5) + (byte // 8) + 1)
						 numArgs: (fixedExtB bitShift: 3) + (byte \\ 8)].
			^client
				send: (method literalAt: (extA bitShift: 5) + (byte // 8) + 1)
				super: bytecode = 235
				numArgs: (extB bitShift: 3) + (byte \\ 8)].

		 bytecode = 236 ifTrue:
			[^client trapIfNotInstanceOf: (method literalAt: (extA bitShift: 8) + byte + 1)].
		bytecode = 237 ifTrue:
			[^client jump: (extB bitShift: 8) + byte].
		 ^client jump: (extB bitShift: 8) + byte if: bytecode = 238].
	bytecode < 243 ifTrue:
		[bytecode = 240 ifTrue:
			[^client popIntoReceiverVariable: (extA bitShift: 8) + byte].
		 bytecode = 241 ifTrue:
			[^client popIntoLiteralVariable: (method literalAt: (extA bitShift: 8) + byte + 1)].
		 ^client popIntoTemporaryVariable: byte].
	bytecode = 243 ifTrue:
		[^client storeIntoReceiverVariable: (extA bitShift: 8) + byte].
	bytecode = 244 ifTrue:
		[^client storeIntoLiteralVariable: (method literalAt: (extA bitShift: 8) + byte + 1)].
	bytecode = 245 ifTrue:
		[^client storeIntoTemporaryVariable: byte].
	"246-247	1111011 i	xxxxxxxx	UNASSIGNED"
	^self interpretUnusedBytecode: client at: startPC
]

{ #category : #interpreting }
InstructionStream >> interpretNext3ByteSistaV1Instruction: bytecode for: client extA: extA extB: extB startPC: startPC [
	"Send to the argument, client, a message that specifies the next instruction.
	 This method handles the three-byte codes.
	 For a table of the bytecode set, see EncoderForSistaV1's class comment."

	| method byte2 byte3 |
	method := self compiledCode.
	byte2 := method at: pc.
	byte3 := method at: pc + 1.
	pc := pc + 2.
	"we search the bytecodes by what we expect to be the static frequency."
	bytecode = 248 ifTrue:
		[^client callPrimitive: byte2 + (byte3 bitShift: 8)].
	bytecode = 250 ifTrue:
		["**	250  11111010  eeiiikkk  jjjjjjjj  Push Closure Num Copied iii (+ExtA//16*8) Num Args kkk (+ ExtA\\16*8) BlockSize jjjjjjjj (+ExtB*256). ee = num extensions"
		 ^client
			pushClosureCopyNumCopiedValues: ((byte2 bitShift: -3) bitAnd: 7) + (extA // 16 bitShift: 3)
			numArgs: (byte2 bitAnd: 7) + (extA \\ 16 bitShift: 3)
			blockSize: byte3 + (extB bitShift: 8)].
	bytecode = 251 ifTrue:
		[^client pushRemoteTemp: byte2 inVectorAt: byte3].
	bytecode = 252 ifTrue:
		[^client storeIntoRemoteTemp: byte2 inVectorAt: byte3].
	bytecode = 253 ifTrue:
		[^client popIntoRemoteTemp: byte2 inVectorAt: byte3].
	"249		11111001 	xxxxxxxx	syyyyyyy	Reserved for Push Float"
	bytecode = 254 ifTrue: 
		[^client 
			jumpOrPopIfNotInstanceOf: (method literalAt: (extA bitShift: 8) + byte2 + 1) 
			distance: ((extB bitShift: 8) + byte3) ].
	bytecode = 249 ifTrue: 
		[^client 
			pushFullClosure: (method literalAt: (extA bitShift: 8) + byte2 + 1) 
			numCopied: (byte3 bitAnd: 16r3F) 
			receiverOnStack: (byte3 bitAt: 7) = 1
			ignoreOuterContext: (byte3 bitAt: 8) = 1 ].
	^self interpretUnusedBytecode: client at: startPC
]

{ #category : #interpreting }
InstructionStream >> interpretNextInstructionFor: client [ 
	"Send to the argument, client, a message that specifies the type of the 
	next instruction."
	^ self compiledCode encoderClass interpretNextInstructionFor: client  in: self
]

{ #category : #interpreting }
InstructionStream >> interpretNextSistaV1InstructionFor: client [
	"Send to the argument, client, a message that specifies the next instruction."

	| byte div16 offset method extA extB savedPC |
	method := self compiledCode.
	"For a table of the bytecode set, see EncoderForSistaV1's class comment."
	"consume and compute any extensions first."
	extA := extB := 0.
	savedPC := pc.
	[byte := self compiledCode at: pc.
	 pc := pc + 1.
	 byte between: 16rE0 and: 16rE1] whileTrue:
		[| extByte |
		 extByte := self compiledCode at: pc.
		 pc := pc + 1.
		 byte = 16rE0
			ifTrue:
				[extA := (extA bitShift: 8) + extByte]
			ifFalse:
				[extB := (extB = 0 and: [extByte > 127])
							ifTrue: [extByte - 256]
							ifFalse: [(extB bitShift: 8) + extByte]]].
	div16 := byte // 16.
	offset := byte \\ 16.
	"We do an inline quasi-binary search on each of the possible 16 values of div16"
	div16 < 11 ifTrue:
		[div16 < 6 ifTrue:
			[div16 < 4 ifTrue:
				[div16 < 2 ifTrue:
					[div16 = 0 ifTrue:
						 [^client pushReceiverVariable: offset].
					^client pushLiteralVariable: (method literalAt: offset + 1)]. "div16 = 1"
				 ^client pushConstant: (method literalAt: byte \\ 32 + 1)].
			 div16 = 4 ifTrue:
				[offset < 12 ifTrue:
					[^client pushTemporaryVariable: offset].
				 offset = 12 ifTrue:
					[^client pushReceiver].
				 offset = 13 ifTrue:
					[^client pushConstant: true].
				 offset = 14 ifTrue:
					[^client pushConstant: false].
				 offset = 15 ifTrue:
					[^client pushConstant: nil]].
			"div16 = 5"
			 offset < 2 ifTrue:
				[^client pushConstant: offset].
			 offset = 2 ifTrue:
				[^self interpretSistaV1ExtendedPush: extB for: client].
			 offset = 3 ifTrue:
				[^client doDup].
			
			 offset = 8 ifTrue:
				[^client methodReturnReceiver].
			 offset = 9 ifTrue:
				[^client methodReturnConstant: true].
			 offset = 10 ifTrue:
				[^client methodReturnConstant: false].
			 offset = 11 ifTrue:
				[^client methodReturnConstant: nil].
			 offset = 12 ifTrue:
				[^client methodReturnTop].
			 offset = 13 ifTrue:
				[^client blockReturnConstant: nil].
			 offset = 14 ifTrue:
				[^client blockReturnTop].
			 offset = 15 ifTrue:
				[^client doNop].
			 ^self interpretUnusedBytecode: client at: savedPC].
		"short sends"
		div16 = 6 ifTrue:
			[^client
				send: (Smalltalk specialSelectorAt: offset + 1)
				super: false
				numArgs: (Smalltalk specialNargsAt: offset + 1)].
		 div16 = 7 ifTrue:
			[^client
				send: (Smalltalk specialSelectorAt: offset + 17)
				super: false
				numArgs: (Smalltalk specialNargsAt: offset + 17)].
		^client
			send: (method literalAt: offset + 1)
			super: false
			numArgs: div16 - 8].
	"div16 >= 11; bytecode >= 176"
	div16 < 14 ifTrue:
		[div16 = 11 ifTrue:
			[offset < 8 ifTrue:
				[^client jump: offset + 1].
			 ^client jump: offset - 7 if: true].
		 div16 = 12 ifTrue:
			[offset < 8 ifTrue:
				[^client jump: offset + 1 if: false].
			 ^client popIntoReceiverVariable: offset - 8].
		 "div16 = 13"
		 offset < 8 ifTrue:
		 	[^client popIntoTemporaryVariable: offset].
		 offset = 8 ifTrue: [ ^ client doPop ].
		 offset = 9 ifTrue: [ ^ client trap ].
		^self interpretUnusedBytecode: client at: savedPC].
	"2 byte and 3 byte codes"
	byte < 248 ifTrue:
		[^self interpretNext2ByteSistaV1Instruction: byte for: client extA: extA extB: extB startPC: savedPC].
	^self interpretNext3ByteSistaV1Instruction: byte for: client extA: extA extB: extB startPC: savedPC
]

{ #category : #interpreting }
InstructionStream >> interpretNextV3PlusClosureInstructionFor: client [ 
	"Send to the argument, client, a message that specifies the type of the 
	next instruction."

	| byte type offset method |
	method := self compiledCode.  
	byte := method at: pc.
	type := byte // 16.  
	offset := byte \\ 16.   
	pc := pc+1.
	"We do an inline binary search on each of the possible 16 values of type:
	The old, cleaner but slowe code is retained as a comment below"
	type < 8
	ifTrue: [type < 4
				ifTrue: [type < 2
						ifTrue: [type < 1
								ifTrue: ["type = 0"
									^ client pushReceiverVariable: offset]
								ifFalse: ["type = 1"
									^ client pushTemporaryVariable: offset]]
						ifFalse: [type < 3
								ifTrue: ["type = 2"
									^ client
										pushConstant: (method literalAt: offset + 1)]
								ifFalse: ["type = 3"
									^ client
										pushConstant: (method literalAt: offset + 17)]]]
				ifFalse: [type < 6
						ifTrue: [type < 5
								ifTrue: ["type = 4"
									^ client
										pushLiteralVariable: (method literalAt: offset + 1)]
								ifFalse: ["type = 5"
									^ client
										pushLiteralVariable: (method literalAt: offset + 17)]]
						ifFalse: [type < 7
								ifTrue: ["type = 6"
									offset < 8
										ifTrue: [^ client popIntoReceiverVariable: offset]
										ifFalse: [^ client popIntoTemporaryVariable: offset - 8]]
								ifFalse: ["type = 7"
									offset = 0
										ifTrue: [^ client pushReceiver].
									offset < 8
										ifTrue: [^ client
												pushConstant: (SpecialConstants at: offset)].
									offset = 8
										ifTrue: [^ client methodReturnReceiver].
									offset < 12
										ifTrue: [^ client
												methodReturnConstant: (SpecialConstants at: offset - 8)].
									offset = 12
										ifTrue: [^ client methodReturnTop].
									offset = 13
										ifTrue: [^ client blockReturnTop].
									offset > 13
										ifTrue: [^ self interpretUnusedBytecode: client at: pc - 1 ]]]]]
		ifFalse: [type < 12
				ifTrue: [type < 10
						ifTrue: [type < 9
								ifTrue: ["type = 8"
									^ self
										interpretV3PlusClosureExtension: offset 
										in: method 
										for: client]
								ifFalse: ["type = 9 (short jumps)"
									offset < 8
										ifTrue: [^ client jump: offset + 1].
									^ client jump: offset - 8 + 1 if: false]]
						ifFalse: [type < 11
								ifTrue: ["type = 10 (long jumps)"
									byte := method at: pc.
									pc := pc + 1.
									offset < 8
										ifTrue: [^ client jump: offset - 4 * 256 + byte].
									^ client jump: (offset bitAnd: 3)
											* 256 + byte if: offset < 12]
								ifFalse: ["type = 11"
									^ client
										send: (Smalltalk specialSelectorAt: offset + 1)
										super: false
										numArgs: (Smalltalk specialNargsAt: offset + 1)]]]
				ifFalse: [type = 12
						ifTrue: [^ client
								send: (Smalltalk specialSelectorAt: offset + 17)
								super: false
								numArgs: (Smalltalk specialNargsAt: offset + 17)]
						ifFalse: ["type = 13, 14 or 15"
							^ client
								send: (method literalAt: offset + 1)
								super: false
								numArgs: type - 13]]].


"    old code 
	type=0 ifTrue: [^client pushReceiverVariable: offset].
	type=1 ifTrue: [^client pushTemporaryVariable: offset].
	type=2 ifTrue: [^client pushConstant: (method literalAt: offset+1)].
	type=3 ifTrue: [^client pushConstant: (method literalAt: offset+17)].
	type=4 ifTrue: [^client pushLiteralVariable: (method literalAt: offset+1)].
	type=5 ifTrue: [^client pushLiteralVariable: (method literalAt: offset+17)].
	type=6 
		ifTrue: [offset<8
					ifTrue: [^client popIntoReceiverVariable: offset]
					ifFalse: [^client popIntoTemporaryVariable: offset-8]].
	type=7
		ifTrue: [offset=0 ifTrue: [^client pushReceiver].
				offset<8 ifTrue: [^client pushConstant: (SpecialConstants at: offset)].
				offset=8 ifTrue: [^client methodReturnReceiver].
				offset<12 ifTrue: [^client methodReturnConstant: 
												(SpecialConstants at: offset-8)].
				offset=12 ifTrue: [^client methodReturnTop].
				offset=13 ifTrue: [^client blockReturnTop].
				offset>13 ifTrue: [^self error: 'unusedBytecode']].
	type=8 ifTrue: [^self interpretExtension: offset in: method for: client].
	type=9
		ifTrue:  short jumps
			[offset<8 ifTrue: [^client jump: offset+1].
			^client jump: offset-8+1 if: false].
	type=10 
		ifTrue:  long jumps
			[byte:= method at: pc.  pc:= pc+1.
			offset<8 ifTrue: [^client jump: offset-4*256 + byte].
			^client jump: (offset bitAnd: 3)*256 + byte if: offset<12].
	type=11 
		ifTrue: 
			[^client 
				send: (Smalltalk specialSelectorAt: offset+1) 
				super: false
				numArgs: (Smalltalk specialNargsAt: offset+1)].
	type=12 
		ifTrue: 
			[^client 
				send: (Smalltalk specialSelectorAt: offset+17) 
				super: false
				numArgs: (Smalltalk specialNargsAt: offset+17)].
	type>12
		ifTrue: 
			[^client send: (method literalAt: offset+1) 
					super: false
					numArgs: type-13]"
]

{ #category : #interpreting }
InstructionStream >> interpretSistaV1ExtendedPush: extB for: client [ 
	"Implement the extended push for non-zero extensions."
	"*	82			01010010			Push thisContext, (then Extend B = 1 => push
	thisProcess) "
	extB = 0
		ifTrue: [^ client pushActiveContext].
	extB = 1
		ifTrue: [^ client pushActiveProcess].
	self error: 'undefined extended push'

]

{ #category : #interpreting }
InstructionStream >> interpretUnusedBytecode: client at: startPC [
	^ client unusedBytecode
]

{ #category : #interpreting }
InstructionStream >> interpretV3PlusClosureExtension: offset in: method for: client [
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
					super: true numArgs: byte2 // 32].
		offset = 6 ifTrue:   "Second extended send"
			[^client send: (method literalAt: byte2 \\ 64 + 1)
					super: false numArgs: byte2 // 64]].
	offset = 7 ifTrue: [^client doPop].
	offset = 8 ifTrue: [^client doDup].
	offset = 9 ifTrue: [^client pushActiveContext].
	byte2 := method at: pc. pc := pc + 1.
	offset = 10 ifTrue:
		[^byte2 < 128
			ifTrue: [client pushNewArrayOfSize: byte2]
			ifFalse: [client pushConsArrayWithElements: byte2 - 128]].
	byte3 := method at: pc.  pc := pc + 1.
	offset = 11 ifTrue: [^client callPrimitive: byte2 + (byte3 * 256) ].
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

{ #category : #scanning }
InstructionStream >> method [
	"Answer the compiled method that supplies the receiver's bytecodes."

	^sender		"method access when used alone (not as part of a context)"
]

{ #category : #private }
InstructionStream >> method: method pc: startpc [

	sender := method. 
	"allows this class to stand alone as a method scanner"
	pc := startpc
]

{ #category : #scanning }
InstructionStream >> pc [
	"Answer the index of the next bytecode."

	^pc
]

{ #category : #private }
InstructionStream >> pc: anInteger [

	pc := anInteger
]
