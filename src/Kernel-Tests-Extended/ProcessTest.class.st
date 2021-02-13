"
A ProcessTest holds test cases for generic Process-related behaviour.
"
Class {
	#name : #ProcessTest,
	#superclass : #TestCase,
	#category : #'Kernel-Tests-Extended-Processes'
}

{ #category : #tests }
ProcessTest >> testFork [

	| hasBlockRun block return checkAssert |
	checkAssert := Semaphore new.
	hasBlockRun := false.
	block := [ hasBlockRun := true. checkAssert signal.].
	return := block fork.
	
	"Returns immediately, forked block not yet run"
	self deny: hasBlockRun.
	
	"Returns a process - Blue book specifies that it returns the block itself"
	self assert: (return isKindOf: Process).
	
	"Forked process has been scheduled"
	checkAssert wait.
	self assert: hasBlockRun 
]

{ #category : #tests }
ProcessTest >> testForkAtHigherPriority [
	| hasBlockRun |
	hasBlockRun := false.
	[ hasBlockRun := true ] forkAt: Processor activeProcess priority + 1.

	"Preempts current process"
	self assert: hasBlockRun
]

{ #category : #'tests - exception handlers' }
ProcessTest >> testInjectingExceptionHandlerFromProcessItself [
	| error interceptedError process interrupted |
	DefaultExecutionEnvironment beActive.
	error := Error new messageText: 'test error'.
	interrupted := true.
	process := [ Processor activeProcess
		on: Error
		do: [ :err | interceptedError := err ].
	error signal.
	interrupted := false ] fork.

	[ process isTerminated ] whileFalse: [ Processor yield ].

	self assert: interceptedError identicalTo: error.
	self assert: interrupted
]

{ #category : #'tests - exception handlers' }
ProcessTest >> testInjectingExceptionHandlerIntoNotRunningProcess [
	| error interceptedError process interrupted |
	DefaultExecutionEnvironment beActive.
	error := Error new messageText: 'test error'.
	interrupted := true.
	process := [ error signal.
	interrupted := false ] newProcess.
	process
		on: Error
		do: [ :err | interceptedError := err ].
	process resume.
	[ process isTerminated ] whileFalse: [ Processor yield ].

	self assert: interceptedError identicalTo: error.
	self assert: interrupted
]

{ #category : #'tests - exception handlers' }
ProcessTest >> testInjectingExceptionHandlerIntoProcessWithArg [
	| error interceptedError process interrupted processArg |
	DefaultExecutionEnvironment beActive.
	error := Error new messageText: 'test error'.
	interrupted := true.
	process := [ :arg | 
	processArg := arg.
	error signal.
	interrupted := false ] newProcessWith: #(#arg).
	process
		on: Error
		do: [ :err | interceptedError := err ].
	process resume.
	[ process isTerminated ] whileFalse: [ Processor yield ].

	self assert: interceptedError identicalTo: error.
	self assert: interrupted.
	self assert: processArg equals: #arg
]

{ #category : #'tests - exception handlers' }
ProcessTest >> testInjectingExceptionHandlerIntoRunningProcess [
	| error interceptedError process sema started interrupted |
	DefaultExecutionEnvironment beActive.
	error := Error new messageText: 'test error'.
	sema := Semaphore new.
	started := false.
	interrupted := true.
	process := [ started := true.
	sema wait.
	error signal.
	interrupted := false ] newProcess.
	process resume.
	[ started ] whileFalse: [ Processor yield ].

	process
		on: Error
		do: [ :err | interceptedError := err ].

	sema signal.
	[ process isTerminated ] whileFalse: [ Processor yield ].

	self assert: interceptedError identicalTo: error.
	self assert: interrupted
]

{ #category : #'tests - exception handlers' }
ProcessTest >> testInjectingMultipleExceptionHandlersIntoNotRunningProcess [

	| error process lastHandler firstHandler |
	DefaultExecutionEnvironment beActive.
	firstHandler := lastHandler := false.
	process := [ error signal ] newProcess.
	process on: ZeroDivide do: [ :err | firstHandler := true ].
	process on: Error do: [ :err | lastHandler := true ].
	
	error := ZeroDivide new.
	process resume.
	[process isTerminated] whileFalse: [ Processor yield ].
	self assert: firstHandler.
	self deny: lastHandler.
	
	firstHandler := lastHandler := false.
	process := [ error signal ] newProcess.
	process on: ZeroDivide do: [ :err | firstHandler := true ].
	process on: Error do: [ :err | lastHandler := true ].
	
	error := Error new.
	process resume.
	[process isTerminated] whileFalse: [ Processor yield ].
	self deny: firstHandler.
	self assert: lastHandler
]

{ #category : #'tests - exception handlers' }
ProcessTest >> testInjectingMultipleExceptionHandlersIntoRunningProcess [

	| error process lastHandler firstHandler sema started |
	DefaultExecutionEnvironment beActive.
	started := firstHandler := lastHandler := false.	
	sema := Semaphore new.
	process := [started := true. sema wait. error signal ] fork.
	[started] whileFalse: [ Processor yield ].
	process on: ZeroDivide do: [ :err | firstHandler := true ].
	process on: Error do: [ :err | lastHandler := true ].
	
	error := ZeroDivide new.
	sema signal.
	[process isTerminated] whileFalse: [ Processor yield ].
	self assert: firstHandler.
	self deny: lastHandler.
	
	started := firstHandler := lastHandler := false.
	sema := Semaphore new.
	process := [started := true. sema wait. error signal ] fork.
	[started] whileFalse: [ Processor yield ].
	process on: ZeroDivide do: [ :err | firstHandler := true ].
	process on: Error do: [ :err | lastHandler := true ].
	
	error := Error new.
	sema signal.
	[process isTerminated] whileFalse: [ Processor yield ].
	self deny: firstHandler.
	self assert: lastHandler
]

{ #category : #tests }
ProcessTest >> testIsNotSuspendedWhenItIsActiveProcess [

	| semaphore suspended |
	semaphore := Semaphore new.
	[ suspended := Processor activeProcess isSuspended. semaphore signal ] fork.
	semaphore wait.
	self deny: suspended
]

{ #category : #tests }
ProcessTest >> testIsNotSuspendedWhenItIsRunningButNotActiveProcess [

	| semaphore process |
	semaphore := Semaphore new.
	process := [ semaphore signal. Processor yield ] fork.
	semaphore wait.
	self deny: process isTerminated.
	self deny: process isSuspended
]

{ #category : #tests }
ProcessTest >> testIsNotSuspendedWhenItIsTerminated [

	| semaphore process |
	semaphore := Semaphore new.
	process := [ semaphore signal] fork.
	semaphore wait.
	self assert: process isTerminated.
	self deny: process isSuspended
]

{ #category : #tests }
ProcessTest >> testIsSelfEvaluating [
	self assert: Processor printString equals: 'Processor'
]

{ #category : #tests }
ProcessTest >> testIsSuspendedWhenItIsNotStartedYet [

	| process |
	process := [  ] newProcess.
	self assert: process isSuspended
]

{ #category : #'tests - termination' }
ProcessTest >> testIsTerminatingForcedTermination [
	| process unwound started terminator unwindChecks terminationSemaphore |
	unwound := false.
	started := false.
	terminationSemaphore := Semaphore new.
	terminationSemaphore signal.
	process := [ started := true.
	[ terminationSemaphore
		wait;
		wait ]
		ensure: [ terminator := Processor activeProcess.
			unwindChecks value.
			unwound := true ] ] newProcess.
	process priority: Processor activePriority - 1.

	self assert: process isSuspended.
	self deny: process isTerminating.
	self deny: process isTerminated.
	self deny: started.
	self deny: unwound.

	process resume.
	[ terminationSemaphore isSignaled ] whileTrue: [ 50 milliSeconds asDelay wait ].
	self deny: process isSuspended.
	self deny: process isTerminating.
	self deny: process isTerminated.
	self assert: started.
	self deny: unwound.
	self deny: terminator identicalTo: process.

	terminationSemaphore signal.
	"This will run the #ensure: block and block on the Semaphore."
	process terminate.
	"We want these checks to run during unwinding, so we need to cheat a bit."
	unwindChecks := [ self assert: process isSuspended.
	"We're inside of #terminate."
	self assert: process isTerminating.
	"Still unwinding, so not finished."
	self deny: process isTerminated.
	self assert: started.
	"Not unwound yet."
	self deny: unwound.
	self assert: terminator identicalTo: process ].

	[ process isTerminated ] whileFalse: [ 50 milliSeconds asDelay wait ].
	self deny: process isSuspended.
	self assert: process isTerminating.
	self assert: process isTerminated.
	self assert: started.
	self assert: unwound.
	self assert: terminator identicalTo: process
]

{ #category : #'tests - termination' }
ProcessTest >> testIsTerminatingForcedTerminationWithoutRunning [
	| process unwound started terminator |
	unwound := false.
	started := false.
	process := [ started := true.
	[ Semaphore new wait ]
		ensure: [ terminator := Processor activeProcess.
			unwound := true ] ] newProcess.
	"This will prevent the process from getting a chance to run.
	Effectively the pc of suspendedContext will be equal to startpc."
	process priority: Processor systemBackgroundPriority.

	self assert: process isSuspended.
	self deny: process isTerminating.
	self deny: process isTerminated.
	self deny: started.
	self deny: unwound.

	process resume.
	self deny: process isSuspended.
	self deny: process isTerminating.
	self deny: process isTerminated.
	self deny: unwound.

	process terminate.
	self deny: process isSuspended.
	self assert: process isTerminating.
	self assert: process isTerminated.
	"The process never ran"
	self deny: started.
	"No unwind blocks were ever activated, so the next two lines can't be true."
	self deny: unwound.
	self deny: terminator identicalTo: process
]

{ #category : #'tests - termination' }
ProcessTest >> testIsTerminatingNormalTermination [
	| sem process unwound started terminator |
	sem := Semaphore new.
	unwound := false.
	started := false.
	process := [ started := true.
	[ sem wait ]
		ensure: [ terminator := Processor activeProcess.
			unwound := true ] ] fork.
	self deny: process isSuspended.
	self deny: process isTerminating.
	self deny: process isTerminated.
	self deny: started.
	self deny: unwound.

	sem signal.
	self waitForProcessTermination: process.
	"#terminate will be sent by the process itself after its context has finished (see BlockClosure>>newProcess)"
	self deny: process isSuspended.
	self assert: process isTerminating.
	self assert: process isTerminated.
	self assert: started.
	"When inside of an unwind context, that unwind context needs run through."
	self assert: unwound.
	"A process should terminte itself."
	self assert: terminator identicalTo: process
]

{ #category : #'tests - creation' }
ProcessTest >> testNewProcess [

	| hasBlockRun block return |
	hasBlockRun := false.
	block := [ hasBlockRun := true ].
	return := block newProcess.
	
	"Returns immediately"
	self deny: hasBlockRun.
	
	"Returns a process - Blue book specifies the block"
	self assert: (return isKindOf: Process).
	
	"Forked process has not been scheduled"
	self assert: return isSuspended.
]

{ #category : #'tests - creation' }
ProcessTest >> testNewProcessWith [

	| hasBlockRun block process passedArguments receivedArgument1 receivedArgument2 |
	hasBlockRun := false.
	block := [ :a :b |
		receivedArgument1 := a.
		receivedArgument2 := b.
		hasBlockRun := true ].
	passedArguments := #(1 2).
	process := block newProcessWith: passedArguments.
	
	"Returns immediately"
	self deny: hasBlockRun.
	
	self assert: (process isKindOf: Process).
	
	"Process has not been scheduled"
	self assert: process isSuspended.
	
	process resume.
	[process isTerminated] whileFalse: [ Processor yield ].
	
	"Each element in the collection argument was passed separately to the block"
	self assert: { receivedArgument1. receivedArgument2 } equals: passedArguments.
]

{ #category : #tests }
ProcessTest >> testNormalProcessCompletionWithLeftEffectiveProcess [
	
	| effectiveProcess activeProcess |
	effectiveProcess := [ 10 seconds wait ] forkAt: Processor activePriority + 1.
	activeProcess := [ Processor activeProcess suspend. ] forkAt: Processor activePriority + 1.
	activeProcess instVarNamed: #effectiveProcess put: effectiveProcess.
	
	activeProcess resume.
	
	self assert: activeProcess isTerminated.
	self deny: effectiveProcess isTerminated.
	effectiveProcess terminate
]

{ #category : #tests }
ProcessTest >> testNormalProcessWithArgsCompletionWithLeftEffectiveProcess [
	
	| effectiveProcess activeProcess |
	effectiveProcess := [ 10 seconds wait ] forkAt: Processor activePriority + 1.
	activeProcess := [:arg | Processor activeProcess suspend. ] newProcessWith: #(1).
	activeProcess 
		priority: Processor activePriority + 1; 
		resume.
	activeProcess instVarNamed: #effectiveProcess put: effectiveProcess.
	
	activeProcess resume.
	
	self assert: activeProcess isTerminated.
	self deny: effectiveProcess isTerminated.
	effectiveProcess terminate
]

{ #category : #tests }
ProcessTest >> testSchedulingHigherPriorityServedFirst [
    "The first process to run will pass straight through the gate
    while the other waits for the assert to whichRan."

	"Even though the low priority process is waiting longer, 
	the higher priority process should run first."

	| gate checkAssert whichRan |
	gate := Semaphore new signal. 
	checkAssert := Semaphore new.
	
	[ gate wait. whichRan := 11. checkAssert signal ] forkAt: 11.
	[ gate wait. whichRan := 12. checkAssert signal ] forkAt: 12.
	
	checkAssert wait.
	self assert: whichRan=12 description: 'Second scheduled but higher priority should run first'.	
	gate signal. 
	
	checkAssert wait.
	self assert: whichRan=11 description: 'First scheduled but lower priority should run after'.

]

{ #category : #tests }
ProcessTest >> testSchedulingSamePriorityFirstComeFirstServed [
    "The first process to run will pass straight through the gate
    while the other waits for the assert to whichRan."

	"At the same priority process, the longer waiting process should run first."

	| gate checkAssert whichRan |
	gate := Semaphore new signal. 
	checkAssert := Semaphore new.
		
	[ gate wait. whichRan := 1. checkAssert signal ] fork.
	[ gate wait. whichRan := 2. checkAssert signal ] fork.
	
	checkAssert wait.
	self assert: whichRan=1 description: 'First scheduled process should run first'.
	gate signal. 

	checkAssert wait.
	self assert: whichRan=2 description: 'Second scheduled process should run after'.
]

{ #category : #'tests - termination' }
ProcessTest >> testTerminateActive [

	| lastStatementEvaluated block1HasRun block2HasRun p1 p2 |
	block1HasRun := block2HasRun := lastStatementEvaluated := false.
	p1 := [
		block1HasRun := true.
		Processor activeProcess terminate.
		lastStatementEvaluated := true ] fork.
	
	p2 := [
		block2HasRun := true.
		Processor terminateActive.
		lastStatementEvaluated := true ] fork.
	
	[p1 isTerminated & p2 isTerminated] whileFalse: [ Processor yield ].
	
	"Expressions following terminate are never executed"
	self assert: block1HasRun.
	self assert: block2HasRun.
	self deny: lastStatementEvaluated.
]

{ #category : #'tests - termination' }
ProcessTest >> testTerminationShouldProceedAllEnsureBlocksIfSomeWasFailed [

	| ensureCalled process ensureFailure started unwindError |
	ensureFailure := Error new messageText: 'signalled inside ensure'.
	ensureCalled := false.
	started := false.
	process := [ 
		[ 
		[[started := true. 10 seconds wait] 
			ensure: [ ensureFailure signal ]]
				ensure: [ ensureCalled := true ].
		] on: UnwindError do: [ :err | unwindError := err ]
	] fork.
	[started] whileFalse: [ Processor yield ].
	process terminate.	
	Processor yield.
	self assert: ensureCalled.
	self assert: unwindError signalerContext sender exception equals: ensureFailure
]

{ #category : #'tests - termination' }
ProcessTest >> testTerminationShouldProceedEnsureBlocks [

	| ensureCalled process semaphore |
	ensureCalled := false.
	semaphore := Semaphore new.
	process := [ 
		[semaphore signal. [10 milliSeconds wait] repeat] ensure: [ ensureCalled := true ]
	] fork.
	semaphore wait.
	
	process terminate.
	self assert: ensureCalled
]

{ #category : #tests }
ProcessTest >> testYield [

	| lowerHasRun lowerPriority same1HasRun same2HasRun |
	lowerHasRun := same1HasRun := same2HasRun := false.
	lowerPriority := Processor activeProcess priority - 10 min: 10.
	[ lowerHasRun := true ] forkAt: lowerPriority.
	[ same1HasRun := true ] fork.
	[ same2HasRun := true ] fork.

	Processor yield.
	
	"All processes of same priority have been given a chance to execute"
	self assert: same1HasRun.
	self assert: same2HasRun.
	self deny: lowerHasRun.
]

{ #category : #helpers }
ProcessTest >> waitForProcessTermination: aProcess [
	aProcess priority: Processor activePriority + 1.
	[ aProcess isTerminated ] whileFalse: [ Processor yield ]
]
