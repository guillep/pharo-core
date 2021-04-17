"
SUnit tests for exceptions

Some of these tests are of the form:
`self assertSuccess: (ExceptionTester new runTest: <<<aSelector>>> )`
For example:
	The code of ExceptionTests>>#testDoubleOuterPass is `self assertSuccess: (ExceptionTester new runTest: #doubleOuterPassTest )`.
	In this example, <<<aSelector>>> = #doubleOuterPassTest.

Here is how these tests are performed:
- ExceptionTester has instance variables 'log' and 'suiteLog' of type OrderedCollection
- ExceptionTester>>#runTest: adds <<<aSelector>>> as a string to 'suiteLog' and clears 'log'
- ExceptionTester>>#runTest: performs the method named <<<aSelector>>>.
  <<<aSelector>>> has an exception-based control flow, and calls methods like #doSomething, #doSomethingElse etc... at some points of it. These methods just add specific strings to 'log' to build a sort of trace of where the execution went.
- If a MyTestError exception would leave method <<<aSelector>>> uncaught, it is caught, the incident is added to 'log', and <<<aSelector>>>'s execution is stopped
- After performing <<<aSelector>>>, ExceptionTester>>#runTest: performs its twin method: <<<aSelector>>>Results (In the example from above, it would be #doubleOuterPassTestResults). This twin method builds the expected value of 'log' by creating an OrderedCollection and filling it with the  right specific strings in the expected order.
- ExceptionTester>>#runTest: compares 'log' and the expected value of 'log'. If they are the same, it appends the 'succeeded' string to the '<<<aSelector>>>' string that was stored in 'suiteLog' earlier. If they are different, it appends the 'failed' string instead.
- Finally, ExceptionTests>>#assertSuccess: asserts that the first element of 'suiteLog' ends with the 'suceeded' string


"
Class {
	#name : #ExceptionTest,
	#superclass : #TestCase,
	#category : #'Kernel-Tests-Exception'
}

{ #category : #private }
ExceptionTest >> assertSuccess: anExceptionTester [
	self should: [ ( anExceptionTester suiteLog first) endsWith:  'succeeded'].
]

{ #category : #private }
ExceptionTest >> runCaseManaged [
	"We should disable TestEnvironment to avoid any logic for unhandled errors from background processes.
	Some tests fork processes to ensure clean no handlers (SUnit catches errors for example)"
	
	^DefaultExecutionEnvironment beActiveDuring: [ self runCase]
]

{ #category : #private }
ExceptionTest >> runWithNoHandlers: aBlock [
	"Executing the given block directly would go through all handlers of SUnit machinery.
	Here we simulate the clean environment with no outer handlers for possible block errors"
	| synchSemaphore result |
	synchSemaphore := Semaphore new. 
	[result := aBlock ensure: [synchSemaphore signal]] forkNamed: 'Test process'.
	"we should not wait forever in case of wrong behaviour 
	(general test timeout is disabled in #runCaseManaged)"
	(synchSemaphore wait: 2 seconds)
		ifTrue: [ self error: 'Timeout for block execution' ].
	^result
]

{ #category : #test }
ExceptionTest >> testDefaultAction [
	"Ensure that the resuming an UnhandledError when the underlying
	Exception is resumable, results in the resumption value serving
	as the result of the original #signal."

	| expected result |
	expected := #marker.
	self runWithNoHandlers: [ 
		[ result := MyResumableTestError signal ]
			on: UnhandledError
			do: [ :ex | ex resume: expected ] ].
	self assert: result equals: expected
]

{ #category : #test }
ExceptionTest >> testDefaultDescription [
   "Tests that the description of an Exception, is the defaultDescription"
   |anException|
	anException := Exception new.
	self assert: anException description equals: anException defaultDescription 
	
]

{ #category : #test }
ExceptionTest >> testDescription [
   |anException|
	anException := Exception new.
	self assert: anException description isNotNil.
	self assert: anException description isString.
	"If the default exception desciption changes, this test will be broken"
	self assert: anException description equals: 'Exception'
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testDoubleOuterPass [
	self assertSuccess: (ExceptionTester new runTest: #doubleOuterPassTest ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testDoublePassOuter [
	self assertSuccess: (ExceptionTester new runTest: #doublePassOuterTest ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testDoubleResume [
	self assertSuccess: (ExceptionTester new runTest: #doubleResumeTest ) 
]

{ #category : #'tests - handling' }
ExceptionTest >> testHandlerContext [
	"A test ensuring that when evaluating the action block the exception environment is set to the handler context."

	| result |
	result := [ 
	[ 
	[ MyResumableTestError signal ]
		on: MyTestError
		do: [ 'handler 2' ] ]
		on: MyResumableTestError
		do: [ MyTestError signal ] ]
		on: MyTestError
		do: [ 'handler 1' ].
	self assert: 'handler 1' = result description: 'Incorrect handler'
]

{ #category : #'tests - handling' }
ExceptionTest >> testHandlerFromAction [
	"A test ensuring that nested exceptions work as expected."

	| result |
	result := [ 
	[ 
	[ self error: 'trigger error' ]
		on: ZeroDivide
		do: [ :ex | 'inner' ] ]
		on: Error
		do: [ :ex | 3 / 0 ] ]
		on: ZeroDivide
		do: [ :ex | 'outer' ].
	self assert: 'outer' = result description: 'Incorrect handler'
]

{ #category : #'tests - handling' }
ExceptionTest >> testHandlingExceptionSetWithExclusion [

	| wasHandled  |

	wasHandled := false.

	self
		should: [ 
			[ ZeroDivide signalWithDividend: 1 ]
				on: Error, ArithmeticError - ZeroDivide
				do: [ :exception | 
					wasHandled := true.
					exception return ] ]
		raise: ZeroDivide.
	
	self deny: wasHandled
]

{ #category : #'tests - handling' }
ExceptionTest >> testHandlingWhenThereIsSomeExclusionButDontApplies [

	| wasHandled result |

	wasHandled := false.

	result := [ 
	ZeroDivide signalWithDividend: 1.
	2 ]
		on: Error - MessageNotUnderstood
		do: [ :exception | 
			wasHandled := true.
			exception return ].

	self
		assert: wasHandled;
		assert: result isNil
]

{ #category : #'tests - handling' }
ExceptionTest >> testHandlingWithExclusion [

	| wasHandled  |

	wasHandled := false.

	self
		should: [ 
			[ ZeroDivide signalWithDividend: 1 ]
				on: Error - ZeroDivide
				do: [ :exception | 
					wasHandled := true.
					exception return ] ]
		raise: ZeroDivide.
	
	self deny: wasHandled
]

{ #category : #'tests - handling' }
ExceptionTest >> testHandlingWithSeveralExclusions [
	| wasHandled |
	wasHandled := false.
	self
		should: [ 
			[ ZeroDivide signalWithDividend: 1 ]
				on: Error - Warning - ZeroDivide
				do: [ :exception | 
					wasHandled := true.
					exception return ] ]
		raise: ZeroDivide.
	self deny: wasHandled.
	
	self
		should: [ 
			[ ZeroDivide signalWithDividend: 1 ]
				on: Error - (Warning , ZeroDivide)
				do: [ :exception | 
					wasHandled := true.
					exception return ] ]
		raise: ZeroDivide.
	self deny: wasHandled.
]

{ #category : #'tests - handling' }
ExceptionTest >> testHandlingWithSeveralExclusionsAndExceptionSetsHandling [

	| wasHandled result |

	wasHandled := false.

	result := [ 
	ZeroDivide signalWithDividend: 1.
	2 ]
		on: Error - MessageNotUnderstood - Warning
		do: [ :exception | 
			wasHandled := true.
			exception return ].

	self
		assert: wasHandled;
		assert: result isNil.
		
	wasHandled := false.

	result := [ 
	ZeroDivide signalWithDividend: 1.
	2 ]
		on: Error - (MessageNotUnderstood , Warning)
		do: [ :exception | 
			wasHandled := true.
			exception return ].

	self
		assert: wasHandled;
		assert: result isNil.	
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testNoTimeout [
	self assertSuccess: (ExceptionTester new runTest: #simpleNoTimeoutTest ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testNonResumableFallOffTheEndHandler [
	self assertSuccess: (ExceptionTester new runTest: #nonResumableFallOffTheEndHandler ) 
]

{ #category : #'tests - outer' }
ExceptionTest >> testNonResumableOuter [

	self should: [
		[Error signal. 4] 
			on: Error 
			do: [:ex | ex outer. ex return: 5]
		] raise: Error

]

{ #category : #'tests - outer' }
ExceptionTest >> testNonResumablePass [

	self should: [
		[Error signal. 4] 
			on: Error 
			do: [:ex | ex pass. ex return: 5]
		] raise: Error

]

{ #category : #'tests - resignal' }
ExceptionTest >> testResignalAs [

	| answer |
	answer := [
		[3 zork]
			on: ZeroDivide
			do: [:ex | ex return: 5]
	] on: Error do: [:ex | ex resignalAs: ZeroDivide].
	self assert: answer == 5
]

{ #category : #'tests - resignal' }
ExceptionTest >> testResignalAsUnwinds [

	| unwound answer |
	unwound := false.
	answer := [
		[3 zork]
			on: ZeroDivide do: [:ex | self assert: unwound.  ex return: 5]
	] on: Error do: [:ex | [ex resignalAs: ZeroDivide] ifCurtailed: [unwound := true]].
	self assert: answer == 5
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testResumableFallOffTheEndHandler [
	self assertSuccess: (ExceptionTester new runTest: #resumableFallOffTheEndHandler ) 
]

{ #category : #'tests - outer' }
ExceptionTest >> testResumableOuter [

	| result |
	result := [Notification signal. 4] 
		on: Notification 
		do: [:ex | ex outer. ex return: 5].
	self assert: result equals: 5

]

{ #category : #'tests - outer' }
ExceptionTest >> testResumablePass [
	| result |
	result := [ Notification signal.
	4 ]
		on: Notification
		do: [ :ex | 
			ex pass.
			ex return: 5 ].
	self assert: result equals: 4
]

{ #category : #test }
ExceptionTest >> testResumeNonresumableUnhandledError [

	"Ensure that the resuming an UnhandledError results in
	an IllegalResumeAttempt."

	| signalOccurred |
	self
		runWithNoHandlers: [ 
			[[ MyTestError signal ]
				on: UnhandledError
				do: [ :ex | ex resume: nil ]]
			on: IllegalResumeAttempt
			do: [:ex | signalOccurred := true. ex return ]].
	self assert: signalOccurred
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSignalFromHandlerActionTest [
	self assertSuccess: (ExceptionTester new runTest: #signalFromHandlerActionTest ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSignalWithTag [
	| aTag |
	aTag := Object new.
	
	[ 
		DomainError signal: 'aMessage' withTag: aTag.
		self fail: 'The exception was not signaled'. 
	] on: DomainError do: [ :e | 
		self assert: e messageText equals: 'aMessage'.
		self assert: e tag equals: aTag.
	]
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSimpleEnsure [
	self assertSuccess: (ExceptionTester new runTest: #simpleEnsureTest ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSimpleEnsureTestWithError [
	self assertSuccess: (ExceptionTester new runTest: #simpleEnsureTestWithError ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSimpleEnsureTestWithNotification [
	self assertSuccess: (ExceptionTester new runTest: #simpleEnsureTestWithNotification ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSimpleEnsureTestWithUparrow [
	self assertSuccess: (ExceptionTester new runTest: #simpleEnsureTestWithUparrow ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSimpleIsNested [
	self assertSuccess: (ExceptionTester new runTest: #simpleIsNestedTest ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSimpleOuter [
	self assertSuccess: (ExceptionTester new runTest: #simpleOuterTest ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSimplePass [
	self assertSuccess: (ExceptionTester new runTest: #simplePassTest ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSimpleResignalAs [
	self assertSuccess: (ExceptionTester new runTest: #simpleResignalAsTest ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSimpleResume [
	self assertSuccess: (ExceptionTester new runTest: #simpleResumeTest ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testSimpleReturn [
	self assertSuccess: (ExceptionTester new runTest: #simpleReturnTest ) 
]

{ #category : #'tests - exceptiontester' }
ExceptionTest >> testTimeoutWithZeroDuration [
	self assertSuccess: (ExceptionTester new runTest: #simpleTimeoutWithZeroDurationTest ) 
]

{ #category : #'tests - handling' }
ExceptionTest >> testUnhandledErrorWhenHandlerPassesOriginalException [
	| executed |
	executed := false.
	self runWithNoHandlers: [
		[ 
			[ 1/0 ] on: UnhandledError do: [ :e | executed := true ]
		] on: ZeroDivide do: [:z | z pass].
	].
	self assert: executed
]

{ #category : #'tests - handling' }
ExceptionTest >> testUnhandledErrorWhenNoHandlers [
	| executed |
	executed := false.
	self runWithNoHandlers: [
		[ 1/0 ] on: UnhandledError do: [ :e | executed := true ]
	].
	self assert: executed
]

{ #category : #'tests - handling' }
ExceptionTest >> testUnhandledErrorWhenTwoHandlersPassOriginalException [
	| executed |
	executed := false.
	self runWithNoHandlers: [
		[ [  
				[ 1/0 ] on: UnhandledError do: [ :e | executed := true ]
			] on: ZeroDivide do: [:z | z pass]
		] on: ZeroDivide do: [:z | z pass]
	].
	self assert: executed
]

{ #category : #'tests - handling' }
ExceptionTest >> testUnhandledExceptionShouldAllowToCatchError [
	
	| error caughtException |
	error := Error new.
	self runWithNoHandlers: [ 
		[ error signal ] on: UnhandledException do: [ :err | caughtException := err ]
	].
	self assert: caughtException class equals: UnhandledError.
	self assert: caughtException exception equals: error
]

{ #category : #'tests - handling' }
ExceptionTest >> testUnhandledExceptionShouldAllowToCatchHalt [
	
	| halt caughtException |
	halt := Halt new.
	self runWithNoHandlers: [
		[ halt signal ] on: UnhandledException do: [ :err | caughtException := err ]
	].
	self assert: caughtException equals: halt
]

{ #category : #'tests - handling' }
ExceptionTest >> testUnhandledExceptionShouldAllowToCatchWarning [
	
	| warning caughtException |
	warning := Warning new.
	self runWithNoHandlers: [
		[ warning signal ] on: UnhandledException do: [ :err | caughtException := err ]
	].
	self assert: caughtException class equals: UnhandledError.
	self assert: caughtException exception equals: warning
]

{ #category : #'tests - handling' }
ExceptionTest >> testUnhandledWarningShouldBeProcessedAsUnhandledError [
	
	| warning caughtException |
	warning := Warning new.
	self runWithNoHandlers: [
		[ warning signal ] on: UnhandledError do: [ :err | caughtException := err ]
	].
	self assert: caughtException exception equals: warning
]
