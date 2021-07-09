"
The information required to open a debugger can take multiple forms.
This object is a builder, to be filled with the relevant information by any object that wants to open a debugger.
Once this object is filled, call its #debug or #warning method to open a debugger/send a warning.

# Information That Can Be Provided (and their type)
- exception: Exception
- context: Context
- label: String
- process: Process
- compiledMethod: CompiledMethod

# Notes
- You NEED to provide an exception OR a context. The other information are optional.
- If an exception and a label are provided, the label will be ignored (in favour of the #description of the exception)
- Providing a compiledMethod will make it so the execution will be stepped until it is in that method , prior to the debugger opening

# Instance Variables
- exception: Exception.
- context: Context.
- label: String. If not provided, the result of ""self defaultLabel_"" will be used.
- process: Process. If not provided, the result of ""self defaultProcess"" will be used.
- compiledMethod: CompiledMethod
- preDebugActions: OrderedCollection<BlockClosure<DebugSession, nil>>. A list of blocks, taking as arguments a DebugSession on the execution to be debugged. These will be executed before the debugger opens.

# Technical Details
- the setters are meant to be used by the caller, to fill this object with information
- the getters are meant to be used by whatever objects is opening a debugger based on the information contained in this object
"
Class {
	#name : #OupsDebugRequest,
	#superclass : #Object,
	#instVars : [
		'exception',
		'context',
		'label',
		'process',
		'compiledMethod',
		'preDebugActions',
		'debugSession'
	],
	#category : #'Debugger-Oups-Infrastructure'
}

{ #category : #'instance creation' }
OupsDebugRequest class >> new [
	self shouldNotImplement
]

{ #category : #'instance creation' }
OupsDebugRequest class >> newForContext: aContext [
	<debuggerCompleteToSender>
	^ self basicNew context: aContext; yourself
]

{ #category : #'instance creation' }
OupsDebugRequest class >> newForException: anException [
	"By default we assume that the debugger is requested from the process itself as the result of anException. In that case we must use #realActiveProcess instead of #activeProcess.
	When debugger opens it must stop the current process. Otherwise the error signal will return to the sender and it will continue execution. Obviously it may cause an unexpected behavior and in worst case it may break the system completely (with some infinite recursion triggering debuggers at every step).
	Therefore in this scenario we use #realActiveProcess to reliably get a really running process. 
	For more details see #realActiveProcess and #terminateRealActive comments"
	<debuggerCompleteToSender>
	^ self basicNew 
			exception: anException;
			process: Processor realActiveProcess;
			yourself
]

{ #category : #accessing }
OupsDebugRequest >> compiledMethod: anObject [
	compiledMethod := anObject
]

{ #category : #building }
OupsDebugRequest >> computePreDebugActions [

	"If compiledMethod is not nil, this DebugRequest has been created to debug the execution of a specific method. Add a pre-debug action to step the execution until that method is reached"

	compiledMethod ifNil: [ ^ self ].
	self preDebugActions add:
		(self preDebugActionForDebugItMethod: compiledMethod)
]

{ #category : #accessing }
OupsDebugRequest >> context: anObject [
	context := anObject
]

{ #category : #accessing }
OupsDebugRequest >> debugSession [

	^ debugSession ifNil: [ debugSession := self newDebugSession ]
]

{ #category : #'default values' }
OupsDebugRequest >> defaultException [

	^ self nullExceptionFor: context named: self label
]

{ #category : #'default values' }
OupsDebugRequest >> defaultLabel [
	^ 'No label was provided'
]

{ #category : #'default values' }
OupsDebugRequest >> defaultProcess [
	^ Processor activeProcess
]

{ #category : #'default values' }
OupsDebugRequest >> defaultUIManager [
	^ UIManager default
]

{ #category : #accessing }
OupsDebugRequest >> exception [

	^ exception ifNil: [ exception := self defaultException ]
]

{ #category : #accessing }
OupsDebugRequest >> exception: anObject [
	exception := anObject
]

{ #category : #accessing }
OupsDebugRequest >> label [

	^ label ifNil: [ label := self defaultLabel ]
]

{ #category : #accessing }
OupsDebugRequest >> label: anObject [
	label := anObject
]

{ #category : #building }
OupsDebugRequest >> newDebugSession [

	^ (self process
		   newDebugSessionNamed: self exception description
		   startedAt: self exception signalerContext)
		  exception: self exception;
		  yourself
]

{ #category : #helpers }
OupsDebugRequest >> nullExceptionFor: aContext named: aString [
	^ (OupsNullException fromSignallerContext: aContext)
		messageText: aString;
		yourself
]

{ #category : #building }
OupsDebugRequest >> preDebugActionForDebugItMethod: aCompiledMethod [

	"Return a PreDebug action that will step the debugged execution until it is in a call to aCompiledMethod"

	^ [ :session | 
	  session stepIntoUntil: [ :currentContext | 
		  currentContext method == aCompiledMethod ] ]
]

{ #category : #accessing }
OupsDebugRequest >> preDebugActions [
	preDebugActions ifNil: [ preDebugActions := OrderedCollection new ].
	^ preDebugActions
]

{ #category : #accessing }
OupsDebugRequest >> process [
	"If a process was provided, return it, otherwise use the result of 'self defaultProcess'"
	^ process ifNil: [ self defaultProcess ]
]

{ #category : #accessing }
OupsDebugRequest >> process: anObject [
	process := anObject
]

{ #category : #requests }
OupsDebugRequest >> submit [
	<debuggerCompleteToSender>
	"Submit this debug request to the system. The system will typically open a debugger for it"
	OupsDebuggerSystem new handleDebugRequest: self
]
