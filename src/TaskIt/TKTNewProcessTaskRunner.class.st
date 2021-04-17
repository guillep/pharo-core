"
! TKTNewProcessTaskRunner

A new process task runner, instance of TKTNewProcessTaskRunner, is a task runner that runs each task in a new separate Pharo process.

[[[language=smalltalk
aRunner := TKTNewProcessTaskRunner new.
aRunner schedule: [ 1 second wait. 'test' logCr ].
]]]

Moreover, since new processes are created to manage each task, scheduling two different tasks will be executed concurrently. For example, in the code snippet below, we schedule twice a task that printing the identity hash of the current process.

[[[language=smalltalk
aRunner := TKTNewProcessTaskRunner new.
task := [ 10 timesRepeat: [ 10 milliSeconds wait.
                ('Hello from: ', Processor activeProcess identityHash asString) logCr ] ].
aRunner schedule: task.
aRunner schedule: task.
]]]

The generated output will look something like this:

[[[
'Hello from: 887632640'
'Hello from: 949846528'
'Hello from: 887632640'
'Hello from: 949846528'
'Hello from: 949846528'
'Hello from: 887632640'
'Hello from: 949846528'
'Hello from: 887632640'
'Hello from: 949846528'
'Hello from: 887632640'
'Hello from: 949846528'
'Hello from: 887632640'
'Hello from: 949846528'
'Hello from: 887632640'
'Hello from: 949846528'
'Hello from: 887632640'
'Hello from: 949846528'
'Hello from: 887632640'
'Hello from: 949846528'
'Hello from: 887632640'
]]]

First, you'll see that a different processes is being used to execute each task. Also, their execution is concurrent, as we can see the messages interleaved.
"
Class {
	#name : #TKTNewProcessTaskRunner,
	#superclass : #TKTRunner,
	#category : #'TaskIt-Kernel'
}

{ #category : #scheduling }
TKTNewProcessTaskRunner >> scheduleTaskExecution: aTaskExecution [
	TKTConfiguration processProvider
		createProcessDoing:
			(MessageSend
				receiver: self
				selector: #executeTask:
				arguments: {aTaskExecution})
]
