"
I provide at least one test which corresponds to a message sent by InstructionStream>>#interpretNextInstructionFor: to its client.
"
Class {
	#name : #OCSourceCode2BytecodeTest,
	#superclass : #AbstractEnvironmentTestCase,
	#instVars : [
		'instVar'
	],
	#classVars : [
		'ClassVar'
	],
	#category : #'OpalCompiler-Tests-Source'
}

{ #category : #accessing }
OCSourceCode2BytecodeTest class >> classVar [

	 ^ClassVar

]

{ #category : #compiling }
OCSourceCode2BytecodeTest >> compile2method: sourceStream [ 
			"Compile code without logging the source in the changes file"
			^OpalCompiler new
						source: sourceStream;
						class: self class;			
						compile.
		
]

{ #category : #accessing }
OCSourceCode2BytecodeTest >> instVar [

	^ instVar
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testDoDup [
	| selector method scanner |
	method := self compile2method: 'duplicateTopBytecode 3 + 4; yourself'.
	selector := method selector.
	scanner := InstructionStream on:  method.
	1
		timesRepeat: [scanner interpretNextInstruction].
	self assert: scanner peekInstruction selector == #doDup description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testDoPop [
	| selector method scanner |
	selector := (method := self compile2method: 'popStackBytecode 3 + 4') selector.
	scanner := InstructionStream on:  method.
	3
		timesRepeat: [scanner interpretNextInstruction].
	self assert: scanner peekInstruction selector == #doPop description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimAdd [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimAdd 3 + 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#+. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimAt [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimAt self at: 3') selector.
	scanner := InstructionStream on: method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#at:. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimAtEnd [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimSize self atEnd') selector.
	scanner := InstructionStream on:  method.
	1
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#atEnd. false. 0}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimAtPut [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimAtPut self at: 3 put: 4') selector.
	scanner := InstructionStream on:  method.
	3
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#at:put:. false. 2}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimBitAnd [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimBitAnd 3 bitAnd: 4') selector.
	scanner := InstructionStream on: method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#bitAnd:. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimBitOr [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimBitOr 3 bitOr: 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#bitOr:. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimBitShift [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimBitShift 3 bitShift: 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#bitShift:. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimDivide [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimDivide 3 / 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#/. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimDoWith [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodeDoWith self do: #something') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#do:. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimEqual [
	| selector method scanner did |
	selector := (method  := self compile2method: 'bytecodePrimEqual 3 = 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#'='. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimGreaterOrEqual [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimGreaterOrEqual 3 >= 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#'>='. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimGreaterThan [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimGreaterThan 3 > 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#>. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimIdentity [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimIdentity 3 == 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#==. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimLessOrEqual [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimLessOrEqual 3 <= 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#<=. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimLessThan [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimLessThan 3 < 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#<. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimMakePoint [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimMakePoint 3 @ 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#'@'. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimMod [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimMod 3 \\ 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#\\. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimMultiply [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimMultiply 3 * 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#'*'. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimNew [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimNew super new') selector.
	scanner := InstructionStream on:  method.
	1
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#new. true. 0}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimNewWith [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodeNewWith self new: 3') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#new:. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimNext [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimSize self next') selector.
	scanner := InstructionStream on:  method.
	1
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#next. false. 0}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimNextPut [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimNextPut self nextPut: 3') selector.
	scanner := InstructionStream on: method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#nextPut:. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimNotEqual [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimNotEqual 3 ~= 4') selector.
	scanner := InstructionStream on: method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#~=. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimPointX [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimPointX self x') selector.
	scanner := InstructionStream on: method.
	1
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#x. false. 0}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimPointY [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimPointY self y') selector.
	scanner := InstructionStream on: method.
	1
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#y. false. 0}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimQuo [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimQuo 3 // 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#//. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimSize [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimSize self size') selector.
	scanner := InstructionStream on: method.
	1
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#size. false. 0}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimSubtract [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimSubtract 3 - 4') selector.
	scanner := InstructionStream on:  method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#-. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimValue [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodePrimValue self value') selector.
	scanner := InstructionStream on:  method.
	1
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#value. false. 0}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPrimValueWith [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodeValueWith self value: 3') selector.
	scanner := InstructionStream on: method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#value:. false. 1}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushActiveContextBytecode [
	| selector method scanner |
	selector := (method := self compile2method: 'pushActiveContextBytecode thisContext yourself') selector.
	scanner := InstructionStream on: method.
	self assert: scanner peekInstruction selector == #pushActiveContext
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushConstantFalseBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'pushConstantFalseBytecode false yourself') selector.
	scanner := InstructionStream on: method.
	self
		assert: ((did := scanner peekInstruction) selector == #pushConstant:
				and: [did arguments first not])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushConstantMinusOneBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'pushConstantMinusOneBytecode -1 yourself') selector.
	scanner := InstructionStream on: method.
	self
		assert: ((did := scanner peekInstruction) selector == #pushConstant:
				and: [did arguments first == -1])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushConstantNilBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'pushConstantNilBytecode nil yourself') selector.
	scanner := InstructionStream on: method.
	self
		assert: ((did := scanner peekInstruction) selector == #pushConstant:
				and: [did arguments first isNil])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushConstantOneBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'pushConstantOneBytecode 1 yourself') selector.
	scanner := InstructionStream on:  method.
	self
		assert: ((did := scanner peekInstruction) selector == #pushConstant:
				and: [did arguments first == 1])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushConstantTrueBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'pushConstantTrueBytecode true yourself') selector.
	scanner := InstructionStream on: method.
	self assert: ((did := scanner peekInstruction) selector == #pushConstant:
					and: [did arguments first])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushConstantTwoBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'pushConstantTwoBytecode 2 yourself') selector.
	scanner := InstructionStream on: method.
	self
		assert: ((did := scanner peekInstruction) selector == #pushConstant:
				and: [did arguments first == 2])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushConstantZeroBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'pushConstantZeroBytecode 0 yourself') selector.
	scanner := InstructionStream on: method.
	self
		assert: ((did := scanner peekInstruction) selector == #pushConstant:
				and: [did arguments first == 0])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushLiteralConstantBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'pushLiteralConstantBytecode #() yourself') selector.
	scanner := InstructionStream on: method.
	self assert: ((did := scanner peekInstruction) selector == #pushConstant:
					and: [did arguments first = #()])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushLiteralVariableBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'pushLiteralVariableBytecode ClassVar yourself') selector.
	scanner := InstructionStream on: method.
	self
		assert: (did := scanner peekInstruction) selector == #pushLiteralVariable:
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushReceiverBytecode [
	| selector method scanner |
	selector := (method := self compile2method: 'pushReceiverBytecode ^ self yourself') selector.
	scanner := InstructionStream on: method.
	self assert: scanner peekInstruction selector == #pushReceiver
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushReceiverVariableBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'pushReceiverVariableBytecode instVar yourself') selector.
	scanner := InstructionStream on: method.
	self
		assert: ((did := scanner peekInstruction) selector == #pushReceiverVariable:
				and: [did arguments first == 3])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testPushTemporaryVariableBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'pushTemporaryVariableBytecode: t0 t0 yourself') selector.
	scanner := InstructionStream on: method.
	self
		assert: ((did := scanner peekInstruction) selector == #pushTemporaryVariable:
				and: [did arguments first == 0])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testReturnFalseBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'returnFalseBytecode 3 + 4. ^ false') selector.
	scanner := InstructionStream on: method.
	4
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #methodReturnConstant:
				and: [did arguments first not])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testReturnNilBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'returnNilBytecode 3 + 4. ^ nil') selector.
	scanner := InstructionStream on: method.
	4
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #methodReturnConstant:
				and: [did arguments first isNil])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testReturnReceiver [
	| selector method scanner |
	selector := (method := self compile2method: 'returnReceiver 3 + 4. ^ self') selector.
	scanner := InstructionStream on: method.
	4
		timesRepeat: [scanner interpretNextInstruction].
	self assert: scanner peekInstruction selector == #methodReturnReceiver
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testReturnTopFromBlock [
	| selector method scanner |
	
	"Only Valid if we have inlined closures in the method"
	CompilationContext optionFullBlockClosure ifTrue: [ ^ self skip ].
	
	selector := (method := self compile2method: 'returnTopFromBlock |ia| ^[ia]') selector.
	scanner := InstructionStream on: method.
	3 timesRepeat: [scanner interpretNextInstruction].
	self assert: scanner peekInstruction selector == #blockReturnTop
		description: ('Failed ' , selector)
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testReturnTopFromMethod [
	| selector method scanner |
	selector := (method := self compile2method: 'returnTopFromMethod ^ 3 + 4') selector.
	scanner := InstructionStream on: method.
	3
		timesRepeat: [scanner interpretNextInstruction].
	self assert: scanner peekInstruction selector == #methodReturnTop
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testReturnTrueBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'returnTrueBytecode 3 + 4. ^ true') selector.
	scanner := InstructionStream on: method.
	4
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #methodReturnConstant:
				and: [did arguments first])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testStoreAndPopLiteralVariableBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'storeAndPopLiteralVariableBytecode ClassVar := nil') selector.
	scanner := InstructionStream on: method.
	self
		assert: (did := scanner interpretNextInstruction; peekInstruction) selector == #popIntoLiteralVariable:
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testStoreAndPopReceiverVariableBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'storeAndPopReceiverVariableBytecode instVar := self') selector.
	scanner := InstructionStream on: method.
	self
		assert: ((did := scanner interpretNextInstruction; peekInstruction) selector == #popIntoReceiverVariable:
				and: [did arguments first == 3])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testStoreAndPopTemporaryVariableBytecode [
	| selector method scanner did |
	selector := (method:= self compile2method: 'storeAndPopTemporaryVariableBytecode | t0 t1 | t1 := t0') selector.
	scanner := InstructionStream on: method.
	self
		assert: ((did := scanner interpretNextInstruction; peekInstruction) selector == #popIntoTemporaryVariable:
				and: [did arguments first == 1])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testStoreIntoLiteralVariableBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'storeIntoLiteralVariableBytecode ^ (ClassVar := nil)') selector.
	scanner := InstructionStream on: method.
	self
		assert: (did := scanner interpretNextInstruction; peekInstruction) selector == #storeIntoLiteralVariable:
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testStoreIntoReceiverVariableBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'storeIntoReceiverVariableBytecode ^ (instVar := self)') selector.
	scanner := InstructionStream on: method.
	self
		assert: ((did := scanner interpretNextInstruction; peekInstruction) selector == #storeIntoReceiverVariable:
				and: [did arguments first == 3])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testStoreIntoTemporaryVariableBytecode [
	| selector method scanner did |
	selector := (method := self compile2method: 'storeIntoTemporaryVariableBytecode | t0 t1 | ^ (t1 := t0)') selector.
	scanner := InstructionStream on: method.
	self
		assert: ((did := scanner interpretNextInstruction; peekInstruction) selector == #storeIntoTemporaryVariable:
				and: [did arguments first == 1])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testSuperSend [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodeSuperSend super yourself') selector.
	scanner := InstructionStream on: method.
	1
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#yourself. true. 0}])
		description: 'Failed ' , selector
]

{ #category : #tests }
OCSourceCode2BytecodeTest >> testSuperSendWith [
	| selector method scanner did |
	selector := (method := self compile2method: 'bytecodeSuperSendWith super new: 0') selector.
	scanner := InstructionStream on: method.
	2
		timesRepeat: [scanner interpretNextInstruction].
	self
		assert: ((did := scanner peekInstruction) selector == #send:super:numArgs:
				and: [did arguments = {#new:. true. 1}])
		description: 'Failed ' , selector
]
