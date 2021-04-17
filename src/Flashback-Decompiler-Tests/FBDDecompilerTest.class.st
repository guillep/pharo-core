"
SUnit tests for FBSDecompiler
"
Class {
	#name : #FBDDecompilerTest,
	#superclass : #TestCase,
	#category : #'Flashback-Decompiler-Tests-Base'
}

{ #category : #verification }
FBDDecompilerTest >> checkCorrectDecompilation: aSelector [

	self checkCorrectMethodDecompilation: (self getMethod: aSelector)
]

{ #category : #verification }
FBDDecompilerTest >> checkCorrectDecompilationClassSide: aSelector [

	self checkCorrectMethodDecompilation: (self getMethodClassSide: aSelector)
]

{ #category : #verification }
FBDDecompilerTest >> checkCorrectMethodDecompilation: originalMethod [

	| newMethod |
	newMethod := self decompileThenRecompile: originalMethod.
	self compare: originalMethod with: newMethod
]

{ #category : #verification }
FBDDecompilerTest >> compare: originalMethod with: newMethod [

	| gp1 gp2 gp1Result gp2Result |
	gp1 := self exampleClass new.
	gp2 := self exampleClass new.
	gp1Result := gp1 withArgs: #(  ) executeMethod: newMethod.
	gp2Result := gp2 withArgs: #(  ) executeMethod: originalMethod.
	self compareResult: gp1Result with: gp2Result.
	self comparePigs: gp1 with: gp2
]

{ #category : #verification }
FBDDecompilerTest >> comparePigs: gp1 with: gp2 [

	self assert: gp1 iVar equals: gp2 iVar
]

{ #category : #verification }
FBDDecompilerTest >> compareResult: result1 with: result2 [

	self assert: result1 class equals: result2 class
]

{ #category : #private }
FBDDecompilerTest >> decompileThenRecompile: originalMethod [

	| methodNode |
	methodNode := FBDDecompiler new decompile: originalMethod.
	methodNode ifNil: [ ^ nil ].
	^ self exampleClass compiler compile: methodNode formattedCode
]

{ #category : #accessing }
FBDDecompilerTest >> exampleClass [

	^ FBDExamples
]

{ #category : #private }
FBDDecompilerTest >> getMethod: selector [

	^ self exampleClass >> selector
]

{ #category : #private }
FBDDecompilerTest >> getMethodClassSide: selector [

	^ self exampleClass class >> selector
]

{ #category : #tests }
FBDDecompilerTest >> test2Loops [

	self checkCorrectDecompilation: #example2Loops
]

{ #category : #tests }
FBDDecompilerTest >> test2Loops2 [

	self checkCorrectDecompilation: #example2Loops2
]

{ #category : #tests }
FBDDecompilerTest >> testAnd [

	self checkCorrectDecompilation: #exampleAnd
]

{ #category : #tests }
FBDDecompilerTest >> testAnd2 [

	self checkCorrectDecompilation: #exampleAnd2
]

{ #category : #tests }
FBDDecompilerTest >> testAndOr [

	self checkCorrectDecompilation: #exampleAndOr
]

{ #category : #tests }
FBDDecompilerTest >> testAndOr2 [

	self checkCorrectDecompilation: #exampleAndOr2
]

{ #category : #tests }
FBDDecompilerTest >> testAndOr3 [

	self checkCorrectDecompilation: #exampleAndOr3
]

{ #category : #tests }
FBDDecompilerTest >> testAndOr4 [

	self checkCorrectDecompilation: #exampleAndOr4
]

{ #category : #tests }
FBDDecompilerTest >> testAndOr5 [

	self checkCorrectDecompilation: #exampleAndOr5
]

{ #category : #tests }
FBDDecompilerTest >> testAndOr6 [

	self checkCorrectDecompilation: #exampleAndOr6
]

{ #category : #tests }
FBDDecompilerTest >> testBlockArgument [

	self checkCorrectDecompilation: #exampleBlockArgument
]

{ #category : #tests }
FBDDecompilerTest >> testBlockExternal [

	self checkCorrectDecompilation: #exampleBlockExternal
]

{ #category : #tests }
FBDDecompilerTest >> testBlockExternal2 [

	self checkCorrectDecompilation: #exampleBlockExternal2
]

{ #category : #tests }
FBDDecompilerTest >> testBlockExternalArg [

	self checkCorrectDecompilation: #exampleBlockExternalArg
]

{ #category : #tests }
FBDDecompilerTest >> testBlockExternalNested [

	self checkCorrectDecompilation: #exampleBlockExternalNested
]

{ #category : #tests }
FBDDecompilerTest >> testBlockInternal [

	self checkCorrectDecompilation: #exampleBlockInternal
]

{ #category : #tests }
FBDDecompilerTest >> testBlockIntoCascade [

	self checkCorrectDecompilation: #exampleBlockIntoCascade
]

{ #category : #tests }
FBDDecompilerTest >> testBlockNested [

	self checkCorrectDecompilation: #exampleBlockNested
]

{ #category : #tests }
FBDDecompilerTest >> testBlockNumCopied [

	self checkCorrectDecompilation: #exampleBlockNumCopied
]

{ #category : #tests }
FBDDecompilerTest >> testBlockWithArg [

	self checkCorrectDecompilation: #exampleBlockWithArg
]

{ #category : #tests }
FBDDecompilerTest >> testCascade [

	self checkCorrectDecompilation: #exampleCascade
]

{ #category : #tests }
FBDDecompilerTest >> testCascade2 [

	self checkCorrectDecompilation: #exampleCascade2
]

{ #category : #tests }
FBDDecompilerTest >> testCascade3 [

	self checkCorrectDecompilation: #exampleCascade3
]

{ #category : #tests }
FBDDecompilerTest >> testCascade4 [

	self checkCorrectDecompilation: #exampleCascade4
]

{ #category : #tests }
FBDDecompilerTest >> testCascadeIfFalse [

	self checkCorrectDecompilation: #exampleCascadeIfFalse
]

{ #category : #tests }
FBDDecompilerTest >> testCascadeIfNil [

	self checkCorrectDecompilation: #exampleCascadeIfNil
]

{ #category : #tests }
FBDDecompilerTest >> testCascadeIfTrueIfFalse [

	self checkCorrectDecompilation: #exampleCascadeIfTrueIfFalse
]

{ #category : #tests }
FBDDecompilerTest >> testCascadeIntoBlockIntoCascade [

	self checkCorrectDecompilation: #exampleCascadeIntoBlockIntoCascade
]

{ #category : #tests }
FBDDecompilerTest >> testCascadeIntoBlockWithTempIfTrueIfFalse [

	self checkCorrectDecompilation:
		#exampleCascadeIntoBlockWithTempIfTrueIfFalse
]

{ #category : #tests }
FBDDecompilerTest >> testCascadeIntoBlockWithTempIntoCascade [

	self checkCorrectDecompilation:
		#exampleCascadeIntoBlockWithTempIntoCascade
]

{ #category : #tests }
FBDDecompilerTest >> testCascadeNested [

	self checkCorrectDecompilation: #exampleCascadeNested
]

{ #category : #tests }
FBDDecompilerTest >> testCaseOf [

	self checkCorrectDecompilation: #exampleCaseOf
]

{ #category : #tests }
FBDDecompilerTest >> testCaseOf2 [

	self checkCorrectDecompilation: #exampleCaseOf2
]

{ #category : #tests }
FBDDecompilerTest >> testCaseOf3 [

	self checkCorrectDecompilation: #exampleCaseOf3
]

{ #category : #tests }
FBDDecompilerTest >> testCaseOf4 [
	self checkCorrectDecompilation: #exampleCaseOf4.
]

{ #category : #tests }
FBDDecompilerTest >> testCaseOf5 [
	self checkCorrectDecompilation: #exampleCaseOf5.
]

{ #category : #tests }
FBDDecompilerTest >> testCaseOf6 [

	self checkCorrectDecompilation: #exampleCaseOf6
]

{ #category : #tests }
FBDDecompilerTest >> testCaseOf7 [

	self checkCorrectDecompilation: #exampleCaseOf7
]

{ #category : #tests }
FBDDecompilerTest >> testCaseOf8 [

	self checkCorrectDecompilation: #exampleCaseOf8
]

{ #category : #tests }
FBDDecompilerTest >> testCaseOfOtherwise [

	self checkCorrectDecompilation: #exampleCaseOfOtherwise
]

{ #category : #tests }
FBDDecompilerTest >> testClassVar [

	self checkCorrectDecompilation: #exampleClassVar
]

{ #category : #tests }
FBDDecompilerTest >> testCopyingBlock [

	self checkCorrectDecompilation: #exampleCopyingBlock
]

{ #category : #tests }
FBDDecompilerTest >> testDoublePrimitive [
	self checkCorrectDecompilation: #exampleDoublePrimitive
]

{ #category : #tests }
FBDDecompilerTest >> testDoubleRemoteAnidatedBlocks [

	self checkCorrectDecompilation: #doubleRemoteAnidatedBlocks
]

{ #category : #tests }
FBDDecompilerTest >> testEffectValues [

	self checkCorrectDecompilation: #exampleEffectValues
]

{ #category : #tests }
FBDDecompilerTest >> testEmptyMethod [

	self checkCorrectDecompilation: #exampleEmptyMethod
]

{ #category : #tests }
FBDDecompilerTest >> testFullBlock [

	self checkCorrectDecompilation: #exampleFullBlock
]

{ #category : #tests }
FBDDecompilerTest >> testIV [

	self checkCorrectDecompilation: #exampleIV
]

{ #category : #tests }
FBDDecompilerTest >> testIfFalse [

	self checkCorrectDecompilation: #exampleIfFalse
]

{ #category : #tests }
FBDDecompilerTest >> testIfFalse2 [

	self checkCorrectDecompilation: #exampleIfFalse2
]

{ #category : #tests }
FBDDecompilerTest >> testIfFalse3 [

	self checkCorrectDecompilation: #exampleIfFalse3
]

{ #category : #tests }
FBDDecompilerTest >> testIfFalseIfTrue [

	self checkCorrectDecompilation: #exampleIfFalseIfTrue
]

{ #category : #tests }
FBDDecompilerTest >> testIfFalseIfTrue2 [

	self checkCorrectDecompilation: #exampleIfFalseIfTrue2
]

{ #category : #tests }
FBDDecompilerTest >> testIfFalseIfTrue3 [

	self checkCorrectDecompilation: #exampleIfFalseIfTrue3
]

{ #category : #tests }
FBDDecompilerTest >> testIfFalseIfTrue4 [

	self checkCorrectDecompilation: #exampleIfFalseIfTrue4
]

{ #category : #tests }
FBDDecompilerTest >> testIfFalseIfTrue5 [

	self checkCorrectDecompilation: #exampleIfFalseIfTrue5
]

{ #category : #tests }
FBDDecompilerTest >> testIfFalseIfTrue6 [

	self checkCorrectDecompilation: #exampleIfFalseIfTrue6
]

{ #category : #tests }
FBDDecompilerTest >> testIfNil [

	self checkCorrectDecompilation: #exampleIfNil
]

{ #category : #tests }
FBDDecompilerTest >> testIfNilClosure [

	self checkCorrectDecompilation: #exampleIfNilClosure
]

{ #category : #tests }
FBDDecompilerTest >> testIfNilDup [

	self checkCorrectDecompilation: #exampleIfNilDup
]

{ #category : #tests }
FBDDecompilerTest >> testIfNilIfNotNil [

	self checkCorrectDecompilation: #exampleIfNilIfNotNil
]

{ #category : #tests }
FBDDecompilerTest >> testIfNotNilArg [

	self checkCorrectDecompilation: #exampleIfNotNilArg
]

{ #category : #tests }
FBDDecompilerTest >> testIfNotNilDup [

	self checkCorrectDecompilation: #exampleIfNotNilDup
]

{ #category : #tests }
FBDDecompilerTest >> testIfNotNilReturnNil [

	self checkCorrectDecompilation: #exampleIfNotNilReturnNil
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrue [

	self checkCorrectDecompilation: #exampleIfTrue
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrue2 [

	self checkCorrectDecompilation: #exampleIfTrue2
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrue3 [

	self checkCorrectDecompilation: #exampleIfTrue3
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrueForEffectNested [

	self checkCorrectDecompilation: #exampleIfTrueForEffectNested
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrueIfFalse [

	self checkCorrectDecompilation: #exampleIfTrueIfFalse
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrueIfFalse2 [

	self checkCorrectDecompilation: #exampleIfTrueIfFalse2
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrueIfFalse3 [

	self checkCorrectDecompilation: #exampleIfTrueIfFalse3
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrueIfFalseLikeAnd [

	self checkCorrectDecompilation: #exampleIfTrueIfFalseLikeAnd
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrueIfFalseNested [

	self checkCorrectDecompilation: #exampleIfTrueIfFalseNested
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrueIfFalseNested2 [

	self checkCorrectDecompilation: #exampleIfTrueIfFalseNested2
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrueIfFalseNested3 [

	self checkCorrectDecompilation: #exampleIfTrueIfFalseNested3
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrueNested [

	self checkCorrectDecompilation: #exampleIfTrueNested
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrueWithNilAssertion [

	self checkCorrectDecompilation: #exampleIfTrueWithNilAssertion
]

{ #category : #tests }
FBDDecompilerTest >> testIfTrueWithOr [

	self checkCorrectDecompilation: #exampleIfTrueWithOr
]

{ #category : #tests }
FBDDecompilerTest >> testInlineBlockCollectionLR3 [

	self checkCorrectDecompilation: #exampleInlineBlockCollectionLR3
]

{ #category : #tests }
FBDDecompilerTest >> testMethodTempInNestedBlock [

	self checkCorrectDecompilation: #exampleMethodTempInNestedBlock
]

{ #category : #tests }
FBDDecompilerTest >> testMethodWithOptimizedBlocksA [

	self checkCorrectDecompilation: #exampleMethodWithOptimizedBlocksA
]

{ #category : #tests }
FBDDecompilerTest >> testNestedBlockScoping [

	self checkCorrectDecompilation: #exampleNestedBlockScoping
]

{ #category : #tests }
FBDDecompilerTest >> testNestedBlocksRemoteInBlockCase1 [

	self checkCorrectDecompilation: #nestedBlocksRemoteInBlockCase1
]

{ #category : #tests }
FBDDecompilerTest >> testNestedBlocksRemoteInBlockCase2 [

	self checkCorrectDecompilation: #nestedBlocksRemoteInBlockCase2
]

{ #category : #tests }
FBDDecompilerTest >> testNestedBlocksRemoteInBlockCase3 [

	self checkCorrectDecompilation: #nestedBlocksRemoteInBlockCase3
]

{ #category : #tests }
FBDDecompilerTest >> testNestedIfNilIfNotNil [

	self checkCorrectDecompilation: #exampleNestedIfNilIfNotNil
]

{ #category : #tests }
FBDDecompilerTest >> testNewArray [

	self checkCorrectDecompilation: #exampleNewArray
]

{ #category : #tests }
FBDDecompilerTest >> testNoRemoteBlockArgument [

	self checkCorrectDecompilation: #noRemoteBlockArgument
]

{ #category : #tests }
FBDDecompilerTest >> testNoRemoteBlockTemp [

	self checkCorrectDecompilation: #noRemoteBlockTemp
]

{ #category : #tests }
FBDDecompilerTest >> testNoRemoteReadInBlock [

	self checkCorrectDecompilation: #noRemoteReadInBlock
]

{ #category : #tests }
FBDDecompilerTest >> testNoRemoteReadNestedBlocks [

	self checkCorrectDecompilation: #noRemoteReadNestedBlocks
]

{ #category : #tests }
FBDDecompilerTest >> testOptimizedBlockWrittenAfterClosedOverCase1 [

	self checkCorrectDecompilation:
		#optimizedBlockWrittenAfterClosedOverCase1
]

{ #category : #tests }
FBDDecompilerTest >> testOptimizedBlockWrittenAfterClosedOverCase2 [

	self checkCorrectDecompilation:
		#optimizedBlockWrittenAfterClosedOverCase2
]

{ #category : #tests }
FBDDecompilerTest >> testOr [

	self checkCorrectDecompilation: #exampleOr
]

{ #category : #tests }
FBDDecompilerTest >> testPrimitiveErrorCode [

	self checkCorrectDecompilation: #examplePrimitiveErrorCode
]

{ #category : #tests }
FBDDecompilerTest >> testPrimitiveErrorCodeModule [

	self decompileThenRecompile:
		(self getMethod: #examplePrimitiveErrorCodeModule)
]

{ #category : #tests }
FBDDecompilerTest >> testPrimitiveErrorCodeModule2 [

	self decompileThenRecompile:
		(self getMethod: #examplePrimitiveErrorCodeModule2)
]

{ #category : #tests }
FBDDecompilerTest >> testPushArray [

	self checkCorrectDecompilation: #examplePushArray
]

{ #category : #tests }
FBDDecompilerTest >> testPushBigArray [

	self checkCorrectDecompilation: #examplePushBigArray
]

{ #category : #tests }
FBDDecompilerTest >> testRepeatEffect [

	self checkCorrectDecompilation: #exampleRepeatEffect
]

{ #category : #tests }
FBDDecompilerTest >> testRepeatValue [
	self checkCorrectDecompilation: #exampleRepeatValue
]

{ #category : #tests }
FBDDecompilerTest >> testReturn1 [

	self checkCorrectDecompilation: #exampleReturn1
]

{ #category : #tests }
FBDDecompilerTest >> testReturn1plus2 [

	self checkCorrectDecompilation: #exampleReturn1plus2
]

{ #category : #tests }
FBDDecompilerTest >> testReturn42 [

	self checkCorrectDecompilation: #exampleReturn42
]

{ #category : #tests }
FBDDecompilerTest >> testSelf [

	self checkCorrectDecompilation: #exampleSelf
]

{ #category : #tests }
FBDDecompilerTest >> testSend [

	self checkCorrectDecompilation: #exampleSend
]

{ #category : #tests }
FBDDecompilerTest >> testSend2Args [

	self checkCorrectDecompilation: #exampleSend2Args
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlock [

	self checkCorrectDecompilation: #exampleSimpleBlock
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockArgument1 [

	self checkCorrectDecompilation: #exampleSimpleBlockArgument1
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockArgument2 [

	self checkCorrectDecompilation: #exampleSimpleBlockArgument2
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockArgument3 [

	self checkCorrectDecompilation: #exampleSimpleBlockArgument3
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockArgument4 [

	self checkCorrectDecompilation: #exampleSimpleBlockArgument4
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockArgument5 [

	self checkCorrectDecompilation: #exampleSimpleBlockArgument5
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockEmpty [

	self checkCorrectDecompilation: #exampleSimpleBlockEmpty
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockLocal [

	self checkCorrectDecompilation: #exampleSimpleBlockLocal
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockLocalIf [

	self checkCorrectDecompilation: #exampleSimpleBlockLocalIf
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockLocalIfNested [

	self checkCorrectDecompilation: #exampleSimpleBlockLocalIfNested
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockLocalWhile [

	self checkCorrectDecompilation: #exampleSimpleBlockLocalWhile
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockNested [

	self checkCorrectDecompilation: #exampleSimpleBlockNested
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockReturn [

	self checkCorrectDecompilation: #exampleSimpleBlockReturn
]

{ #category : #tests }
FBDDecompilerTest >> testSimpleBlockiVar [

	self checkCorrectDecompilation: #exampleSimpleBlockiVar
]

{ #category : #tests }
FBDDecompilerTest >> testSuper [

	self checkCorrectDecompilation: #exampleSuper
]

{ #category : #tests }
FBDDecompilerTest >> testSuperCallInBlock [

	self checkCorrectDecompilation: #superCallInBlock
]

{ #category : #tests }
FBDDecompilerTest >> testSuperCallInBlockClassSide [

	self checkCorrectDecompilationClassSide: #superCallInBlock
]

{ #category : #tests }
FBDDecompilerTest >> testThisContext [

	self checkCorrectDecompilation: #exampleThisContext
]

{ #category : #tests }
FBDDecompilerTest >> testTimesRepeatEffect [

	self checkCorrectDecompilation: #exampleTimesRepeatEffect
]

{ #category : #tests }
FBDDecompilerTest >> testTimesRepeatValue [

	self checkCorrectDecompilation: #exampleTimesRepeatValue
]

{ #category : #tests }
FBDDecompilerTest >> testToByDo [

	self decompileThenRecompile: (self getMethod: #exampleToByDo)
]

{ #category : #tests }
FBDDecompilerTest >> testToByDoNegativeLoop [

	self decompileThenRecompile:
		(self getMethod: #exampleToByDoNegativeLoop)
]

{ #category : #tests }
FBDDecompilerTest >> testToDo [

	self checkCorrectDecompilation: #exampleToDo
]

{ #category : #tests }
FBDDecompilerTest >> testToDo2 [

	self checkCorrectDecompilation: #exampleToDo2
]

{ #category : #tests }
FBDDecompilerTest >> testToDo3 [

	self checkCorrectDecompilation: #exampleToDo3
]

{ #category : #tests }
FBDDecompilerTest >> testToDo4 [

	self checkCorrectDecompilation: #exampleToDo4
]

{ #category : #tests }
FBDDecompilerTest >> testToDo5 [

	self checkCorrectDecompilation: #exampleToDo5
]

{ #category : #tests }
FBDDecompilerTest >> testToDoArgument [

	self checkCorrectDecompilation: #exampleToDoArgument
]

{ #category : #tests }
FBDDecompilerTest >> testToDoArgumentLimitIsExpression [

	self checkCorrectDecompilation: #exampleToDoArgumentLimitIsExpression
]

{ #category : #tests }
FBDDecompilerTest >> testToDoArgumentNotInlined [

	self checkCorrectDecompilation: #exampleToDoArgumentNotInlined
]

{ #category : #tests }
FBDDecompilerTest >> testToDoInsideBlock [

	self checkCorrectDecompilation: #exampleToDoInsideBlock
]

{ #category : #tests }
FBDDecompilerTest >> testToDoInsideTemp [

	self checkCorrectDecompilation: #exampleToDoInsideTemp
]

{ #category : #tests }
FBDDecompilerTest >> testToDoInsideTempNotInlined [

	self checkCorrectDecompilation: #exampleToDoInsideTempNotInlined
]

{ #category : #tests }
FBDDecompilerTest >> testToDoOutsideTemp [

	self checkCorrectDecompilation: #exampleToDoOutsideTemp
]

{ #category : #tests }
FBDDecompilerTest >> testToDoOutsideTempNotInlined [

	self checkCorrectDecompilation: #exampleToDoOutsideTempNotInlined
]

{ #category : #tests }
FBDDecompilerTest >> testToDoValue [

	self checkCorrectDecompilation: #exampleToDoValue
]

{ #category : #tests }
FBDDecompilerTest >> testToDoValueLimitExpression [
	self checkCorrectDecompilation: #exampleToDoValueLimitExpression
]

{ #category : #tests }
FBDDecompilerTest >> testToDoWithMessage [

	self checkCorrectDecompilation: #exampleToDoWithMessage
]

{ #category : #tests }
FBDDecompilerTest >> testWhileFalse [

	self checkCorrectDecompilation: #exampleWhileFalse
]

{ #category : #tests }
FBDDecompilerTest >> testWhileFalse2 [

	self checkCorrectDecompilation: #exampleWhileFalse2
]

{ #category : #tests }
FBDDecompilerTest >> testWhileModificationAfterNotInlined [

	self checkCorrectDecompilation:
		#exampleWhileModificationAfterNotInlined
]

{ #category : #tests }
FBDDecompilerTest >> testWhileModificationBefore [

	self checkCorrectDecompilation: #exampleWhileModificationBefore
]

{ #category : #tests }
FBDDecompilerTest >> testWhileModificationBeforeNotInlined [

	self checkCorrectDecompilation:
		#exampleWhileModificationBeforeNotInlined
]

{ #category : #tests }
FBDDecompilerTest >> testWhileNoModification [

	self checkCorrectDecompilation: #exampleWhileNoModification
]

{ #category : #tests }
FBDDecompilerTest >> testWhileTrue [

	self checkCorrectDecompilation: #exampleWhileTrue
]

{ #category : #tests }
FBDDecompilerTest >> testWhileTrue2 [

	self checkCorrectDecompilation: #exampleWhileTrue2
]

{ #category : #tests }
FBDDecompilerTest >> testWhileTrue3 [

	self checkCorrectDecompilation: #exampleWhileTrue3
]

{ #category : #tests }
FBDDecompilerTest >> testWhileTrueSameJumpTarget [

	self checkCorrectDecompilation: #exampleWhileTrueSameJumpTarget
]

{ #category : #tests }
FBDDecompilerTest >> testWhileTrueSameJumpTarget2 [

	self checkCorrectDecompilation: #exampleWhileTrueSameJumpTarget2
]

{ #category : #tests }
FBDDecompilerTest >> testWhileWithTemp [

	self checkCorrectDecompilation: #exampleWhileWithTemp
]

{ #category : #tests }
FBDDecompilerTest >> testWhileWithTempNotInlined [

	self checkCorrectDecompilation: #exampleWhileWithTempNotInlined
]

{ #category : #tests }
FBDDecompilerTest >> testWithArgsAnd [

	self decompileThenRecompile: (self getMethod: #exampleWithArgs:and:)
]

{ #category : #tests }
FBDDecompilerTest >> testWithArgsAndTempsAnd [

	self decompileThenRecompile:
		(self getMethod: #exampleWithArgsAndTemps:and:)
]
