Extension { #name : #Time }

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> benchmarkMillisecondClock [
	"Benchmark the time spent in a call to Time>>millisecondClockValue.
	On the VM level this tests the efficiency of calls to ioMSecs()."
	<script>
	
	"PII/400 Windows 98: 0.725 microseconds per call"	
	| temp1 temp2 temp3 delayTime nLoops time |
	delayTime := 5000. "Time to run benchmark is approx. 2*delayTime"

	"Don't run the benchmark if we have an active delay since
	we will measure the additional penalty in the primitive dispatch
	mechanism (see #benchmarkPrimitiveResponseDelay)."
	Delay anyActive ifTrue: [ 
		^ self notify: 'Some delay is currently active.
Running this benchmark will not give any useful result.' ].

	"Flush the cache for this benchmark so we will have
	a clear cache hit for each send to #millisecondClockValue below"
	Object flushCache.
	temp1 := 0.
	temp2 := self. "e.g., temp1 == Time"
	temp3 := self millisecondClockValue + delayTime.

	"Now check how often we can run the following loop in the given time"
	[ temp2 millisecondClockValue < temp3 ] whileTrue: [ 
		temp1 := temp1 + 1 ].

	nLoops := temp1. "Remember the loops we have run during delayTime"

	"Setup the second loop"
	temp1 := 0.
	temp3 := nLoops.

	"Now measure how much time we spend without sending #millisecondClockValue"
	time := Time millisecondClockValue.
	[ temp1 < temp3 ] whileTrue: [ temp1 := temp1 + 1 ].
	time := Time millisecondsSince: time.

	"And compute the number of microseconds spent per call to #millisecondClockValue"
	^ (delayTime - time * 1000.0 / nLoops truncateTo: 0.001) printString
	  , ' microseconds per call to Time>>millisecondClockValue'
]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> benchmarkPrimitiveResponseDelay [	 
	"Benchmark the overhead for primitive dispatches with an active Delay.
	On the VM level, this tests the efficiency of ioLowResMSecs."
	<script>
	
	"PII/400 Windows98: 0.128 microseconds per prim"
	
	"ar 9/6/1999: This value is *extremely* important for stuff like sockets etc.
	I had a bad surprise when Michael pointed this particular problem out:
	Using the hardcoded clock() call for ioLowResMSecs on Win32 resulted in an overhead
	of 157.4 microseconds per primitive call - meaning you can't get no more than
	approx. 6000 primitives per second on my 400Mhz PII system with an active delay!
	BTW, it finally explains why Squeak seemed soooo slow when running PWS or 
	other socket stuff. The new version (not using clock() but some Windows function) 
	looks a lot better (see above; approx. 8,000,000 prims per sec with an active delay)."

	| nLoops bb index baseTime actualTime delayTime |
	delayTime := 5000. "Time to run this test is approx. 3*delayTime"

	Delay anyActive ifTrue:[
		^self notify:'Some delay is currently active.
Running this benchmark will not give any useful result.'].

	bb := Array new: 1. "The object we send the prim message to"

	"Compute the # of loops we'll run in a decent amount of time"
	[(Delay forMilliseconds: delayTime) wait] 
		forkAt: Processor userInterruptPriority.

	nLoops := 0.
	[Delay anyActive] whileTrue:[
		bb basicSize; basicSize; basicSize; basicSize; basicSize; 
			basicSize; basicSize; basicSize; basicSize; basicSize.
		nLoops := nLoops + 1.
	].

	"Flush the cache and make sure #basicSize is in there"
	Object flushCache.
	bb basicSize.

	"Now run the loop without any active delay
	for getting an idea about its actual speed."
	baseTime := self millisecondClockValue.
	index := nLoops.
	[index > 0] whileTrue:[
		bb basicSize; basicSize; basicSize; basicSize; basicSize; 
			basicSize; basicSize; basicSize; basicSize; basicSize.
		index := index - 1.
	].
	baseTime := self millisecondsSince: baseTime.

	"Setup the active delay but try to never make it active"
	[(Delay forMilliseconds: delayTime + delayTime) wait] 
		forkAt: Processor userInterruptPriority.

	"And run the loop"
	actualTime := self millisecondClockValue.
	index := nLoops.
	[index > 0] whileTrue:[
		bb basicSize; basicSize; basicSize; basicSize; basicSize; 
			basicSize; basicSize; basicSize; basicSize; basicSize.
		index := index - 1.
	].
	actualTime := self millisecondsSince: actualTime.

	"And get us some result"
	^((actualTime - baseTime) * 1000 asFloat / (nLoops * 10) truncateTo: 0.001) printString,
		' microseconds overhead per primitive call'
]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> dateAndTimeFromSeconds: secondCountSinceEpoch [
 
	| dateAndTime |
	dateAndTime := DateAndTime fromSeconds: secondCountSinceEpoch.
 	^ Array
 		with: dateAndTime asDate
 		with: dateAndTime asTime
]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> fromString: aString [
	^ self readFrom: aString readStream.

]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> hour: hour minute: minute second: second [
	"Answer a Time"
 
 	^ self hour: hour minute: minute second: second nanoSecond: 0
]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> hour: hour minute: minute second: second  nano: nano [
 
	| nanoMultiplicative |
	
	nanoMultiplicative := 1000000000 / (10 ** nano numberOfDigits).	
	
 	^ self hour: hour minute: minute second: second nanoSecond: nano * nanoMultiplicative
]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> hour: hour minute: minute second: second  nanoSecond: nanoCount [
	"Answer a Time - only second precision for now"
	
	hour >= HoursInDay ifTrue: [ Error new signal: ('An hour must be {1} or less' format: {HoursInDay})].
	minute >= MinutesInHour ifTrue: [ Error new signal: ('A minute must be {1} or less' format: {MinutesInHour}) ].
	second > SecondsInMinute ifTrue: [ Error new signal: ('A second must be {1} or less' format: {SecondsInMinute}) ].
	
 	^ self 
		seconds: (hour * SecondsInHour) + (minute * SecondsInMinute) + second 
		nanoSeconds: nanoCount
]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> midnight [

	^ self seconds: 0

]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> milliseconds: currentTime since: lastTime [
	"Answer the elapsed time since last recorded in milliseconds.
	Compensate for rollover."

	| delta |
	delta := currentTime - lastTime.
	^ delta < 0
		ifTrue: [SmallInteger maxVal + delta]
		ifFalse: [delta]

]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> millisecondsSince: lastTime [
 	"Answer the elapsed time since last recorded in milliseconds.
 	Compensate for rollover."
 
 	^self milliseconds: self millisecondClockValue since: lastTime
]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> millisecondsToRun: timedBlock [ 
	"Answer the number of milliseconds timedBlock takes to return its value."

	^(self microsecondsToRun: timedBlock) // 1e3
]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> noon [

	^ self seconds: (SecondsInDay / 2)

]

{ #category : #'*Kernel-Chronology-Extras' }
Time class >> readFrom: aStream [

	"Read a Time from the stream in the form:
		<hour>:<minute>:<second>.<nseconds> <am/pm>
	<minute>, <second> or <am/pm> may be omitted.  e.g. 1:59:30 pm; 8AM; 15:30"

	| hour minute second ampm nanos power |
	hour := Integer readFrom: aStream.
	minute := second := nanos := 0.
	(aStream peekFor: $:) ifTrue: [ 
		minute := Integer readFrom: aStream.
		(aStream peekFor: $:) ifTrue: [ 
			second := Integer readFrom: aStream.
			(aStream peekFor: $.) ifTrue: [ 
				power := 1.
				[ aStream atEnd not and: [ aStream peek isDigit ] ] whileTrue: [ 
					nanos := nanos * 10 + aStream next digitValue.
					power := power * 10 ].
				nanos := nanos / power * 1000000000 ] ] ].
	aStream skipSeparators.
	aStream atEnd ifFalse: [ 
		('APap' includes: aStream peek)
			ifTrue: [ 
				ampm := aStream next asLowercase.
				(ampm = $p and: [ hour < 12 ]) ifTrue: [ hour := hour + 12 ].
				(ampm = $a and: [ hour = 12 ]) ifTrue: [ hour := 0 ].
				(aStream peekFor: $m) ifFalse: [ aStream peekFor: $M ] ]
			ifFalse: [ 
				('Z+-' includes: aStream peek) ifFalse: [ 
					Error new signal: 'Trailing characters after time' ] ] ].

	aStream skipSeparators.
	aStream atEnd ifFalse: [  
	    ('Z+-' includes: aStream peek) ifFalse: [ 
					Error new signal: 'Trailing characters after time' ]].
	
	^ self
		  hour: hour
		  minute: minute
		  second: second
		  nanoSecond: nanos
]

{ #category : #'*Kernel-Chronology-Extras' }
Time >> to: anEnd [
	"Answer a Timespan. anEnd must respond to #asDateAndTime"

	^ self asDateAndTime to: anEnd
]
