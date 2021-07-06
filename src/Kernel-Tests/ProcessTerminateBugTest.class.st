"
SUnit tests for Process termination
"
Class {
	#name : #ProcessTerminateBugTest,
	#superclass : #TestCase,
	#category : #'Kernel-Tests-Processes'
}

{ #category : #tests }
ProcessTerminateBugTest >> testSchedulerTermination [	
	| process sema gotHere sema2 |
	gotHere := false.
	sema := Semaphore new.
	sema2 := Semaphore new.
	process := [
		sema signal.
		sema2 wait.
		"will be suspended here"
		gotHere := true. "e.g., we must *never* get here" ] forkAt: Processor activeProcess priority.
	sema wait. "until process gets scheduled"
 	process terminate.
	sema2 signal.
	Processor yield. "will give process a chance to continue and
horribly screw up"
	self assert: gotHere not.

]

{ #category : #tests }
ProcessTerminateBugTest >> testTerminationDuringNestedUnwindB1 [
	"Test all nested unwind blocks are correctly unwound; 
	all unwind blocks halfway 	through their execution should be completed."

	| p x1 x2 x3 semaphore |
	x1 := x2 := x3 := false.
	semaphore := Semaphore new.
	p := 
		[
			[
				[ ] ensure: [
					[semaphore wait] ensure: [
						x1 := true]. 
					x2 := true]
			] ensure: [
				x3 := true]
		] newProcess resume.
	Processor yield.
	"make sure p is not suspended and none of the unwind blocks has finished yet;
	ideally we'd like to make sure p is blocked but isBlocked is not implemented"
	self deny: p isSuspended.
	self deny: x1 | x2 | x3.
	"now terminate the process and make sure all unwind blocks have finished"
	p terminate.
	self assert: p isTerminated.
	self assert: x1 & x2 & x3

]

{ #category : #tests }
ProcessTerminateBugTest >> testTerminationDuringNestedUnwindB2 [
	"Test all nested unwind blocks are correctly unwound; 
	all unwind blocks halfway 	through their execution should be completed."

	| p x1 x2 x3 semaphore |
	x1 := x2 := x3 := false.
	semaphore := Semaphore new.
	p := 
		[
			[
				[ ] ensure: [
					[ ] ensure: [
						semaphore wait.
						x1 := true]. 
					x2 := true]
			] ensure: [
				x3 := true]
		] newProcess resume.
	Processor yield.
	"make sure p is not suspended and none of the unwind blocks has finished yet;
	ideally we'd like to make sure p is blocked but isBlocked is not implemented"
	self deny: p isSuspended.
	self deny: x1 | x2 | x3.
	"now terminate the process and make sure all unwind blocks have finished"
	p terminate.
	self assert: p isTerminated.
	self assert: x1 & x2 & x3

]

{ #category : #tests }
ProcessTerminateBugTest >> testTerminationDuringNestedUnwindR1 [
	"Test all nested unwind blocks are correctly unwound; 
	all unwind blocks halfway through their execution should be completed."

	| p x1 x2 x3 |
	x1 := x2 := x3 := false.
	p := 
		[
			[
				[ ] ensure: [
					[Processor yield] ensure: [
						x1 := true]. 
					x2 := true]
			] ensure: [
				x3 := true]
		] newProcess resume.
	Processor yield.
	"make sure p is not suspended and none of the unwind blocks has finished yet;
	ideally we'd like to make sure p is runnable but isRunnable is not implemented"
	self deny: p isSuspended.
	self deny: x1 | x2 | x3.
	"now terminate the process and make sure all unwind blocks have finished"
	p terminate.
	self assert: p isTerminated.
	self assert: x1 & x2 & x3

]

{ #category : #tests }
ProcessTerminateBugTest >> testTerminationDuringNestedUnwindR2 [
	"Test all nested unwind blocks are correctly unwound; 
	all unwind blocks halfway 	through their execution should be completed."

	| p x1 x2 x3 |
	x1 := x2 := x3 := false.
	p := 
		[
			[
				[ ] ensure: [
					[ ] ensure: [
						Processor yield. 
						x1 := true]. 
					x2 := true]
			] ensure: [
				x3 := true]
		] newProcess resume.
	Processor yield.
	"make sure p is not suspended and none of the unwind blocks has finished yet;
	ideally we'd like to make sure p is runnable but isRunnable is not implemented"
	self deny: p isSuspended.
	self deny: x1 | x2 | x3.
	"now terminate the process and make sure all unwind blocks have finished"
	p terminate.
	self assert: p isTerminated.
	self assert: x1 & x2 & x3

]

{ #category : #tests }
ProcessTerminateBugTest >> testTerminationDuringNestedUnwindS1 [
	"Test all nested unwind blocks are correctly unwound; 
	all unwind blocks halfway through their execution should be completed."

	| p x1 x2 x3 |
	x1 := x2 := x3 := false.
	p := 
		[
			[
				[ ] ensure: [
					[Processor activeProcess suspend] ensure: [
						x1 := true]. 
					x2 := true]
			] ensure: [
				x3 := true]
		] newProcess resume.
	Processor yield.
	"make sure p is suspended and none of the unwind blocks has finished yet"
	self assert: p isSuspended.
	self deny: x1 | x2 | x3.
	"now terminate the process and make sure all unwind blocks have finished"
	p terminate.
	self assert: p isTerminated.
	self assert: x1 & x2 & x3

]

{ #category : #tests }
ProcessTerminateBugTest >> testTerminationDuringNestedUnwindS2 [
	"Test all nested unwind blocks are correctly unwound; 
	all unwind blocks halfway through their execution should be completed."

	| p x1 x2 x3 |
	x1 := x2 := x3 := false.
	p := 
		[
			[
				[ ] ensure: [
					[ ] ensure: [
						Processor activeProcess suspend. 
						x1 := true]. 
					x2 := true]
			] ensure: [
				x3 := true]
		] newProcess resume.
	Processor yield.
	"make sure p is suspended and none of the unwind blocks has finished yet"
	self assert: p isSuspended.
	self deny: x1 | x2 | x3.
	"now terminate the process and make sure all unwind blocks have finished"
	p terminate.
	self assert: p isTerminated.
	self assert: x1 & x2 & x3

]

{ #category : #tests }
ProcessTerminateBugTest >> testTerminationDuringUnwind [
	"An illustration of the issue of process termination during unwind.
	This uses a well-behaved unwind block that we should allow to complete
	if at all possible."		
	| unwindStarted unwindFinished p |
	unwindStarted := unwindFinished := false.
	p := [[] ensure:
			[ unwindStarted := true.
			Processor yield.
			unwindFinished := true. ]] fork.
	self deny: unwindStarted.
	Processor yield.
	self assert: unwindStarted.
	self deny: unwindFinished.
	p terminate.
	self assert: unwindFinished.
]

{ #category : #tests }
ProcessTerminateBugTest >> testUnwindFromActiveProcess [
	| sema |
	sema := Semaphore forMutualExclusion.
	self assert: sema isSignaled.
	[ 
	sema critical: [ 
		self deny: sema isSignaled.
		Processor activeProcess terminate ] ] forkAt: Processor userInterruptPriority.
	self assert: sema isSignaled
]

{ #category : #tests }
ProcessTerminateBugTest >> testUnwindFromForeignProcess [

	| sema process |
	sema := Semaphore forMutualExclusion.
	self assert: sema isSignaled.
	process := [ 
	sema
		critical: [ 
			self deny: sema isSignaled.
			sema wait	"deadlock" ] ] forkAt: Processor userInterruptPriority.
	self deny: sema isSignaled.	"This is for illustration only - the BlockCannotReturn cannot 
	be handled here (it's truncated already)"
	process terminate.
	self assert: sema isSignaled
]
