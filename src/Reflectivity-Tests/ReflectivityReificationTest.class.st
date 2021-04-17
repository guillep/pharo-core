Class {
	#name : #ReflectivityReificationTest,
	#superclass : #TestCase,
	#instVars : [
		'tag',
		'link'
	],
	#category : #'Reflectivity-Tests-Base'
}

{ #category : #tagging }
ReflectivityReificationTest >> tagExec [
	tag := #yes
]

{ #category : #tagging }
ReflectivityReificationTest >> tagExec: aTag [
	tag := aTag.
]

{ #category : #running }
ReflectivityReificationTest >> tearDown [
	link ifNotNil: [ link uninstall ].
	super tearDown 
]

{ #category : #'tests - variablenodes' }
ReflectivityReificationTest >> testAccessTemp [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleAssignment) ast body statements second.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: {(RBVariableNode named: #temp)}.
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: tag equals: 3
]

{ #category : #'tests - blocks' }
ReflectivityReificationTest >> testBlockOperationAfter [
	| blockNode instance |
	blockNode := (ReflectivityExamples >> #exampleBlock) ast statements first value receiver.
	self assert: blockNode isBlock.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(operation).
	blockNode link: link.
	self assert: blockNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleBlock identicalTo: 5.
	self assert: tag value value equals: 5.
	self assert: tag class equals: RFBlockOperation.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: CompiledMethod
]

{ #category : #'tests - blocks' }
ReflectivityReificationTest >> testBlockOperationBefore [
	| blockNode |
	blockNode := (ReflectivityExamples >> #exampleBlock) ast statements first value receiver.
	self assert: blockNode isBlock.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #before;
		arguments: #(operation).
	blockNode link: link.
	self assert: blockNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleBlock identicalTo: 5.
	self assert: tag class equals: RFBlockOperation.
	self assert: tag value value equals: 5.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: CompiledMethod
]

{ #category : #'tests - blocks' }
ReflectivityReificationTest >> testBlockOperationInstead [
	| blockNode instance |
	blockNode := (ReflectivityExamples >> #exampleBlock) ast statements first value receiver.
	self assert: blockNode isBlock.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #instead;
		arguments: #(operation).
	blockNode link: link.
	self assert: blockNode hasMetalinkInstead.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleBlock identicalTo: self.
	self assert: tag value value equals: 5.
	self assert: tag class equals: RFBlockOperation.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: CompiledMethod
]

{ #category : #'tests - blocks - body' }
ReflectivityReificationTest >> testBlockSequenceArguments [
	| blockNode |
	blockNode := (ReflectivityExamples >> #exampleBlock) ast statements first value receiver body.
	self assert: blockNode isSequence.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #before;
		arguments: #(arguments).
	blockNode link: link.
	self assert: blockNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleBlock identicalTo: 5.
	self assert: tag equals: #().
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: CompiledMethod
]

{ #category : #'tests - blocks - body' }
ReflectivityReificationTest >> testBlockSequenceArgumentsWithArg [
	| blockNode |
	blockNode := (ReflectivityExamples >> #exampleBlockWithArg) ast statements first value receiver body.
	self assert: blockNode isSequence.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #before;
		arguments: #(arguments).
	blockNode link: link.
	self assert: blockNode hasMetalinkBefore.
	self assert: (ReflectivityExamples >> #exampleBlockWithArg) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleBlockWithArg identicalTo: 5.
	self assert: tag equals: #(2).
	self assert: (ReflectivityExamples >> #exampleBlockWithArg) class equals: CompiledMethod
]

{ #category : #'tests - blocks - body' }
ReflectivityReificationTest >> testBlockSequenceArgumentsWithArgAfter [
	| blockNode |
	blockNode := (ReflectivityExamples >> #exampleBlockWithArg) ast statements first value receiver body.
	self assert: blockNode isSequence.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(arguments).
	blockNode link: link.
	self assert: blockNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleBlockWithArg) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleBlockWithArg identicalTo: 5.
	self assert: tag equals: #(2).
	self assert: (ReflectivityExamples >> #exampleBlockWithArg) class equals: CompiledMethod
]

{ #category : #'tests - blocks - body' }
ReflectivityReificationTest >> testBlockSequenceArgumentsWithArgAfterInstead [
	| blockNode |
	blockNode := (ReflectivityExamples >> #exampleBlockWithArg) ast statements first value receiver body.
	self assert: blockNode isSequence.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #instead;
		arguments: #(arguments).
	blockNode link: link.
	self assert: blockNode hasMetalinkInstead.
	self assert: (ReflectivityExamples >> #exampleBlockWithArg) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleBlockWithArg identicalTo: self.
	self assert: tag equals: #(2).
	self assert: (ReflectivityExamples >> #exampleBlockWithArg) class equals: CompiledMethod
]

{ #category : #'tests - blocks' }
ReflectivityReificationTest >> testBlockValueAfter [
	| blockNode |
	blockNode := (ReflectivityExamples >> #exampleBlock) ast statements first value receiver.
	self assert: blockNode isBlock.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(value).
	blockNode link: link.
	self assert: blockNode hasMetalinkAfter.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleBlock identicalTo: 5.
	self assert: tag printString equals: [ 2 + 3 ] printString.
	self assert: (ReflectivityExamples >> #exampleBlock) class equals: CompiledMethod
]

{ #category : #'tests - misc' }
ReflectivityReificationTest >> testLiteralOperationAfter [
	| literalNode |
	literalNode := (ReflectivityExamples >> #exampleLiteral) ast statements first value.
	self assert: literalNode isLiteralNode.
	link := MetaLink new
		metaObject: [ :value | self assert: value value equals: 2 ];
		selector: #value:;
		arguments: #(operation);
		control: #after.
	literalNode link: link.
	self assert: literalNode hasMetalinkAfter.
	self assert: ReflectivityExamples new exampleLiteral identicalTo: 2
]

{ #category : #'tests - misc' }
ReflectivityReificationTest >> testLiteralValueAfter [
	| literalNode |
	literalNode := (ReflectivityExamples >> #exampleLiteral) ast statements first value.
	self assert: literalNode isLiteralNode.
	link := MetaLink new
		metaObject: [ :value | self assert: value equals: 2 ];
		selector: #value:;
		arguments: #(value);
		control: #after.
	literalNode link: link.
	self assert: literalNode hasMetalinkAfter.
	self assert: ReflectivityExamples new exampleLiteral identicalTo: 2
]

{ #category : #'tests - misc' }
ReflectivityReificationTest >> testLiteralValueBefore [
	| literalNode |
	literalNode := (ReflectivityExamples >> #exampleLiteral) ast statements first value.
	self assert: literalNode isLiteralNode.
	link := MetaLink new
		metaObject: [ :value | self assert: value equals: 2 ];
		selector: #value:;
		arguments: #(value);
		control: #before.
	literalNode link: link.
	self assert: literalNode hasMetalinkBefore.
	self assert: ReflectivityExamples new exampleLiteral identicalTo: 2
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifyArguments2level [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleSendTwoArgs) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(arguments);
		level: 0.
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleSendTwoArgs) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self deny: (Processor activeProcess isMeta).
	self assert: instance exampleSendTwoArgs equals: #(1 2).
	self deny: (Processor activeProcess isMeta).
	self assert: tag equals: #(1 2)
]

{ #category : #'tests - misc' }
ReflectivityReificationTest >> testReifyArrayOperationAfter [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleArray) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(operation).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleArray) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleArray equals: #(3).
	self assert: tag value equals: #(3)
]

{ #category : #'tests - misc' }
ReflectivityReificationTest >> testReifyArrayOperationBefore [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleArray) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #before;
		arguments: #(operation).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleArray) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleArray equals: #(3).
	self assert: tag class equals: Array.
	self assert: tag value equals: #(3)
]

{ #category : #'tests - misc' }
ReflectivityReificationTest >> testReifyArrayOperationInstead [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleArray) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #instead;
		arguments: #(operation).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self
		assert: (ReflectivityExamples >> #exampleArray) class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleArray equals: self.
	self assert: tag value equals: #(3)
]

{ #category : #'tests - misc' }
ReflectivityReificationTest >> testReifyArrayValue [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleArray) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(value).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleArray) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleArray equals: #(3).
	self assert: tag equals: #(3)
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyAssignmentClassVarOperationAfter [
	| varNode instance reachHere |
	varNode := (ReflectivityExamples >> #exampleAssignmentClassVar) assignmentNodes first.
	reachHere := false.
	link := MetaLink new
		metaObject: [:operation | reachHere := true. self assert: operation value equals: 3];
		selector: #value:;
		control: #after;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignmentClassVar equals: 3.
	self assert: reachHere.
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyAssignmentClassVarOperationBefore [
	| varNode instance reachHere |
	varNode := (ReflectivityExamples >> #exampleAssignmentClassVar) assignmentNodes first.
	reachHere := false.
	link := MetaLink new
		metaObject: [:operation | reachHere := true. self assert: operation value equals: 3];
		selector: #value:;
		control: #before;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignmentClassVar equals: 3.
	self assert: reachHere.
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyAssignmentClassVarOperationInstead [
	| varNode instance reachHere |
	varNode := (ReflectivityExamples >> #exampleAssignmentClassVar) assignmentNodes first.
	reachHere := false.
	link := MetaLink new
		metaObject: [:operation | reachHere := true. operation value];
		selector: #value:;
		control: #instead;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignmentClassVar equals: 3.
	self assert: reachHere.
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyAssignmentSlotOperationAfter [
	| varNode instance reachHere |
	varNode := (ReflectivityExamples >> #exampleAssignmentIvar) assignmentNodes first.
	reachHere := false.
	link := MetaLink new
		metaObject: [:operation | reachHere := true. self assert: operation value equals: 3];
		selector: #value:;
		control: #after;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignmentIvar equals: 3.
	self assert: reachHere.
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyAssignmentSlotOperationBefore [
	| varNode instance reachHere |
	varNode := (ReflectivityExamples >> #exampleAssignmentIvar) assignmentNodes first.
	reachHere := false.
	link := MetaLink new
		metaObject: [:operation | reachHere := true. self assert: operation value equals: 3];
		selector: #value:;
		control: #before;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignmentIvar equals: 3.
	self assert: reachHere.
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyAssignmentSlotOperationInstead [
	| varNode instance reachHere |
	varNode := (ReflectivityExamples >> #exampleAssignmentIvar) assignmentNodes first.
	reachHere := false.
	link := MetaLink new
		metaObject: [:operation | reachHere := true. operation value];
		selector: #value:;
		control: #instead;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignmentIvar equals: 3.
	self assert: reachHere.
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyAssignmentTempOperationAfter [
	| varNode instance reachHere |
	varNode := (ReflectivityExamples >> #exampleAssignment) assignmentNodes first.
	reachHere := false.
	link := MetaLink new
		metaObject: [:operation | reachHere := true. operation value];
		selector: #value:;
		control: #after;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: reachHere.
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyAssignmentTempOperationBefore [
	| varNode instance reachHere |
	varNode := (ReflectivityExamples >> #exampleAssignment) assignmentNodes first.
	reachHere := false.
	link := MetaLink new
		metaObject: [:operation | reachHere := true. self assert: operation value equals: 3];
		selector: #value:;
		control: #before;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: reachHere.

]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyAssignmentTempOperationInstead [
	| varNode instance reachHere |
	varNode := (ReflectivityExamples >> #exampleAssignment) assignmentNodes first.
	reachHere := false.
	link := MetaLink new
		metaObject: [:operation | 	reachHere := true . operation value];
		selector: #value:;
		control: #instead;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: reachHere.
]

{ #category : #'tests - allnodes' }
ReflectivityReificationTest >> testReifyByInstanceNotKey [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: {RFNodeReification new}.
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: varNode
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifyCascadeValue [
	| cascadeNode instance |
	cascadeNode := (ReflectivityExamples >> #exampleCascade) ast statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(value).
	cascadeNode link: link.
	self assert: cascadeNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleCascade) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleCascade equals: 1.
	self assert: tag equals: 1
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyClassVarOperation [
	| node instance |
	node := (ReflectivityExamples >> #exampleClassVarRead) ast variableNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(operation).
	node link: link.
	self assert: node hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleClassVarRead equals: #AClassVar.
	self assert: tag value equals: #AClassVar
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifyClassVariableClass [
	| classVar instance |
	classVar := ReflectivityExamples classVariableNamed: #ClassVar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(class).
	classVar link: link.
	self assert: classVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleClassVarRead equals: #AClassVar.
	self assert: tag identicalTo: ReflectivityExamples
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifyClassVariableContext [
	| classVar instance |
	classVar := ReflectivityExamples classVariableNamed: #ClassVar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(context).
	classVar link: link.
	self assert: classVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleClassVarRead equals: #AClassVar.
	self assert: tag class identicalTo: Context
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifyClassVariableEntity [
	| classVar instance |
	classVar := ReflectivityExamples classVariableNamed: #ClassVar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(entity).
	classVar link: link.
	self assert: classVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleClassVarRead identicalTo: #AClassVar.
	self assert: tag equals: classVar
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifyClassVariableLink [
	| classVar instance |
	classVar := ReflectivityExamples classVariableNamed: #ClassVar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(link).
	classVar link: link.
	self assert: classVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleClassVarRead equals: #AClassVar.
	self assert: tag identicalTo: link
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifyClassVariableName [
	| classVar instance |
	classVar := ReflectivityExamples classVariableNamed: #ClassVar.
	link := MetaLink new 
		metaObject: self; 
		selector: #tagExec:;
		arguments: #(name).
	classVar link: link.
	self assert: classVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: ReflectiveMethod.
	self assert: (tag isNil).
	instance := ReflectivityExamples new.
	self assert: instance exampleClassVarRead equals: #AClassVar.
	self assert: tag equals: #ClassVar.
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifyClassVariableObject [
	| classVar instance |
	classVar := ReflectivityExamples classVariableNamed: #ClassVar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(object).
	classVar link: link.
	self assert: classVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleClassVarRead equals: #AClassVar.
	self assert: tag class identicalTo: ReflectivityExamples
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifyClassVariableValue [
	| classVar instance |
	classVar := ReflectivityExamples classVariableNamed: #ClassVar.
	link := MetaLink new 
		metaObject: self; 
		selector: #tagExec:;
		arguments: #(value).
	classVar link: link.
	self assert: classVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: ReflectiveMethod.
	self assert: (tag isNil).
	instance := ReflectivityExamples new.
	self assert: instance exampleClassVarRead equals: #AClassVar.
	self assert: tag equals: #AClassVar.
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifyClassVariableVariable [
	| classVar instance |
	classVar := ReflectivityExamples classVariableNamed: #ClassVar.
	link := MetaLink new 
		metaObject: self; 
		selector: #tagExec:;
		arguments: #(variable).
	classVar link: link.
	self assert: classVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleClassVarRead) class equals: ReflectiveMethod.
	self assert: (tag isNil).
	instance := ReflectivityExamples new.
	self assert: instance exampleClassVarRead equals: #AClassVar.
	self assert: tag equals: classVar.
]

{ #category : #'tests - allnodes' }
ReflectivityReificationTest >> testReifyEntity [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(entity).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: varNode
]

{ #category : #'tests - variablenodes' }
ReflectivityReificationTest >> testReifyGlobalName [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleGlobalRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(name).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleGlobalRead equals: GlobalForTesting.
	self assert: tag equals: #GlobalForTesting
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyGlobalOperation [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleGlobalRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleGlobalRead equals: GlobalForTesting.
	self assert: tag class identicalTo: RFGlobalRead.
	self assert: tag value equals: GlobalForTesting
]

{ #category : #'tests - variablenodes' }
ReflectivityReificationTest >> testReifyGlobalValue [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleGlobalRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(value).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleGlobalRead equals: GlobalForTesting.
	self assert: tag equals: GlobalForTesting
]

{ #category : #'tests - variablenodes' }
ReflectivityReificationTest >> testReifyGlobalVariable [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleGlobalRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(variable).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleGlobalRead equals: GlobalForTesting.
	self assert: tag class identicalTo: GlobalVariable
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifyGlobalVariableValue [
	| globalVar instance |
	globalVar := GlobalForTesting binding.
	link := MetaLink new 
		metaObject: self; 
		selector: #tagExec:;
		arguments: #(name).
	globalVar link: link.
	self assert: globalVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleGlobalRead) class equals: ReflectiveMethod.
	self assert: (tag isNil).
	instance := ReflectivityExamples new.
	self assert: instance exampleGlobalRead equals: GlobalForTesting.
	self assert: tag equals: #GlobalForTesting.
]

{ #category : #'tests - assignment' }
ReflectivityReificationTest >> testReifyIndexAssigmentIvar [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleAssignmentIvar)
		assignmentNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(index).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignmentIvar equals: 3.
	self assert: tag equals: 1
]

{ #category : #'tests - variablenodes' }
ReflectivityReificationTest >> testReifyIvarIndex [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(index).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: 1
]

{ #category : #'tests - variablenodes' }
ReflectivityReificationTest >> testReifyIvarName [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(name).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: 'ivar'
]

{ #category : #'tests - variablenodes' }
ReflectivityReificationTest >> testReifyIvarValue [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(value).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: 33
]

{ #category : #'tests - variablenodes' }
ReflectivityReificationTest >> testReifyIvarVariable [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(variable).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: (tag isKindOf: Slot)
]

{ #category : #'tests - misc' }
ReflectivityReificationTest >> testReifyLiteralArrayContext [
	| literalArrayNode instance |
	literalArrayNode := (ReflectivityExamples >> #exampleLiteralArray) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #before;
		arguments: #(context).
	literalArrayNode link: link.
	self assert: literalArrayNode hasMetalink.
	self
		assert: (ReflectivityExamples >> #exampleLiteralArray) class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleLiteralArray equals: #(1).
	self assert: tag class identicalTo: Context.
]

{ #category : #'tests - misc' }
ReflectivityReificationTest >> testReifyLiteralArrayOperation [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleLiteralArray) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(operation).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self
		assert: (ReflectivityExamples >> #exampleLiteralArray) class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleLiteralArray equals: #(1).
	self assert: tag value equals: #(1)
]

{ #category : #'tests - misc' }
ReflectivityReificationTest >> testReifyLiteralArrayValue [
	| literalArrayNode instance |
	literalArrayNode := (ReflectivityExamples >> #exampleLiteralArray) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(value).
	literalArrayNode link: link.
	self assert: literalArrayNode hasMetalink.
	self
		assert: (ReflectivityExamples >> #exampleLiteralArray) class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleLiteralArray equals: #(1).
	self assert: tag equals: #(1)
]

{ #category : #'tests - allnodes' }
ReflectivityReificationTest >> testReifyMethod [
	| varNode instance origMethod |
	origMethod := ReflectivityExamples >> #exampleIvarRead.
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(method).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: ReflectivityExamples >> #exampleIvarRead.
	self deny: tag identicalTo: origMethod
]

{ #category : #'tests - method ' }
ReflectivityReificationTest >> testReifyMethodArgs [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleWithArg:) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(arguments).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleWithArg:) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: (instance exampleWithArg: 3) equals: 5.
	self assert: tag equals: #(3)
]

{ #category : #'tests - method ' }
ReflectivityReificationTest >> testReifyMethodArgsAfter [
	| methodNode instance |
	methodNode := (ReflectivityExamples >> #exampleWithArg:) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(arguments).
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleWithArg:) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: (instance exampleWithArg: 3) equals: 5.
	self assert: tag equals: #(3)
]

{ #category : #'tests - method ' }
ReflectivityReificationTest >> testReifyMethodArgsAfter2 [
	| methodNode |
	methodNode := (ReflectivityExamples >> #exampleMethod) ast.
	link := MetaLink new
		metaObject: [ :aReceiver :aSelector :args :mylink | 
			tag := #yes.
			self assert: aReceiver class equals: ReflectivityExamples.
			self assert: aSelector equals: #exampleMethod.
			self assert: args equals: #().
			self assert: link identicalTo: link ];
		selector: #value:value:value:value:;
		arguments: #(object selector arguments link);
		control: #after.
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - method - body' }
ReflectivityReificationTest >> testReifyMethodBodyArgsAfter [
	| sequenceNode instance |
	sequenceNode := (ReflectivityExamples >> #exampleWithArg:) ast body.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(arguments).
	sequenceNode link: link.
	self assert: sequenceNode isSequence.
	self assert: sequenceNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleWithArg:) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: (instance exampleWithArg: 3) equals: 5.
	self assert: tag equals: #(3)
]

{ #category : #'tests - method - body' }
ReflectivityReificationTest >> testReifyMethodBodyArgsBefore [
	| sequenceNode instance |
	sequenceNode := (ReflectivityExamples >> #exampleWithArg:) ast body.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #before;
		arguments: #(arguments).
	sequenceNode link: link.
	self assert: sequenceNode isSequence.
	self assert: sequenceNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleWithArg:) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: (instance exampleWithArg: 3) equals: 5.
	self assert: tag equals: #(3)
]

{ #category : #'tests - method - body' }
ReflectivityReificationTest >> testReifyMethodBodyArgsInstead [
	| sequenceNode instance |
	sequenceNode := (ReflectivityExamples >> #exampleWithArg:) ast body.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #instead;
		arguments: #(arguments).
	sequenceNode link: link.
	self assert: sequenceNode isSequence.
	self assert: sequenceNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleWithArg:) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: (instance exampleWithArg: 3) equals: self.
	self assert: tag equals: #(3)
]

{ #category : #'tests - method ' }
ReflectivityReificationTest >> testReifyMethodReceiver [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(receiver).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag equals: instance
]

{ #category : #'tests - method ' }
ReflectivityReificationTest >> testReifyMethodSelector [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(selector).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag equals: #exampleMethod
]

{ #category : #'tests - method ' }
ReflectivityReificationTest >> testReifyMethodThisContext [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(context).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag class equals: Context
]

{ #category : #'tests - method ' }
ReflectivityReificationTest >> testReifyMethodThisContextAfter [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(context).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag class equals: Context.
	self deny: tag isBlockContext.
]

{ #category : #'tests - method ' }
ReflectivityReificationTest >> testReifyMethodValue [
	| methodNode instance |
	methodNode := (ReflectivityExamples >> #exampleMethod) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(value).
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag equals: 5
]

{ #category : #'tests - assignment' }
ReflectivityReificationTest >> testReifyNewValueAssignmentAfter [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleAssignment)
		assignmentNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(newValue).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: tag equals: 3
]

{ #category : #'tests - assignment' }
ReflectivityReificationTest >> testReifyNewValueAssignmentBefore [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleAssignment) assignmentNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(newValue).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: tag equals: 3
]

{ #category : #'tests - allnodes' }
ReflectivityReificationTest >> testReifyNode [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(node).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: varNode
]

{ #category : #'tests - allnodes' }
ReflectivityReificationTest >> testReifyObject [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(object).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag equals: instance.
	self
		assert: (ReflectivityExamples >> #exampleMethod) class
		equals: CompiledMethod
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyOperationMethod [
	| methodNode instance |
	methodNode := (ReflectivityExamples >> #exampleWithArg:) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #before;
		arguments: #(operation).
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleWithArg:) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: (instance exampleWithArg: 3) equals: 5.
	self assert: tag value equals: 5
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyOperationMethodAfter [
	| methodNode instance |
	methodNode := (ReflectivityExamples >> #exampleWithArg:) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(operation).
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleWithArg:) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: (instance exampleWithArg: 3) equals: 5.
	self assert: tag class identicalTo: RFMethodOperation.
	self assert: tag value equals: 5
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyOperationMethodInstead [
	| methodNode instance |
	methodNode := (ReflectivityExamples >> #exampleWithArg:) ast.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #instead;
		arguments: #(operation).
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleWithArg:) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: (instance exampleWithArg: 3) equals: self.
	self assert: tag class identicalTo: RFMethodOperation.
	self assert: tag value equals: 5
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyOperationSend [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #before;
		arguments: #(operation).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag value equals: 5
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyOperationSendAfter [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(operation).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag value equals: 5
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyOperationSendInstead [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #instead;
		arguments: #(operation).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: self.
	self assert: tag value equals: 5
]

{ #category : #'tests - options' }
ReflectivityReificationTest >> testReifyOptionArgsAsArray [
	" test that we can pass all arguments in an array"

	| methodNode |
	methodNode := (ReflectivityExamples >> #exampleMethod) ast.
	link := MetaLink new
		metaObject: [ :aReceiver :aSelector :args :mylink | 
			tag := #yes.
			self assert: aReceiver class equals: ReflectivityExamples.
			self assert: aSelector equals: #exampleMethod.
			self assert: args equals: #().
			self assert: link identicalTo: link ];
		selector: #valueWithArguments:;
		option: #(+ argsAsArray);
		arguments: #(object selector arguments link);
		control: #after.
	methodNode link: link.
	self assert: methodNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: ReflectivityExamples new exampleMethod equals: 5.
	self assert: tag equals: #yes.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: CompiledMethod
]

{ #category : #'tests - allnodes' }
ReflectivityReificationTest >> testReifyOrigMethod [
	| varNode instance origMethod |
	origMethod := ReflectivityExamples >> #exampleIvarRead.
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(originalmethod).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self deny: tag equals: ReflectivityExamples >> #exampleIvarRead.
	self assert: tag identicalTo: origMethod
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifyReceiverOnSendWithArguments [
	| sendNode instance beforeSize |
	sendNode := (ReflectivityExamples>>#exampleSendNoReturn) ast body statements last.
	beforeSize := 0.
	link := MetaLink new 
		metaObject: [:receiver | beforeSize := receiver size]; 
		selector: #value:;
		control: #before;
		arguments: #(receiver).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples>>#exampleSendNoReturn) class equals: ReflectiveMethod.
	self assert: beforeSize equals: 0.
	instance := ReflectivityExamples new .
	instance exampleSendNoReturn.
	self assert: beforeSize equals: 2.
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifyReceiverOnSendWithArgumentsAfter [
	| sendNode instance beforeSize |
	sendNode := (ReflectivityExamples>>#exampleSendNoReturn) ast body statements last.
	beforeSize := 0.
	link := MetaLink new 
		metaObject: [:receiver | beforeSize := receiver size]; 
		selector: #value:;
		control: #after;
		arguments: #(receiver).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples>>#exampleSendNoReturn) class equals: ReflectiveMethod.
	self assert: beforeSize equals: 0.
	instance := ReflectivityExamples new .
	instance exampleSendNoReturn.
	self assert: beforeSize equals: 1.
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyReturnOperation [
	"operation on return makes only sense for #instead (as else the return already was done)"
	"
	| returnNode reachHere instance |
	
	returnNode := (ReflectivityExamples >> #exampleAssignment) ast body statements last.
	reachHere := false.
	link := MetaLink new
		metaObject: [:operation | reachHere := true. operation value];
		selector: #value:;
		control: #instead;
		arguments: #(operation).
	returnNode link: link.
	self assert: returnNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: reachHere."
]

{ #category : #'tests - return' }
ReflectivityReificationTest >> testReifyReturnValue [
	| returnNode instance |
	returnNode := (ReflectivityExamples >> #exampleAssignment) ast body statements last.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(value).
	returnNode link: link.
	self assert: returnNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: tag equals: 3
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendAfterMany [
	"test to reify a lot after"
	| sendNode instance executed |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	executed := false.
		link := MetaLink new
		metaObject: [ :s :r :a :v | self assert: v equals: 5. executed := true ];
		selector: #value:value:value:value:;
		control: #after;
		arguments: #(selector receiver arguments value).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: executed.
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendAll [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: #receiver;
		selector: #perform:withArguments:;
		arguments: #(selector arguments).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendArgsAsArray [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(selector context);
		options: #(argsAsArray).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag isArray.
	self assert: tag first identicalTo: #+.
	self assert: tag second class identicalTo: Context
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendArguments [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body
		statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(arguments).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag equals: #(3)
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendArguments2 [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleSendTwoArgs) ast body
		statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(arguments).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleSendTwoArgs) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleSendTwoArgs equals: #(1 2).
	self assert: tag equals: #(1 2)
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendArgumentsLevel [
	| sendNode instance|
	sendNode := (ReflectivityExamples>>#exampleMethod) ast body statements first value.
	link := MetaLink new 
		metaObject: self; 
		selector: #tagExec:;
		arguments: #(arguments);
		level: 0.
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples>>#exampleMethod) class equals: ReflectiveMethod.
	self assert: (tag isNil).
	instance := ReflectivityExamples new .
	self assert: instance exampleMethod equals: 5.
	self assert: tag equals: #(3).

]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendMethodToExecute [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(methodToExecute).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag equals: (SmallInteger>>#+).
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendReceiver [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(receiver).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag equals: 2
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendSelector [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(selector).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag equals: #+
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendSender [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(sender).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag equals: instance
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendThisContext [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(context).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag class equals: Context.
	
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendThisContextAfter [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(context).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag class equals: Context.
	self deny: tag isBlockContext.
	
]

{ #category : #'tests - sends' }
ReflectivityReificationTest >> testReifySendValue [
	| sendNode instance |
	sendNode := (ReflectivityExamples >> #exampleMethod) ast body statements first value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(value).
	sendNode link: link.
	self assert: sendNode hasMetalink.
	self assert: (ReflectivityExamples >> #exampleMethod) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleMethod equals: 5.
	self assert: tag equals: 5
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifySlotClass [
	| iVar instance |
	iVar := ReflectivityExamples slotNamed: #ivar.
	link := MetaLink new 
		metaObject: self; 
		selector: #tagExec:;
		arguments: #(class).
	iVar link: link.
	self assert: iVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleIvarRead) class equals: ReflectiveMethod.
	self assert: (tag isNil).
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: ReflectivityExamples.
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifySlotName [
	| iVar instance |
	iVar := ReflectivityExamples slotNamed: #ivar.
	link := MetaLink new 
		metaObject: self; 
		selector: #tagExec:;
		arguments: #(name).
	iVar link: link.
	self assert: iVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleIvarRead) class equals: ReflectiveMethod.
	self assert: (tag isNil).
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: #ivar.
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifySlotOperation [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag class identicalTo: RFSlotRead.
	self deny: tag equals: 'ivar'.
	self assert: tag value equals: 33
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifySlotOperationAfter [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag class identicalTo: RFSlotRead.
	self deny: tag equals: 'ivar'.
	self assert: tag value equals: 33
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifySlotOperationInstead [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleIvarRead) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #instead;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: self.
	self assert: tag class identicalTo: RFSlotRead.
	self deny: tag equals: 'ivar'.
	self assert: tag value equals: 33
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifySlotValue [
	| iVar instance |
	iVar := ReflectivityExamples slotNamed: #ivar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(value).
	iVar link: link.
	self assert: iVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleIvarRead) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: 33
]

{ #category : #'tests - variables' }
ReflectivityReificationTest >> testReifySlotVariable [
	| iVar instance |
	iVar := ReflectivityExamples slotNamed: #ivar.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(variable).
	iVar link: link.
	self assert: iVar hasMetalink.
	self assert: (ReflectivityExamples >> #exampleIvarRead) class equals: ReflectiveMethod.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleIvarRead equals: 33.
	self assert: tag equals: iVar
]

{ #category : #'tests - variablenodes' }
ReflectivityReificationTest >> testReifyTempName [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleAssignment) ast body statements first variable.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(name).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: tag equals: 'temp'
]

{ #category : #'tests - variablenodes' }
ReflectivityReificationTest >> testReifyTempNewValue [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleAssignment) ast body statements first variable.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(newValue).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: tag equals: 3
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyTempOperation [
	| varNode instance executed |
	varNode := (ReflectivityExamples >> #exampleAssignment) ast body statements last value.
	executed := false.
	link := MetaLink new
		metaObject: [ :operation | 
			executed := true.
			self assert: operation class identicalTo: RFTempRead.
			self assert: operation value equals: 3 ];
		selector: #value:;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: executed
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyTempOperationAfter [
	| varNode instance executed |
	varNode := (ReflectivityExamples >> #exampleAssignment) ast body statements last value.
	executed := false.
	link := MetaLink new
		metaObject: [ :operation | 
			executed := true.
			self assert: operation class identicalTo: RFTempRead.
			self assert: operation value equals: 3 ];
		selector: #value:;
		control: #after;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: executed
]

{ #category : #'tests - operations' }
ReflectivityReificationTest >> testReifyTempOperationInstead [
	| varNode instance executed |
	self skip. 
	"skip for now as #usingMethods of the variable gets confused with instead"
	varNode := (ReflectivityExamples >> #exampleAssignment) ast body statements last value.
	executed := false.
	link := MetaLink new
		metaObject: [ :operation | 
			executed := true.
			self assert: operation class identicalTo: RFTempRead.
			self assert: operation value equals: 3.
			operation value ];
		selector: #value:;
		control: #instead;
		arguments: #(operation).
	varNode link: link.
	self assert: varNode hasMetalink.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: executed
]

{ #category : #'tests - variablenodes' }
ReflectivityReificationTest >> testReifyTempValue [
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleAssignment) ast body statements last value.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(value).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: tag equals: 3
]

{ #category : #'tests - assignment' }
ReflectivityReificationTest >> testReifyValueAssignmentAfter [
	"#value for Assignemnt is the new value when #after"
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleAssignment) assignmentNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		control: #after;
		arguments: #(value).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: tag equals: 3
]

{ #category : #'tests - assignment' }
ReflectivityReificationTest >> testReifyValueAssignmentBefore [
	"#value for Assignemnt is the old value, is that what we want?"
	| varNode instance |
	varNode := (ReflectivityExamples >> #exampleAssignment) assignmentNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec:;
		arguments: #(value).
	varNode link: link.
	self assert: varNode hasMetalink.
	self assert: tag isNil.
	instance := ReflectivityExamples new.
	self assert: instance exampleAssignment equals: 3.
	self assert: tag equals: nil
]
