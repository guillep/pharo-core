"
EncoderForSistaV1 encodes a bytecode set for Sista, the Speculative Inlining Smalltalk Architecture, a project by Clément Bera and Eliot Miranda.  Sista is an optimizer that exists in the Smalltalk image, /not/ in the VM,  and optimizes by substituting normal bytecoded methods by optimized bytecoded methods that may use special bytecodes for which the Cogit can generate faster code.  These bytecodes eliminate overheads such as bounds checks or polymorphic code (indexing Array, ByteArray, String etc).  But the bulk of the optimization performed is in inlining blocks and sends for the common path.  This bytecode set therefore differs from a normal Smalltalk set in providing a set of inlined primitives that do not validate their arguments that the compiler generates only when it can prove that the primitives' arguments are valid.

The basic scheme is that the Cogit generates code containing performance counters.  When these counters trip, a callback into the image is performed, at which point Sista analyses some portion of the stack, looking at performance data for the methods on the stack, and optimises based on the stack and performance data.  Execution then resumes in the optimized code.

The Sista Cogit (e.g. SistaStackToRegisterMappingCogit) adds counters to conditional branches.  Each branch has an executed and a taken count.  On execution the executed count is decremented and if the count goes below zero the VM sends a message at a special index in the specialObjectsArray (as of writing, conditionalCounterTrippedOn:).  Then if the branch is taken the taken count is decremented.  The two counter values allow the Sista optimizer to collect basic block execution paths and to know what are the ""hot"" paths through execution that are worth agressively optimizing.  Since conditional branches are about 1/6 as frequent as sends, and since they can be used to determine the hot path through code, they are a better choice to count than, for example, method or block entry.

The VM provides a primitive that fills an Array with the state of the counters, and the state of each linked send in a method.  Tthe optimizer obtains the branch and send data for a method via this primitive.

This bytecde set encodes a bytecode set for Smalltalk that lifts limits on the number of literals and branch distances, and extended push integer and push character bytecodes.  Bytecodes are ordered by length to make decoding easier.  Bytecodes marked with an * are extensible via a prefix bytecode.

N.B.  Extension bytecodes can only come before extensible bytecodes, and only if valid (one cannot extend a bytecode extensible by Ext A with an Ext B).  An extensible bytecode consumes (and zeros) its extension(s).  Hence the hidden implicit variables holding extensions are always zero except after a valid sequence of extension bytecodes.

Instance Variables (inherited)

1 Byte Bytecodes
	code	(note)	binary			name
	0-15			0000 iiii 				Push Receiver Variable #iiii
	16-31		0001 iiii				Push Literal Variable #iiii
	32-63		001 iiiii				Push Literal #iiiii
	64-71		01000 iii				Push Temp #iii
	72-75		010010 ii				Push Temp #ii + 8
	76			01001100			Push Receiver
	77			01001101			Push true
	78			01001110			Push false
	79			01001111			Push nil
	80			01010000			Push 0
	81			01010001			Push 1
*	82			01010010			Push thisContext, (then Extend B = 1 => push thisProcess)
	83			01010011			Duplicate Stack Top
	84-87		010101 ii				UNASSIGNED
	88-91		010110 ii				Return Receiver/true/false/nil
	92			01011100			Return top
	93			01011101			BlockReturn nil
*	94			01011110			BlockReturn Top [* return from enclosing block N, N = Extend A, then jump by Ext B ]
*	95			01011111			Nop
	96-111		0110 iiii				Send Arithmetic Message #iiii #(#+ #- #< #> #<= #>= #= #~= #* #/ #\\ #@ #bitShift: #// #bitAnd: #bitOr:)
	112-127	0111 iiii					Send Special Message #iiii #(#at: #at:put: #size #next #nextPut: #atEnd #== class #~~ #value #value: #do: #new #new: #x #y)
	128-143	1000 iiii					Send Literal Selector #iiii With 0 Argument
	144-159	1001 iiii					Send Literal Selector #iiii With 1 Arguments
	160-175	1010 iiii					Send Literal Selector #iiii With 2 Arguments
	176-183	10110 iii					Jump iii + 1 (i.e., 1 through 8)
	184-191	10111 iii					Pop and Jump 0n True iii +1 (i.e., 1 through 8)
	192-199	11000 iii					Pop and Jump 0n False iii +1 (i.e., 1 through 8)
	200-207	11001 iii					Pop and Store Receiver Variable #iii
	208-215	11010 iii					Pop and Store Temporary Variable #iii
	216		11011000				Pop Stack Top
	217		11011001				Unconditional trap [Sista specific]
	218-219	1101101 i				UNASSIGNED
	220-223	110111 ii					UNASSIGNED

2 Byte Bytecodes
*	224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A) A is an unsigned extension.
*	225		11100001	bbbbbbbb	Extend B (Ext B = Ext B prev * 256 + Ext B) B is a signed extension.
*	226		11100010	iiiiiiii		Push Receiver Variable #iiiiiiii (+ Extend A * 256)
*	227		11100011	iiiiiiii		Push Literal Variable #iiiiiiii (+ Extend A * 256)
*	228		11100100	iiiiiiii		Push Literal #iiiiiiii (+ Extend A * 256)
	229		11100101	iiiiiiii		Push Temporary Variable #iiiiiiii
	230		11100110	iiiiiiii		UNASSIGNED (was pushNClosureTemps)
	231		11100111	jkkkkkkk	Push (Array new: kkkkkkk) (j = 0)
									&	Pop kkkkkkk elements into: (Array new: kkkkkkk) (j = 1)
*	232		11101000	iiiiiiii		Push Integer #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)
*	233		11101001	iiiiiiii		Push Character #iiiiiiii (+ Extend B * 256)
**	234		11101010	iiiiijjj		Send Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments
**	235	(1)	11101011	iiiiijjj	ExtendB < 64
										ifTrue: [Send To Superclass Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments]
										ifFalse: [Send To Superclass of Stacked Class Literal Selector #iiiii (+ Extend A * 32) with jjj (+ (Extend B bitAnd: 63) * 8) Arguments]
	236		11101100	iiiiiiii		Call Mapped inlined primitive #iiiiiiii [Sista specific]
*	237		11101101	iiiiiiii		Jump #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)
**	238		11101110	iiiiiiii		Pop and Jump 0n True #iiiiiiii (+ Extend B * 256, where Extend B >= 0) 
**	239		11101111	iiiiiiii		Pop and Jump 0n False #iiiiiiii (+ Extend B * 256, where Extend B >= 0)
*	240		11110000	iiiiiiii		Pop and Store Receiver Variable #iiiiiii (+ Extend A * 256) 
*	241		11110001	iiiiiiii		Pop and Store Literal Variable #iiiiiiii (+ Extend A * 256) 
	242		11110010	iiiiiiii		Pop and Store Temporary Variable #iiiiiiii
*	243		11110011	iiiiiiii		Store Receiver Variable #iiiiiii (+ Extend A * 256) 
*	244		11110100	iiiiiiii		Store Literal Variable #iiiiiiii (+ Extend A * 256) 
	245		11110110	iiiiiiii		Store Temporary Variable #iiiiiiii
	246-247	1111011 i	xxxxxxxx	UNASSIGNED

3 Byte Bytecodes
	248	(2)	11111000 	iiiiiiii	mssjjjjj		Call Primitive #iiiiiiii + (jjjjj * 256) 
								m=1 means inlined primitive, no hard return after execution. 
								ss defines the unsafe operation set used to encode the operations. 
								(ss = 0 means sista unsafe operations, ss = 01 means lowcode operations, other numbers are not used) [Sista specific]
	249		11111001 	xxxxxxxx	siyyyyyy	push Closure Compiled block literal index xxxxxxxx (+ Extend A * 256) numCopied yyyyyy receiverOnStack: s = 1 ignoreOuterContext: i = 1
**	250		11111010 	eeiiikkk		jjjjjjjj		Push Closure Num Copied iii (+ExtA//16*8) Num Args kkk (+ ExtA\\16*8) BlockSize jjjjjjjj (+ExtB*256). ee = num extensions
	251		11111011 	kkkkkkkk	jjjjjjjj		Push Temp At kkkkkkkk In Temp Vector At: jjjjjjjj
*	252	(3)	11111100 	kkkkkkkk	jjjjjjjj		Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj
*	253	(3)	11111101 	kkkkkkkk	jjjjjjjj		Pop and Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj
	254		11111110	kkkkkkkk	jjjjjjjj		UNASSIGNED
	255		11111111	xxxxxxxx	jjjjjjjj			UNASSIGNED

(1) Bytecode 235 is a super send bytecode that starts the lookup in the superclass of some class.  It has two forms, ""normal"" and ""directed"". In the normal form, the class is the value of the method's methodClassAssociation which must be the last literal.  In the directed form the class is the class on top of stack.

(2) The Call Primitive Bytecode specifies either a primitive in the primitive table (m=0) or an inlined primitive (m=1). Non-inlined primtiives from the primitive table have index (jjjjjjj * 256) + iiiiiiii and return from the method if they succeed.  This bytecode is only valid as the first bytecode of a method.  Inline primitives have index (jjjjjjj * 256) + iiiiiiii, cannot fail, and do not return when they succeed, yielding a result (typically on top of stack after popping their arguments, but possibly in a byte data stack, for example for unboxed floating-point primitives).

[Sista specific] The 3 bytecodes with this annotations are not used in the default Pharo runtime but only in specific circumstances (Sista runtime, etc.)

Here is the specification of the sista unsafe instructions (unsafe operations, set 00). The lowcode set uses external specifications.

We sort the inline primitive operations by arity.  Nullary primitives occupy the 0-999 range. Unary primitives occupy the 1-1999 range, up until 5 args. Primitives starting at 6000 are jumps. 6000-6999 are 1 parameter jump (the distance), 7000-7999 are 2 parameters jump and jumps over 8000 have 3 parameters.

All jumps encoded as inlined primitives (mapped or not) use the pushIntegerLong: scheme to push their jump size on stack.

We define the following *non-mapped* inlined primitives:
1000	rawClass
not a forwarder => Behavior (Same as class special send, but receiver is not a forwarder)
1001	numSlots
pointer object => Smi between 0 and SmallInteger maxVal // 4 - 1 (Answers total size in pointer-sized slots)
1002	numBytes
byte object => Smi between 0 and SmallInteger maxVal - 9 (Includes compiled code)
1003	numShorts
short object => Smi between 0 and SmallInteger maxVal - 9
1004	numWords
word object => Smi between 0 and SmallInteger maxVal - 9
1005	numDoubleWords
double word object => Smi between 0 and SmallInteger maxVal - 9
1011	rawNew
literal which is a fixed-sized behavior => instance of the receiver with fields nilled out
1012	rawNewNoInit
literal which is a fixed-sized behavior => instance of the receiver (Fields of returned value contain undefined data)
1020	objectIdentityHash
non-immediate and non-behavior => 22 bits strictly positive Smi
1021	smiIdentityHash
Smi => Smi
1022	charIdentityHash
Character => 22 bits strictly positive Smi
1023	smallfloatIdentityHash
SmallFloat => Smi
1024	behaviorIdentityHash
Behavior => 22 bits strictly positive Smi
1030	characterAsInteger
Character => 22 bits strictly positive Smi (Unicode)
1031	smallFloatAsInteger
SmallFloat => Smi
1032	smiAsFloat
Smi => SmallFloat
1039	unforwardNonImmediate
non immediate => Not a forwarder
1040	unforward
Anything => Not a forwarder
1041	possibleRoot
non-immediate, not a forwarder => receiver is returned (should be effect-only) (If old, becomes gray and remembered to allow many unchecked stores in a row afterwards)

2000	smiAdd:
Smi, Smi => Smi (no overflow, optimised if one operand is a constant)
2001	smiSub:
Smi, Smi => Smi (no overflow, optimised if one operand is a constant)
2002	smiMul:
Smi, Smi => Smi (no overflow, optimised if one operand is a constant)
2003	smiDivide:
Smi, Smi => Smi (no overflow, optimised if one operand is a constant)
2004	smiDiv:
Smi, Smi => Smi (no overflow, optimised if one operand is a constant)
2005	smiMod:
Smi, Smi => Smi (no overflow, optimised if one operand is a constant)
2006	smiQuo:
Smi, Smi => Smi (no overflow, optimised if one operand is a constant)
2016	smiBitAnd:
Smi, Smi => Smi (optimised if one operand is a constant)
2017	smiBitOr:
Smi, Smi => Smi (optimised if one operand is a constant)
2018	smiBitXor:
Smi, Smi => Smi (optimised if one operand is a constant)
2019	smiBitShiftLeft:
Smi greater or equal to 0, Smi greater or equal to 0 => Smi (no overflow, optimised if arg1 is a constant)
2020	smiBitShiftRight:
Smi, Smi greater or equal to 0 => Smi (optimised if arg1 is a constant)
2032	smiGreater:
Smi, Smi => Boolean (optimised if one operand is a constant, Pipelined with ifTrue:ifFalse:)
2033	smiLess:
Smi, Smi => Boolean (optimised if one operand is a constant, Pipelined with ifTrue:ifFalse:)
2034	smiGreaterOrEqual:
Smi, Smi => Boolean (optimised if one operand is a constant, Pipelined with ifTrue:ifFalse:)
2035	smiLessOrEqual:
Smi, Smi => Boolean (optimised if one operand is a constant, Pipelined with ifTrue:ifFalse:)
2036	smiEquals:
Smi, Smi => Boolean (optimised if one operand is a constant, Pipelined with ifTrue:ifFalse:)
2037	smiNotEquals:
Smi, Smi => Boolean (optimised if one operand is a constant, Pipelined with ifTrue:ifFalse:)
2038	rawEqualsEquals:
not a forwarder, not a forwarder => Boolean (optimised if one operand is a constant, Pipelined with ifTrue:ifFalse:)
2039	rawNotEqualsEquals:
not a forwarder, not a forwarder => Boolean (optimised if one operand is a constant, Pipelined with ifTrue:ifFalse:)
2048	rawNewColon:
literal which is a variable-sized behavior, Smi => instance of receiver, fields nilled/zeroed out (optimised if arg1 is a constant)
2049	rawNewColonNoInit:
literal which is a variable-sized behavior, Smi => instance of receiver (Fields of returned value contain undefined data, optimised if arg1 is a constant)
2064	pointerAt:
Pointer object (Fixed sized or not) and not a context, Smi =>  (1-based, optimised if arg1 is a constant)
2065	maybeContextPointerAt:
Pointer object (Fixed sized or not), Smi =>  (1-based, optimised if arg1 is a constant)
2066	byteAt:
byte object, Smi => 8 bits unsigned Smi (1-based, optimised if arg1 is a constant)
2067	shortAt:
short object, Smi => 16 bits unsigned Smi (1-based, optimised if arg1 is a constant)
2068	wordAt:
word object, Smi => 32 bits unsigned Smi (1-based, optimised if arg1 is a constant)
2069	doubleWordAt:
double word object, Smi => 64 bits unsigned Smi or LargePositiveInteger (1-based, optimised if arg1 is a constant)

3000	pointerAt:put:
Mutable pointer object (Fixed sized or not) and not a context, Smi, Anything => arg2 (1-based, optimised if arg1 is a constant)
3001	storeCheckPointerAt:put:
Mutable pointer object (Fixed sized or not) and not a context, Smi, Anything => arg2 (1-based, optimised if arg1 is a constant)
3002	maybeContextPointerAt:put:
Mutable pointer object (Fixed sized or not), Smi, Anything => arg2 (1-based, optimised if arg1 is a constant)
3003	maybeContextStoreCheckPointerAt:put:
Mutable pointer object (Fixed sized or not), Smi, Anything => arg2 (1-based, optimised if arg1 is a constant)
3004	byteAt:put:
Mutable byte object, Smi, 8 bits unsigned Smi => arg2 (1-based, optimised if arg1 is a constant)
3005	shortAt:put:
Mutable short object, Smi, 16 bits unsigned Smi => arg2 (1-based, optimised if arg1 is a constant)
3006	wordAt:put:
Mutable word object, Smi, 32 bits unsigned Smi => arg2 (1-based, optimised if arg1 is a constant)
3007	doubleWordAt:put:
Mutable double word object, Smi, 64 bits unsigned Smi or LargePositiveInteger => arg2 (1-based, optimised if arg1 is a constant)

6000	backjumpNoInterrupt
literal which is a Smi
7016	jumpWritable:
Not a forwarder, literal which is a Smi
7017	jumpReadOnly:
Not a forwarder, literal which is a Smi
7018	jumpYoung:
Not a forwarder, literal which is a Smi
7019	jumpOld:
Not a forwarder, literal which is a Smi

8000	instanceOf:jumpTrue:
Anything, literal which is a Behavior, literal which is a Smi
8001	instanceOf:jumpFalse:
Anything, literal which is a Behavior, literal which is a Smi
8002	instanceOfOneOf:jumpTrue:
Anything, Array of behaviors, literal which is a Smi
8003	instanceOfOneOf:jumpFalse:
Anything, Array of behaviors, literal which is a Smi

Mapped primitives are a bit different. They're sorting by arity up to 3 parameters (0-49 is nullary, 50-99 is binary, etc.). 200 and over are variable number of parameter instructions. 250 and over are mapped jumped. 

We define the folloing mapped primitives:
50	ensureEnoughSlots
literal which is a Smi => ret value is receiver
150	immCheckPointerAt:put:
pointer object (Fixed sized or not) and not a context, Smi, Anything => arg2 (1-based, optimised if arg1 is a constant)
151	immCheckStoreCheckPointerAt:put:
pointer object (Fixed sized or not) and not a context, Smi, Anything => arg2 (1-based, optimised if arg1 is a constant)
152	immCheckMaybeContextPointerAt:put:
pointer object (Fixed sized or not), Smi, Anything => arg2 (1-based, optimised if arg1 is a constant (Concept-only, contexts are mutable right now))
153	immCheckMaybeContextStoreCheckPointerAt:put:
pointer object (Fixed sized or not), Smi, Anything => arg2 (1-based, optimised if arg1 is a constant (Concept-only, contexts are mutable right now))
154	immCheckByteAt:put:
byte object, Smi, 8 bits unsigned Smi => arg2 (1-based, optimised if arg1 is a constant)
155	immCheckShortAt:put:
short object, Smi, 16 bits unsigned Smi => arg2 (1-based, optimised if arg1 is a constant)
156	immCheckWordAt:put:
word object, Smi, 32 bits unsigned Smi => arg2 (1-based, optimised if arg1 is a constant)
157	immCheckDoubleWordAt:put:
double word object, Smi, 64 bits unsigned Smi or LargePositiveInteger => arg2 (1-based, optimised if arg1 is a constant)
200	withArgs:executeMethod:
literal index of the method to call on top of stack =>  (variable number of parameters (on contrary to what the selector suggests, no array), the index and not the method is pushed for efficient inline caches.)
250	backjumpAlwaysInterrupt
literal which is a Smi

"
Class {
	#name : #EncoderForSistaV1,
	#superclass : #BytecodeEncoder,
	#category : #'Kernel-BytecodeEncoders'
}

{ #category : #'bytecode decoding' }
EncoderForSistaV1 class >> backJumpBytecodeSize [
	^ 4
]

{ #category : #'compiled method support' }
EncoderForSistaV1 class >> bindingReadScanBlockFor: litVarIndex using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for reads of the value of the binding with zero-relative index litVarIndex.
	 N.B. Don't assume the compiler uses the most compact encoding available."

	"	16-31		0001 i i i i				Push Literal Variable #iiii
	 *	224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)
	 *	227		11100011	i i i i i i i i	Push Literal Variable #iiiiiiii (+ Extend A * 256)"
	| extension |
	extension := 0.
	^[:b| | prevext |
	   prevext := extension.
	   extension := b = 224 ifTrue: [scanner secondByte bitShift: 8] ifFalse: [0].
	   (b < 32 and: [b >= 16 and: [b - 16 = litVarIndex]])
	    or: [b = 227
			and: [scanner secondByte + prevext = litVarIndex]]]
]

{ #category : #'compiled method support' }
EncoderForSistaV1 class >> bindingWriteScanBlockFor: litVarIndex using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for writes of the value of the binding with zero-relative index litVarIndex.
	 N.B. Don't assume the compiler uses the most compact encoding available."

	"*	224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)
	 *	241		11110001	iiiiiiii		Pop and Store Literal Variable #iiiiiiii (+ Extend A * 256)
	 *	244		11110100	iiiiiiii		Store Literal Variable #iiiiiiii (+ Extend A * 256)"
	| extension |
	extension := 0.
	^[:b| | prevext |
	   prevext := extension.
	   extension := b = 224 ifTrue: [scanner secondByte bitShift: 8] ifFalse: [0].
	   (b = 241 or: [b = 244])
	   and: [scanner secondByte + prevext = litVarIndex]]
]

{ #category : #'block closure support' }
EncoderForSistaV1 class >> blockCreationBytecodeMessageAt: startpc method: method [
	"**	250		11111010 	eeiiikkk		jjjjjjjj		Push Closure Num Copied iii (+ExtA//16*8) Num Args kkk (+ ExtA\\16*8) BlockSize jjjjjjjj (+ExtB*256). ee = num extensions"
	| numExts | 
	numExts := (method at: startpc - 2) >> 6.
	^ method abstractBytecodeMessageAt: startpc - 3 - (2 * numExts).
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> bytecodeSize: bytecode [
	"Answer the number of bytes in the bytecode."
	bytecode < 224 ifTrue: [^1].
	bytecode < 248 ifTrue: [^2].
	^3
]

{ #category : #'bytecode decoding' }
EncoderForSistaV1 class >> callPrimitiveCode [
	"Answer the call primitive bytecode, if it exists in the encoder's bytecode set, or nil if not.
	 248	11111000 	iiiiiiii	mjjjjjjj	Call Primitive #iiiiiiii + (jjjjjjj * 256) m=1 means inlined primitive, no hard return after execution."
	^248
]

{ #category : #'compiled method support' }
EncoderForSistaV1 class >> extensionsAt: bcpc in: method into: aTrinaryBlock [
	"If the bytecode at pc is an extension then evaluate aBinaryBlock with the values of extA and extB and number of extension *bytes*.
	 If the bytecode at pc is not extended then evaluate aBinaryBlock with 0 and 0.
	224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)
	225		11100001	bbbbbbbb	Extend B (Ext B = Ext B prev * 256 + Ext B)"
 
	| scanpc byte extByte extA extB |
	scanpc := bcpc.
	"There may be an extension (it could be a false positive).  We must scan as fast as possible..."
	extA := extB := 0.
	[byte := method at: scanpc.
	 byte >= 224 and: [byte <= 225]] whileTrue: 
		[extByte := method at: scanpc + 1.
		 scanpc := scanpc + 2.
		 byte = 224
			ifTrue:
				[extA := (extA bitShift: 8) + extByte]
			ifFalse:
				[extB := (extB = 0 and: [extByte > 127])
					ifTrue: [extByte - 256]
					ifFalse: [(extB bitShift: 8) + extByte]]].
	^aTrinaryBlock value: extA value: extB value: scanpc - bcpc


"Why use
	byte >= 224 and: [byte <= 225]
 and not
	(byte bitAnd: 16rFE) = 16rE0
 ?
 | n |
 n := 100000000.
 #(0 224) collect:
	[:byte|
	{ Time millisecondsToRun: [1 to: n do: [:i| (byte >= 224 and: [byte <= 225]) ifTrue: []]].
	   Time millisecondsToRun: [1 to: n do: [:i| (byte bitAnd: 16rFE) = 16rE0 ifTrue: []]] }] #(#(297 599) #(702 671))"
]

{ #category : #'compiled method support' }
EncoderForSistaV1 class >> firstSpecialSelectorByte [
	^ 16r5F
]

{ #category : #'compiled method support' }
EncoderForSistaV1 class >> instVarReadScanBlockFor: varIndexCode using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for reads of the inst var with zero-relative index varIndexCode.
	 N.B. Don't assume the compiler uses the most compact encoding available."

	"	0-15		0000 i i i i 				Push Receiver Variable #iiii
	*	224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)
	*	226		11100010	i i i i i i i i	Push Receiver Variable #iiiiiiii (+ Extend A * 256)"
	| extension |
	extension := 0.
	^[:b| | prevext |
	   prevext := extension.
	   extension := b = 224 ifTrue: [scanner secondByte bitShift: 8] ifFalse: [0].
	   (b < 16 and: [b = varIndexCode])
	    or: [b = 226
			and: [scanner secondByte + prevext = varIndexCode]]]
]

{ #category : #'compiled method support' }
EncoderForSistaV1 class >> instVarWriteScanBlockFor: varIndexCode using: scanner [
	"Answer a block argument for InstructionStream>>scanFor: that answers true
	 for writes of the inst var with zero-relative index varIndexCode.
	 N.B. Don't assume the compiler uses the most compact encoding available."

	"	200-207	11001 iii			Pop and Store Receiver Variable #iii
	*	224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)
	*	240		11110000	iiiiiiii		Pop and Store Receiver Variable #iiiiiii (+ Extend A * 256)
	*	243		11110011	iiiiiiii		Store Receiver Variable #iiiiiii (+ Extend A * 256)"
	| extension |
	extension := 0.
	^[:b| | prevext |
	   prevext := extension.
	   extension := b = 224 ifTrue: [scanner secondByte bitShift: 8] ifFalse: [0].
	   (b >= 200
	    and: [b < 208
	    and: [b - 200 = varIndexCode]])
	   or: [(b = 240 or: [b = 243])
		  and: [scanner secondByte + prevext = varIndexCode]]]
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> interpretNextInstructionFor: aClient in: anInstructionStream [
	"Double-dispatch through the encoder to select the correct instruction set decoder."
	^anInstructionStream interpretNextSistaV1InstructionFor: aClient
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isBlockReturnAt: pc in: method [
	"Answer whether the bytecode at pc is a return from block."
	"	93			01011101			BlockReturn nil
	 *	94			01011110			BlockReturn Top [* return from enclosing block N, N = Extend A, then jump by Ext B ]"
	^(self nonExtensionBytecodeAt: pc in: method) between: 93 and: 94
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isBranchIfFalseAt: pc in: method [
	"Answer whether the bytecode at pc is a conditional branch-if-false."

	"	192-199	11000 iii				Pop and Jump 0n False iii +1 (i.e., 1 through 8)
	 *	239		11101111	iiiiiiii		Pop and Jump 0n False #iiiiiiii (+ Extend B * 256, where Extend B >= 0)"
	| byte |
	byte := self nonExtensionBytecodeAt: pc in: method.
	^byte >= 192 and: [byte <= 199 or: [byte = 239]]
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isBranchIfTrueAt: pc in: method [
	"Answer whether the bytecode at pc is a conditional branch-if-true."

	"	184-191	10111 iii				Pop and Jump 0n True iii +1 (i.e., 1 through 8)
	 *	238		11101110	iiiiiiii		Pop and Jump 0n True #iiiiiiii (+ Extend B * 256, where Extend B >= 0))"
	| byte |
	byte := self nonExtensionBytecodeAt: pc in: method.
	^byte >= 184 and: [byte <= 191 or: [byte = 238]]
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isCreateBlockAt: pc in: method [
	"Answer whether the bytecode at pc is a block creation bytecode."
	
	"250		11111010 	eeiiikkk		jjjjjjjj		Push Closure Num Copied iii (+ExtA//16*8) Num Args kkk (+ ExtA\\16*8) BlockSize jjjjjjjj (+ExtB*256). ee = num extensions"

	| byte |
	byte := self nonExtensionBytecodeAt: pc in: method.
	^ byte = 250
]

{ #category : #'block closure support' }
EncoderForSistaV1 class >> isCreateFullBlock: compiledBlock code: code at: pc [
	^self extensionsAt: pc in: code into:
		[:extA :extB :nExtBytes| 
			(code at: pc + nExtBytes) = 16rF9 and: [ 
				compiledBlock = (code literalAt: (code at: pc + nExtBytes + 1) + (extA bitShift: 8) + 1)] ]
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isCreateFullBlockAt: pc in: code [
	^ self
		  extensionsAt: pc
		  in: code
		  into: [ :extA :extB :nExtBytes | 
		  (code at: pc + nExtBytes) = 16rF9 ]
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isExtension: bytecode [
	"Answer if the bytecode is an extension bytecode, i.e. one that extends
	 the range of the following bytecode."
	^bytecode >= 16rE0 and: [bytecode <= 16rE1]
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isJumpAt: pc in: method [
	"Answer whether the bytecode at pc is an (unconditional) jump."

	"	176-183	10110 iii				Jump iii + 1 (i.e., 1 through 8)
	 *	225		11100001	bbbbbbbb	Extend B (Ext B = Ext B prev * 256 + Ext B)
	 *	237		11101101	iiiiiiii		Jump #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	| byte |
	byte := self nonExtensionBytecodeAt: pc in: method.
	^byte >= 176 and: [byte <= 183 or: [byte = 237]]
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isJustPopAt: pc in: method [
	"Answer whether the bytecode at pc is a pop."

	^(method at: pc) = 216 "216		11011000			Pop Stack Top"
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isPushTempAt: pc in: method [
	"64-71		01000 iii			Push Temp #iii
	 72-75		010010 ii			Push Temp #ii + 8
	 229		11100101	iiiiiiii	Push Temporary Variable #iiiiiiii"

	| byte |
	((byte := method at: pc) between: 64 and: 75) ifTrue: [ ^ true ].
	^ byte = 229
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isRealSendAt: pc in: method [
	"Answer whether the bytecode at pc is a real message-send, not blockCopy:."

	^self isSendAt: pc in: method
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isReturnAt: pc in: method [
	"Answer whether the bytecode at pc is a return from block."
	"	88-91		010110 ii			Return Receiver/true/false/nil
		92			01011100			Return top
		93			01011101			BlockReturn nil
	 *	94			01011110			BlockReturn Top [* return from enclosing block N, N = Extend A, then jump by Ext B ]"
	^(self nonExtensionBytecodeAt: pc in: method) between: 88 and: 94
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isReturnTopFromMethodAt: pc in: method [
	"Answer whether the bytecode at pc is a return stack top from method."

	^(method at: pc) = 92
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isSendAt: pc in: method [
	"Answer whether the bytecode at pc is a message-send."

	"	96-111		0110 iiii			Send Arithmetic Message #iiii #(#+ #- #< #> #'<=' #'>=' #= #'~=' #* #/ #'\\' #@ #bitShift: #'//' #bitAnd: #bitOr:)
		112-119	01110 iii			Send Special Message #iii #(#at: #at:put: #size #next #nextPut: #atEnd #'==' class)
		120		01111000			UNASSIGNED (was: blockCopy:)
		121		01111001			Send Special Message #value
		122-123	0111101 i			Send Special Message #i #(#value: #do:)
		124-127	011111 ii			Send Special Message #ii #(#new #new: #x #y))
		128-143	1000 iiii			Send Literal Selector #iiii With 0 Argument
		144-159	1001 iiii			Send Literal Selector #iiii With 1 Arguments
		160-175	1010 iiii			Send Literal Selector #iiii With 2 Arguments
	 **	234		11101010	iiiiijjj	Send Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments
	 **	235		11101011	iiiiijjj	Send To Superclass Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments"

	| byte |
	byte := self nonExtensionBytecodeAt: pc in: method.
	^byte >= 96
	  and: [byte <= 175
		 or: [byte >= 234 and: [byte <= 235]]]
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isStoreAt: pc in: method [
	"Answer whether the bytecode at pc is a store or store-pop."

	"	200-207	11001 iii						Pop and Store Receiver Variable #iii
		208-215	11010 iii						Pop and Store Temporary Variable #iii
	 *	224		11100000	aaaaaaaa			Extend A (Ext A = Ext A prev * 256 + Ext A)
	 *	240		11110000	iiiiiiii				Pop and Store Receiver Variable #iiiiiii (+ Extend A * 256)
	 *	241		11110001	iiiiiiii				Pop and Store Literal Variable #iiiiiiii (+ Extend A * 256)
		242		11110010	iiiiiiii				Pop and Store Temporary Variable #iiiiiiii
	 *	243		11110011	iiiiiiii				Store Receiver Variable #iiiiiii (+ Extend A * 256)
	 *	244		11110100	iiiiiiii				Store Literal Variable #iiiiiiii (+ Extend A * 256)
		245		11110110	iiiiiiii				Store Temporary Variable #iiiiiiii

		252		11111100 	kkkkkkkk	jjjjjjjj	Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj
		253		11111101 	kkkkkkkk	jjjjjjjj	Pop and Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj"

	| byte |
	byte := self nonExtensionBytecodeAt: pc in: method.
	^byte >= 200
	  and: [byte <= 215
		 or: [(byte between: 240 and: 245)
		 or: [(byte between: 252 and: 253)]]]
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> isStorePopAt: pc in: method [
	"Answer whether the bytecode at pc is a store or store-pop."

	"	200-207	11001 iii						Pop and Store Receiver Variable #iii
		208-215	11010 iii						Pop and Store Temporary Variable #iii
	 *	224		11100000	aaaaaaaa			Extend A (Ext A = Ext A prev * 256 + Ext A)
	 *	240		11110000	iiiiiiii				Pop and Store Receiver Variable #iiiiiii (+ Extend A * 256)
	 *	241		11110001	iiiiiiii				Pop and Store Literal Variable #iiiiiiii (+ Extend A * 256)
		242		11110010	iiiiiiii				Pop and Store Temporary Variable #iiiiiiii

		253		11111101 	kkkkkkkk	jjjjjjjj	Pop and Store Temp At kkkkkkkk In Temp Vector At: jjjjjjjj"

	| byte |
	byte := self nonExtensionBytecodeAt: pc in: method.
	^byte >= 200
	  and: [byte <= 215
		 or: [(byte between: 240 and: 242)
		 or: [byte = 253]]]
]

{ #category : #'compiled method support' }
EncoderForSistaV1 class >> literalIndexOfBytecodeAt: pc in: aCompiledMethod [
	"	16-31		0001 i i i i				Push Literal Variable #iiii
	 	32-63		001 i i i i i				Push Literal #iiiii
	 *	224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)
	 *	227		11100011	i i i i i i i i	Push Literal Variable #iiiiiiii (+ Extend A * 256)
	 *	228		11100100	i i i i i i i i	Push Literal #iiiiiiii (+ Extend A * 256)
	 *	241		11110001	iiiiiiii		Pop and Store Literal Variable #iiiiiiii (+ Extend A * 256)
	 *	244		11110100	iiiiiiii		Store Literal Variable #iiiiiiii (+ Extend A * 256)"
	| byte |
	byte := aCompiledMethod at: pc.
	byte <= 63 ifTrue:
		[byte >= 32 ifTrue:
			[^byte bitAnd: 16r1F].
		 ^byte >= 16 ifTrue:
			[byte bitAnd: 16rF]].
	(#(227 228 241 244) includes: byte) ifTrue:
		[^aCompiledMethod at: pc + 1].
	(byte = 224 "Ext A"
	 and: [#(227 228 241 244) includes: (aCompiledMethod at: pc + 2)]) ifTrue:
		[^(aCompiledMethod at: pc + 1) * 256 + (aCompiledMethod at: pc + 3)].
	^nil
]

{ #category : #accessing }
EncoderForSistaV1 class >> literalMethodBytecodes [
	"#[32 92] means pushConstant: x, returnTop" 
	
	^ #[32 92] 
]

{ #category : #'compiled method support' }
EncoderForSistaV1 class >> markerOrNilFor: aMethod [
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
    	and: [(aMethod at:  expectedHeaderPlusLliteralSize + 1) = 76 "push self"
    	and: [(aMethod at: expectedHeaderPlusLliteralSize + 2) = 128]]])  "send <literal 1>"
    	ifTrue: [aMethod literalAt: 1]
]

{ #category : #scanning }
EncoderForSistaV1 class >> method: method refersInBytecodeToLiteral: aLiteral specialSelectorIndex: specialOrNil [
	"Answer if method refers to the literal aLiteral in the bytecode, as opposed to in its literal frame."

	"	77			01001101				Push true
		78			01001110				Push false
		79			01001111				Push nil
		80			01010000				Push 0
		81			01010001				Push 1
		88-91		010110 ii				Return Receiver/true/false/nil
		93			01011101				BlockReturn nil
		96-111		0110 iiii				Send Arithmetic Message #iiii #(#+ #- #< #> #'<=' #'>=' #= #'~=' #* #/ #'\\' #@ #bitShift: #'//' #bitAnd: #bitOr:)
		112-119	01110 iii				Send Special Message #iii #(#at: #at:put: #size #next #nextPut: #atEnd #'==' class)
		120		01111000				UNASSIGNED (was: blockCopy:)
		121		01111001				Send Special Message #value
		122-123	0111101 i				Send Special Message #i #(#value: #do:)
		124-127	011111 ii				Send Special Message #ii #(#new #new: #x #y))
	*	224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)
	*	225		11100001	sbbbbbbb	Extend B (Ext B = Ext B prev * 256 + Ext B)
	*	232		11101000	iiiiiiii		Push Integer #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)
	*	233		11101001	iiiiiiii		Push Character #iiiiiiii (+ Extend B * 256)
		249		11111001 	xxxxxxxx	syyyyyyy	Reserved for Push Float"
	| byte extended scanner |
	specialOrNil ifNotNil:
		[byte := specialOrNil + 95.
		^(InstructionStream on: method) scanFor: [:b| b = byte]].
	extended := false.
	aLiteral isInteger ifTrue:
		[(aLiteral >= -32768 and: [aLiteral <= 32767]) ifFalse: [^false].
		 scanner := InstructionStream on: method.
		 (aLiteral >= 0 and: [aLiteral <= 255]) ifTrue:
			[aLiteral <= 1 ifTrue:
				[byte := aLiteral + 80.
				 ^scanner scanFor: [:b| b = byte]].
			 ^scanner scanFor:
				[:b|
				(b = 232
				 and: [extended not
				 and: [scanner secondByte = aLiteral]])
				or: [extended := b = 225.
					false]]].
		 byte := (aLiteral bitShift: -8) bitAnd: 255.
		^scanner scanFor:
			[:b|
			(b = 232
			 and: [extended
			 and: [scanner secondByte = (aLiteral bitAnd: 255)]])
			or: [extended := b = 225 and: [scanner secondByte = byte].
				false]]].
	aLiteral isCharacter ifTrue:
		[aLiteral asciiValue <= 65535 ifFalse: [^false].
		 scanner := InstructionStream on: method.
		 aLiteral asciiValue <= 255 ifTrue:
			[^scanner scanFor:
				[:b|
				(b = 233
				 and: [extended not
				 and: [scanner secondByte = aLiteral]])
				or: [extended := b = 225.
					false]]].
		 byte := (aLiteral bitShift: -8) bitAnd: 255.
		^scanner scanFor:
			[:b|
			(b = 233
			 and: [extended
			 and: [scanner secondByte = (aLiteral bitAnd: 255)]])
			or: [extended := b = 225 and: [scanner secondByte = byte].
				false]]].
	aLiteral == nil ifTrue:
		[^(InstructionStream on: method) scanFor: [:b| b = 79 or: [b = 91 or: b = 93]]].
	aLiteral == true ifTrue:
		[^(InstructionStream on: method) scanFor: [:b| b = 77 or: [b = 89]]].
	aLiteral == false ifTrue:
		[^(InstructionStream on: method) scanFor: [:b| b = 78 or: [b = 90]]].
	
	^false
]

{ #category : #'block closure support' }
EncoderForSistaV1 class >> methodReturnBytecodes [
	^ 88 to: 92
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> nonExtensionBytecodeAt: pc in: method [
	"Answer the actual bytecode at pc in method, skipping past any preceeding extensions."
	| scanpc byte |
	scanpc := pc.
	[ byte := method at: scanpc.
	 byte >= 224 and: [byte <= 225]] whileTrue: [ scanpc := scanpc + 2 ].
	^ byte
]

{ #category : #'block closure support' }
EncoderForSistaV1 class >> numLocalTempsForBlockAt: startpc in: method [
	"**	250		11111010 	eeiiikkk		jjjjjjjj		Push Closure Num Copied iii (+ExtA//16*8) Num Args kkk (+ ExtA\\16*8) BlockSize jjjjjjjj (+ExtB*256). ee = num extensions"
	^ BlockLocalTempCounter
		tempCountForBlockAt: startpc - 3 - (((method at: startpc - 2) >> 6) * 2)
		in: method 
]

{ #category : #'compiled method support' }
EncoderForSistaV1 class >> prepareMethod: compiledMethod forSimulationWith: numArgs [
	self shouldBeImplemented
]

{ #category : #'bytecode decoding' }
EncoderForSistaV1 class >> pushNilByte [
	^ 79
]

{ #category : #'compiled method support' }
EncoderForSistaV1 class >> readsSelfFor: compiledMethod [
	"Answer whether compiledMethod reads self"
	| scanner |
	scanner := InstructionStream on: compiledMethod.
	^ scanner scanFor: 
		[:instr |  instr = 76 or: [ instr = 88 ] ]
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> readsThisContextFor: compiledMethod [
	"Answer whether compiledMethod reads thisContext"
	| scanner |
	scanner := InstructionStream on: compiledMethod.
	^ scanner scanFor: 
		[:instr |  instr = 82 ]
]

{ #category : #'bytecode decoding' }
EncoderForSistaV1 class >> selectorToSendOrItselfFor: anInstructionStream in: method at: pc [
	"If anInstructionStream is at a send bytecode then answer the send's selector,
	 otherwise answer anInstructionStream itself.  The rationale for answering
	 anInstructionStream instead of, say, nil, is that potentially any existing object
	 can be used as a selector, but since anInstructionStream postdates the method,
	 it can't be one of them.
	 The complication is that for convenience we allow the pc to point to the
	 raw send bytecode after its extension(s), or at the extension(s) preceeding it.
	96-111		0110 iiii			Send Arithmetic Message #iiii (+ - < > <= >= = ~= * / \\ @ bitShift: // bitAnd: bitOr:)
	112-119	01110 iii			Send Special Message #iii + 0 (at: at:put: size next nextPut: atEnd == class)
	120-127	01111 iii			Send Special Message #iii + 8 (~~ value value: do: new new: x y)
	128-143	1000 iiii			Send Literal Selector #iiii With 0 Argument
	144-159	1001 iiii			Send Literal Selector #iiii With 1 Arguments
	160-175	1010 iiii			Send Literal Selector #iiii With 2 Arguments
	*	224	11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)
	*	225	11100001	bbbbbbbb	Extend B (Ext B = Ext B prev * 256 + Ext B)
	**	234	11101010	iiiiijjj		Send Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments
	**	235	11101011	iiiiijjj	ExtendB < 64
										ifTrue: [Send To Superclass Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments]
										ifFalse: [Send To Superclass of Stacked Class Literal Selector #iiiii (+ Extend A * 32) with jjj (+ (Extend B "

	| byte |
	byte := method at: pc.
	byte < 96 ifTrue:
		[^anInstructionStream].
	byte <= 175 ifTrue: 
		["special byte or short send"
		 ^byte >= 128
			ifTrue: [method literalAt: (byte bitAnd: 15) + 1]
			ifFalse: [Smalltalk specialSelectorAt: byte - 95]].
	byte < 234 ifTrue: "need to check for either extension cuz order of extensions is not restricted. so extB could preceed extA"
		[(byte >= 224 and: [byte <= 225]) ifTrue:
			[^self extensionsAt: pc in: method into:
				[:extA :extB :nExtBytes| | byteAfter index |
				byteAfter := method at: pc + nExtBytes.
				(byteAfter >= 234 and: [byteAfter <= 235])
					ifTrue:
						[index := ((method at: pc + nExtBytes + 1) bitShift: -3) + (extA bitShift: 5).
						 method literalAt: index + 1]
					ifFalse: [anInstructionStream]]].
		^anInstructionStream].
	byte > 235 ifTrue:
		[^anInstructionStream].
	"they could be extended..."
	^self extensionsFor: pc in: method into:
		[:extA :extB :nExtBytes| | index |
		 index := ((method at: pc + 1) bitShift: -3) + (extA bitShift: 5).
		 method literalAt: index + 1]
]

{ #category : #'compiled method support' }
EncoderForSistaV1 class >> sendsToSuperFor: compiledMethod [
	"Answer whether the receiver sends any message to super."
	| scanner |
	scanner := InstructionStream on: compiledMethod.
	^ scanner scanFor: [:instr |  instr = 235 ]
]

{ #category : #'bytecode decoding' }
EncoderForSistaV1 class >> specialLiterals [
	^ #(true false nil 0 1) 
]

{ #category : #'bytecode decoding' }
EncoderForSistaV1 class >> stackDeltaForPrimitive: primitiveIndex in: method [
	"Answer the stack delta for the callPrimitive: bytecode (see my class comment).
	 There is no delta for non-inlined primitives (its implicitly 0 - method numArgs).
	 Inlined primitives are grouped by the thousand by argument count, 32 args max ;-)."
	^primitiveIndex < 32678
		ifTrue: [0]
		ifFalse: [primitiveIndex - 32768 // 1000]
]

{ #category : #'instruction stream support' }
EncoderForSistaV1 class >> superSendScanBlockUsing: scanner [
	"Answer a block argument for InstructionStream>>scanFor:
	 that answers true for super sends."

	"*	224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)
	 *	225		11100001	sbbbbbbb	Extend B (Ext B = Ext B prev * 256 + Ext B)
	 **	235		11101011	iiiiijjj		Send To Superclass Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments"
					
	^[:instr | instr = 235]
]

{ #category : #'bytecode decoding' }
EncoderForSistaV1 class >> unusedBytecode [
	"Answer the opcode of a single-byte unused bytecode, if it exists in the encoder's bytecode set, or nil if not."
	^ 84
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genBranchPopFalse: distance [
	(distance > 0 and: [distance < 9]) ifTrue:
		["192-199	11000 iii			Pop and Jump 0n False iii + 1 (i.e., 1 through 8)"
		 stream nextPut: 191 + distance.
		 ^self].
	^self genBranchPopFalseLong: distance
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genBranchPopFalseLong: distance [
	"239		11101111	iiiiiiii		Pop and Jump 0n False #iiiiiiii (+ Extend B * 256, where Extend B >= 0)	"
	| distanceMod256 |
	(distance < 0 or: [distance > 32767]) ifTrue:
		[^self outOfRangeError: 'distance' index: distance range: 0 to: 32767].
	distanceMod256 := (distance < 0 or: [distance > 255])
							ifTrue:
								[self genUnsignedSingleExtendB: (distance bitShift: -8).
								 distance bitAnd: 255]
							ifFalse: [distance].
	stream
		nextPut: 239;
		nextPut: distanceMod256
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genBranchPopTrue: distance [
	(distance > 0 and: [distance < 9]) ifTrue:
		["184-191	10111 iii			Pop and Jump 0n True iii + 1 (i.e., 1 through 8)"
		 stream nextPut: 183 + distance.
		 ^self].
	^self genBranchPopTrueLong: distance
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genBranchPopTrueLong: distance [
	"238		11101110	iiiiiiii		Pop and Jump 0n True #iiiiiiii (+ Extend B * 256, where Extend B >= 0)"
	| distanceMod256 |
	(distance < 0 or: [distance > 32767]) ifTrue:
		[^self outOfRangeError: 'distance' index: distance range: 0 to: 32767].
	(distance > 0 and: [distance < 9]) ifTrue:
		["184-191	10111 iii			Pop and Jump 0n True iii + 1 (i.e., 1 through 8)"
		 stream nextPut: 183 + distance.
		 ^self].
	distanceMod256 := (distance < 0 or: [distance > 255])
							ifTrue:
								[self genUnsignedSingleExtendB: (distance bitShift: -8).
								 distance bitAnd: 255]
							ifFalse: [distance].
	stream
		nextPut: 238;
		nextPut: distanceMod256
]

{ #category : #'extended bytecode generation' }
EncoderForSistaV1 >> genCallMappedInlinedPrimitive: primIndex [
	"236		11101100	iiiiiiii		callMappedInlinedPrimitive [Sista specific]"
	(primIndex < 0 or: [primIndex > 255]) ifTrue:
		[self outOfRangeError: 'primitive index' index: primIndex range: 1 to: 32767].
	stream
		nextPut: 236;
		nextPut: primIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genCallPrimitive: primitiveIndex [
	"248		11111000	i i i i i i i i	0jjjjjjj		Call Primitive #iiiiiiii + (jjjjjjj * 256)"
	"N.B. We could have made CallPrimitive a 2-byte code taking an extension, but that would
	 complicate the VM's determination of the primitive number and the primitive error code
	 store since the extension, being optional, would make the sequence variable length."
	(primitiveIndex < 1 or: [primitiveIndex > 65535]) ifTrue:
		[self outOfRangeError: 'primitive index' index: primitiveIndex range: 1 to: 65535].
	stream
		nextPut: 248;
		nextPut: (primitiveIndex bitAnd: 255);
		nextPut: (primitiveIndex bitShift: -8)
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genDup [
	"83			01010011			Duplicate Stack Top"
	stream nextPut: 83
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genJump: distance [
	(distance > 0 and: [distance < 9]) ifTrue:
		["176-183	10110 iii			Jump iii + 1 (i.e., 1 through 8)"
		 stream nextPut: 175 + distance.
		 ^self].
	"237		11101101	iiiiiiii		Jump #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	^self genJumpLong: distance
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genJumpLong: distance [
	"237		11101101	iiiiiiii		Jump #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	(distance between: -32768 and: 32767) ifFalse:
		[^self outOfRangeError: 'index' index: distance range: -32768 to: 32767].
	(distance < 0 or: [distance > 255]) ifTrue:
		[self genSignedSingleExtendB: (distance bitShift: -8)].
	stream
		nextPut: 237;
		nextPut: (distance bitAnd: 255)
]

{ #category : #'extended bytecode generation' }
EncoderForSistaV1 >> genNop [
	"95			01011111			Nop"
	stream nextPut: 95
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPop [
	"216		11011000			Pop Stack Top"
	stream nextPut: 216
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushCharacter: aCharacterOrCode [
	"233		11101001	i i i i i i i i	Push Character #iiiiiiii (+ Extend B * 256)"
	"Why restrict the range to 16 bits when we could encode arbitrarily 32-bit Characters?
	 Well, 16 bits requires 4 bytes (extB + byte, 78 + byte) and so beyond this range we
	 lose space verses a single-byte pushLiteral and a 4 byte Character literal on 32-bits.
	 And generating the same bytecode on 64-bit and 32-bit is important if we want to be
	 able to load binary code from one to the other (e.g. via Fuel)."
	| code |
	code := aCharacterOrCode isInteger ifTrue: [aCharacterOrCode] ifFalse: [aCharacterOrCode asInteger].
	(code < 0 or: [code > 65535]) ifTrue:
		[^self outOfRangeError: 'character' index: code range: 0 to: 65535].
	(code > 255) ifTrue:
		[self genUnsignedSingleExtendB: (code bitShift: -8)].
	stream
		nextPut: 233;
		nextPut: (code bitAnd: 255)
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushClosureCopyNumCopiedValues: numCopied numArgs: numArgs jumpSize: jumpSize [
	"250		11111010 eeiiikkk		jjjjjjjj		Push Closure Num Copied iii (+ Ext A // 16 * 8) Num Args kkk (+ Ext A \\ 16 * 8) BlockSize jjjjjjjj (+ Ext B * 256). ee = num extensions"
	"Including numExtensions makes decoding the bytecode quicker since it obviates having to scan from the beginning of a method."
	| numExtensions numCopiedMod8 numArgsMod8 extA |
	(jumpSize < 0 or: [jumpSize > 65535]) ifTrue:
		[^self outOfRangeError: 'block size' index: jumpSize range: 0 to: 65535].
	(numCopied < 0 or: [numCopied > 127]) ifTrue:
		[^self outOfRangeError: 'num copied' index: numCopied range: 0 to: 127].
	(numArgs < 0 or: [numArgs > 127]) ifTrue:
		[^self outOfRangeError: 'num args' index: numArgs range: 0 to: 127].
	extA := numExtensions := 0.
	(numArgsMod8 := numArgs) > 7 ifTrue:
		[extA := numArgs // 8.
		 numArgsMod8 := numArgsMod8 \\ 8].
	(numCopiedMod8 := numCopied) > 7 ifTrue:
		[extA := extA + (numCopied // 8 * 16).
		 numCopiedMod8 := numCopiedMod8 \\ 8].
	extA ~= 0 ifTrue:
		[self genUnsignedSingleExtendA: extA.
		 numExtensions := 1].
	jumpSize > 255 ifTrue:
		[numExtensions := numExtensions + 1.
		 self genUnsignedSingleExtendB: jumpSize // 256].
	stream
		nextPut: 250;
		nextPut: (numExtensions bitShift: 6) + (numCopiedMod8 bitShift: 3) + numArgsMod8;
		nextPut: (jumpSize bitAnd: 16rFF)
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushConsArray: size [
	(size < 0 or: [size > 127]) ifTrue:
		[^self outOfRangeError: 'size' index: size range: 0 to: 127].
	"231		11100111	jkkkkkkk	Push (Array new: kkkkkkk) (j = 0)
									&	Pop kkkkkkk elements into: (Array new: kkkkkkk) (j = 1)"
	stream
		nextPut: 231;
		nextPut: size + 128
]

{ #category : #'extended bytecode generation' }
EncoderForSistaV1 >> genPushFullClosure: compiledBlockLiteralIndex numCopied: numCopied receiverOnStack: receiverOnStack outerContextNeeded: outerContextNeeded [
	"*	249		11111001 	xxxxxxxx	siyyyyyy	push Closure Compiled block literal index xxxxxxxx (+ Extend A * 256) numCopied yyyyyy receiverOnStack: s = 1 ignoreOuterContext: i = 1"
	| extendedIndex |
	(numCopied < 0 or: [numCopied > 64]) ifTrue:
		[self outOfRangeError: 'num copied' index: numCopied range: 0 to: 64].
	(compiledBlockLiteralIndex < 0 or: [compiledBlockLiteralIndex > 32768]) ifTrue:
		[^self outOfRangeError: 'index' index: compiledBlockLiteralIndex range: 0 to: 32768].
	(extendedIndex := compiledBlockLiteralIndex) > 255 ifTrue:
		[self genUnsignedSingleExtendA: extendedIndex // 256.
		 extendedIndex := extendedIndex \\ 256].
	stream
		nextPut: 249;
		nextPut: extendedIndex;
		nextPut: receiverOnStack asBit << 7 + (outerContextNeeded not asBit << 6) + numCopied
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushInstVar: instVarIndex [
	(instVarIndex between: 0 and: 15) ifTrue:
		["0-15 	0000iiii 	Push Receiver Variable #iiii"
		 stream nextPut: 0 + instVarIndex.
		 ^self].
	self genPushInstVarLong: instVarIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushInstVarLong: instVarIndex [
	"226		11100010	i i i i i i i i	Push Receiver Variable #iiiiiiii (+ Extend A * 256)"
	"See also MaybeContextInstanceVariableNode"
	(instVarIndex < 0 or: [instVarIndex > 65535]) ifTrue:
		[^self outOfRangeError: 'index' index: instVarIndex range: 0 to: 65535].
	instVarIndex > 255 ifTrue:
		[self genUnsignedSingleExtendA: instVarIndex // 256].
	stream
		nextPut: 226;
		nextPut: instVarIndex \\ 256
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushInteger: anInteger [
	"80			01010000				Push 0
	 81			01010001				Push 1
	 232		11101000	i i i i i i i i	Push Integer #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	anInteger = 0 ifTrue:
		[stream nextPut: 80.
		 ^self].
	anInteger = 1 ifTrue:
		[stream nextPut: 81.
		 ^self].
	(anInteger < 0 or: [anInteger > 255]) ifTrue:
		[^self genPushIntegerLong: anInteger].
	stream
		nextPut: 232;
		nextPut: (anInteger bitAnd: 255)
]

{ #category : #'extended bytecode generation' }
EncoderForSistaV1 >> genPushIntegerLong: anInteger [
	"232		11101000	i i i i i i i i	Push Integer #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	"Why restrict the range to 16 bits when we could encode arbitrarily large integers?
	 Well, 16 bits requires 4 bytes (extB + byte, 78 + byte) and so beyond this range we lose space
	 verses a single-byte pushLiteral and a 4 byte integer literal on 32-bits.  And generating the same
	 bytecode on 64-bit and 32-bit is important if we want to be able to load binary code from one to
	 the other (e.g. via Fuel)."
	(anInteger < -32768 or: [anInteger > 32767]) ifTrue:
		[^self outOfRangeError: 'integer' index: anInteger range: -32768 to: 32767].
	self genSignedSingleExtendB: (anInteger bitShift: -8).
	stream
		nextPut: 232;
		nextPut: (anInteger bitAnd: 255)
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushLiteral: literalIndex [
	| extendedIndex |
	(literalIndex < 0 or: [literalIndex > 32768]) ifTrue:
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 32768].
	literalIndex < 32 ifTrue: 
		["32-63 	001iiiii 	Push Literal #iiiii"
		 stream nextPut: 32 + literalIndex.
		 ^self].
	"228		11100100	i i i i i i i i	Push Literal #iiiiiiii (+ Extend A * 256)"
	(extendedIndex := literalIndex) > 255 ifTrue:
		[self genUnsignedSingleExtendA: extendedIndex // 256.
		 extendedIndex := extendedIndex \\ 256].
	stream
		nextPut: 228;
		nextPut: extendedIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushLiteralVar: literalIndex [
	| extendedIndex |
	(literalIndex < 0 or: [literalIndex > 32768]) ifTrue:
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 32768].
	literalIndex < 16 ifTrue: 
		["16-31		0001 i i i i		Push Literal Variable #iiii"
		 stream nextPut: 16 + literalIndex.
		 ^self].
	"227		11100011	i i i i i i i i	Push Literal Variable #iiiiiiii (+ Extend A * 256)"
	(extendedIndex := literalIndex) > 255 ifTrue:
		[self genUnsignedSingleExtendA: extendedIndex // 256.
		 extendedIndex := extendedIndex \\ 256].
	stream
		nextPut: 227;
		nextPut: extendedIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushNewArray: size [
	(size < 0 or: [size > 127]) ifTrue:
		[^self outOfRangeError: 'size' index: size range: 0 to: 127].
	"231		11100111	jkkkkkkk	Push (Array new: kkkkkkk) (j = 0)
									&	Pop kkkkkkk elements into: (Array new: kkkkkkk) (j = 1)"
	stream
		nextPut: 231;
		nextPut: size
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushReceiver [
	"76			01001100		Push Receiver"
	stream nextPut: 76
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushRemoteTemp: tempIndex inVectorAt: tempVectorIndex [
	"251		11111011 	kkkkkkkk	sjjjjjjj		Push Temp At kkkkkkkk In Temp Vector At: jjjjjjj, s = 1 implies remote inst var access instead of remote temp vector access"
	(tempIndex < 0 or: [tempIndex >= 256]) ifTrue:
		[^self outOfRangeError: 'remoteTempIndex' index: tempIndex range: 0 to: 255].
	(tempVectorIndex < 0 or: [tempVectorIndex >= 128]) ifTrue:
		[^self outOfRangeError: 'tempVectorIndex' index: tempVectorIndex range: 0 to: 127].
	stream
		nextPut: 251;
		nextPut: tempIndex;
		nextPut: tempVectorIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushSpecialLiteral: aLiteral [
	"77			01001101			Push true
	 78			01001110			Push false
	 79			01001111			Push nil
	 80			01010000			Push 0
	 81			01010001			Push 1
	 232		11101000	iiiiiiii		Push Integer #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	| index |
	aLiteral isInteger ifTrue:
		[aLiteral == 0 ifTrue:
			[stream nextPut: 80.
			 ^self].
		 aLiteral == 1 ifTrue:
			[stream nextPut: 81.
			 ^self].
		 ^self genPushInteger: aLiteral].
	index := #(true false nil)
					indexOf: aLiteral
					ifAbsent: [^self error: 'push special literal: ', aLiteral printString,  ' is not one of true false nil'].
	stream nextPut: 76 + index
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushTemp: tempIndex [
	(tempIndex < 0 or: [tempIndex > 63]) ifTrue:
		[^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63].
	tempIndex < 12 ifTrue: 
		["64-71		01000 i i i		Push Temporary Variable #iii
		   72-75	010010 i i		Push Temporary Variable #ii + 8"
		 stream nextPut: 64 + tempIndex.
		 ^self].
	"229		11100101	i i i i i i i i	Push Temporary Variable #iiiiiiii"
	stream
		nextPut: 229;
		nextPut: tempIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushThisContext [
	"82			01010010			Push thisContext, (then e.g. Extend B 1 = push thisProcess)"
	stream nextPut: 82
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genPushThisProcess [
	"82			01010010			Push thisContext, (then e.g. Extend B 1 = push thisProcess)"
	stream nextPut: 225.
	stream nextPut: 1.
	stream nextPut: 82.

]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genReturnReceiver [
	"88-91		010110 ii			Return Receiver/true/false/nil"
	stream nextPut: 88
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genReturnSpecialLiteral: aLiteral [
	"88-91		010110 ii			Return Receiver/true/false/nil"
	| index |
	index := #(true false nil) indexOf: aLiteral ifAbsent: 0.
	index = 0 ifTrue:
		[^self error: 'return special literal: ', aLiteral printString,  ' is not one of true false nil'].
	stream nextPut: 88 + index
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genReturnTop [
	"92		1011100		Return Stack Top From Message"
	stream nextPut: 92
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genReturnTopToCaller [
	"94		01011110		Return Stack Top From Block [* return from enclosing block N, ExtA]"
	"If extended, the least significant bit of the extension determines if we return to the caller or not
	 and the most significant bits determine how many levels of the static chain to return from.
		ExtA = iiiiiiij
		iiiiiii=0,j=0	=>	return to caller
		iiiiiii=0,j=1	=>	illegal
		iiiiiii=1,j=0	=>	return to outerContext
		iiiiiii=1,j=1	=>	return to outerContext sender/return from outerContext
		iiiiiii=2,j=0	=>	return to outerContext outerContext
		iiiiiii=2,j=1	=>	return to outerContext outerContext sender/return from outerContext outerContext
		etc"

	stream nextPut: 94
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genSend: selectorLiteralIndex numArgs: nArgs [
	| extendedIndex extendedNArgs |
	(selectorLiteralIndex < 0 or: [selectorLiteralIndex > 65535]) ifTrue:
		[^self outOfRangeError: 'selectorLiteralIndex' index: selectorLiteralIndex range: 0 to: 65535].
	(nArgs < 0 or: [nArgs > 31]) ifTrue:
		[^self outOfRangeError: 'numArgs' index: nArgs range: 0 to: 31 "!!"].
	(selectorLiteralIndex < 16 and: [nArgs < 3]) ifTrue: 
	 	["128-143	1000 iiii			Send Literal Selector #iiii With 0 Argument
		  144-159	1001 iiii			Send Literal Selector #iiii With 1 Arguments
		  160-175	1010 iiii			Send Literal Selector #iiii With 2 Arguments"
		 stream nextPut: 128 + (nArgs * 16) + selectorLiteralIndex.
		 ^self].
	(extendedIndex := selectorLiteralIndex) > 31 ifTrue:
		[self genUnsignedSingleExtendA: extendedIndex // 32.
		 extendedIndex := extendedIndex \\ 32].
	(extendedNArgs := nArgs) > 7 ifTrue:
		[self genUnsignedSingleExtendB: extendedNArgs // 8.
		 extendedNArgs := extendedNArgs \\ 8].
	"234		11101010	i i i i i j j j	Send Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments"
	stream
		nextPut: 234;
		nextPut: extendedNArgs + (extendedIndex * 8)
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genSendDirectedSuper: selectorLiteralIndex numArgs: nArgs [
	| extendedIndex |
	(selectorLiteralIndex < 0 or: [selectorLiteralIndex > 65535]) ifTrue:
		[^self outOfRangeError: 'selectorLiteralIndex' index: selectorLiteralIndex range: 0 to: 65535].
	(nArgs < 0 or: [nArgs > 31]) ifTrue:
		[^self outOfRangeError: 'numArgs' index: nArgs range: 0 to: 31 "!!"].
	(extendedIndex := selectorLiteralIndex) > 31 ifTrue:
		[self genUnsignedSingleExtendA: extendedIndex // 32.
		 extendedIndex := extendedIndex \\ 32].
	"Bit 6 of the ExtB byte is the directed send flag.  Bit 6 allows for future expansion to up to 255 args."
	self genUnsignedSingleExtendB: nArgs // 8 + 64.
	"235		11101011	iiiiijjj		Send To Superclass Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments"
	stream
		nextPut: 235;
		nextPut: nArgs \\ 8 + (extendedIndex * 8)
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genSendSpecial: specialSelectorIndex numArgs: nArgs [
	self assert: (specialSelectorIndex between: 1 and: Smalltalk specialSelectorSize).
	self assert: nArgs = (Smalltalk specialNargsAt: specialSelectorIndex).
	"Special selector sends.
		96-111		0110 iiii			Send Arithmetic Message #iiii #(#+ #- #< #> #'<=' #'>=' #= #'~=' #* #/ #'\\' #@ #bitShift: #'//' #bitAnd: #bitOr:)
		112-119	01110 iii			Send Special Message #iii #(#at: #at:put: #size ? ? ? #'==' class ? value value: ? ? ? ? ?)"

	stream nextPut: specialSelectorIndex + 95
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genSendSuper: selectorLiteralIndex numArgs: nArgs [
	| extendedIndex extendedNArgs |
	(selectorLiteralIndex < 0 or: [selectorLiteralIndex > 65535]) ifTrue:
		[^self outOfRangeError: 'selectorLiteralIndex' index: selectorLiteralIndex range: 0 to: 65535].
	(nArgs < 0 or: [nArgs > 31]) ifTrue:
		[^self outOfRangeError: 'numArgs' index: nArgs range: 0 to: 31 "!!"].
	(extendedIndex := selectorLiteralIndex) > 31 ifTrue:
		[self genUnsignedSingleExtendA: extendedIndex // 32.
		 extendedIndex := extendedIndex \\ 32].
	(extendedNArgs := nArgs) > 7 ifTrue:
		[self genUnsignedSingleExtendB: extendedNArgs // 8.
		 extendedNArgs := extendedNArgs \\ 8].
	"235		11101011	iiiiijjj		Send To Superclass Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments"
	stream
		nextPut: 235;
		nextPut: extendedNArgs + (extendedIndex * 8)
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genSignedSingleExtendB: extendedIndex [
	(extendedIndex between: -128 and: 127) ifFalse:
		[^self outOfRangeError: 'index' index: extendedIndex range: -128 to: 127].
	"225		11100001	sbbbbbbb	Extend B (Ext B = Ext B prev * 256 + Ext B)"
	stream
		nextPut: 225;
		nextPut: (extendedIndex >= 0 ifTrue: [extendedIndex] ifFalse: [extendedIndex + 256]) 
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genStoreInstVar: instVarIndex [
	"243		11110011	iiiiiiii		Store Receiver Variable #iiiiiii (+ Extend A * 256)"
	(instVarIndex < 0 or: [instVarIndex > 65535]) ifTrue:
		[^self outOfRangeError: 'index' index: instVarIndex range: 0 to: 65535].
	instVarIndex > 255 ifTrue:
		[self genUnsignedSingleExtendA: instVarIndex // 256].
	stream
		nextPut: 243;
		nextPut: instVarIndex \\ 256
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genStoreInstVarLong: instVarIndex [
	"Only one instruction for inst var store, so there is no long encoding. However this is used only for MaybeContext object, there is no storeInstVar in the image for those and it is very unlikely that anyone would add some. So I did not add a different bytecode for such an uncommon case."
	self genStorePopInstVarLong: instVarIndex.
	self genPushInstVarLong: instVarIndex.
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genStoreLiteralVar: literalIndex [
	"244		11110100	iiiiiiii		Store Literal Variable #iiiiiiii (+ Extend A * 256)"
	(literalIndex < 0 or: [literalIndex > 32768]) ifTrue:
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 32768].
	literalIndex > 255 ifTrue: 
		[self genUnsignedSingleExtendA: literalIndex // 256].
	stream
		nextPut: 244;
		nextPut: literalIndex \\ 256
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genStorePopInstVar: instVarIndex [
	"200-207	11001 iii			Pop and Store Receiver Variable #iii
	 240		11110000	iiiiiiii	Pop and Store Receiver Variable #iiiiiii (+ Extend A * 256)"
	(instVarIndex < 0 or: [instVarIndex > 7]) ifTrue:
		[^self genStorePopInstVarLong: instVarIndex].
	stream nextPut: 200 + instVarIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genStorePopInstVarLong: instVarIndex [
	"240		11110000	iiiiiiii		Pop and Store Receiver Variable #iiiiiii (+ Extend A * 256)"
	(instVarIndex < 0 or: [instVarIndex > 65535]) ifTrue:
		[^self outOfRangeError: 'index' index: instVarIndex range: 0 to: 65535].
	instVarIndex > 255 ifTrue:
		[self genUnsignedSingleExtendA: instVarIndex // 256].
	stream
		nextPut: 240;
		nextPut: instVarIndex \\ 256
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genStorePopLiteralVar: literalIndex [
	"241		11110001	iiiiiiii		Pop and Store Literal Variable #iiiiiiii (+ Extend A * 256)"
	(literalIndex < 0 or: [literalIndex > 32768]) ifTrue:
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 32768].
	literalIndex > 255 ifTrue: 
		[self genUnsignedSingleExtendA: literalIndex // 256].
	stream
		nextPut: 241;
		nextPut: literalIndex \\ 256
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genStorePopRemoteTemp: tempIndex inVectorAt: tempVectorIndex [
	"*	253	(3)	11111101 	kkkkkkkk	sjjjjjjj		Pop and Store Temp At kkkkkkkk In Temp Vector At: jjjjjjj s = 1 implies remote inst var access instead of remote temp vector access"
	(tempIndex < 0 or: [tempIndex >= 256]) ifTrue:
		[^self outOfRangeError: 'remoteTempIndex' index: tempIndex range: 0 to: 255].
	(tempVectorIndex < 0 or: [tempVectorIndex >= 128]) ifTrue:
		[^self outOfRangeError: 'tempVectorIndex' index: tempVectorIndex range: 0 to: 127].
	stream
		nextPut: 253;
		nextPut: tempIndex;
		nextPut: tempVectorIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genStorePopTemp: tempIndex [
	"208-215	11010 iii			Pop and Store Temporary Variable #iii
	 242		11110010	iiiiiiii	Pop and Store Temporary Variable #iiiiiiii"
	(tempIndex < 0 or: [tempIndex > 63]) ifTrue:
		[^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63].
	tempIndex < 8 ifTrue:
		[stream nextPut: 208 + tempIndex.
		 ^self].
	stream
		nextPut: 242;
		nextPut: tempIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genStoreRemoteTemp: tempIndex inVectorAt: tempVectorIndex [
	"*252	(3)	11111100 	kkkkkkkk	sjjjjjjj		Store Temp At kkkkkkkk In Temp Vector At: jjjjjjj s = 1 implies remote inst var access instead of remote temp vector access"
	(tempIndex < 0 or: [tempIndex >= 256]) ifTrue:
		[^self outOfRangeError: 'remoteTempIndex' index: tempIndex range: 0 to: 255].
	(tempVectorIndex < 0 or: [tempVectorIndex >= 128]) ifTrue:
		[^self outOfRangeError: 'tempVectorIndex' index: tempVectorIndex range: 0 to: 127].
	stream
		nextPut: 252;
		nextPut: tempIndex;
		nextPut: tempVectorIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genStoreTemp: tempIndex [
	"245		11110110	iiiiiiii		Store Temporary Variable #iiiiiiii"
	(tempIndex < 0 or: [tempIndex > 63]) ifTrue:
		[^self outOfRangeError: 'index' index: tempIndex range: 0 to: 63].
	stream
		nextPut: 245;
		nextPut: tempIndex
]

{ #category : #'extended bytecode generation' }
EncoderForSistaV1 >> genTrap [
	"217		11011001			Unconditionnal trap"
	stream nextPut: 217
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genTrapIfNotInstanceOf: literalIndex [
	"*	236		11101100	iiiiiiii		Trap If Not Instance Of Behavior/Array Of Behavior #iiiiiiii (+ Extend A * 256, where Extend A >= 0)"

	| extendedIndex |
	(literalIndex < 0 or: [literalIndex > 65535]) ifTrue:
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 65536].
	(extendedIndex := literalIndex) > 255 ifTrue:
		[self genUnsignedSingleExtendA: extendedIndex // 256.
		 extendedIndex := extendedIndex \\ 256].
	stream
		nextPut: 236;
		nextPut: extendedIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genUnsignedMultipleExtendA: extendedIndex [
	"224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)"
	extendedIndex > 255 ifTrue:
		[self genUnsignedMultipleExtendA: extendedIndex // 256].
	stream
		nextPut: 224;
		nextPut: extendedIndex \\ 256
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genUnsignedSingleExtendA: extendedIndex [
	(extendedIndex between: 0 and: 255) ifFalse:
		[^self outOfRangeError: 'index' index: extendedIndex range: 0 to: 255].
	"224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)"
	stream
		nextPut: 224;
		nextPut: extendedIndex
]

{ #category : #'bytecode generation' }
EncoderForSistaV1 >> genUnsignedSingleExtendB: extendedIndex [
	(extendedIndex between: 0 and: 255) ifFalse:
		[^self outOfRangeError: 'index' index: extendedIndex range: 0 to: 255].
	"225		11100001	sbbbbbbb	Extend B (Ext B = Ext B prev * 256 + Ext B)"
	stream
		nextPut: 225;
		nextPut: extendedIndex
]

{ #category : #'special literal encodings' }
EncoderForSistaV1 >> isSpecialLiteralForPush: literal [
	^literal == false
	  or: [literal == true
	  or: [literal == nil
	  or: [(literal isInteger and: [literal between: -32768 and: 32767])
	  or: [(literal isCharacter and: [literal asInteger between: 0 and: 65535])]]]]
]

{ #category : #'special literal encodings' }
EncoderForSistaV1 >> sizePushFullClosure: compiledBlockLiteralIndex numCopied: numCopied [
	^self sizeOpcodeSelector: #genPushFullClosure:numCopied: withArguments: {compiledBlockLiteralIndex.numCopied}
]

{ #category : #'special literal encodings' }
EncoderForSistaV1 >> sizePushFullClosure: compiledBlockLiteralIndex numCopied: numCopied receiverOnStack: rcvrOnStack ignoreOuterContext: ignoreOuterContext [
	^self sizeOpcodeSelector: #genPushFullClosure:numCopied:receiverOnStack:ignoreOuterContext: withArguments: {compiledBlockLiteralIndex.numCopied.rcvrOnStack.ignoreOuterContext} 
]
