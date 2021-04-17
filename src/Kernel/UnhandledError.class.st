"
I am the ultimate error. 
By default if an Exception is not handled by the code the default action is to raise an UnhandledError (#raiseUnhandledError) which in interactive mode triggers the UIManager to open a debugger.

	Error signal
	...
	UnhandledError signalForException: error
	...
	UIManager opens a debugger
	
The UI action here can be specialied for different kind of exceptions. The actual logic is implemented by exceptions themselves as #unhandledErrorAction:

	UnhandledError>>defaultAction 
		^ exception unhandledErrorAction

For example It allows to have specific debugger for Warning while it still processed through same UnhandledError machinery.

The logic behind my class name and methods: 
Not all exceptions are errors. But by default the absence of any handler for signaled exception is considered as an error. Therefore #defaultAction for Exception raises an error, an UnhandledError. And because exception should be able to specify default action for UnhandledError it implements #unhandledErrorAction
"
Class {
	#name : #UnhandledError,
	#superclass : #UnhandledException,
	#instVars : [
		'exception'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #signalling }
UnhandledError class >> signalForException: anError [

	^ self new
		exception: anError;
		signal
]

{ #category : #handling }
UnhandledError >> defaultAction [
	^ exception unhandledErrorAction
]

{ #category : #accessing }
UnhandledError >> exception [

	^ exception
]

{ #category : #accessing }
UnhandledError >> exception: anError [

	exception := anError
]

{ #category : #testing }
UnhandledError >> isResumable [

	"UnhandledError can be signaled for more than non-resumable Errors.
	If UnhandledError reflects the underlying Exception, we are able to
	resume the underlying Exception."

	^ self exception isResumable
]
