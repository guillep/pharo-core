"
I am the main class of FBD package.
My job is to decompile a compiledMethod to get valid Abstract Syntax Tree (AST).

The first step of decompilation is to give the byte code to the FBDLoopScanner, to annotate it. This will be important to detect all the loops in the method and handle it correctly in the Decompiler.

The second step of decompilation is to interpret the byte code to create corresponding AST nodes. The decompiler will call the right ASTBuilder method and create a full AST. 

Then the AST is returned. The Flashback Decompiler's job stops there, because there are already some frameworks to generate Smalltalk code from an AST.

The returned AST does not take optimized messages into account. Use FBDOptimizedMessagesRewriter to recover the optimized messages.

Instance Variables
	simulatedStack <OrderedCollection> Simulates the bytecode stack, pushing AST nodes instead of concrete values
	builder <FBDASTBuilder> change to another builder to build another AST than RB. By default, use a builder building RB nodes 
	instructionStream <InstructionStream> used to decode the bytecode.
	currentSequence <RBSequence> current AST sequence being decompiled
	argCount <SmallInteger> counter to create args into the current sequence with a valid name
	tempCount <SmallInteger> counter to create temps into the current sequence with a valid name
	jumpSize <SmallInteger> used to remember a jump size during a dual branch message decompilation
	loopsArray <Array> is the array containing informations about loops that the loop scanner gave me

"
Class {
	#name : #FBDDecompiler,
	#superclass : #InstructionClient,
	#instVars : [
		'simulatedStack',
		'builder',
		'instructionStream',
		'currentSequence',
		'argCount',
		'tempCount',
		'jumpSize',
		'loopsArray',
		'method'
	],
	#category : #'Flashback-Decompiler-Base'
}

{ #category : #'instruction decoding forward' }
FBDDecompiler >> blockReturnConstant: value [ 
	self pushConstant: value.
	self blockReturnTop
]

{ #category : #'data flow instructions' }
FBDDecompiler >> blockReturnTop [
	self doPop
]

{ #category : #initialize }
FBDDecompiler >> canDecompile: aCompiledMethod [
	"Answers false if aCompiledMethod can't be decompiled due to framework specific constraints."
	^ (self isPrimitiveNativeCall: aCompiledMethod) not
]

{ #category : #initialize }
FBDDecompiler >> createNArgs: numArgs [
	
	| argName |
	^ (1 to: numArgs)
		collect: [ :i | 
			self incrArgCount.
			argName := (method propertyAt: #argumentNames)
				ifNil: [ 'arg' , argCount printString ]
				ifNotNil: [ :args | args at: argCount ].
			builder codeArgument: argName ]
]

{ #category : #initialize }
FBDDecompiler >> createNTemps: numTemps [
	^ (1 to: numTemps) collect: [ :i | self newTemp ]
]

{ #category : #'control flow instructions' }
FBDDecompiler >> decodeConditionalLoop: loop nextLoops: loops [
	| condSeq pastSequence boolean |
	
	pastSequence := currentSequence.
	
	condSeq := builder codeEmptySequence.
	currentSequence := condSeq.
	self interpret: loop exitCondition - 1 nextLoops: loops.
	self doPop.
	boolean := instructionStream willJumpIfFalse.
	instructionStream advanceToFollowingPc. "skip the conditional jump exiting the loop"
	
	currentSequence := builder codeEmptySequence.
	self interpret: loop backjump - 1.
	instructionStream advanceToFollowingPc. "skip the backjump"
	
	simulatedStack addLast:  (builder 
		codeLoopNode: boolean
		condition: condSeq
		body: currentSequence).
	currentSequence := pastSequence.
	self doPop.
]

{ #category : #'control flow instructions' }
FBDDecompiler >> decodeLoop: loop nextLoops: loops [
	loop isConditionalLoop
		ifTrue: [ self decodeConditionalLoop: loop nextLoops: loops ]
		ifFalse: [ self decodeRepeatLoop: loop nextLoops: loops ]
]

{ #category : #'control flow instructions' }
FBDDecompiler >> decodeLoops: loops [
	"There are multiple loops if all their backjumps target the same pc.
	In this case the loops are ordereed from innerMost to outerMost, and we decompile them in the correct order so the inner loop is decompiled inside the outerloop"
	self decodeLoop: loops removeLast nextLoops: loops
]

{ #category : #'control flow instructions' }
FBDDecompiler >> decodeRepeatLoop: loop nextLoops: loops [
	| pastSequence  |
	
	pastSequence := currentSequence.
	
	currentSequence := builder codeEmptySequence.
	self interpret: loop backjump - 1 nextLoops: loops.
	instructionStream advanceToFollowingPc. "skip backjump"
	
	simulatedStack addLast:  (builder codeRepeatNode:  currentSequence).
	currentSequence := pastSequence.
	self doPop.
]

{ #category : #'public api' }
FBDDecompiler >> decompile: aCompiledMethod [
	"Main API. Works only if the method holds a reference to the class it is installed in and its selector. Answers an AST"
	^ self
		decompile: aCompiledMethod selector
		in: aCompiledMethod methodClass
		method: aCompiledMethod
]

{ #category : #'public api' }
FBDDecompiler >> decompile: aSelector in: aClass method: anInitialCompiledMethod [
	| aCompiledMethod |
	builder := FBDASTBuilder newFor: aClass.
	(self canDecompile: anInitialCompiledMethod)
		ifFalse: [ ^ self generateNativeBoostCallErrorMethodFrom: anInitialCompiledMethod ].
	aCompiledMethod := (self shouldUseOriginalMethod: anInitialCompiledMethod)
		ifTrue: [ anInitialCompiledMethod propertyAt: #ffiNonCompiledMethod ]
		ifFalse: [ anInitialCompiledMethod ].
	self initializeForMethod: aCompiledMethod.
	self interpretMethod: aCompiledMethod.
	^ FBDOptimizedMessagesRewriter new
		rewriteAST:
			(builder
				codeMethod: aSelector
				arguments: (simulatedStack first: aCompiledMethod numArgs)
				body: currentSequence
				pragmas: (self pragmasForMethod: aCompiledMethod)
				class: aClass)
]

{ #category : #'public api' }
FBDDecompiler >> decompileAll [
	Smalltalk globals allClassesAndTraits
		do: [ :classOrTrait | self decompileThenRecompileClass: classOrTrait ]
		displayingProgress: 'Decompiling all classes and traits'
]

{ #category : #recompilation }
FBDDecompiler >> decompileThenRecompileClass: aClass [
	{aClass.
	aClass class}
		do: [ :class | 
			class localSelectors
				do: [ :aMethod | self recompile: aMethod from: class ]
				displayingProgress: [ :aMethod | 'Decompiling ' , class name , '>>#' , aMethod asString ] ]
]

{ #category : #'data flow instructions' }
FBDDecompiler >> directedSuperSend: selector numArgs: numberArguments [

	| args currentClass |

	currentClass := self popFromStack: 1. 
	args := self popFromStack: numberArguments.
	simulatedStack removeLast.
	simulatedStack addLast: (builder codeMessage: selector receiver: builder codeSuper arguments: args ).
]

{ #category : #'data flow instructions' }
FBDDecompiler >> doDup [
	| dupTemp |
	simulatedStack last class == RBVariableNode
		ifTrue: [ ^ simulatedStack addLast: simulatedStack last ].
	self incrTempCount.
	dupTemp := self newTemp.
	currentSequence addNode: (builder codeAssignment: simulatedStack removeLast to: dupTemp).
	currentSequence addTemporaryNamed: 'tmp' , tempCount printString.
	simulatedStack 
		addLast: dupTemp;
		addLast: dupTemp.
		
]

{ #category : #'data flow instructions' }
FBDDecompiler >> doPop [
	currentSequence addNode: simulatedStack removeLast
]

{ #category : #initialize }
FBDDecompiler >> errorCodeNameFor: cm [
	"Assumes the method holds a primitive with error code"
	| primitivePragma selectorParts |
	primitivePragma := cm pragmas detect: [ :pragma | 
		selectorParts := pragma selector separateKeywords splitOn: '  '.
		selectorParts first = 'primitive:' ].
	^ primitivePragma argumentAt: (selectorParts indexOf: 'error:')
]

{ #category : #'data flow instructions' }
FBDDecompiler >> extractBlockWith: copied numArgs: numArgs blockSize: blockSize [
	| startPC numTemps |
	numTemps := instructionStream method encoderClass 
		numLocalTempsForBlockAt: self pc 
		in: instructionStream method.
	self initializeStackNumArgs: numArgs copied: copied numTemps: numTemps.
	startPC := self pc.
	self skipTemps: numTemps.
	self interpret: startPC + blockSize - 1.
	^ builder 
		codeBlock: currentSequence 
		arguments: (simulatedStack first: numArgs)
]

{ #category : #'closure support' }
FBDDecompiler >> extractFullBlock: aCompiledBlock numCopied: numCopied [

	| oldInstructionStream oldLoops|

	self
		initializeStackNumArgs: aCompiledBlock numArgs
		copied: (self popFromStack: numCopied)
		numTemps: aCompiledBlock numTemps - aCompiledBlock numArgs - numCopied.

	oldLoops := loopsArray.
	oldInstructionStream := instructionStream.

	loopsArray := FBDLoopScanner scan: aCompiledBlock.
	instructionStream := InstructionStream on: aCompiledBlock.

	self interpret: aCompiledBlock endPC.

	instructionStream := oldInstructionStream.
	loopsArray := oldLoops.

	^ builder
		codeBlock: currentSequence
		arguments: (simulatedStack first: aCompiledBlock numArgs)
]

{ #category : #private }
FBDDecompiler >> generateNativeBoostCallErrorMethodFrom: aCompiledMethod [
	| seq args |
	seq := RBSequenceNode
		statements:
			{RBMessageNode receiver: (RBVariableNode named: #CannotDecompileNativeBoostCalls) selector: #signal arguments: #()}.
	args := OrderedCollection new.
	1 to: aCompiledMethod numArgs do: [ :i | args add: (RBVariableNode named: 'arg' , i asString) ].
	^ builder
		codeMethod: aCompiledMethod selector
		arguments: args
		body: seq
		pragmas: (self pragmasForMethod: aCompiledMethod)
		class: aCompiledMethod methodClass
]

{ #category : #'data flow instructions' }
FBDDecompiler >> goToNextInstruction [
	instructionStream advanceToFollowingPc
]

{ #category : #private }
FBDDecompiler >> incrArgCount [
	argCount := argCount + 1
]

{ #category : #private }
FBDDecompiler >> incrTempCount [
	tempCount := tempCount + 1
]

{ #category : #initialize }
FBDDecompiler >> initializeErrorCode: cm [
	| index |
	cm isPrimitive
		ifFalse: [ ^ self ].
	instructionStream willStore
		ifFalse: [ ^ self ].
	index := instructionStream decodeNextInstruction arguments first.
	currentSequence removeTemporaryNamed: (simulatedStack at: index + 1) name.
	simulatedStack at: index + 1 put: (builder codeTemp: (self errorCodeNameFor: cm))
]

{ #category : #initialize }
FBDDecompiler >> initializeForMethod: aCompiledMethod [
	method := aCompiledMethod.
	loopsArray := FBDLoopScanner scan: method.
	instructionStream := InstructionStream on: method.
	self initializeStack.
	jumpSize := 0
]

{ #category : #initialize }
FBDDecompiler >> initializeStack [
	argCount := 0.
	tempCount := 0.
	self
		initializeStackNumArgs: method numArgs
		copied: #()
		numTemps: method numTemps - method numArgs
]

{ #category : #initialize }
FBDDecompiler >> initializeStackNumArgs: numArgs copied: copiedVars numTemps: numTemps [
	| args temps |
	simulatedStack := OrderedCollection new.
	args := self createNArgs: numArgs.
	temps := self createNTemps: numTemps.
	args , copiedVars , temps do: [ :arg | simulatedStack addLast: arg ].
	currentSequence := builder codeSequence: temps
]

{ #category : #private }
FBDDecompiler >> interpret: endPC [
	[ self pc > endPC ]
		whileFalse: [ 
			(loopsArray at: self pc)
				ifNotNil: [ :ls | self decodeLoops: ls ]
				ifNil: [ instructionStream interpretNextInstructionFor: self ] ].
			
]

{ #category : #'control flow instructions' }
FBDDecompiler >> interpret: endPC nextLoops: loops [
	loops 
		ifNotEmpty: [ self decodeLoops: loops ]
		ifEmpty: [ self pc > endPC ifFalse: [ instructionStream interpretNextInstructionFor: self ] ].
	self interpret: endPC 
]

{ #category : #'control flow instructions' }
FBDDecompiler >> interpret: seq1 then: seq2 distance: distance [
	| hasPopped hasPopped2 jmpSz topValue stackSize |
	"If next instruction will pop, skip it and pop the element from the stack"
	instructionStream willJustPop ifTrue: [ 
			topValue := simulatedStack removeLast.
			instructionStream advanceToFollowingPc ].

	stackSize := simulatedStack size.
	hasPopped := self interpretSeq: seq1 baseStackSize: stackSize distance: distance - topValue notNil asBit.
	jmpSz := jumpSize.
	jumpSize := 0.
	topValue ifNotNil: [:e | simulatedStack addLast: e ].
	hasPopped2 := self interpretSeq: seq2 baseStackSize: stackSize distance: jmpSz.
	^ hasPopped2 or: [hasPopped]
]

{ #category : #private }
FBDDecompiler >> interpretMethod: aCompiledMethod [
	self maybeSkipCallPrimitiveBytecode: aCompiledMethod.
	aCompiledMethod isQuick
		ifTrue: [ self quickMethod ]
		ifFalse: [ 
			self initializeErrorCode: aCompiledMethod.
			self interpret: aCompiledMethod endPC ]
]

{ #category : #'control flow instructions' }
FBDDecompiler >> interpretSeq: seq baseStackSize: stackSize distance: distance [
	currentSequence := seq.
	self interpret: self pc + distance - 1.
	^ stackSize = simulatedStack size 
		ifFalse: [ self doPop. true ]
		ifTrue: [ false ]
]

{ #category : #initialize }
FBDDecompiler >> isPrimitiveNativeCall: aCompiledMethod [
	aCompiledMethod isPrimitive
		ifFalse: [ ^ false ].
	^ (aCompiledMethod pragmas anySatisfy: [ :aPragma | aPragma arguments isNotEmpty and: [ (aPragma argumentAt: 1) = 'primitiveNativeCall' ] ])
]

{ #category : #'control flow instructions' }
FBDDecompiler >> jump: distance [
	distance < 0 ifTrue: [ ^ self error: 'should have been detected by the scanner and skipped' ].
	jumpSize := distance.
]

{ #category : #'control flow instructions' }
FBDDecompiler >> jump: distance if: boolean [
	"If we reach this code, this means this is a condition (if) and not a loop."

	| expr trueSeq falseSeq pastSequence hasPopped |
	pastSequence := currentSequence.
	expr := simulatedStack removeLast.
	trueSeq := builder codeEmptySequence.
	falseSeq := builder codeEmptySequence.
	hasPopped := boolean
		ifTrue: [ self interpret: falseSeq then: trueSeq distance: distance ]
		ifFalse: [ self interpret: trueSeq then: falseSeq distance: distance ].
	currentSequence := pastSequence.
	simulatedStack addLast: (builder codeConditionalNode: expr trueSequence: trueSeq falseSequence: falseSeq).
	hasPopped
		ifFalse: [ self doPop ]
]

{ #category : #private }
FBDDecompiler >> maybeSkipCallPrimitiveBytecode: aCompiledMethod [
	"If the method's bytecode set uses the callPrimitive bytecode, ignore it.
	The primitive is handled specifically before bytecode interpretation."
	instructionStream peekByte = aCompiledMethod encoderClass callPrimitiveCode 
		ifTrue: [ instructionStream advanceToFollowingPc ]
]

{ #category : #'instruction decoding forward' }
FBDDecompiler >> methodReturnConstant: value [ 
	self pushConstant: value.
	self methodReturnTop
]

{ #category : #'instruction decoding forward' }
FBDDecompiler >> methodReturnReceiver [
	self pushReceiver.
	self methodReturnTop
]

{ #category : #'data flow instructions' }
FBDDecompiler >> methodReturnTop [
	^ currentSequence addNode: (builder codeReturn: simulatedStack removeLast)
]

{ #category : #private }
FBDDecompiler >> newTemp [	
	self incrTempCount.
	^ builder codeTemp: 'tmp' , tempCount printString
]

{ #category : #private }
FBDDecompiler >> pc [
	^ instructionStream pc
]

{ #category : #private }
FBDDecompiler >> popFromStack: numElements [
	^ ((1 to: numElements) collect: [ :i | simulatedStack removeLast ]) reverse
]

{ #category : #'data flow instructions' }
FBDDecompiler >> popIntoLiteralVariable: association [
	self storeIntoLiteralVariable: association.
	self doPop.

]

{ #category : #'data flow instructions' }
FBDDecompiler >> popIntoReceiverVariable: offset [ 
	self storeIntoReceiverVariable: offset.
	self doPop.

]

{ #category : #'data flow instructions' }
FBDDecompiler >> popIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	self storeIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex.
	self doPop.
]

{ #category : #'data flow instructions' }
FBDDecompiler >> popIntoTemporaryVariable: offset [
	simulatedStack last class = Array
		ifTrue: [ 
			"Temp vector"
			currentSequence removeTemporaryNamed: (simulatedStack at: offset + 1) name.
			simulatedStack at: offset + 1 put: simulatedStack removeLast ]
		ifFalse: [ 
			simulatedStack
				addLast: (builder codeAssignment: simulatedStack removeLast to: (simulatedStack at: offset + 1)). self doPop ]	
]

{ #category : #initialize }
FBDDecompiler >> pragmasForMethod: aCompiledMethod [
	^ aCompiledMethod pragmas collect: [ :each |
		RBPragmaNode 
			selector: each selector 
			arguments: (each arguments collect: [ :arg | RBLiteralNode value: arg ]) ]
]

{ #category : #'data flow instructions' }
FBDDecompiler >> pushActiveContext [
	simulatedStack addLast: builder codeThisContext 
]

{ #category : #'closure support' }
FBDDecompiler >> pushCleanClosure: aCompiledBlock [

	| savedSimStack savedSequence |

	savedSimStack := simulatedStack.
	savedSequence := currentSequence.

	simulatedStack addLast: (self
		extractFullBlock: aCompiledBlock numCopied: 0).

	simulatedStack := savedSimStack.
	currentSequence := savedSequence.

]

{ #category : #'data flow instructions' }
FBDDecompiler >> pushClosureCopyNumCopiedValues: numCopied numArgs: numArgs blockSize: blockSize [
	| savedSimStack savedSequence |
	savedSimStack := simulatedStack.
	savedSequence := currentSequence.
	savedSimStack addLast: (self
		extractBlockWith: (self popFromStack: numCopied)
		numArgs: numArgs
		blockSize: blockSize).
	simulatedStack := savedSimStack.
	currentSequence := savedSequence.
]

{ #category : #'data flow instructions' }
FBDDecompiler >> pushConsArrayWithElements: numElements [
	| array |
	array := Array new: numElements.
	numElements to: 1 by: -1 do: [ :i | array at: i put: simulatedStack removeLast ].
	simulatedStack addLast: (builder codeArray: array)
]

{ #category : #'data flow instructions' }
FBDDecompiler >> pushConstant: value [
	value isEmbeddedBlock ifTrue: [ ^self pushCleanClosure: value compiledBlock  ].
	simulatedStack addLast: (builder codeLiteral: value)
]

{ #category : #'data flow instructions' }
FBDDecompiler >> pushFullClosure: aCompiledBlock numCopied: numCopied receiverOnStack: receiverOnStack ignoreOuterContext: ignoreOuterContext [ 

	| savedSimStack savedSequence |

	savedSimStack := simulatedStack.
	savedSequence := currentSequence.

	receiverOnStack ifTrue: [ self error: 'not yet supported, please open issue' ].

	simulatedStack addLast: (self
		extractFullBlock: aCompiledBlock numCopied: numCopied).

	simulatedStack := savedSimStack.
	currentSequence := savedSequence.

]

{ #category : #'data flow instructions' }
FBDDecompiler >> pushLiteralVariable: anAssociation [
	simulatedStack addLast: (builder codeAnyLitInd: anAssociation)
]

{ #category : #'data flow instructions' }
FBDDecompiler >> pushNewArrayOfSize: numElements [
	"tempVector"

	| tempVect |
	tempVect := self createNTemps: numElements.
	currentSequence addTemporariesNamed: (tempVect collect: [ :e | e name ]).
	simulatedStack addLast: tempVect
]

{ #category : #'data flow instructions' }
FBDDecompiler >> pushReceiver [
	simulatedStack addLast: builder codeReceiver 
]

{ #category : #'data flow instructions' }
FBDDecompiler >> pushReceiverVariable: offset [ 
	simulatedStack addLast: (builder codeInstanceVariable: offset + 1)

]

{ #category : #'data flow instructions' }
FBDDecompiler >> pushRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	simulatedStack addLast: ((simulatedStack at: tempVectorIndex + 1) at: remoteTempIndex + 1)
]

{ #category : #'data flow instructions' }
FBDDecompiler >> pushTemporaryVariable: offset [
	simulatedStack addLast: (simulatedStack at: offset + 1)
]

{ #category : #initialize }
FBDDecompiler >> quickMethod [
	instructionStream method isReturnSelf
		ifTrue: [ ^ self methodReturnReceiver ].
	instructionStream method isReturnSpecial
		ifTrue: [ 
			^ self
				methodReturnConstant:
					(instructionStream method encoderClass quickPrimSpecialConstants at: instructionStream method primitive - 256) ].
	instructionStream method isReturnField
		ifTrue: [ 
			self pushReceiverVariable: instructionStream method returnField.
			^ self methodReturnTop ].
	self error: 'quick method inconsistency'
]

{ #category : #recompilation }
FBDDecompiler >> recompile: selector from: oldClass [
	| newMethod |
	newMethod := oldClass compiler
		source: (self decompile: oldClass >> selector) formattedCode;
		class: oldClass;
		failBlock: [ ^ self ];
		compiledMethodTrailer: CompiledMethodTrailer empty;
		compile.	"Assume OK after proceed from SyntaxError"
	selector == newMethod selector
		ifFalse: [ self error: 'selector changed!' ].
	oldClass 	addSelector: selector withRecompiledMethod: newMethod.
]

{ #category : #'data flow instructions' }
FBDDecompiler >> send: selector numArgs: numberArguments [
	| args |
	args := self popFromStack: numberArguments.
	simulatedStack addLast: (builder codeMessage: selector receiver: simulatedStack removeLast arguments: args)
]

{ #category : #'data flow instructions' }
FBDDecompiler >> send: selector super: supered numArgs: numberArguments [
	supered 
		ifTrue:[ self superSend: selector numArgs: numberArguments ]
		ifFalse: [ self send: selector numArgs: numberArguments ]
]

{ #category : #asserting }
FBDDecompiler >> shouldUseOriginalMethod: aCompiledMethod [
	^ aCompiledMethod hasProperty: #ffiNonCompiledMethod
]

{ #category : #'data flow instructions' }
FBDDecompiler >> skipTemps: numTemps [
	instructionStream method encoderClass skipTemps: numTemps for: self
]

{ #category : #'data flow instructions' }
FBDDecompiler >> storeIntoLiteralVariable: association [
	simulatedStack addLast: (builder codeAssignment: simulatedStack removeLast to: (builder codeVariable: association key))
]

{ #category : #'data flow instructions' }
FBDDecompiler >> storeIntoReceiverVariable: offset [ 
	simulatedStack addLast: (builder codeAssignment: simulatedStack removeLast to: (builder codeInstanceVariable: offset + 1)).

]

{ #category : #'data flow instructions' }
FBDDecompiler >> storeIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	simulatedStack addLast: (builder codeAssignment: simulatedStack removeLast to: ((simulatedStack at: tempVectorIndex + 1) at: remoteTempIndex + 1))
]

{ #category : #'data flow instructions' }
FBDDecompiler >> storeIntoTemporaryVariable: offset [
	| val |
	simulatedStack addLast: (builder codeAssignment: (val := simulatedStack removeLast) to: (simulatedStack at: offset +1)).	
	(loopsArray at: self pc) ifNotNil: [ self doPop. simulatedStack addLast: val ]
]

{ #category : #'data flow instructions' }
FBDDecompiler >> superSend: selector numArgs: numberArguments [
	| args |
	args := self popFromStack: numberArguments.
	simulatedStack removeLast.
	simulatedStack addLast: (builder codeMessage: selector receiver: builder codeSuper arguments: args ).
]
