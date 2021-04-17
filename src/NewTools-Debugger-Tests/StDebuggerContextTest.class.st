Class {
	#name : #StDebuggerContextTest,
	#superclass : #TestCase,
	#instVars : [
		'debuggerContext',
		'hostObject'
	],
	#category : #'NewTools-Debugger-Tests-Model'
}

{ #category : #helpers }
StDebuggerContextTest >> contextWithArgs [

	"Creates and returns a context in which we step until we enter a method with temporary variables, then step two times over the assignement of the first temp"

	| context |
	context := [ hostObject methodWithArg1: 4 arg2: 2  ] asContext.
	[ context method selector = #methodWithArg1:arg2: ] whileFalse: [ 
		context := context step ].

	context := context step.
	context := context step.
	^ context
]

{ #category : #helpers }
StDebuggerContextTest >> contextWithArgsInBlock [

	"Creates and returns a context in which we step until we enter a method with arguments in a block, then step 4 times until we're in the block"

	| context |
	context := [ hostObject methodWithArgsInBlock ] asContext.
	[ context method selector = #methodWithArgsInBlock ] whileFalse: [ 
		context := context step ].

	4 timesRepeat: [ context := context step ].
	context := context step.
	^ context
]

{ #category : #helpers }
StDebuggerContextTest >> contextWithTemps [

	"Creates and returns a context in which we step until we enter a method with temporary variables, then step two times over the assignement of the first temp"

	| context |
	context := [ hostObject methodWithTemps ] asContext.
	[ context method selector = #methodWithTemps ] whileFalse: [ 
		context := context step ].

	context := context step.
	context := context step.
	^ context
]

{ #category : #running }
StDebuggerContextTest >> setUp [
	super setUp.
	
	debuggerContext := StDebuggerContext new.
	hostObject := StDebuggerObjectForTests new
]

{ #category : #tests }
StDebuggerContextTest >> testArgumentsNodes [
	|nodes| 
	debuggerContext context: self contextWithArgs.
	nodes := debuggerContext temporaryVariablesNodes select: [ :tempNode | tempNode tempVariable isArgumentVariable ].	
	self assert: nodes size equals: 2.
	self assert: nodes first key equals: 'i'.
	self assert: nodes first variableTag equals: 'arg'.
	self assert: nodes first rawValue equals: 4.
	self assert: nodes first class equals: StInspectorTempNode.
	self assert: nodes second key equals: 'j'.
	self assert: nodes second variableTag equals: 'arg'.
	self assert: nodes second rawValue equals: 2.
	self assert: nodes second class equals: StInspectorTempNode.
	self deny: (nodes anySatisfy: [:n| n key = 'self'])
]

{ #category : #tests }
StDebuggerContextTest >> testArgumentsNodesInBlock [
	|nodes|
	debuggerContext context: self contextWithArgsInBlock.
	nodes := debuggerContext temporaryVariablesNodes select: [ :tempNode | tempNode tempVariable isArgumentVariable ].	
	self assert: nodes size equals: 2.
	self assert: nodes first key equals: 'a'.
	self assert: nodes first variableTag equals: 'arg'.
	self assert: nodes first rawValue equals: 4.
	self assert: nodes second key equals: 'b'.
	self assert: nodes second variableTag equals: 'arg'.
	self assert: nodes second rawValue equals: 2.
	self deny: (nodes anySatisfy: [:n| n key = 'self'])
]

{ #category : #tests }
StDebuggerContextTest >> testBuildInspectorNodes [
	|nodes nodesNames|
	debuggerContext context: self contextWithArgs.
	nodes := debuggerContext buildInspectorNodes.		
	nodesNames := (nodes collect:[:n| n key]).
	
	"Args"
	self assertCollection: nodesNames includesAll: #(#i #j).
	
	"Temps"
	self assertCollection: nodesNames includesAll: #(#a #b).

	"Self"
	self assertCollection: nodesNames includesAll: #(#self #instVar).
	
	"Stacktop"
	self assertCollection: nodesNames includesAll: #('stackTop').
		
	"thisContext"
	self assertCollection: nodesNames includesAll: #('thisContext').	
	
	"There is no more elements"
	self assert: nodesNames size equals: 8
]

{ #category : #tests }
StDebuggerContextTest >> testBuildInspectorNodesForException [
	| nodes object exception |
	object := Object new.
	[ object toto ]
		on: Error
		do: [ :e | 
			exception := e freeze.
			debuggerContext context: e signalerContext.
			debuggerContext exception: e ].
	nodes := debuggerContext buildInspectorNodes.
	self assert: (nodes at: (nodes size - 1)) key equals: 'Exception'.
	self assert: (nodes at: (nodes size - 1)) rawValue identicalTo: exception.
	self assert: (nodes last) key equals: 'DNU receiver'. 
	self assert: (nodes last) rawValue identicalTo: object
]

{ #category : #tests }
StDebuggerContextTest >> testContext [

	| closure contextSource ctx |
	closure := debuggerContext context closure.
	contextSource := closure method sourceCode
		                 copyFrom: closure sourceNode start
		                 to: closure sourceNode stop.
	self assert: contextSource equals: '[]'.
	ctx := self contextWithArgs.
	debuggerContext context: ctx.
	self assert: debuggerContext context identicalTo: ctx
]

{ #category : #tests }
StDebuggerContextTest >> testExceptionNodes [

	| nodes object exception |
	object := Object new.
	[ object toto ]
		on: Error
		do: [ :e | 
			exception := e freeze.
			debuggerContext context: e signalerContext.
			debuggerContext exception: e ].
	nodes := debuggerContext exceptionNodes.
	self assert: nodes size equals: 2.
	self assert: nodes first key equals: 'Exception'.
	self assert: nodes first rawValue equals: exception.
	self assert: nodes first variableTag equals: 'implicit'.
	self
		assert: nodes first rawValue class
		identicalTo: MessageNotUnderstood.
	self assert: nodes second key equals: 'DNU receiver'.
	self assert: nodes second rawValue identicalTo: object.
	self assert: nodes first variableTag equals: 'implicit'.
]

{ #category : #tests }
StDebuggerContextTest >> testNoDuplicatesBetweenArgsAndTemps [
	|nodes nodesNamesArray nodesNamesSet|
	debuggerContext context: self contextWithArgs.
	nodes := debuggerContext allInspectorNodes.	
	nodesNamesArray := (nodes collect:[:n| n key]) asSortedCollection.
	nodesNamesSet := nodesNamesArray asSet asSortedCollection.
	self assertCollection: nodesNamesArray equals: nodesNamesSet
]

{ #category : #tests }
StDebuggerContextTest >> testNullExceptionNodes [

	self assertEmpty: debuggerContext exceptionNodes
]

{ #category : #tests }
StDebuggerContextTest >> testReceiverNodes [

	| nodes |
	debuggerContext context: self contextWithTemps.
	nodes := debuggerContext receiverNodes.
	self assert: nodes size equals: 1.
	self assert: nodes first key equals: 'instVar'.
	self assert: nodes first rawValue equals: hostObject instVar
]

{ #category : #tests }
StDebuggerContextTest >> testSelfNodes [

	| node |
	debuggerContext context: self contextWithTemps.
	node := debuggerContext selfNode.
	self assert: node key equals: 'self'.
	self assert: node rawValue identicalTo: hostObject.
]

{ #category : #tests }
StDebuggerContextTest >> testStackTopNode [	
	| node|
	"We step once on the context to be on the value part of the next assignment"
	debuggerContext context: self contextWithTemps step.
	node := debuggerContext stackTopNode.	
	self assert: node key equals: 'stackTop'.
	self assert: node rawValue equals: 0
]

{ #category : #tests }
StDebuggerContextTest >> testTemporaryVariablesNodes [
	|nodes|	
	debuggerContext context: self contextWithTemps.
	nodes := debuggerContext temporaryVariablesNodes.
	self assert: nodes size equals: 2.
	self assert: nodes first key equals: 'a'.
	self assert: nodes first variableTag equals: 'temp'.	
	self assert: nodes first rawValue equals: 0.
	self assert: nodes first tempVariable isTempVariable.
	self assert: nodes second key equals: 'b'.
	self assert: nodes second variableTag equals: 'temp'.	
	self assert: nodes second rawValue equals: nil.
	self assert: nodes first tempVariable isTempVariable.
	self deny: (nodes anySatisfy: [:n| n key = 'self'])
]

{ #category : #tests }
StDebuggerContextTest >> testThisContextNode [
	|ctx node|
	ctx := self contextWithTemps.
	debuggerContext context: ctx.
	node := debuggerContext thisContextNode.	
	self assert: node key equals: 'thisContext'.
	self assert: node rawValue identicalTo: ctx
]
