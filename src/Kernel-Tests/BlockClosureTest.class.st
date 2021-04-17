"
SUnit tests for BlockClosure
"
Class {
	#name : #BlockClosureTest,
	#superclass : #TestCase,
	#instVars : [
		'aBlockContext',
		'contextOfaBlockContext'
	],
	#category : #'Kernel-Tests-Methods'
}

{ #category : #helpers }
BlockClosureTest >> blockWithNonLocalReturn: resultObject [
		
	^[ ^resultObject ] 
]

{ #category : #running }
BlockClosureTest >> setUp [
	super setUp.
	"we reference self to force a full block"
	aBlockContext := [self . 100@100 corner: 200@200].
	contextOfaBlockContext := thisContext.
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testCull [
	[  ] cull: 1.
	[ :x |  ] cull: 1.
	self should: [ [ :x :y |  ] cull: 1 ] raise: Error.
	self should: [ [ :x :y :z |  ] cull: 1 ] raise: Error.
	self should: [ [ :x :y :z :a |  ] cull: 1 ] raise: Error.
	self should: [ [ :x :y :z :a :b |  ] cull: 1 ] raise: Error.
	self assert: ([ 0 ] cull: 1) equals: 0.
	self assert: ([ :x | x ] cull: 1) equals: 1
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testCullCull [
	[  ] cull: 1 cull: 2.
	[ :x |  ] cull: 1 cull: 2.
	[ :x :y |  ] cull: 1 cull: 2.
	self should: [ [ :x :y :z |  ] cull: 1 cull: 2 ] raise: Error.
	self should: [ [ :x :y :z :a |  ] cull: 1 cull: 2 ] raise: Error.
	self should: [ [ :x :y :z :a :b |  ] cull: 1 cull: 2 ] raise: Error.
	self assert: ([ 0 ] cull: 1 cull: 2) equals: 0.
	self assert: ([ :x | x ] cull: 1 cull: 2) equals: 1.
	self assert: ([ :x :y | y ] cull: 1 cull: 2) equals: 2
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testCullCullCull [
	[  ] cull: 1 cull: 2 cull: 3.
	[ :x |  ] cull: 1 cull: 2 cull: 3.
	[ :x :y |  ] cull: 1 cull: 2 cull: 3.
	[ :x :y :z |  ] cull: 1 cull: 2 cull: 3.
	self should: [ [ :x :y :z :a |  ] cull: 1 cull: 2 cull: 3 ] raise: Error.
	self should: [ [ :x :y :z :a :b |  ] cull: 1 cull: 2 cull: 3 ] raise: Error.
	self assert: ([ 0 ] cull: 1 cull: 2 cull: 3) equals: 0.
	self assert: ([ :x | x ] cull: 1 cull: 2 cull: 3) equals: 1.
	self assert: ([ :x :y | y ] cull: 1 cull: 2 cull: 3) equals: 2.
	self assert: ([ :x :y :z | z ] cull: 1 cull: 2 cull: 3) equals: 3
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testCullCullCullCull [
	[  ]
		cull: 1
		cull: 2
		cull: 3
		cull: 4.
	[ :x |  ]
		cull: 1
		cull: 2
		cull: 3
		cull: 4.
	[ :x :y |  ]
		cull: 1
		cull: 2
		cull: 3
		cull: 4.
	[ :x :y :z |  ]
		cull: 1
		cull: 2
		cull: 3
		cull: 4.
	[ :x :y :z :a |  ]
		cull: 1
		cull: 2
		cull: 3
		cull: 4.
	self
		should: [ [ :x :y :z :a :b |  ]
				cull: 1
				cull: 2
				cull: 3
				cull: 4 ]
		raise: Error.
	self
		assert:
			([ 0 ]
				cull: 1
				cull: 2
				cull: 3
				cull: 4)
		equals: 0.
	self
		assert:
			([ :x | x ]
				cull: 1
				cull: 2
				cull: 3
				cull: 4)
		equals: 1.
	self
		assert:
			([ :x :y | y ]
				cull: 1
				cull: 2
				cull: 3
				cull: 4)
		equals: 2.
	self
		assert:
			([ :x :y :z | z ]
				cull: 1
				cull: 2
				cull: 3
				cull: 4)
		equals: 3.
	self
		assert:
			([ :x :y :z :a | a ]
				cull: 1
				cull: 2
				cull: 3
				cull: 4)
		equals: 4
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testHasMethodReturn [

	self assert: [ ^self  ] hasMethodReturn.
	self deny: [ 1 + 2 ] hasMethodReturn.
	self deny: [ self printString ] hasMethodReturn.
	
	"nested blocks"
	self assert: [ 1 > 2 ifTrue: [ ^self ] ] hasMethodReturn.
	self assert: [ #(1) do: [ ^self ] ] hasMethodReturn
]

{ #category : #'test -testing' }
BlockClosureTest >> testIsClean [
	| local |
	local := #testIsClean.
	self assert: [] isClean. "closes over nothing at all"
	self assert: [thisContext] isClean. "we can access the context"
	self assert: [:a :b| a < b] isClean. "accesses only arguments"
	self assert: [:a :b| | s | s := a + b. s even] isClean. "accesses only local variables"
	self deny: [^nil] isClean. "closes over home (^-return)"
	self deny: [self] isClean. "closes over the receiver"
	self deny: [super testIsClean] isClean. "closes over the receiver"
	self deny: [contextOfaBlockContext] isClean. "closes over the receiver (to access the inst var contextOfaBlockContext)"
	self deny: [local] isClean. "closes over local variable of outer context"
]

{ #category : #tests }
BlockClosureTest >> testNew [
	self	should: [Context new: 5] raise: Error.
	[Context new: 5]
		onErrorDo: [:error | self assert: error description equals: 'Error: Contexts must only be created with newForMethod:'].
	[Context new]
		onErrorDo: [:error | self assert: error description equals: 'Error: Contexts must only be created with newForMethod:'].	
	[Context basicNew]
		onErrorDo: [:error | self assert: error description equals: 'Error: Contexts must only be created with newForMethod:'].

]

{ #category : #tests }
BlockClosureTest >> testNoArguments [
	| block1 block2 |
	"avoid compile error in GemStone"
	block1 := [ :arg | 1 + 2 ].
	block2 := [ :arg1 :arg2 | 1 + 2 ].
	[ 10 timesRepeat: block1 ] onErrorDo: [ :err | self assert: err description equals: 'ArgumentsCountMismatch: This block accepts 1 argument, but was called with 0 arguments.' ].
	[ 10 timesRepeat: block2 ] onErrorDo: [ :err | self assert: err description equals: 'ArgumentsCountMismatch: This block accepts 2 arguments, but was called with 0 arguments.' ]
]

{ #category : #tests }
BlockClosureTest >> testOnErrorDo [

	self assert: ([1 foo ] onErrorDo: [:err | 'huh?']) equals: 'huh?'
]

{ #category : #'tests - on-fork' }
BlockClosureTest >> testOnFork [
	"Test that if code runs without errors, there is no fork! "

	| result1 result2 |
	result2 := nil.
	result1 := [ 1 ] on: Exception fork: [ result2 := 2 ].

	Processor yield.

	self assert: result1 equals: 1.
	self assert: result2 isNil
]

{ #category : #'tests - on-fork' }
BlockClosureTest >> testOnForkErrorExecutesBlock [
	"Test that if code runs with error, there is fork"

	| result sema |
	sema := Semaphore new.
	result := nil.
	[ 1 / 0 ]
		on: Exception
		fork: [ result := 2.
			sema signal ].

	sema wait.
	"and of course result should be not nil "
	self assert: result equals: 2
]

{ #category : #'tests - on-fork' }
BlockClosureTest >> testOnForkErrorOnSeparateProcess [
	"Test that if code runs with error, there is fork"

	| forkedProc sema |
	sema := Semaphore new.
	[ 1 / 0 ] on: Exception fork: [ 
		forkedProc := Processor activeProcess.
		sema signal ].

	sema wait.
	self deny: forkedProc identicalTo: Processor activeProcess
]

{ #category : #'tests - on-fork' }
BlockClosureTest >> testOnForkErrorReturnsNil [
	"Test that if code runs with error, there is fork"
	
	| result sema |
	
	sema := Semaphore new.	
	result := [ 1/0 ] on: Exception fork: [ sema signal. ].
	
	sema wait.
	"in case of error, evaluation result should be nil"
	self assert: result isNil.
]

{ #category : #'tests - on-fork' }
BlockClosureTest >> testOnForkErrorTakesLessThanOneSecond [
	"Test that if code runs with error, there is fork"

	| sema timeout |
	self
		flag: 'This test is too brittle, failing often on Windows CI';
		skip.

	self flag: 'The following line makes the test pass under headless linux. Everywhere else this test works'.
	Smalltalk os isUnix ifTrue: [ 1 milliSecond wait ].

	sema := Semaphore new.
	[ 1 / 0 ] on: Exception fork: [ sema signal ].

	timeout := sema waitTimeoutSeconds: 1.
	self assert: timeout identicalTo: false
]

{ #category : #'tests - on-fork' }
BlockClosureTest >> testOnForkSplit [
	"Test that when forking, the stack are split correctly (there is no any contexts referenced by both processes)"
	
	| sema timeout forkedContexts myContexts c |
	
	self flag: 'This test is too brittle, failing often on CI'; skip.
		
	sema := Semaphore new.
	
	[ 1/0 ] on: Exception fork: [  | ctx |
		forkedContexts := IdentitySet new.
		ctx := thisContext.
		[ ctx notNil ] whileTrue: [ forkedContexts add: ctx. ctx := ctx sender ].
		sema signal ].
	
	timeout := (sema waitTimeoutSeconds: 1).
	self assert: timeout == false description: 'fork lasted more than one second'.

	myContexts := IdentitySet new.
	c := thisContext.
	[ c notNil ] whileTrue: [ myContexts add: c. c := c sender ].

	self assert: (myContexts noneSatisfy: [:b | forkedContexts includes: b ]) description: 'myContexts are not within forkedContexts'.
	self assert: (forkedContexts noneSatisfy: [:b | myContexts includes: b ]) description: 'forkedContexts are not within myContexts'.
]

{ #category : #tests }
BlockClosureTest >> testOneArgument [
	| c |
	c := OrderedCollection new.
	c add: 'hello'.
	[ c do: [ 1 + 2 ] ] onErrorDo: [ :err | self assert: err description equals: 'ArgumentsCountMismatch: This block accepts 0 arguments, but was called with 1 argument.' ].
	[ c do: [ :arg1 :arg2 | 1 + 2 ] ] onErrorDo: [ :err | self assert: err description equals: 'ArgumentsCountMismatch: This block accepts 2 arguments, but was called with 1 argument.' ]
]

{ #category : #'tests - printing' }
BlockClosureTest >> testPrintOn [
	self assert: (RBParser parseExpression: [ 1 + 2 ] printString) equals: (RBParser parseExpression: '[ 1 + 2 ]')
]

{ #category : #'tests - printing' }
BlockClosureTest >> testPrintOnBlockDefinedInMethodWithoutSourceCode [
	| method copy start block |
	"Generating method with source code"
	UndefinedObject compile: 'method ^ [ 1 + 2 ]'.
	method := UndefinedObject >> #method.
	["Removing the source code of method"
		copy := method copyWithTrailerBytes: CompiledMethodTrailer new.
		start := method endPC + 1.
		method replaceFrom: start to: method size with: copy startingAt: start.
		block := nil method.
		
		self deny: method hasSourceCode.
		self assert: (RBParser parseExpression: block printString) equals: (RBParser parseExpression: '[ 1 + 2 ]').
	] ensure: [ method removeFromSystem ]
]

{ #category : #tests }
BlockClosureTest >> testSetUp [
	"Note: In addition to verifying that the setUp worked the way it was expected to, testSetUp is used to illustrate the meaning of the simple access methods, methods that are not normally otherwise 'tested'"

	self assert: aBlockContext home equals: contextOfaBlockContext.
	self assert: aBlockContext receiver equals: self.
	"Depending on the closure implementation, it's either a compiled block, a compiled method or nil."
	self assert: (aBlockContext method isNil or: [ aBlockContext method isKindOf: CompiledCode ])
]

{ #category : #tests }
BlockClosureTest >> testSupplyAnswerOfFillInTheBlank [
	self
		assert:
			([ UIManager default request: 'Your favorite color?' ]
				valueSupplyingAnswer: #('Your favorite color?' 'blue'))
		equals: 'blue'
]

{ #category : #tests }
BlockClosureTest >> testSupplyAnswerOfFillInTheBlankUsingDefaultAnswer [
	self
		assert:
			([ UIManager default
				request: 'Your favorite color?'
				initialAnswer: 'red' ]
				valueSupplyingAnswer: #('Your favorite color?' #default))
		equals: 'red'
]

{ #category : #tests }
BlockClosureTest >> testSupplyAnswerThroughNestedBlocks [

	self should: [true = ([[self confirm: 'You like Smalltalk?'] 
		valueSupplyingAnswer: #('Blub' false)] valueSupplyingAnswer: #('Smalltalk' true))]
]

{ #category : #tests }
BlockClosureTest >> testSupplyAnswerUsingOnlySubstringOfQuestion [

	self should: [false = ([self confirm: 'You like Smalltalk?'] 
		valueSupplyingAnswer: #('like' false))]
]

{ #category : #tests }
BlockClosureTest >> testSupplyAnswerUsingRegexMatchOfQuestion [

	(String includesSelector: #matchesRegex:) ifFalse: [^ self].
	
	self should: [true = ([self confirm: 'You like Smalltalk?'] 
		valueSupplyingAnswer: #('.*Smalltalk\?' true))]
]

{ #category : #tests }
BlockClosureTest >> testSupplyAnswerUsingTraditionalMatchOfQuestion [

	self should: [true = ([self confirm: 'You like Smalltalk?'] 
		valueSupplyingAnswer: #('*Smalltalk#' true))]
]

{ #category : #tests }
BlockClosureTest >> testSupplySameAnswerToAllQuestions [

	self should: [true = ([self confirm: 'You like Smalltalk?'] valueSupplyingAnswer: true)].
	
	self should: [#(true true) = ([{self confirm: 'One'. self confirm: 'Two'}] valueSupplyingAnswer: true)].
]

{ #category : #tests }
BlockClosureTest >> testSupplySeveralAnswersToSeveralQuestions [

	self should: [#(false true) = ([{self confirm: 'One'. self confirm: 'Two'}] 
		valueSupplyingAnswers: #( ('One' false) ('Two' true) ))].
	
	self should: [#(true false) = ([{self confirm: 'One'. self confirm: 'Two'}] 
		valueSupplyingAnswers: #( ('One' true) ('Two' false) ))]
]

{ #category : #tests }
BlockClosureTest >> testSupplySpecificAnswerToQuestion [

	self should: [false = ([self confirm: 'You like Smalltalk?'] 
		valueSupplyingAnswer: #('You like Smalltalk?' false))]
]

{ #category : #tests }
BlockClosureTest >> testSuppressInform [

	self should: [[nil inform: 'Should not see this message or this test failed!'] valueSuppressingAllMessages isNil]
]

{ #category : #tests }
BlockClosureTest >> testSuppressInformUsingStringMatchOptions [

	self should: [([nil inform: 'Should not see this message or this test failed!'] valueSuppressingMessages: #('Should not see this message or this test failed!')) isNil].
	
	self should: [([nil inform: 'Should not see this message or this test failed!'] valueSuppressingMessages: #('not see this message')) isNil].
	
	self should: [([nil inform: 'Should not see this message or this test failed!'] valueSuppressingMessages: #('*message*failed#')) isNil].

]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueWithArguments [

	self shouldnt: [ aBlockContext valueWithArguments: #() ] raise: ArgumentsCountMismatch.

	self should: [ aBlockContext valueWithArguments: #(1) ] raise: ArgumentsCountMismatch 
		withExceptionDo: [ :err | 
			self assert: err expectedArgumentsCount equals: 0.
			self assert: err calledArgumentsCount equals: 1 ].
		
	self should: [ [ :i | 3 + 4 ] valueWithArguments: #(1 2) ] raise: ArgumentsCountMismatch 
		withExceptionDo: [ :err | 
			self assert: err expectedArgumentsCount equals: 1.
			self assert: err calledArgumentsCount equals: 2 ].

]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueWithArgumentsWithOrderedCollection [

	self 
		shouldnt: [ aBlockContext valueWithArguments: #() asOrderedCollection ] 
		raise: ArgumentsCountMismatch.

	self 
		should: [ aBlockContext valueWithArguments: #(1) asOrderedCollection ] 
		raise: ArgumentsCountMismatch 
		withExceptionDo: [ :err | 
			self assert: err expectedArgumentsCount equals: 0.
			self assert: err calledArgumentsCount equals: 1 ].
		
	self 
		should: [ [ :i | 3 + 4 ] valueWithArguments: #(1 2) asOrderedCollection ] 
		raise: ArgumentsCountMismatch 
		withExceptionDo: [ :err | 
			self assert: err expectedArgumentsCount equals: 1.
			self assert: err calledArgumentsCount equals: 2 ].

]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueWithExit [
	self assert: [:exit | 1 ] valueWithExit equals: 1
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueWithExitBreak [
	| val |
	[ :break | 
	1 to: 10 do: [ :i | 
		val := i.
		i = 4 ifTrue: [ break value ] ] ] valueWithExit.

	self assert: val equals: 4
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueWithExitContinue [
	| val last |
	val := 0.

	1 to: 10 do: [ :i | 
		[ :continue | 
		i = 4 ifTrue: [ continue value ].
		val := val + 1.
		last := i ] valueWithExit ].

	self assert: val equals: 9.
	self assert: last equals: 10
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueWithPossibleArgs [
	| block blockWithArg blockWith2Arg |
	block := [ 1 ].
	blockWithArg := [ :arg | arg ].
	blockWith2Arg := [ :arg1 :arg2 | {arg1 . arg2} ].
	self assert: (block valueWithPossibleArgs: #()) equals: 1.
	self assert: (block valueWithPossibleArgs: #(1)) equals: 1.
	self assert: (blockWithArg valueWithPossibleArgs: #()) isNil.
	self assert: (blockWithArg valueWithPossibleArgs: #(1)) equals: 1.
	self assert: (blockWithArg valueWithPossibleArgs: #(1 2)) equals: 1.
	self assert: (blockWith2Arg valueWithPossibleArgs: #()) equals: {nil . nil}.
	self assert: (blockWith2Arg valueWithPossibleArgs: #(1)) equals: {1 . nil}.
	self assert: (blockWith2Arg valueWithPossibleArgs: #(1 2)) equals: #(1 2).
	self assert: (blockWith2Arg valueWithPossibleArgs: #(1 2 3)) equals: #(1 2)
]

{ #category : #'tests - evaluating' }
BlockClosureTest >> testValueWithPossibleArgument [
	| block blockWithArg blockWith2Arg |
	block := [ 1 ].
	blockWithArg := [ :arg | arg ].
	blockWith2Arg := [ :arg1 :arg2 | {arg1 . arg2} ].

	self assert: (block valueWithPossibleArgument: 1) equals: 1.

	self assert: (blockWithArg valueWithPossibleArgument: 1) equals: 1.

	self assert: (blockWith2Arg valueWithPossibleArgument: 1) equals: {1 . nil}
]
