"
My instances observe and report the amount of time spent in methods.

NOTE: a higher-level user interface (combining the MessageTally result tree with a method browser) is available from TimeProfileBrowser. Note that TimeProfileBrowser was not fancy with the different setting possibilities.

	TimeProfileBrowser spyOn:  [20 timesRepeat: 
			[Transcript show: 100 factorial printString]]
	

Strategies
-----------
MessageTally provides two different strategies available for profiling:

* spyOn: and friends use a high-priority Process to interrupt the block or process being spied on at periodic intervals. The interrupted call stack is then examined for caller information. See below for an example showing different settings

* tallySends: and friends use the interpreter simulator to run the block, recording every method call.

The two give you different results:

	* spyOn: gives you a view of where the time is being spent in your program, at least on a rough statistical level (assuming you've run the 	block for long enough and have a high enough poll rate). If you're trying to optimize your code, start here and optimize the methods where 	most of the time is being spent first.

	* tallySends: gives you accurate counts of how many times methods get called, and by exactly which route. If you're debugging, or trying to 	figure out if a given method is getting called too many times, this is your tool.

Q: How do you interpret MessageTally>>tallySends
A: The methods #tallySends and #spyOn: measure two very different quantities, but broken down in the same who-called-who format.  #spyOn: is approximate, but more indicative of real time spent, whereas #tallySends is exact and a precise record of how many times each method got executed.

Examples
----------

Here you can see all the processes computation time
	
		[1000 timesRepeat: [3.14159 printString. Processor yield]] fork.
		[1000 timesRepeat: [30 factorial. Processor yield]] fork.
		[1000 timesRepeat: [30 factorial. Processor yield]] fork.
		MessageTally spyAllOn: [ (Delay forMilliseconds: 100) wait] 


Settings
---------
You can change the printing format (that is, the whitespace and string compression) by using these instance methods: 
	maxClassNameSize:
	maxClassPlusSelectorSize:
	maxTabs:

You can change the default polling period (initially set to 1) by calling
	MessageTally defaultPollPeriod: numberOfMilliseconds


To understand the difference
----------------------------------
Here we see all the processes
	[1000 timesRepeat: [
		100 timesRepeat: [120 factorial].
		(Delay forMilliseconds: 10) wait
		]] forkAt: 45 named: '45'.
	MessageTally spyAllOn: [10000 timesRepeat: [1.23 printString]]
	
	
Here we only see the execution of the expression [10000 timesRepeat: [1.23 printString]
	[1000 timesRepeat: [
		100 timesRepeat: [120 factorial].
		(Delay forMilliseconds: 10) wait
		]] forkAt: 45 named: '45'.
	MessageTally spyOn: [10000 timesRepeat: [1.23 printString]]
	
Here we only check the exact message sends: this is not a pc-sampling approach
	[1000 timesRepeat: [
		100 timesRepeat: [120 factorial].
		(Delay forMilliseconds: 10) wait
		]] forkAt: 45 named: '45'.
	MessageTally tallySends: [10000 timesRepeat: [1.23 printString]]
	



"
Class {
	#name : #MessageTally,
	#superclass : #Magnitude,
	#instVars : [
		'class',
		'method',
		'process',
		'tally',
		'receivers',
		'senders',
		'time',
		'gcStats',
		'maxClassNameSize',
		'maxClassPlusSelectorSize',
		'maxTabs',
		'reportOtherProcesses'
	],
	#classVars : [
		'DefaultPollPeriod',
		'Timer'
	],
	#category : #'Tool-Profilers-Messages'
}

{ #category : #defaults }
MessageTally class >> defaultMaxClassNameSize [
	"Return the default maximum width of the class name alone"
	^50
]

{ #category : #defaults }
MessageTally class >> defaultMaxClassPlusSelectorSize [
	"Return the default maximum width of the class plus selector together (not counting the '>>')"
	^100
]

{ #category : #defaults }
MessageTally class >> defaultMaxTabs [
	"Return the default number of tabs after which leading white space is compressed"
	^120
]

{ #category : #defaults }
MessageTally class >> defaultPollPeriod [
	"Answer the number of milliseconds between interrupts for spyOn: and friends.
	This should be faster for faster machines."
	^DefaultPollPeriod ifNil: [ DefaultPollPeriod := 1 ]
]

{ #category : #defaults }
MessageTally class >> defaultPollPeriod: numberOfMilliseconds [
	"Set the default number of milliseconds between interrupts for spyOn: and friends.
	This should be faster for faster machines."
	DefaultPollPeriod := numberOfMilliseconds
]

{ #category : #examples }
MessageTally class >> example [

	[1000 timesRepeat: [3.14159 printString. Processor yield]] fork.
	[1000 timesRepeat: [20 factorial. Processor yield]] fork.
	[1000 timesRepeat: [20 factorial. Processor yield]] fork.
	MessageTally spyAllOn: [ (Delay forMilliseconds: 100) wait]
]

{ #category : #examples }
MessageTally class >> exampleSpyForSeconds [

	self spyFor: 2
]

{ #category : #spying }
MessageTally class >> spyAllOn: aBlock [
	"Spy on all the processes in the system"
	<script: 'self example'>
	^ self spyAllOn: aBlock cutoff: 1
]

{ #category : #spying }
MessageTally class >> spyAllOn: aBlock cutoff: aNumber [
	| node result |
	node := self new.
	node reportOtherProcesses: true.	"Irrelevant in this case. All processes will be reported on their own."
	result := node spyAllEvery: self defaultPollPeriod on: aBlock.
	StandardWindow new
		withText:
				(String streamContents: [ :s |  node report: s cutoff: aNumber; close ])
			label: 'Spy Results';
		openInWorld.
	^ result
]

{ #category : #spying }
MessageTally class >> spyOn: aBlock [
	"
	Spy on aBlock, in the current process. Can include or not statistics on other processes in the report.
	[1000 timesRepeat: [
		100 timesRepeat: [120 factorial].
		(Delay forMilliseconds: 10) wait
		]] forkAt: 45 named: '45'.
	MessageTally spyOn: [10000 timesRepeat: [1.23 printString]]
	"
	^self spyOn: aBlock reportOtherProcesses: false
]

{ #category : #spying }
MessageTally class >> spyOn: aBlock cutoff: aNumber [

	^self spyOn: aBlock reportOtherProcesses: false cutoff: aNumber
]

{ #category : #spying }
MessageTally class >> spyOn: aBlock reportOtherProcesses: aBoolean [
	"
	Spy on aBlock, in the current process. Can include or not statistics on other processes in the report.
	[1000 timesRepeat: [
		100 timesRepeat: [120 factorial].
		(Delay forMilliseconds: 10) wait
		]] forkAt: 45 named: '45'.
	MessageTally spyOn: [10000 timesRepeat: [1.23 printString]] reportOtherProcesses: true
	"
	^ self spyOn: aBlock reportOtherProcesses: aBoolean cutoff: 1
]

{ #category : #spying }
MessageTally class >> spyOn: aBlock reportOtherProcesses: aBoolean cutoff: aNumber [
	"
	Spy on aBlock, in the current process. Can include or not statistics on other processes in the report.
	[1000 timesRepeat: [
		100 timesRepeat: [120 factorial].
		(Delay forMilliseconds: 10) wait
		]] forkAt: 45 named: '45'.
	MessageTally spyOn: [10000 timesRepeat: [1.23 printString]] reportOtherProcesses: true
	"
	^ self 
		spyOn: aBlock 
		reportOtherProcesses: aBoolean 
		cutoff: aNumber 
		openResultWindow: true 
		closeAfter: true
]

{ #category : #spying }
MessageTally class >> spyOn: aBlock reportOtherProcesses: aBoolean cutoff: aNumber openResultWindow: openResultWindow [

	^ self 
		spyOn: aBlock 
		reportOtherProcesses: aBoolean 
		cutoff: aNumber 
		openResultWindow: openResultWindow 
		closeAfter: true
]

{ #category : #spying }
MessageTally class >> spyOn: aBlock reportOtherProcesses: aBoolean cutoff: aNumber openResultWindow: openResultWindow closeAfter: closeAfter [
	| node |
	node := self new.
	node reportOtherProcesses: aBoolean.
	node spyEvery: self defaultPollPeriod on: aBlock.
	openResultWindow
		ifTrue: [ 
			StandardWindow new
				withText: (String streamContents: [ :s | node report: s cutoff: aNumber ]) label: 'Spy Results';
				openInWorld ].
	closeAfter
		ifTrue: [ node close ].
	^ node
]

{ #category : #public }
MessageTally class >> spyOn: aBlock toFileNamed: fileName reportOtherProcesses: aBoolean [
	"Spy on the evaluation of aBlock. Write the data collected on a file
	named fileName."

	| value node |
	node := self new.
	node reportOtherProcesses: aBoolean.
	value := node spyEvery: self defaultPollPeriod on: aBlock.
	fileName asFileReference writeStreamDo: [ :out | node report: out ].
	^ value
]

{ #category : #spying }
MessageTally class >> spyOnProcess: aProcess forMilliseconds: msecDuration [ 

	^self spyOnProcess: aProcess forMilliseconds: msecDuration reportOtherProcesses: false

]

{ #category : #spying }
MessageTally class >> spyOnProcess: aProcess forMilliseconds: msecDuration reportOtherProcesses: aBoolean [
	"
	Spy on aProcess for a certain amount of time
	| p1 p2 |  
	p1 := [100000 timesRepeat: [3.14159 printString. Processor yield]] newProcess.  
	p2 := [100000 timesRepeat: [3.14159 printString. Processor yield]] newProcess.
	p1 resume.
	p2 resume.  
	(Delay forMilliseconds: 100) wait.  
	MessageTally spyOnProcess: p1 forMilliseconds: 1000 reportOtherProcesses: true
	"
	| node |
	node := self new.
	node reportOtherProcesses: aBoolean.
	node
		spyEvery: self defaultPollPeriod
		onProcess: aProcess
		forMilliseconds: msecDuration.
	StandardWindow new
		withText:  (String streamContents: [:s | node report: s])
		 label: 'Spy Results';
		openInWorld.
]

{ #category : #spying }
MessageTally class >> spyOnProcess: aProcess forMilliseconds: msecDuration toFileNamed: fileName reportOtherProcesses: aBoolean [
	"Spy on the evaluation of aProcess. Write the data collected on a file  
	named fileName. Will overwrite fileName"
	
	| node |
	node := self new.
	node reportOtherProcesses: aBoolean.
	node
		spyEvery: self defaultPollPeriod
		onProcess: aProcess
		forMilliseconds: msecDuration.
	fileName asFileReference writeStreamDo: [ :out | node report: out ]
]

{ #category : #public }
MessageTally class >> tallySends: aBlock [
	"
	MessageTally tallySends: [3.14159 printString]
	"
	
	"This method uses the simulator to count the number of calls on each method
	invoked in evaluating aBlock. If receiver is not nil, then only sends
	to that receiver are tallied.
	Results are presented as leaves, sorted by frequency,
	preceded, optionally, by the whole tree."

	^ self tallySendsTo: nil inBlock: aBlock showTree: true
]

{ #category : #spying }
MessageTally class >> tallySendsTo: receiver inBlock: aBlock showTree: treeOption [
	^ self tallySendsTo: receiver inBlock: aBlock showTree: treeOption closeAfter: true
]

{ #category : #spying }
MessageTally class >> tallySendsTo: receiver inBlock: aBlock showTree: treeOption closeAfter: closeAfter [
	^ self tallySendsTo: receiver inBlock: aBlock showTree: treeOption closeAfter: closeAfter openResultWindow: true
]

{ #category : #spying }
MessageTally class >> tallySendsTo: receiver inBlock: aBlock showTree: treeOption closeAfter: closeAfter openResultWindow: openResultWindow [
	"
	MessageTally tallySends: [3.14159 printString]
	"
	"This method uses the simulator to count the number of calls on each method
	invoked in evaluating aBlock. If receiver is not nil, then only sends
	to that receiver are tallied.
	Results are presented as leaves, sorted by frequency,
	preceded, optionally, by the whole tree."
	| prev tallies startTime totalTime |
	startTime := Time millisecondClockValue.
	tallies := self new class: aBlock receiver class method: aBlock method.
	tallies reportOtherProcesses: true.	"Do NOT filter nodes with nil process"
	prev := aBlock.
	thisContext sender
		runSimulated: aBlock
		contextAtEachStep:
			[:current |
			current == prev ifFalse: 
				["call or return"
				prev sender ifNotNil: 
					["call only"
					(receiver isNil or: [current receiver == receiver])
						ifTrue: [tallies tally: current by: 1]].
				prev := current]].

	totalTime := Time millisecondClockValue - startTime // 1000.0 roundTo: 0.01.
	openResultWindow ifTrue: [
		StandardWindow new 
			withText: (String streamContents:
				[:s |
				s nextPutAll: 'This simulation took ' , totalTime printString
								, ' seconds.'; cr.
				treeOption
					ifTrue: [ tallies fullPrintExactOn: s ]
					ifFalse: [ tallies leavesPrintExactOn: s ].
				])
			 label: 'Spy Results';
			openInWorld ].
	closeAfter ifTrue: [ tallies close ].
	^ tallies
]

{ #category : #private }
MessageTally class >> terminateTimerProcess [
	<script>
	Timer ifNotNil: [ Timer terminate ].
	Timer := nil
]

{ #category : #spying }
MessageTally class >> time: aBlock [

	^ Time millisecondsToRun: aBlock
]

{ #category : #comparing }
MessageTally >> < aMessageTally [ 
	"Refer to the comment in Magnitude|<."

	^tally > aMessageTally tally
]

{ #category : #comparing }
MessageTally >> = aMessageTally [

	self species == aMessageTally species ifFalse: [^ false].
	^ aMessageTally method == method 
		and: [ aMessageTally process == process ]
]

{ #category : #comparing }
MessageTally >> > aMessageTally [ 
	"Refer to the comment in Magnitude|>."

	^tally < aMessageTally tally
]

{ #category : #'collecting leaves' }
MessageTally >> bump: hitCount [
	tally := tally + hitCount
]

{ #category : #'collecting leaves' }
MessageTally >> bump: hitCount fromSender: senderTally [
	"Add this hitCount to the total, and include a reference to the
	sender responsible for the increment"
	self bump: hitCount.
	senders ifNil: [senders := OrderedCollection new].
	senderTally ifNotNil: [senders add: (senderTally copyWithTally: hitCount)]
]

{ #category : #tallying }
MessageTally >> bumpBy: count [

	tally := tally + count
]

{ #category : #private }
MessageTally >> class: aClass method: aMethod [

	class := aClass.
	method := aMethod.
	tally := 0.
	receivers := Array new: 0
]

{ #category : #private }
MessageTally >> close [

	Timer ifNotNil: [ Timer terminate ].
	Timer := nil.
	class := method := tally := receivers := nil
]

{ #category : #private }
MessageTally >> copyWithTally: hitCount [
	^ (self class new class: class method: method)
		reportOtherProcesses: reportOtherProcesses;
		process: process;
		bump: hitCount
]

{ #category : #printing }
MessageTally >> displayStringOn: aStream [
	self displayIdentifierOn: aStream.
	aStream 
		nextPutAll: ' (';
		nextPutAll: self tally printString;
		nextPutAll: ')'
]

{ #category : #printing }
MessageTally >> fullPrintExactOn: aStream [
	aStream nextPutAll: '**Tree**'; cr.
	self
		treePrintOn: aStream
		tabs: OrderedCollection new
		thisTab: ''
		total: tally
		totalTime: time
		tallyExact: true
		orThreshold: nil.
	aStream nextPut: Character newPage; cr.
	aStream nextPutAll: '**Leaves**'; cr.
	self leavesPrintExactOn: aStream
]

{ #category : #printing }
MessageTally >> fullPrintOn: aStream threshold: perCent [
	| threshold |  
	threshold := (perCent asFloat / 100 * tally) rounded.
	aStream nextPutAll: '**Tree**'; cr.
	self
		rootPrintOn: aStream
		total: tally
		totalTime: time
		threshold: threshold.
	aStream nextPut: Character newPage; cr.
	aStream nextPutAll: '**Leaves**'; cr.
	self
		leavesPrintOn: aStream
		threshold: threshold
]

{ #category : #comparing }
MessageTally >> hash [
	"Hash is reimplemented because = is implemented."

	^method hash
]

{ #category : #initialization }
MessageTally >> initialize [
	"We do not do a super initialize since it is not strickly necessary and more importantly MessageTally must be instantiated quickly"
	"super initialize."
	
	maxClassNameSize := self class defaultMaxClassNameSize.
	maxClassPlusSelectorSize := self class defaultMaxClassPlusSelectorSize.
	maxTabs := self class defaultMaxTabs.
	reportOtherProcesses := true.
	time := 0.
	tally := 0.
]

{ #category : #'collecting leaves' }
MessageTally >> into: leafDict fromSender: senderTally [ 
	| leafNode |
	leafNode := leafDict at: method
				ifAbsentPut: 
					[ (self class new class: class method: method)
						process: process;
						reportOtherProcesses: reportOtherProcesses ].
					
	leafNode bump: tally fromSender: senderTally
]

{ #category : #comparing }
MessageTally >> isPrimitives [
	"Detect pseudo node used to carry tally of local hits"
	^ receivers isNil
]

{ #category : #'collecting leaves' }
MessageTally >> leavesInto: leafDict fromSender: senderTally [

	| rcvrs |
	rcvrs := self sonsOver: 0.
	rcvrs isEmpty
		ifTrue: [ self into: leafDict fromSender: senderTally ]
		ifFalse: [
			
			(reportOtherProcesses not and: [ rcvrs anyOne process isNil ]) ifTrue: [
				^self].
			
			rcvrs do: [ :node |
				node isPrimitives
					ifTrue: [ node leavesInto: leafDict fromSender: senderTally ]
					ifFalse: [ node leavesInto: leafDict fromSender: self ]]]
]

{ #category : #printing }
MessageTally >> leavesPrintExactOn: aStream [
	| dict |
	dict := IdentityDictionary new: 100.
	self leavesInto: dict fromSender: nil.
	dict asSortedCollection
		do: [ :node |
			node printOn: aStream total: tally totalTime: nil tallyExact: true.
			node printSenderCountsOn: aStream ]
]

{ #category : #printing }
MessageTally >> leavesPrintOn: aStream threshold: threshold [
	| dict |
	dict := IdentityDictionary new: 100.
	self leavesInto: dict fromSender: nil.
	(dict asOrderedCollection
			select: [:node | node tally > threshold])
		asSortedCollection do: [:node |
			node printOn: aStream total: tally totalTime: time tallyExact: false ]
]

{ #category : #'printing format' }
MessageTally >> maxClassNameSize [
	^maxClassNameSize
]

{ #category : #'printing format' }
MessageTally >> maxClassNameSize: aNumber [
	maxClassNameSize := aNumber
]

{ #category : #'printing format' }
MessageTally >> maxClassPlusSelectorSize [
	^maxClassPlusSelectorSize
]

{ #category : #'printing format' }
MessageTally >> maxClassPlusSelectorSize: aNumber [
	maxClassPlusSelectorSize := aNumber
]

{ #category : #'printing format' }
MessageTally >> maxTabs [
	^maxTabs
]

{ #category : #'printing format' }
MessageTally >> maxTabs: aNumber [
	maxTabs := aNumber
]

{ #category : #accessing }
MessageTally >> method [
	"Return the compiled method associated to this tally"
	
	^method
]

{ #category : #private }
MessageTally >> primitives: anInteger [

	tally := anInteger.
	receivers := nil
]

{ #category : #printing }
MessageTally >> printOn: aStream [ 
	| aSelector className |
	(class isNil or: [method isNil]) ifTrue: [^super printOn: aStream].
	aSelector := method selector.
	className := method methodClass name.
	aStream
		nextPutAll: (class name contractTo: self maxClassNameSize);
		nextPutAll: '(';
		nextPutAll: (className  contractTo: self maxClassNameSize);
		nextPutAll: ')';
		nextPutAll: ' >> ';
		nextPutAll: (aSelector 
					contractTo: self maxClassPlusSelectorSize - className size)
]

{ #category : #printing }
MessageTally >> printOn: aStream total: total totalTime: totalTime tallyExact: isExact [ 

	isExact 
		ifTrue: [
			| myTally |
			myTally := tally.
			receivers == nil 
				ifFalse: [receivers do: [:r | myTally := myTally - r tally]].
			aStream
				print: myTally;
				space]
		ifFalse: [
			| percentage |
			percentage := tally asFloat / total * 100.0.
			aStream
				nextPutAll: (percentage printShowingDecimalPlaces: 1);
				nextPutAll: '% {';
				print: (percentage * totalTime / 100) rounded;
				nextPutAll: 'ms} '].
	receivers 
		ifNil: [
			aStream
				nextPutAll: 'primitives';
				cr]
		ifNotNil: [
			| className aSelector aClass |
			aSelector := method selector.
			aClass := method methodClass.
			className := aClass name contractTo: self maxClassNameSize.
			aStream
				nextPutAll: class name;
				nextPutAll: (aClass = class 
							ifTrue: ['>>']
							ifFalse: ['(' , aClass name , ')>>']);
				nextPutAll: (aSelector 
							contractTo: self maxClassPlusSelectorSize - className size);
				cr]
]

{ #category : #printing }
MessageTally >> printSenderCountsOn: aStream [
	| mergedSenders |
	mergedSenders := IdentityDictionary new.
	senders do: [ :node | | mergedNode |
		mergedNode := mergedSenders at: node method ifAbsent: [ nil ].
		mergedNode
			ifNil: [ mergedSenders at: node method put: node ]
			ifNotNil: [ mergedNode bump: node tally ]].
	mergedSenders asSortedCollection do: [ :node | 
		10 to: node tally printString size by: -1 do: [ :i | aStream space].
		node printOn: aStream total: tally totalTime: nil tallyExact: true]
]

{ #category : #accessing }
MessageTally >> process [
	"Return the profiled process"
	
	^process
]

{ #category : #accessing }
MessageTally >> process: aProcess [
	process := aProcess
]

{ #category : #accessing }
MessageTally >> receivers [ 
	^ receivers 
]

{ #category : #reporting }
MessageTally >> report: strm [ 
	"Print a report, with cutoff percentage of each element of the tree 
	(leaves, roots, tree), on the stream, strm."

	self report: strm cutoff: 1
]

{ #category : #reporting }
MessageTally >> report: strm cutoff: threshold [ 
	tally = 0
		ifTrue: [strm nextPutAll: ' - no tallies obtained']
		ifFalse: 
			[strm nextPutAll: ' - '; print: tally; nextPutAll: ' tallies, ', time printString, ' msec.'; cr; cr.
			self fullPrintOn: strm threshold: threshold].
		
	time isZero ifFalse:	
		[self reportGCStatsOn: strm].
]

{ #category : #reporting }
MessageTally >> reportGCStatsOn: str [
	| oldSpaceEnd youngSpaceEnd memoryEnd fullGCs fullGCTime incrGCs incrGCTime tenureCount upTime rootOverflows |
	upTime := time.
	oldSpaceEnd			:= gcStats at: 1.
	youngSpaceEnd		:= gcStats at: 2.
	memoryEnd			:= gcStats at: 3.
	fullGCs				:= gcStats at: 7.
	fullGCTime			:= gcStats at: 8.
	incrGCs				:= gcStats at: 9.
	incrGCTime			:= gcStats at: 10.
	tenureCount			:= gcStats at: 11.
	rootOverflows		:= gcStats at: 22.

	str cr.
	str	nextPutAll: '**Memory**'; cr.
	str	nextPutAll:	'	old			'.
	oldSpaceEnd printWithCommasSignedOn: str. 
	str nextPutAll: ' bytes'; cr.
	str	nextPutAll: '	young		'.
	(youngSpaceEnd - oldSpaceEnd) printWithCommasSignedOn: str. 
	str  nextPutAll: ' bytes'; cr.
	str	nextPutAll: '	used		'.
	youngSpaceEnd printWithCommasSignedOn: str. 
	str  nextPutAll: ' bytes'; cr.
	str	nextPutAll: '	free		'.
	(memoryEnd - youngSpaceEnd) printWithCommasSignedOn: str. 
	str  nextPutAll: ' bytes'; cr.

	str cr.
	str	nextPutAll: '**GCs**'; cr.
	str	nextPutAll: '	full			';
		print: fullGCs; nextPutAll: ' totalling '.
	fullGCTime printWithCommasOn: str.
	str nextPutAll: 'ms (';
		print: ((fullGCTime / upTime * 100) roundTo: 1.0);
		nextPutAll: '% uptime)'.
	fullGCs = 0 ifFalse:
		[str	nextPutAll: ', avg '; print: ((fullGCTime / fullGCs) roundTo: 1.0); nextPutAll: 'ms'].
	str	cr.
	str	nextPutAll: '	incr		';
		print: incrGCs; nextPutAll: ' totalling '.
	incrGCTime printWithCommasOn: str.
	str nextPutAll: 'ms (';
		print: ((incrGCTime / upTime * 100) roundTo: 1.0);
		nextPutAll: '% uptime)'.
	incrGCs = 0 ifFalse:
		[str nextPutAll:', avg '; print: ((incrGCTime / incrGCs) roundTo: 1.0); nextPutAll: 'ms'].
	str cr.
	str	nextPutAll: '	tenures		'.
	tenureCount printWithCommasOn: str.
	tenureCount = 0 ifFalse:
		[str nextPutAll: ' (avg '; print: (incrGCs / tenureCount) asInteger; nextPutAll: ' GCs/tenure)'].
	str	cr.
	str	nextPutAll: '	root table	'.
	rootOverflows printWithCommasOn: str.
	str nextPutAll:' overflows'.
	str cr.

]

{ #category : #accessing }
MessageTally >> reportOtherProcesses [
	^ reportOtherProcesses
]

{ #category : #accessing }
MessageTally >> reportOtherProcesses: aBoolean [
	reportOtherProcesses := aBoolean
]

{ #category : #printing }
MessageTally >> rootPrintOn: aStream total: total totalTime: totalTime threshold: threshold [

	| groups |
	groups := (self sonsOver: threshold) groupedBy: [ :aTally | aTally process] having: [ :g | true ].
	groups do: [ :g |
		| sons p |
		sons := g asArray sort.
		p := g anyOne process.
		(reportOtherProcesses or: [ p notNil ]) ifTrue: [
			aStream nextPutAll: '--------------------------------'; cr.
			aStream nextPutAll: 'Process: ',  (p ifNil: [ 'other processes'] ifNotNil: [ p browserPrintString]); cr.
			aStream nextPutAll: '--------------------------------'; cr.
			sons do: [ :son |
				son
					treePrintOn: aStream
					tabs: OrderedCollection new
					thisTab: ''
					total: total
					totalTime: totalTime
					tallyExact: false
					orThreshold: threshold]].
	]
]

{ #category : #comparing }
MessageTally >> sonsOver: threshold [
	"Returns all the sons that are not below a certain threshold. threshold is a number."
	| hereTally sons |
	(receivers isNil or: [ receivers isEmpty ]) ifTrue: [ ^#() ].
	hereTally := tally.
	sons := receivers select: [ :son | "subtract subNode tallies for primitive hits here"
		hereTally := hereTally - son tally.
		son tally > threshold ].
	hereTally > threshold
		ifTrue: [
			| last |
			last := self class new class: class method: method.
			last process: process.
			last reportOtherProcesses: reportOtherProcesses.
			^sons copyWith: (last primitives: hereTally)].
	^sons
]

{ #category : #initialization }
MessageTally >> spyAllEvery: millisecs on: aBlock [
	"Create a spy and spy on the given block at the specified rate."
	"Spy all the system processes"

	| myDelay time0 |
	aBlock isBlock
		ifFalse: [ self error: 'spy needs a block here' ].
	self class: aBlock receiver class method: aBlock method.
		"set up the probe"
	myDelay := Delay forMilliseconds: millisecs.
	time0 := Time millisecondClockValue.
	gcStats := Smalltalk vm getParameters.
	Timer ifNotNil: [ self error: 'it seems a tally is already running' ].
	Timer := [
		[true] whileTrue: [
			| startTime observedProcess |
			startTime := Time millisecondClockValue.
			myDelay wait.
			observedProcess := Processor preemptedProcess.
			self
				tally: observedProcess suspendedContext
				in: observedProcess
				"tally can be > 1 if ran a long primitive"
				by: (Time millisecondClockValue - startTime) // millisecs].
		nil] newProcess.
	Timer priority: Processor timingPriority-1.
		"activate the probe and evaluate the block"
	Timer resume.
	^ aBlock ensure: [
		"cancel the probe and return the value"
		"Could have already been terminated. See #terminateTimerProcess"
		Timer ifNotNil: [
			Timer terminate.
			Timer := nil ].
		"Collect gc statistics"
		Smalltalk vm getParameters keysAndValuesDo: [ :idx :gcVal | 
			gcVal isNumber ifTrue: [ gcStats at: idx put: (gcVal - (gcStats at: idx))]].
		time := Time millisecondClockValue - time0]
]

{ #category : #initialization }
MessageTally >> spyEvery: millisecs on: aBlock [
	"Create a spy and spy on the given block at the specified rate."
	"Spy only on the active process (in which aBlock is run)"

	| myDelay time0 observedProcess |
	aBlock isBlock
		ifFalse: [ self error: 'spy needs a block here' ].
	self class: aBlock receiver class method: aBlock method.
		"set up the probe"
	observedProcess := Processor activeProcess.
	myDelay := Delay forMilliseconds: millisecs.
	time0 := Time millisecondClockValue.
	gcStats := Smalltalk vm getParameters.
	Timer ifNotNil: [ self error: 'it seems a tally is already running' ].
	Timer := [
		[ true ] whileTrue: [
			| startTime |
			startTime := Time millisecondClockValue.
			myDelay wait.
			self
				tally: Processor preemptedProcess suspendedContext
				in: (observedProcess == Processor preemptedProcess ifTrue: [observedProcess] ifFalse: [nil])
				"tally can be > 1 if ran a long primitive"
				by: (Time millisecondClockValue - startTime) // millisecs].
		nil] newProcess.
	Timer priority: Processor timingPriority-1.
		"activate the probe and evaluate the block"
	Timer resume.
	^ aBlock ensure: [
		"cancel the probe and return the value"
		"Could have already been terminated. See #terminateTimerProcess"
		Timer ifNotNil: [
			Timer terminate.
			Timer := nil ].
		"Collect gc statistics"
		Smalltalk vm getParameters keysAndValuesDo: [ :idx :gcVal | 
			gcVal isNumber ifTrue: [ gcStats at: idx put: (gcVal - (gcStats at: idx))]].
		time := Time millisecondClockValue - time0]
]

{ #category : #initialization }
MessageTally >> spyEvery: millisecs onProcess: aProcess forMilliseconds: msecDuration [
	"Create a spy and spy on the given process at the specified rate."
	| myDelay time0 endTime observedProcess sem |
	(aProcess isKindOf: Process)
		ifFalse: [self error: 'spy needs a Process here'].
	self class: aProcess suspendedContext receiver class method: aProcess suspendedContext method.
	"set up the probe"
	observedProcess := aProcess.
	myDelay := Delay forMilliseconds: millisecs.
	time0 := Time millisecondClockValue.
	endTime := time0 + msecDuration.
	sem := Semaphore new.
	gcStats := Smalltalk vm getParameters.
	Timer ifNotNil: [ self error: 'it seems a tally is already running' ].
	Timer := [
			[
				| startTime |
				startTime := Time millisecondClockValue.
				myDelay wait.
				self
					tally: Processor preemptedProcess suspendedContext
					in: (observedProcess == Processor preemptedProcess ifTrue: [ observedProcess ] ifFalse: [nil])
					"tally can be > 1 if ran a long primitive"
					by: (Time millisecondClockValue - startTime) // millisecs.
				startTime < endTime
			] whileTrue.
			sem signal.
		] newProcess.
	Timer priority: Processor timingPriority-1.
		"activate the probe and evaluate the block"
	Timer resume.
	"activate the probe and wait for it to finish"
	sem wait.
	"Collect gc statistics"
	Smalltalk vm getParameters keysAndValuesDo: [ :idx :gcVal | 
		gcVal isNumber ifTrue: [ gcStats at: idx put: (gcVal - (gcStats at: idx)) ] ].
	time := Time millisecondClockValue - time0
]

{ #category : #accessing }
MessageTally >> tally [
	"Answer the receiver's number of tally."

	^tally
]

{ #category : #tallying }
MessageTally >> tally: context by: count [
	"Explicitly tally the specified context and its stack."
	| sender |
	
	"Add to this node if appropriate"
	context method == method ifTrue: [^self bumpBy: count].
	
	"No sender? Add new branch to the tree."
	(sender :=  context sender) ifNil: [
		^ (self bumpBy: count) tallyPath: context by: count].
	
	"Find the node for the sending context (or add it if necessary)"
	^ (self tally: sender by: count) tallyPath: context by: count
]

{ #category : #tallying }
MessageTally >> tally: context in: aProcess by: count [
	"Explicitly tally the specified context and its stack."
	| sender |

	"Add to this node if appropriate"
	context method == method ifTrue: [^self bumpBy: count].
	
	"No sender? Add new branch to the tree."
	(sender := context sender) ifNil: [
		^ (self bumpBy: count) tallyPath: context in: aProcess by: count].
	
	"Find the node for the sending context (or add it if necessary)"
	^ (self tally: sender in: aProcess by: count) tallyPath: context in: aProcess by: count
]

{ #category : #tallying }
MessageTally >> tallyPath: context by: count [
	| aMethod path |
	aMethod := context method.
	
	"Find the correct child (if there)"
	receivers do: [ :oldTally | 
		oldTally method == aMethod ifTrue: [path := oldTally]].
	
	"Add new child if needed"
	path ifNil: [
		path := self class new class: context receiver class method: aMethod.
		path reportOtherProcesses: reportOtherProcesses.
		receivers := receivers copyWith: path].
	
	^ path bumpBy: count
]

{ #category : #tallying }
MessageTally >> tallyPath: context in: aProcess by: count [
	| aMethod path |
	aMethod := context method.
	
	"Find the correct child (if there)"
	receivers do: [ :oldTally | 
		(oldTally method == aMethod and: [oldTally process == aProcess])
			ifTrue: [path := oldTally]].
		
	"Add new child if needed"
	path ifNil:[
		path := self class new class: context receiver class method: aMethod;
			process: aProcess;
			reportOtherProcesses: reportOtherProcesses;
			maxClassNameSize: maxClassNameSize;
			maxClassPlusSelectorSize: maxClassPlusSelectorSize;
			maxTabs: maxTabs.
		receivers := receivers copyWith: path].

	^ path bumpBy: count
]

{ #category : #accessing }
MessageTally >> theClass [
	"Return the class of the object receiver related to this tally"
	
	 ^ class
]

{ #category : #accessing }
MessageTally >> time [
	"Answer the receiver's run time."

	^time
]

{ #category : #printing }
MessageTally >> treePrintOn: aStream tabs: tabs thisTab: myTab total: total totalTime: totalTime tallyExact: isExact orThreshold: threshold [ 
	| sons sonTab |
	tabs do: [:tab | aStream nextPutAll: tab].
	tabs size > 0 
		ifTrue: 
			[self 
				printOn: aStream
				total: total
				totalTime: totalTime
				tallyExact: isExact].
	sons := isExact ifTrue: [receivers] ifFalse: [self sonsOver: threshold].
	sons isEmpty 
		ifFalse: 
			[tabs addLast: myTab.
			sons := sons asSortedCollection.
			1 to: sons size do: 
					[:i | 
					sonTab := i < sons size ifTrue: ['  |'] ifFalse: ['  '].
					(sons at: i) 
						treePrintOn: aStream
						tabs: (tabs size < self maxTabs 
								ifTrue: [tabs]
								ifFalse: [(tabs select: [:x | x = '[']) copyWith: '['])
						thisTab: sonTab
						total: total
						totalTime: totalTime
						tallyExact: isExact
						orThreshold: threshold].
			tabs removeLast]
]
