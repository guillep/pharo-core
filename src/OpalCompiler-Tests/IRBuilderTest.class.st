Class {
	#name : #IRBuilderTest,
	#superclass : #AbstractEnvironmentTestCase,
	#classVars : [
		'TestToPush'
	],
	#category : #'OpalCompiler-Tests-IR'
}

{ #category : #accessing }
IRBuilderTest class >> compilerClass [
	^ OpalCompiler
]

{ #category : #accessing }
IRBuilderTest class >> testToPush [
	^TestToPush
]

{ #category : #accessing }
IRBuilderTest class >> testToPush: anObject [

	TestToPush := anObject
]

{ #category : #'testing - builder' }
IRBuilderTest >> testBuildMethod [
	|  aCompiledMethod |
	
	aCompiledMethod := IRBuilder buildMethod: [ : builder | 
		builder pushLiteral: 3;
		pushDup;
		send: #=;
		returnTop].

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
]

{ #category : #testing }
IRBuilderTest >> testDup [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder buildIR: [ : builder | 
		builder pushLiteral: 3;
		pushDup;
		send: #=;
		returnTop].

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
  	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #() ).
	^iRMethod
	
]

{ #category : #testing }
IRBuilderTest >> testInstVar [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushInstVar: 1;
		pushInstVar: 2;
		send: #+;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: 3 @ 4 arguments: #()) equals: 7.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testJumpAheadTo [
	| iRMethod aCompiledMethod iRBuilder |
	iRBuilder := IRBuilder new.
	iRMethod := iRBuilder
		pushLiteral: 2;
		pushLiteral: 1;
		send: #+;
		jumpAheadTo: #end;
		pushLiteral: 3;
		jumpAheadTarget: #end;
		returnTop;
		ir.


	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 3.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testJumpAheadToIf [

	| iRMethod aCompiledMethod |
	
	iRMethod := IRBuilder new
		pushReceiver;
		pushLiteral: true;
		jumpAheadTo: #end if: true;
		returnTop;
		jumpAheadTarget: #end;	
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
 	self assert: ((aCompiledMethod valueWithReceiver: nil arguments: #() ) isNil).
	^iRMethod.
	
]

{ #category : #testing }
IRBuilderTest >> testJumpBackTo [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushReceiver;
		pushLiteral: false;
		jumpBackTarget: #begin;
		jumpAheadTo: #end if: true;
		pushLiteral: true;
		jumpBackTo: #begin;
		jumpAheadTarget: #end;	
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: ((aCompiledMethod valueWithReceiver: nil arguments: #() ) isNil).
	^iRMethod.
	
]

{ #category : #testing }
IRBuilderTest >> testLiteralArray [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: #(test 4 you);
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: #(test 4 you).
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testLiteralBoolean [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: true; 	
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: ((aCompiledMethod valueWithReceiver: nil arguments: #() )).
	^iRMethod.

	
]

{ #category : #testing }
IRBuilderTest >> testLiteralCharacter [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: $e;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: $e.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testLiteralFloat [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 2.0; 	
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
 	self assert: ((aCompiledMethod valueWithReceiver: nil arguments: #() ) closeTo: 2.0).
	^iRMethod

	
]

{ #category : #testing }
IRBuilderTest >> testLiteralInteger [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 2;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 2.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testLiteralNil [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: nil; 	
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
     self assert: ((aCompiledMethod valueWithReceiver: 4 arguments: #() ) isNil).
	^iRMethod
	
]

{ #category : #testing }
IRBuilderTest >> testLiteralString [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 'hello';
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 'hello'.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testLiteralSymbol [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: #you;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: #you.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testLiteralVariableClass [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteralVariable: Object binding;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: Object.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testLiteralVariableClassVariable [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteralVariable: (OCOpalExamples classVariableNamed: #ExampleClassVariable);
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	OCOpalExamples new classVariable: #tag.
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: #tag.
	OCOpalExamples reset.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testLiteralVariableGlobale [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteralVariable: (testingEnvironment associationAt: #Smalltalk);
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: Smalltalk.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testPopTop [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushReceiver;
		pushLiteral: false;
		popTop;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: ((aCompiledMethod valueWithReceiver: nil arguments: #() ) isNil).
	^iRMethod
	
]

{ #category : #'testing - blocks' }
IRBuilderTest >> testPushClosureCopyNoCopied [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushReceiver;
		pushClosureCopyCopiedValues: #() args: #() jumpTo: #block;
		pushLiteral: 1;
		pushLiteral: 2;
		send: #+;
		blockReturnTop;
		jumpAheadTarget: #block;
		send: #value;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 3.
	^ iRMethod
]

{ #category : #'testing - blocks' }
IRBuilderTest >> testPushClosureCopyNoCopiedArg [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushReceiver;
		pushClosureCopyCopiedValues: #() args: #(d) jumpTo: #block;
		pushLiteral: 1;
		pushTemp: #d;
		send: #+;
		blockReturnTop;
		jumpAheadTarget: #block;
		pushLiteral: 1;
		send: #value:;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 2.
	^ iRMethod
]

{ #category : #'testing - blocks' }
IRBuilderTest >> testPushClosureCopyNoCopiedArgNamed [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushReceiver;
		pushClosureCopyCopiedValues: #() args: #(d) jumpTo: #block;
		pushLiteral: 1;
		pushTemp: #d;
		send: #+;
		blockReturnTop;
		jumpAheadTarget: #block;
		pushLiteral: 1;
		send: #value:;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 2.
	^ iRMethod
]

{ #category : #'testing - blocks' }
IRBuilderTest >> testPushClosureCopyOneCopied [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		addTemps: #(c a);
		pushReceiver;
		pushLiteral: 1;
		storeTemp: #a;
		popTop;
		pushClosureCopyCopiedValues: #(a) args: #() jumpTo: #block;
		pushTemp: #a;
		blockReturnTop;
		jumpAheadTarget: #block;
		send: #value;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 1.
	^ iRMethod
]

{ #category : #'testing - blocks' }
IRBuilderTest >> testPushClosureCopyOneCopiedArg [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		addTemps: #(c a);
		pushReceiver;
		pushLiteral: 1;
		storeTemp: #a;
		popTop;
		pushClosureCopyCopiedValues: #(a) args: #(d) jumpTo: #block;
		pushTemp: #a;
		pushTemp: #d;
		send: #+;
		blockReturnTop;
		jumpAheadTarget: #block;
		pushLiteral: 1;
		send: #value:;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 2.
	^ iRMethod
]

{ #category : #'testing - blocks' }
IRBuilderTest >> testPushClosureCopyOneCopiedTemp [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		addTemps: #(c a);
		pushReceiver;
		pushLiteral: 1;
		storeTemp: #a;
		popTop;
		pushClosureCopyCopiedValues: #(a) args: #() jumpTo: #block;
		addTemps: #(d);
		"the temp"
			pushTemp: #a;
		pushLiteral: 1;
		send: #+;
		storeTemp: #d;
		popTop;
		pushTemp: #d;
		blockReturnTop;
		jumpAheadTarget: #block;
		send: #value;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 2.
	^ iRMethod
]

{ #category : #'testing - blocks' }
IRBuilderTest >> testPushClosureCopyOneCopiedTempArg [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		addTemps: #(c a);
		pushReceiver;
		pushLiteral: 1;
		storeTemp: #a;
		popTop;
		pushClosureCopyCopiedValues: #(a) args: #(e) jumpTo: #block;
		addTemps: #(d);
		"the temp"
			pushTemp: #a;
		pushTemp: #e;
		send: #+;
		storeTemp: #d;
		popTop;
		pushTemp: #d;
		blockReturnTop;
		jumpAheadTarget: #block;
		pushLiteral: 1;
		send: #value:;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 2.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testPushConsArray [
	| iRMethod aCompiledMethod receiver |
	iRMethod := IRBuilder new
		pushReceiver;
		pushConsArray: 1;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	receiver := 5 @ 8.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: receiver arguments: #()) first identicalTo: receiver.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testPushConsArray2 [
	| iRMethod aCompiledMethod receiver |
	iRMethod := IRBuilder new
		pushLiteral: 'hi!';
		pushConsArray: 1;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.

	receiver := 5 @ 8.

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: receiver arguments: #()) equals: #('hi!').
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testPushNewArray [

	| iRMethod aCompiledMethod receiver |
	iRMethod := IRBuilder new

		pushNewArray: 1;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	
	receiver :=  (5@8).

	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: ((aCompiledMethod valueWithReceiver: receiver arguments: #()) first isNil).
	^iRMethod

]

{ #category : #testing }
IRBuilderTest >> testPushSelf [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushReceiver;
		send: #class;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) identicalTo: UndefinedObject.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testPushTempArgument [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		numArgs: 2;
		addTemps: #(a b);
		pushTemp: #a;
		pushTemp: #b;
		send: #+;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #(2 8)) equals: 10.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testPushTempTemp [

	| iRMethod aCompiledMethod  |
	iRMethod := IRBuilder new
		addTemps: #(a);
		pushTemp: #a;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
     self assert: ((aCompiledMethod valueWithReceiver: 5 arguments: #() ) isNil).
	^iRMethod
	
]

{ #category : #testing }
IRBuilderTest >> testPushThisContext [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushThisContext;
		send: #receiver;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: 5 arguments: #()) equals: 5.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testPushThisProcess [
	
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushThisProcess;
		send: #class;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	
	"the bc is only created if we use EncoderForSistaV1"
	(aCompiledMethod encoderClass  = EncoderForSistaV1) ifFalse: [ ^self skip ].
	
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: Process.
	^ iRMethod
]

{ #category : #'testing - blocks' }
IRBuilderTest >> testRemoteTemp [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		addTemps: #(a c);
		"we have one real temp"
			createTempVectorNamed: #methodVector withVars: #(b);
		"b we know will be written to, so make a tempvector entry"
			pushLiteral: 1;
		storeTemp: #a;
		popTop;
		pushClosureCopyCopiedValues: #(#a #c #methodVector) args: #() jumpTo: #block;
		pushTemp: #a;
		"a is just read, so we copy it to the block"
			pushLiteral: 1;
		send: #+;
		storeRemoteTemp: #b inVector: #methodVector;
		"b comes from tempvetor, as we do write to it"
			blockReturnTop;
		jumpAheadTarget: #block;
		send: #value;
		pushRemoteTemp: #b inVector: #methodVector;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 2.
	^ iRMethod
]

{ #category : #'testing - blocks' }
IRBuilderTest >> testRemoteTempNested [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		addTemps: #(a);
		"we have one real temp"
			createTempVectorNamed: #methodVector withVars: #(b);
		"b we know will be written to, so make a tempvector entry"
			pushLiteral: 1;
		storeTemp: #a;
		popTop;
		pushClosureCopyCopiedValues: #(methodVector a) args: #() jumpTo: #block;
		createTempVectorNamed: #blockVector withVars: #(f);
		pushTemp: #a;
		"a is just read, so we copy it to the block"
			pushClosureCopyCopiedValues: #(methodVector) args: #() jumpTo: #block2;
		pushLiteral: 1;
		storeRemoteTemp: #b inVector: #methodVector;
		"f comes from tempvetor, as we do write to it"
			blockReturnTop;
		jumpAheadTarget: #block2;
		send: #value;
		send: #+;
		storeRemoteTemp: #b inVector: #methodVector;
		"b comes from tempvetor, as we do write to it"
			blockReturnTop;
		jumpAheadTarget: #block;
		send: #value;
		pushRemoteTemp: #b inVector: #methodVector;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 2.
	^ iRMethod
]

{ #category : #'testing - blocks' }
IRBuilderTest >> testRemoteTempShadowed [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		addTemps: #(a);
		"we have one real temp"
			pushLiteral: 1;
		storeTemp: #a;
		popTop;
		pushClosureCopyCopiedValues: #() args: #() jumpTo: #block;
		addTemps: #(a);
		pushTemp: #a;
		"a shadows the outer one"
			send: #isNil;
		blockReturnTop;
		jumpAheadTarget: #block;
		send: #value;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: true.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testReturnInstVar [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushInstVar: 1;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: 3 @ 4 arguments: #()) equals: 3.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testReturnTop [

	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: false;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self deny: (aCompiledMethod valueWithReceiver: nil arguments: #()).
	^iRMethod
	
]

{ #category : #testing }
IRBuilderTest >> testSendSuper [

	| iRMethod aCompiledMethod  |
	iRMethod := IRBuilder new
		pushReceiver;
		send: #isThisEverCalled toSuperOf: self class;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
     self should: [(aCompiledMethod valueWithReceiver: (self class new) arguments: #())] raise: Error.
	^iRMethod
	
]

{ #category : #testing }
IRBuilderTest >> testStoreIntoVariable [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 4;
		storeIntoLiteralVariable: (self class bindingOf: #TestToPush);
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	aCompiledMethod valueWithReceiver: nil arguments: #().
	self assert: self class testToPush equals: 4.
	self class testToPush: nil.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testStoreIvar [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 34;
		storeInstVar: 2;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: self arguments: #()) equals: 34.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testStorePopIntoVariable [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 4;
		storeIntoLiteralVariable: (self class bindingOf: #TestToPush);
		popTop;
		pushLiteralVariable: (self class bindingOf: #TestToPush);
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.


	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	aCompiledMethod valueWithReceiver: nil arguments: #().
	self assert: self class testToPush equals: 4.
	self class testToPush: nil.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testStorePopIvar [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		pushLiteral: 34;
		storeInstVar: 2;
		popTop;
		pushInstVar: 2;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: self arguments: #()) equals: 34.
	^ iRMethod
]

{ #category : #testing }
IRBuilderTest >> testStoreTemp [
	| iRMethod aCompiledMethod |
	iRMethod := IRBuilder new
		addTemps: #(a);
		pushLiteral: 34;
		storeTemp: #a;
		popTop;
		pushTemp: #a;
		returnTop;
		ir.

	aCompiledMethod := iRMethod compiledMethod.
	self assert: (aCompiledMethod isKindOf: CompiledMethod).
	self assert: (aCompiledMethod valueWithReceiver: nil arguments: #()) equals: 34.
	^ iRMethod
]
