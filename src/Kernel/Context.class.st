"
Instance variables:
	receiver: <Object> (self)
	closureOrNil: <BlockClosure|nil> 
		nil if I'm a method context
		the blockClosure being executed if I'm a block context
	method <CompiledMethod> 
		method being executed if I'm a method context
		method holding the block if I'm a block context
	variable fields: <Object> temporary variables (including arguments)

My instances hold all the dynamic state associated with the execution of either a method activation resulting from a message send or a block activation resulting from a block evaluation.
	
MethodContexts, though normal in their variable size, are actually only used in two sizes, small and large, which are determined by the temporary space required by the method being executed.

MethodContexts must only be created using the method newForMethod:.  Note that it is impossible to determine the real object size of a MethodContext except by asking for the frameSize of its method.  Any fields above the stack pointer (stackp) are truly invisible -- even (and especially!) to the garbage collector.  Any store into stackp other than by the primitive method stackp: is potentially fatal.
"
Class {
	#name : #Context,
	#superclass : #InstructionStream,
	#type : #variable,
	#instVars : [
		'stackp',
		'method',
		'closureOrNil',
		'receiver'
	],
	#classVars : [
		'PrimitiveFailToken',
		'SpecialPrimitiveSimulators',
		'TryNamedPrimitiveTemplateMethod'
	],
	#category : #'Kernel-Methods'
}

{ #category : #enumerating }
Context class >> allInstances [
	"Answer all instances of the receiver."
	<primitive: 177>
	"The primitive can fail because memory is low.  If so, fall back on the old
	 enumeration code, which gives the system a chance to GC and/or grow.
	 Because aBlock might change the class of inst (for example, using become:),
	 it is essential to compute next before aBlock value: inst.
	 Only count until thisContext since this context has been created only to
	 compute the existing instances."
	| inst insts next |
	insts := WriteStream on: (Array new: 64).
	inst := self someInstance.
	[inst == thisContext or: [inst == nil]] whileFalse:
		[next := inst nextInstance.
		 insts nextPut: inst.
		 inst := next].
	^insts contents
]

{ #category : #hacks }
Context class >> allInstancesDo: aBlock [
	"Evaluate aBlock with each of the current instances of the receiver."
	| instances inst next |
	instances := self allInstancesOrNil.
	instances ifNotNil:
		[instances do: aBlock.
		 ^self].
	"allInstancesOrNil can fail because memory is low.  If so, fall back on the old
	 enumeration code.  Because aBlock might change the class of inst (for example,
	 using become:), it is essential to compute next before aBlock value: inst.
	 Only count until thisContext since evaluation of aBlock will create new contexts."
	inst := self someInstance.
	[inst == thisContext or: [inst == nil]] whileFalse:
		[next := inst nextInstance.
		 aBlock value: inst.
		 inst := next]
]

{ #category : #'instance creation' }
Context class >> basicNew: size [
	self error: 'Contexts must only be created with newForMethod:'
]

{ #category : #private }
Context class >> carefullyPrint: anObject on: aStream [
	aStream nextPutAll: ([anObject printString]
		on: Error
		do: ['unprintable ' , anObject class name])
]

{ #category : #'special context creation' }
Context class >> contextEnsure: block [
	"Create an #ensure: context that is ready to return from executing its receiver"

	| ctxt chain |
	ctxt := thisContext.
	[chain := thisContext sender cut: ctxt. 
		
		"As the jump will return to the current context inside the context ensure:
		It is needed to emulate the return value of sending the message ensure:
		If this is not done, the context will do an additional pop, affecting the temporary variables. 
		This is required because we are breaking a condition on Context >> jump.
		The receiver of jump should be a Top context, in this case it is not. "
		ctxt push: nil. 
		ctxt jump] ensure: block.
	"jump above will resume here without unwinding chain"
	^ chain
]

{ #category : #'special context creation' }
Context class >> contextOn: exceptionClass do: block [
	"Create an #on:do: context that is ready to return from executing its receiver"

	| ctxt chain |
	ctxt := thisContext.
	[chain := thisContext sender cut: ctxt. 
	
		"As the jump will return to the current context inside the context on:do:
		It is needed to emulate the return value of sending the message on:do:
		If this is not done, the context will do an additional pop, affecting the temporary variables. 
		This is required because we are breaking a condition on Context >> jump.
		The receiver of jump should be a Top context, in this case it is not. "
		ctxt push:nil. 
		ctxt jump] on: exceptionClass do: block.
	"jump above will resume here without unwinding chain"
	^ chain
]

{ #category : #simulation }
Context class >> initialize [

	"A unique object to be returned when a primitive fails during simulation"
	PrimitiveFailToken := Object new.
	self initializeTryNamedPrimitiveTemplateMethod.
	SpecialPrimitiveSimulators := nil
]

{ #category : #simulation }
Context class >> initializePrimitiveSimulators [
	"extra primitive simulators can be registered by implementing
	#registerPrimitiveSimulators method in class side of your class."
	<ignoreUnimplementedCalls: #(#registerPrimitiveSimulators)>
	
	SpecialPrimitiveSimulators := Dictionary new.

	Class allSubclassesDo: [:metaclass |
		(metaclass includesSelector: #registerPrimitiveSimulators) ifTrue: [
			metaclass instanceSide registerPrimitiveSimulators.
			]
		].
]

{ #category : #simulation }
Context class >> initializeTryNamedPrimitiveTemplateMethod [
	| source method |
	source := 'tryNamedPrimitive
	"This method is a template that the Smalltalk simulator uses to 
	execute primitives. See Object documentation whatIsAPrimitive."
	<primitive:'' module:'' error: errorCode>
	^ Context primitiveFailTokenFor: errorCode'.
	method := Smalltalk compiler
				class: UndefinedObject;
				source: source;
				compile.
	TryNamedPrimitiveTemplateMethod := method copyWithSource: source.



	
]

{ #category : #testing }
Context class >> isContextClass [
	^true
]

{ #category : #'instance creation' }
Context class >> new [

	self error: 'Contexts must only be created with newForMethod:'
]

{ #category : #'instance creation' }
Context class >> new: size [

	self error: 'Contexts must only be created with newForMethod:'
]

{ #category : #'instance creation' }
Context class >> newForMethod: aMethod [
	"This is the only method for creating new contexts, other than primitive cloning.
	Any other attempts, such as inherited methods like shallowCopy, should be
	avoided or must at least be rewritten to determine the proper size from the
	method being activated.  This is because asking a context its size (even basicSize!)
	will not return the real object size but only the number of fields currently
	accessible, as determined by stackp."

	^ super basicNew: aMethod frameSize
]

{ #category : #simulation }
Context class >> primitiveFailToken [

	^ self primitiveFailTokenFor: nil
]

{ #category : #simulation }
Context class >> primitiveFailTokenFor: errorCode [

	^ { PrimitiveFailToken. errorCode }

]

{ #category : #'instance creation' }
Context class >> sender: s receiver: r method: m arguments: args [ 
	"Answer an instance of me with attributes set to the arguments."

	^(self newForMethod: m) setSender: s receiver: r method: m arguments: args
]

{ #category : #accessing }
Context class >> specialPrimitiveSimulators [
	SpecialPrimitiveSimulators ifNil: [ self initializePrimitiveSimulators ].
	^ SpecialPrimitiveSimulators
]

{ #category : #'special context creation' }
Context class >> theReturnMethod [

	| meth |
	meth := self lookupSelector: #return:.
	meth isPrimitive ifTrue: [^ self error: 'expected #return: to not be a primitive'].
	^ meth
]

{ #category : #accessing }
Context class >> tryNamedPrimitiveTemplateMethod [
	^ TryNamedPrimitiveTemplateMethod
]

{ #category : #private }
Context >> aboutToReturn: result through: firstUnwindContext [ 
	"Called from VM when an unwindBlock is found between self and its home.
	 Return to home's sender, executing unwind blocks on the way."

	self methodReturnContext return: result through: firstUnwindContext
]

{ #category : #controlling }
Context >> activateMethod: newMethod withArgs: args receiver: rcvr class: class [ 
	"Answer a Context initialized with the arguments."

	^Context 
		sender: self
		receiver: rcvr
		method: newMethod
		arguments: args
]

{ #category : #private }
Context >> activateReturn: aContext value: value [
	"Activate 'aContext return: value' in place of self, so execution will return to aContext's sender"

	^ self
		activateMethod: Context theReturnMethod
		withArgs: {value}
		receiver: aContext
		class: aContext class
]

{ #category : #accessing }
Context >> activeHome [
	"If executing closure, search senders for the activation of the original
	 (outermost) method that (indirectly) created my closure (the closureHome).
	 If the closureHome is not found on the sender chain answer nil."

	| methodReturnContext |
	self isBlockContext ifFalse: [^self].
	self sender ifNil: [^nil].
	methodReturnContext := self methodReturnContext.
	^self sender findContextSuchThat: [:ctxt | ctxt = methodReturnContext]
]

{ #category : #accessing }
Context >> activeOuterContext [
	"If executing closure, search senders for the activation in which the receiver's
	 closure was created (the receiver's outerContext).  If the outerContext is not
	 found on the sender chain answer nil."

	| outerContext |
	self isBlockContext ifFalse: [^self].
	self sender ifNil: [^nil].
	outerContext := self outerContext.
	^self sender findContextSuchThat: [:ctxt | ctxt = outerContext]
]

{ #category : #accessing }
Context >> arguments [
	"returns the arguments of a message invocation"
	
	| arguments numargs |
	numargs :=  self compiledCode numArgs.
	arguments := Array new: numargs.
	1 to: numargs do: [ :i | arguments at: i put: (self tempAt: i) ].
	^ arguments
]

{ #category : #'closure support' }
Context >> asContext [

	^ self
]

{ #category : #accessing }
Context >> at: index [
	"Primitive. Assumes receiver is indexable. Answer the value of an
	 indexable element in the receiver. Fail if the argument index is not an
	 Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 210>
	index isInteger ifTrue:
		[self errorSubscriptBounds: index].
	index isNumber
		ifTrue: [^self at: index asInteger]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
Context >> at: index put: value [
	"Primitive. Assumes receiver is indexable. Answer the value of an
	 indexable element in the receiver. Fail if the argument index is not
	 an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 211>
	index isInteger ifTrue:
		[self errorSubscriptBounds: index].
	index isNumber
		ifTrue: [^self at: index asInteger put: value]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #accessing }
Context >> basicAt: index [
	"Primitive. Assumes receiver is indexable. Answer the value of an
	 indexable element in the receiver. Fail if the argument index is not an
	 Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 210>
	index isInteger ifTrue:
		[self errorSubscriptBounds: index].
	self errorNonIntegerIndex
]

{ #category : #accessing }
Context >> basicAt: index put: value [
	"Primitive. Assumes receiver is indexable. Answer the value of an
	 indexable element in the receiver. Fail if the argument index is not
	 an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 211>
	index isInteger ifTrue:
		[self errorSubscriptBounds: index].
	self errorNonIntegerIndex
]

{ #category : #accessing }
Context >> basicSize [
	"Primitive. Answer the number of indexable variables in the receiver. 
	This value is the same as the largest legal subscript. Essential. Do not 
	override in any subclass. See Object documentation whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 212>
	"The number of indexable fields of fixed-length objects is 0"
	^self primitiveFail
]

{ #category : #'instruction decoding' }
Context >> blockReturnConstant: value [ 
	"Simulate the interpreter's action when a ReturnConstantToCaller
	bytecode is 
	encountered in the receiver. This should only happen in a closure
	activation. "
	self assert: closureOrNil isClosure.
	^ self return: value from: self

]

{ #category : #'instruction decoding' }
Context >> blockReturnTop [
	"Simulate the interpreter's action when a ReturnTopOfStackToCaller bytecode is 
	 encountered in the receiver.  This should only happen in a closure activation."
	[closureOrNil isClosure] assert.
	^self return: self pop from: self
]

{ #category : #query }
Context >> bottomContext [
	"Return the last context (the first context invoked) in my sender chain"

	^ self findContextSuchThat: [ :context | context sender isNil]
]

{ #category : #'private - exceptions' }
Context >> canHandleSignal: exception [
	"Sent to handler (on:do:) contexts only.  If my exception class (first arg) handles exception then return true, otherwise forward this message to the next handler context.  If none left, return false (see nil>>canHandleSignal:)"

	^ (self exceptionClass handles: exception)
		or: [ self nextHandlerContext canHandleSignal: exception ].

]

{ #category : #'private - exceptions' }
Context >> cannotReturn: result [

	closureOrNil ifNotNil: [ 
		^ BlockCannotReturn result: result from: self home ].
	UIManager default
		requestDebuggerOpeningNamed: 'computation has been terminated'
		inContext: thisContext
]

{ #category : #private }
Context >> cannotReturn: result to: aContext [
	"The receiver tried to return result to homeContext that no longer exists."

	^ ContextCannotReturn result: result to: aContext
]

{ #category : #accessing }
Context >> client [
	"Answer the client, that is, the object that sent the message that created this context."

	^sender receiver
]

{ #category : #accessing }
Context >> closure [
	^closureOrNil
]

{ #category : #controlling }
Context >> closureCopy: numArgs copiedValues: anArray [
	"Distinguish a block of code from its enclosing method by 
	creating a BlockClosure for that block. The compiler inserts into all 
	methods that contain blocks the bytecodes to send the message 
	closureCopy:copiedValues:. Do not use closureCopy:copiedValues: in code that you write! Only the 
	compiler can decide to send the message closureCopy:copiedValues:. Fail if numArgs is 
	not a SmallInteger. Optional. No Lookup. See Object documentation 
	whatIsAPrimitive."

	<primitive: 200>
	^BlockClosure 
		outerContext: self
		startpc: pc + 2
		numArgs: numArgs
		copiedValues: anArray
]

{ #category : #accessing }
Context >> compiledCode [

	^method
]

{ #category : #accessing }
Context >> contextClass [
"The context class of a message send should be the one of the method to be evaluated, because if that method has some super sends, the method lookup won't work as expected'"

	^self compiledCode methodClass
]

{ #category : #'debugger access' }
Context >> contextStack [ 
	"Answer an Array of the contexts on the receiver's sender chain."

	^self stackOfSize: 100000
]

{ #category : #'closure support' }
Context >> contextTag [
	"Context tags may be used for referring to contexts instead of contexts themselves as they can be copied and will continue to work in other processes (continuations). By default, we use the context itself to as its tag."
	^self
]

{ #category : #query }
Context >> copyStack [

	^ self copyTo: nil
]

{ #category : #query }
Context >> copyTo: aContext [
	"Copy self and my sender chain down to, but not including, aContext.  End of copied chain will have nil sender."

	| copy |
	self == aContext ifTrue: [^ nil].
	self pc. "this is a workaround, see https://github.com/pharo-project/pharo/issues/2949"
	copy := self copy.
	self sender ifNotNil: [
		copy privSender: (self sender copyTo: aContext)].
	^ copy
]

{ #category : #private }
Context >> cut: aContext [
	"Cut aContext and its senders from my sender chain"

	| context callee |
	context := self.
	[ context == aContext ] whileFalse: [
		callee := context.
		context := context sender.
		context ifNil: [
			aContext ifNotNil: [
				self error: 'aContext not a sender' ]]].
	callee privSender: nil.

]

{ #category : #printing }
Context >> debugStack: stackSize on: aStream [
	"print a condensed version of the stack up to stackSize on aStream"

	(self stackOfSize: stackSize)
		do: [ :item | 
			item printDebugOn: aStream.
			aStream cr ]
]

{ #category : #printing }
Context >> debugStackOn: aStream [
	"print the top ten contexts on my sender chain."
	^ self debugStack: 100 on: aStream
]

{ #category : #'debugger access' }
Context >> depthBelow: aContext [
	"Answer how many calls there are between this and aContext."

	| context depth |
	context := self.
	depth := 0.
	[ context == aContext or: [ context == nil ]]
		whileFalse: [
			context := context sender.
			depth := depth + 1 ].
	^ depth
]

{ #category : #'instruction decoding' }
Context >> directedSuperSend: selector numArgs: numArgs [ 
	
	| lookupClass arguments currentReceiver |

	lookupClass := self pop superclass.
	
	arguments := Array new: numArgs.
	numArgs to: 1 by: -1 do: [ :i | 
		arguments at: i put: self pop ].

	currentReceiver := self pop.
	
	^ self send: selector to: currentReceiver with: arguments lookupIn: lookupClass
]

{ #category : #'instruction decoding' }
Context >> doDup [
	"Simulate the action of a 'duplicate top of stack' bytecode."

	self push: self top
]

{ #category : #'instruction decoding' }
Context >> doNop [

	"do nothing"
]

{ #category : #'instruction decoding' }
Context >> doPop [
	"Simulate the action of a 'remove top of stack' bytecode."

	self pop
]

{ #category : #private }
Context >> doPrimitive: primitiveIndex method: meth receiver: aReceiver args: arguments [ 
	"Simulate a primitive method whose index is primitiveIndex.  The simulated receiver and
	 arguments are given as arguments to this message. If successful, push result and return
	 resuming context, else ^ {errCode, PrimitiveFailToken}. Any primitive which provokes
	 execution needs to be intercepted and simulated to avoid execution running away."

	| value |
	"Judicious use of primitive 19 (a null primitive that doesn't do anything) prevents
	 the debugger from entering various run-away activities such as spawning a new
	 process, etc.  Injudicious use results in the debugger not being able to debug
	 interesting code, such as the debugger itself.  hence use primitive 19 with care :-)"
	"SystemNavigation new browseAllSelect: [:m| m primitive = 19]"
	"primitiveIndex = 19 ifTrue:	[ | debugSession | 
			debugSession := Processor activeProcess newDebugSessionNamed: 'Code simulation error' startedAt: self.
			Smalltalk tools debugger openOn: debugSession withFullView: true]."

	((primitiveIndex between: 201 and: 222)
	 and: [(self objectClass: aReceiver) includesBehavior: BlockClosure]) ifTrue:
		[((primitiveIndex between: 201 and: 205)			 "BlockClosure>>value[:value:...]"
		  or: [primitiveIndex between: 221 and: 222]) ifTrue: "BlockClosure>>valueNoContextSwitch[:]"
			[^aReceiver simulateValueWithArguments: arguments caller: self].
		 primitiveIndex = 206 ifTrue:						"BlockClosure>>valueWithArguments:"
			[^aReceiver simulateValueWithArguments: arguments first caller: self]].
	
	((primitiveIndex between: 207 and: 209) "FullBlockClosure primitives"
	  and: [(self objectClass: aReceiver) includesBehavior: FullBlockClosure]) ifTrue: 
		[^primitiveIndex = 208 
			ifTrue: [aReceiver simulateValueWithArguments: arguments first caller: self]
			ifFalse: [aReceiver simulateValueWithArguments: arguments caller: self]].

	primitiveIndex = 83 ifTrue: "afr 9/11/1998 19:50" "Object>>perform:[with:...]"
		[^self send: arguments first to: aReceiver with: arguments allButFirst super: false].
	primitiveIndex = 84 ifTrue: "afr 9/11/1998 19:50 & eem 8/18/2009 17:04" "Object>>perform:withArguments:"
		[^self send: arguments first to: aReceiver with: (arguments at: 2) lookupIn: (self objectClass: aReceiver)].
	primitiveIndex = 100 ifTrue: "eem 8/18/2009 16:57" "Object>>perform:withArguments:inSuperclass:"
		[arguments size = 3 
			ifTrue: [ ^self send: arguments first to: aReceiver with: (arguments at: 2) lookupIn: (arguments at: 3)]
			ifFalse: [ ^self send: (arguments at: 2) to: (arguments at: 1) with: (arguments at: 3) lookupIn: (arguments at: 4) ]
		].

	primitiveIndex = 88 ifTrue: ["Process>>suspend"
		"Simulation of suspend primitive should do nothing (with receiver return) by two reasons:
			- if by mistake the receiver is a simulating process itself 
				the suspend would stop it and the simulation would hang.
				For example the debugger can hang during stepping over #suspend of real active process.
			- suspend over already suspended process does nothing anyway. 
				For example debugger always steps over suspended process"
		^self push: aReceiver ].

	"Mutex>>primitiveEnterCriticalSection
	 Mutex>>primitiveTestAndSetOwnershipOfCriticalSection"
	(primitiveIndex = 186 or: [primitiveIndex = 187]) ifTrue:
		[| active effective |
		 active := Processor activeProcess.
		 effective := active effectiveProcess.
		 "active == effective"
		 value := primitiveIndex = 186
					ifTrue: [aReceiver primitiveEnterCriticalSectionOnBehalfOf: effective]
					ifFalse: [aReceiver primitiveTestAndSetOwnershipOfCriticalSectionOnBehalfOf: effective].
		 ^(self isPrimFailToken: value)
			ifTrue: [value]
			ifFalse: [self push: value]].

	primitiveIndex = 188 ifTrue: "eem 5/27/2008 11:10 Object>>withArgs:executeMethod:"
		[arguments size = 2 
			ifTrue: "normal primitive"
				[^Context
					sender: self
					receiver: aReceiver
					method: (arguments at: 2)
					arguments: (arguments at: 1)]
			ifFalse: "mirror primitive"
				[^Context
					sender: self
					receiver: (arguments at: 1)
					method: (arguments at: 3)
					arguments: (arguments at: 2)]
		].
	"Closure primitives"
	(primitiveIndex = 200 and: [self == aReceiver]) ifTrue:
		"ContextPart>>closureCopy:copiedValues:; simulated to get startpc right"
		[^self push: (BlockClosure
						outerContext: aReceiver
						startpc: pc + 2
						numArgs: arguments first
						copiedValues: arguments last)].

	primitiveIndex = 118 ifTrue: "tryPrimitive:withArgs:; avoid recursing in the VM"
		[(arguments size = 2
		 and: [arguments first isInteger
		 and: [(self objectClass: arguments last) == Array]]) ifFalse:
			[^Context primitiveFailTokenFor: nil].
		 ^self doPrimitive: arguments first method: meth receiver: aReceiver args: arguments last].

	value := primitiveIndex = 120 "FFI method"
				ifTrue: [(meth literalAt: 1) tryInvokeWithArguments: arguments]
				ifFalse:
					[primitiveIndex = 117 "named primitives"
						ifTrue: [self tryNamedPrimitiveIn: meth for: aReceiver withArgs: arguments]
						ifFalse: [aReceiver tryPrimitive: primitiveIndex withArgs: arguments]].

	^(self isPrimFailToken: value)
		ifTrue: [value]
		ifFalse: [self push: value]
]

{ #category : #private }
Context >> endPC [
	^closureOrNil
		ifNil:	[self compiledCode endPC]
		ifNotNil: [closureOrNil endPC]
]

{ #category : #'debugger access' }
Context >> errorReportOn: stream [
	"Write a detailed error report on the stack (above me) on a  
	stream.  For both the error file, and emailing a bug report.   
	Suppress any errors while getting printStrings.  Limit the length."
	
	| stackDepth aContext |
	stream print: Date today; space; print: Time now; cr.
	stream cr.
	stream nextPutAll: 'VM: ';
		nextPutAll: Smalltalk os name asString;
		nextPutAll: ' - ';	
		nextPutAll: Smalltalk os subtype asString;
		nextPutAll: ' - ';
		nextPutAll: Smalltalk os version asString;
		nextPutAll: ' - ';
		nextPutAll: Smalltalk vm version asString;
		cr.	
	stream nextPutAll: 'Image: ';
		nextPutAll:  SystemVersion current version asString;
		nextPutAll: ' [';
		nextPutAll: Smalltalk lastUpdateString asString;
		nextPutAll: ']';
		cr.
	stream cr.
	"Note: The following is an open-coded version of  Context>>stackOfSize: since this method may be called during a  low space condition and we might run out of space for allocating the  full stack."	
	stackDepth := 0.  
	aContext := self.
	[ aContext notNil and: [ (stackDepth := stackDepth + 1) < 40 ]] 
		whileTrue: [
			"variable values"
			aContext printDetails: stream.
			stream cr.
			aContext := aContext sender ].
	stream cr; nextPutAll: '--- The full stack ---'; cr.
	aContext := self.	
	stackDepth := 0.
	[ aContext == nil ] whileFalse:	[
		stackDepth := stackDepth + 1.	
		stackDepth = 40 ifTrue: [ stream nextPutAll: ' - - - - - - - - - - - - - - -  
			- - - - - - - - - - - - - - - - - -'; cr ].
		"just class>>selector"	
		stream print: aContext; cr. 		
		stackDepth > 200 ifTrue: [
			stream nextPutAll: '-- and more not shown --'.
			^  self ].
		aContext := aContext sender ].
]

{ #category : #'private - exceptions' }
Context >> evaluateSignal: exception [
	"The following primitive is just a marker used to find the evaluation context. 
	See MethodContext>>#isHandlerOrSignalingContext. "

	<primitive: 199>
	<debuggerCompleteToSender>
	| value |
	exception privHandlerContext: self contextTag.
	value := self exceptionHandlerBlock cull: exception.	
	"return from self if not otherwise directed in handle block"
	self return: value
]

{ #category : #'special context access' }
Context >> exception [
	"signaling context (Context>>evaluateSignal:) only. Access the exception argument."
	^self tempAt: 1

]

{ #category : #'special context access' }
Context >> exceptionClass [
	"handlercontext only. access temporaries from BlockClosure>>#on:do:"
	^self tempAt: 1

]

{ #category : #'special context access' }
Context >> exceptionHandlerBlock [
	"handlercontext only. access temporaries from BlockClosure>>#on:do:"
	^self tempAt: 2

]

{ #category : #'private - exceptions' }
Context >> exceptionsToCaptureWhenStepping [

	| exceptionsToCapture exceptionsSet |
	exceptionsToCapture := Exception allSubclasses select: [ :c | 
		                       c captureIfSignalledWhenStepping ].
	exceptionsSet := ExceptionSet new.
	exceptionsToCapture do: [ :e | exceptionsSet add: e ].
	^ exceptionsSet
]

{ #category : #'system simulation' }
Context >> failPrimitiveWith: maybePrimFailToken [
	"The receiver is a freshly-created context on a primitive method.  Skip the callPrimitive:
	 bytecode and store the primitive fail code if there is one and the method consumes it."
	self skipCallPrimitive.
	((self isPrimFailToken: maybePrimFailToken)
	  and: [method encoderClass isStoreAt: pc in: method]) ifTrue:
		[self at: stackp put: maybePrimFailToken last]
]

{ #category : #query }
Context >> findContextSuchThat: testBlock [
	"Search self and my sender chain for first one that satisfies testBlock.  Return nil if none satisfy"

	| context |
	context := self.
	[ context isNil ] whileFalse: [
		(testBlock value: context) 
			ifTrue: [ ^ context ].
		context := context sender ].
	^ nil
]

{ #category : #'private - exceptions' }
Context >> findNextHandlerContext [
	"Return the next handler marked context, returning nil if there is none.  
	Search starts with self and proceeds up to nil."
	| context searchStartContext |
	context := self findNextHandlerOrSignalingContext.
	context ifNil: [ ^ nil ].
	context isHandlerContext ifTrue: [ ^ context ].	
	"If it isn't a handler context, it must be a signaling context.
	When we reach a signaling context we must skip over any handlers
	that might be on the stack between the signaling context and the handler context for that signal"
	searchStartContext := context exception privHandlerContext ifNil: [ context ].
	^searchStartContext nextHandlerContext
]

{ #category : #'private - exceptions' }
Context >> findNextHandlerOrSignalingContext [
	"Return the next handler/signaling marked context, answering nil if there is none. 
	Search starts with self and proceeds up to nil."

	<primitive: 197>
	| context |
	context := self.
	[ 
	context isHandlerOrSignalingContext
		ifTrue: [ ^ context ].
	(context := context sender) == nil ] whileFalse.
	^ nil
]

{ #category : #'private - exceptions' }
Context >> findNextUnwindContextUpTo: aContext [
	"Return the next unwind marked above the receiver, returning nil if there is none.  Search proceeds up to but not including aContext."

	| context |
	<primitive: 195>
	context := self.
	[
		(context := context sender) == nil
		or: [ context == aContext ]
	] whileFalse: [
		context isUnwindContext
			ifTrue: [ ^context ]].
	^nil
]

{ #category : #query }
Context >> findSecondToOldestSimilarSender [
	"Search the stack for the second-to-oldest occurance of self's method.  Very useful for an infinite recursion.  Gets back to the second call so you can see one complete recursion cycle, and how it was called at the beginning."

	| secondContext context lastContext |
	secondContext := self.
	context := self.
	[	lastContext := context findSimilarSender.
		lastContext isNil
	] whileFalse: [
		secondContext := context.
		context := lastContext.
	].
	^ secondContext

]

{ #category : #query }
Context >> findSimilarSender [
	"Return the closest sender with the same method, return nil if none found"

	^ self sender findContextSuchThat: [ :context | 
		context compiledCode == method ]
]

{ #category : #'private - exceptions' }
Context >> handleSignal: exception [
	"Sent to handler (on:do:) contexts only.  If my exception class (first arg) handles exception then execute my handle block (second arg), otherwise forward this message to the next handler context.  If none left, execute exception's defaultAction (see nil>>handleSignal:)."
	<debuggerCompleteToSender>
	(self exceptionClass handles: exception)
		ifFalse: [ ^ self nextHandlerContext handleSignal: exception ].
	self evaluateSignal: exception
]

{ #category : #testing }
Context >> hasContext: aContext [ 
	"Answer whether aContext is me or one of my senders"

	^ (self findContextSuchThat: [ :context | context == aContext ]) notNil
]

{ #category : #accessing }
Context >> hasInstVarRef [
	"Answer whether the receiver references an instance variable."

	^self compiledCode hasInstVarRef.
]

{ #category : #testing }
Context >> hasMethodReturn [
	^closureOrNil hasMethodReturn
]

{ #category : #testing }
Context >> hasSender: context [ 
	"Answer whether the receiver is strictly above context on the stack."

	| senderContext |
	self == context 
		ifTrue: [^false].
	senderContext := sender.
	[senderContext == nil]
		whileFalse: [
			senderContext == context
				ifTrue: [^true].
			senderContext := senderContext sender].
	^false
]

{ #category : #testing }
Context >> hasTemporaryVariableNamed: aName [
	^ self tempNames includes: aName
]

{ #category : #accessing }
Context >> home [ 
	"Answer the context in which the receiver was defined, i.e. the context from which an ^-return should return from."

	closureOrNil == nil ifTrue:
		[^self].
	^closureOrNil outerContext home
]

{ #category : #private }
Context >> insertSender: aContext [
	"Insert aContext and its sender chain between me and my sender.  Return new callee of my original sender."

	| context |
	context := aContext bottomContext.
	context privSender: self sender.
	self privSender: aContext.
	^ context
]

{ #category : #private }
Context >> instVarAt: index put: value [
	index = 3 
		ifTrue: [
			self stackp: value. 
			^ value].
	^ super instVarAt: index put: value
]

{ #category : #testing }
Context >> isBlockContext [
	"Is this executing a block versus a method?  In the new closure
	 implemetation this is true if closureOrNil is not nil, in which case
	 it should be holding a BlockClosure."

	^closureOrNil isClosure
]

{ #category : #testing }
Context >> isBottomContext [
	"Answer if this is the last context (the first context invoked) in my sender chain"

	^sender isNil
]

{ #category : #testing }
Context >> isContext [
	^true
]

{ #category : #testing }
Context >> isDead [
	"Context is dead when
	- it is self finished (returned to sender) 
	- it is at the last instruction of process termination (it is unwinded and process is suspended)"

	^ pc isNil or: [  self isEndOfProcessTermination ]
]

{ #category : #testing }
Context >> isEndOfProcessTermination [ 
	"The normal completion of any process always ends at Process>>doTerminationFromYourself method
	(see #newProcess and #terminateRealActive).
	The last instruction is the call to #suspend primitive method 
	which finally removes the process from the scheduler.
	This precise criteria of the terminated process is used here" 
	method selector == #doTerminationFromYourself ifFalse: [ ^false ].
	method methodClass == Process ifFalse: [ ^false ].	
	^pc = (self endPC - 1)
]

{ #category : #testing }
Context >> isExecutingBlock [
	"for compatibility"
	^self isBlockContext 
]

{ #category : #private }
Context >> isFailToken: anObject [
	^ (self objectClass: anObject) == Array 
			and: [ anObject size = 2 and: [(anObject at: 1) == PrimitiveFailToken]]
]

{ #category : #'private - exceptions' }
Context >> isHandlerContext [
	"is this context for #on:do:?"
	^self isHandlerOrSignalingContext and: [ self selector == #on:do: ]
]

{ #category : #'private - exceptions' }
Context >> isHandlerOrSignalingContext [
	"Both BlockClosure>>on:do: (handler) and Context>>evaluateSignal: (signaling) 
	are marked with primitive 199."
	^method primitive = 199
]

{ #category : #private }
Context >> isPrimFailToken: anObject [
	^ (self objectClass: anObject) == Array
		  and: [anObject size = 2
		  and: [anObject first == PrimitiveFailToken]]
]

{ #category : #'private - exceptions' }
Context >> isUnwindContext [
	"is this context for  method that is marked?"
	^method primitive = 198
]

{ #category : #controlling }
Context >> jump [
	"Abandon thisContext and resume self instead (using the same current process).  You may want to save thisContext's sender before calling this so you can jump back to it.
	Self MUST BE a top context (ie. a suspended context or an abandoned context that was jumped out of).  A top context already has its return value on its stack (see Interpreter>>primitiveSuspend and other suspending primitives).
	If self is not a top context is the responsibility of the caller to push something in the context. If this is not guarantee an error when accessing the values in the context is produced. Pay special attention to the implementation of Context class >> #contextOn: exceptionClass do: block and Context class >> #contextEnsure:. 
	
	thisContext's sender is converted to a top context (by pushing a nil return value on its stack) so it can be jump back to."

	| top |
	"Make abandoned context a top context (has return value (nil)) so it can be jumped back to"
	thisContext sender push: nil.

	"Pop self return value then return it to self (since we jump to self by returning to it)"
	stackp = 0 ifTrue: [self stepUntilSomethingOnStack].
	stackp = 0 ifTrue: [self push: nil].  "must be quick return self/constant"
	top := self pop.
	thisContext privSender: self.
	^ top
]

{ #category : #'instruction decoding' }
Context >> jump: distance [ 
	"Simulate the action of a 'unconditional jump' bytecode whose offset is 
	the argument, distance."

	pc := pc + distance
]

{ #category : #'instruction decoding' }
Context >> jump: distance if: condition [ 
	"Simulate the action of a 'conditional jump' bytecode whose offset is the 
	argument, distance, and whose condition is the argument, condition."

	| bool |
	bool := self pop.
	(bool == true or: [bool == false]) ifFalse: [
		^self
			send: #mustBeBoolean
			to: bool
			with: {}
			super: false].
	(bool eqv: condition) ifTrue: [self jump: distance]
]

{ #category : #'debugger access' }
Context >> longStack [
	"Answer a String showing the top 100 contexts on my sender chain."

	^ String streamContents: [ :stream |
		(self stackOfSize: 100) do: [ :item | 
			stream print: item; cr ]]
]

{ #category : #accessing }
Context >> method [
	"self
		deprecated: 'Should use compiledCode since it can be CompiledMethod or a CompiledBlock'
		transformWith: '`@receiver method' 
						-> '`@receiver compiledCode'."

	^method
]

{ #category : #'debugger access' }
Context >> methodClass [ 
	"Answer the class in which the receiver's method was found."
	
	^self compiledCode methodClass ifNil:[self receiver class].
]

{ #category : #accessing }
Context >> methodNode [
	^ self compiledCode methodNode.
]

{ #category : #accessing }
Context >> methodReturnContext [

	^ self home.
]

{ #category : #'instruction decoding' }
Context >> methodReturnReceiver [
	"Simulate the action of a 'return receiver' bytecode. This corresponds to
	 the source expression '^self'."

	^self return: self receiver from: self methodReturnContext
]

{ #category : #'instruction decoding' }
Context >> methodReturnTop [
	"Simulate the action of a 'return top of stack' bytecode. This corresponds
	 to source expressions like '^something'."

	^self return: self pop from: self methodReturnContext
]

{ #category : #accessing }
Context >> methodSelector [
	^ self compiledCode selector
]

{ #category : #'private - exceptions' }
Context >> nextHandlerContext [

	^ self sender findNextHandlerContext
]

{ #category : #accessing }
Context >> numArgs [
	"Answer the number of arguments for this activation."
	^closureOrNil
		ifNil: [method numArgs]
		ifNotNil: [closureOrNil numArgs]
]

{ #category : #accessing }
Context >> numTemps [
	"Answer the number of temporaries for this activation; this includes
	 the number of arguments, and for blocks, the number of copied values."
	^closureOrNil
		ifNil: [method numTemps]
		ifNotNil: [closureOrNil numTemps]
]

{ #category : #'mirror primitives' }
Context >> object: anObject basicAt: index [ 
	"Answer the value of an indexable element in the argument anObject without sending
	 it a message. Fail if the argument index is not an Integer or is out of bounds, or if
	 anObject is not indexable. This mimics the action of the VM when it indexes an object.
	 Used to simulate the execution machinery by, for example, the debugger.
	 Primitive.  See Object documentation whatIsAPrimitive."

	<primitive: 60>
	index isInteger ifTrue: [self errorSubscriptBounds: index].
	index isNumber
		ifTrue: [^self object: anObject basicAt: index asInteger]
		ifFalse: [self errorNonIntegerIndex]
]

{ #category : #'mirror primitives' }
Context >> object: anObject basicAt: index put: value [ 
	"Store the last argument 
	 value in the indexable element of the argument anObject indicated by index without sending
	 anObject a message. Fail if the argument index is not an Integer or is out of bounds, or if
	 anObject is not indexable, or if value is an inappropriate value for anObject's indexable slots.
	 This mimics the action of the VM when it indexes an object.
	 Used to simulate the execution machinery by, for example, the debugger.
	 Primitive.  See Object documentation whatIsAPrimitive."

	<primitive: 61>
	index isInteger
		ifTrue: [(index >= 1 and: [index <= (self objectSize: anObject)])
					ifFalse: [self errorSubscriptBounds: index]].
	index isNumber
		ifTrue: [^self object: anObject basicAt: index asInteger put: value]
		ifFalse: [self errorNonIntegerIndex].
	anObject isReadOnlyObject 
		ifTrue: [ ^ (ModificationForbidden new
				object: anObject;
				fieldIndex: index;
				newValue: value;
				retrySelector: #basicAt:put:) signal ].
	self errorImproperStore
]

{ #category : #'mirror primitives' }
Context >> object: anObject eqeq: anOtherObject [ 
	"Answer whether the first and second arguments are the same object (have the
	 same object pointer) without sending a message to the first argument.  This
	 mimics the action of the VM when it compares two object pointers.  Used to
	 simulate the execution machinery by, for example, the debugger.
	 Primitive.  See Object documentation whatIsAPrimitive."

	<primitive: 110>
	self primitiveFailed
]

{ #category : #'mirror primitives' }
Context >> object: anObject instVarAt: anIndex [
	"Primitive. Answer a fixed variable in an object. The numbering of the 
	 variables corresponds to the named instance variables. Fail if the index 
	 is not an Integer or is not the index of a fixed variable. Essential for the
	 debugger. See  Object documentation whatIsAPrimitive."

	<primitive: 73>
	"Access beyond fixed variables."
	^self object: anObject basicAt: anIndex - (self objectClass: anObject) instSize
]

{ #category : #'mirror primitives' }
Context >> object: anObject instVarAt: anIndex put: aValue [ 
	"Primitive. Store a value into a fixed variable in the argument anObject.
	 The numbering of the variables corresponds to the named instance
	 variables.  Fail if the index is not an Integer or is not the index of a
	 fixed variable.  Answer the value stored as the result. Using this
	 message violates the  principle that each object has sovereign control
	 over the storing of values into its instance variables. Essential for the
	 debugger. See Object documentation whatIsAPrimitive."

	<primitive: 74>
	"Access beyond fixed fields"
	^self object: anObject basicAt: anIndex - (self objectClass: anObject) instSize put: aValue
]

{ #category : #'mirror primitives' }
Context >> object: anObject perform: selector withArguments: argArray inClass: lookupClass [
	"Send the selector, aSymbol, to anObject with arguments in argArray.
	 Fail if the number of arguments expected by the selector 
	 does not match the size of argArray, or if lookupClass
	 cannot be found among the anObject's superclasses.
	 Primitive. Essential for the debugger."

	<primitive: 100 error: error>
	selector isSymbol
		ifFalse: [ ^ self error: 'selector argument must be a Symbol' ].
	(argArray isMemberOf: Array)
		ifFalse: [ ^ self error: 'argArray must be an Array' ].
	selector numArgs = argArray size
		ifFalse: [ ^ self error: 'incorrect number of arguments' ].
	((self objectClass: anObject) includesBehavior: lookupClass)
		ifFalse: [ ^ self error: 'lookupClass is not in anObject''s inheritance chain' ].
	self primitiveFailed
]

{ #category : #'mirror primitives' }
Context >> objectClass: aReceiver [
	<primitive: 111>
	self primitiveFailed
]

{ #category : #'mirror primitives' }
Context >> objectSize: anObject [
	"Answer the number of indexable variables in the argument anObject without sending
	 it a message. This mimics the action of the VM when it fetches an object's variable size.
	 Used to simulate the execution machinery by, for example, the debugger.
	 Primitive.  See Object documentation whatIsAPrimitive."

	<primitive: 62>
	"The number of indexable fields of fixed-length objects is 0"
	^0
]

{ #category : #accessing }
Context >> outerContext [
	"Answer the context within which the receiver is nested."
	
	^closureOrNil ifNotNil:
		[closureOrNil outerContext ifNil: ["if the outer is nil, this is a CleanBlock" self sender]]
]

{ #category : #accessing }
Context >> outerMostContext [
	^ self outerContext 
		ifNil: [ self ]
		ifNotNil: [ self outerContext ]
]

{ #category : #controlling }
Context >> pop [
	"Answer the top of the receiver's stack and remove the top of the stack."
	| value |
	value := self at: stackp.
	self stackp: stackp - 1.
	^ value
]

{ #category : #'instruction decoding' }
Context >> popIntoLiteralVariable: value [ 
	"Simulate the action of bytecode that removes the top of the stack and 
	stores it into a literal variable of my method."

	value value: self pop
]

{ #category : #'instruction decoding' }
Context >> popIntoReceiverVariable: offset [ 
	"Simulate the action of bytecode that removes the top of the stack and 
	stores it into an instance variable of my receiver."

	self object: self receiver instVarAt: offset + 1 put: self pop
]

{ #category : #'instruction decoding' }
Context >> popIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	"Simulate the action of bytecode that removes the top of the stack and  stores
	 it into an offset in one of my local variables being used as a remote temp vector."

	(self at: tempVectorIndex + 1) at: remoteTempIndex + 1 put: self pop
]

{ #category : #'instruction decoding' }
Context >> popIntoTemporaryVariable: offset [ 
	"Simulate the action of bytecode that removes the top of the stack and 
	stores it into one of my temporary variables."

	self at: offset + 1 put: self pop
]

{ #category : #'debugger access' }
Context >> print: anObject on: aStream [
	"Safely print anObject in the face of direct ProtoObject subclasses"
	| title |
	(anObject class canUnderstand: #printOn:)
		ifTrue: [ ^ anObject printOn: aStream ].
	title := anObject class name.
	aStream
		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: title
]

{ #category : #printing }
Context >> printDebugOn: aStream [	
	"print a condensed for of the stack.
		For methods simply print Class >> selector
		For blocks only print the first line"
	| blockSource blockSourceSize |
	
	self printOn: aStream.
	self outerContext ifNil: [ ^ self ].
	"print the block..."
	aStream 
		nextPutAll: ' in Block: '.
	
	blockSource := closureOrNil printStringLimitedTo: 50.
	blockSourceSize := blockSource size.
	blockSource := blockSource copyUpTo: Character cr.
	
	aStream nextPutAll: blockSource.
	blockSource size < blockSourceSize
		ifTrue: [ aStream nextPutAll: '...' ].
]

{ #category : #printing }
Context >> printDetails: stream [

	"Put my class>>selector and instance variables and arguments and temporaries on the stream.  Protect against errors during printing."

	| errorMessage string |
	self printOn: stream.
	stream cr.
	stream
		tab;
		nextPutAll: 'Receiver: '.
	errorMessage := '<<error during printing>>'.
	stream nextPutAll:
		([ receiver printStringLimitedTo: 90 ] on: Exception do: [ errorMessage ]).

	stream
		cr;
		tab;
		nextPutAll: 'Arguments and temporary variables: ';
		cr.
	string := [ 
	          (self tempsAndValuesLimitedTo: 80 indent: 2)
		          padRightTo: 1
		          with: $x ] on: Exception do:  [ errorMessage ].
	stream nextPutAll: string.

	stream
		cr;
		tab;
		nextPutAll: 'Receiver''s instance variables: ';
		cr.
	receiver class allInstVarNames isEmpty
		ifTrue: [ 
			stream nextPutAll:
				([ receiver printStringLimitedTo: 90 ] on: Exception do:  [ errorMessage ]) ]
		ifFalse: [ 
			[ receiver longPrintOn: stream limitedTo: 80 indent: 2 ] 
				on: Exception do:  [ stream nextPutAll: errorMessage ] ].
	stream cr
]

{ #category : #printing }
Context >> printOn: aStream [
	(closureOrNil isNotNil and: [closureOrNil isClean]) ifTrue: 
		[ | selector |
			selector := self selector ifNil: [ self compiledCode defaultSelector ].
			aStream 
			 print: closureOrNil;
			 nextPutAll: ' in ';
			 nextPutAll: self methodClass name;
			 nextPutAll: '>>';
			 nextPutAll: selector.
			 ^self].
	
	self outerContext
		ifNil:
			[ | selector class mclass |
			self compiledCode
				ifNil: [ ^ super printOn: aStream ].
			class := self receiver class.
			mclass := self methodClass.
			selector := self selector ifNil: [ self compiledCode defaultSelector ].
			aStream nextPutAll: class name.
			mclass == class
				ifFalse:
					[ aStream nextPut: $(.
					aStream nextPutAll: mclass name.
					aStream nextPut: $) ].
			aStream nextPutAll: '>>'.
			aStream nextPutAll: selector.
			selector = #doesNotUnderstand:
				ifTrue:
					[ aStream space.
					(self tempAt: 1) selector printOn: aStream ] ]
		ifNotNil:
			[ :outerContext | 
			closureOrNil printOn: aStream.
			aStream nextPutAll: ' in '.
			outerContext printOn: aStream ]
]

{ #category : #initialization }
Context >> privRefresh [
	"Reinitialize the receiver so that it is in the state it was at its creation."
	 closureOrNil
		ifNotNil:
			[pc := closureOrNil startpc.
			self stackp: closureOrNil initialStackPointer.
			1 to: closureOrNil numCopiedValues do:
				[:i | self tempAt: closureOrNil numArgs + i put: (closureOrNil at: i)].
			closureOrNil clearTemporariesOn: self]
		ifNil:
			[pc := method initialPC.
			self stackp: method numTemps.
			method numArgs+1 to: method numTemps do:
				[:i | self tempAt: i put: nil]]
]

{ #category : #initialization }
Context >> privRefreshWith: aCompiledMethod [ 
	"Reinitialize the receiver as though it had been for a different method. 
	 Used by a Debugger when one of the methods to which it refers is 
	 recompiled."

	aCompiledMethod isCompiledMethod ifFalse:
		[self error: 'method can only be set to aCompiledMethod'].
	method := aCompiledMethod.
	[closureOrNil == nil] assert.
	"was: receiverMap := nil."
	self privRefresh
]

{ #category : #private }
Context >> privSender: aContext [ 

	sender := aContext
]

{ #category : #controlling }
Context >> push: value [ 
	"Push value on the receiver's stack."

	self stackp: stackp + 1.
	self at: stackp put: value
]

{ #category : #'instruction decoding' }
Context >> pushActiveContext [
	"Simulate the action of bytecode that pushes the the active context on the 
	top of its own stack."

	self push: self
]

{ #category : #'instruction decoding' }
Context >> pushActiveProcess [
	"Simulate the action of bytecode that pushes the the active Process on the 
	top of its own stack."

	self push: Processor activeProcess
]

{ #category : #'system simulation' }
Context >> pushArgs: arguments from: senderContext [
	"Helps simulate action of the value primitive for closures.
	 This is used by Context>>runSimulated:contextAtEachStep:"

	closureOrNil
		ifNil: [self error: 'context needs a closure!']
		ifNotNil: [
			"See BlockClosure>>asContextWithSender:"
			 stackp ~= (closureOrNil numArgs + closureOrNil numCopiedValues) 
				ifTrue: [ self error: 'stack pointer is incorrect!' ]].

	1 to: closureOrNil numArgs do: [:i |
		self at: i put: (arguments at: i)].
	sender := senderContext
]

{ #category : #'instruction decoding' }
Context >> pushClosureCopyNumCopiedValues: numCopied numArgs: numArgs blockSize: blockSize [
	"Simulate the action of a 'closure copy' bytecode whose result is the
	 new BlockClosure for the following code"
	| copiedValues |
	numCopied > 0
		ifTrue: [
			copiedValues := Array new: numCopied.
			numCopied to: 1 by: -1 do: [ :i |
				copiedValues at: i put: self pop ]]
		ifFalse: [ copiedValues := nil ].
	self push: (BlockClosure
				outerContext: self
				startpc: pc
				numArgs: numArgs
				copiedValues: copiedValues).
	self jump: blockSize
]

{ #category : #'instruction decoding' }
Context >> pushClosureTemps: numTemps [
	numTemps timesRepeat: [ self push: nil ]
]

{ #category : #'instruction decoding' }
Context >> pushConsArrayWithElements: numElements [ 
	| array |
	array := Array new: numElements.
	numElements to: 1 by: -1 do: [ :i |
		array at: i put: self pop ].
	self push: array
]

{ #category : #'instruction decoding' }
Context >> pushConstant: value [ 
	"Simulate the action of bytecode that pushes the constant, value, on the 
	top of the stack."

	self push: value
]

{ #category : #'instruction decoding' }
Context >> pushFullClosure: compiledBlock numCopied: numCopied receiverOnStack: onStack ignoreOuterContext: ignore [
	| copiedValues cls |
	copiedValues := (1 to: numCopied) collect: [ :i | self pop ].
	self push: (cls := (FullBlockClosure new: numCopied) 
		outerContext: (ignore ifFalse: [self]);
		receiver: (onStack ifTrue: [ self pop ] ifFalse: [ receiver ]);
		numArgs: compiledBlock numArgs;
		compiledBlock: compiledBlock;
		yourself).
	copiedValues size to: 1 by: -1 do: [ :i |
		 cls at: copiedValues size - i + 1 put: (copiedValues at: i) ]
]

{ #category : #'instruction decoding' }
Context >> pushLiteralVariable: value [ 
	"Simulate the action of bytecode that pushes the contents of the literal 
	variable whose index is the argument, index, on the top of the stack."

	self push: value value
]

{ #category : #'instruction decoding' }
Context >> pushNewArrayOfSize: arraySize [ 
	self push: (Array new: arraySize)
]

{ #category : #'instruction decoding' }
Context >> pushReceiver [
	"Simulate the action of bytecode that pushes the active context's receiver 
	on the top of the stack."

	self push: self receiver
]

{ #category : #'instruction decoding' }
Context >> pushReceiverVariable: offset [ 
	"Simulate the action of bytecode that pushes the contents of the receiver's 
	instance variable whose index is the argument, index, on the top of the 
	stack."

	self push: (self object: self receiver instVarAt: offset + 1)
]

{ #category : #'instruction decoding' }
Context >> pushRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	"Simulate the action of bytecode that pushes the value at remoteTempIndex
	 in one of my local variables being used as a remote temp vector."
	self push: ((self at: tempVectorIndex + 1) at: remoteTempIndex + 1)
]

{ #category : #'instruction decoding' }
Context >> pushTemporaryVariable: offset [ 
	"Simulate the action of bytecode that pushes the contents of the 
	temporary variable whose index is the argument, index, on the top of 
	the stack."

	self push: (self at: offset + 1)
]

{ #category : #private }
Context >> quickMethodPrimitiveBytecodeSize [

	"A quick method starts with a 3 bytecodes primitive (264 or 256)"

	^ 3
]

{ #category : #accessing }
Context >> receiver [ 

	^receiver
]

{ #category : #'private - exceptions' }
Context >> receiver: anObject [

	receiver := anObject
]

{ #category : #'debugger access' }
Context >> release [
	"Remove information from the receiver and all of the contexts on its 
	sender chain in order to break circularities."

	self releaseTo: nil
]

{ #category : #'debugger access' }
Context >> releaseTo: caller [ 
	"Remove information from the receiver and the contexts on its sender 
	chain up to caller in order to break circularities."

	| contex senderContext |
	contex := self.
	[ contex == nil or: [ contex == caller ]]
		whileFalse: [
			senderContext := contex sender.
			contex singleRelease.
			contex := senderContext ]
]

{ #category : #accessing }
Context >> removeSelf [
	"Nil the receiver pointer and answer its former value."

	| tempSelf |
	tempSelf := receiver.
	receiver := nil.
	^tempSelf
]

{ #category : #controlling }
Context >> resume [
	"Roll back thisContext to self and resume.  Execute unwind blocks when rolling back.  ASSUMES self is a sender of thisContext"

	self resume: nil
]

{ #category : #controlling }
Context >> resume: value [
	"Unwind thisContext to self and resume with value as result of last send.  Execute unwind blocks when unwinding.  ASSUMES self is a sender of thisContext"
	
	self resume: value through: (thisContext findNextUnwindContextUpTo: self)
	
]

{ #category : #controlling }
Context >> resume: value through: firstUnwindContext [
	"Unwind thisContext to self and resume with value as result of last send.
	 Execute any unwind blocks while unwinding.
	 ASSUMES self is a sender of thisContext."

	| context unwindBlock |
	self isDead 
		ifTrue: [ self cannotReturn: value to: self ].
	context := firstUnwindContext.
	[ context isNil ] whileFalse: [	
		context unwindComplete ifNil:[
			context unwindComplete: true.
			unwindBlock := context unwindBlock.
			thisContext terminateTo: context.
			unwindBlock value].
		context := context findNextUnwindContextUpTo: self].
	thisContext terminateTo: self.
	^value

]

{ #category : #controlling }
Context >> resumeEvaluating: aBlock [
	"Unwind thisContext to self and resume with aBlock value as result of last send.  
	Execute unwind blocks when unwinding.  
	ASSUMES self is a sender of thisContext"
	| context unwindBlock |
	self isDead ifTrue: [self cannotReturn: aBlock value to: self].
	context := thisContext.
	[
		context := context findNextUnwindContextUpTo: self.
		context isNil
	] whileFalse: [	
		context unwindComplete ifNil:[
			context unwindComplete: true.
			unwindBlock := context unwindBlock.
			thisContext terminateTo: context.
			unwindBlock value]
	].
	thisContext terminateTo: self.
	^aBlock value

]

{ #category : #controlling }
Context >> return [
	"Unwind until my sender is on top"

	self return: self receiver
]

{ #category : #controlling }
Context >> return: value [
	"Unwind thisContext to self and return value to self's sender.  Execute any unwind blocks while unwinding.  ASSUMES self is a sender of thisContext"

	sender ifNil: [^self cannotReturn: value to: sender].
	sender resume: value
]

{ #category : #controlling }
Context >> return: value from: aSender [ 
	"For simulation.  Roll back self to aSender and return value from it.  Execute any unwind blocks on the way.  ASSUMES aSender is a sender of self"

	| newTop context |
	aSender isDead ifTrue: [
		^ self send: #cannotReturn: to: self with: {value} super: false ].
	newTop := aSender sender.
	context := self findNextUnwindContextUpTo: newTop.
	context ifNotNil: [
		^ self send: #aboutToReturn:through: to: self with: {value. context} super: false] .
	self releaseTo: newTop.
	newTop ifNotNil: [ newTop push: value ].
	^ newTop

]

{ #category : #controlling }
Context >> return: value through: firstUnwindContext [
	"Unwind thisContext to self and return value to self's sender.
	 Execute any unwind blocks while unwinding.
	 ASSUMES self is a sender of thisContext."

	sender ifNil: [self cannotReturn: value to: sender].
	sender resume: value through: firstUnwindContext
]

{ #category : #controlling }
Context >> runUntilErrorOrReturnFrom: aSender [ 
	"ASSUMES aSender is a sender of self.  Execute self's stack until aSender returns or an unhandled exception is raised.  Return a pair containing the new top context and a possibly nil exception.  The exception is not nil if it was raised before aSender returned and it was not handled.  The exception is returned rather than openning the debugger, giving the caller the choice of how to handle it."
	"Self is run by jumping directly to it (the active process abandons thisContext and executes self).  However, before jumping to self we insert an ensure block under aSender that jumps back to thisContext when evaluated.  We also insert an exception handler under aSender that jumps back to thisContext when an unhandled exception is raised.  In either case, the inserted ensure and exception handler are removed once control jumps back to thisContext."

	| error context here topContext |
	here := thisContext.

	"Insert ensure and exception handler contexts under aSender"
	error := nil.
	context := aSender insertSender: (Context
		contextOn: self exceptionsToCaptureWhenStepping do: [:ex |
			error ifNil: [
				error := ex.
				topContext := thisContext.
				ex resumeUnchecked: here jump ]
			ifNotNil: [ ex pass ]]).
	context := context insertSender: (Context
		contextEnsure: [error ifNil: [
				topContext := thisContext.
				here jump]
		]).
	self jump.  "Control jumps to self"

	"Control resumes here once above ensure block or exception handler is executed"
	^ error ifNil: [
		"No error was raised, remove ensure context by stepping until popped"
		[(context isDead)or: [ topContext isNil  ]] whileFalse: [topContext := topContext stepToCallee].
		{topContext. nil}

	] ifNotNil: [
		"Error was raised, remove inserted above contexts then return signaler context"
		aSender terminateTo: context sender.  "remove above ensure and handler contexts"
		{topContext. error}
	].

]

{ #category : #query }
Context >> secondFromBottom [
	"Return the second from bottom of my sender chain"

	self sender ifNil: [ ^ nil ].
	^ self findContextSuchThat: [ :context |
		context sender sender isNil]
]

{ #category : #'debugger access' }
Context >> selector [
	"Answer the selector of the method that created the receiver."

	^self compiledCode selector ifNil: [self compiledCode defaultSelector].
]

{ #category : #controlling }
Context >> send: selector to: rcvr with: arguments lookupIn: lookupClass [
	"Simulate the action of sending a message with selector and arguments
	 to rcvr. The argument, lookupClass, is the class in which to lookup the
	 message.  This is the receiver's class for normal messages, but for super
	 messages it will be some specific class related to the source method."

	| meth primIndex val ctxt |
	(meth := lookupClass lookupSelector: selector) ifNil:
		[^self send: #doesNotUnderstand:
				to: rcvr
				with: {Message selector: selector arguments: arguments}
				lookupIn: lookupClass].
	(primIndex := meth primitive) > 0 ifTrue:
		[val := self doPrimitive: primIndex method: meth receiver: rcvr args: arguments.
		 (self isPrimFailToken: val) ifFalse:
			[^val]].
	(selector == #doesNotUnderstand: and: [lookupClass == ProtoObject]) ifTrue:
		[^self error: 'Simulated message ', arguments first selector, ' not understood'].
	ctxt := Context sender: self receiver: rcvr method: meth arguments: arguments.
	primIndex > 0 ifTrue:
		[ctxt failPrimitiveWith: val].
	^ctxt
]

{ #category : #controlling }
Context >> send: selector to: aReceiver with: arguments super: superFlag [

	"Simulate the action of sending a message with selector, selector, and 
	arguments, args, to receiver. The argument, superFlag, tells whether the 
	receiver of the message was specified with 'super' in the source method."

	| class aMethod value context |
	class := superFlag
		         ifTrue: [ 
			         (self compiledCode literalAt:
				          self compiledCode numLiterals) value superclass ]
		         ifFalse: [ self objectClass: aReceiver ].
	aMethod := class lookupSelector: selector.
	aMethod == nil ifTrue: [ 
		^ self
			  send: #doesNotUnderstand:
			  to: aReceiver
			  with:
			  (Array with: (Message selector: selector arguments: arguments))
			  super: superFlag ].
	aMethod isCompiledMethod ifFalse: [ 
		^ self
			  send: #run:with:in:
			  to: aMethod
			  with: (Array with: selector with: arguments with: aReceiver)
			  super: superFlag ].

	(aMethod isRealPrimitive or:[self stepIntoQuickMethod not]) ifTrue: [ 
		value := self
			         tryPrimitiveFor: aMethod
			         receiver: aReceiver
			         args: arguments.
		"primitive runs without failure?"
		(self isFailToken: value) ifFalse: [ ^ value ] ].

	(selector == #doesNotUnderstand: and: [ 
		 (class canUnderstand: #doesNotUnderstand:) not ]) ifTrue: [ 
		^ self error:
			  'Simulated message ' , (arguments at: 1) selector
			  , ' not understood' ].

	(selector == #terminateRealActive and: [ aReceiver == Processor ]) ifTrue: [ 
		"We should never simulate #terminateRealActive as it will terminate a simulating process 
		(UI process of debugger) instead of the actual process under simulation.
		Therefore the simulation always delegates this method to the public one 
		which explicitly supports the simulation with effective process logic.
		Notice that #terminateRealActive is a process completion method 
		and normally users do not step over it"
		^self send: #terminateActive to: aReceiver with: arguments super: superFlag
	].

	"failure.. lets activate the method"
	context := self
		           activateMethod: aMethod
		           withArgs: arguments
		           receiver: aReceiver
		           class: class.
		
	"The quick method contains 3 bytecodes:
	- primitive 264 or 256: a 3 bytecode primitive (initialPC)
	- a push of a value (endPC - 1)
	- the return top instruction (endPC)
	When activating the quick method, we arrive on the PC corresponding to the primitive which is not suposed to be stepped.
	We have to fix the PC so that the next executed bytecode is the push.
	We do that by setting the PC to aMethod initialPC + 3 (the number of bytes of the primitive)."
	(aMethod isQuick and:[self stepIntoQuickMethod]) ifTrue: [ context pc: aMethod initialPC + self quickMethodPrimitiveBytecodeSize].
	
	"check if activated method handles the error code (a first bytecode will be store into temp)"
	"long store temp"
	(context compiledCode at: context pc) = 129 ifTrue: [ 
		context at: context stackPtr put: value last ].
	^ context
]

{ #category : #'debugger access' }
Context >> sender [
	"Answer the context that sent the message that created the receiver."

	^sender
]

{ #category : #private }
Context >> setNamedPrimitiveInformationFrom: fromMethod toMethod: toMethod [
	"For named primitives, the first literal contains a special object that has information of the primitive. In this method we cope such information from one to another one."
	| spec |	
	spec := toMethod literalAt: 1.	
	spec replaceFrom: 1 to: spec size with: (fromMethod literalAt: 1) startingAt: 1.
	

]

{ #category : #private }
Context >> setSender: newSender receiver: newReceiver method: newMethod arguments: arguments [ 
	"Create the receiver's initial state."

	sender := newSender.
	receiver := newReceiver.
	method := newMethod.
	closureOrNil := nil.
	pc := method initialPC.
	self stackp: method numTemps.
	1 to: arguments size do: [ :i | 
		self at: i put: (arguments at: i)]
]

{ #category : #private }
Context >> setSender: newSender receiver: newReceiver method: newMethod closure: newClosure startpc: startpc [
	"Create the receiver's initial state."

	sender := newSender.
	receiver := newReceiver.
	method := newMethod.
	closureOrNil := newClosure.
	pc := startpc.
	stackp := 0
]

{ #category : #controlling }
Context >> shortDebugStack [
	"Answer a String showing the top ten contexts on my sender chain."

	^ String streamContents: [ :stream | self debugStack: 10 on: stream ]
]

{ #category : #printing }
Context >> shortDebugStackOn: aStream [
	"print the top 30 contexts on my sender chain."

	^ self debugStack: 30 on: aStream
]

{ #category : #'debugger access' }
Context >> shortStack [
	"Answer a String showing the top ten contexts on my sender chain."

	^ String streamContents: [ :stream |
		(self stackOfSize: 10) do: [ :item |
			stream print: item; cr]]
]

{ #category : #'debugger access' }
Context >> singleRelease [
	"Remove information from the receiver in order to break circularities."

	stackp ifNotNil: [
		1 to: stackp do: [ :i |
			self at: i put: nil ]].
	sender := nil.
	pc := nil.

]

{ #category : #accessing }
Context >> size [
	"Primitive. Answer the number of indexable variables in the receiver. 
	This value is the same as the largest legal subscript. Essential. See Object 
	documentation whatIsAPrimitive.  Override the default primitive to give latitude to
	 the VM in context management."

	<primitive: 212>
	"The number of indexable fields of fixed-length objects is 0"
	^self primitiveFail
]

{ #category : #'debugger access' }
Context >> sourceCode [
	^self compiledCode sourceCode.
]

{ #category : #'debugger access' }
Context >> stack [ 
	"Answer an Array of the contexts on the receiver's sender chain."

	^self stackOfSize: 9999
]

{ #category : #'debugger access' }
Context >> stackOfSize: limit [ 
	"Answer an OrderedCollection of the top 'limit' contexts
	 on the receiver's sender chain."

	| stack context |
	stack := OrderedCollection new.
	stack addLast: (context := self).
	[(context := context sender) ~~ nil
	 and: [stack size < limit]] whileTrue: [
		stack addLast: context ].
	^ stack
]

{ #category : #private }
Context >> stackPtr [  
	"For use only by the SystemTracer and the Debugger, Inspectors etc"
	^ stackp
]

{ #category : #private }
Context >> stackp: newStackp [
	"Storing into the stack pointer is a potentially dangerous thing.
	This primitive stores nil into any cells that become accessible as a result,
	and it performs the entire operation atomically."
	"Once this primitive is implemented, failure code should cause an error"

	<primitive: 76>
	self error: 'stackp store failure'.
"
	stackp == nil ifTrue: [stackp := 0].
	newStackp > stackp  'effectively checks that it is a number'
		ifTrue: [oldStackp := stackp.
				stackp := newStackp.
				'Nil any newly accessible cells'
				oldStackp + 1 to: stackp do: [:i | self at: i put: nil]]
		ifFalse: [stackp := newStackp]
"
]

{ #category : #private }
Context >> startpc [
	^closureOrNil
		ifNil:	[self compiledCode initialPC]
		ifNotNil: [closureOrNil startpc]
]

{ #category : #controlling }
Context >> step [
	"Simulate the execution of the receiver's next bytecode. Answer the 
	context that would be the active context after this bytecode."

	^self interpretNextInstructionFor: self
]

{ #category : #'debugger access' }
Context >> stepIntoQuickMethod [
	^self compiledCode stepIntoQuickMethods
]

{ #category : #'debugger access' }
Context >> stepIntoQuickMethod: aBoolean [

	self compiledCode stepIntoQuickMethods: aBoolean
]

{ #category : #controlling }
Context >> stepToCallee [
	"Step to callee or sender"

	| context |
	context := self.
	[ (context := context step) == self ] whileTrue.
	^ context
]

{ #category : #controlling }
Context >> stepUntilSomethingOnStack [
	"Simulate the execution of bytecodes until either sending a message or 
	returning a value to the receiver (that is, until switching contexts)."

	| context |
	[ stackp = 0 ]
		whileTrue: [
			self isDead ifTrue: [ ^ self ].
			context := self step.
			context == self ifFalse: [
				"Caused by mustBeBoolean handling"
				^context ]]
]

{ #category : #'instruction decoding' }
Context >> storeIntoLiteralVariable: value [ 
	"Simulate the action of bytecode that stores the top of the stack into a 
	literal variable of my method."

	value value: self top
]

{ #category : #'instruction decoding' }
Context >> storeIntoReceiverVariable: offset [ 
	"Simulate the action of bytecode that stores the top of the stack into an 
	instance variable of my receiver."

	self object: self receiver instVarAt: offset + 1 put: self top
]

{ #category : #'instruction decoding' }
Context >> storeIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	"Simulate the action of bytecode that stores the top of the stack at
	 an offset in one of my local variables being used as a remote temp vector."

	(self at: tempVectorIndex + 1) at: remoteTempIndex + 1 put: self top
]

{ #category : #'instruction decoding' }
Context >> storeIntoTemporaryVariable: offset [ 
	"Simulate the action of bytecode that stores the top of the stack into one 
	of my temporary variables."

	self at: offset + 1 put: self top
]

{ #category : #'private - exceptions' }
Context >> swapReceiver: newReceiver [

	receiver := newReceiver
]

{ #category : #'debugger access' }
Context >> swapSender: coroutine [ 
	"Replace the receiver's sender with coroutine and answer the receiver's 
	previous sender. For use in coroutining."

	| oldSender |
	oldSender := sender.
	sender := coroutine.
	^oldSender
]

{ #category : #accessing }
Context >> tempAt: index [ 
	"Answer the value of the temporary variable whose index is the 
	 argument, index.  Primitive. Assumes receiver is indexable. Answer the
	 value of an indexable element in the receiver. Fail if the argument index
	 is not an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default at: primitive to give latitude to the
	 VM in context management."

	<primitive: 210>
	^self at: index
]

{ #category : #accessing }
Context >> tempAt: index put: value [ 
	"Store the argument, value, as the temporary variable whose index is the 
	 argument, index.  Primitive. Assumes receiver is indexable. Answer the
	 value of an indexable element in the receiver. Fail if the argument index
	 is not an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default at:put: primitive to give latitude to
	 the VM in context management."

	<primitive: 211>
	^self at: index put: value
]

{ #category : #controlling }
Context >> terminate [
	"Make myself unresumable."

	sender := nil.
	pc := nil.

]

{ #category : #controlling }
Context >> terminateTo: previousContext [
	"Terminate all the Contexts between me and previousContext, if previousContext is on my Context stack. Make previousContext my sender."

	| currentContext sendingContext |
	<primitive: 196>
	(self hasSender: previousContext) ifTrue: [
		currentContext := sender.
		[currentContext == previousContext] whileFalse: [
			sendingContext := currentContext sender.
			currentContext terminate.
			currentContext := sendingContext ]].
	sender := previousContext
]

{ #category : #controlling }
Context >> top [
	"Answer the top of the receiver's stack."

	^self at: stackp
]

{ #category : #private }
Context >> tryNamedPrimitiveIn: aCompiledMethod for: aReceiver withArgs: arguments [
	<primitive: 218 error: errorCode>
	errorCode ifNotNil: [
		"If errorCode is an integer other than -1 there was a problem with primitive 218,
		 not with the external primitive itself.  -1 indicates a generic failure (where
		 errorCode should be nil) but errorCode = nil means primitive 218 is not implemented.  So
		 interpret -1 to mean the external primitive failed with a nil error code."
		errorCode isInteger 
			ifTrue: [
				errorCode = -1
					ifTrue: [ errorCode := nil ]
					ifFalse: [ self primitiveFailed ]].
				^  self class primitiveFailTokenFor: errorCode ].
	"Assume a nil error code implies the primitive is not implemented and fall back on the old code."
	
	"The primitive doesn't exist or there was an error. Hence, we follow another solution without the primitive"
	^ self 
		withoutPrimitiveTryNamedPrimitiveIn: aCompiledMethod
		for: aReceiver
		withArgs: arguments

]

{ #category : #private }
Context >> tryPrimitiveFor: aMethod receiver: aReceiver args: arguments [ 
	"If this method has a primitive index, then run the primitive and return its result.
	Otherwise (and also if the primitive fails) return PrimitiveFailToken,
	as an indication that the method should be activated and run as bytecodes."
	| primIndex |
	(primIndex := aMethod primitive) = 0 
		ifTrue: [ ^ self class primitiveFailToken ].
	^ self doPrimitive: primIndex method: aMethod receiver: aReceiver args: arguments
]

{ #category : #'special context access' }
Context >> unwindBlock [
	"unwindContext only. access temporaries from BlockClosure>>#ensure: and BlockClosure>>#ifCurtailed:"
	^self tempAt: 1

]

{ #category : #'special context access' }
Context >> unwindComplete [
	"unwindContext only. access temporaries from BlockClosure>>#ensure: and BlockClosure>>#ifCurtailed:"
	^self tempAt: 2

]

{ #category : #'special context access' }
Context >> unwindComplete: aBoolean [
	"unwindContext only. access temporaries from BlockClosure>>#ensure: and BlockClosure>>#ifCurtailed:"
	self tempAt: 2 put: aBoolean

]

{ #category : #'private - exceptions' }
Context >> unwindForTermination [
	"Unwind to execute pending ensure:/ifCurtailed: blocks before terminating active process.
	It assumes that self belongs to the active process. "
	| unwindContext unwindBlock |
	unwindContext := self.
	[ unwindContext := unwindContext findNextUnwindContextUpTo: nil.
	unwindContext isNil ] whileFalse: [ 
		unwindContext unwindComplete ifNil: [ 
			"N.B. Unlike Context>>unwindTo: we do not set complete (tempAt: 2) to true."
			unwindBlock := unwindContext unwindBlock.
			self terminateTo: unwindContext.
			unwindBlock value ]].
	self terminateTo: nil
]

{ #category : #'private - exceptions' }
Context >> unwindTo: aContext [

	| context unwindBlock |
	context := self.
	[ (context := context findNextUnwindContextUpTo: aContext) isNil ] whileFalse: [
		(context unwindComplete) ifNil: [
			context unwindComplete: true.
			unwindBlock := context unwindBlock.
			unwindBlock value ]].

]

{ #category : #private }
Context >> withoutPrimitiveTryNamedPrimitiveIn: aCompiledMethod for: aReceiver withArgs: arguments [
"When using the debugger we want to run a method step by step. What what happens when we do a step into a CompiledMethod which has a primitive? If such a method is executed from outside the Debugger (normal scenario) the VM knows that such CompiledMethod has a primitive declaration and hence executes it. If it fails then it continues executing all the bytecodes of the method. Otherwise, it just returns. 

Now, what is the problem with the Debugger? The problem is that if the primitive fail, we don't want that the VM directly executes all the remaining bytecodes of the method. Instead, we would like to go step by step witht he Debugger, just as happens with normal methods. 

To solve the mentioned problem, we use the following trick: We have the orignal compiled method (the one that has a primitive invocation), the receiver and the arguments. So the idea is to use a template compiled method that ONLY contains the primitive declaration (it doesn't include all the smalltalk code after the primitive). #tryNamedPrimitiveTemplateMethod answers such a template method which looks like:

tryNamedPrimitive
	<primitive:'' module:''>
	^ Context primitiveFailToken'

Since this method does not change its bytecodes for every invocation, we can reuse it for all methods with primitives. There are only 2 things we have to change in the template: the number of arguments and the primitive declaration (to use the correct primitive name and module name).

Then what we do is to run that compiled method with the receiver and arguments we have. The result is that we will be invoking almost the same original method but a slighly different version that does not have the smalltalk part after the primitive and that in contrast sends #primitiveFailToken. If this method invocation does not fail, then the Debugger continues debugging the sender of the primitive method. In this case, the step in is the same as step over. If the primitive fails, then the debugger continues executing the smalltalk part after the primitive method. In this case, step in is a real step in."	
	| theMethod  |
	arguments size > 8 
		ifTrue: [ ^ self class primitiveFailToken ].
	theMethod := self class tryNamedPrimitiveTemplateMethod.
	theMethod prepareForSimulationWith: arguments size.
	theMethod == nil 
		ifTrue: [ ^ self class primitiveFailToken ].
	self setNamedPrimitiveInformationFrom: aCompiledMethod toMethod: theMethod.
	theMethod flushCache.
	
	^ theMethod valueWithReceiver: aReceiver arguments: arguments
]
