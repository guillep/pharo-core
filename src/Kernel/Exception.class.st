"
This is the main class used to implement the exception handling system (EHS).  It plays two distinct roles:  that of the exception, and that of the exception handler.  More specifically, it implements the bulk of the protocols laid out in the ANSI specification - those protocol names are reflected in the message categories.

Exception is an abstract class.  Instances should neither be created nor trapped.  In most cases, subclasses should inherit from Error or Notification rather than directly from Exception.

Exceptions have an optional #messageText that can be set when they are signaled.
Exceptions also have the concept of #signaler, the object that is the subject of the exception.
This will be set automatically (to the #receiver), but can be set when the exception is signaled. 

In implementing this EHS, The Fourth Estate Inc. incorporated some ideas and code from Craig Latta's EHS.  His insights were crucial in allowing us to implement Context>>valueUninterruptably (and by extension, #ensure: and #ifCurtailed:), and we imported the following methods with little or no modification:

Context>>terminateTo:
Context>>terminate
Context>>receiver:
Context>>answer:

Thanks, Craig!
"
Class {
	#name : #Exception,
	#superclass : #Object,
	#instVars : [
		'messageText',
		'tag',
		'signaler',
		'signalContext',
		'handlerContext',
		'outerContext'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #exceptionselector }
Exception class >> , anotherException [
	"Create an exception set containing the receiver and anotherException"

	^ ExceptionSet new
		add: self;
		add: anotherException;
		yourself
]

{ #category : #exceptionselector }
Exception class >> - anotherException [
	"Create an exception set containing the receiver and anotherException as exclusion."

	^ ExceptionSetWithExclusions new
		add: self;
		addExclusion: anotherException;
		yourself
]

{ #category : #exceptionselector }
Exception class >> handles: exception [
	"Determine whether an exception handler will accept a signaled exception."

	^ exception isKindOf: self
]

{ #category : #exceptioninstantiator }
Exception class >> signal [
	"Signal the occurrence of an exceptional condition."

	^ self new signal
]

{ #category : #exceptioninstantiator }
Exception class >> signal: message [
	"Signal the occurrence of an exceptional condition with a specified textual description."

	^ self new signal: message
]

{ #category : #exceptioninstantiator }
Exception class >> signal: message in: context [
	"Signal the occurrence of an exceptional condition with a specified textual description in the given context."

	^ self new 
		messageText: message;
		signalIn: context
]

{ #category : #exceptioninstantiator }
Exception class >> signal: message withTag: aTag [
	"Signal the occurrence of an exceptional condition with a specified textual description including a tag for the exception."

	^ self new 
		messageText: message;
		tag: aTag; 
		signal
]

{ #category : #exceptioninstantiator }
Exception class >> signalIn: context [
	"Signal the occurrence of an exceptional condition in the given context."

	^ self new signalIn: context
]

{ #category : #private }
Exception >> completeProcess: aProcess with: aContext [
	"I am a hook during process completion in case one of my subclass wants to plug a special behavior.
	
	By default I return my signal context"

	^ self signalContext
]

{ #category : #handling }
Exception >> debug [

	"requests a debugger on myself"

	<debuggerCompleteToSender>
	UIManager default requestDebuggerOpeningFor: self
]

{ #category : #handling }
Exception >> defaultAction [
	"No one has handled this error, but now give them a chance to decide how to debug it. 
	If none handles this either then open debugger (see UnhandedError-defaultAction).
	
	Note about naming here: 
	Even if not all exceptions are errors the absence of a handler for signaled exception is considered as an error by default. Therefore #defaultAction for Exception raises an error, an UnhandledError"

	^ self raiseUnhandledError
]

{ #category : #default }
Exception >> defaultDescription [
	"Return a textual description of the exception."

	^ String streamContents: [ :stream | | mt |
		stream << self class name.
		(mt := self messageText) isEmptyOrNil
			ifFalse: [ stream << ': ' << mt ] ]
]

{ #category : #private }
Exception >> defaultResumeValue [
	"Answer the value that by default should be returned if the exception is resumed"
	
	^ nil
]

{ #category : #private }
Exception >> defaultReturnValue [
	"Answer the value that by default should be returned if the exception is returned"
	
	^ nil
]

{ #category : #accessing }
Exception >> description [

	"Returns a textual description of the exception."

	"Must be overriden to return a specialized description "

	^ self defaultDescription
]

{ #category : #handling }
Exception >> freeze [
	"Freeze the context stack to keep the exception usable outside the catch blocks"

	self freezeUpTo: thisContext
]

{ #category : #handling }
Exception >> freezeUpTo:  aContext [
	"Freeze the signal context up to the given context so the exception is usable outside the catch block"
	
	signalContext := signalContext copyTo: aContext
]

{ #category : #testing }
Exception >> isDebuggerFailure [
	^false
]

{ #category : #testing }
Exception >> isHandleableBy: aDebugger [
	^ true
]

{ #category : #testing }
Exception >> isNested [
	"Determine whether the current exception handler is within the scope of another handler for the same exception."

	^ handlerContext nextHandlerContext canHandleSignal: self
]

{ #category : #testing }
Exception >> isResumable [
	"Determine whether an exception is resumable."

	^ true
]

{ #category : #accessing }
Exception >> messageText [
	"Return an exception's message text."

	^ messageText ifNil: [ String empty ]
]

{ #category : #signaling }
Exception >> messageText: signalerText [
	"Set an exception's message text."

	messageText := signalerText
]

{ #category : #accessing }
Exception >> originException [
	^ self
]

{ #category : #handling }
Exception >> outer [
	"Evaluate the enclosing exception action and return to here instead of signal if it resumes (see #resumeUnchecked:)."
	| prevOuterContext currentHandler |
	self isResumable 
		ifTrue: [
			prevOuterContext := outerContext. "required and accessed in resumeUnchecked:"
			outerContext := thisContext contextTag ].
	currentHandler := handlerContext.
	[self pass] ensure: [handlerContext := currentHandler].
]

{ #category : #handling }
Exception >> pass [
	"Yield control to the enclosing exception action for the receiver."

	| nextHandler |
	nextHandler := handlerContext nextHandlerContext.
	handlerContext := nil.
	nextHandler handleSignal: self
]

{ #category : #printing }
Exception >> printOn: stream [

	stream nextPutAll: self description
]

{ #category : #private }
Exception >> privHandlerContext [

	^handlerContext
]

{ #category : #private }
Exception >> privHandlerContext: aContextTag [

	handlerContext := aContextTag
]

{ #category : #handling }
Exception >> raiseUnhandledError [
	"No one has handled this error, but now give them a chance to decide how to debug it.  If none handle this either then open debugger (see UnhandedError>>#defaultAction)"

	^ UnhandledError signalForException: self
]

{ #category : #accessing }
Exception >> receiver [
	^ self signalerContext receiver
]

{ #category : #handling }
Exception >> resignalAs: replacementException [
	"Signal an alternative exception in place of the receiver."
	signalContext resumeEvaluating: [replacementException signal]
]

{ #category : #handling }
Exception >> resume [
	"Return from the message that signaled the receiver."

	self resume: self defaultResumeValue
]

{ #category : #handling }
Exception >> resume: resumptionValue [
	"Return resumptionValue as the value of the signal message."

	self isResumable ifFalse: [ IllegalResumeAttempt signal ].
	self resumeUnchecked: resumptionValue
]

{ #category : #handling }
Exception >> resumeUnchecked: resumptionValue [
	"Return resumptionValue as the value of #signal, unless this was called after an #outer message, then return resumptionValue as the value of #outer."

	| ctxt |
	outerContext 
		ifNil: [
			signalContext return: resumptionValue ] 
		ifNotNil: [
			ctxt := outerContext.
			outerContext := ctxt tempAt: 1. "prevOuterContext in #outer"
			ctxt return: resumptionValue ]

]

{ #category : #handling }
Exception >> return [
	"Return nil as the value of the block protected by the active exception handler."

	self return: self defaultReturnValue
]

{ #category : #handling }
Exception >> return: returnValue [
	"Return the argument as the value of the block protected by the active exception handler."

	handlerContext return: returnValue
]

{ #category : #handling }
Exception >> searchFrom: aContext [
	"Set the context where the handler search will start. "

	signalContext := aContext contextTag
]

{ #category : #signaling }
Exception >> signal [
	"Ask ContextHandlers in the sender chain to handle this signal.  The default is to execute and return my defaultAction."
	<debuggerCompleteToSender>
	signalContext := thisContext contextTag.
	signaler ifNil: [ signaler := self receiver ].
	^ signalContext nextHandlerContext handleSignal: self
]

{ #category : #signaling }
Exception >> signal: signalerText [
	"Signal the occurrence of an exceptional condition with a specified textual description."

	self messageText: signalerText.
	^ self signal
]

{ #category : #signaling }
Exception >> signalIn: context [
	"Ask ContextHandlers in the sender chain starting at the given context to handle this signal. 
	The default is to execute and return my defaultAction."

	signalContext := context.
	signaler ifNil: [ signaler := self receiver ].
	^ signalContext nextHandlerContext handleSignal: self
]

{ #category : #accessing }
Exception >> signaler [
	"Return the object that is the subject involving me.
	This is set automatically to my #receiver during #signal
	but could be overwritten when I am signaled"

	^ signaler
]

{ #category : #accessing }
Exception >> signaler: anObject [
	"Set the object that is the subject involving me.
	This is set automatically to my #receiver during #signal
	but could be overwritten when I am signaled"

	signaler := anObject
]

{ #category : #accessing }
Exception >> signalerContext [
	"Find the first sender of signal(:), the first context which is neither for an instance method nor for a class side method of Exception (or subclass).
	This will make sure that the same context is found for both, `Error signal` and `Error new signal`"

	^ signalContext findContextSuchThat: [ :context |
		(context receiver == self 
		or: [ context receiver == self class ]) not ]
]

{ #category : #accessing }
Exception >> tag [
	"Return an exception's tag value."

	^ tag 
		ifNil: [ self messageText ]
		ifNotNil: [ tag ]
]

{ #category : #accessing }
Exception >> tag: t [
	"This message is not specified in the ANSI protocol, but that looks like an oversight because #tag is specified, and the spec states that the signaler may store the tag value."

	tag := t
]

{ #category : #handling }
Exception >> unhandledErrorAction [
	"No one has handled this error, then I gave them a chance to decide how to debug it and I raise an UnhandledError. But it was not handled by anybody so that we are here (see nhandedError-defaultAction).
	It is the final action an exception can do which is normally a debugger in interactive image"

 	^ UIManager default unhandledErrorDefaultAction: self
]
