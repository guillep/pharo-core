"
Tests for Reflective method
"
Class {
	#name : #ReflectivityControlTest,
	#superclass : #TestCase,
	#instVars : [
		'tag',
		'link'
	],
	#category : #'Reflectivity-Tests-Base'
}

{ #category : #tagging }
ReflectivityControlTest >> recordLevel [
	tag := Processor activeProcess level
]

{ #category : #tagging }
ReflectivityControlTest >> return3 [
	^3
]

{ #category : #tagging }
ReflectivityControlTest >> tagExec [
	tag := #yes
]

{ #category : #tagging }
ReflectivityControlTest >> tagExec: aTag [
	tag := aTag
]

{ #category : #running }
ReflectivityControlTest >> tearDown [
	link ifNotNil: [ link uninstall ].
	super tearDown 
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterArray [
	| arrayNode |
	arrayNode := (ReflectivityExamples >> #exampleArray) ast statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	arrayNode link: link.
	self assert: arrayNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleArray) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleArray isArray.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleArray) class equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterAssignment [
	| assignmentNode |
	assignmentNode := (ReflectivityExamples >> #exampleAssignment)
		assignmentNodes first.
	self assert: assignmentNode isAssignment.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	assignmentNode link: link.
	self assert: assignmentNode hasMetalinkAfter.
	self
		assert: (ReflectivityExamples >> #exampleAssignment) class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleAssignment equals: 3.
	self assert: tag equals: 'yes'.
	self
		assert: (ReflectivityExamples >> #exampleAssignment) class
		equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterBlock [
	| blockNode |
	blockNode := (ReflectivityExamples >> #exampleBlock) ast statements first value receiver.
	self assert: blockNode isBlock.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	blockNode link: link.
	self assert: blockNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleBlock identicalTo: 5.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterBlockOptimizedIfTrue [
	| blockNode |
	blockNode := (ReflectivityExamples >> #exampleIfTrueIfFalse) ast blockNodes second.
	self assert: blockNode isBlock.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	blockNode link: link.
	self assert: blockNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleIfTrueIfFalse) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleIfTrueIfFalse identicalTo: 5.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleIfTrueIfFalse) class equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterBlockOptimizedWhileFalseSend [
	| sendNode |
	sendNode := (ReflectivityExamples >> #exampleWhileFalse) ast sendNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	sendNode link: link.
	self assert: sendNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleWhileFalse) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleWhileFalse equals: 11.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleWhileFalse) class equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterBlockSequence [
	| sequence |
	sequence := (ReflectivityExamples >> #exampleBlock) ast statements first value receiver body.
	self assert: sequence isSequence.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	sequence link: link.
	self assert: sequence hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleBlock identicalTo: 5.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterCascade [
	| cascadeNode |
	cascadeNode := (ReflectivityExamples >> #exampleCascade) ast statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	cascadeNode link: link.
	self assert: cascadeNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleCascade) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleCascade equals: 1.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleCascade) class equals: CompiledMethod
]

{ #category : #'tests - after - variables' }
ReflectivityControlTest >> testAfterClassVariable [
	| classVar |
	classVar := ReflectivityExamples classVariableNamed: #ClassVar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	classVar link: link.
	self assert: classVar hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleClassVarRead equals: #AClassVar.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleClassVarRead) isQuick
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterLiteral [
	| literalNode |
	literalNode := (ReflectivityExamples >> #exampleLiteral) ast statements first value.
	self assert: literalNode isLiteralNode.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	literalNode link: link.
	self assert: literalNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleLiteral) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleLiteral identicalTo: 2.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleLiteral) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleLiteral) isQuick
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterLiteralArray [
	| literalArray |
	literalArray := (ReflectivityExamples >> #exampleLiteralArray) ast statements first value.
	self assert: literalArray isLiteralArray.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	literalArray link: link.
	self assert: literalArray hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleLiteralArray) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleLiteralArray equals: #(1).
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleLiteralArray) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleLiteralArray) isQuick
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterMethod [
	| methodNode |
	methodNode := (ReflectivityExamples >> #exampleMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterMethod2 [
	| methodNode instance |
	methodNode := (ReflectivityExamples >> #exampleMethod2) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod2) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod2 equals: instance.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleMethod2) class equals: CompiledMethod
]

{ #category : #'tests - level' }
ReflectivityControlTest >> testAfterMethodLevel [
	| methodNode |
	"check that level is correct in #after on methodNode"
	methodNode := (ReflectivityExamples >> #exampleMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #recordLevel;
		control: #after;
		level: 0.
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag equals: 1.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterMethodPrimitive [
	| methodNode |
	ReflectivityExamples recompile: #examplePrimitiveMethod.
	methodNode := (ReflectivityExamples >> #examplePrimitiveMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	self assert: (ReflectivityExamples>>#examplePrimitiveMethod) isRealPrimitive.
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #examplePrimitiveMethod) class equals: CompiledMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new examplePrimitiveMethod class equals: ByteString.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #examplePrimitiveMethod) class equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterMethodWithTemps [
	| methodNode |
	ReflectivityExamples recompile: #exampleAssignment.
	methodNode := (ReflectivityExamples >> #exampleAssignment) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleAssignment) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleAssignment equals: 3.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleAssignment) class equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterSend [
	| sendNode |
	sendNode := (ReflectivityExamples >> #exampleMethod) sendNodes first.
	self assert: sendNode isMessage.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(#node).
	sendNode link: link.
	self assert: sendNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag class equals: RBMessageNode.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterSendWeak [
	| sendNode |
	sendNode := (ReflectivityExamples >> #exampleMethod) sendNodes first.
	self assert: sendNode isMessage.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		option: #(+ optionWeakAfter);
		arguments: #(node).
	sendNode link: link.
	self assert: sendNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag class equals: RBMessageNode.
	self deny: ((ReflectivityExamples >> #exampleMethod) messages includes: #ensure:).
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterSequence [
	| sequence |
	sequence := (ReflectivityExamples >> #exampleMethod) ast body.
	self assert: sequence isSequence.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	sequence link: link.
	self assert: sequence hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - after - variables' }
ReflectivityControlTest >> testAfterSlot [
	| iVar instance |
	iVar := ReflectivityExamples slotNamed: #ivar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(name).
	iVar link: link.
	self assert: iVar hasMetalink.
	self
		assert: (ReflectivityExamples >> #exampleIvarRead) class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: #ivar
]

{ #category : #'tests - after - variables' }
ReflectivityControlTest >> testAfterSlotWrite [
	| iVar instance |
	iVar := ReflectivityExamples slotNamed: #ivar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(name).
	iVar link: link.
	self assert: iVar hasMetalink.
	self
		assert: (ReflectivityExamples >> #exampleAssignmentIvar) class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignmentIvar equals: 3.
	self assert: tag equals: #ivar
]

{ #category : #'tests - after' }
ReflectivityControlTest >> testAfterVariableNode [
	| variableNode |
	variableNode := (ReflectivityExamples >> #exampleGlobalRead) ast statements first value.
	self assert: variableNode isVariable.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #after.
	variableNode link: link.
	self assert: variableNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleGlobalRead) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleGlobalRead equals: GlobalForTesting.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleGlobalRead) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleGlobalRead) isQuick
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeArray [
	| arrayNode |
	arrayNode := (ReflectivityExamples >> #exampleArray) ast statements first value.
	self assert: arrayNode isDynamicArray.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	arrayNode link: link.
	self assert: arrayNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleArray) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleArray isArray.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleArray) class equals: CompiledMethod
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeAssignment [
	| assignmentNode |
	assignmentNode := (ReflectivityExamples >> #exampleAssignment) assignmentNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	assignmentNode link: link.
	self assert: assignmentNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleAssignment) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleAssignment equals: 3.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleAssignment) class equals: CompiledMethod
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeBlock [
	| blockNode |
	blockNode := (ReflectivityExamples >> #exampleBlock) ast statements first value receiver.
	self assert: blockNode isBlock.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	blockNode link: link.
	self assert: blockNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleBlock identicalTo: 5.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: CompiledMethod
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeBlockSequence [
	| sequence |
	sequence := (ReflectivityExamples >> #exampleBlock) ast statements first value receiver body.
	self assert: sequence isSequence.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	sequence link: link.
	self assert: sequence hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleBlock identicalTo: 5.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: CompiledMethod
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeBlockSequenceNoValue [
	| sequence |
	sequence := (ReflectivityExamples >> #exampleBlockNoValue) ast statements first value body.
	self assert: sequence isSequence.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	sequence link: link.
	self assert: sequence hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleBlockNoValue) class equals: ReflectiveMethod.
	self assert: tag isNil.
	ReflectivityExamples new exampleBlockNoValue.
	self assert: tag isNil.
	ReflectivityExamples new exampleBlockNoValue value.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleBlockNoValue) class equals: CompiledMethod
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeBlockSequenceOptimized [
	| sequence |
	"we should be able to set a link on the sequence of an optimzied block with escaping vars"
	sequence := (ReflectivityExamples >> #exampleBlockOptimized) ast blockNodes first body.
	self assert: sequence isSequence.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	sequence link: link.
	self assert: sequence hasMetalinkBefore.
	self assert: tag isNil.
	ReflectivityExamples new exampleBlockOptimized.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleBlockNoValue) class equals: CompiledMethod
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeCascade [
	| cascadeNode |
	cascadeNode := (ReflectivityExamples >> #exampleCascade) ast statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	cascadeNode link: link.
	self assert: cascadeNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleCascade) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleCascade equals: 1.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleCascade) class equals: CompiledMethod
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeClassVariable [

	| classVar |
	classVar := ReflectivityExamples classVariableNamed: #ClassVar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	classVar link: link.
	self assert: classVar hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleClassVarRead equals: #AClassVar.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleClassVarRead) isQuick
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeLiteral [
	| literalNode |
	literalNode := (ReflectivityExamples >> #exampleLiteral) ast statements first value.
	self assert: literalNode isLiteralNode.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	literalNode link: link.
	self assert: literalNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleLiteral) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleLiteral identicalTo: 2.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleLiteral) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleLiteral) isQuick
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeLiteralArray [
	| literalArray |
	literalArray := (ReflectivityExamples >> #exampleLiteralArray) ast statements first value.
	self assert: literalArray isLiteralArray.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	literalArray link: link.
	self assert: literalArray hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleLiteralArray) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleLiteralArray equals: #(1).
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleLiteralArray) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleLiteralArray) isQuick
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeMethod [
	| methodNode |
	methodNode := (ReflectivityExamples >> #exampleMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeMethodPrimitive [
	| methodNode |
	methodNode := (ReflectivityExamples >> #examplePrimitiveMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	self assert: (ReflectivityExamples>>#examplePrimitiveMethod) isRealPrimitive.	
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #examplePrimitiveMethod) class equals: CompiledMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new examplePrimitiveMethod class equals: ByteString.
	self deny: (ReflectivityExamples>>#examplePrimitiveMethod) isRealPrimitive.	
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #examplePrimitiveMethod) class equals: CompiledMethod.
	link uninstall.
	self assert: (ReflectivityExamples >> #examplePrimitiveMethod) class equals: CompiledMethod.
	self assert: (ReflectivityExamples>>#examplePrimitiveMethod) isRealPrimitive
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeReturn [
	| returnNode |
	returnNode := (ReflectivityExamples >> #exampleLiteral) ast statements first.
	self assert: returnNode isReturn.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	returnNode link: link.
	self assert: returnNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleLiteral) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleLiteral identicalTo: 2.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleLiteral) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleLiteral) isQuick
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeSend [
	| sendNode |
	sendNode := (ReflectivityExamples >> #exampleMethod) sendNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(#node).
	sendNode link: link.
	self assert: sendNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag class equals: RBMessageNode.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeSendInCascade [
	| sendNode |
	sendNode := (ReflectivityExamples >> #exampleCascade) ast statements first value messages first.
	self assert: sendNode isMessage.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	sendNode link: link.
	self assert: sendNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleCascade) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleCascade equals: 1.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleCascade) class equals: CompiledMethod
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeSequence [
	| seqNode |
	seqNode := (ReflectivityExamples >> #exampleAssignment) ast body.
	self assert: seqNode isSequence.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	seqNode link: link.
	self assert: seqNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleAssignment) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleAssignment equals: 3.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleAssignment) class equals: CompiledMethod
]

{ #category : #'tests - after - variables' }
ReflectivityControlTest >> testBeforeSlot [
	| iVar instance |
	iVar := ReflectivityExamples slotNamed: #ivar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #before;
		arguments: #(name).
	iVar link: link.
	self assert: iVar hasMetalink.
	self
		assert: (ReflectivityExamples >> #exampleIvarRead) class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: #ivar
]

{ #category : #'tests - after - variables' }
ReflectivityControlTest >> testBeforeSlotWrite [
	| iVar instance |
	iVar := ReflectivityExamples slotNamed: #ivar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #before;
		arguments: #(name).
	iVar link: link.
	self assert: iVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleAssignmentIvar) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignmentIvar equals: 3.
	self assert: tag equals: #ivar
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeVariable [
	| variableNode |
	variableNode := (ReflectivityExamples >> #exampleGlobalRead) ast statements first value.
	self assert: variableNode isVariable.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	variableNode link: link.
	self assert: variableNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleGlobalRead) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleGlobalRead equals: GlobalForTesting.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleGlobalRead) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleGlobalRead) isQuick
]

{ #category : #'tests - before' }
ReflectivityControlTest >> testBeforeVariableSelf [
	| variableNode |
	variableNode := (ReflectivityExamples >> #exampleSelf) ast statements
		first.
	self assert: variableNode isVariable.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	variableNode link: link.
	self assert: variableNode hasMetalinkBefore.
	self
		assert: (ReflectivityExamples >> #exampleSelf) class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	self
		assert: ReflectivityExamples new exampleSelf class
		equals: ReflectivityExamples.
	self assert: tag equals: 'yes'.
	self
		assert: (ReflectivityExamples >> #exampleSelf) class
		equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleSelf) isQuick
]

{ #category : #'tests - conditions' }
ReflectivityControlTest >> testConditionDisableEnableNoArguments [
"check that a link is not executed, if the condition is disabled (link>>#disable)."
"and  that it is executed again if the condition is enabled again (link>>#enable"
	| sendNode |
	sendNode := (ReflectivityExamples >> #exampleMethod) sendNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		condition: [ true ];
		arguments: #(#node).
	sendNode link: link.
	self assert: sendNode hasMetalinkBefore.
	self assert: tag isNil.
	ReflectivityExamples new exampleMethod.
	self assert: tag class equals: RBMessageNode.
	tag := nil.
	link disable.
	ReflectivityExamples new exampleMethod.
	self assert: tag isNil.
	link enable.
	ReflectivityExamples new exampleMethod.
	self assert: tag class equals: RBMessageNode

]

{ #category : #'tests - conditions' }
ReflectivityControlTest >> testConditionDisableEnableWithArguments [
"check that a link is not executed, if the condition is disabled (link>>#disable)."
"and  that it is executed again if the condition is enabled again (link>>#enable"
	| sendNode |
	sendNode := (ReflectivityExamples >> #exampleMethod) sendNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		condition: [ :arg | arg == sendNode ] arguments:#(#node);
		arguments: #(#node).
	sendNode link: link.
	self assert: sendNode hasMetalinkBefore.
	self assert: tag isNil.
	ReflectivityExamples new exampleMethod.
	self assert: tag class equals: RBMessageNode.
	tag := nil.
	link disable.
	ReflectivityExamples new exampleMethod.
	self assert: tag isNil.
	link enable.
	ReflectivityExamples new exampleMethod.
	self assert: tag class equals: RBMessageNode
]

{ #category : #'tests - level' }
ReflectivityControlTest >> testConditionMetaLevel [
	"check that the condition is evaluated on the same meta level as the link"

	| sendNode |
	sendNode := (ReflectivityExamples >> #exampleMethod) sendNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		condition: [ self assert: Processor activeProcess level identicalTo: 1.
			true ];
		level: 0;
		arguments: #(#node).
	sendNode link: link.
	self assert: sendNode hasMetalinkBefore.
	self assert: tag isNil.
	ReflectivityExamples new exampleMethod.
	self assert: tag class equals: RBMessageNode
]

{ #category : #'tests - conditions' }
ReflectivityControlTest >> testConditionWithArgument [
	| sendNode |
	sendNode := (ReflectivityExamples >> #exampleMethod) sendNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		condition: [ :node | node == sendNode ] arguments: #(#node);
		arguments: #(#node).
	sendNode link: link.
	self assert: sendNode hasMetalinkBefore.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag class equals: RBMessageNode.
	link condition: [ :node | node == 5 ].
	tag := nil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag isNil
]

{ #category : #'tests - conditions' }
ReflectivityControlTest >> testConditionWithArgument2 [
	| sendNode |
	sendNode := (ReflectivityExamples >> #exampleMethod) sendNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		condition: [ :arg | arg == sendNode ] arguments: #(node);
		arguments: #(#node).
	sendNode link: link.
	self assert: sendNode hasMetalinkBefore.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag class equals: RBMessageNode.
	link condition: [ :node | node == 5 ].
	tag := nil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag isNil
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testFailingDoubleRWInstead [

	|readLink readMO writeLink writeMO readSites writeSites|

	readSites := (ReflectivityExamples>>#exampleLazyInit) 
		variableReadNodes select: [ :node | node name = 'singleton' ].
		
	writeSites :=  (ReflectivityExamples>>#exampleLazyInit) 
		variableWriteNodes select: [ :node | node name = 'singleton' ].
	
	"default MO for rw -- bug manifests on install"
	readMO := [ :object | object class classVarNamed: 'singleton' ].
	writeMO := [ :object :newValue | object class classVarNamed: 'singleton' put: newValue ].
		
	readLink := MetaLink new 
		metaObject: readMO; 
		selector: #value:;
		control: #instead;
		options: #(+ optionCompileOnLinkInstallation);
		arguments: #(object).
		
	writeLink := MetaLink new 
		metaObject: writeMO; 
		selector: #value:value:;
		control: #instead;
		options: #(+ optionCompileOnLinkInstallation);
		arguments: #(newValue object).
	
	readSites do: [ :readNode | readNode link: readLink ].
	writeSites do: [ :writeNode | writeNode link: writeLink ].
	readLink uninstall.
	writeLink uninstall
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testFailingDoubleRWInsteadSimplified [

	|readLink readMO readNode|

	readNode := ((ReflectivityExamples>>#exampleLazyInit) 
		variableReadNodes select: [ :node | node name = 'singleton' ]) first.

	"default MO for rw -- bug manifests on install"
	readMO := [ :object | object class classVarNamed: 'singleton' ].
		
	readLink := MetaLink new 
		metaObject: readMO; 
		selector: #value:;
		control: #instead;
		options: #(+ optionCompileOnLinkInstallation);
		arguments: #(object).
			
	readNode link: readLink.
	readLink uninstall

]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadArray [
	| arrayNode |
	arrayNode := (ReflectivityExamples >> #exampleArray) ast statements first value.
	self assert: arrayNode isDynamicArray.
	link := MetaLink new
		metaObject: self;
		control: #instead;
		selector: #return3.
	arrayNode link: link.
	self assert: arrayNode hasMetalinkInstead.
	self assert: (ReflectivityExamples >> #exampleArray) class equals: ReflectiveMethod.
	self assert: ReflectivityExamples new exampleArray equals: 3.
	self assert: (ReflectivityExamples >> #exampleArray) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleArray) isQuick
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadAssign [
	| assignmentNode instance |
	assignmentNode := (ReflectivityExamples >> #exampleAssignment) assignmentNodes first.
	self assert: assignmentNode isAssignment.
	link := MetaLink new
		metaObject: #context;
		selector: #tempNamed:put:;
		control: #instead;
		arguments: #(#name #newValue).
	assignmentNode link: link.
	self assert: assignmentNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleAssignment) class equals: ReflectiveMethod.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadBlock [
	| blockNode |
	blockNode := (ReflectivityExamples >> #exampleBlock) ast statements first value receiver.
	self assert: blockNode isBlock.
	link := MetaLink new
		metaObject: self;
		control: #instead;
		selector: #return3.
	self assert: ReflectivityExamples new exampleBlock identicalTo: 5.
	blockNode link: link.
	self assert: blockNode hasMetalinkInstead.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: ReflectiveMethod.
	self assert: ReflectivityExamples new exampleBlock identicalTo: 3.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: CompiledMethod
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadBlockSequence [
	| sequence |
	sequence := (ReflectivityExamples >> #exampleBlock) ast statements first value receiver body.
	self assert: sequence isSequence.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #instead.
	sequence link: link.
	self assert: sequence hasMetalinkInstead.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: ReflectiveMethod.
	self assert: tag isNil.
 	ReflectivityExamples new exampleBlock.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: CompiledMethod
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadCascade [
	| cascadeNode |
	cascadeNode := (ReflectivityExamples >> #exampleCascade) ast statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #instead.
	cascadeNode link: link.
	self assert: cascadeNode hasMetalinkInstead.
	self assert: (ReflectivityExamples >> #exampleCascade) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleCascade equals: self.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleCascade) class equals: CompiledMethod
]

{ #category : #'tests - after - variables' }
ReflectivityControlTest >> testInsteadClassVariable [
	| classVar |
	self skip.
	classVar := ReflectivityExamples classVariableNamed: #ClassVar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #instead.
	classVar link: link.
	self assert: classVar hasMetalinkInstead.
	self assert: tag isNil.
	self
		assert: (ReflectivityExamples >> #exampleClassVarRead) class
		equals: ReflectiveMethod.
	self
		assert: ReflectivityExamples new exampleClassVarRead class equals: self class.
	self assert: tag equals: 'yes'.
	self
		assert: (ReflectivityExamples >> #exampleClassVarRead) class
		equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleClassVarRead) isQuick
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadLiteral [
	| literalNode |
	literalNode := (ReflectivityExamples >> #exampleLiteral) ast statements first value.
	self assert: literalNode isLiteralNode.
	link := MetaLink new
		metaObject: self;
		control: #instead;
		selector: #return3.
	literalNode link: link.
	self assert: literalNode hasMetalinkInstead.
	self assert: (ReflectivityExamples >> #exampleLiteral) class equals: ReflectiveMethod.
	self assert: ReflectivityExamples new exampleLiteral identicalTo: 3.
	self assert: (ReflectivityExamples >> #exampleLiteral) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleLiteral) isQuick
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadLiteralArray [
	| literalArray |
	literalArray := (ReflectivityExamples >> #exampleLiteralArray) ast statements first value.
	self assert: literalArray isLiteralArray.
	link := MetaLink new
		metaObject: self;
		control: #instead;
		selector: #return3.
	literalArray link: link.
	self assert: literalArray hasMetalinkInstead.
	self assert: (ReflectivityExamples >> #exampleLiteralArray) class equals: ReflectiveMethod.
	self assert: ReflectivityExamples new exampleLiteralArray equals: 3.
	self assert: (ReflectivityExamples >> #exampleLiteralArray) class equals: CompiledMethod.
	self deny: (ReflectivityExamples >> #exampleLiteralArray) isQuick
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadMethod [
	| node |
	node := (ReflectivityExamples >> #exampleMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #instead.
	node link: link.
	self assert: node hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	ReflectivityExamples new exampleMethod.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadPrimitiveMethod [
	| node |
	ReflectivityExamples recompile: #examplePrimitiveMethod.
	node := (ReflectivityExamples >> #examplePrimitiveMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		control: #instead.
	node link: link.
	self assert: node hasMetalink.
	self assert: (ReflectivityExamples >> #examplePrimitiveMethod) class equals: CompiledMethod.
	self assert: tag isNil.
	ReflectivityExamples new examplePrimitiveMethod.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #examplePrimitiveMethod) class equals: CompiledMethod
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadSend [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) sendNodes first.
	link := MetaLink new
		metaObject: #receiver;
		selector: #perform:withArguments:;
		control: #instead;
		arguments: #(#selector #arguments).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadSendMultipleSites [
	| sendNodes instance |
	sendNodes := (ReflectivityExamples >> #exampleMethodMultipleSites) sendNodes.
	link := MetaLink new
		metaObject: [ :receiver :selector :arguments | receiver perform: selector withArguments: arguments ];
		selector: #value:value:value:;
		control: #instead;
		arguments: #(#receiver #selector #arguments).
	sendNodes do: [ :sn | sn link: link ].
	self assert: sendNodes anyOne hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethodMultipleSites) class equals: ReflectiveMethod.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethodMultipleSites equals: 5
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadSequence [
	| seqNode |
	seqNode := (ReflectivityExamples >> #exampleAssignment) ast body.
	self assert: seqNode isSequence.
	link := MetaLink new
		metaObject: self;
		control: #instead;
		selector: #tagExec.
	self assert: (seqNode isKindOf: RBSequenceNode).
	seqNode link: link.
	self assert: seqNode hasMetalinkInstead.
	self assert: (ReflectivityExamples >> #exampleAssignment) class equals: ReflectiveMethod.
	self assert: tag isNil.
	ReflectivityExamples new exampleAssignment.
	self assert: tag equals: 'yes'.
	self assert: (ReflectivityExamples >> #exampleAssignment) class equals: CompiledMethod.
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadVariableReadGlobal [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleGlobalRead) variableReadNodes first.
	link := MetaLink new
		metaObject: #class;
		selector: #bindingOf:;
		control: #instead;
		arguments: #(#name).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleGlobalRead) class equals: ReflectiveMethod.
	instance := ReflectivityExamples new.
	self assert: instance exampleGlobalRead value equals: GlobalForTesting
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadVariableReadIvar [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleIvarRead) variableReadNodes first.
	link := MetaLink new
		metaObject: #object;
		selector: #instVarNamed:;
		control: #instead;
		arguments: #(#name).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleIvarRead) class equals: ReflectiveMethod.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead value equals: 33.
	self deny: (ReflectivityExamples >> #exampleIvarRead) isQuick	"yes, we changed the method"
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadVariableReadTemp [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleAssignment) variableReadNodes first.
	link := MetaLink new
		metaObject: #context;
		selector: #tempNamed:;
		control: #instead;
		arguments: #(#name).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleAssignment) class equals: ReflectiveMethod.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment value equals: 3
]

{ #category : #'tests - instead' }
ReflectivityControlTest >> testInsteadVariableWrite [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleAssignment) variableWriteNodes first.
	link := MetaLink new
		metaObject: #context;
		selector: #tempNamed:put:;
		control: #instead;
		arguments: #(#name #newValue).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleAssignment) class equals: ReflectiveMethod.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3
]

{ #category : #'tests - options' }
ReflectivityControlTest >> testLinkOneShot [
	| sendNode |
	sendNode := (ReflectivityExamples>>#exampleMethod) sendNodes first.
	link := MetaLink new 
		metaObject: self; 
		options: #(+ optionOneShot);
		selector: #tagExec.
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag equals: #yes.
	self deny: sendNode hasMetalink.	
	tag := nil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag isNil

]

{ #category : #'tests - options' }
ReflectivityControlTest >> testLinkOptionDisabledLink [
	| sendNode |
	sendNode := (ReflectivityExamples>>#exampleMethod) sendNodes first.
	link := MetaLink new 
		metaObject: self; 
		options: #(+ optionDisabledLink);
		selector: #tagExec.
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples>>#exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag isNil.
	self assert: (ReflectivityExamples>>#exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - options' }
ReflectivityControlTest >> testLinkoptionInlineCondition [
	| sendNode |
	sendNode := (ReflectivityExamples>>#exampleMethod) sendNodes first.
	link := MetaLink new 
		metaObject: self; 
		options: #(- optionInlineCondition);
		condition: [ true ];
		selector: #tagExec.
	sendNode link: link.
	self assert: sendNode hasMetalink.
		self assert: (ReflectivityExamples>>#exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag equals: #yes.
	"if we now change the meta object, the method should not be invalidated"
	link condition: [true].
	self assert: (ReflectivityExamples>>#exampleMethod) class equals: CompiledMethod.
	tag := nil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self deny: tag isNil.
	link condition: [true].
	self assert: (ReflectivityExamples>>#exampleMethod) class equals: CompiledMethod.
	tag := nil.
	link condition: [false].
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag isNil
]

{ #category : #'tests - options' }
ReflectivityControlTest >> testLinkoptionInlineMetaObject [
	| sendNode |
	sendNode := (ReflectivityExamples>>#exampleMethod) sendNodes first.
	link := MetaLink new 
		metaObject: self; 
		options: #(- optionInlineMetaObject);
		selector: #tagExec.
	sendNode link: link.
	self assert: sendNode hasMetalink.
		self assert: (ReflectivityExamples>>#exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag equals: #yes.
	"if we now change the meta object, the method should not be invalidated"
	link metaObject: self class new.
	self assert: (ReflectivityExamples>>#exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - level' }
ReflectivityControlTest >> testRecursionStopper [
	"check that we can break a loop"
	| methodNode |
	methodNode := (self class >> #tagExec) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec;
		level: 0.
	methodNode link: link.
	self assert: methodNode hasMetalinkBefore.
	self assert: tag isNil.
	self tagExec.
	self assert: tag equals: #yes
]
