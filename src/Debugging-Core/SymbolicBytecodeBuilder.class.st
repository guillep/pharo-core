"
I parse a method and create a collection of SymbolicBytecode objects for introspection.


"
Class {
	#name : #SymbolicBytecodeBuilder,
	#superclass : #InstructionClient,
	#instVars : [
		'method',
		'scanner',
		'oldPC',
		'symbolicBytecodes'
	],
	#category : #'Debugging-Core'
}

{ #category : #decoding }
SymbolicBytecodeBuilder class >> decode: aMethod [

	^(self new method: aMethod) decode
	
]

{ #category : #private }
SymbolicBytecodeBuilder >> addBytecode: description [ 
	"Append to the receiver a description of the bytecode, instruction." 

	| bytes symbolic |
	
	bytes := ByteArray new: (scanner pc - oldPC).
	
	(oldPC to: scanner pc - 1) doWithIndex: [:each :index | 
		bytes at: index put: (method at: each)].
	
	 symbolic := SymbolicBytecode new 
		method: method;
		bytes: bytes;
	 	description: description;
		offset: oldPC.
	symbolicBytecodes add: symbolic.
	oldPC := scanner pc

]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> blockReturnConstant: cst [

	self addBytecode: 'blockReturn: ' , cst printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> blockReturnTop [
	"Print the Return Top Of Stack bytecode."

	self addBytecode: 'blockReturn'
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> callPrimitive: primNumber [
	"Print the callPrimitive bytecode."
	| isInlined |
	isInlined := primNumber >= (1 << 15) ifTrue: [ 'Inlined' ] ifFalse: [ '' ].
	self addBytecode: 'call', isInlined, 'Primitive: ', primNumber printString
]

{ #category : #api }
SymbolicBytecodeBuilder >> decode [
	
	| end |
	symbolicBytecodes := OrderedCollection new.
	scanner := InstructionStream on: method.
	end := method endPC.
	oldPC := scanner pc.
	scanner interpretWithClient: self.
	^symbolicBytecodes
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> directedSuperSend: selector numArgs: numberArguments [
	"Print the Directed Super Send Message With Selector, selector, bytecode. 
	The current class is located in the stack, then the arguments of the message and the receiver just 
	below them."

	self addBytecode: 'directedSuperSend: ', selector printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> doDup [
	"Print the Duplicate Top Of Stack bytecode."

	self addBytecode: 'dup'
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> doPop [
	"Print the Remove Top Of Stack bytecode."

	self addBytecode: 'pop'
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> jump: offset [
	"Print the Unconditional Jump bytecode."

	self addBytecode: 'jumpTo: ', (scanner pc + offset) printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> jump: offset if: condition [ 
	"Print the Conditional Jump bytecode."

	self addBytecode: 
		(condition
			ifTrue: ['jumpTrue: ']
			ifFalse: ['jumpFalse: '])
			, (scanner pc + offset) printString
]

{ #category : #accessing }
SymbolicBytecodeBuilder >> method [
	^method
]

{ #category : #accessing }
SymbolicBytecodeBuilder >> method: aMethod [
	method :=  aMethod
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> methodReturnConstant: value [ 
	"Print the Return Constant bytecode."

	self addBytecode: 'return: ', value printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> methodReturnReceiver [
	"Print the Return Self bytecode."

	self addBytecode: 'returnSelf'
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> methodReturnTop [
	"Print the Return Top Of Stack bytecode."

	self addBytecode: 'returnTop'
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> popIntoLiteralVariable: anAssociation [ 
	"Print the Remove Top Of Stack And Store Into Literal Variable bytecode."

	self addBytecode: 'popIntoLit: ', anAssociation key
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> popIntoReceiverVariable: offset [ 
	"Print the Remove Top Of Stack And Store Into Instance Variable 
	bytecode."

	self addBytecode: 'popIntoRcvr: ', offset printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> popIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [

	self addBytecode: 'popIntoTemp: ', remoteTempIndex printString, ' inVectorAt: ', tempVectorIndex printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> popIntoTemporaryVariable: offset [ 
	"Print the Remove Top Of Stack And Store Into Temporary Variable 
	bytecode."

	self addBytecode: 'popIntoTemp: ', offset printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushActiveContext [
	"Print the Push Active Context On Top Of Its Own Stack bytecode."

	self addBytecode: 'pushThisContext'
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushActiveProcess [

	self addBytecode: 'pushThisProcess'
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushClosureCopyNumCopiedValues: numCopied numArgs: numArgs blockSize: blockSize [

	self addBytecode: 'closureNumCopied: ', numCopied printString
			, ' numArgs: ', numArgs printString
			, ' bytes ', scanner pc printString
			, ' to ', (scanner pc + blockSize - 1) printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushClosureTemps: numTemps [
	"Push on stack nil numTemps times for the closure temps."
	
	self addBytecode: 'pushClosureTemps:' , numTemps printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushConsArrayWithElements: numElements [

	self addBytecode: 'pop ', numElements printString, ' into (Array new: ', numElements printString, ')'
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushConstant: obj [
	"Print the Push Constant, obj, on Top Of Stack bytecode."

	self addBytecode: (String streamContents:
				[:s |
				s nextPutAll: 'pushConstant: '.
				obj isVariableBinding
					ifFalse: [obj printOn: s]
					ifTrue: [obj key
						ifNotNil: [s nextPutAll: '##'; nextPutAll: obj key]
						ifNil: [s nextPutAll: '###'; nextPutAll: obj value soleInstance name]]])

]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushFullClosure: lit numCopied: numCopied receiverOnStack: rcvr ignoreOuterContext: ignore [

	self addBytecode: 'fullClosure:' , lit printString , ' NumCopied: ', numCopied printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushLiteralVariable: anAssociation [
	"Print the Push Contents Of anAssociation On Top Of Stack bytecode."

	self addBytecode: 'pushLit: ' , (anAssociation key 
		ifNil: [ anAssociation value ] 
		ifNotNil: [ anAssociation key ]) asString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushNewArrayOfSize: numElements [
 
	self addBytecode: 'push: (Array new: ', numElements printString, ')'
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushReceiver [
	"Print the Push Active Context's Receiver on Top Of Stack bytecode."

	self addBytecode: 'self'
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushReceiverVariable: offset [
	"Print the Push Contents Of the Receiver's Instance Variable Whose Index 
	is the argument, offset, On Top Of Stack bytecode."

	self addBytecode: 'pushRcvr: ' , offset printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [

	self addBytecode: 'pushTemp: ', remoteTempIndex printString, ' inVectorAt: ', tempVectorIndex printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> pushTemporaryVariable: offset [
	"Print the Push Contents Of Temporary Variable Whose Index Is the 
	argument, offset, On Top Of Stack bytecode."

	self addBytecode: 'pushTemp: ', offset printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> send: selector super: supered numArgs: numberArguments [
	"Print the Send Message With Selector, selector, bytecode. The argument, 
	supered, indicates whether the receiver of the message is specified with 
	'super' in the source method. The arguments of the message are found in 
	the top numArguments locations on the stack and the receiver just 
	below them."

	self addBytecode: (supered ifTrue: ['superSend: '] ifFalse: ['send: ']), selector
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> storeIntoLiteralVariable: anAssociation [ 
	"Print the Store Top Of Stack Into Literal Variable Of Method bytecode."

	self addBytecode: 'storeIntoLit: ', anAssociation key
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> storeIntoReceiverVariable: offset [ 
	"Print the Store Top Of Stack Into Instance Variable Of Method bytecode."

	self addBytecode: 'storeIntoRcvr: ', offset printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> storeIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [

	self addBytecode: 'storeIntoTemp: ', remoteTempIndex printString, ' inVectorAt: ', tempVectorIndex printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> storeIntoTemporaryVariable: offset [ 
	"Print the Store Top Of Stack Into Temporary Variable Of Method 
	bytecode."

	self addBytecode: 'storeIntoTemp: ', offset printString
]

{ #category : #'instruction decoding' }
SymbolicBytecodeBuilder >> trap [ 
	"send the class trap message to the current context."
	
	self addBytecode: 'trap'

]
