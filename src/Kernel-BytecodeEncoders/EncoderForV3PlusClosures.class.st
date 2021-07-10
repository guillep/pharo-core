"
An encoder for the V3 bytecode set augmented with the following bytecodes that are part of the full closure implementation.
	138   10001010 jkkkkkkk		Push (Array new: kkkkkkk) (j = 0)
								or	Pop kkkkkkk elements into: (Array new: kkkkkkk) (j = 1)

	140   10001100 kkkkkkkk jjjjjjjj 	Push Temp At kkkkkkkk In Temp Vector At: jjjjjjjj
	141   10001101 kkkkkkkk jjjjjjjj 	Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj
	142   10001110 kkkkkkkk jjjjjjjj 	Pop and Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj
	143   10001111 llllkkkk jjjjjjjj iiiiiiii	Push Closure Num Copied llll Num Args kkkk BlockSize jjjjjjjjiiiiiiii
This is an exact duplicate of EncoderForLongFormV3PlusClosures.
Could be a trait (or in Newspeak, a Mixin).
For now we impose upon you to synchronise any and all changes between these two classes.
"
Class {
	#name : #EncoderForV3PlusClosures,
	#superclass : #BytecodeEncoder,
	#category : #'Kernel-BytecodeEncoders'
}

{ #category : #'bytecode decoding' }
EncoderForV3PlusClosures class >> backJumpBytecodeSize [
	^ 2
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> bindingReadScanBlockFor: litIndex using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for reads of the value of the binding with zero-relative index litVarIndex.
	 N.B. Don't assume the compiler uses the most compact encoding available."
	^ [:b|
		b >= 64
		and:
			[b <= 95
				ifTrue: [b - 64 = litIndex]
				ifFalse:
					[b = 128
						ifTrue: [scanner secondByte - 192 = litIndex]
						ifFalse:
							[b = 132
							 and: [(scanner secondByte between: 128 and: 159)
							 and: [scanner thirdByte = litIndex]]]]]]
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> bindingWriteScanBlockFor: litVarIndex using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for writes of the value of the binding with zero-relative index litVarIndex.
	 N.B. Don't assume the compiler uses the most compact encoding available."
	^ [:b|
		(b = 129 or: [b = 130])
			ifTrue: [scanner secondByte - 192 = litVarIndex]
			ifFalse:
				[b = 132
				 and: [scanner secondByte >= 224
				 and: [scanner thirdByte = litVarIndex]]]]
]

{ #category : #'block closure support' }
EncoderForV3PlusClosures class >> blockCreationBytecodeMessageAt: startpc method: method [
	"143   10001111 llllkkkk jjjjjjjj iiiiiiii	Push Closure Num Copied llll Num Args kkkk BlockSize jjjjjjjjiiiiiiii"
	^ method abstractBytecodeMessageAt: startpc - 4
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> bytecodeSize: bytecode [
	"Answer the number of bytes in the bytecode."
	bytecode <= 125 ifTrue:
		[^1].
	bytecode >= 176 ifTrue:
		[^1].
	bytecode >= 160 ifTrue: "long jumps"
		[^2].
	bytecode >= 144 ifTrue: "short jumps"
		[^1].
	"extensions"
	bytecode >= 128 ifTrue:
		[^#(2 2 2 2 3 2 2 1 1 1 2 3 3 3 3 4) at: bytecode - 127].
	^nil
]

{ #category : #'bytecode decoding' }
EncoderForV3PlusClosures class >> callPrimitiveCode [
	"139	11101111	iiiiiiii jjjjjjjj	Call Primitive #iiiiiiii + (jjjjjjjj * 256)"
	^139
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> firstSpecialSelectorByte [
	^ 16rAF
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> instVarReadScanBlockFor: varIndexCode using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for reads of the inst var with zero-relative index varIndexCode.
	 N.B. Don't assume the compiler uses the most compact encoding available."
	^ [:b|
		b < 16
			ifTrue: [b = varIndexCode]
			ifFalse:
				[b = 128
					ifTrue: [scanner secondByte = varIndexCode and: [varIndexCode <= 63]]
					ifFalse:
						[b = 132
						 and: [(scanner secondByte between: 64 and: 95)
						 and: [scanner thirdByte = varIndexCode]]]]]
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> instVarWriteScanBlockFor: varIndexCode using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for writes of the inst var with zero-relative index varIndexCode.
	 N.B. Don't assume the compiler uses the most compact encoding available."
	^ [:b|
		b >= 96
		and: [b <= 103
				ifTrue: [b - 96 = varIndexCode]
				ifFalse:
					[(b = 129 or: [b = 130])
						ifTrue: [scanner secondByte = varIndexCode and: [varIndexCode <= 63]]
						ifFalse:
							[b = 132
							 and: [(scanner secondByte between: 160 and: 223)
							 and: [scanner thirdByte = varIndexCode]]]]]]
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> interpretNextInstructionFor: aClient in: anInstructionStream [
	"Double-dispatch through the encoder to select the correct instruction set decoder."
	^ anInstructionStream interpretNextV3PlusClosureInstructionFor: aClient
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isBlockReturnAt: pc in: method [
	^ (method at: pc) =  125
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isBranchIfFalseAt: pc in: method [
	"Answer whether the bytecode at pc is a conditional branch-if-false."
	
	
	| byte |
	byte := method at: pc.
	^(byte between: 152 and: 159) or: [byte between: 172 and: 175]
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isBranchIfTrueAt: pc in: method [
	"Answer whether the bytecode at pc is a conditional branch-if-true."
	
	| byte |
	byte := method at: pc.
	^ byte between: 168 and: 171
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isCreateBlockAt: pc in: method [
	^ (method at: pc) = 143
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isCreateFullBlockAt: pc in: code [
	"full blocks not supported"
	^false
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isExtension: byte [
	"no extension byteocde in this set"
	^ false
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isJumpAt: pc in: method [
	"Answer whether the bytecode at pc is an (unconditional) jump."

	| byte |
	byte := method at: pc.
	^ (byte between: 144 and: 151) or: [byte between: 160 and: 167]
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isJustPopAt: pc in: method [
	"Answer whether the bytecode at pc is a pop."

	^ (method at: pc) = 135
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isPushTempAt: pc in: method [
	| byte |
	((byte := method at: pc) between: 16 and: 31) ifTrue: [ ^ true ].
	^ byte = 128 and: [ (method at: pc + 1) >> 6 = 1 ]
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isReturnAt: pc in: method [
	"Answer whether the bytecode at pc is a return from block."
	
	^(method at: pc) between: 120 and: 125
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isSendAt: pc in: method [
	"Answer whether the bytecode at pc is a message-send."
	
	| byte |
	byte := method at: pc.
	^byte >= 131
	  and: [ "special send or short send" 
		byte >= 176 or: [ "long sends" byte <= 134]]
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isStoreAt: pc in: method [
	"Answer whether the bytecode at pc is a store or store-pop."

	| byte |
	byte := method at: pc.
	^(byte between: 96 and: 142)
		and: [
			"96 103		storeAndPopReceiverVariableBytecode"
			"104 111	storeAndPopTemporaryVariableBytecode"
			byte <= 111 
			or: [
				"129		extendedStoreBytecode"
				byte >= 129
				and: [
					"130		extendedStoreAndPopBytecode"
					byte <= 130
					or: [(
							"132		doubleExtendedDoAnythingBytecode"
							byte = 132	 
							and: [ (method at: pc+1) >= 160 ])
					or: [
						"141		storeRemoteTempLongBytecode"
						byte = 141
					or: [
						"142		storeAndPopRemoteTempLongBytecode"
						byte = 142]]]]]]
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> isStorePopAt: pc in: method [
	"Answer whether the bytecode at pc is a store or store-pop."
	
	| byte |
	byte := method at: pc.
	"130		extendedStoreAndPopBytecode"
	^ byte = 130
		or: [
			"142		storeAndPopRemoteTempLongBytecode"
			byte = 142
		or: [
			"96 103		storeAndPopReceiverVariableBytecode"
			"104 111	storeAndPopTemporaryVariableBytecode"
			byte between: 96 and: 111 ]]
]

{ #category : #accessing }
EncoderForV3PlusClosures class >> literalMethodBytecodes [
	"#[32 124] means pushConstant: x, returnTop" 
	
	^ #[32 124] 
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> markerOrNilFor: aMethod [
	"What is a marker method?  It is method with body like 
		'self subclassResponsibility' or '^ self subclassResponsibility' 
	used to indicate ('mark') a special property.

	Marker methods compile to bytecode like:

		9 <70> self
		10 <D0> send: <literal 1>
		11 <87> pop
		12 <78> returnSelf

	for the first form, or 

		9 <70> self
		10 <D0> send: <literal 1>
		11 <7C> returnTop

	for the second form."

	| expectedHeaderPlusLliteralSize e |
  	expectedHeaderPlusLliteralSize := Smalltalk wordSize * 4.
  	^(((e := aMethod endPC - expectedHeaderPlusLliteralSize) = 3 or: [e = 4]) 
    	and: [aMethod numLiterals = 3
    	and: [(aMethod at:  expectedHeaderPlusLliteralSize + 1) = 16r70 "push self"
    	and: [(aMethod at: expectedHeaderPlusLliteralSize + 2) = 16rD0]]])  "send <literal 1>"
    	ifTrue: [aMethod literalAt: 1]
]

{ #category : #'block closure support' }
EncoderForV3PlusClosures class >> methodReturnBytecodes [
	^ 120 to: 124
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> nonExtensionBytecodeAt: pc in: method [
	"Answer the actual bytecode at pc in method, skipping past any preceeding extensions."
	^ method at: pc
]

{ #category : #'block closure support' }
EncoderForV3PlusClosures class >> numLocalTempsForBlockAt: startpc in: method [
	"4 = size of push closure copy bytecode"
	^ BlockLocalTempCounter
		tempCountForBlockAt: startpc - 4 
		in: method 
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> prepareMethod: compiledMethod forSimulationWith: numArgs [
	| xpc |
	xpc := compiledMethod initialPC.
	"long store temp"
	(compiledMethod at: xpc) = 129 
		ifTrue: [
			compiledMethod at: xpc + 1 put: (16r40 + numArgs).
			compiledMethod at: xpc + 3 put: (16r10 + numArgs)]
]

{ #category : #'bytecode decoding' }
EncoderForV3PlusClosures class >> pushNilByte [
	^ 115
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> readsSelfFor: compiledMethod [
	"Answer whether compiledMethod reads self"
	| scanner |
	scanner := InstructionStream on: compiledMethod.
	^ scanner scanFor: [:instr | instr = 112 ]
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> readsThisContextFor: compiledMethod [
	"Answer whether compiledMethod reads thisContext"
	| scanner |
	scanner := InstructionStream on: compiledMethod.
	^ scanner scanFor: [:instr | instr = 137 ]
]

{ #category : #'instruction stream support' }
EncoderForV3PlusClosures class >> selectorToSendOrItselfFor: anInstructionStream in: method at: pc [
	"If anInstructionStream is at a send bytecode then answer the send's selector,
	 otherwise answer anInstructionStream itself.  The rationale for answering
	 anInstructionStream instead of, say, nil, is that potentially any existing object
	 can be used as a selector, but since anInstructionStream postdates the method,
	 it can't be one of them."

	| byte byte2 |
	byte := method at: pc.
	byte < 131 ifTrue: [^ anInstructionStream].
	byte >= 176
		ifTrue: [
			"special byte or short send"
			byte >= 208
				ifTrue: [^ method literalAt: (byte bitAnd: 15) + 1]
				ifFalse: [^ Smalltalk specialSelectorAt: byte - 176 + 1]]
		ifFalse: [
			byte <= 134 
				ifTrue: [ 
					byte2 := method at: pc + 1.
					byte = 131 ifTrue: [^ method literalAt: byte2 \\ 32 + 1].
					byte = 132 ifTrue: [
						byte2 < 64 ifTrue: [^ method literalAt: ( method at: pc + 2) + 1]]	.
					byte = 133 ifTrue: [^ method literalAt: byte2 \\ 32 + 1].
					byte = 134 ifTrue: [^ method literalAt: byte2 \\ 64 + 1]]].
	^ anInstructionStream
]

{ #category : #'compiled method support' }
EncoderForV3PlusClosures class >> sendsToSuperFor: compiledMethod [
	"Answer whether the receiver sends any message to super."
	| scanner |
	scanner := InstructionStream on: compiledMethod.
	^ scanner scanFor: [:instr |
			instr = 16r85 or: [instr = 16r84 and: [scanner secondByte between: 16r20 and: 16r3F ] ] ]
]

{ #category : #'bytecode decoding' }
EncoderForV3PlusClosures class >> specialLiterals [
	^ #(true false nil -1 0 1 2) 
]

{ #category : #'bytecode decoding' }
EncoderForV3PlusClosures class >> unusedBytecode [
	"Answer the opcode of a single-byte unused bytecode, if it exists in the encoder's bytecode set, or nil if not."
	^ 126
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genBranchPopFalse: distance [
	"See BlueBook page 596"
	distance < 0 ifTrue:
		[^self outOfRangeError: 'distance' index: distance range: 0 to: 1023].
	(distance > 0 and: [distance < 9]) ifTrue:
		["152-159 	10011iii 	Pop and Jump 0n False iii +1 (i.e., 1 through 8)"
		 stream nextPut: 152 + distance - 1.
		 ^self].
	distance < 1024 ifTrue:
		["172-175 	101011ii jjjjjjjj 	Pop and Jump On False ii *256+jjjjjjjj"
		 stream
			nextPut: 172 + (distance bitShift: -8);
			nextPut: distance + 1024 \\ 256.
		 ^self].
	^self outOfRangeError: 'distance' index: distance range: 0 to: 1023
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genBranchPopTrue: distance [
	"See BlueBook page 596"
	distance < 0 ifTrue:
		[^self outOfRangeError: 'distance' index: distance range: 0 to: 1023].
	distance < 1024 ifTrue:
		["168-171 	101010ii jjjjjjjj 	Pop and Jump On True ii *256+jjjjjjjj"
		 stream
			nextPut: 168 + (distance bitShift: -8);
			nextPut: distance + 1024 \\ 256.
		 ^self].
	^self outOfRangeError: 'distance' index: distance range: 0 to: 1023
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genCallPrimitive: primitiveIndex [
	"139	11101111	iiiiiiii jjjjjjjj	Call Primitive #iiiiiiii + (jjjjjjjj * 256)"
	(primitiveIndex < 1 or: [primitiveIndex > 65535]) ifTrue:
		[self outOfRangeError: 'primitive index' index: primitiveIndex range: 1 to: 65535].
	stream
		nextPut: 139;
		nextPut: (primitiveIndex bitAnd: 255);
		nextPut: (primitiveIndex bitShift: -8)
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genDup [
	"See BlueBook page 596"
	"136 	10001000 	Duplicate Stack Top"
	stream nextPut: 136
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genJump: distance [
	"See BlueBook page 596"
	(distance > 0 and: [distance < 9]) ifTrue:
		["144-151 	10010iii 	Jump iii + 1 (i.e., 1 through 8)"
		 stream nextPut: 144 + distance - 1.
		 ^self].
	"160-167 	10100iii jjjjjjjj 	Jump(iii - 4) *256+jjjjjjjj"
	^self genJumpLong: distance
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genJumpLong: distance [
	"See BlueBook page 596"
	(distance >= -1024 and: [distance < 1024]) ifTrue:
		["160-167 	10100iii jjjjjjjj 	Jump(iii - 4) *256+jjjjjjjj"
		 stream
			nextPut: 160 + (distance + 1024 bitShift: -8);
			nextPut: distance + 1024 \\ 256.
		 ^self].
	^self outOfRangeError: 'distance' index: distance range: -1024 to: 1023
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPop [
	"See BlueBook page 596"
	"135 	10000111 	Pop Stack Top"
	stream nextPut: 135
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushClosureCopyNumCopiedValues: numCopied numArgs: numArgs jumpSize: jumpSize [
	"143 	10001111 llllkkkk jjjjjjjj iiiiiiii	Push Closure Num Copied llll Num Args kkkk BlockSize jjjjjjjjiiiiiiii"
	(jumpSize < 0 or: [jumpSize > 65535]) ifTrue:
		[^self outOfRangeError: 'block size' index: jumpSize range: 0 to: 65535].
	(numCopied < 0 or: [numCopied > 15]) ifTrue:
		[^self outOfRangeError: 'num copied' index: numCopied range: 0 to: 15].
	(numArgs < 0 or: [numArgs > 15]) ifTrue:
		[^self outOfRangeError: 'num args' index: numArgs range: 0 to: 15].
	stream
		nextPut: 143;
		nextPut: numArgs + (numCopied bitShift: 4);
		nextPut: (jumpSize bitShift: -8);
		nextPut: (jumpSize bitAnd: 16rFF)
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushConsArray: size [
	(size < 0 or: [size > 127]) ifTrue:
		[^self outOfRangeError: 'numElements' index: size range: 0 to: 127].
	"138 	10001010 1kkkkkkk 	Push (Array new: kkkkkkk)"
	stream
		nextPut: 138;
		nextPut: size + 128
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushInstVar: instVarIndex [
	"See BlueBook page 596"
	instVarIndex >= 0 ifTrue:
		[instVarIndex < 16 ifTrue:
			["0-15 	0000iiii 	Push Receiver Variable #iiii"
			 stream nextPut: 0 + instVarIndex.
			 ^self].
		instVarIndex < 64 ifTrue:
			["128 	10000000 jjkkkkkk 	Push (Receiver Variable, Temporary Location, Literal Constant, Literal Variable) [jj] #kkkkkk"
			 stream
				nextPut: 128;
				nextPut: instVarIndex.
			 ^self]].
	self genPushInstVarLong: instVarIndex
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushInstVarLong: instVarIndex [
	"See BlueBook page 596"
	"See also MaybeContextInstanceVariableNode"
	(instVarIndex >= 0 and: [instVarIndex < 256]) ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 64;
			nextPut: instVarIndex.
		 ^self].
	^self outOfRangeError: 'index' index: instVarIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushLiteral: literalIndex [
	"See BlueBook page 596"
	literalIndex < 0 ifTrue: 
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255].
	literalIndex < 32 ifTrue: 
		["32-63 	001iiiii 	Push Literal Constant #iiiii"
		 stream nextPut: 32 + literalIndex.
		 ^self].
	literalIndex < 64 ifTrue: 
		["128 	10000000 jjkkkkkk 	Push (Receiver Variable, Temporary Location, Literal Constant, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 128;
			nextPut: 128 + literalIndex.
		 ^self].
	literalIndex < 256 ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 96;
			nextPut: literalIndex.
		 ^self].
	^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushLiteralVar: literalIndex [
	"See BlueBook page 596"
	literalIndex < 0 ifTrue: 
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255].
	literalIndex < 32 ifTrue: 
		["64-95 	010iiiii 	Push Literal Variable #iiiii"
		 stream nextPut: 64 + literalIndex.
		 ^self].
	literalIndex < 64 ifTrue: 
		["128 	10000000 jjkkkkkk 	Push (Receiver Variable, Temporary Location, Literal Constant, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 128;
			nextPut: 192 + literalIndex.
		 ^self].
	literalIndex < 256 ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 128;
			nextPut: literalIndex.
		 ^self].
	^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushNewArray: size [
	(size < 0 or: [size > 127]) ifTrue:
		[^self outOfRangeError: 'numElements' index: size range: 0 to: 127].
	"138 	10001010 0kkkkkkk 	Pop kkkkkkk into: (Array new: kkkkkkk)"
	stream
		nextPut: 138;
		nextPut: size
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushReceiver [
	"See BlueBook page 596"
	"112-119 	01110iii 	Push (receiver, true, false, nil, -1, 0, 1, 2) [iii]"
	stream nextPut: 112
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushRemoteTemp: tempIndex inVectorAt: tempVectorIndex [
	(tempIndex >= 0 and: [tempIndex < 256
	 and: [tempVectorIndex >= 0 and: [tempVectorIndex < 256]]]) ifTrue:
		["140 	10001100 kkkkkkkk jjjjjjjj 	Push Temp At kkkkkkkk In Temp Vector At: jjjjjjjj"
		 stream
			nextPut: 140;
			nextPut: tempIndex;
			nextPut: tempVectorIndex.
		 ^self].
	tempIndex >= 256 ifTrue:
		[^self outOfRangeError: 'remoteTempIndex' index: tempIndex range: 0 to: 255].
	tempVectorIndex >= 256 ifTrue:
		[^self outOfRangeError: 'tempVectorIndex' index: tempVectorIndex range: 0 to: 255]
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushSpecialLiteral: aLiteral [
	"112-119 	01110iii 	Push (receiver, true, false, nil, -1, 0, 1, 2) [iii]"
	| index |
	index := #(true false nil -1 0 1 2) indexOf: aLiteral ifAbsent: 0.
	index = 0 ifTrue:
		[^self error: 'push special literal: ', aLiteral printString,  ' is not one of true false nil -1 0 1 2'].
	stream nextPut: index + 112
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushTemp: tempIndex [
	"See BlueBook page 596"
	tempIndex < 0 ifTrue:
		[^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63].
	tempIndex < 16 ifTrue: 
		["16-31 	0001iiii 	Push Temporary Location #iiii"
		 stream nextPut: 16 + tempIndex.
		 ^self].
	tempIndex < 64 ifTrue: 
		["128 	10000000 jjkkkkkk 	Push (Receiver Variable, Temporary Location, Literal Constant, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 128;
			nextPut: 64 + tempIndex.
		 ^self].
	^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genPushThisContext [
	"See BlueBook page 596"
	"137 	10001001 	Push Active Context"
	stream nextPut: 137
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genReturnReceiver [
	"See BlueBook page 596"
	"120-123 	011110ii 	Return (receiver, true, false, nil) [ii] From Message"
	stream nextPut: 120
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genReturnSpecialLiteral: aLiteral [
	"120-123 	011110ii 	Return (receiver, true, false, nil) [ii] From Message"
	| index |
	index := #(true false nil) indexOf: aLiteral ifAbsent: 0.
	index = 0 ifTrue:
		[^self error: 'return special literal: ', aLiteral printString,  ' is not one of true false nil'].
	stream nextPut: 120 + index
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genReturnTop [
	"See BlueBook page 596"
	"124-125 	0111110i 	Return Stack Top From (Message, Block) [i]"
	stream nextPut: 124
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genReturnTopToCaller [
	"See BlueBook page 596"
	"124-125 	0111110i 	Return Stack Top From (Message, Block) [i]"
	stream nextPut: 125
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genSend: selectorLiteralIndex numArgs: nArgs [
	"See BlueBook page 596 (with exceptions for 132 & 134)"
	nArgs < 0 ifTrue:
		[^self outOfRangeError: 'numArgs' index: nArgs range: 0 to: 31 "!!"].
	selectorLiteralIndex < 0 ifTrue:
		["Special selector sends.
			176-191 	1011iiii 	Send Arithmetic Message #iiii
			192-207 	1100iiii 	Send Special Message #iiii"
		 (selectorLiteralIndex negated between: 176 and: 207) ifFalse:
			[^self outOfRangeError: 'special selector code' index: selectorLiteralIndex negated range: 176 to: 207].
		 stream nextPut: selectorLiteralIndex negated.
		 ^self].
	(selectorLiteralIndex < 16 and: [nArgs < 3]) ifTrue:
		["	208-223 	1101iiii 	Send Literal Selector #iiii With No Arguments
			224-239 	1110iiii 	Send Literal Selector #iiii With 1 Argument
			240-255 	1111iiii 	Send Literal Selector #iiii With 2 Arguments"
		 stream nextPut: 208 + (nArgs * 16) + selectorLiteralIndex.
		 ^self].
	(selectorLiteralIndex < 32 and: [nArgs < 8]) ifTrue: 
		["	131 	10000011 jjjkkkkk 	Send Literal Selector #kkkkk With jjj Arguments"
		 stream
			nextPut: 131;
			nextPut: ((nArgs bitShift: 5) + selectorLiteralIndex).
		 ^self].
	(selectorLiteralIndex < 64 and: [nArgs < 4]) ifTrue: 
	 	["In Squeak V3
			134 	10000110 jjjjjjjj kkkkkkkk 	Send Literal Selector #kkkkkkkk To Superclass With jjjjjjjj Arguments
		 is replaced by
			134 	10000110 jjkkkkkk 	Send Literal Selector #kkkkkk With jj Arguments"
		 stream
			nextPut: 134;
			nextPut: ((nArgs bitShift: 6) + selectorLiteralIndex).
		 ^self].
	(selectorLiteralIndex < 256 and: [nArgs < 32]) ifTrue: 
		["In Squeak V3
			132 	10000100 jjjjjjjj kkkkkkkk 	Send Literal Selector #kkkkkkkk With jjjjjjjj Arguments
		  is replaced by
			132 	10000100 ooojjjjj kkkkkkkk
				ooo = 0 => Send Literal Selector #kkkkkkkk With jjjjj Arguments
				ooo = 1 => Send Literal Selector #kkkkkkkk To Superclass With jjjjj Arguments"
		stream
			nextPut: 132;
			nextPut: nArgs;
			nextPut: selectorLiteralIndex.
		 ^self].
	nArgs >= 32 ifTrue:
		[^self outOfRangeError: 'numArgs' index: nArgs range: 0 to: 31].
	selectorLiteralIndex >= 256 ifTrue: 
		[^self outOfRangeError: 'selector literal index' index: selectorLiteralIndex range: 0 to: 255]
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genSendSpecial: specialSelectorIndex numArgs: nArgs [
	self assert: (specialSelectorIndex between: 1 and: Smalltalk specialSelectorSize).
	self assert: nArgs = (Smalltalk specialNargsAt: specialSelectorIndex).
	"Special selector sends.
		96-111		0110 iiii			Send Arithmetic Message #iiii #(#+ #- #< #> #'<=' #'>=' #= #'~=' #* #/ #'\\' #@ #bitShift: #'//' #bitAnd: #bitOr:)
		112-119	01110 iii			Send Special Message #iii #(#at: #at:put: #size ? ? ? #'==' class ? value value: ? ? ? ? ?)"

	stream nextPut: specialSelectorIndex + 175
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genSendSuper: selectorLiteralIndex numArgs: nArgs [
	"See BlueBook page 596 (with exceptions for 132 & 134)"
	nArgs < 0 ifTrue:
		[^self outOfRangeError: 'numArgs' index: nArgs range: 0 to: 31 "!!"].
	selectorLiteralIndex < 0 ifTrue:
		[^self outOfRangeError: 'selector literal index' index: selectorLiteralIndex range: 0 to: 255].
	(selectorLiteralIndex < 32 and: [nArgs < 8]) ifTrue: 
		["	133 	10000011 jjjkkkkk 	Send Literal Selector #kkkkk To Superclass With jjj Arguments"
		 stream
			nextPut: 133;
			nextPut: ((nArgs bitShift: 5) + selectorLiteralIndex).
		 ^self].
	(selectorLiteralIndex < 256 and: [nArgs < 32]) ifTrue: 
		["In Squeak V3
			132 	10000100 jjjjjjjj kkkkkkkk 	Send Literal Selector #kkkkkkkk With jjjjjjjj Arguments
		  is replaced by
			132 	10000100 ooojjjjj kkkkkkkk
				ooo = 0 => Send Literal Selector #kkkkkkkk With jjjjj Arguments
				ooo = 1 => Send Literal Selector #kkkkkkkk To Superclass With jjjjj Arguments"
		stream
			nextPut: 132;
			nextPut: 32 + nArgs;
			nextPut: selectorLiteralIndex.
		 ^self].
	nArgs >= 32 ifTrue:
		[^self outOfRangeError: 'numArgs' index: nArgs range: 0 to: 31].
	selectorLiteralIndex >= 256 ifTrue: 
		[^self outOfRangeError: 'selector literal index' index: selectorLiteralIndex range: 0 to: 255]
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStoreInstVar: instVarIndex [
	"See BlueBook page 596"
	(instVarIndex >= 0 and: [instVarIndex < 64]) ifTrue: 
		["129 	10000001 jjkkkkkk 	Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 129;
			nextPut: instVarIndex.
		 ^self].
	self genStoreInstVarLong: instVarIndex
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStoreInstVarLong: instVarIndex [
	"See BlueBook page 596"
	"See also MaybeContextInstanceVariableNode"
	(instVarIndex >= 0 and: [instVarIndex < 256]) ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 160;
			nextPut: instVarIndex.
		 ^self].
	^self outOfRangeError: 'index' index: instVarIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStoreLiteralVar: literalIndex [
	"See BlueBook page 596"
	literalIndex < 0 ifTrue:
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255].
	literalIndex < 64 ifTrue: 
		["129 	10000001 jjkkkkkk 	Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 129;
			nextPut: 192 + literalIndex.
		 ^self].
	literalIndex < 256 ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 224;
			nextPut: literalIndex.
		 ^self].
	^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStorePopInstVar: instVarIndex [
	"See BlueBook page 596"
	instVarIndex >= 0 ifTrue:
		[instVarIndex < 8 ifTrue:
			["96-103 	01100iii 	Pop and Store Receiver Variable #iii"
			 stream nextPut: 96 + instVarIndex.
			 ^self].
		instVarIndex < 64 ifTrue:
			["130 	10000010 jjkkkkkk 	Pop and Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
			 stream
				nextPut: 130;
				nextPut: instVarIndex.
			 ^self]].
	self genStorePopInstVarLong: instVarIndex
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStorePopInstVarLong: instVarIndex [
	"See BlueBook page 596"
	"See also MaybeContextInstanceVariableNode"
	(instVarIndex >= 0 and: [instVarIndex < 256]) ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 192;
			nextPut: instVarIndex.
		 ^self].
	^self outOfRangeError: 'index' index: instVarIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStorePopLiteralVar: literalIndex [
	"See BlueBook page 596"
	literalIndex < 0 ifTrue:
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255].
	literalIndex < 64 ifTrue: 
		["130 	10000010 jjkkkkkk 	Pop and Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 130;
			nextPut: 192 + literalIndex.
		 ^self].
	literalIndex < 256 ifTrue: 
		["132 	10000100 iiijjjjj kkkkkkkk 	(Send, Send Super, Push Receiver Variable, Push Literal Constant, Push Literal Variable, Store Receiver Variable, Store-Pop Receiver Variable, Store Literal Variable)[iii] #kkkkkkkk jjjjj"
		 stream
			nextPut: 132;
			nextPut: 224;
			nextPut: literalIndex.
		 self genPop.
		 ^self].
	^self outOfRangeError: 'index' index: literalIndex range: 0 to: 255
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStorePopRemoteTemp: tempIndex inVectorAt: tempVectorIndex [
	"142 	10001110 kkkkkkkk jjjjjjjj 	Pop and Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj"
	(tempIndex >= 0 and: [tempIndex < 256
	 and: [tempVectorIndex >= 0 and: [tempVectorIndex < 256]]]) ifTrue:
		[stream
			nextPut: 142;
			nextPut: tempIndex;
			nextPut: tempVectorIndex.
		 ^self].
	tempIndex >= 256 ifTrue:
		[^self outOfRangeError: 'remoteTempIndex' index: tempIndex range: 0 to: 255].
	tempVectorIndex >= 256 ifTrue:
		[^self outOfRangeError: 'tempVectorIndex' index: tempVectorIndex range: 0 to: 255]
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStorePopTemp: tempIndex [
	"See BlueBook page 596"
	tempIndex < 0 ifTrue:
		[^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63].
	tempIndex < 8 ifTrue: 
		["104-111 	01101iii 	Pop and Store Temporary Location #iii"
		 stream nextPut: 104 + tempIndex.
		 ^self].
	tempIndex < 64 ifTrue: 
		["130 	10000010 jjkkkkkk 	Pop and Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 130;
			nextPut: 64 + tempIndex.
		 ^self].
	^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStoreRemoteTemp: tempIndex inVectorAt: tempVectorIndex [
	"141 	10001101 kkkkkkkk jjjjjjjj 	Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj"
	(tempIndex >= 0 and: [tempIndex < 256
	 and: [tempVectorIndex >= 0 and: [tempVectorIndex < 256]]]) ifTrue:
		[stream
			nextPut: 141;
			nextPut: tempIndex;
			nextPut: tempVectorIndex.
		 ^self].
	tempIndex >= 256 ifTrue:
		[^self outOfRangeError: 'remoteTempIndex' index: tempIndex range: 0 to: 255].
	tempVectorIndex >= 256 ifTrue:
		[^self outOfRangeError: 'tempVectorIndex' index: tempVectorIndex range: 0 to: 255]
]

{ #category : #'bytecode generation' }
EncoderForV3PlusClosures >> genStoreTemp: tempIndex [
	"See BlueBook page 596"
	tempIndex < 0 ifTrue:
		[^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63].
	tempIndex < 64 ifTrue: 
		["129 	10000001 jjkkkkkk 	Store (Receiver Variable, Temporary Location, Illegal, Literal Variable) [jj] #kkkkkk"
		 stream
			nextPut: 129;
			nextPut: 64 + tempIndex.
		 ^self].
	^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63
]

{ #category : #testing }
EncoderForV3PlusClosures >> isSpecialLiteralForPush: literal [
	^ literal == false
		or:
			[ 
			literal == true
				or:
					[ 
					literal isNil
						or: [ literal isInteger and: [ literal between: -1 and: 2 ] ] ] ]
]
