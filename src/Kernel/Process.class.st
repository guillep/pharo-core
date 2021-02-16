"
I represent an independent path of control in the system. This path of control may be stopped (by sending the message suspend) in such a way that it can later be restarted (by sending the message resume). When any one of several paths of control can be advanced, the single instance of ProcessorScheduler named Processor determines which one will actually be advanced partly using the value of priority.

(If anyone ever makes a subclass of Process, be sure to use allSubInstances in anyProcessesAbove:.)


Process-specific storage: 

	An old implementation using #environmentAt: [ifAbsent:/put:] protocol are no longer supported.
	One must not use a process-specific storage (PSS) methods directly, and instead use ProcessSpecificVariable (or subclass) instances to access process-specific storage.
	
A new implemention is a revision towards making an access to PSS faster.

When new instance of ProcessSpecificVariable are created, it obtains an unique index, which is registered using #allocatePSKey: (see class side).
This allows to dynamically create as many process-specific variables as needed, and access them in fast manner via simple array index (instead of dictionary lookup,
as in previous implementation).

Another important aspect of new implementation is that all values in PSS are held weakly. This is done to prevent accidental memory leaks
as well as no need to manually unregistering a process-specific keys , once they are no longer in use.
"
Class {
	#name : #Process,
	#superclass : #Link,
	#instVars : [
		'suspendedContext',
		'priority',
		'myList',
		'name',
		'env',
		'effectiveProcess',
		'terminating',
		'level'
	],
	#classVars : [
		'InheritablePSKeys',
		'PSKeys',
		'PSKeysSema'
	],
	#category : #'Kernel-Processes'
}

{ #category : #'process specific' }
Process class >> allocatePSKey: aPSVariable [

	"Add a new process-specific key. 
	If an object already registered as a key, answer its index,
	if object is not registered, first search for an empty slot for insertion and if not found, grow an array to add new object"

	| index |
	self psKeysSema critical: [
		PSKeys 
			ifNil: [ PSKeys := WeakArray with: aPSVariable. index := 1 ]
			ifNotNil: [ 
				index := PSKeys indexOf: aPSVariable.
				index = 0 ifTrue: [
					index := PSKeys indexOf: nil.
					index = 0 
						ifTrue: [
							index := (PSKeys := PSKeys copyWith: aPSVariable) size ]
						ifFalse: [
							"Yes, this is slow, but we have to make sure that if we reusing index,
							all existing processes having value at given index reset to nil.
							We don't care if new processes will be created during this loop,
							since their env variable will be initially nil anyways, hence nothing to reset "
							Process allSubInstancesDo: [:p | p resetPSValueAt: index ].
							PSKeys at: index put: aPSVariable.
							]
				]
			].

		aPSVariable isInheritable ifTrue: [ 
			InheritablePSKeys 
				ifNil: [ InheritablePSKeys := Array with: index ]
				ifNotNil: [ 
					(InheritablePSKeys includes: index) ifFalse: [ InheritablePSKeys := InheritablePSKeys copyWith: index ]]
		]
	].

	^ index
]

{ #category : #'instance creation' }
Process class >> forContext: aContext priority: anInteger [ 
	"Answer an instance of me that has suspended aContext at priority 
	anInteger."

	| newProcess |
	newProcess := self new.
	newProcess suspendedContext: aContext.
	newProcess priority: anInteger.
	Processor activeProcess installEnvIntoForked: newProcess.
	^newProcess
]

{ #category : #'process specific' }
Process class >> psKeysSema [
	"Isolate handling of class variable"

	^PSKeysSema ifNil: [ PSKeysSema := Semaphore forMutualExclusion ]
]

{ #category : #'process specific' }
Process class >> updateInheritableKeys [
"
	self updateInheritableKeys
"
	| keys |
	keys := Set new.
	ProcessSpecificVariable allSubclasses select: [ :each | each isInheritable ] thenDo: [ :each | keys add: each soleInstance index].
	  
	InheritablePSKeys := keys asArray ifEmpty: [ nil ]
]

{ #category : #'changing suspended state' }
Process >> activateReturn: aContext value: value [
	"Activate 'aContext return: value', so execution will return to aContext's sender"

	^Processor activeProcess
		evaluate: [suspendedContext := suspendedContext activateReturn: aContext value: value]
		onBehalfOf: self
]

{ #category : #printing }
Process >> browserPrintString [
	^self browserPrintStringWith: suspendedContext
]

{ #category : #printing }
Process >> browserPrintStringWith: anObject [ 
	| stream |
	stream := (String new: 100) writeStream.
	stream nextPut: $(.
	priority printOn: stream.
	self isSuspended
		ifTrue: [stream nextPut: $s].
	stream nextPutAll: ') '.
	stream nextPutAll: self name.
	stream nextPut: $:.
	stream space.
	stream nextPutAll: anObject asString.
	^ stream contents
]

{ #category : #accessing }
Process >> calleeOf: aContext [
	"Return the context whose sender is aContext.  Return nil if aContext is on top.  Raise error if aContext is not in process chain."

	suspendedContext == aContext ifTrue: [^ nil].
	^ (suspendedContext findContextSuchThat: [:c | c sender == aContext])
		ifNil: [self error: 'aContext not in process chain']
]

{ #category : #testing }
Process >> canBeStepped [
	self isTerminated ifTrue: [ ^false ].
	
	^suspendedContext canBeSteppedSafely 
]

{ #category : #'changing suspended state' }
Process >> complete: aContext [
	"Run self until aContext is popped or an unhandled error is raised.  Return self's new top context, unless an unhandled error was raised then return the signal context (rather than open a debugger)."

	| ctxt pair |
	ctxt := suspendedContext.
	suspendedContext := nil.	"disable this process while running its stack in active process below"
	pair := Processor activeProcess
				evaluate: [ ctxt runUntilErrorOrReturnFrom: aContext ]
				onBehalfOf: self.
	suspendedContext := pair first.
	^ pair second
		ifNil: [ suspendedContext ]
		ifNotNil: [ :error | error completeProcess: self with: aContext ]
]

{ #category : #'changing suspended state' }
Process >> completeStep: aContext [ 
	"Resume self until aContext is on top, or if already on top, complete next step"

	| callee |
	self suspendedContext == aContext ifFalse: [
		^ self complete: (self calleeOf: aContext)].
	callee := self step.
	callee == aContext ifTrue: [^ callee].
	aContext isDead ifTrue: [^ self suspendedContext].  "returned"
	^ self complete: callee  "finish send"
]

{ #category : #'changing suspended state' }
Process >> completeTo: aContext [ 
	"Resume self until aContext is on top"

	self suspendedContext == aContext ifTrue: [^ aContext].
	^ self complete: (self calleeOf: aContext)
]

{ #category : #accessing }
Process >> copyStack [

	^ self copy install: suspendedContext copyStack
]

{ #category : #debugging }
Process >> debug [
	^ self debugWithTitle: 'Debug'.
]

{ #category : #debugging }
Process >> debugWithTitle: title [

	| context |
	context := self isActiveProcess
		           ifTrue: [ thisContext ]
		           ifFalse: [ self suspendedContext ].
	UIManager default
		requestDebuggerOpeningForProcess: self
		named: title
		inContext: context
]

{ #category : #private }
Process >> doTerminationFromAnotherProcess [ 
	"Stop this process forever from another process.  
	Unwind to execute pending ensure:/ifCurtailed: blocks before terminating.
	It assumes that self is not the active process
	and the termination is requested from another process"
	| ctxt oldList |
	self isTerminating ifTrue: [ ^ ProcessAlreadyTerminating signal ].
	terminating := true.
	"Always suspend the process first so it doesn't accidentally get woken up"
	oldList := self suspend.
	suspendedContext ifNil: [^self].

	"Figure out if we are terminating the process while waiting inside special object like
	in Semaphore>>critical:. So if waiting object is interesting on this situation we will ask it to handle it. In case of Semaphore>>critical, Semaphore will pop the suspendedContext so that we leave the ensure: block inside	Semaphore>>critical: without signaling the semaphore.
	This methods allow to not be restricted only on Semaphore case."
	suspendedContext := oldList handleProcessTerminationOfWaitingContext: suspendedContext.
	"If we are terminating a process halfways through an unwind, try to complete that unwind block first."
	(suspendedContext findNextUnwindContextUpTo: nil) ifNotNil: [:outer |
		(suspendedContext findContextSuchThat: [ :c | c closure == outer unwindBlock ]) ifNotNil: [ :inner |
			"This is an unwind block currently under evaluation"
			suspendedContext runUntilErrorOrReturnFrom: inner ] ].		
	ctxt := self popTo: suspendedContext bottomContext.
	[ ctxt == suspendedContext bottomContext ] whileFalse: [
		"There was a problem during termination. Make the user aware of the problem
		but ensure that the current process will be properly terminated."
		| stackCopy |
		stackCopy := ctxt copyStack.
		[ UnwindError signalIn: stackCopy ] forkNamed: 'Unwind error during termination'.
		ctxt terminateTo: ctxt sender.
		ctxt := self popTo: suspendedContext bottomContext ].
	"The suspendedContext of process that has never run will have 
	a pc equal to the startpc. #isTerminate would thus answer false
	even though the process is dead. To prevent that we set the pc
	of the suspendedContext to nil (#isDead ---> true)."
	(suspendedContext notNil and: [ suspendedContext isBottomContext ]) ifTrue: [
		suspendedContext pc: nil ]
]

{ #category : #private }
Process >> doTerminationFromYourself [ 
	"Stop this process forever from the process itself. 
	Unwind to execute pending ensure:/ifCurtailed: blocks before terminating.
	It assumes that self is the active process. "
	terminating := true.
	thisContext unwindForTermination.
	self suspend
]

{ #category : #accessing }
Process >> effectiveProcess [
	"effectiveProcess is a mechanism to allow process-faithful debugging.  The debugger executes code
	 on behalf of processes, so unless some effort is made the identity of Processor activeProcess is not
	 correctly maintained when debugging code.  The debugger uses evaluate:onBehalfOf: to assign the
	 debugged process as the effectiveProcess of the process executing the code, preserving process
	 identity."
	^effectiveProcess ifNil: [self] 
]

{ #category : #accessing }
Process >> effectiveProcess: aProcess [ 
	effectiveProcess := aProcess
]

{ #category : #private }
Process >> evaluate: aBlock onBehalfOf: aProcess [
	"Evaluate aBlock setting effectiveProcess to aProcess.  Used
	 in the execution simulation machinery to ensure that
	 Processor activeProcess evaluates correctly when debugging."
	| oldEffectiveProcess |
	oldEffectiveProcess := effectiveProcess.
	effectiveProcess := aProcess.
	^aBlock ensure: [effectiveProcess := oldEffectiveProcess]
]

{ #category : #initialization }
Process >> initialize [
	super initialize.
	
	terminating := false
]

{ #category : #'changing suspended state' }
Process >> install: aContext [ 
	"Replace the suspendedContext with aContext."

	self == Processor activeProcess
		ifTrue: [^self error: 'The active process cannot install contexts'].
	suspendedContext := aContext
]

{ #category : #'process specific' }
Process >> installEnvIntoForked: newProcess [
	env ifNil: [ ^ self ].
	InheritablePSKeys ifNil: [ ^self ].

	"InheritablePSKeys includes indices of all inheritable variables"
	1 to: InheritablePSKeys size do: [ :i | | varIndex varValue |
		varIndex := InheritablePSKeys at: i.
		(varIndex <= env size) "if new variable was installed into system existed processes env can not have room for it"
			ifTrue: [ 
				varValue := env at: varIndex.
				varValue ifNotNil: [ (PSKeys at: varIndex) installValue: varValue intoForked: newProcess from: self ] ]]
]

{ #category : #testing }
Process >> isActiveProcess [

	^ self == Processor activeProcess
]

{ #category : #testing }
Process >> isSuspended [
	"Answer true if I was never scheduled yet (new process, never been sent #resume) or paused (was sent #suspend)"
	self isActiveProcess ifTrue: [ ^false ].
	self isTerminated ifTrue: [ ^false ].
	^myList isNil or: [ myList isEmpty ]
]

{ #category : #testing }
Process >> isTerminated [
	self isActiveProcess ifTrue: [ ^ false ].
	
	^ suspendedContext isNil or: [
		"If the suspendedContext is the bottomContext it is the block in Process>>newProcess.
		If so, and the pc is greater than the startpc, the block has already sent and returned
		from value and there is nothing more to do."
		suspendedContext isBottomContext and: [
			suspendedContext isDead or: [
				"The pc of the suspendedContext is set to nil in #terminate explicitly.
				Leaving this line in for safety."
  	  			suspendedContext pc > suspendedContext startpc ] ] ]

]

{ #category : #testing }
Process >> isTerminating [
	"lazy initialization is a fallback only for processes that existed before this addition"
	^ terminating ifNil: [ false ]
]

{ #category : #printing }
Process >> longPrintOn: stream [
	| ctxt |
	super printOn: stream.
	stream cr.
	ctxt := self suspendedContext.
	[ ctxt isNil ]
		whileFalse: [ 
			stream space.
			ctxt printOn: stream.
			stream cr.
			ctxt := ctxt sender ]
]

{ #category : #accessing }
Process >> name [
 
 	^name ifNil: [ self hash asString forceTo: 10 paddingStartWith: $ ]
]

{ #category : #accessing }
Process >> name: aString [

	name := aString
]

{ #category : #signaling }
Process >> on: exception do: handlerAction [
	"This method inject new bottom context into process with exception handler. 
	It uses context jump tricks to achieve it"
	| currentContext root newRoot |
	currentContext := self isActiveProcess ifTrue: [ thisContext ] ifFalse: [self suspendedContext].
	root := currentContext bottomContext.
	newRoot := [
			[root insertSender: thisContext.
			currentContext jump] on: exception do: handlerAction.
		Processor terminateRealActive] asContext.

	self isActiveProcess 
		ifTrue: [ newRoot jump ]
		ifFalse: [ self install: newRoot ]
]

{ #category : #'changing suspended state' }
Process >> popTo: aContext [ 
	"Pop self down to aContext by remote returning from aContext's callee.  Unwind blocks will be executed on the way.
	This is done by pushing a new context on top which executes 'aContext callee return' then resuming self until aContext is reached.  This way any errors raised in an unwind block will get handled by senders in self and not by senders in the activeProcess.
	If an unwind block raises an error that is not handled then the popping stops at the error and the signalling context is returned, othewise aContext is returned."

	self == Processor activeProcess ifTrue:
		[^self error: 'The active process cannot pop contexts'].
	^(self calleeOf: aContext)
		ifNil: [aContext]  "aContext is on top"
		ifNotNil:
			[:callee|
			 Processor activeProcess
				evaluate: [self return: callee value: callee receiver]
				onBehalfOf: self]
]

{ #category : #'changing suspended state' }
Process >> popTo: aContext value: aValue [
	"Replace the suspendedContext with aContext, releasing all contexts 
	 between the currently suspendedContext and it."

	self == Processor activeProcess ifTrue:
		[^self error: 'The active process cannot pop contexts'].
	^(self calleeOf: aContext)
		ifNil: [aContext]  "aContext is on top"
		ifNotNil:
			[:callee|
			 Processor activeProcess
				evaluate: [self return: callee value: aValue]
				onBehalfOf: self]
]

{ #category : #'changing process state' }
Process >> primitiveResume [
	"Primitive. Allow the process that the receiver represents to continue. Put 
	the receiver in line to become the activeProcess. Fail if the receiver is 
	already waiting in a queue (in a Semaphore or ProcessScheduler). 
	Essential. See Object documentation whatIsAPrimitive."

	<primitive: 87>
	self primitiveFailed
]

{ #category : #printing }
Process >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: ' in '.
	suspendedContext printOn: aStream
]

{ #category : #accessing }
Process >> priority [
	"Answer the priority of the receiver."

	^priority
]

{ #category : #accessing }
Process >> priority: anInteger [
	"Set the receiver's priority to anInteger."

	(anInteger between: Processor lowestPriority and: Processor highestPriority)
		ifTrue: [ priority := anInteger ]
		ifFalse: [ self error: 'Invalid priority: ' , anInteger printString ]
]

{ #category : #'process specific' }
Process >> psValueAt: index [
	"Answer a process-specific value at given index, or nil if value at given index is not defined"
	
	"NOTE: this method are PRIVATE. Do not use it directly, instead use ProcessSpecificVariable (or its subclasses) "
	env ifNil: [ ^ nil ].
	^ env at: index ifAbsent: nil
]

{ #category : #'process specific' }
Process >> psValueAt: index put: value [
	"Set a value for given index in process-specific storage"

	"NOTE: this method are PRIVATE. Do not use it directly, instead use ProcessSpecificVariable (or its subclasses) "

	env ifNil: [ env := WeakArray new: PSKeys size ].
	env size < PSKeys size ifTrue: [ env := env grownBy: PSKeys size - env size ].
	^ env at: index put: value.
]

{ #category : #signaling }
Process >> pvtSignal: anException list: aList [
	"Private. This method is used to signal an exception from another
	process...the receiver must be the active process.  If the receiver 
	was previously waiting on a Semaphore, then return the process
	to the waiting state after signaling the exception and if the Semaphore
	has not been signaled in the interim"

	"Since this method is not called in a normal way, we need to take care
	that it doesn't directly return to the caller (because I believe that could
	have the potential to push an unwanted object on the caller's stack)."
	<debuggerCompleteToSender>
	| blocker |
	self isActiveProcess ifFalse: [^self].
	anException signal.
	blocker := Semaphore new.
	[self suspend.
	suspendedContext := suspendedContext swapSender: nil.
	aList class == Semaphore 
		ifTrue:
			[aList isSignaled
				ifTrue: 
					[aList wait.  "Consume the signal that would have restarted the receiver"
					self resume]
				ifFalse:
					["Add us back to the Semaphore's list (and remain blocked)"
					myList := aList.
					aList add: self]]
		ifFalse: [self resume]] fork.
	blocker wait.



]

{ #category : #'process specific' }
Process >> resetPSValueAt: index [

	"NOTE: this method are PRIVATE. "

	env ifNil: [ ^ self ]. 
	index > env size ifTrue: [ ^ self ].
	
	env at: index put: nil
]

{ #category : #'changing suspended state' }
Process >> restartTop [
	"Rollback top context and replace with new method.  Assumes self is suspended"

	suspendedContext privRefresh
]

{ #category : #'changing suspended state' }
Process >> restartTopWith: method [
	"Rollback top context and replace with new method.  Assumes self is suspended"

	method isQuick 
		ifTrue: [ self popTo: suspendedContext sender ]
		ifFalse: [ suspendedContext privRefreshWith: method ].

]

{ #category : #'changing process state' }
Process >> resume [
	"Allow the process that the receiver represents to continue. Put  
	the receiver in line to become the activeProcess. Check for a nil 
	suspendedContext, which indicates a previously terminated Process that 
	would cause a vm crash if the resume attempt were permitted"

	suspendedContext ifNil: [^ self primitiveFailed].
	^ self primitiveResume
]

{ #category : #'changing suspended state' }
Process >> return: aContext value: value [
	"Pop thread down to aContext's sender.  Execute any unwind blocks on the way.  See #popTo: comment and #runUntilErrorOrReturnFrom: for more details."

	suspendedContext == aContext ifTrue:
		[^Processor activeProcess
			evaluate: [suspendedContext := aContext return: value from: aContext]
			onBehalfOf: self].
	self activateReturn: aContext value: value.
	^self complete: aContext
]

{ #category : #'changing process state' }
Process >> run [
	"Suspend current process and execute self instead"

	| proc |
	proc := Processor activeProcess.
	[	proc suspend.
		self resume.
	] forkAt: Processor highestPriority
]

{ #category : #signaling }
Process >> signalException: anException [
	"Signal an exception in the receiver process...if the receiver is currently
	suspended, the exception will get signaled when the receiver is resumed.  If 
	the receiver is blocked on a Semaphore, it will be immediately re-awakened
	and the exception will be signaled; if the exception is resumed, then the receiver
	will return to a blocked state unless the blocking Semaphore has excess signals"
	| oldList |
	"If we are the active process, go ahead and signal the exception"
	self isActiveProcess ifTrue: [^anException signal].

	"Suspend myself first to ensure that I won't run away in the
	midst of the following modifications."
	myList ifNotNil:[oldList := self suspend].

	"Add a new method context to the stack that will signal the exception"
	suspendedContext := Context
		sender: suspendedContext
		receiver: self
		method: (self class lookupSelector: #pvtSignal:list:)
		arguments: (Array with: anException with: oldList).

	"If we are on a list to run, then suspend and restart the receiver 
	(this lets the receiver run if it is currently blocked on a semaphore).  If
	we are not on a list to be run (i.e. this process is suspended), then when the
	process is resumed, it will signal the exception"

	oldList ifNotNil: [self resume].

]

{ #category : #'changing suspended state' }
Process >> step [

	^Processor activeProcess
		evaluate: [suspendedContext := suspendedContext step]
		onBehalfOf: self
]

{ #category : #'changing suspended state' }
Process >> step: aContext [ 
	"Resume self until aContext is on top, or if already on top, do next step"

	^Processor activeProcess
		evaluate:
			[self suspendedContext == aContext
				ifTrue: [suspendedContext := suspendedContext step]
				ifFalse: [self complete: (self calleeOf: aContext)]]
		onBehalfOf: self
]

{ #category : #'changing suspended state' }
Process >> stepToCallee [
	"Step until top context changes"

	Processor activeProcess
		evaluate:
			[| ctxt |
			ctxt := suspendedContext.
			[ctxt == suspendedContext] whileTrue: [
				suspendedContext := suspendedContext step]]
		onBehalfOf: self.
	^suspendedContext
]

{ #category : #'changing suspended state' }
Process >> stepToHome: aContext [ 
	| ctxt pair error |
	ctxt := suspendedContext.
	suspendedContext := nil.
	pair := Processor activeProcess
				evaluate: [ctxt stepToHome: aContext]
				onBehalfOf: self.
	suspendedContext := pair first.
	error := pair second.

	error ifNotNil: [
		suspendedContext := error signalerContext.
		"As we are activating a context that has been interrupted in the signal of the exception,
		we need to push a receiver of the signal message.
		A suspended context should always be a top context.
		A top context has the return value of the message in the stack.
		As this context has been suspended while sending a message the return value should be pushed. 
		This is maybe not the expected return value (the #signal message returns the value with the 
		one the exception is resumed).
		But this allows the debugger to continue executing and does not crash the interpreter nor 
		the VM
		"
		suspendedContext push: nil].
	^ suspendedContext
]

{ #category : #'changing suspended state' }
Process >> stepToSendOrReturn [

	^Processor activeProcess
		evaluate: [suspendedContext := suspendedContext stepToSendOrReturn]
		onBehalfOf: self
]

{ #category : #'changing process state' }
Process >> suspend [
	"Primitive. Stop the process that the receiver represents in such a way 
	that it can be restarted at a later time (by sending the receiver the 
	message resume). If the receiver represents the activeProcess, suspend it. 
	Otherwise remove the receiver from the list of waiting processes.
	The return value of this method is the list the receiver was previously on (if any)."
	| oldList |
	<primitive: 88>
	"This is fallback code for VMs which only support the old primitiveSuspend which 
	would not accept processes that are waiting to be run."
	myList ifNil:[^nil]. "this allows us to use suspend multiple times"
	oldList := myList.
	myList := nil.
	oldList remove: self ifAbsent:[].
	^oldList
]

{ #category : #accessing }
Process >> suspendedContext [
	"Answer the context the receiver has suspended."

	^suspendedContext
]

{ #category : #private }
Process >> suspendedContext: aContext [

	suspendedContext := aContext
]

{ #category : #accessing }
Process >> suspendingList [
	"Answer the list on which the receiver has been suspended."

	^myList
]

{ #category : #'changing process state' }
Process >> terminate [ 
	"Stop the process that the receiver represents forever.  Unwind to execute pending ensure:/ifCurtailed: blocks before terminating."
	self isActiveProcess 
		ifTrue: [ self doTerminationFromYourself ]
		ifFalse: [ self doTerminationFromAnotherProcess]
]
