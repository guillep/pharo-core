"
My single instance,  named Processor,  coordinates the use of the physical processor by all Processes requiring service.

My instances variables are managed by the VM. The VM has for role to choose which process should be executed and when.

NB: DelayBasicScheduler is THE HIGHEST priority code which is run in Pharo. See DelayBasicScheduler for additional comments.

"
Class {
	#name : #ProcessorScheduler,
	#superclass : #Object,
	#instVars : [
		'quiescentProcessLists',
		'activeProcess'
	],
	#classVars : [
		'BackgroundProcess',
		'HighIOPriority',
		'IdleTime',
		'LowIOPriority',
		'SystemBackgroundPriority',
		'SystemRockBottomPriority',
		'TimingPriority',
		'UserBackgroundPriority',
		'UserInterruptPriority',
		'UserSchedulingPriority'
	],
	#category : #'Kernel-Processes'
}

{ #category : #'background process' }
ProcessorScheduler class >> idleProcess [
	"A default background process which is invisible. During the idle time, the delays may not wake up."

	[true] whileTrue:
		[self relinquishProcessorForMicroseconds: IdleTime]
]

{ #category : #settings }
ProcessorScheduler class >> idleTime [

	"The default idle time for the Pharo process in case of inactivity. In idle mode, the system can be awakened by a signal. This value can limit the minimal delay time."
	
	^ IdleTime
]

{ #category : #settings }
ProcessorScheduler class >> idleTime: microsecondsCount [

	IdleTime := microsecondsCount
]

{ #category : #settings }
ProcessorScheduler class >> idleTimeSettingOn: aBuilder [
	<systemsettings>
	
	(aBuilder setting: #idleTime)
		target: self;
		parent: #pharoSystem ;
		default: 50000;
		label: 'Default idle time for the system (microseconds)' ;
		description: 'Detault idle time for the Pharo process in case of inactivity. In idle mode, the system can be awakened by a signal. This value can limit the minimal delay time.'
]

{ #category : #'class initialization' }
ProcessorScheduler class >> initialize [
	"ProcessorScheduler initialize."
	     
	SystemRockBottomPriority := 10.
	SystemBackgroundPriority := 20.
	UserBackgroundPriority := 30.
	UserSchedulingPriority := 40.
	UserInterruptPriority := 50.
	LowIOPriority := 60.
	HighIOPriority := 70.
	TimingPriority := 80.
	IdleTime := 50000.

	SessionManager default
		registerSystemClassNamed: self name
		atPriority: 30.
]

{ #category : #'instance creation' }
ProcessorScheduler class >> new [
	"New instances of ProcessorScheduler should not be created."

	self error:
'New ProcessSchedulers should not be created since
the integrity of the system depends on a unique scheduler'
]

{ #category : #'background process' }
ProcessorScheduler class >> relinquishProcessorForMicroseconds: anInteger [
	"Platform specific. This primitive is used to return processor cycles to the host operating system when Pharo's idle process is running (i.e., when no other Pharo process is runnable). On some platforms, this primitive causes the entire Pharo application to sleep for approximately the given number of microseconds. No Pharo process can run while the Pharo application is sleeping, even if some external event makes it runnable. On the Macintosh, this primitive simply calls GetNextEvent() to give other applications a chance to run. On platforms without a host operating system, it does nothing. This primitive should not be used to add pauses to a Pharo process; use a Delay instead."

	<primitive: 230>
	"don't fail if primitive is not implemented, just do nothing"

]

{ #category : #'background process' }
ProcessorScheduler class >> startUp [
	"Install a background process of the lowest possible priority that is always runnable."
	"Details: The virtual machine requires that there is always some runnable process that can be scheduled; this background process ensures that this is the case."

	Smalltalk installLowSpaceWatcher.
	BackgroundProcess ifNotNil: [BackgroundProcess terminate].
	BackgroundProcess := [self idleProcess] newProcess.
	BackgroundProcess priority: SystemRockBottomPriority.
	BackgroundProcess name: 'Idle Process'.
	BackgroundProcess resume.

]

{ #category : #accessing }
ProcessorScheduler >> activePriority [
	"Answer the priority level of the currently running Process."

	^self activeProcess priority
]

{ #category : #accessing }
ProcessorScheduler >> activeProcess [
	"Answers the currently running Process.
	It can be just pretending to be the active process
	(like during the code simulation in the debugger)"

	^activeProcess effectiveProcess
]

{ #category : #private }
ProcessorScheduler >> anyProcessesAbove: highestPriority [ 
	"Do any instances of Process exist with higher priorities?"

	^(Process allInstances "allSubInstances" select: [:aProcess | 
		aProcess priority > highestPriority]) isEmpty
		"If anyone ever makes a subclass of Process, be sure to use allSubInstances."
]

{ #category : #accessing }
ProcessorScheduler >> backgroundProcess [
	"Answer the background process"
	^ BackgroundProcess
]

{ #category : #'priority names' }
ProcessorScheduler >> highIOPriority [
	"Answer the priority at which the most time critical input/output 
	processes should run. An example is the process handling input from a 
	network."

	^HighIOPriority
]

{ #category : #accessing }
ProcessorScheduler >> highestPriority [
	"Answer the number of priority levels currently available for use."
	"NB: If you are looking to set a priority when forking a process, please use the methods in 'priority names' protocol"

	^quiescentProcessLists size
]

{ #category : #accessing }
ProcessorScheduler >> highestPriority: newHighestPriority [
	"Change the number of priority levels currently available for use."

	| newProcessLists |
	(quiescentProcessLists size > newHighestPriority
		and: [self anyProcessesAbove: newHighestPriority])
			ifTrue: [self error: 'There are processes with priority higher than '
													,newHighestPriority printString].
	newProcessLists := Array new: newHighestPriority.
	1 to: ((quiescentProcessLists size) min: (newProcessLists size)) do: 
		[:priority | newProcessLists at: priority put: (quiescentProcessLists at: priority)].
	quiescentProcessLists size to: newProcessLists size do: 
		[:priority | newProcessLists at: priority put: ProcessList new].
	quiescentProcessLists := newProcessLists
]

{ #category : #'self evaluating' }
ProcessorScheduler >> isSelfEvaluating [
	^self == Processor
]

{ #category : #'priority names' }
ProcessorScheduler >> lowIOPriority [
	"Answer the priority at which most input/output processes should run. 
	Examples are the process handling input from the user (keyboard, 
	pointing device, etc.) and the process distributing input from a network."

	^LowIOPriority
]

{ #category : #'priority names' }
ProcessorScheduler >> lowestPriority [
	"Return the lowest priority that is allowed with the scheduler"
	^SystemRockBottomPriority
]

{ #category : #'CPU usage tally' }
ProcessorScheduler >> nextReadyProcess [
	quiescentProcessLists reverseDo: [ :list |
		list isEmpty ifFalse: [ | proc |
			proc := list first.
			proc suspendedContext ifNotNil: [ ^proc ]]].
	^nil
]

{ #category : #accessing }
ProcessorScheduler >> preemptedProcess [
	"Return the process that the currently active process just preempted."
	| list |
	activeProcess priority to: 1 by: -1 do:[:priority|
		list := quiescentProcessLists at: priority.
		list isEmpty ifFalse:[^list last].
	].
	^nil

	"Processor preemptedProcess"
]

{ #category : #printing }
ProcessorScheduler >> printOn: aStream [
	self isSelfEvaluating ifFalse: [^super printOn: aStream].
	aStream nextPutAll: #Processor
]

{ #category : #accessing }
ProcessorScheduler >> realActiveProcess [
	"Answers the real currently running Process (ignoring any effective process installed).
	Method should be used carefully only in specific low level parts of the system.
	End users should use #activeProcess instead. 

	This method is not debuggable because stepping over it would wrongly return an actual UI process of the debugger instead of a process under the debugger. 
	But this is the required property for the use cases like debugger requests which must work with real running process (not a simulated one)"

	^activeProcess
]

{ #category : #removing }
ProcessorScheduler >> remove: aProcess ifAbsent: aBlock [ 
	"Remove aProcess from the list on which it is waiting for the processor 
	and answer aProcess. If it is not waiting, evaluate aBlock."

	(quiescentProcessLists at: aProcess priority)
		remove: aProcess ifAbsent: aBlock.
	^aProcess
]

{ #category : #accessing }
ProcessorScheduler >> scanSchedule: aBlock startingAt: topPriority [
	"Iterate over scheduled processes  list, starting from topPriority down to lowest one. "

	topPriority to: 1 by: -1 do:[:priority | | list |
		list := quiescentProcessLists at: priority.
		list do: [:proc | 
			aBlock value: proc
		].
	].

]

{ #category : #'process state change' }
ProcessorScheduler >> suspendFirstAt: aPriority [ 
	"Suspend the first Process that is waiting to run with priority aPriority."

	^self suspendFirstAt: aPriority
		  ifNone: [self error: 'No Process to suspend']
]

{ #category : #'process state change' }
ProcessorScheduler >> suspendFirstAt: aPriority ifNone: noneBlock [ 
	"Suspend the first Process that is waiting to run with priority aPriority. If 
	no Process is waiting, evaluate the argument, noneBlock."

	| aList |
	aList := quiescentProcessLists at: aPriority.
	aList isEmpty
		ifTrue: [^noneBlock value]
		ifFalse: [^aList first suspend]
]

{ #category : #'priority names' }
ProcessorScheduler >> systemBackgroundPriority [
	"Answer the priority at which system background processes should run. 
	Examples are an incremental garbage collector or status checker."

	^SystemBackgroundPriority
]

{ #category : #'CPU usage tally' }
ProcessorScheduler >> tallyCPUUsageFor: seconds [
	"Start a high-priority process that will tally the next ready process for the given
	number of seconds. Answer a Block that will return the tally (a Bag) after the task
	is complete" 
	^self tallyCPUUsageFor: seconds every: 10

]

{ #category : #'CPU usage tally' }
ProcessorScheduler >> tallyCPUUsageFor: seconds every: msec [
	"Start a high-priority process that will tally the next ready process for the given
	number of seconds. Answer a Block that will return the tally (a Bag) after the task
	is complete" 
	| tally sem delay endDelay |
	tally := IdentityBag new: 200.
	delay := Delay forMilliseconds: msec truncated.
	endDelay := Delay forSeconds: seconds.
	endDelay schedule.
	sem := Semaphore new.
	[
		[ endDelay isExpired ] whileFalse: [
			delay wait.
			tally add: Processor nextReadyProcess
		].
		sem signal.
	] forkAt: self highestPriority.

	^[ sem wait. tally ]
]

{ #category : #'process state change' }
ProcessorScheduler >> terminateActive [
	"Terminate the process that is currently running."

	self activeProcess doTerminationFromYourself
]

{ #category : #'process state change' }
ProcessorScheduler >> terminateRealActive [
	"IMPORTANT: Do not step over this method in the debugger (normally you will never do it) because it will terminate the UIProcess of the debugger instead of the process under the debugger.
	Method should not be used by users. It is only for specific low level places of the system like a normal process termination.
	
	It terminates the active process that is really currently running despite on any effective process installed. 	
	It is very critical to ignore the simulation trick of the debugger (the effective process) during the normal completion of the process. This method ensures that every process is able to complete. 
	Previously #terminateActive was used for the process completion. But #terminateActive targets the effective process which the debugger sets for the stepping over the Processor calls. Debugger resets this value at the end of stepping but there are huge amount of cases where it is impossible to do or due to the bugs in the debugger implementation.
	The consequences of unreset effective process is inability of the process to finish the execution.
	The following scenario happens in this case: 
	- Process completes by ```Processor terminateActive``` call (it is the end of any process). 
	- #terminateActive can't terminate the real active process because the effective one is used.
	- Without the stop the #terminateActive continutes the execution to the nil sender (it is nil after the full unwind during Process>>terminate).
	- The return to nil sender causes the VM fallback logic. It sends #cannotReturn: message to the context.
	- #cannotReturn: method raises an error which requests the debugger
	- Debugger is opened in UI process and the current process is suspended to stop the execution.
	- To suspend the current process the debugger uses ```Processor activeProcess suspend`` 
	- The active process there is not a real process due to effectiveProcess state.
	- Suspend is executed over wrong process 
	- Really running process continues the execution after #suspend.
	- Execution tries to return from cannotReturn: method to the nil sender.
	- VM sends again #cannotReturn: message. 
	- Image hangs due to this infinite recursion triggering new debugger at every step.
	- Interrupt (cmd+dot) does not help by same reason. The Debugger will suspend the wrong process.
	
	In other words the effective process trick is very dangerous mechanizm and critical system operations must avoid it. 
	Therefore this method. It is used only as the last instruction for the process termination. See #newProcess for example: 
			[ self value, Processor terminateRealActive ]
	"

	activeProcess doTerminationFromYourself
]

{ #category : #'priority names' }
ProcessorScheduler >> timingPriority [
	"Answer the priority at which the system processes keeping track of real 
	time should run."
	"BEFORE USING IT: please read the 'Original word of advice' in the DelayScheduler class comment. 
	TL;DR: for top priority processes use 'Processor timingPriority - 1' except if you really know what you are doing!"

	^TimingPriority
]

{ #category : #'priority names' }
ProcessorScheduler >> userBackgroundPriority [
	"Answer the priority at which user background processes should run."

	^UserBackgroundPriority
]

{ #category : #'priority names' }
ProcessorScheduler >> userInterruptPriority [
	"Answer the priority at which user processes desiring immediate service 
	should run. Processes run at this level will preempt the window 
	scheduler and should, therefore, not consume the processor forever."

	^UserInterruptPriority
]

{ #category : #'priority names' }
ProcessorScheduler >> userSchedulingPriority [
	"Answer the priority at which the window scheduler should run."

	^UserSchedulingPriority
]

{ #category : #accessing }
ProcessorScheduler >> waitingProcessesAt: aPriority [
	"Return the list of processes at the given priority level."
	^quiescentProcessLists at: aPriority
]

{ #category : #'process state change' }
ProcessorScheduler >> yield [
	"Give other Processes at the current priority a chance to run."

	| semaphore |

	<primitive: 167>
	semaphore := Semaphore new.
	[semaphore signal] fork.
	semaphore wait
]
