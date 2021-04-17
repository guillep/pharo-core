"
! TKTRunner

So far we created and executed tasks without caring too much on the form they were executed. Indeed, we knew that they were run concurrently because they were non-blocking. We also said already that the difference between a schedule message and a fork message is that scheduled messages are run by a task runner.

A task runner is an object in charge of executing tasks eventually. Indeed, the main API of a task runner is the schedule: message that allows us to tell the task runner to schedule a task.

[[[language=smalltalk
aRunner schedule: [ 1 + 1 ]
]]]

A nice extension built on top of schedule is the future: message that allows us to schedule a task but obtain a future of its eventual execution.

[[[language=smalltalk
future := aRunner future: [ 1 + 1 ]
]]]

Indeed, the messages schedule and future we have learnt before are only syntax-sugar extensions that call these respective ones on a default task runner. See TKTRunner subclasses for details on specific runners.

!! Managing Runner Exceptions

As we stated before, in TaskIT the result of a task can be interesting for us or not. In case we do not need a task's result, we will schedule it usign the schedule or schedule: messages. This is a kind of fire-and-forget way of executing tasks. On the other hand, if the result of a task execution interests us we can get a future on it using the future and future: messages. These two ways to execute tasks require different ways to handle exceptions during task execution.

First, when an exception occurs during a task execution that has an associated future, the exception is forwarded to the future. In the future we can subscribe a failure callback using the onFailureDo: message to manage the exception accordingly.

However, on a fire-and-forget kind of scheduling, the execution and results of a task is not anymore under our control. If an exception happens in this case, it is the responsibility of the task runner to catch the exception and manage it gracefully. For this, each task runners is configured with an exception handler in charge of it. TaskIT exception handler classes are subclasses of the abstract TKTExceptionHandler that defines a handleException: method. Subclasses need to override the handleException: method to define their own way to manage exceptions.

TaskIt provides by default a TKTDebuggerExceptionHandler that will open a debugger on the raised exception. The handleException: method is defined as follows:

[[[language=smalltalk
handleException: anError 
    anError debug
]]]

Changing a runner's exception handler can be done by sending it the exceptionHandler: message, as follows:

[[[language=smalltalk
aRunner exceptionHandler: TKTDebuggerExceptionHandler new.
]]]
"
Class {
	#name : #TKTRunner,
	#superclass : #TKTAbstractExecutor,
	#traits : 'TTaskScheduler',
	#classTraits : 'TTaskScheduler classTrait',
	#category : #'TaskIt-Kernel'
}

{ #category : #testing }
TKTRunner class >> isAbstract [

	^self == TKTRunner 
]
