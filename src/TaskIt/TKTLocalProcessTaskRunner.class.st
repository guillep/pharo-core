"
! TKTLocalProcessTaskRunner

The local process runner, instance of TKTLocalProcessTaskRunner, is a task runner that executes a task in the caller process. In other words, this task runner does not run concurrently. Executing the following piece of code:

[[[language=smalltalk
aRunner := TKTLocalProcessTaskRunner new.
future := aRunner schedule: [ 1 second wait ].
]]]

is equivalent to the following piece of code:

[[[language=smalltalk
[ 1 second wait ] value.
]]]

or even:

[[[language=smalltalk
1 second wait.
]]]

While this runner may seem a bit naive, it may also come in handy to control and debug task executions. Besides, the power of task runners is that they offer a polymorphic API to execute tasks.
"
Class {
	#name : #TKTLocalProcessTaskRunner,
	#superclass : #TKTRunner,
	#category : #'TaskIt-Kernel'
}

{ #category : #scheduling }
TKTLocalProcessTaskRunner >> isLocalThreadRunner [
	^ true
]

{ #category : #scheduling }
TKTLocalProcessTaskRunner >> scheduleTaskExecution: aTaskExecution [
	self executeTask: aTaskExecution
]

{ #category : #polymorphism }
TKTLocalProcessTaskRunner >> start [

]
