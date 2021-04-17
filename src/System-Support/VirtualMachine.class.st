"
I am exposing a various attributes of smalltalk virtual machine.


The direct use of this class is not recommended. 

All attributes are normally should be accessed via

Smalltalk vm someAttribute

instead of 

VirtualMachine someAttribute


"
Class {
	#name : #VirtualMachine,
	#superclass : #Object,
	#classVars : [
		'LastStats',
		'WordSize'
	],
	#category : #'System-Support-VM'
}

{ #category : #gc }
VirtualMachine >> allocationsBetweenGC [
	"allocations between GCs (read-write)"
	^ self parameterAt: 5
]

{ #category : #gc }
VirtualMachine >> allocationsBetweenGC: anInteger [
	"allocations between GCs (read-write)"
	^ self parameterAt: 5 put: anInteger
]

{ #category : #accessing }
VirtualMachine >> buildDate [			
	"Return a String reflecting the build date of the VM"
	"Smalltalk buildDate"

	^self getSystemAttribute: 1006
]

{ #category : #attributes }
VirtualMachine >> cogitClass [
	"Return the jit class that is currently executing the system (Cog VM only)"
	^self getSystemAttribute: 1008
]

{ #category : #accessing }
VirtualMachine >> command [
	"return a bash-like lauch command for the vm including all arguments up to the image name "
	^ String streamContents: [ :s|
		s nextPutAll: (self optionAt: 0).
		Smalltalk commandLine options 
			do: [ :argument|
				(argument endsWith: '.image')
					ifTrue: [ ^ s contents ].
				
				s space; nextPutAll: argument]]
]

{ #category : #statistics }
VirtualMachine >> compiledBlocksCount [

	^ self parameterAt: 77

]

{ #category : #statistics }
VirtualMachine >> compiledMethodsCount [

	^ self parameterAt: 75

]

{ #category : #accessing }
VirtualMachine >> directory [
	
	^ self primVmPath asByteArray utf8Decoded
]

{ #category : #modules }
VirtualMachine >> disableModuleLoading [
	"Primitive. Disable a new module loading mechanism for the rest of current session.
	This operation is not reversable.
	Any subsequent attempts to load either external or internal module(s) will fail"

	<primitive: 'primitiveDisableModuleLoading' module: ''>
]

{ #category : #accessing }
VirtualMachine >> documentPath [
	"Answer the absolute path of the document passed to the vm or nil if none."
	"Smalltalk commandLine documentPath"
	
	^self getSystemAttribute: 2
]

{ #category : #gc }
VirtualMachine >> edenSpaceSize [
	"for spur, size of eden, in bytes"
		
	^ self parameterAt: 44

]

{ #category : #attributes }
VirtualMachine >> extraVMMemory [
	"Answer the current setting of the 'extraVMMemory' VM parameter. See the comment in extraVMMemory: for details."

	^ self parameterAt: 23

]

{ #category : #attributes }
VirtualMachine >> extraVMMemory: extraBytesToReserve [
	"Request that the given amount of extra memory be reserved for use by the virtual machine to leave extra C heap space available for things like plugins, network and file buffers, and so on. This request is stored when the image is saved and honored when the image is next started up. Answer the previous value of this parameter."

	extraBytesToReserve < 0
		ifTrue: [self error: 'VM memory reservation must be non-negative'].
	^ self parameterAt: 23 put: extraBytesToReserve

]

{ #category : #accessing }
VirtualMachine >> fileName [
	^ self fullPath
]

{ #category : #attributes }
VirtualMachine >> flagInterpretedMethods: aBoolean [
	"The Cog VM can be instructed to set the flag bit of CompiledMethods that it executes but will only interpret.  This can be used e.g. to profile startup. See CompiledMethod>>#flag & CompiledMethod>>#clearFlag. This flag persists across snapshots, stored in the image header."
	
	self parameterAt: 48 put: ((self parameterAt: 48) bitClear: 2) + (aBoolean ifTrue: [2] ifFalse: [0])
]

{ #category : #accessing }
VirtualMachine >> for32bit: aBlockFor32bit for64bit: aBlockFor64bit [

	"evaluates a block or returns a provided value depending on bitness of the current VM"

	self is32bit ifTrue: [ ^ aBlockFor32bit value ].
	self is64bit ifTrue: [ ^ aBlockFor64bit value ].

	self error: 'Unknown VM bitness'
]

{ #category : #modules }
VirtualMachine >> forgetModule: aString [
	"Primitive. If the module named aString is loaded, unloaded. If not, and it is marked an unloadable, unmark it so the VM will try to load it again next time. See comment for #unloadModule:."
	<primitive: 571>
	^self primitiveFailed
]

{ #category : #gc }
VirtualMachine >> freeOldSpaceSize [
	"for spur, total size of free old space, otherwise nil"
		
	^ self parameterAt: 54

]

{ #category : #gc }
VirtualMachine >> freeSize [
	"Return the amount of free memory of the heap in bytes."
		
	^ self freeOldSpaceSize + self edenSpaceSize - self youngSpaceSize
]

{ #category : #statistics }
VirtualMachine >> fullGCCount [
	"Answer the total number of full GCs since startup (read-only)."

	^ self parameterAt: 7

]

{ #category : #accessing }
VirtualMachine >> fullPath [
	"Return the full vm path as a string"
	"Ex: '/Applications/.../Contents/MacOS/vm '"
	"SmalltalkImage current vm fullPath"

	^self getSystemAttribute: 0
]

{ #category : #gc }
VirtualMachine >> gcBiasToGrowLimit: arg [
	"Tell the VM the grow limit if the GC logic has bias to grow."
	
	<primitive: 'primitiveSetGCBiasToGrowGCLimit'>
	^self primitiveFailed
]

{ #category : #parameters }
VirtualMachine >> getParameters [	
	"Answer an Array containing the current values of the VM's internal
	parameter/metric registers.  Each value is stored in the array at the
	index corresponding to its VM register.  (See #vmParameterAt: and
	#vmParameterAt:put:.)"
	"Smalltalk vm getParameters"
	
	<primitive: 254>
	self primitiveFailed
]

{ #category : #attributes }
VirtualMachine >> getSystemAttribute: attributeID [ 
	"Optional. Answer the string for the system attribute with the given 
	integer ID. Answer nil if the given attribute is not defined on this 
	platform. On platforms that support invoking programs from command 
	lines (e.g., Unix), this mechanism can be used to pass command line 
	arguments to programs written in Pharo.

	By convention, the first command line argument that is not a VM
	configuration option is considered a 'document' to be filed in. Such a
	document can add methods and classes, can contain a serialized object,
	can include code to be executed, or any combination of these.

	Currently defined attributes include: 
	-1000   1000th command line argument that specify VM options
   	...
	-1              first command line argument that specify VM options
      0               the full path name for currently executing VM
                       (or, on some platforms, just the path name of the VM's directory)
       1               full path name of this image (better use primImageName instead)
       2               a Pharo document to open, if any
       3               first command line argument for Pharo programs
       ...
       1000    1000th command line argument for Pharo programs
       1001    this platform's operating system 'Mac OS', 'Win32', 'unix', ...
       1002    operating system version
       1003    this platform's processor type
       1004    vm version
       1005    window system name
       1006    vm build id
       1007    Interpreter class (Cog VM only)
       1008    Cogit class (Cog VM only)
       1201    max filename length (Mac OS only)
       1202    file last error (Mac OS only)
       10001   hardware details (Win32 only)
       10002   operating system details (Win32 only)
       10003   graphics hardware details (Win32 only)"

	<primitive: 149>
	^ nil
]

{ #category : #testing }
VirtualMachine >> hasSmallFloats [
	"SmallFloats are available in 64 bits machines"
	^ self wordSize = 8
]

{ #category : #accessing }
VirtualMachine >> headlessOption [
	"Return the default name for the headless option for this VM"
	^ self optionDash, (Smalltalk os isUnix
		ifTrue: [ 'vm-display-null' ]
		ifFalse: [ 'headless' ])
]

{ #category : #accessing }
VirtualMachine >> imageFile [
	"Image file "
	^ Smalltalk image imageFile
]

{ #category : #accessing }
VirtualMachine >> imagePath [
	"Image file path
	Ex:  '/Users/foo/Pharo/Pharo-1.1.1-dev10.09.1.image'"
	^ Smalltalk image imagePath
]

{ #category : #parameters }
VirtualMachine >> imageVersionNumber [
	"Image version number (6505 means the Squeak V3 format with BlockClosure support (but _without_ BlockContext support)"
		
	^ self parameterAt: 41
]

{ #category : #gc }
VirtualMachine >> incrementalGCCount [
	"Answer the total number of incremental GCs since startup (read-only)."

	^ self parameterAt: 9

]

{ #category : #accessing }
VirtualMachine >> interpreterClass [
	"Return the interpreter class that is currently executing the system (Cog VM only)"
	^ self getSystemAttribute: 1007
]

{ #category : #accessing }
VirtualMachine >> interpreterSourceDate [
	"Return the date of changes given by `self interpreterSourceVersion`"
	| dateString parts | 
	
	dateString := (self interpreterSourceVersion splitOn: 'Date: ') second.
	
	dateString first isDigit
		ifTrue: [ 
			"most probably the date is in ISO 8601 Format" 
			^ dateString asDateAndTime ].
		
	"Otherwise assume the old format: DDD MMM DD HH:MM:SS YYYY +TTTT ..."
	parts := dateString substrings first: 6.
	"create a more reasonable string.."
	dateString := String streamContents: [ :s |
		s 
			nextPutAll: (parts at: 5 ); space; "year"
			nextPutAll: (parts at: 2 ); space; "month name"
			nextPutAll: (parts at: 3 ); space; "day of month"
			nextPutAll: (parts at: 4 ); space; "time"
			nextPutAll: (parts last); space    "timezone"].
	^ dateString asDateAndTime 
]

{ #category : #accessing }
VirtualMachine >> interpreterSourceVersion [
	"The use of this primitive not recommended. Not all VMs providing that"

	"Answer a string corresponding to the version of the interpreter source.
	This represents the version level of the Smalltalk source code (interpreter
	and various plugins) that is translated to C by a CCodeGenerator, as distinct
	from the external platform source code, typically written in C and managed
	separately for each platform. An optional primitive is invoked that may not
	be available on all virtual machines."

	"Smalltalk vm interpreterSourceVersion"

	<primitive: 'primitiveInterpreterSourceVersion'>
	^ self getSystemAttribute: 1009
]

{ #category : #testing }
VirtualMachine >> is32bit [
	"Answers if this VM is a 32bit version"
	^ self wordSize = 4
]

{ #category : #testing }
VirtualMachine >> is64bit [
	"Answers if this VM is a 64bit version"
	^ self wordSize = 8
]

{ #category : #testing }
VirtualMachine >> isAIOInterrupt [
	"Answer true, if the vm is capable of being interupted until there is an AIO event. 
	 (This means we are going idle until we have something real to process)"

	^ (self getSystemAttribute: 1010) = 'AIO'
]

{ #category : #testing }
VirtualMachine >> isPharoVM [
	"Answers if this VM is a valid PharoVM (made with our sources)"
	| version |
	
	self flag: #pharoTodo. "We need a certain way of identify PharoVM, but in the mean time this ensures "
	version := self version.
	^ (version beginsWith: 'PharoVM')
		or: [ 
			(version includesSubstring: 'NBCoInterpreter')
				or: [
					(version includesSubstring: 'Commit: ') 
						and: [ 
							| pos |
							pos := (version findString: 'Commit: ') + 8.
							(version copyFrom: pos to: pos + 39) allSatisfy: [ :each | (($a to: $f), ($0 to: $9)) includes: each ] ] ] ]
]

{ #category : #testing }
VirtualMachine >> isRunningCog [
	"Returns true if we're running on a Cog VM (JIT or StackInterpreter)
	 (parameterAt: 42 is the number of stack pages)"

	^[(self parameterAt: 42) > 0] on: Error do:[:ex| ex return: false]
]

{ #category : #testing }
VirtualMachine >> isRunningCogit [
	"Returns true if we're running on the Cog JIT
	 (vmParameterAt: 46 is the size of the machine code zone)"

	^[(self parameterAt: 46) > 0] on: Error do:[:ex| ex return: false]
]

{ #category : #testing }
VirtualMachine >> isRunningInWorkerThread [
	"Answers whether the vm is running on worker thread ot not"

	^ (self getSystemAttribute: 1011) = 'WORKER_THREAD'
]

{ #category : #testing }
VirtualMachine >> isSpur [ 
	"this value is always true but is here for backward compatibility (non Spur images should return false)"
	^ true
]

{ #category : #modules }
VirtualMachine >> listBuiltinModule: index [
	"Return the name of the n-th builtin module.
	This list is not sorted!"
	<primitive: 572>
	^self primitiveFailed
]

{ #category : #modules }
VirtualMachine >> listBuiltinModules [
	"Smalltalk vm listBuiltinModules"

	"Return a list of all builtin modules (e.g., plugins). Builtin plugins are those that are 
	compiled with the VM directly, as opposed to plugins residing in an external shared library. 	
	The list will include all builtin plugins regardless of whether they are currently loaded 
	or not. Note that the list returned is not sorted!"

	| modules index tname |
	modules := Array new writeStream.
	index := 1.
	[ true ]
		whileTrue: [ 
			tname := self listBuiltinModule: index.
			tname ifNil: [ ^ modules contents ].
			modules nextPut: tname.
			index := index + 1 ]
]

{ #category : #modules }
VirtualMachine >> listLoadedModule: index [
	"Return the name of the n-th loaded module.
	This list is not sorted!"
	<primitive: 573>
	^self primitiveFailed
]

{ #category : #modules }
VirtualMachine >> listLoadedModules [
	"SmalltalkImage current listLoadedModules"
	"Return a list of all currently loaded modules (e.g., plugins). Loaded modules are those that currently in use (e.g., active). The list returned will contain all currently active modules regardless of whether they're builtin (that is compiled with the VM) or external (e.g., residing in some external shared library). Note that the returned list is not sorted!"
	| modules index tname |
	modules := Array new writeStream.
	index := 1.
	[true] whileTrue: [
		tname := self listLoadedModule: index.
		tname ifNil:[^modules contents].
		modules nextPut: tname.
		index := index + 1.
	].
]

{ #category : #attributes }
VirtualMachine >> maxExternalSemaphores [
	"The size of array in some VM's where external signals for
	semaphores in externalObjects are handled.
	Essentially, if a semaphore is registered in externalObjects outside
	its bounds, they will not be signalled."
	^ [self parameterAt: 49]
		on: PrimitiveFailed
		do: [:ex | ex return: nil]
]

{ #category : #attributes }
VirtualMachine >> maxExternalSemaphores: aSize [
	"This method should never be called as result of normal program
    execution. If it is however, fork off the growth to keep new
    Semaphores flowing for other users, but raise an error in this thread
    indicating that something needs to change to avoid potentially
    unhandled interrupts."

	self maxExternalSemaphores ifNil: [ ^ 0 ].
	
	[ self maxExternalSemaphoresSilently: aSize.
	SystemNotification signal: ('WARNING: Had to increase size of semaphore signal handling table due to many external objects concurrently in use', String cr,
		'You should increase this size at startup using #maxExternalSemaphoresSilently:', String cr,
		'Current table size: ' , self maxExternalSemaphores printString) ] forkAt: Processor userBackgroundPriority.
	
	self error: 'Not enough space for external objects, set a larger size at startup!'.
	^ self maxExternalSemaphores
]

{ #category : #attributes }
VirtualMachine >> maxExternalSemaphoresSilently: aSize [ 
	"Changes the size of array where external signals for semaphores in
	externalObjects are handled.. 
	The size can only grow, and will always be the next power of two
	larger than the parameter.
	
	The intended use is to set the table size to some adequate
	maximum as part of a non-resuming image startUp.
	
	Setting this at any time other than start-up can potentially result in
	lost signals during reallocation.
	i.e. Requests handled during copying og signals from old to new array
	won't be seen if they occur to indices already copied, before
	pointers to the new and old arrays are switched."
	self maxExternalSemaphores
		ifNil: [^ 0].
	"The vm-header field where the size is stored is a short, maximum
	64k entries. 
	Well, on most platforms anyways"
	(aSize < 0
			or: [aSize > 65535])
		ifTrue: [^ DomainError signalFrom: 0 to: 65535].
	^ self parameterAt: 49 put: aSize
]

{ #category : #accessing }
VirtualMachine >> maxFilenameLength [
	"Return the maximal filename length (only under MacOS) as a string
	 or nil for other platforms "
	"Smalltalk vm maxFilenameLength"
	^ (self getSystemAttribute: 1201) ifNotNil: [ :string | string asNumber ]
]

{ #category : #statistics }
VirtualMachine >> maximumPauseTimeDueToSegmentAllocation [

	^ self parameterAt: 74

]

{ #category : #gc }
VirtualMachine >> memoryEnd [
	"end of memory"
		
	^ self parameterAt: 3

]

{ #category : #gc }
VirtualMachine >> memorySize [
	"Return the memory size of the heap in bytes."
		
	^ self parameterAt: 3 "Readonly parameter for spur"
]

{ #category : #gc }
VirtualMachine >> oldSpace [
	"for spur, sizeof old-space (0-based, read-only)"
		

	^ self parameterAt: 1

]

{ #category : #gc }
VirtualMachine >> oldSpaceEnd [
	"end of old-space (0-based, read-only)"
		

	^ self parameterAt: 1

]

{ #category : #accessing }
VirtualMachine >> optionAt: i [
	"Answer the i-th option of the command line, or nil if not so many options."
	
	^self getSystemAttribute: i negated
]

{ #category : #accessing }
VirtualMachine >> optionDash [
	"VMs release in Mai 2013 use -- instead of - for VM command line options"
	^ (Smalltalk vm interpreterSourceDate > '2013-05-17' asDate)
		ifTrue: [ '--' ]
		ifFalse: [ '-' ]
]

{ #category : #accessing }
VirtualMachine >> options [
	"return an array with all the options passed to the VM (up to the image) "
	^ Array streamContents: [ :s|
		Smalltalk commandLine options 
			do: [ :argument|
				(argument endsWith: '.image')
					ifTrue: [ ^ s contents ].
				
				s nextPut: argument ]]
]

{ #category : #parameters }
VirtualMachine >> parameter46Documentation [

"
46      size of machine code zone, in bytes

To speed-up execution, the cog uses internally a JIT compiler which translates to machine code frequently used bytecoded method and run the machine code to execute them instead of using the interpreter. The machine code zone is an executable memory zone containing all the machine code versions of methods. 

The default size should be between 1Mb and 2Mb for standard applications. If memory is a constraint, it can be lowered down to 750kb, under that you should use the stack VM else the performance starts to drastically decrease.

This setting is useful to tune your application performance. For example, on compilation-intensive benchs, 750kb is the optimal machine code zone size. On large benchmarks, 2 Mb, maybe more, is better, but then one may see machine code garbage collection pauses. On small benchs all the methods fit into this zone so it doesn't really matter.

Growing the machine code zone:
- increase the number of methods that can be present there, hence decreasing machine code zone garbage collection frequency and method jit compilation.
- decrease the machine code zone to cpu instruction cache mapping
- slow down machine code zone garbage collection

To set the machine code zone you need to use another parameter (47 I think) and restart the VM+image.
"
]

{ #category : #parameters }
VirtualMachine >> parameterAt: parameterIndex [
	"parameterIndex is a positive integer corresponding to one of the VM's internal
	parameter/metric registers.  Answer with the current value of that register.
	Fail if parameterIndex has no corresponding register.

	VM parameters are numbered as follows:

		1	end (v3)/size(Spur) of old-space (0-based, read-only)
		2	end (v3)/size(Spur) of young/new-space (read-only)
		3	end (v3)/size(Spur) of heap (read-only)
		4	nil (was allocationCount (read-only))
		5	nil (was allocations between GCs (read-write)
		6	survivor count tenuring threshold (read-write)
		7	full GCs since startup (read-only)
		8	total milliseconds in full GCs since startup (read-only)
		9	incremental GCs (SqueakV3) or scavenges (Spur) since startup (read-only)
		10	total milliseconds in incremental GCs (SqueakV3) or scavenges (Spur) since startup (read-only)
		11	tenures of surving objects since startup or reset (read-write)
		12-20 were specific to ikp's JITTER VM, now 12-15 are open for use
		16	total microseconds at idle since start-up (if non-zero)
		17	fraction of the code zone to use (Sista only; used to control code zone use to preserve sendAndBranchData on counter tripped callback)
		18	total milliseconds in compaction phase of full GC since start-up (Spur only)
		19	scavenge threshold, the effective size of eden.  When eden fills to the threshold a scavenge is scheduled. Newer Spur VMs only.
		20	utc microseconds at VM start-up (actually at time initialization, which precedes image load).
		21	root/remembered table size (occupancy) (read-only)
		22	root table overflows since startup (read-only)
		23	bytes of extra memory to reserve for VM buffers, plugins, etc (stored in image file header).
		24	memory threshold above which shrinking object memory (rw)
		25	memory headroom when growing object memory (rw)
		26	interruptChecksEveryNms - force an ioProcessEvents every N milliseconds (rw)
		27	number of times mark loop iterated for current IGC/FGC (read-only) includes ALL marking
		28	number of times sweep loop iterated for current IGC/FGC (read-only)
		29	number of times make forward loop iterated for current IGC/FGC (read-only)
		30	number of times compact move loop iterated for current IGC/FGC (read-only)
		31	number of grow memory requests (read-only)
		32	number of shrink memory requests (read-only)
		33	number of root table entries used for current IGC/FGC (read-only)
		34	Spur: bytes allocated in total since start-up or reset (read-write) (Used to be number of allocations done before current IGC/FGC (read-only))
		35	number of survivor objects after current IGC/FGC (read-only)
		36	millisecond clock when current IGC/FGC completed (read-only)
		37	number of marked objects for Roots of the world, not including Root Table entries for current IGC/FGC (read-only)
		38	milliseconds taken by current IGC (read-only)
		39	Number of finalization signals for Weak Objects pending when current IGC/FGC completed (read-only)
		40	BytesPerOop for this image
		41	imageFormatVersion for the VM
		42	number of stack pages in use
		43	desired number of stack pages (stored in image file header, max 65535)
		44	size of eden, in bytes
		45	desired size of eden, in bytes (stored in image file header)
		46	machine code zone size, in bytes (Cog only; otherwise nil)
		47	desired machine code zone size (stored in image file header; Cog only; otherwise nil)
		48	various header flags.  See getCogVMFlags.
		49	max size the image promises to grow the external semaphore table to (0 sets to default, which is 256 as of writing)
		50-51 nil; reserved for VM parameters that persist in the image (such as eden above)
		52	root/remembered table capacity
		53	number of segments (Spur only; otherwise nil)
		54	total size of free old space (Spur only, otherwise nil)
		55	ratio of growth and image size at or above which a GC will be performed post scavenge
		56	number of process switches since startup (read-only)
		57	number of ioProcessEvents calls since startup (read-only)
		58	number of ForceInterruptCheck calls since startup (read-only)
		59	number of check event calls since startup (read-only)
		60	number of stack page overflows since startup (read-only)
		61	number of stack page divorces since startup (read-only)
		62	compiled code compactions since startup (read-only; Cog only; otherwise nil)
		63	total milliseconds in compiled code compactions since startup (read-only; Cog only; otherwise nil)
		64	the number of methods that currently have jitted machine-code
		65	whether the VM supports a certain feature, MULTIPLE_BYTECODE_SETS is bit 0, IMMUTABILITY is bit 1
		66	the byte size of a stack page
		67	the max allowed size of old space (Spur only; nil otherwise; 0 implies no limit except that of the underlying platform)
		68	the average number of live stack pages when scanned by GC (at scavenge/gc/become et al) (read-write)
		69	the maximum number of live stack pages when scanned by GC (at scavenge/gc/become et al) (read-write)
		70	the vmProxyMajorVersion (the interpreterProxy VM_MAJOR_VERSION)
		71	the vmProxyMinorVersion (the interpreterProxy VM_MINOR_VERSION)
		72 total milliseconds in full GCs Mark phase since startup (read-only)
		73 total milliseconds in full GCs Sweep phase since startup (read-only, can be 0 depending on compactors)
		74 maximum pause time due to segment allocation
		75 number of JIT compiled methods since startup (read-only)
		76 total milliseconds spent on JIT compiled methods since startup (read-only)
		77 number of JIT compiled block since startup (read-only)
		78 total milliseconds spent on JIT compiled block since startup (read-only)"

	<primitive: 254>
	self primitiveFailed
]

{ #category : #parameters }
VirtualMachine >> parameterAt: parameterIndex put: newValue [
	"parameterIndex is a positive integer corresponding to one of the VM's internal
	parameter/metric registers.  Store newValue (a positive integer) into that
	register and answer with the previous value that was stored there.
	Fail if newValue is out of range, if parameterIndex has no corresponding
	register, or if the corresponding register is read-only."

	<primitive: 254>
	self primitiveFailed
]

{ #category : #accessing }
VirtualMachine >> path [
	"Answer the path for the directory containing the Smalltalk virtual machine. Return the 	empty string if this primitive is not implemented."

	"Smalltalk vm path"
	self
		deprecated: 'Use #directory instead'
		on: '12 November 2018'
		in: #Pharo7
		transformWith: '`@receiver path' 
						-> '`@receiver directory'.
	^ self primVmPath
]

{ #category : #accessing }
VirtualMachine >> platformSourceVersion [
	"The use of this primitive not recommended. Not all VMs providing that"


	"Answer a string corresponding to the version of the external platform source
	code, typically written in C and managed separately for each platform. This
	invokes an optional primitive that may not be available on all virtual machines."

	"Smalltalk vm platformSourceVersion"

	<primitive: 'primitivePlatformSourceVersion'>
	self notify: 'This virtual machine does not support the optional primitive #primitivePlatformSourceVersion'.
	^''
]

{ #category : #primitives }
VirtualMachine >> primVmPath [
	"Answer the path for the directory containing the Smalltalk virtual machine. Return the empty string if this primitive is not implemented."
	"Smalltalk vmPath"

	<primitive: 142>
	^ ''
]

{ #category : #attributes }
VirtualMachine >> processHasThreadIdInstVar: aBoolean [
	"The threaded VM needs to know if the 4th inst var of Process
	 is threadId which it uses to control process-to-thread binding.
	 This flag persists across snapshots, stored in the image header."
	aBoolean ifTrue: [self assert: (Process instVarNames at: 4) ='threadId'].
	self parameterAt: 48 put: ((self parameterAt: 48) bitClear: 1) + (aBoolean asBit)
	

]

{ #category : #testing }
VirtualMachine >> processPreemptionYields [
	"Answer whether the VM causes a process to yield on process preemption, i.e. to put a preempted process at the back of its run queue.  If the parameter is unavailable (non-Cog VMs) or bit 2 (4) is 0 then preemption yields."

	^(([self parameterAt: 48]
			on: Error
			do: [:ex| ^true]) allMask: 2r100) not
]

{ #category : #attributes }
VirtualMachine >> processPreemptionYields: aBoolean [
	"The Cog VM can be instructed not to yield on process preemption, i.e. not to put a preempted process at the back of its run queue.  By default preempting a process causes it to yield (Blue Book semantics) which can have unfortunate effects. This flag persists across snapshots, stored in the image header."
	
	self parameterAt: 48 put: ((self parameterAt: 48) bitClear: 4) + (aBoolean ifTrue: [0] ifFalse: [2r100])
]

{ #category : #gc }
VirtualMachine >> setGCBiasToGrowGCLimit: aNumber [
	"Primitive. Indicate that the bias to grow logic should do a GC after aNumber Bytes"
	<primitive: 'primitiveSetGCBiasToGrowGCLimit'>
	^self primitiveFailed
"Example:
	Smalltalk vm setGCBiasToGrowGCLimit: 16*1024*1024.
"
]

{ #category : #gc }
VirtualMachine >> setGCParameters [
	"Adjust the VM's default GC parameters to avoid too much tenuring.
	 Maybe this should be left to the VM?"

	| proportion edenSize survivorSize averageObjectSize numObjects |
	proportion := 0.9. "tenure when 90% of pastSpace is full"
	edenSize := self edenSpaceSize.
	survivorSize := edenSize / 5.0. "David's paper uses 140Kb eden + 2 x 28kb survivor spaces; Spur uses the same ratios :-)"
	averageObjectSize := 8 * self wordSize. "a good approximation"
	numObjects := (proportion * survivorSize / averageObjectSize) rounded.
	self tenuringThreshold: numObjects  "tenure when more than this many objects survive the GC"
]

{ #category : #gc }
VirtualMachine >> setGCSemaphore: semaIndex [
	"Primitive. Indicate the GC semaphore index to be signaled on GC occurance."
	<primitive: 'primitiveSetGCSemaphore'>
	^self primitiveFailed
"Example:

	| index sema process |
	sema := Semaphore new.
	index := Smalltalk registerExternalObject: sema.
	Smalltalk setGCSemaphore: index.
	process := [
		[[true] whileTrue:[
			sema wait.
			Smalltalk beep.
		]] ensure:[
			Smalltalk setGCSemaphore: 0.
			Smalltalk unregisterExternalObject: sema.
		].
	] fork.
	process inspect.
"
]

{ #category : #statistics }
VirtualMachine >> statisticsReport [
	"Workspace openContents: (Smalltalk vm statisticsReport) label: 'VM Statistics'"

	| oldSpaceSize youngSpaceSize memorySize freeSize fullGCs fullGCTime incrGCs incrGCTime tenureCount upTime upTime2 fullGCs2 fullGCTime2 incrGCs2 incrGCTime2 tenureCount2 str |
	oldSpaceSize		:= self oldSpace.
	youngSpaceSize		:= self youngSpaceSize.
	tenureCount			:= self tenureCount.
	memorySize			:= self memorySize.
	freeSize				:= self freeSize.
	fullGCs				:= self fullGCCount.
	fullGCTime			:= self totalFullGCTime.
	incrGCs				:= self incrementalGCCount.
	incrGCTime			:= self totalIncrementalGCTime.
 
	upTime := Time millisecondClockValue.
	str := (String new: 1000) writeStream.
	str	<< 'uptime			';
		print: (upTime / 1000 / 60 // 60); nextPut: $h;
		print: (upTime / 1000 / 60 \\ 60) asInteger; nextPut: $m;
		print: (upTime / 1000 \\ 60) asInteger; nextPut: $s; cr.

	str	<< 'memory			'.
	memorySize printWithCommasOn: str.
	str << ' bytes'; cr.
	str	<<	'	old			'.
	oldSpaceSize printWithCommasOn: str.
	str << ' bytes (';
		print: ((oldSpaceSize / memorySize * 100) roundTo: 0.1); << '%)'; cr.
	str	<< '	young		'.
	(youngSpaceSize) printWithCommasOn: str.
	str << ' bytes (';
		print: ((youngSpaceSize / memorySize * 100) roundTo: 0.1); << '%)'; cr.
	str	<< '	used		'.
	youngSpaceSize + oldSpaceSize - freeSize printWithCommasOn: str.
	str << ' bytes (';
		print: ((youngSpaceSize + oldSpaceSize - freeSize / memorySize * 100) roundTo: 0.1); << '%)'; cr.
	str	<< '	free		'.
	freeSize printWithCommasOn: str.
	str << ' bytes (';
		print: ((freeSize / memorySize * 100) roundTo: 0.1); << '%)'; cr.

	str	<< 'GCs				'.
	(fullGCs + incrGCs) printWithCommasOn: str.
	fullGCs + incrGCs > 0 ifTrue: [
		str
			<< ' ('; 
			print: ((upTime / (fullGCs + incrGCs)) roundTo: 1); 
			<< 'ms between GCs)'
	].
	str cr.
	str	<< '	full			';
		print: fullGCs; << ' totalling '.
	fullGCTime printWithCommasOn: str.
	str << 'ms (';
		print: ((fullGCTime / upTime * 100) roundTo: 0.1);
		<< '% uptime)'.
	fullGCs = 0 ifFalse:
		[str	<< ', avg '; print: ((fullGCTime / fullGCs) roundTo: 0.1); << 'ms'].
	str	cr.
	str	<< '	incr		';
		print: incrGCs; << ' totalling '.
	incrGCTime printWithCommasOn: str.
	str << 'ms (';
		print: ((incrGCTime / upTime * 100) roundTo: 0.1);
		<< '% uptime), avg '; print: ((incrGCTime / incrGCs) roundTo: 0.1); << 'ms'; cr.
	str	<< '	tenures		'.
	tenureCount printWithCommasOn: str.
	tenureCount = 0 ifFalse:
		[str << ' (avg '; print: (incrGCs / tenureCount) asInteger; << ' GCs/tenure)'].
	str	cr.

LastStats ifNil: [LastStats := Array new: 6]
ifNotNil: [
	upTime2 := upTime - (LastStats at: 1).
	fullGCs2 := fullGCs - (LastStats at: 2).
	fullGCTime2 := fullGCTime - (LastStats at: 3).
	incrGCs2 := incrGCs - (LastStats at: 4).
	incrGCTime2 := incrGCTime - (LastStats at: 5).
	tenureCount2 := tenureCount - (LastStats at: 6).

	str	<<  'Since last view	'.
	(fullGCs2 + incrGCs2) printWithCommasOn: str.
	fullGCs2 + incrGCs2 > 0 ifTrue: [
		str
			<< ' ('; 
			print: ((upTime2 / (fullGCs2 + incrGCs2)) roundTo: 1); 
			<< 'ms between GCs)'.
	].
	str cr.
	str	<< '	uptime		'; print: ((upTime2 / 1000.0) roundTo: 0.1); << 's'; cr.
	str	<< '	full			';
		print: fullGCs2; << ' totalling '.
	fullGCTime2 printWithCommasOn: str.
	str << 'ms (';
		print: ((fullGCTime2 / upTime2 * 100) roundTo: 0.1);
		<< '% uptime)'.
	fullGCs2 = 0 ifFalse:
		[str	<< ', avg '; print: ((fullGCTime2 / fullGCs2) roundTo: 0.1); << 'ms'].
	str	cr.
	str	<< '	incr		';
		print: incrGCs2; << ' totalling '.
	incrGCTime2 printWithCommasOn: str.
	str << 'ms (';
		print: ((incrGCTime2 / upTime2 * 100) roundTo: 0.1);
		<< '% uptime), avg '.
	incrGCs2 > 0 ifTrue: [
		 str print: ((incrGCTime2 / incrGCs2) roundTo: 0.1); << 'ms'
	].
	str cr.
	str	<< '	tenures		'.
	tenureCount2 printWithCommasOn: str.
	tenureCount2 = 0 ifFalse:
		[str << ' (avg '; print: (incrGCs2 / tenureCount2) asInteger; << ' GCs/tenure)'].
	str	cr.
].
	LastStats at: 1 put: upTime.
	LastStats at: 2 put: fullGCs.
	LastStats at: 3 put: fullGCTime.
	LastStats at: 4 put: incrGCs.
	LastStats at: 5 put: incrGCTime.
	LastStats at: 6 put: tenureCount.

	^ str contents

]

{ #category : #testing }
VirtualMachine >> supportsMultipleBytecodeSets [
	"Answer whether the VM supports multiple bytecodeSets."

	^(self parameterAt: 65)
		ifNil: [false]
		ifNotNil:
			[:param| "In older VMs this is a boolean reflecting MULTIPLE_BYTECODE_SETS"
			 param isInteger "In newer VMs it is a set of integer flags, bit 0 of which is MULTIPLE_BYTECODE_SETS"
				ifTrue: [param anyMask: 1]
				ifFalse: [param]]
]

{ #category : #testing }
VirtualMachine >> supportsWriteBarrier [
	"Answer whether the VM observes the per-object read-only flag and consequently
	 aborts writes to inst vars of, and fails primitives that attempt to write, to read-only objects."

	^(self parameterAt: 65)
		ifNil: [false]
		ifNotNil:
			[:param| "In older VMs this is a boolean reflecting MULTIPLE_BYTECODE_SETS"
			 param isInteger "In newer VMs it is a set of integer flags, bit 1 of which is IMMUTABILITY"
				ifTrue: [param anyMask: 2]
				ifFalse: [false]]
]

{ #category : #statistics }
VirtualMachine >> tenureCount [
	"tenures of surving objects since startup (read-only)."

	^ self parameterAt: 11

]

{ #category : #gc }
VirtualMachine >> tenuringThreshold [
	"survivor count tenuring threshold (read-write)"
	^ self parameterAt: 6
]

{ #category : #gc }
VirtualMachine >> tenuringThreshold: anInteger [
	"survivor count tenuring threshold (read-write).
	tenure when more than this many objects survive the GC"
	
	^ self parameterAt: 6 put: anInteger
]

{ #category : #statistics }
VirtualMachine >> totalFullGCTime [
	"Answer the total time in milliseconds spent in full GCs since startup (read-only)."

	^ self parameterAt: 8

]

{ #category : #statistics }
VirtualMachine >> totalGCMarkPhaseTime [

	^ self parameterAt: 72

]

{ #category : #statistics }
VirtualMachine >> totalGCSweepPhaseTime [

	^ self parameterAt: 73

]

{ #category : #statistics }
VirtualMachine >> totalGCTime [
	^ self totalFullGCTime + self totalIncrementalGCTime
]

{ #category : #statistics }
VirtualMachine >> totalIncrementalGCTime [
	"Answer the total time in milliseconds spent in incremental GCs since startup (read-only)."

	^ self parameterAt: 10

]

{ #category : #statistics }
VirtualMachine >> totalJITCompileBlocksTime [

	^ self parameterAt: 78

]

{ #category : #statistics }
VirtualMachine >> totalJITCompileMethodsTime [

	^ self parameterAt: 76

]

{ #category : #statistics }
VirtualMachine >> totalJITCompileTime [
	
	^ self totalJITCompileMethodsTime + self totalJITCompileBlocksTime
]

{ #category : #modules }
VirtualMachine >> unloadModule: aString [
	"Primitive. Unload the given module.
	This primitive is intended for development only since some
	platform do not implement unloading of DLL's accordingly.
	Also, the mechanism for unloading may not be supported
	on all platforms."
	<primitive: 571>
	^self primitiveFailed
]

{ #category : #accessing }
VirtualMachine >> version [
	"Return a string of attributes representing the current VM"
	"
	Smalltalk vm version
	"
	^ String streamContents: [ :s |
			s nextPutAll: self interpreterClass; cr.
			self isRunningCogit ifTrue: [ s nextPutAll: self cogitClass; cr ].
			s nextPutAll: self interpreterSourceVersion; cr ].
]

{ #category : #accessing }
VirtualMachine >> versionLabel [
	"The use of this primitive not recommended. Not all VMs providing that"

	"Answer a string corresponding to the version of virtual machine. This
	represents the version level of the Smalltalk source code (interpreter
	and various plugins) that is translated to C by a CCodeGenerator,  in
	addition to the external platform source code, typically written in C and
	managed separately for each platform.
	
	This invokes an optional primitive that may not be available on all virtual
	machines. See also vmVersion, which answers a string identifying the image
	from which virtual machine sources were generated."

	"Smalltalk vm versionLabel"

	<primitive: 'primitiveVMVersion'>
	self notify: 'This virtual machine does not support the optional primitive #primitiveVMVersion'.
	^''
]

{ #category : #accessing }
VirtualMachine >> vmDirectory [

	self
		deprecated: 'Use #directory instead'
		on: '12 November 2018'
		in: #Pharo7
		transformWith: '`@receiver vmDirectory' 
						-> '`@receiver directory'.

	^ self directory
]

{ #category : #accessing }
VirtualMachine >> vmFileName [
	^ self fileName
]

{ #category : #gc }
VirtualMachine >> voidCogVMState [
	"Void any internal caches the VM maintains other than the method lookup caches.
	 These comprise
		- the stack zone, where method activations are stored, and
		- the machine code zone, where the machine code form of CompiledMethods is held."
	<primitive: 214>
	^self primitiveFailed
]

{ #category : #attributes }
VirtualMachine >> wordSize [
	^ WordSize ifNil: [WordSize := [self parameterAt: 40] on: Error do: [4]]
]

{ #category : #gc }
VirtualMachine >> youngSpaceEnd [
	"end of young-space"
		
	^ self parameterAt: 2

]

{ #category : #gc }
VirtualMachine >> youngSpaceSize [
	"for spur, size of young/new-space (read-only)"
		
	^ self parameterAt: 2

]
