"
I am a support class for the decompiler that is used to find the number of local temps in a block by finding out what the stack offset is at the end of a block.
"
Class {
	#name : #BlockLocalTempCounter,
	#superclass : #InstructionClient,
	#instVars : [
		'stackPointer',
		'scanner',
		'blockEnd',
		'joinOffsets'
	],
	#category : #'Debugging-Core'
}

{ #category : #'instance creation' }
BlockLocalTempCounter class >> tempCountForBlockAt: pc in: method [
	^self new tempCountForBlockAt: pc in: method
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> blockReturnConstant: cst [
	"Return Top Of Stack bytecode."
	scanner pc < blockEnd ifTrue:
		[self doJoin]
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> blockReturnTop [
	"Return Top Of Stack bytecode."
	stackPointer := stackPointer - 1.
	scanner pc < blockEnd ifTrue:
		[self doJoin]
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> directedSuperSend: selector numArgs: numArgs [
	"Send Message Above Specific Class With Selector, selector, bytecode.
	 Start the lookup above the class that is the value of the association on
	 top of stack. The arguments  of the message are found in the top numArgs
	 stack locations beneath the association, and the receiver just below them."

	stackPointer := stackPointer - (numArgs + 1)
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> doDup [
	"Duplicate Top Of Stack bytecode."
	stackPointer := stackPointer + 1
]

{ #category : #private }
BlockLocalTempCounter >> doJoin [
	scanner pc < blockEnd ifTrue:
		[stackPointer := joinOffsets at: scanner pc]
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> doPop [
	"Remove Top Of Stack bytecode."
	stackPointer := stackPointer - 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> jump: offset [
	"Unconditional Jump bytecode."
	offset > 0 ifTrue:
		[joinOffsets at: scanner pc + offset put: stackPointer.
		 self doJoin]
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> jump: offset if: condition [ 
	"Conditional Jump bytecode."
	stackPointer := stackPointer - 1.
	offset > 0 ifTrue:
		[joinOffsets at: scanner pc + offset put: stackPointer]
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> methodReturnConstant: value [ 
	"Return Constant bytecode."
	self doJoin
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> methodReturnReceiver [
	"Return Self bytecode."
	self doJoin
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> methodReturnTop [
	"Return Top Of Stack bytecode."
	stackPointer := stackPointer - 1.
	self doJoin
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> popIntoLiteralVariable: anAssociation [ 
	"Remove Top Of Stack And Store Into Literal Variable bytecode."
	stackPointer := stackPointer - 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> popIntoReceiverVariable: offset [ 
	"Remove Top Of Stack And Store Into Instance Variable bytecode."
	stackPointer := stackPointer - 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> popIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	"Remove Top Of Stack And Store Into Offset of Temp Vector bytecode."
	stackPointer := stackPointer - 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> popIntoTemporaryVariable: offset [ 
	"Remove Top Of Stack And Store Into Temporary Variable bytecode."
	stackPointer := stackPointer - 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> pushActiveContext [
	"Push Active Context On Top Of Its Own Stack bytecode."
	stackPointer := stackPointer + 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> pushClosureCopyNumCopiedValues: numCopied numArgs: numArgs blockSize: blockSize [
	"Push Closure bytecode.  Either compute the end of the block if this is
	 the block we're analysing, or skip it, adjusting the stack as appropriate."
	blockEnd
		ifNil: [blockEnd := scanner pc + blockSize]
		ifNotNil:
			[stackPointer := stackPointer - numCopied + 1.
			 scanner pc: scanner pc + blockSize]
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> pushConsArrayWithElements: numElements [
	"Push Cons Array of size numElements popping numElements items from the stack into the array bytecode."
	stackPointer := stackPointer - numElements + 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> pushConstant: value [
	"Push Constant, value, on Top Of Stack bytecode."
	stackPointer := stackPointer + 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> pushLiteralVariable: anAssociation [
	"Push Contents Of anAssociation On Top Of Stack bytecode."
	stackPointer := stackPointer + 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> pushNewArrayOfSize: numElements [ 
	"Push New Array of size numElements bytecode."
	stackPointer := stackPointer + 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> pushReceiver [
	"Push Active Context's Receiver on Top Of Stack bytecode."
	stackPointer := stackPointer + 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> pushReceiverVariable: offset [
	"Push Contents Of the Receiver's Instance Variable Whose Index 
	is the argument, offset, On Top Of Stack bytecode."
	stackPointer := stackPointer + 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> pushRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	"Push Contents at Offset in Temp Vector bytecode."
	stackPointer := stackPointer + 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> pushTemporaryVariable: offset [
	"Push Contents Of Temporary Variable Whose Index Is the 
	argument, offset, On Top Of Stack bytecode."
	stackPointer := stackPointer + 1
]

{ #category : #'instruction decoding' }
BlockLocalTempCounter >> send: selector super: supered numArgs: numberArguments [
	"Send Message With Selector, selector, bytecode. The argument, 
	supered, indicates whether the receiver of the message is specified with 
	'super' in the source method. The arguments of the message are found in 
	the top numArguments locations on the stack and the receiver just 
	below them."

	stackPointer := stackPointer - numberArguments
]

{ #category : #initialization }
BlockLocalTempCounter >> tempCountForBlockAt: pc in: method [
	"Compute the number of local temporaries in a block.
	 If the block begins with a sequence of push: nil bytecodes then some of
	 These could be initializing local temps.  We can only reliably disambuguate
	 them from other uses of nil by parsing the stack and seeing what the offset
	 of the stack pointer is at the end of the block.

	 There are short-cuts.  The ones we take here are
		- if there is no sequence of push nils there can be no local temps
		- we follow forward jumps to shorten the amount of scanning"
	stackPointer := 0.
	scanner := InstructionStream new method: method pc: pc.
	scanner interpretNextInstructionFor: self.
	blockEnd ifNil:
		[self error: 'pc is not that of a block'].
	scanner peekByte = method encoderClass pushNilByte ifTrue: [
		joinOffsets := Dictionary new.
		[scanner pc < blockEnd] whileTrue: [
			scanner interpretNextInstructionFor: self ] ].
	^stackPointer
]
