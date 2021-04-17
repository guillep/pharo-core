"
I schedule delays in a basic way independent of any particular time-base
and without any special multi-threaded synchronisation protection. 

I provide the delay scheduling loop running as the system's highest priority process 
waiting for user delay scheduling events or VM events indicating a delay needs to be expired.
I manage suspendedDelays as a Heap sorted by the resumption time of the delay.

My main collaborators are:
Delay - holds the resumptionTick calculated by the ticker
Delay{time-base}Ticker - time-base specific interaction with VM and calculation of resumptionTicks 

USER-API 
#schedule: aDelay
	Forwards delay from user-thread to #timingPrioritySchedule: thread (via signalling #timingPriorityRunEventLoop) 

#unschedule: aDelay
	Forwards delay from user-thread to #timingPriorityUnschedule: thread (via signalling #timingPriorityRunEventLoop) 
	

SYSTEM-API
#startTimerEventLoop{Priority:}
	creates a process runnning the delay scheduling loop, customisable priority to help unit testing

#stopTimeEventLoop
	flags the delay scheduling loop to execute and expire all suspended delays

#shutDown
	suspend the delay scheduling loop to facilite clean snapshot 

#startUp
	unsuspend delay scheduling loop when snapshot resumes


INTERNAL - TIMING PRIORITY FACILITIES
timingPriority is the highest priority process in the system

#timingPriorityRunEventLoop 
	outer loop uses the ticker to wait for VM or user signals
	handles suspend-loop requests from #shutDown 
	invokes the main event handler
	when loop exits, signals all remaining suspendedDelays

#timingPriorityHandleEvent
	the main event handler
	hands delays to the next two methods...

#timingPrioritySchedule: aDelay
   inserts into suspendedDelays and determines activeDelay

#timingPriorityUnSchedule: aDelay
   deletes from suspendedDelays and determines activeDelay


INTERNAL - SYNCHRONISATION
Lacking synchronisation protection I rely solely on the implict semantics of process scheduling.
Specifically, in #schedule:/#unschedule there can be no suspension point between 
the variable assignment and the following #signal which transfers execution to the highest priority process that consumes and clears the variable. In practice this currently works quite well,
but is fragile wrt changing process scheduling semantics.  Subclasses add specific synchronisation
protection.
"
Class {
	#name : #DelayBasicScheduler,
	#superclass : #DelayNullScheduler,
	#instVars : [
		'ticker',
		'runTimerEventLoop',
		'timerEventLoop',
		'suspendedDelays',
		'activeDelay',
		'suspendSemaphore',
		'timingSemaphore',
		'delayToStart',
		'delayToStop'
	],
	#category : #'Kernel-Delays'
}

{ #category : #accessing }
DelayBasicScheduler class >> defaultSuspendedDelaysHeap [
	 ^ Heap 
			sortBlock: [ :delay1 :delay2 | 
				delay1 resumptionTick <= delay2 resumptionTick ]

]

{ #category : #'instance creation' }
DelayBasicScheduler class >> onTicker: aDelayTicker suspendedDelaysHeap: aHeap [
	"Facilitates unit tests examining the otherwise hidden suspendedDelays variable"
	^self basicNew initializeTicker: aDelayTicker suspendedDelaysHeap: aHeap
]

{ #category : #testing }
DelayBasicScheduler >> anyActive [
	"Return true if there is any delay currently active"
	^activeDelay notNil
]

{ #category : #initialization }
DelayBasicScheduler >> initialize [
	"Default configuration."

	self initializeTicker: (DelayMicrosecondTicker new) 
		  suspendedDelaysHeap: DelayBasicScheduler defaultSuspendedDelaysHeap.

]

{ #category : #initialization }
DelayBasicScheduler >> initializeTicker: aDelayTicker suspendedDelaysHeap: aHeap [
	ticker := aDelayTicker.
	suspendedDelays := aHeap.
	timingSemaphore := Semaphore new
]

{ #category : #deprecated }
DelayBasicScheduler >> millisecondsUntilResumptionTime: microsecondResumptionTime [
	^ (microsecondResumptionTime - Time microsecondClockValue) // 1000
]

{ #category : #testing }
DelayBasicScheduler >> nextWakeUpTime [
	^ activeDelay 
			ifNil: [ 0 ]
			ifNotNil: [ :delay | delay resumptionTick ]
]

{ #category : #printing }
DelayBasicScheduler >> printOn: aStream [
	super printOn: aStream.
	aStream 
		nextPutAll: '(';
		print: self identityHash ;
		nextPutAll: ') on ' ;
		nextPutAll: ticker className.
		 
]

{ #category : #'system-api' }
DelayBasicScheduler >> restartTimerEventLoop [
	"Start the timer event loop"
	"Delay restartTimerEventLoop"
	self stopTimerEventLoop.
	self startTimerEventLoop.


]

{ #category : #'user-api' }
DelayBasicScheduler >> resume [
	"Unsuspend the timing-priority delay scheduling loop when resuming a snapshot."
	
	suspendSemaphore
		ifNil:[ ^self error: 'Not suspended' ].
	suspendSemaphore signal. 
	"signal transfers execution to #suspendAtTimingPriority, 
	 which does... suspendSemaphore := nil."
]

{ #category : #'private - timing priority process' }
DelayBasicScheduler >> runBackendLoopAtTimingPriority [
	"Private! Outer loop for the timing priority timer event loop.
	 Invoked by api-system #startTimerEventLoop"

	"Unit tests may run this at a lower priority" 
	[  [runTimerEventLoop] whileTrue: 
		[	|nowTick|
			"Warning! Stepping <Over> the following line may lock the Image. Use <Into> or <Proceed>."
		 	ticker waitForUserSignalled: timingSemaphore orExpired: activeDelay. 

			"Invoke the api back-ends, which set the transfer-variable to nil" 		
			suspendSemaphore ifNotNil: [ self suspendAtTimingPriority    ].
			delayToStart     ifNotNil: [ self scheduleAtTimingPriority   ].
			delayToStop      ifNotNil: [ self unscheduleAtTimingPriority ].

			"Signal any expired delays"
			nowTick := ticker nowTick.
			[ 	activeDelay notNil and: [nowTick >= activeDelay resumptionTick] ] 
					whileTrue: [
						activeDelay timingPrioritySignalExpired.
						activeDelay := suspendedDelays removeFirstOrNil ].
		]
	] ensure: [ "When timer event loop exits, expire remaining delays."
		[activeDelay notNil] whileTrue: [
				activeDelay timingPrioritySignalExpired.
				activeDelay := suspendedDelays removeFirstOrNil ]].
]

{ #category : #'user-api' }
DelayBasicScheduler >> schedule: aDelay [
	"This is the front-half of scheduling a delay. Invoked from user processes. 
	 For back-half see #scheduleAtTimingPriority"
	
	"Only one signal is sent when delay expires, and if that is already spoken for"
	aDelay beingWaitedOn ifTrue: [^self error: 'This Delay has already been scheduled.'].
	
	"The basic scheduler is highly dependant on semantics of cooperative multitasking and 
	 bytecode inlining such that interuption *cannot* occur between the following assignment and signal.
	 The #signal immediately transfers execution to timing-priority #runTimerEventLoop
	 such that no other thread can overwrite our value until consumed by timing-priority thread.
	 Subclasses provide addition protections to lessen the importance of these semantics."
	delayToStart := aDelay.
	timingSemaphore signal. "Transfer execution to back-end #scheduleAtTimingPriority"
]

{ #category : #'private - timing priority process' }
DelayBasicScheduler >> scheduleAtTimingPriority [
	"Private! Invoke only from the timing-priority process.
	 This is the back-half of scheduling a delay. For front-half see #schedule:"
	
	(delayToStart timingPriorityScheduleTicker: ticker) ifFalse:[ ^self ]. "Already scheduled"

	activeDelay 
		ifNil: [ activeDelay := delayToStart ]
		ifNotNil: [
			delayToStart resumptionTick < activeDelay resumptionTick
				ifTrue: [
					suspendedDelays add: activeDelay.
					activeDelay := delayToStart ]
				ifFalse: [ suspendedDelays add: delayToStart ]].
	delayToStart := nil

]

{ #category : #'system-api' }
DelayBasicScheduler >> schedulingProcess [
	^ timerEventLoop 
]

{ #category : #'system-api' }
DelayBasicScheduler >> shutDown [
	self suspend
]

{ #category : #'support - test cases' }
DelayBasicScheduler >> simulate_vmMilliseconds: milliseconds [ 
	"This method is only called from tests which make use of the 'simulation' tickers 
	which implement the next method."
	ticker simulate_vmMilliseconds: milliseconds.

]

{ #category : #'system-api' }
DelayBasicScheduler >> startTimerEventLoop [
	"Start the timer event loop"
	"Delay restartTimerEventLoop"
	
	self startTimerEventLoopPriority: Processor timingPriority
]

{ #category : #'system-api' }
DelayBasicScheduler >> startTimerEventLoopPriority: processorPriority [
	"Start the timer event loop"
	"Delay restartTimerEventLoop"
	
	timerEventLoop ifNotNil: [ self error: 'Timer event loop has already been started.' ].
	
	runTimerEventLoop := true.
	
	timerEventLoop := [ self runBackendLoopAtTimingPriority ] newProcess.
	timerEventLoop 
		name: self className , '(' , ticker className, ')';
		priority: processorPriority.
	timerEventLoop resume.

]

{ #category : #'system-api' }
DelayBasicScheduler >> startUp [
	self resume
]

{ #category : #'system-api' }
DelayBasicScheduler >> stopTimerEventLoop [
	"Stop the timingpriority event loop"	
		
	runTimerEventLoop := false.
	"Transfer execution to #timingPriorityWaitForUserOrDelay:"
	timingSemaphore signal. 
	
	"In normal operation the timingpriority event loop process should already have terminated, 
	but things can get out of order with multi-threaded debuggin. Ensure its terminated." 
	timerEventLoop isTerminated  
		ifFalse: [ 
			self error: 'Expected timing priority event loop terminated already'.
			timerEventLoop terminate ].
	timerEventLoop := nil.
]

{ #category : #'user-api' }
DelayBasicScheduler >> suspend [
	"This is the front-half for suspending the delay scheduler to prevent
	 wake-up of delayed threads in the middle of snapshotting.
	 For back-half see #suspendAtTimingPriority"

	suspendSemaphore := Semaphore new.
	timingSemaphore signal.	
		
	"That #signal transfers execution to timingPriorityRunEventLoop 
	 which then waits for suspendSemaphore to be signalled from #startup"

]

{ #category : #'private - timing priority process' }
DelayBasicScheduler >> suspendAtTimingPriority [
	"Private! This is the front-half for suspending the delay scheduler to prevent
	 wake-up of delayed threads in the middle of snapshotting. For front-half see #suspend"
	
	ticker saveResumptionTimes: suspendedDelays asArray, {activeDelay}.
	"Warning! Stepping <Over> the following line may lock the Image. Use <Proceed>."
	suspendSemaphore wait.
	
	ticker restoreResumptionTimes: suspendedDelays asArray, {activeDelay}.  
	suspendSemaphore := nil

]

{ #category : #'system-api' }
DelayBasicScheduler >> ticker [
	^ticker
]

{ #category : #'user-api' }
DelayBasicScheduler >> unschedule: aDelay [
	"This is the front-half of unscheduling a delay. Invoked from user processes. 
	 For back-half see #unscheduleAtTimingPriority"

	"The basic scheduler is highly dependant on semantics of cooperative multitasking and 
	 bytecode inlining such that interuption *cannot* occur between the assignment and the signal.
	 The #signal immediately transfers execution to timing-priority #runTimerEventLoop
	 such that no other thread can overwrite our value until consumed by timing-priority thread.
	 Subclasses add protection against this."
	delayToStop := aDelay.
	timingSemaphore signal. "Transfer execution to #unscheduleAtTimingPriority"
]

{ #category : #'private - timing priority process' }
DelayBasicScheduler >> unscheduleAtTimingPriority [
	"Private! Invoke only from the timing-priority process.
	 This is the back-half of unscheduling a delay. For front-half see #unschedule:"
	
	delayToStop beingWaitedOn ifFalse:[ ^self ].
	
	activeDelay == delayToStop 
		ifTrue: [ activeDelay := suspendedDelays removeFirstOrNil ] 
		ifFalse:[ suspendedDelays remove: delayToStop ifAbsent: [] ].
	
	delayToStop timingPriorityUnschedule.
	delayToStop := nil.
]
