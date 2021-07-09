Extension { #name : #Context }

{ #category : #'*Debugging-Core' }
Context >> callChainAnySatisfy: aBlock [

	(aBlock value: self) ifTrue: [ ^ true ].
	self sender ifNil: [ ^ false ].
	^ self sender callChainAnySatisfy: aBlock.
]

{ #category : #'*Debugging-Core' }
Context >> callPrimitive: primNumber [
	| res |
	res := receiver tryPrimitive: primNumber withArgs: self arguments.
	primNumber >= (1 << 15) ifTrue: [ "inlined primitive, cannot fail" ^ self push: res ].  
	"regular primitive. Always at the beginning of methods."
	(self isFailToken: res) ifTrue: [ "keeps interpreting the method" ^ self ].
	self push: res.
	self methodReturnTop
]

{ #category : #'*Debugging-Core' }
Context >> lookupTempVar: aSymbol [
	| var |
	var := self lookupVar: aSymbol.
	var isLocalVariable ifFalse: [ ^self error: var name, ' is not a temp but, ', var class name].
	^var
]

{ #category : #'*Debugging-Core' }
Context >> lookupVar: aSymbol [
	^ self astScope lookupVar: aSymbol
]

{ #category : #'*Debugging-Core' }
Context >> lookupVar: aSymbol declare: aBoolean [
	^ self astScope lookupVar: aSymbol declare: aBoolean
]

{ #category : #'*Debugging-Core' }
Context >> methodReturnConstant: value [
	"Simulate the action of a 'return constant' bytecode whose value is the
	 argument, value. This corresponds to a source expression like '^0'."

	^self return: value from: self methodReturnContext
]

{ #category : #'*Debugging-Core' }
Context >> namedTempAt: index [

	"Answer the value of the temp at index in the receiver's sequence of tempNames."

	"NOTE: this list of temp names is completely virtual! It omits temp vectors but 
	adds every variable that could be acccessed from a source perspective but might not be.
	Do *not* use this!"

	self
		deprecated: 'Please access temps by name using #tempNamed:'
		transformWith: '`@rec namedTempAt: `@arg' -> '`@rec tempNamed: (`@rec tempNames at: `@arg)'.
	
	^ self tempNamed: (self tempNames at: index)
]

{ #category : #'*Debugging-Core' }
Context >> namedTempAt: index put: aValue [
	"Set the value of the temp at index in the receiver's sequence of tempNames"
	"NOTE: this list of temp names is completely virtual! It omits temp vectors but 
	adds every variable that could be acccessed from a source perspective but might not be"
	"Do *not* use this!"
	self
		deprecated: 'Please access temps by name using #tempNamed:put:'
		transformWith: '`@rec namedTempAt: `@arg1 put: `@arg2' ->
		               '`@rec tempNamed: (`@rec tempNames at: `@arg1) put: `@arg2'.
	
	self tempNamed: (self tempNames at: index) put: aValue
]

{ #category : #'*Debugging-Core' }
Context >> pcRangeContextIsActive: contextIsActive [
 	"return the debug highlight for aPC"		 
	| thePC |

  	"make sure we have some usable value (can happen for contexts in the ProcessBrowser"		
 	thePC := self isDead ifTrue: [self endPC] ifFalse: [pc].

  	"When on the top of the stack the pc is pointing to right instruction, but deeper in the stack		
 	the pc was already advanced one bytecode, so we need to go back this one bytecode, which		
 	can consist of multiple bytes. But on IR, we record the *last* bytecode offset as the offset of		
 	the IR instruction, which means we can just go back one"		
 	thePC := contextIsActive ifTrue: [thePC] ifFalse: [thePC - 1].		

  	^self method rangeForPC: thePC
]

{ #category : #'*Debugging-Core' }
Context >> readVariableNamed: aName [
	^ (self lookupVar: aName) readInContext: self
]

{ #category : #'*Debugging-Core' }
Context >> respondsToUnknownBytecode [
	"This method is triggerred by the VM when the interpreter tries to execute an unknown bytecode"
	
	| unknownBytecode |
	unknownBytecode := self compiledCode at: self pc.
	self error: 'VM cannot run unknown bytecode ', unknownBytecode printString
	

]

{ #category : #'*Debugging-Core' }
Context >> restart [
	"Unwind thisContext to self and resume from beginning.  Execute unwind blocks when unwinding.  ASSUMES self is a sender of thisContext"

	| context unwindBlock |
	self isDead ifTrue: [self cannotReturn: nil to: self].
	self privRefresh.
	context := thisContext.
	[	context := context findNextUnwindContextUpTo: self.
		context isNil 
	] whileFalse: [
		context unwindComplete ifNil:[
			context unwindComplete: true.
			unwindBlock := context unwindBlock.
			thisContext terminateTo: context.
			unwindBlock value ]].
	
	thisContext terminateTo: self.
	self jump.

]

{ #category : #'*Debugging-Core' }
Context >> restartWithNewReceiver: obj [

	self
		swapReceiver: obj;
		restart
]

{ #category : #'*Debugging-Core' }
Context >> return: value to: aSender [
	"Simulate the return of value to aSender."

	self releaseTo: aSender.
	aSender ifNil: [^ nil].
	^ aSender push: value
]

{ #category : #'*Debugging-Core' }
Context >> returnBooleanPrimitive [

	^ 257
]

{ #category : #'*Debugging-Core' }
Context >> returnSelfPrimitive [

	^ 256
]

{ #category : #'*Debugging-Core' }
Context class >> runSimulated: aBlock [
	"Simulate the execution of the argument, current. Answer the result it 
	returns."

	^ thisContext sender
		runSimulated: aBlock
		contextAtEachStep: [:ignored |]

	"Context runSimulated: [Pen new defaultNib: 5; go: 100]"
]

{ #category : #'*Debugging-Core' }
Context >> runSimulated: aBlock contextAtEachStep: block2 [
	"Simulate the execution of the argument, aBlock, until it ends. aBlock 
	MUST NOT contain an '^'. Evaluate block2 with the current context 
	prior to each instruction executed. Answer the simulated value of aBlock."
	| current returnContext exception |
	
	aBlock hasMethodReturn
		ifTrue: [ self error: 'simulation of blocks with ^ can run loose' ].
		
	current := [ aBlock
					on: Exception
					do: [ :ex | SimulationExceptionWrapper signalForException: ex  ] ] asContext.
	
	returnContext := Context
			sender: nil
			receiver: self home receiver
			method: self home compiledCode
			arguments: self home arguments.
	
	current pushArgs: Array new from: returnContext.
	
	[current == returnContext]
		whileFalse: [ 
			block2 value: current.
			current := current step ].
	
	exception := returnContext pop.
	exception class == SimulationExceptionWrapper
		ifTrue: [ ^ exception exception signal ].
	^ exception
	
]

{ #category : #'*Debugging-Core' }
Context >> send: selector super: superFlag numArgs: numArgs [
	"Simulate the action of bytecodes that send a message with selector, 
	selector. The argument, superFlag, tells whether the receiver of the 
	message was specified with 'super' in the source method. The arguments 
	of the message are found in the top numArgs locations on the stack and 
	the receiver just below them."

	| currentReceiver arguments  |
	arguments := Array new: numArgs.
	numArgs to: 1 by: -1 do: [ :i | 
		arguments at: i put: self pop ].
	currentReceiver := self pop.
"	selector == #doPrimitive:method:receiver:args:
		ifTrue: [answer := receiver 
					doPrimitive: (arguments at: 1)
					method: (arguments at: 2)
					receiver: (arguments at: 3)
					args: (arguments at: 4).
				self push: answer.
				^self]. "
	^ self send: selector to: currentReceiver with: arguments super: superFlag
]

{ #category : #'*Debugging-Core' }
Context >> simulatePrimitive: primitiveIndex in: aMethod receiver: aReceiver arguments: arguments [
	| key simulator |
	
	key := primitiveIndex = 117 
		ifTrue: [ | literal |
			literal := aMethod literalAt: 1.
			"primitive name, module name"
			{literal second. literal first}] 
		ifFalse: [ primitiveIndex ].
	
	simulator := self class specialPrimitiveSimulators at: key ifAbsent: [
		 "named primitives"
		^  primitiveIndex = 117
				ifTrue: [
					self withoutPrimitiveTryNamedPrimitiveIn: aMethod for: aReceiver withArgs: arguments.
					"this uses primitive 218, which doesn't works as expected... 
					self tryNamedPrimitiveIn: method for: receiver withArgs: arguments " ]
				ifFalse: [ aReceiver tryPrimitive: primitiveIndex withArgs: arguments ]]. 
	
	^ simulator 
		simulatePrimitiveFor: aMethod
		receiver: aReceiver
		arguments: arguments
		context: self
]

{ #category : #'*Debugging-Core' }
Context class >> simulatePrimitive: primName module: moduleName with: simulator [
	^ self specialPrimitiveSimulators at: {primName. moduleName} put: simulator
]

{ #category : #'*Debugging-Core' }
Context class >> simulatePrimitiveNumber: num with: simulator [
	^ self specialPrimitiveSimulators at: num put: simulator
]

{ #category : #'*Debugging-Core' }
Context >> stepToHome: aContext [
	"Resume self until the home of top context is aContext.  Top context may be a block context."

	| home ctxt here error wrapperContext |
	here := thisContext.
	error := nil.
	
	wrapperContext := aContext insertSender: (Context contextOn: Exception do: [ :ex | 
				            error
					            ifNil: [ 
						            			error := ex.
												ex resumeUnchecked: here jump ]
					            ifNotNil: [ 
										ex pass ] ]).
	home := aContext home.

	"A first Step to do at least one step"
	ctxt := self step.

	home == ctxt home ifTrue: [ 
		"remove above inserted ensure and handler contexts"
		aContext terminateTo: wrapperContext sender.
		^ { 
			  ctxt.
			  error } ].

	[  ctxt := ctxt step.
		error ifNotNil: [ 
		"remove above inserted ensure and handler contexts"
		aContext terminateTo: wrapperContext sender.
			^ { 
				  ctxt.
				  error } ].

		home == ctxt home ] whileFalse: [ 
			(home isDead or: [ ctxt isDead ]) ifTrue: [ 
				^ { 
					  ctxt.
					  nil } ] ].
	"remove above inserted ensure and handler contexts"
	aContext terminateTo: wrapperContext sender.
	
	^ { 
		  ctxt.
		  nil }
]

{ #category : #'*Debugging-Core' }
Context >> stepToSendOrReturn [
	"Simulate the execution of bytecodes until either sending a message or 
	returning a value to the receiver (that is, until switching contexts)."

	| context |
	[ self isDead or: [ self willSend or: [  self willReturn or: [ self willStore or: [self willCreateBlock ] ] ] ] ]
		whileFalse: [
			context := self step.
			context == self ifFalse: [
				"Caused by mustBeBoolean handling"
				^context ]]
]

{ #category : #'*Debugging-Core' }
Context class >> tallyInstructions: aBlock [
	"This method uses the simulator to count the number of occurrences of
	each of the Smalltalk instructions executed during evaluation of aBlock.
	Results appear in order of the byteCode set."
	| tallies |
	tallies := Bag new.
	thisContext sender
		runSimulated: aBlock
		contextAtEachStep:
			[:current | tallies add: current nextByte].
	^tallies sortedElements

	"Context tallyInstructions: [3.14159 printString]"
]

{ #category : #'*Debugging-Core' }
Context class >> tallyMethods: aBlock [
	"This method uses the simulator to count the number of calls on each method
	invoked in evaluating aBlock. Results are given in order of decreasing counts."
	| prev tallies |
	tallies := Bag new.
	prev := aBlock.
	thisContext sender
		runSimulated: aBlock
		contextAtEachStep:
			[:current |
			current == prev ifFalse: "call or return"
				[prev sender ifNotNil: "call only"
					[tallies add: current printString].
				prev := current]].
	^ tallies sortedCounts

	"Contex tallyMethods: [3.14159 printString]"
]

{ #category : #'*Debugging-Core' }
Context >> tempNamed: aName [
	"Returns the value of the temporaries, aName"

	^(self lookupTempVar: aName) readInContext: self
]

{ #category : #'*Debugging-Core' }
Context >> tempNamed: aName put: anObject [
	"Assign the value of the temp with name in aContext"
	
	^(self lookupTempVar: aName) write: anObject inContext: self
]

{ #category : #'*Debugging-Core' }
Context >> tempNames [
	"Answer all the temp names in scope in aContext starting with the home's first local 
	(the first argument or first temporary if no arguments).
	
	These are all the temps that a programmer could access in the context, but keep in mind
	that as they might not be accesses here. 
	In addition, even vars that are accessed in this context could be stored
	in a temp vector, which itself would be a copied temp that has no name..."
	
	^ self astScope allTempNames
]

{ #category : #'*Debugging-Core' }
Context >> temporaryVariableNamed: aName [
	(self hasTemporaryVariableNamed: aName)
		ifFalse: [ ^ nil ].
	^self lookupTempVar: aName

]

{ #category : #'*Debugging-Core' }
Context >> temporaryVariables [
	^self sourceNode temporaries collect: [ :each | each binding ] 

]

{ #category : #'*Debugging-Core' }
Context >> tempsAndValues [
	"Return a string of the temporary variabls and their current values"
	
	^ String streamContents: [ :aStream |
		self tempNames 
			do: [ :name  |
			 aStream nextPutAll: name; nextPut: $:; space; tab.
			 self print: (self tempNamed: name) on: aStream]
			separatedBy: [aStream cr ]]
]

{ #category : #'*Debugging-Core' }
Context >> tempsAndValuesLimitedTo: sizeLimit indent: indent [
	"Return a string of the temporary variabls and their current values"

	^ String streamContents: [ :aStream |
		self tempNames 
			do: [ :name |
				indent timesRepeat: [ aStream tab ].
				aStream nextPutAll: name; nextPut: $:; space; tab.
				aStream nextPutAll: 
					((self tempNamed: name) printStringLimitedTo: (sizeLimit -3 -name size max: 1))]
			separatedBy: [aStream cr ]]
]

{ #category : #'*Debugging-Core' }
Context >> unusedBytecode [
	^ self respondsToUnknownBytecode 
]

{ #category : #'*Debugging-Core' }
Context >> updatePCForQuickPrimitiveRestart [

	({self returnBooleanPrimitive.	self returnSelfPrimitive } includes: self method primitive) 
		ifTrue: [ 
			pc := self method endPC.
			^ self ].

	pc := pc + self quickMethodPrimitiveBytecodeSize
]

{ #category : #'*Debugging-Core' }
Context >> writeVariableNamed: aName value: anObject [ 
	^ (self lookupVar: aName) write: anObject inContext: self
]
