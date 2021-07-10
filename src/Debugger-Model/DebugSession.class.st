"
A DebugSession models a debugging session. It contains the interrupted context and process. Its main goal is to handle debugger actions such as restart or stepInto, as well as recompilation of methods. It is the model used as an input to a ui.

As it is just a model it does not contain any information related to the ui. For example, it does not know what a selection in the ui is. It is the job of the ui to maintain the selection and call this session with the proper context.

To create sessions use the method 'process: aProcess context: aContext'. aContext must be a context belonging to aProcess, and aProcess must be an interrupted process.

Instance Variables
	name:
	interruptedContext: Context
	interruptedProcess: Process
	errorWasInUIProcess: Boolean
	
interruptedContext
is the context which sent the signal message that eventually raised the exception that invoked the debugger. It can be different from the suspendedContext of the interruptedProcess, which is the top (“hot”) context the interruptedProcess’s context chain.
Why interruptedContext is different from the suspendedContext of the interruptedProcess:
Because the exception system is implemented in Pharo, the handling of the initial signal (eg in Object>>#halt), all the way to opening a debugger, is itself Pharo code, and exists as activations from suspendedContext to interruptedContext.  The debugger, with help from the exception system, carefully hides this processing from the programmer.  If it did not we would have to wade through many activations before we found where the exception occurred. When a process is interrupted by control period things are different.  Here, another process handles opening the debugger and suspendedContext and interruptedContext are the same.



"
Class {
	#name : #DebugSession,
	#superclass : #Object,
	#instVars : [
		'name',
		'interruptedContext',
		'interruptedProcess',
		'errorWasInUIProcess',
		'exception'
	],
	#classVars : [
		'LogDebuggerStackToFile'
	],
	#category : #'Debugger-Model-Core'
}

{ #category : #settings }
DebugSession class >> logDebuggerStackToFile [
	^ LogDebuggerStackToFile ifNil: [LogDebuggerStackToFile := true]
]

{ #category : #settings }
DebugSession class >> logDebuggerStackToFile: aBoolean [
	LogDebuggerStackToFile := aBoolean
]

{ #category : #'instance creation' }
DebugSession class >> named: aString on: aProcess startedAt: aContext [
	^ self new
		name: aString;
		process: aProcess context: aContext;
		detectUIProcess
]

{ #category : #'debugging actions' }
DebugSession >> clear [
	"If after resuming the process the user does plan to reuse this session with
	the same process, it should call this method."
	exception := nil.
	interruptedProcess := nil.
	self updateContextTo: nil
]

{ #category : #accessing }
DebugSession >> context [

	^ interruptedContext
]

{ #category : #context }
DebugSession >> contextChanged [

	self triggerEvent: #contextChanged
]

{ #category : #accessing }
DebugSession >> createModelForContext: aContext [

	^ (DebugContext forContext: aContext) topContext: interruptedContext
]

{ #category : #initialization }
DebugSession >> detectUIProcess [

	errorWasInUIProcess := UIManager default uiProcess == interruptedProcess 
	

]

{ #category : #context }
DebugSession >> downInContext: aContext [
	"move down the context stack to the previous (enclosing) context"

	self flag: 'This does not take into account (bypasses) filtering'.
	^ aContext sender 
]

{ #category : #accessing }
DebugSession >> errorWasInUIProcess [
	
	^ errorWasInUIProcess
]

{ #category : #initialization }
DebugSession >> errorWasInUIProcess: aBoolean [

	errorWasInUIProcess := aBoolean
]

{ #category : #accessing }
DebugSession >> exception [ 
	^ exception
]

{ #category : #accessing }
DebugSession >> exception: anObject [
	exception := anObject
]

{ #category : #evaluating }
DebugSession >> implement: aMessage classified: aSymbol inClass: aClass forContext: aContext [
	
	aClass
		compile: (DynamicMessageImplementor for: aMessage in: aClass) value
		classified: aSymbol.

	aContext privRefreshWith: (aClass lookupSelector: aMessage selector).
	aContext method numArgs > 0 ifTrue:
		[aMessage arguments withIndexDo:
			[:arg :index|
				aContext tempAt: index put: arg]].
		
	self updateContextTo: aContext.
	self contextChanged
]

{ #category : #private }
DebugSession >> installAlarm: aSelector [ 
	
	self installAlarm: aSelector withArgument: #()
]

{ #category : #private }
DebugSession >> installAlarm: aSelector withArgument: args [
	
	self currentWorld
		addAlarm: aSelector
		withArguments: args
		for: self
		at: Time millisecondClockValue + 200
]

{ #category : #accessing }
DebugSession >> interruptedContext [

	^ interruptedContext
]

{ #category : #accessing }
DebugSession >> interruptedProcess [

	^ interruptedProcess
]

{ #category : #testing }
DebugSession >> isAboutUIProcess [

	^errorWasInUIProcess 
]

{ #category : #testing }
DebugSession >> isContextPostMortem: selectedContext [
	"return whether we're inspecting a frozen exception without a process attached"
	| suspendedContext |
	suspendedContext := interruptedProcess suspendedContext.
	suspendedContext ifNil: [ ^ false ].
	^ (suspendedContext hasContext: selectedContext) not.
]

{ #category : #testing }
DebugSession >> isInterruptedContextATest [

	^ (self isTestObject: self interruptedContext receiver) and: [ self isTestMethod: self interruptedContext method of: self interruptedContext receiver ]
]

{ #category : #testing }
DebugSession >> isInterruptedContextDoesNotUnderstand [	
	
	^ self interruptedContext selector == #doesNotUnderstand:
]

{ #category : #context }
DebugSession >> isLatestContext: aContext [
  	^ interruptedProcess suspendedContext == aContext
]

{ #category : #testing }
DebugSession >> isTestMethod: aCompiledMethod of: aTestCase [

	^ aCompiledMethod selector = aTestCase selector
]

{ #category : #testing }
DebugSession >> isTestObject: anObject [

	"I'm not sure this is the best way to doit because it creates a coupling with TestCase, but due that SUnit is part of the core I think it is not bad after all - Hernan'"
	^ anObject isKindOf: TestCase
]

{ #category : #logging }
DebugSession >> logStackToFileIfNeeded [
	self class logDebuggerStackToFile ifFalse: [ ^self ].
	
	[[Smalltalk logError: name inContext: interruptedContext  ] onErrorDo: [ ]]
		valueWithin: 100 milliSeconds onTimeout: [  ]
]

{ #category : #accessing }
DebugSession >> name [
	^ name
]

{ #category : #accessing }
DebugSession >> name: aString [
	name := aString
]

{ #category : #context }
DebugSession >> pcRangeForContext: aContext [
	"Answer the indices in the source code for the method corresponding to 
	aContext's program counter value."

	(aContext isNil or: [ aContext isDead ])
		ifTrue: [ ^ 1 to: 0 ].
	^ aContext pcRangeContextIsActive: (self isLatestContext: aContext)
]

{ #category : #'debugging actions' }
DebugSession >> peelToFirstLike: aContext [
	"Peel the stack back to the second occurance of the currently selected message.  Very useful for an infinite recursion.  Gets back to the second call so you can see one complete recursion cycle, and how it was called at the beginning.  Also frees a lot of space!"

	| ctxt |
	self flag: 'should be called only on the selected context'.	
	(self isContextPostMortem: aContext) ifTrue: [^ self].

	ctxt := interruptedProcess popTo: aContext findSecondToOldestSimilarSender.
	self updateContextTo: ctxt.
	self contextChanged 

	
]

{ #category : #private }
DebugSession >> prepareTestToRunAgain [

	self interruptedContext receiver prepareToRunAgain
]

{ #category : #accessing }
DebugSession >> process [
	^ interruptedProcess
]

{ #category : #initialization }
DebugSession >> process: aProcess context: aContext [
	"aProcess stepToSendOrReturn"
	"aProcess isSuspended ifTrue: [ aProcess stepToSendOrReturn ]"

	interruptedProcess := aProcess.
	interruptedContext ifNil: [ interruptedContext := aContext ]
]

{ #category : #'debugging actions' }
DebugSession >> recompileMethodTo: text inContext: aContext notifying: aNotifyer [
	"The retrieved information has changed and its source must now be updated.
	 In this case, the retrieved information is the method of the given context."

	| newMethod recompilationContext canRewind |
	canRewind := (self isContextPostMortem: self interruptedContext) not.
	"Do not try to recompile a doIt method"
	aContext method isDoIt
		ifTrue: [ UIManager default alert:  'Can not modify a DoIt-Method.'.
			^ false ].
	(recompilationContext := (self createModelForContext: aContext) locateClosureHomeWithContent: text) ifNil: [ ^ false ].
	canRewind
		ifFalse: [ (self confirm: 'Can not rewind post mortem context for new method.\ Accept anyway ?' withCRs) or: [ ^ false ] ].
	newMethod := (self createModelForContext: recompilationContext) recompileCurrentMethodTo: text notifying: aNotifyer.
	newMethod ifNil: [ ^ false ].
	newMethod isQuick ifTrue: [
		recompilationContext := self downInContext: recompilationContext.
		recompilationContext pc: recompilationContext previousPc ].
	(self isContextPostMortem: self interruptedContext)
		ifFalse: [ self rewindContextToMethod: newMethod fromContext: recompilationContext ].

	"Use an alarm instead of triggering the notification directly, as the content of
	the editor can still be unaccepted. "
	self installAlarm: #contextChanged.
	^ true
]

{ #category : #'debugging actions' }
DebugSession >> restart: aContext [
	"Proceed from the initial state of selectedContext." 
	"Closing now depends on a setting (RestartAlsoProceeds class variable) --> not supported in this version"

	(self isContextPostMortem: aContext) ifTrue: [^ self].

	"Issue 3015 - Hernan"
	self isInterruptedContextATest ifTrue: [ self prepareTestToRunAgain ].
	self unwindAndRestartToContext: aContext.	

	self triggerEvent: #restart		
	
]

{ #category : #'debugging actions' }
DebugSession >> resume [
	"Proceed execution of the receiver's model, starting after the expression at 
	which an interruption occurred."

	"If the user of this session does not plan to reuse it, it should call 'self clean' "

	Smalltalk okayToProceedEvenIfSpaceIsLow
		ifFalse: [ ^ self ].
	(self isContextPostMortem: self interruptedContext)
		ifTrue: [ ^ self ].
	self resumeProcess.
	self triggerEvent: #resume
]

{ #category : #'debugging actions' }
DebugSession >> resume: aValue [
	"Proceed execution of the receiver's model, starting after the expression at 
	which an interruption occurred."

	"If the user of this session does not plan to reuse it, it should call 'self clean' "

	Smalltalk okayToProceedEvenIfSpaceIsLow
		ifFalse: [ ^ self ].
	(self isContextPostMortem: self interruptedContext)
		ifTrue: [ ^ self ].
	self resumeProcessWithValue: aValue.
	self triggerEvent: #resume
]

{ #category : #private }
DebugSession >> resumeProcess [
	"Make sure the interrupted process is restored properly and restart the low space handler"
	
	interruptedProcess isTerminated
		ifFalse: [ 
			errorWasInUIProcess
				ifTrue: [ UIManager default resumeUIProcess: interruptedProcess ]
				ifFalse: [ interruptedProcess resume ]].

	"restart low space handler"
	Smalltalk installLowSpaceWatcher
		
	
]

{ #category : #private }
DebugSession >> resumeProcessWithValue: aValue [
	"Make sure the interrupted process is restored properly and restart the low space handler"
	
	self returnValue: aValue from: interruptedProcess suspendedContext.
	self resumeProcess	
]

{ #category : #'debugging actions' }
DebugSession >> returnValue: anObject from: aContext [
	"Force a return of a given value to the previous context!"

	| previous |
	self flag: 'should be called only on the selected context. WHY?'.	
	(self isContextPostMortem: aContext) ifTrue: [^ self].

	previous := aContext sender.
	"self resetContext: previous."
	interruptedProcess popTo: previous value: anObject.
	self updateContextTo: previous.
	self contextChanged 
]

{ #category : #evaluating }
DebugSession >> rewindContextToMethod: aMethod fromContext: aContext [
	"this method is typically to be used after a hot compilation of a method from the stack.
	in order to return to the context containg the compiled method."
	| ctxt |
	ctxt :=  interruptedProcess popTo: aContext.
	
	ctxt == aContext
		ifFalse: [
			self inform: 'Method saved, but current context unchanged\because of unwind error. Click OK to see error' withCRs ]
		ifTrue: [
			aMethod isQuick ifFalse: [
				interruptedProcess restartTopWith: aMethod.
				self stepToFirstInterestingBytecodeIn: interruptedProcess ] ].
	self updateContextTo:  ctxt.
	
	"Issue 3015 - Hernan"
	self isInterruptedContextATest ifTrue: [ self prepareTestToRunAgain ]
]

{ #category : #'debugging actions' }
DebugSession >> runToSelection: selectionInterval inContext: aContext [ 
	"Attempt to step over instructions in selectedContext until the 
	execution reaches the selected instruction. This happens when the
	program counter passes the begining of selectionInterval.
	
	A not nill and valid interval is expected." 
	
	(self pcRangeForContext: aContext) first >= selectionInterval first 
		ifTrue: [ ^self ].
	self stepOver: aContext.
	[ aContext == self interruptedContext and: [ (self pcRangeForContext: aContext) first < selectionInterval first ] ] 
		whileTrue: [ self stepOver: aContext ]
]

{ #category : #accessing }
DebugSession >> selectedCodeRangeForContext: selectedContext [

	^ self pcRangeForContext: selectedContext
]

{ #category : #testing }
DebugSession >> shouldDisplayContext: aContext basedOnFilters: stackFilters [
	"Return true if all filters match the given context, or false otherwise.
	True is returned if there are no filters."
		
	^stackFilters allSatisfy: [ :aFilter | aFilter shouldDisplay: aContext ]
	
]

{ #category : #logging }
DebugSession >> signalDebuggerError: anError [

	DebuggerSettings emergencyDebugger
		debugError: anError
		fromSession: self
]

{ #category : #accessing }
DebugSession >> stack [

	^ interruptedContext stack
]

{ #category : #accessing }
DebugSession >> stackOfSize: size [

	^ interruptedContext stackOfSize: size
]

{ #category : #accessing }
DebugSession >> stackOfSize: limit usingFilters: stackFilters [
	"Answer an OrderedCollection of the top 'limit' contexts on the receiver's sender chain, according to the given filters.
	
	Consider the following stack:   
		a <-- top of the stack
		b
		a
		c
		a
		b
		d
		e
		a <-- bottom of the stack
		
	If the given filters do not match context 'a' and 'b' the following stack will be returned:
		a <-- top of the stack
		b
		a
		c
		d
		e <-- bottom of the stack
		
	First all consecutive contexts starting from the top of the stack for which a filter does not match are 
	added to the result (a b a in the example). Then from the remaining stack only the context for which all
	filters match are added to the  result.
	"

	| stack context |
	stack := OrderedCollection new.
	context := interruptedContext.
	
	"Starting from the top of the stack add all consecutive contexts that should not be displayed."
	[ context ~~ nil
	 	and: [(stack size < limit)
			and: [ (self shouldDisplayContext: context basedOnFilters:  stackFilters) not ] ] ]  whileTrue: [
				stack addLast: context.
				context := context sender ].

	"Add all contexts that should be displayed. (the current context is checked again)"
	[context ~~ nil
		and: [stack size < limit ] ] whileTrue: [
			(self shouldDisplayContext: context basedOnFilters: stackFilters) 
				ifTrue: [ stack addLast: context ].
			context := context sender ].
	^ stack
]

{ #category : #'debugging actions' }
DebugSession >> stepInto [

	self stepInto: interruptedContext
]

{ #category : #'debugging actions' }
DebugSession >> stepInto: aContext [
	"Send the selected message in selectedContext, and take control in 
	the method invoked to allow further step or send."

	(self isContextPostMortem: aContext) ifTrue: [^ self].

	interruptedProcess step: aContext.
	self updateContextTo: (self stepToFirstInterestingBytecodeIn: interruptedProcess).
	
	self triggerEvent: #stepInto
]

{ #category : #'debugging actions' }
DebugSession >> stepIntoUntil: aBlock [
	[ aBlock cull: interruptedContext ]
		whileFalse: [ self stepInto: interruptedContext ]
]

{ #category : #'debugging actions' }
DebugSession >> stepOver [

	self stepOver: interruptedContext
]

{ #category : #'debugging actions' }
DebugSession >> stepOver: aContext [
	"Send the selected message in selectedContext, and regain control 
	after the invoked method returns."
	
	| newContext |
	aContext stepIntoQuickMethod: false.
	(self isContextPostMortem: aContext) ifTrue: [^ self].
	
	newContext := interruptedProcess completeStep: aContext.
	self updateContextTo:  
		(newContext == aContext
			ifTrue: [ (self stepToFirstInterestingBytecodeIn: interruptedProcess) ]
			ifFalse: [ newContext ]).

	self triggerEvent: #stepOver 
]

{ #category : #'debugging actions' }
DebugSession >> stepThrough [

	self stepThrough: interruptedContext
]

{ #category : #'debugging actions' }
DebugSession >> stepThrough: aContext [
	"Send messages until you return to selectedContext.
	 Used to step into a block in the method."
	aContext stepIntoQuickMethod: false.
	(self isContextPostMortem: aContext) ifTrue: [^ self].
	
	interruptedProcess stepToHome: aContext.
	self updateContextTo: (self stepToFirstInterestingBytecodeIn: interruptedProcess).
			
	self triggerEvent: #stepThrough 
]

{ #category : #private }
DebugSession >> stepToFirstInterestingBytecodeIn: aProcess [
	"After a restart of a method activation step to the first 
	bytecode instruction that is of interest for the debugger.
	
	In this case step until a bytecode that causes a context switch,
	as otherwise one will have to press may time step into without 
	seeing any visible results."
	
	^ aProcess stepToSendOrReturn
]

{ #category : #'debugging actions' }
DebugSession >> terminate [
	"Action that needs to be executed after the window containing this debug session is closed, 
	in order to terminate the right process."
	
	self interruptedProcess 
		ifNotNil: [ 
			"Assume the user closed the debugger. Simply kill the interrupted process."
			self interruptedProcess terminate.
			self clear.
			Smalltalk installLowSpaceWatcher.  "restart low space handler" ]
		ifNil: [ 
			"Assume the interrupted process was resumed."
			"Kill the active process if the error was in the UI as there should be only one UI process."
			self isAboutUIProcess
				ifTrue: [Processor terminateActive] ]
	
]

{ #category : #evaluating }
DebugSession >> unwindAndRestartToContext: aContext [

	| ctx |
	ctx := interruptedProcess popTo: aContext.
	ctx == aContext ifTrue: [ "Only restart the process if the stack was unwind"
		interruptedProcess restartTop.

		aContext method isQuick
			ifTrue: [ aContext updatePCForQuickPrimitiveRestart ]
			ifFalse: [ 
			self stepToFirstInterestingBytecodeIn: interruptedProcess ] ].
	self flag: 'Should a warning be displayed if the the unwind failed?'.
	self updateContextTo: aContext
]

{ #category : #context }
DebugSession >> updateContextTo: aContext [

	interruptedContext := aContext
]

{ #category : #updating }
DebugSession >> updateWithContext: newContext fromProcess: aProcess [

	self process: aProcess context: newContext
]
