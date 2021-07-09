"
I contain a sequence of operations. I am defined by Smalltalk expressions inside square brackets. I permit to defer the enclosed operations until I execute a variant of #value. I can have my own arguments and temporaries as a regular method, but I am also able to use external variables: my enclosing method or block temporaries, arguments and receiver.

examples :
[ 1 + 2 ] value
[ :arg | 
	| temp | 
	temp := arg. 
	temp ] value: 5
[ ^ 5 ] value

My return value corresponds to my final expression. A non local return (^) has the same effect as if I did not exist: it returns from my enclosing method, even if I'm nested in other blocks. 

Implementation:

Instance variables:
	outerContext <Context|nil> context that defined me
	startpc: <SmallInteger> (pc = program counter) offset of my first bytecode instruction in the compiledMethod bytecode  
	numArgs: <SmallInteger> my number of arguments

I am created at runtime through a special bytecode:
closureNumCopied: x numArgs: y bytes z1 to z2
On creation, the currently executed context is set to my outerContext, z1 is set as my startpc and y is set as my numArgs. After my creation, the current execution flow jumps to my last bytecode, z2, to skip the execution of my bytecode which is deferred until I execute a variant of #value.

I am executed when I receive a variant of the message value. This message creates a new context, a block context <MethodContext>, which reference me in its variable closureOrNil. This new context executes my bytecode, which correspond to a subset of the bytecode of my enclosing method, starting at startpc and ending in blockReturn/return bytecode.

Accessing variables of the my enclosing context is different depending on variables because of various optimizations:
- self: I access the receiver of my enclosing method by accessing my context's receiver, which is always set to the enclosing method receiver.
- copied variables: If I read a variable from an outerContext but I don't write into it and the variable is not modified after the BlockClosure creation, then the variable is copied in the blockClosure to be more efficient. 
- full variable: If I access and edit a variable from an outerContext, then the variable is stored in an external heap allocated array (named tempVector). The tempVector is known by the method and the block so they can both read and write these variables.

Optimized block closures: 
Common blocks (2/3 of the blocks) are optimized directly in the compiler and have special behaviors. These blocks are the arguments/receiver of control structures: #ifNil:, #ifNotNil:, #ifTrue:, #ifFalse:, #whileTrue:, #whileFalse:, #to:do:, #to:by:do: .

"
Class {
	#name : #BlockClosure,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'outerContext',
		'startpc',
		'numArgs'
	],
	#category : #'Kernel-Methods'
}

{ #category : #'instance creation' }
BlockClosure class >> outerContext: aContext startpc: aStartpc numArgs: argCount copiedValues: anArrayOrNil [
	^(self new: anArrayOrNil basicSize)
		outerContext: aContext
		startpc: aStartpc
		numArgs: argCount
		copiedValues: anArrayOrNil
]

{ #category : #accessing }
BlockClosure >> argumentCount [
	"Answer the number of arguments that must be used to evaluate this block"

	^numArgs
	

]

{ #category : #accessing }
BlockClosure >> argumentNames [
	^ self sourceNode argumentNames
]

{ #category : #scheduling }
BlockClosure >> asContext [
	"Create a MethodContext that is ready to execute self.  Assumes self takes no args (if it does the args will be nil)"

	^self asContextWithSender: nil
]

{ #category : #private }
BlockClosure >> asContextWithSender: aContext [
	"Inner private support method for evaluation.  Do not use unless you know what you're doing."

	^(Context newForMethod: outerContext compiledCode)
		setSender: aContext
		receiver: outerContext receiver
		method: outerContext compiledCode
		closure: self
		startpc: startpc;
		privRefresh
]

{ #category : #private }
BlockClosure >> asMinimalRepresentation [
	"Answer the receiver."

	^self
]

{ #category : #exceptions }
BlockClosure >> assert [

	self value ifFalse: [AssertionFailure signal: 'Assertion failed']

]

{ #category : #exceptions }
BlockClosure >> assertWithDescription: aStringOrABlock [
	| value |
	self value
		ifTrue: [ ^ self ].
	value := aStringOrABlock value.
	AssertionFailure signal: value
]

{ #category : #scanning }
BlockClosure >> blockCreationBytecodeMessage [
	"Answer the abstract bytecode message that created the receiver."
	^self method encoderClass blockCreationBytecodeMessageAt: startpc method: self method

	"(SortedCollection sortBlock: [:a :b| a compare: b caseSensitive: false]) sortBlock blockCreationBytecodeMessage"
]

{ #category : #private }
BlockClosure >> clearTemporariesOn: aContext [

	" I do nothing in the non-full blocks"
]

{ #category : #accessing }
BlockClosure >> copiedValueAt: i [
	<primitive: 60>
	^self basicAt: i
]

{ #category : #private }
BlockClosure >> copyForSaving [
	"Answer a copy of the receiver suitable for serialization.
	 Notionally, if the receiver's outerContext has been returned from then nothing
	 needs to be done and we can use the receiver. But there's a race condition
	 determining if the receiver has been returned from (it could be executing in a
	 different process). So answer a copy anyway."
	^self shallowCopy postCopy
]

{ #category : #evaluating }
BlockClosure >> cull: anArg [
	"Execute the receiver with one or zero arguments depending on the receiver"
	"([ 12 ] cull: 13)>>> 12 "
	"([:x | x + 12] cull: 3)>>> 15"
	^numArgs = 0 
		ifTrue: [self value]
		ifFalse: [self value: anArg]
	
]

{ #category : #evaluating }
BlockClosure >> cull: firstArg cull: secondArg [
	"Execute the receiver with one or two arguments depending on the receiver"
	"([:x | x + 1] cull: 13 cull: 12) >>> 14
	"
	"([:x :y | x + y] cull: 3 cull: 2) >>> 5
	"
	^numArgs < 2 
		ifTrue: [self cull: firstArg]
		ifFalse: [self value: firstArg value: secondArg]
	
]

{ #category : #evaluating }
BlockClosure >> cull: firstArg cull: secondArg cull: thirdArg [
	^numArgs < 3 
		ifTrue: [self cull: firstArg cull: secondArg]
		ifFalse: [self value: firstArg value: secondArg value: thirdArg]
	
]

{ #category : #evaluating }
BlockClosure >> cull: firstArg cull: secondArg cull: thirdArg cull: fourthArg [
	"Execute the receiver with four or less arguments. Check cull:cull: for examples"
	
	^numArgs < 4 
		ifTrue: [self cull: firstArg cull: secondArg cull: thirdArg]
		ifFalse: [self value: firstArg value: secondArg value: thirdArg value: fourthArg]
	
]

{ #category : #printing }
BlockClosure >> doPrintOn: aStream [
	aStream nextPutAll: self sourceNode sourceCode 
]

{ #category : #controlling }
BlockClosure >> doWhileFalse: conditionBlock [
	"Evaluate the receiver once, then again as long the value of conditionBlock is false."
 
	| result |
	[result := self value.
	conditionBlock value] whileFalse.

	^ result
]

{ #category : #controlling }
BlockClosure >> doWhileTrue: conditionBlock [
	"Evaluate the receiver once, then again as long the value of conditionBlock is true."
 
	| result |
	[result := self value.
	conditionBlock value] whileTrue.

	^ result
]

{ #category : #evaluating }
BlockClosure >> durationToRun [
	"Answer the duration taken to execute this block."

	^ self timeToRun




]

{ #category : #accessing }
BlockClosure >> endPC [
	^self blockCreationBytecodeMessage arguments last + startpc - 1
]

{ #category : #exceptions }
BlockClosure >> ensure: aBlock [
	"Evaluate a termination block after evaluating the receiver, regardless of
	 whether the receiver's evaluation completes.  N.B.  This method is *not*
	 implemented as a primitive.  Primitive 198 always fails.  The VM uses prim
	 198 in a context's method as the mark for an ensure:/ifCurtailed: activation."

	| complete returnValue |
	<primitive: 198>
	returnValue := self valueNoContextSwitch.
	complete ifNil:[
		complete := true.
		aBlock value.
	].
	^ returnValue
]

{ #category : #scheduling }
BlockClosure >> fork [
	"Create and schedule a Process running the code in the receiver."

	^ self newProcess resume
]

{ #category : #scheduling }
BlockClosure >> forkAndWait [
	"Suspend current process and execute self in new process, when it completes resume current process"

	| semaphore |
	semaphore := Semaphore new.
	[self ensure: [semaphore signal]] fork.
	semaphore wait.

]

{ #category : #scheduling }
BlockClosure >> forkAt: priority [ 
	"Create and schedule a Process running the code in the receiver at the given priority. Answer the newly created process."

	^ self newProcess
		priority: priority;
		resume
]

{ #category : #scheduling }
BlockClosure >> forkAt: priority named: name [

	"Create and schedule a Process running the code in the receiver at the

	given priority and having the given name. Answer the newly created 

	process."



	| forkedProcess |

	forkedProcess := self newProcess.

	forkedProcess priority: priority.

	forkedProcess name: name.

	^ forkedProcess resume
]

{ #category : #scheduling }
BlockClosure >> forkNamed: aString [

	"Create and schedule a Process running the code in the receiver and

	having the given name."



	^ self newProcess name: aString; resume
]

{ #category : #testing }
BlockClosure >> hasMethodReturn [
	"Answer whether the receiver has a method-return ('^') in its code."
	| scanner endpc |
	scanner := InstructionStream new method: outerContext compiledCode pc: startpc.
	endpc := self endPC.
	scanner scanFor: [:byte | (outerContext compiledCode encoderClass methodReturnBytecodes includes: byte) or: [scanner pc > endpc]].
	^scanner pc <= endpc
]

{ #category : #accessing }
BlockClosure >> home [
	^outerContext home
]

{ #category : #exceptions }
BlockClosure >> ifCurtailed: aBlock [
	"Evaluate the receiver with an abnormal termination action.
	 Evaluate aBlock only if execution is unwound during execution
	 of the receiver.  If execution of the receiver finishes normally do
	 not evaluate aBlock.  N.B.  This method is *not* implemented as a
	 primitive.  Primitive 198 always fails.  The VM uses prim 198 in a
	 context's method as the mark for an ensure:/ifCurtailed: activation."
	| complete result |
	<primitive: 198>
	result := self valueNoContextSwitch.
	complete := true.
	^result
]

{ #category : #private }
BlockClosure >> initialStackPointer [

	^ self numArgs + self numCopiedValues
]

{ #category : #accessing }
BlockClosure >> isBlock [

	^ true
]

{ #category : #testing }
BlockClosure >> isClean [
	"Answer if the receiver does not close-over any variables other than globals, and does
	 not ^-return (does not close over the home context).  Clean blocks are amenable to
	 being created at compile-time."
	self numCopiedValues > 0 ifTrue:
		[^false].

	^ CleanBlockChecker check: self method
]

{ #category : #testing }
BlockClosure >> isClosure [
	^true
]

{ #category : #testing }
BlockClosure >> isDead [
	"Has self finished"
	^false
]

{ #category : #testing }
BlockClosure >> isFullBlock [

	^ false
]

{ #category : #private }
BlockClosure >> isValid [
	"Answer the receiver."

	^true
]

{ #category : #accessing }
BlockClosure >> method [
	^outerContext compiledCode
]

{ #category : #scheduling }
BlockClosure >> newProcess [
	"Answer a Process running the code in the receiver. The process is not 
	scheduled.
	IMPORTANT! Debug stepping this deep infrastructure may lock your Image
  	If you are not sure what you are doing, close the debugger now."
	<primitive: 19> "Simulation guard"
	^Process
		forContext: 
			[self value.
			"IMPORTANT: Do not step over next line of code. See method comments for details"
			Processor terminateRealActive] asContext
		priority: Processor activePriority
]

{ #category : #scheduling }
BlockClosure >> newProcessWith: anArray [ 
	"Answer a Process running the code in the receiver. The receiver's block 
	arguments are bound to the contents of the argument, anArray. The 
	process is not scheduled."
	<primitive: 19> "Simulation guard"
	^Process
		forContext: 
			[self valueWithArguments: anArray.
			"IMPORTANT: Do not step over next line of code. See method comments for details"
			Processor terminateRealActive] asContext
		priority: Processor activePriority
]

{ #category : #accessing }
BlockClosure >> numArgs [
	"Answer the number of arguments that must be used to evaluate this block"

	^numArgs
]

{ #category : #'error handling' }
BlockClosure >> numArgsError: numArgsForInvocation [

	ArgumentsCountMismatch signalExpectedArgumentsCount: numArgs calledArgumentsCount: numArgsForInvocation 
]

{ #category : #accessing }
BlockClosure >> numCopiedValues [
	"Answer the number of copied values of the receiver.  Since these are
	 stored in the receiver's indexable fields this is the receiver's basic size.
	 Primitive. Answer the number of indexable variables in the receiver. 
	 This value is the same as the largest legal subscript."

	<primitive: 62>
	^self basicSize
]

{ #category : #accessing }
BlockClosure >> numLocalTemps [
	"Answer the number of local temporaries for the receiver"
	^ self method encoderClass numLocalTempsForBlockAt: startpc in: outerContext compiledCode
]

{ #category : #accessing }
BlockClosure >> numTemps [
	"Answer the number of temporaries for the receiver; this includes
	 the number of arguments and the number of copied values."
	^self numCopiedValues
	 + self numArgs
	 + self numLocalTemps
]

{ #category : #exceptions }
BlockClosure >> on: exception do: handlerAction [
	"Evaluate the receiver in the scope of an exception handler.
	The following primitive is just a marker used to find the error handling context. 
	See MethodContext>>#isHandlerOrSignalingContext. "
	<primitive: 199>  
	^ self value
]

{ #category : #exceptions }
BlockClosure >> on: exception fork: handlerAction [
	"Activate the receiver. In case of exception, fork a new process, which will handle an error.
	An original process will continue running as if receiver evaluation finished and answered nil,
	i.e., an expression like:
	
	[ self error: 'some error'] on: Error fork: [:ex |  123 ] 
	
	will always answer nil for original process, not 123.

	The context stack , starting from context which sent this message to receiver and
	up to the top of the stack will be transferred to forked process, with handlerAction on top.
	(so when the forked process will be resuming, it will enter the handlerAction)
	 "

	^ self
		  on: exception
		  do: [ :ex | 
			  | onDoCtx handler bottom thisCtx |
			  onDoCtx := thisContext.
			  thisCtx := onDoCtx home.

			  "find the context on stack for which this method's is sender"

			  [ onDoCtx sender == thisCtx ] whileFalse: [ 
				  onDoCtx := onDoCtx sender.
				  onDoCtx ifNil: [ "Can't find our home context. seems like we're already forked
				and handling another exception in new thread. In this case, just pass it through handler." 
					  ^ handlerAction cull: ex ] ].

			  bottom := [ Processor terminateRealActive ] asContext.
			  onDoCtx privSender: bottom.

			  handler := [ handlerAction cull: ex ] asContext.
			  handler privSender: thisContext sender.

			  (Process forContext: handler priority: Processor activePriority) resume.

			  "cut the stack of current process"
			  thisContext privSender: thisCtx.
			  nil ]
]

{ #category : #exceptions }
BlockClosure >> on: exception fork: handlerAction return: answerAction [
	"This is the same as #on:fork: but instead just fork and letting the flow continues, in 
	 case of an error it also evaluates answerAction and returns its result."
		
	^ self on: exception do: [:ex |
		| onDoCtx handler bottom thisCtx |
		
		onDoCtx := thisContext.
		thisCtx := onDoCtx home.

		"find the context on stack for which this method's is sender"

		[ onDoCtx sender == thisCtx] whileFalse: [ 
			onDoCtx := onDoCtx sender.
			onDoCtx ifNil: [ 
				"Can't find our home context. seems like we're already forked
				and handling another exception in new thread. In this case, just pass it through handler."
				^ handlerAction cull: ex ] ].

		bottom := [ Processor terminateRealActive ] asContext.
		onDoCtx privSender: bottom.

		handler := [ handlerAction cull: ex ] asContext.
		handler privSender: thisContext sender.

		(Process forContext: handler priority: Processor activePriority) resume.

		"cut the stack of current process"
		thisContext privSender: thisCtx.
		answerAction cull: exception ]

]

{ #category : #exceptions }
BlockClosure >> onDNU: selector do: handleBlock [
	"Catch MessageNotUnderstood exceptions but only those of the given selector (DNU stands for doesNotUnderstand:)"

	^ self on: MessageNotUnderstood do: [:exception |
		exception message selector = selector
			ifTrue: [handleBlock cull: exception]
			ifFalse: [exception pass]
	  ]
]

{ #category : #evaluating }
BlockClosure >> onErrorDo: errorHandlerBlock [
	"Evaluate the block represented by the receiver, and normally return it's value.  If an error occurs, the errorHandlerBlock is evaluated, and it's value is instead returned.  The errorHandlerBlock must accept zero or one parameter (the error object)."
	"Examples:
		[1 whatsUpDoc] onErrorDo: [:err | 'huh?'].
		[1 / 0] onErrorDo: [:err |
			ZeroDivide = err class
				ifTrue: [Float infinity]
				ifFalse: [self error: err]]
"

	^ self on: Error do: [:ex | errorHandlerBlock cull: ex]
]

{ #category : #accessing }
BlockClosure >> outerContext [
	^outerContext
]

{ #category : #initialization }
BlockClosure >> outerContext: aContext startpc: aStartpc numArgs: argCount copiedValues: anArrayOrNil [
	outerContext := aContext.
	startpc := aStartpc.
	numArgs := argCount.
	1 to: self numCopiedValues do:
		[:i|
		self at: i put: (anArrayOrNil at: i)]
]

{ #category : #printing }
BlockClosure >> printOn: aStream [
		
	[self doPrintOn: aStream] 
		onErrorDo: [ aStream 
				nextPutAll: '<Error printing blockClosure in: ';
				print: self method;
				nextPutAll: ' >' ]
]

{ #category : #accessing }
BlockClosure >> receiver [
	^outerContext receiver
]

{ #category : #private }
BlockClosure >> reentrant [
	"Answer a version of the recever that can be reentered.
	 Closures are reentrant (unlike BlockContect) so simply answer self."
	^self
]

{ #category : #controlling }
BlockClosure >> repeat [
	"Evaluate the receiver repeatedly, ending only if the block explicitly returns."

	[self value. true] whileTrue
]

{ #category : #controlling }
BlockClosure >> repeatWithGCIf: testBlock [
	| ans |
	"run the receiver, and if testBlock returns true, garbage collect and run the receiver again"
	ans := self value.
	(testBlock value: ans) ifTrue: [ Smalltalk garbageCollect. ans := self value ].
	^ans
]

{ #category : #evaluating }
BlockClosure >> rfvalueNoContextSwitch [
	"same as valueNoContextSwitch, for recursion stopping metalinks"
	<primitive: 221>
	<metaLinkOptions: #( + optionDisabledLink)>
	numArgs ~= 0 ifTrue:
		[self numArgsError: 0].
	self primitiveFailed
]

{ #category : #'debugger access' }
BlockClosure >> sender [
	"Answer the context that sent the message that created the receiver."

	^outerContext sender
]

{ #category : #evaluating }
BlockClosure >> simulateValueWithArguments: anArray caller: aContext [
	"Simulate the valueWithArguments: primitive. Fail if anArray is not an array of the right arity."
	| newContext sz |
	newContext := (Context newForMethod: outerContext compiledCode)
						setSender: aContext
						receiver: outerContext receiver
						method: outerContext compiledCode
						closure: self
						startpc: startpc.
	((newContext objectClass: anArray) ~~ Array
	 or: [numArgs ~= anArray size]) ifTrue:
		[^Context primitiveFailTokenFor: nil].
	sz := self basicSize.
	newContext stackp: sz + numArgs.
	1 to: numArgs do:
		[:i| newContext at: i put: (anArray at: i)].
	1 to: sz do:
		[:i| newContext at: i + numArgs put: (self at: i)].
	^newContext
]

{ #category : #accessing }
BlockClosure >> startpc [
	^startpc
]

{ #category : #accessing }
BlockClosure >> startpcOrOuterCode [
	^ startpc 
]

{ #category : #accessing }
BlockClosure >> tempNames [
	^ self sourceNode temporaryNames

]

{ #category : #evaluating }
BlockClosure >> value [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this message.
	 Supply the copied values to the activation as its arguments and copied temps.
	 Primitive. Optional (but you're going to want this for performance)."
	<primitive: 201>
	numArgs ~= 0 ifTrue:
		[self numArgsError: 0].
	^self primitiveFailed
]

{ #category : #evaluating }
BlockClosure >> value: anArg [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this message.
	 Supply the argument and copied values to the activation as its arguments and copied temps.
	 Primitive. Optional (but you're going to want this for performance)."	 
	<primitive: 202>
	numArgs ~= 1 ifTrue:
		[self numArgsError: 1].
	self primitiveFailed
]

{ #category : #evaluating }
BlockClosure >> value: firstArg value: secondArg [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this message.
	 Supply the arguments and copied values to the activation as its arguments and copied temps.
	 Primitive. Optional (but you're going to want this for performance)."
	<primitive: 203>
	numArgs ~= 2 ifTrue:
		[self numArgsError: 2].
	^self primitiveFailed
]

{ #category : #evaluating }
BlockClosure >> value: firstArg value: secondArg value: thirdArg [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this message.
	 Supply the arguments and copied values to the activation as its arguments and copied temps.
	 Primitive. Optional (but you're going to want this for performance)."
	<primitive: 204>
	numArgs ~= 3 ifTrue:
		[self numArgsError: 3].
	^self primitiveFailed
]

{ #category : #evaluating }
BlockClosure >> value: firstArg value: secondArg value: thirdArg value: fourthArg [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this message.
	 Supply the arguments and copied values to the activation as its arguments and copied temps.
	 Primitive. Optional (but you're going to want this for performance)."
	<primitive: 205>
	numArgs ~= 4 ifTrue:
		[self numArgsError: 4].
	^self primitiveFailed
]

{ #category : #evaluating }
BlockClosure >> valueAfterWaiting: aDelay [
	"Waits for a delay, then executes the block. Answers the process so you can terminate it"
	
	^ [ aDelay wait. self value ] 
		forkAt: Processor userBackgroundPriority
		named: (String streamContents: [ :s |
				s 
					<< 'After ';
					print: aDelay;
					<<' do: ';
					print: self ] )
]

{ #category : #evaluating }
BlockClosure >> valueAt: blockPriority [ 
	"Evaluate the receiver (block), with another priority as the actual one 
	and restore it afterwards. The caller should be careful with using 
	higher priorities."
	| activeProcess result outsidePriority |
	activeProcess := Processor activeProcess.
	outsidePriority := activeProcess priority.
	activeProcess priority: blockPriority.
	result := self ensure: [activeProcess priority: outsidePriority].
	"Yield after restoring lower priority to give the preempted processes a  
	chance to run."
	blockPriority > outsidePriority
		ifTrue: [Processor yield].
	^ result
]

{ #category : #evaluating }
BlockClosure >> valueNoContextSwitch [
	"An exact copy of BlockClosure>>value except that this version will not preempt
	 the current process on block activation if a higher-priority process is runnable.
	 Primitive. Essential."
	<primitive: 221>
	numArgs ~= 0 ifTrue:
		[self numArgsError: 0].
	self primitiveFailed
]

{ #category : #evaluating }
BlockClosure >> valueNoContextSwitch: anArg [
	"An exact copy of BlockClosure>>value: except that this version will not preempt
	 the current process on block activation if a higher-priority process is runnable.
	 Primitive. Essential."
	<primitive: 222>
	numArgs ~= 1 ifTrue:
		[self numArgsError: 1].
	self primitiveFailed
]

{ #category : #evaluating }
BlockClosure >> valueSupplyingAnswer: anObject [
	^ (anObject isCollection and: [anObject isString not])
		ifTrue: [self valueSupplyingAnswers: {anObject}]
		ifFalse: [self valueSupplyingAnswers: {{'*'. anObject}}]
]

{ #category : #evaluating }
BlockClosure >> valueSupplyingAnswers: aListOfPairs [
	"evaluate the block using a list of questions / answers that might be called upon to
	automatically respond to Object>>confirm: or FillInTheBlank requests"

	^ self
		on: ProvideAnswerNotification
		do: [ :notify | 
			| caption |
			caption := notify messageText withSeparatorsCompacted.	"to remove new lines"
			aListOfPairs
				detect: [ :each | 
					caption = each first
						or: [ (caption includesSubstring: each first caseSensitive: false)
								or: [ (each first match: caption)
										or: [ (String includesSelector: #matchesRegex:)
												and: [ [ caption matchesRegex: each first ]
														on: Error
														do: [ :ignored | false ] ] ] ] ] ]
				ifFound: [ :answer | notify resume: answer second ]
				ifNone: [ | outerAnswer |
					outerAnswer := ProvideAnswerNotification
						signal: notify messageText.
					outerAnswer
						ifNil: [ notify resume ]
						ifNotNil: [ notify resume: outerAnswer ] ] ]
]

{ #category : #evaluating }
BlockClosure >> valueSuppressingAllMessages [

	^ self valueSuppressingMessages: #('*')
]

{ #category : #evaluating }
BlockClosure >> valueSuppressingMessages: aListOfStrings [

	^ self
		valueSuppressingMessages: aListOfStrings
		supplyingAnswers: #()
]

{ #category : #evaluating }
BlockClosure >> valueSuppressingMessages: aListOfStrings supplyingAnswers: aListOfPairs [

	^ self valueSupplyingAnswers: aListOfPairs, (aListOfStrings collect: [:each | {each . true}])
]

{ #category : #exceptions }
BlockClosure >> valueUninterruptably [
	"Prevent remote returns from escaping the sender.  Even attempts to terminate (unwind) this process will be halted and the process will resume here.  A terminate message is needed for every one of these in the sender chain to get the entire process unwound."

	^ self ifCurtailed: [^ self]
]

{ #category : #private }
BlockClosure >> valueUnpreemptively [
	"Evaluate the receiver (block), without the possibility of preemption by higher priority processes. Use this facility VERY sparingly!"
	"Think about using Block>>valueUninterruptably first, and think about using Semaphore>>critical: before that, and think about redesigning your application even before that! 
	After you've done all that thinking, go right ahead and use it..."
	| activeProcess oldPriority result semaphore |
	activeProcess := Processor activeProcess.
	oldPriority := activeProcess priority.
	activeProcess priority: Processor highestPriority.
	result := self ensure: [activeProcess priority: oldPriority].
	
	"Yield after restoring priority to give the preempted processes a chance to run.
	We inline the code of Processor yield here, but without the primitive.
	The reason: the yield primitive does not take into account a change of priority as done above" 
	semaphore := Semaphore new.
	[semaphore signal] fork.
	semaphore wait.
	^result
]

{ #category : #evaluating }
BlockClosure >> valueWithArguments: anArray [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this message.
	 Supply the arguments in an anArray and copied values to the activation as its arguments and copied temps.
	 Primitive. Optional (but you're going to want this for performance)."
	| newContext ncv |
	<primitive: 206>
	numArgs ~= anArray size ifTrue:
		[self numArgsError: anArray size].
	newContext := self asContextWithSender: thisContext sender.
	ncv := self numCopiedValues.
	newContext stackp: ncv + numArgs.
	1 to: numArgs do:
		[:i| newContext at: i put: (anArray at: i)].
	1 to: ncv do:
		[:i| newContext at: i + numArgs put: (self at: i)].
	thisContext privSender: newContext
]

{ #category : #evaluating }
BlockClosure >> valueWithEnoughArguments: anArray [
	"call me with enough arguments from anArray"
	| args |
	(anArray size == self numArgs)
		ifTrue: [ ^self valueWithArguments: anArray ].

	args := Array new: self numArgs.
	args replaceFrom: 1
		to: (anArray size min: args size)
		with: anArray
		startingAt: 1.

	^ self valueWithArguments: args
]

{ #category : #evaluating }
BlockClosure >> valueWithExit [

	^ self value: [ ^ nil ]
]

{ #category : #evaluating }
BlockClosure >> valueWithInterval: aDelay [
	"Executes the block every x milliseconds specified in arguments. Answers the process, so you can terminate it"
	
	^ [ [ self value. aDelay wait. ] repeat ] 
		forkAt: Processor userBackgroundPriority 
		named: (String streamContents: [ :s |
				s 
					<< 'every ';
					print: aDelay;
					<<' do: ';
					print: self ] )
]

{ #category : #evaluating }
BlockClosure >> valueWithPossibleArgs: anArray [ 
	"Execute the receiver with the correct number of arguments taken from the argument."
	"([:x | x + 1] valueWithPossibleArgs: #( 13 12 15)) >>> 14
	"
	"([:x :y | x + y] valueWithPossibleArgs: #( 13 12 15)) >>> 25
	"
	"([:x :y :z | x + y + z] valueWithPossibleArgs: #( 13 12 15)) >>> 40
	"
	"([:x :y :z | x + y + z] valueWithPossibleArgs: #( 13 12 15)) >>> 40
	"
	^numArgs = 0
		ifTrue: [self value]
		ifFalse:
			[self valueWithArguments:
				(numArgs = anArray size
					ifTrue: [anArray]
					ifFalse:
						[numArgs > anArray size
							ifTrue: [anArray, (Array new: numArgs - anArray size)]
							ifFalse: [anArray copyFrom: 1 to: numArgs]])]
]

{ #category : #evaluating }
BlockClosure >> valueWithPossibleArgument: anArg [ 
	"Evaluate the block represented by the receiver. 
	 If the block requires one argument, use anArg, if it requires more than one,
	 fill up the rest with nils."

	| a |
	numArgs = 0 ifTrue: [^self value].
	numArgs = 1 ifTrue: [^self value: anArg].
	a := Array new: numArgs.
	a at: 1 put: anArg.
	^self valueWithArguments: a
]

{ #category : #evaluating }
BlockClosure >> valueWithin: aDuration onTimeout: timeoutBlock [
	"Evaluate the receiver.
	If the evaluation does not complete in less than aDuration evaluate the timeoutBlock instead"
	<debuggerCompleteToSender>
	| theProcess delay watchdog tag |

	aDuration <= Duration zero ifTrue: [^ timeoutBlock value ].

	"the block will be executed in the current process"
	theProcess := Processor activeProcess.
	delay := aDuration asDelay.
	tag := self.

	"make a watchdog process"
	watchdog := [
		delay wait. 	"wait for timeout or completion"
		theProcess ifNotNil:[ theProcess signalException: (TimedOut new tag: tag)] 
	] newProcess.

	"Watchdog needs to run at high priority to do its job (but not at timing priority)"
	watchdog priority: Processor timingPriority-1.

	"catch the timeout signal"
	^ [	watchdog resume.				"start up the watchdog"
		self ensure:[						"evaluate the receiver"
			theProcess := nil.				"it has completed, so ..."
			delay delaySemaphore signal.	"arrange for the watchdog to exit"
		]] on: TimedOut do: [ :e | 
			e tag == tag 
				ifTrue:[ timeoutBlock value ]
				ifFalse:[ e pass]].
]

{ #category : #controlling }
BlockClosure >> whileFalse [
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the receiver, as long as its value is false."
 
	self value ifFalse: [ self whileFalse ]
]

{ #category : #controlling }
BlockClosure >> whileFalse: aBlock [ 
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the argument, aBlock, as long as the value of the receiver is false."

	self value ifFalse: [ aBlock value. self whileFalse: aBlock ].
	^ nil
]

{ #category : #controlling }
BlockClosure >> whileNil: aBlock [ 
	"Unlike #whileTrue/False: this is not compiled inline."
	^ [self value isNil] whileTrue: [aBlock value]
	
]

{ #category : #controlling }
BlockClosure >> whileNotNil: aBlock [ 
	"Unlike #whileTrue/False: this is not compiled inline."
	^ [self value notNil] whileTrue: [aBlock value]
	
]

{ #category : #controlling }
BlockClosure >> whileTrue [
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the receiver, as long as its value is true."
 
	self value ifTrue: [ self whileTrue ]
]

{ #category : #controlling }
BlockClosure >> whileTrue: aBlock [ 
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the argument, aBlock, as long as the value of the receiver is true."

	self value ifTrue: [ aBlock value. self whileTrue: aBlock ].
	^ nil
]
