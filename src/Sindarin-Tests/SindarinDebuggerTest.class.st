Class {
	#name : #SindarinDebuggerTest,
	#superclass : #TestCase,
	#instVars : [
		'breakpointsBeforeTest',
		'testObjectPoint'
	],
	#category : #'Sindarin-Tests-Base'
}

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod1 [

	| a |
	a := 1.
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod10 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod11 [

	| a |
	a := 5.
	self helperMethod12.
	self helperMethod12.
	^ 3
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod12 [

	| i |
	i := 5.
	[ i = 0 ] whileFalse: [ i := i - 1 ]
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod13 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod14 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod15 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod16 [

	^ 1 + 1
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod17: storeContextBlock [

	storeContextBlock value: thisContext.
	Point x: 5 y: 7
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod18: anArg with: anotherArg [

	Point x: 5 y: 7
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod19 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod2 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod20 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod21 [

	self helperMethod22
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod22 [

	^ Point new
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod23 [

	testObjectPoint sign.
	testObjectPoint extent: (Point x: 3 y: 4).
	Point new
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod24 [

	| p |
	p := Point new.
	p sign
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod3 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod4 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod5 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod6 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod7 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod8 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethod9 [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethodNonLocalReturn [
	| block |
	block := [ ^ 42 ].
	block value.
	^ 43
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethodReturn: bool [

	| a |
	a := bool.
	a ifTrue: [ ^ 1 ].
	^ 2
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethodReturnWithException [

	| a |
	a := 0.
	1 / 0.
	^ a + 1
]

{ #category : #helpers }
SindarinDebuggerTest >> helperMethodReturnWithHalt [
	<haltOrBreakpointForTesting>

	| a |
	a := 0.
	self halt.
	^ a + 1
]

{ #category : #running }
SindarinDebuggerTest >> runCaseManaged [
	^ self runCase
]

{ #category : #running }
SindarinDebuggerTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
	
	super setUp.
	breakpointsBeforeTest := VirtualBreakpoint all.
	VirtualBreakpoint all removeAll.
	testObjectPoint := Point x: 1 y: 2.
]

{ #category : #running }
SindarinDebuggerTest >> tearDown [

	VirtualBreakpoint all removeAll.
	breakpointsBeforeTest do: [ :breakPoint | VirtualBreakpoint all add: breakPoint ].
	super tearDown
]

{ #category : #tests }
SindarinDebuggerTest >> testAddStepHook [
	| stepCounter stepHook scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod11 ].
	stepCounter := 0.
	stepHook := [ stepCounter := stepCounter + 1 ].
	scdbg addStepHook: stepHook.
	scdbg step.
	self assert: stepCounter equals: 1.
	scdbg step; stepOver.
	self assert: stepCounter equals: 21.
	scdbg removeStepHook: stepHook.
	scdbg stepOver.
	self assert: stepCounter equals: 21
]

{ #category : #tests }
SindarinDebuggerTest >> testArguments [
	| p scdbg |
	p := Point new.
	scdbg := SindarinDebugger debug: [ self helperMethod18: 1 with: p ].
	scdbg step.
	self assert: scdbg arguments size equals: 2.
	self assert: (scdbg arguments at: 1) equals: 1.
	self assert: (scdbg arguments at: 2) equals: p
	
]

{ #category : #tests }
SindarinDebuggerTest >> testAssignmentValue [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod2 ].
	scdbg step.
	self assert: scdbg assignmentValue equals: 5
]

{ #category : #tests }
SindarinDebuggerTest >> testAssignmentVariableName [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod3 ].
	scdbg step.
	self assert: scdbg assignmentVariableName equals: #a
]

{ #category : #tests }
SindarinDebuggerTest >> testContext [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod15 ].
	self assert: scdbg context equals: scdbg debugSession interruptedContext.
	scdbg step.
	self assert: scdbg context equals: scdbg debugSession interruptedContext
]

{ #category : #tests }
SindarinDebuggerTest >> testContinue [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg
		step;
		step.
	self assert: scdbg node isMessage.
	self assert: scdbg node selector equals: #asInteger.
	scdbg setBreakpoint.
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg continue.
	self assert: scdbg node isMessage.
	self assert: scdbg node selector equals: #asInteger
]

{ #category : #tests }
SindarinDebuggerTest >> testContinueUntilTheEnd [
	"Test the #continue method when no breakpoint/halt is set. It should step the execution until the end and NOT freeze the image"

	| scdbg semaphore |
	self flag: 'What is "setup code for the timeout?'.
	"VVV Setup code for the timeout"
	semaphore := Semaphore new.
	[ "^^^ Setup code for the timeout"
	scdbg := SindarinDebugger debug: [ self helperMethod20 ].
	scdbg continue.
	self assert: scdbg isExecutionFinished.

	"VVV Code for the timeout"
	semaphore signal ] fork.
	semaphore
		wait: 5 seconds
		onCompletion: [ 'success' ]
		onTimeout: [ "^^^ Setup code for the timeout" self assert: false description: 'Test timed out' ]
]

{ #category : #'tests - execution predicates' }
SindarinDebuggerTest >> testIsAboutToInstantiateClass [

	|debugger session|
	debugger := SindarinDebugger new.
	session := SindarinDebugSessionMock new.
	debugger sindarinSession: session.
	
	session isMessage: false.	
	self deny: debugger isAboutToInstantiateClass.
	
	session isMessage: true.
	session receiver: Object new.
	session selector: #yourself.
	self deny: debugger isAboutToInstantiateClass.
	
	session receiver: Object new.
	session selector: #toto.
	self deny: debugger isAboutToInstantiateClass.
	
	session receiver: Behavior new.
	session selector: #basicNew. "Primitive 70"
	self assert: debugger isAboutToInstantiateClass.
	
	session selector: #basicNew:. "Primitive 71"
	self assert: debugger isAboutToInstantiateClass.
	
	session selector: #adoptInstance:. "Primitive 160"
	self assert: debugger isAboutToInstantiateClass.
	
	session receiver: Object new.
	session selector: #clone. "Primitive 148"
	self assert: debugger isAboutToInstantiateClass.
		
	session receiver: CompiledCode.
	session selector: #newMethod:header:. "Primitive 79"
	self assert: debugger isAboutToInstantiateClass
	
]

{ #category : #tests }
SindarinDebuggerTest >> testIsExecutionFinished [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod16 ].
	self deny: scdbg isExecutionFinished.
	
	[ scdbg isExecutionFinished ] whileFalse: [ scdbg stepOver ].

	self assert: scdbg currentProcess isTerminated
]

{ #category : #tests }
SindarinDebuggerTest >> testMessageArguments [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod4 ].
	scdbg step; step.
	self assert: scdbg messageArguments isEmpty.
	scdbg stepOver.
	self assert: (scdbg messageArguments at: 1) equals: 5.
	self assert: (scdbg messageArguments at: 2) equals: 3
]

{ #category : #tests }
SindarinDebuggerTest >> testMessageReceiver [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod5 ].
	self assert: scdbg messageReceiver equals: self.
	scdbg step; step.
	self assert: scdbg messageReceiver equals: '3'
]

{ #category : #tests }
SindarinDebuggerTest >> testMessageSelector [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod6 ].
	self assert: scdbg messageSelector equals: #helperMethod6.
	scdbg step; step.
	self assert: scdbg messageSelector equals: #asInteger.
	scdbg stepOver.
	self assert: scdbg messageSelector equals: #x:y:
]

{ #category : #tests }
SindarinDebuggerTest >> testMessageTo [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod23 ].
	scdbg step.	"Step to <testObjectPoint sign.> call"
	self assert: (scdbg message: #sign to: testObjectPoint).
	scdbg
		stepOver;
		stepOver.	"Step to <testObjectPoint extent: ...> call"
	self assert: (scdbg message: #extent: to: testObjectPoint).
	
	"Should return false with wrong selector but correct receiver"
	self deny: (scdbg message: #bogus to: testObjectPoint).
	
	"Should return false with correct selector but wrong receiver"
	self deny: (scdbg message: #extent: to: Point new)	
]

{ #category : #tests }
SindarinDebuggerTest >> testMessageToInstanceOf [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod24 ].
	scdbg step; stepOver: 2. "Step to <p sign> call"
	self assert: (scdbg message: #sign toInstanceOf: Point).
	self assert: (scdbg message: #sign toInstanceOf: Object).
	self deny: (scdbg message: #sign toInstanceOf: Rectangle).
	self deny: (scdbg message: #bogus toInstanceOf: Point)
]

{ #category : #tests }
SindarinDebuggerTest >> testMethod [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod7 ].	
	self assert: scdbg method equals: [ self helperMethod7 ] method.
	scdbg step.
	self assert: scdbg method equals: SindarinDebuggerTest>>#helperMethod7.
	scdbg step; step.
	self assert: scdbg method equals: String>>#asInteger
]

{ #category : #tests }
SindarinDebuggerTest >> testNode [
	| node scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod1 ].
	node := scdbg node.
	self assert: node isMessage.
	self assert: node selector equals: #helperMethod1.
	scdbg step.
	node := scdbg node.
	self assert: node isAssignment.
	self assert: node variable name equals: #a.
	scdbg stepOver.
	scdbg stepOver.
	node := scdbg node.
	self assert: node isMessage.
	self assert: node selector equals: #asInteger
]

{ #category : #tests }
SindarinDebuggerTest >> testOnceBreakpoint [
	| breakpoint scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg step; step.
	self assert: scdbg node isMessage.
	self assert: scdbg node selector equals: #asInteger.
	breakpoint := scdbg setBreakpoint.
	breakpoint once.
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg continue.
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg continue.
	self assert: scdbg isExecutionFinished
]

{ #category : #tests }
SindarinDebuggerTest >> testPc [
	| dbg |
	dbg := SindarinDebugger
		debug: [ | a p |
			a := 2.
			p := Point x: 2 y: 3 ].
	dbg step; step; step.
	self assert: dbg pc equals: dbg context pc
]

{ #category : #tests }
SindarinDebuggerTest >> testReceiver [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod8 ].
	self assert: scdbg receiver equals: self.
	scdbg step.
	self assert: scdbg receiver equals: self.
	scdbg step; step.
	self assert: scdbg receiver equals: '3'
]

{ #category : #tests }
SindarinDebuggerTest >> testRemoveBreakpoint [
	| breakpoint scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg step; step.
	self assert: scdbg node isMessage.
	self assert: scdbg node selector equals: #asInteger.
	breakpoint := scdbg setBreakpoint.
	breakpoint remove.
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg continue.
	self assert: scdbg isExecutionFinished
]

{ #category : #tests }
SindarinDebuggerTest >> testSelector [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod9 ].
	self assert: scdbg selector equals: #testSelector.
	scdbg step.
	self assert: scdbg selector equals: #helperMethod9.
	scdbg step; step.
	self assert: scdbg selector equals: #asInteger
]

{ #category : #tests }
SindarinDebuggerTest >> testSetBreakpoint [
	self flag: 'What is this test?'.
	self testContinue
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkip [
	| a p scdbg |
	a := 1.
	scdbg := SindarinDebugger
		debug: [ a := 2.
			p := Point x: 2 y: 3 ].
	scdbg skip.
	self assert: a equals: 1.
	scdbg skip.
	scdbg step.
	self assert: p equals: nil
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipThroughNode [
	| dbg realExecPC realValueOfA targetExecNode realExecTopStack nodeAfterSkipThrough |
	self skipOnPharoCITestingEnvironment.
	dbg := SindarinDebugger
		debug: [ self helperMethod1  ].
	dbg step; stepOver; stepOver.	
	targetExecNode := dbg node.
	realValueOfA := (dbg temporaryNamed: #a).	
	dbg stepOver.
	nodeAfterSkipThrough := dbg node.
	realExecTopStack := dbg topStack.
	realExecPC := dbg pc.
	
	dbg := SindarinDebugger
		debug: [ self helperMethod1  ].
	
	dbg step; stepOver; skipThroughNode: targetExecNode.
		
	self assert: dbg pc equals: realExecPC.
	self assert: dbg node identicalTo: nodeAfterSkipThrough.
	self assert: realValueOfA equals: 5.
	self assert: (dbg temporaryNamed: #a) equals: 1.
	self assert: realExecTopStack equals: 3.
	self assert: dbg topStack equals: nil
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipToPC [
	| dbg realExecPC realValueOfA realExecNode realExecTopStack |
	self skipOnPharoCITestingEnvironment.
	dbg := SindarinDebugger
		debug: [ self helperMethod1  ].
	dbg step; stepOver; stepOver.
	realExecPC := dbg pc.
	realExecNode := dbg node.
	realValueOfA := (dbg temporaryNamed: #a).
	realExecTopStack := dbg topStack.

	dbg := SindarinDebugger
		debug: [ self helperMethod1  ].

	dbg step; stepOver; skipToPC: realExecPC. 
	self assert: dbg pc equals: realExecPC.
	self assert: dbg node equals: realExecNode.
	self assert: realValueOfA equals: 5.
	self assert: (dbg temporaryNamed: #a) equals: 1.
	self assert: dbg topStack equals: realExecTopStack
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipUpToNode [
	| dbg realExecPC realValueOfA realExecNode realExecTopStack |
	self skipOnPharoCITestingEnvironment.
	dbg := SindarinDebugger
		debug: [ self helperMethod1  ].
	dbg step; stepOver; stepOver.
	realExecPC := dbg pc.
	realExecNode := dbg node.
	realValueOfA := (dbg temporaryNamed: #a).
	realExecTopStack := dbg topStack.
	
	dbg := SindarinDebugger
		debug: [ self helperMethod1  ].
	
	dbg step; stepOver; skipUpToNode: realExecNode. 
	self assert: dbg pc equals: realExecPC.
	self assert: dbg node identicalTo: realExecNode.
	self assert: realValueOfA equals: 5.
	self assert: (dbg temporaryNamed: #a) equals: 1.
	self assert: dbg topStack equals: realExecTopStack
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipWith [
	| a p scdbg |
	self skipOnPharoCITestingEnvironment.
	a := 1.
	scdbg := SindarinDebugger
		debug: [ a := 2.
			p := Point x: 2 y: 3 ].
	scdbg skipWith: 3.
	self assert: a equals: 1.
	scdbg skipWith: 5.
	scdbg step.
	self assert: p equals: 5
]

{ #category : #tests }
SindarinDebuggerTest >> testStack [
	| context1 context2 storeContextBlock scdbg |
	storeContextBlock := [ :thisCtx | context2 := thisCtx ].
	scdbg := SindarinDebugger
		debug: [ context1 := thisContext.
			self helperMethod17: storeContextBlock ].
	scdbg step.
	self assert: scdbg stack first equals: context1.
	scdbg
		step;
		stepOver.
	self assert: scdbg stack first equals: context2.
	self assert: (scdbg stack at: 2) equals: context1
]

{ #category : #tests }
SindarinDebuggerTest >> testStep [
	| node scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod13 ].
	scdbg step.
	node := scdbg node.
	self assert: node isAssignment.
	self assert: node variable name equals: #a.
	scdbg step.
	node := scdbg node.
	self assert: node isMessage.
	self assert: node selector equals: #asInteger
]

{ #category : #tests }
SindarinDebuggerTest >> testStepOver [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod14 ].
	scdbg step. "Enters the call of helperMethod14. Current node should be: a:=5"
	scdbg stepOver. "After this, current node should be: '3' asInteger"
	scdbg stepOver. "After this, current node should be: Point x:5 y:'3' asInteger"
	self assert: scdbg node isMessage.
	self assert: scdbg node selector equals: #x:y:
]

{ #category : #tests }
SindarinDebuggerTest >> testStepOverReturnNode [
	|scdbg|
	scdbg := SindarinDebugger debug: [ self helperMethod21 ].
	scdbg step; step.
	scdbg stepOver.
	self shouldnt: [scdbg stepOver] raise: SteppingATerminatingProcess.
	self assert: scdbg selector equals: #helperMethod21.
	self assert: scdbg node isMethod.
	self flag: 'Why is the following commented? Should it be tested somehow?'
"	self assert: scdbg node isBlock."
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToImplicitReturn [
	| dbg |
	self skipOnPharoCITestingEnvironment.
	dbg := SindarinDebugger debug: [ self helperMethod23 ].
	dbg stepToMethodEntry.
	dbg stepToReturn.
	
	self assert: dbg node isMethod.
	dbg step.		
	self assert: dbg topStack equals: self.
	
	

	
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToMethodEntry [
	| dbg |
	self skipOnPharoCITestingEnvironment.
	dbg := SindarinDebugger debug: [ self helperMethodReturn: true ].
	dbg stepToMethodEntry.
		
	self assert: dbg pc equals: dbg method initialPC.
	self assert: dbg method identicalTo: (self class >> #helperMethodReturn:).	
	
	
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToNonLocalReturn [
	| dbg |
	self skipOnPharoCITestingEnvironment.	
	dbg := SindarinDebugger debug: [ self helperMethodNonLocalReturn ].
	dbg stepToMethodEntry.
	dbg stepToReturn.
	
	self assert: dbg node isReturn.
	self assert: dbg topStack equals: 42
	
	

	
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToReturn [
	| dbg |
	self skipOnPharoCITestingEnvironment.
	"First return node"
	dbg := SindarinDebugger debug: [ self helperMethodReturn: true ].
	dbg stepToMethodEntry.
	dbg stepToReturn.
	
	self assert: dbg node isReturn.
	self assert: dbg topStack equals: 1.
	
	"Second return node"
	dbg := SindarinDebugger debug: [ self helperMethodReturn: false ].
	dbg stepToMethodEntry.
	dbg stepToReturn.
	
	self assert: dbg node isReturn.
	self assert: dbg topStack equals: 2
	
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToReturnWithException [
	| dbg |
	self skipOnPharoCITestingEnvironment.
	"First return node"
	dbg := SindarinDebugger debug: [ self helperMethodReturnWithException ].
	dbg stepToMethodEntry.
	dbg stepToReturn.
	
	self assert: dbg receiver class identicalTo: ZeroDivide.
	self assert: dbg method equals: (Exception >> #signal)
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToReturnWithHalt [
	| dbg |
	self skipOnPharoCITestingEnvironment.
	"First return node"
	dbg := SindarinDebugger debug: [ self helperMethodReturnWithHalt ].
	dbg stepToMethodEntry.
	dbg stepToReturn.
	
	self assert: dbg context willReturn.
	self assert: dbg node isReturn.
	self assert: dbg topStack equals: 1
]

{ #category : #tests }
SindarinDebuggerTest >> testStepUntil [
	| i scdbg |
	i := 20.
	scdbg := SindarinDebugger
		debug: [ [ i = 0 ] whileFalse: [ i := i - 1 ] ].
	scdbg stepUntil: [ i = 12 ].
	self assert: i equals: 12
]

{ #category : #tests }
SindarinDebuggerTest >> testSteppingAnExecutionSignalingExceptions [
	| scdbg |
	scdbg := SindarinDebugger
		debug: [ 1 / 0.
			2 / 0.
			3 / 0 ].
	self
		should: [ scdbg
				stepOver;
				stepOver;
				stepOver ]
		raise: UnhandledExceptionSignalledByADebuggedExecution
]

{ #category : #tests }
SindarinDebuggerTest >> testTemporaryNamed [
	| dbg |
	dbg := SindarinDebugger debug: [ self helperMethod10 ].
	dbg step.
	self assert: (dbg temporaryNamed: #a) equals: nil.
	dbg step.
	self assert: (dbg temporaryNamed: #a) equals: 5
]

{ #category : #tests }
SindarinDebuggerTest >> testTerminate [
	| dbg |
	dbg := SindarinDebugger debug: [ self helperMethod13 ].
	self assert: dbg debugSession interruptedContext notNil.
	self assert: dbg debugSession interruptedProcess notNil.
	dbg terminate.
	self assert: dbg debugSession interruptedContext isNil.
	self assert: dbg debugSession interruptedProcess isNil.
]

{ #category : #tests }
SindarinDebuggerTest >> testTopStack [
	| a dbg |
	a := 1.
	dbg := SindarinDebugger debug: [ a := 2 ].
	dbg step.
	self assert: dbg topStack equals: 2
]

{ #category : #tests }
SindarinDebuggerTest >> testWhenHitBreakpoint [
	| breakpoint toggle scdbg |
	toggle := false.
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg step; step.
	self assert: scdbg node isMessage.
	self assert: scdbg node selector equals: #asInteger.
	breakpoint := scdbg setBreakpoint.
	breakpoint whenHit: [ toggle := true ].
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg continue.
	self assert: toggle
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testskipUpToNodeSkipTargetNode [
	"The tested method takes two params: 
		- the node up to which we want to skip execution
		- a boolean telling if we want to skip through the node or give back control to users before that node.
	Variations of these two params are tested by testSkipUpToNode and testSkipThroughNode.
	The following just test the remaining aspect of that API, that is we do not skip through a return node."
	| dbg returnNode |	
	self skipOnPharoCITestingEnvironment.
	dbg := SindarinDebugger
		debug: [ self helperMethod1  ].
		
	returnNode := (self class >> #helperMethod1) ast statements last.
	dbg step; skipThroughNode: returnNode.
	self assert: dbg node equals: returnNode.
	self assert: dbg topStack equals: nil
]
