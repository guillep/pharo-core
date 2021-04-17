"
My instances (and subinstances) are objects suitable for execution by the virtual machine. My subclasses and I have a specific layout so the instances intermix both indexable pointer fields and indexable integer fields.

	
The current format of a CompiledCode is as follows:

	header (4 bytes)
	literals (4 bytes each)
	bytecodes  (variable)
	trailer (variable)

The header describes the compiled code. It's a small integer with the following format: 

sign bit 	1 bit: 	if set, the method is encoded in the SecondaryBytecodeSet, else in the PrimaryBytecodeSet (See class variables) 
(index 0)	15 bits:	number of literals
(index 16)	1 bit:	requires counters (in the sista JIT, methods marked this way cannot trip)
(index 17)	1 bit:	whether a large frame size is needed
(index 18)	6 bits:	number of temporary variables
(index 24)	4 bits:	number of arguments to the method
(index 28)	1 bit:	has primitive
(index 29)	1 bit:	flag bit, ignored by the VM

The trailer encodes how to fetch the method's sources. See CompiledMethodTrailer.
"
Class {
	#name : #CompiledCode,
	#superclass : #ByteArray,
	#type : #compiledMethod,
	#classVars : [
		'LargeFrame',
		'PrimaryBytecodeSetEncoderClass',
		'SecondaryBytecodeSetEncoderClass',
		'SmallFrame'
	],
	#category : #'Kernel-Methods'
}

{ #category : #'instance creation' }
CompiledCode class >> newMethod: numberOfBytes header: headerWord [
	"Primitive. Answer an instance of me. The number of literals (and other 
	 information) is specified by the headerWord (see my class comment).
	 The first argument specifies the number of fields for bytecodes in the
	 method. Fail if either argument is not a SmallInteger, or if numberOfBytes
	 is negative, or if memory is low. Once the header of a method is set by
	 this primitive, it cannot be changed to change the number of literals.
	 Essential. See Object documentation whatIsAPrimitive."

	<primitive: 79 error: ec>
	ec == #'insufficient object memory' ifTrue:
		[^self handleFailingNewMethod: numberOfBytes header: headerWord].
	^self primitiveFailed
]

{ #category : #comparing }
CompiledCode >> = aCompiledMethod [
	"Answer whether the receiver implements the same code as aCompiledMethod."

	self == aCompiledMethod
		ifTrue: [ ^ true ].
	self class = aCompiledMethod class
		ifFalse: [ ^ false ].
	self size = aCompiledMethod size
		ifFalse: [ ^ false ].
	self header = aCompiledMethod header
		ifFalse: [ ^ false ].
	self initialPC to: self endPC do: [ :i | 
		(self at: i) = (aCompiledMethod at: i)
			ifFalse: [ ^ false ] ].
	(self sameLiteralsAs: aCompiledMethod)
		ifFalse: [ ^ false ].
	^ true
]

{ #category : #scanning }
CompiledCode >> accessesField: varIndex [
	"Answer whether the receiver accesses the instance variable indexed by the argument."

	^ (self readsField: varIndex) or: [ self writesField: varIndex ]
]

{ #category : #scanning }
CompiledCode >> accessesRef: literalVariable [
	"Answer whether this method accesses the LiteralVariable"
	"we do not need to call readsRef: or #writesRef:, as if the variable 
	is stored as a Literal, it will be accessed. This check is much faster"

	^ self hasLiteral: literalVariable
]

{ #category : #scanning }
CompiledCode >> accessesSlot: aSlot [
	^aSlot isAccessedIn: self
	
]

{ #category : #accessing }
CompiledCode >> allBlocksDo: aBlock [

	self literals 
		select: [ :aLiteral | aLiteral isEmbeddedBlock ] 
		thenDo: [ :aLiteral | aLiteral withAllBlocksDo: aBlock  ]
]

{ #category : #literals }
CompiledCode >> allLiterals [
	"Answer an Array of the literals referenced by the receiver.	
	 including superclass + selector/properties"
	| literals numberLiterals |
	literals := Array new: (numberLiterals := self numLiterals).
	1 to: numberLiterals do: [:index |
		literals at: index put: (self objectAt: index + 1)].
	^literals
]

{ #category : #'source code management' }
CompiledCode >> argumentNames [
	^ self propertyAt: #argumentNames ifAbsent: [ self ast argumentNames ]
]

{ #category : #converting }
CompiledCode >> asOrderedCollection [
	"We should override it because most of collection methods are not working for CompiledMethod. And it can't be normally converted into OrderedCollection.	
	It is special class which needs to be ByteArray by VM. But it is not behaves like ByteArray from user perspective"
	
	^OrderedCollection with: self
]

{ #category : #printing }
CompiledCode >> asString [

	  ^self sourceCode
]

{ #category : #'source code management' }
CompiledCode >> author [
	"Answer the author of the current version of the receiver. retrieved from the sources or changes file. Answer the empty string if no time stamp is available."

	"(CompiledMethod compiledMethodAt: #author) author"

	self timeStamp ifNotEmpty: [:s | 
		|subS|
		subS := s substrings first. 
		subS first isLetter ifTrue:[^subS]].
	^''
]

{ #category : #accessing }
CompiledCode >> bytecode [
	"Answer an ByteArray of the btyecode of the method."

	| start stop bytecode |

	start := self initialPC.
	stop := self endPC.
	
	bytecode := ByteArray new: (stop - start + 1).
	start to: stop do: [:index |
		bytecode byteAt: index - start + 1 put: (self byteAt: index)].
	^bytecode
]

{ #category : #accessing }
CompiledCode >> clearFlag [
	"Clear the user-level flag bit"

	self objectAt: 1 put: (self header bitAnd: (1 << 29) bitInvert)
]

{ #category : #accessing }
CompiledCode >> clearSignFlag [
	"Clear the sign flag bit.  The sign flag bit may be
	 used by the VM to select an alternate bytecode set."

	self signFlag ifTrue:
		[self objectAt: 1 put: self header - SmallInteger minVal]
]

{ #category : #accessing }
CompiledCode >> comment [
	"Return the first comment of the receiver"
	"(self>>#comment) comment"
	
	^ self ast firstPrecodeComment
]

{ #category : #'source code management' }
CompiledCode >> definition [

	"Polymorphic to class definition"

	self
		deprecated: #definition
		transformWith:
		'`@receiver definition' -> '`@receiver definitionString'.

	^ self definitionString
]

{ #category : #'source code management' }
CompiledCode >> definitionString [

	"Polymorphic to class definitionString"

	^ self sourceCode
]

{ #category : #accessing }
CompiledCode >> encoderClass [
	^ self signFlag 
		ifTrue: [ SecondaryBytecodeSetEncoderClass ]
		ifFalse: [ PrimaryBytecodeSetEncoderClass ]
]

{ #category : #accessing }
CompiledCode >> endPC [
	^ self subclassResponsibility
]

{ #category : #comparing }
CompiledCode >> equivalentTo: aCompiledMethod [
	^self = aCompiledMethod
	or: [self class == aCompiledMethod class
		and: [self numArgs = aCompiledMethod numArgs
		and: [self numLiterals = aCompiledMethod numLiterals
		and: [self methodNode = aCompiledMethod methodNode ]]]]
]

{ #category : #accessing }
CompiledCode >> flag [
	"Answer the user-level flag bit"

	^((self header bitShift: -29) bitAnd: 1) = 1
]

{ #category : #accessing }
CompiledCode >> frameSize [
	"Answer the size of temporary frame needed to run the receiver."
	"NOTE:  Versions 2.7 and later use two sizes of contexts."

	(self header noMask: 16r20000)
		ifTrue: [^ SmallFrame]
		ifFalse: [^ LargeFrame]

]

{ #category : #literals }
CompiledCode >> hasLiteral: literal [
	"Answer whether the receiver references the argument, literal."
	1 to: self numLiterals - self literalsToSkip do: "exclude superclass + selector/properties"
		[:index |
		| lit |
		((lit := self literalAt: index) literalEqual: literal) ifTrue: [^true].
		lit isEmbeddedBlock ifTrue: [ (lit hasLiteral: literal) ifTrue: [ ^true ] ]].
	^false
]

{ #category : #literals }
CompiledCode >> hasLiteralSuchThat: litBlock [
	"Answer true if litBlock returns true for any literal in this method, even if embedded in array structure."
	1 to: self numLiterals - self literalsToSkip do: "exclude header and methodClass or outerCode"
		[:index | | lit |
		lit := self literalAt: index.
		((litBlock value: lit)
		or: [lit isArray and: [lit hasLiteralSuchThat: litBlock]]) ifTrue:
			[^true].
		lit isEmbeddedBlock ifTrue: [ (lit hasLiteralSuchThat: litBlock) ifTrue: [ ^true ] ]].
	^false
]

{ #category : #literals }
CompiledCode >> hasLiteralThorough: aLiteral [
	self 
		deprecated: 'Use #refersToLiteral: instead.' 
		on: '31 January 2020'
		in: #Pharo9
		transformWith: '`@receiver hasLiteralThorough: `@arg' -> '`@receiver refersToLiteral: `@arg'.
	^ self refersToLiteral: aLiteral
]

{ #category : #accessing }
CompiledCode >> hasPragmaNamed: arg1 [ 
	^ self subclassResponsibility
]

{ #category : #literals }
CompiledCode >> hasSelector: selector [ 
	"Answers true if the method refers to the selector"
	^ self hasSelector: selector specialSelectorIndex: (Smalltalk specialSelectorIndexOrNil: selector)
]

{ #category : #literals }
CompiledCode >> hasSelector: selector specialSelectorIndex: specialOrNil [
	"Answers true if the method refers to the selector.
	 If you don't know what's a special selector, use #hasSelector:.
	 If you do, you may call this method directly to avoid recomputing 
	 the special selector index all the time.	
	 I traverse the method and all the compiled blocks in the literals"	
	(self refersToLiteral: selector) ifTrue: [ ^ true ].
	"refersToLiteral: traverses all blocks, but only for non-special literals"
	specialOrNil ifNil: [ ^ false ].
	"if the selector is special, scan all blocks and myself"
	self withAllBlocksDo: [ :aCompiledCode | 
		(aCompiledCode scanFor: self encoderClass firstSpecialSelectorByte + specialOrNil)
			ifTrue: [ ^true ] ].
	^false
]

{ #category : #accessing }
CompiledCode >> hasSourceCode [
	^ self subclassResponsibility
]

{ #category : #comparing }
CompiledCode >> hash [
	"CompiledMethod>>#= compares code, i.e. same literals and same bytecode.
	 So we look at the header, methodClass and some bytes between initialPC and endPC,
	 but /not/ the selector because the equal method does not compare selectors.
	 Note that we must override ByteArray>hash which looks at all bytes of the receiver.
	 Using bytes from the pointer part of a COmpiledmethod can lead to a variable hash
	 if and when when the GC moves literals in the receiver."
	| initialPC endPC hash |
	initialPC := self initialPC.
	endPC := self endPC.
	hash := self species hash + self header + initialPC + endPC + self methodClass hash bitAnd: 16rFFFFFFF.
	"sample approximately 20 bytes"
	initialPC to: endPC by: (endPC - initialPC // 20 max: 1) do:
		[:i| hash := hash + (self at: i)].
	^hash

	"(CompiledMethod>>#hash) hash"

]

{ #category : #literals }
CompiledCode >> header [
	"Answer the word containing the information about the form of the 
	receiver and the form of the context needed to run the receiver."

	^self objectAt: 1
]

{ #category : #literals }
CompiledCode >> headerDescription [
	"Answer a description containing the information about the form of the 
	receiver and the form of the context needed to run the receiver."

	| s |
	s := '' writeStream.
	self header printOn: s.
	s cr; nextPutAll: '"signFlag: '.
	self signFlag printOn: s.
	s nextPutAll: ' ('.
	self encoderClass name printOn: s.
	s nextPut: $).
	s cr; nextPutAll: 'primitive: '.
	self primitive printOn: s.
	s cr; nextPutAll: ' numArgs: '.
	self numArgs printOn: s.
	s cr; nextPutAll: ' numTemps: '.
	self numTemps printOn: s.
	s cr; nextPutAll: ' numLiterals: '.
	self numLiterals printOn: s.
	s cr; nextPutAll: ' frameSize: '.
	self frameSize printOn: s.
	s nextPut: $"; cr.
	^ s contents
]

{ #category : #literals }
CompiledCode >> indexOfLiteral: literal [
	"Answer the literal index of the argument, literal, or zero if none."
	1 to: self numLiterals - self literalsToSkip "exclude superclass + selector/properties"
	   do:
		[:index |
		literal == (self literalAt: index) ifTrue: [^index]].
	^0
]

{ #category : #accessing }
CompiledCode >> initialPC [
	"Answer the program counter for the receiver's first bytecode."

	^ (self numLiterals + 1) * Smalltalk wordSize + 1
]

{ #category : #literals }
CompiledCode >> innerCompiledBlocksAnySatisfy: aBlock [
	self innerCompiledBlocksDo: [ :cb | (aBlock value: cb) ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #literals }
CompiledCode >> innerCompiledBlocksDo: aBlock [
	"We ignore the enclosing compiled code in compiled block by ignoring the last literal"
	1 to: self numLiterals - self literalsToSkip do:
		[:index | | lit |
		lit := self literalAt: index.
		lit isEmbeddedBlock ifTrue: [ aBlock value: lit ] ]
]

{ #category : #testing }
CompiledCode >> isCollection [
	"We should override it because most of collection methods are not working for CompiledMethod. It is special class which needs to be ByteArray by VM. But it is not behaves like ByteArray from user perspective.
	And some tools uses isCollection check for specific behaviour which will fail for CompiledMethod"
	^false
]

{ #category : #testing }
CompiledCode >> isDoIt [
	^ false
]

{ #category : #testing }
CompiledCode >> isExternalCallPrimitive [
	^self primitive = 120
]

{ #category : #testing }
CompiledCode >> isNamedPrimitive [
	^self primitive = 117
]

{ #category : #testing }
CompiledCode >> isPrimitive [
	^self primitive > 0
]

{ #category : #testing }
CompiledCode >> isQuick [
	"Answer whether the receiver is a quick return (of self or of an instance 
	variable)."
	^ self primitive between: 256 and: 519
]

{ #category : #testing }
CompiledCode >> isRealPrimitive [
	^self isPrimitive and: [ self isQuick not ]
]

{ #category : #testing }
CompiledCode >> isReturnSelf [
	"Answer whether the receiver is a quick return of self."

	^ self primitive = 256
]

{ #category : #accessing }
CompiledCode >> isTestMethod [
	^ self subclassResponsibility
]

{ #category : #literals }
CompiledCode >> literalAt: index [ 
	"Answer the literal indexed by the argument."

	^self objectAt: index + 1
]

{ #category : #literals }
CompiledCode >> literalAt: index put: value [ 
	"Replace the literal indexed by the first argument with the second 
	argument. Answer the second argument."

	^self objectAt: index + 1 put: value
]

{ #category : #literals }
CompiledCode >> literals [

	"Answer an Array of the literals referenced by the receiver.	
	 Exclude superclass + selector/properties"

	| literals numberLiterals |
	literals := Array new:
		            (numberLiterals := self numLiterals
		                               - self literalsToSkip).
	1 to: numberLiterals do: [ :index | 
	literals at: index put: (self literalAt: index) ].
	^ literals
]

{ #category : #literals }
CompiledCode >> literalsAt: anIndex [
	"All literals are shifted of one slot. First slot is the method header"
	^ self objectAt: anIndex + 1
]

{ #category : #literals }
CompiledCode >> literalsDo: aBlock [
	"Evaluate aBlock for each of the literals referenced by the receiver."
	1 to: self numLiterals - self literalsToSkip do:
		[:index | aBlock value: (self literalAt: index)]
]

{ #category : #accessing }
CompiledCode >> literalsEvenTheOnesInTheInnerBlocks [

	| literals numberLiterals |
	literals := OrderedCollection new:
		            (numberLiterals := self numLiterals
		                               - self literalsToSkip).
	1 to: numberLiterals do: [ :index | 
		| lit |
		lit := self literalAt: index.
		lit isEmbeddedBlock
			ifTrue: [ literals addAll: lit literalsEvenTheOnesInTheInnerBlocks ]
			ifFalse: [ literals addLast: lit ] ].
	^ literals asArray
]

{ #category : #literals }
CompiledCode >> literalsToSkip [

	^ self subclassResponsibility
]

{ #category : #scanning }
CompiledCode >> localReadsRef: literalAssociation [ 
	"Answer whether the receiver loads the argument."
	| litIndex scanner |
	(litIndex := self indexOfLiteral: literalAssociation) = 0 ifTrue:
		[^false].
	litIndex := litIndex - 1.
	^(scanner := InstructionStream on: self) scanFor: (self encoderClass bindingReadScanBlockFor: litIndex using: scanner)
]

{ #category : #scanning }
CompiledCode >> localReadsSelf [
	^ self encoderClass readsSelfFor: self
]

{ #category : #scanning }
CompiledCode >> localReadsThisContext [
	^ self encoderClass readsThisContextFor: self
]

{ #category : #testing }
CompiledCode >> localSendsAnySelectorOf: aCollection [
	
	self literalsDo: [ :lit |
		(lit isSymbol and: [ aCollection includes: lit ]) 
			ifTrue: [ ^ self messages includesAny: aCollection ]
	].

	^ false 

]

{ #category : #scanning }
CompiledCode >> localSendsToSuper [
	^ self encoderClass sendsToSuperFor: self
]

{ #category : #scanning }
CompiledCode >> localWritesRef: literalAssociation [ 
	"Answer whether the receiver stores into the argument."
	| litIndex scanner |
	(litIndex := self indexOfLiteral: literalAssociation) = 0 ifTrue:
		[^false].
	litIndex := litIndex - 1.
	^(scanner := InstructionStream on: self) scanFor: (self encoderClass bindingWriteScanBlockFor: litIndex using: scanner)
]

{ #category : #printing }
CompiledCode >> longPrintOn: aStream [
	"List of all the byte codes in a method with a short description of each" 

	self isQuick ifTrue: 
		[self isReturnSpecial ifTrue:
			[^ aStream nextPutAll: 'Quick return ' , 
				(#('self' 'true' 'false' 'nil' '-1' '0' '1' '2') at: self primitive - 255)].
		^ aStream nextPutAll: 'Quick return field ' , self returnField printString , ' (0-based)'].

	self isPrimitive ifTrue: [
		self printPrimitiveOn: aStream.
	].
	self symbolicBytecodes do: [ :each | each printOn: aStream ] separatedBy: [ aStream cr ]

]

{ #category : #accessing }
CompiledCode >> method [
	^ self subclassResponsibility
]

{ #category : #accessing }
CompiledCode >> methodClass [
	self subclassResponsibility
]

{ #category : #accessing }
CompiledCode >> methodNode [
	^ self subclassResponsibility
]

{ #category : #initialization }
CompiledCode >> needsFrameSize: newFrameSize [
	"Set the largeFrameBit to accomodate the newFrameSize"
	(self numTemps + newFrameSize) > LargeFrame ifTrue:
		[^ self error: 'Cannot compile -- stack including temps is too deep'].
	self setFrameBit: ((self numTemps + newFrameSize) > SmallFrame 
		or: [ self primitive = 84 "perform:withArguments:"])
]

{ #category : #accessing }
CompiledCode >> numArgs [
	"Answer the number of arguments the receiver takes."

	^ (self header bitShift: -24) bitAnd: 16r0F
]

{ #category : #accessing }
CompiledCode >> numLiterals [
	"Answer the number of literals used by the receiver."
	^self header bitAnd: 16r7FFF
]

{ #category : #accessing }
CompiledCode >> numTemps [
	"Answer the number of temporary variables used by the receiver."
	
	^ (self header bitShift: -18) bitAnd: 16r3F
]

{ #category : #literals }
CompiledCode >> objectAt: index [ 
	"Primitive. Answer the method header (if index=1) or a literal (if index 
	>1) from the receiver. Essential. See Object documentation 
	whatIsAPrimitive."

	<primitive: 68>
	self primitiveFailed
]

{ #category : #literals }
CompiledCode >> objectAt: index put: value [ 
	"Primitive. Store the value argument into a literal in the receiver. An 
	index of 2 corresponds to the first literal. Fails if the index is less than 2 
	or greater than the number of literals. Answer the value as the result. 
	Normally only the compiler sends this message, because only the 
	compiler stores values in CompiledMethods. Essential. See Object 
	documentation whatIsAPrimitive."

	<primitive: 69>
	self primitiveFailed
]

{ #category : #accessing }
CompiledCode >> origin [
	^ self methodClass findOriginClassOf: self method
]

{ #category : #accessing }
CompiledCode >> originMethod [
	^ self methodClass findOriginMethodOf: self method
]

{ #category : #accessing }
CompiledCode >> pragmas [
	^ self subclassResponsibility
]

{ #category : #accessing }
CompiledCode >> primitive [
	^ self subclassResponsibility
]

{ #category : #printing }
CompiledCode >> primitiveErrorVariableName [
	"Answer the primitive error code temp name, or nil if none."
	self isPrimitive ifTrue:
		[self pragmas do:
			[:pragma| | kwds ecIndex |
			((kwds := pragma selector keywords) first = 'primitive:'
			and: [(ecIndex := kwds indexOf: 'error:') > 0]) ifTrue:
				[^pragma argumentAt: ecIndex]]].
	^nil
]

{ #category : #accessing }
CompiledCode >> properties [
	^ self subclassResponsibility
]

{ #category : #accessing }
CompiledCode >> propertyAt: aString ifAbsent: aFullBlockClosure [
	^ aFullBlockClosure value
]

{ #category : #scanning }
CompiledCode >> readsField: varIndex [ 
	"Answer whether the receiver loads the instance variable indexed by the argument."
	| varIndexCode scanner |
	varIndexCode := varIndex - 1.
	((scanner := InstructionStream on: self) scanFor: (self encoderClass instVarReadScanBlockFor: varIndexCode using: scanner)) ifTrue: [ ^ true ].
	^ self innerCompiledBlocksAnySatisfy: [ :cb | cb readsField: varIndex ]
]

{ #category : #scanning }
CompiledCode >> readsRef: literalAssociation [ 
	"Answer whether the receiver loads the argument."
	(self localReadsRef: literalAssociation) ifTrue: [ ^ true ].
	^ self innerCompiledBlocksAnySatisfy: [ :cb | cb readsRef: literalAssociation ]
]

{ #category : #scanning }
CompiledCode >> readsSelf [
	"Answer whether compiledMethod reads self, look into embedded blocks, too"
	self isReturnSelf ifTrue: [ ^ true ].
	self localReadsSelf ifTrue: [ ^ true ].
	^ self innerCompiledBlocksAnySatisfy: [ :cb | cb readsSelf]
]

{ #category : #scanning }
CompiledCode >> readsSlot: aSlot [
	^aSlot isReadIn: self
]

{ #category : #scanning }
CompiledCode >> readsThisContext [
	"Answer whether compiledMethod reads thisContext, look into embedded blocks, too"
	self localReadsThisContext ifTrue: [ ^ true ].
	^ self innerCompiledBlocksAnySatisfy: [ :cb | cb readsThisContext]
]

{ #category : #testing }
CompiledCode >> refersToLiteral: aLiteral [
	"Answer true if any literal in this method is literal,
	even if embedded in array structure."

	1 to: self numLiterals - self literalsToSkip do: [ :index | 
		"exclude selector or additional method state (penultimate slot) 
		and methodClass or outerCode (last slot)"
		((self literalAt: index) refersToLiteral: aLiteral)
			ifTrue: [ ^ true ] ].

	^ false
]

{ #category : #comparing }
CompiledCode >> sameLiteralsAs: method [
	"Compare my literals to those of method. This is needed to compare compiled methods."

	| numLits literal1 literal2 |
	(numLits := self numLiterals) ~= method numLiterals
		ifTrue: [ ^ false ].
	"The last literal requires special checking instead of using #literalEqual:"
	1 to: numLits - 1 do: [ :index | 
		literal1 := self literalAt: index.
		literal2 := method literalAt: index.
		(literal1 == literal2 or: [ literal1 literalEqual: literal2 ])
			ifFalse: [ 
				(index = 1 and: [ self isNamedPrimitive | self isExternalCallPrimitive ])
					ifTrue: [ 
						literal1 isArray
							ifTrue: [ 
								(literal2 isArray and: [ literal1 allButLast = literal2 allButLast ])
									ifFalse: [ ^ false ] ]
							ifFalse: [ 
								"ExternalLibraryFunction"
								(literal1 analogousCodeTo: literal2)
									ifFalse: [ ^ false ] ] ]
					ifFalse: [ 
						index = (numLits - 1)
							ifTrue: [ 
								"properties"
								"don't create properties if they don't exist"
								(literal1 isSymbol and: [ literal2 isSymbol ]) 
									ifTrue: [ ^ false ]
									ifFalse: [
										(self properties analogousCodeTo: method properties) ifFalse: [ ^false ] ] ]
							ifFalse: [ ^ false ] ] ] ].
	"Class side methods have non unique (nil -> a Metaclass) as literal and cannot be compared equal"
	literal1 := self literalAt: numLits.
	literal2 := method literalAt: numLits.
	^literal1 class == literal2 class
	     and: [literal1 isAssociation
	                ifTrue: [literal1 key = literal2 key and: [literal1 value = literal2 value]]
	                ifFalse: [literal1 = literal2]]
]

{ #category : #scanning }
CompiledCode >> scanFor: byte [ 
	"Answer whether the receiver contains the argument as a bytecode."

	^ (InstructionStream on: self) scanFor: [:instr | instr = byte]
"
Smalltalk browseAllSelect: [:m | m scanFor: 134]
"
]

{ #category : #accessing }
CompiledCode >> scanner [

	^ InstructionStream on: self
]

{ #category : #accessing }
CompiledCode >> selector [
	^ self subclassResponsibility
]

{ #category : #testing }
CompiledCode >> sendsAnySelectorOf: aCollection [
	
	(self localSendsAnySelectorOf: aCollection) ifTrue: [ ^ true ].
	^ self innerCompiledBlocksAnySatisfy: [ :cb | cb sendsAnySelectorOf: aCollection ]

]

{ #category : #literals }
CompiledCode >> sendsSelector: aSymbol [ 	
	"Answer whether the method sends a particular selector"
	^ self messages includes: aSymbol
]

{ #category : #scanning }
CompiledCode >> sendsToSuper [
	self localSendsToSuper ifTrue: [ ^ true ].
	^ self innerCompiledBlocksAnySatisfy: [ :cb | cb sendsToSuper ]
]

{ #category : #initialization }
CompiledCode >> setFrameBit: boolean [ 
	"true for large frame, else false"
	| largeFrameBit newHeader |
	largeFrameBit := 16r20000.
	newHeader := self header bitAnd: largeFrameBit bitInvert.
	boolean ifTrue: [ newHeader := newHeader + largeFrameBit ].
	self objectAt: 1 put: newHeader.
]

{ #category : #accessing }
CompiledCode >> setSignFlag [
	"Set the sign flag bit.  The sign flag bit may be
	 used by the VM to select an alternate bytecode set."

	self signFlag ifFalse:
		[self objectAt: 1 put: self header + SmallInteger minVal]
]

{ #category : #accessing }
CompiledCode >> signFlag [
	"Answer the sign flag bit.  The sign flag bit may be
	 used by the VM to select an alternate bytecode set."

	^ self header < 0
]

{ #category : #accessing }
CompiledCode >> sourceCode [
	^ self subclassResponsibility
]

{ #category : #accessing }
CompiledCode >> sourceNode [
	^ self subclassResponsibility
]

{ #category : #accessing }
CompiledCode >> sourceNodeForPC: arg1 [ 
	^ self subclassResponsibility
]

{ #category : #'source code management' }
CompiledCode >> sourcePointer [
	^ self subclassResponsibility 
]

{ #category : #'source code management' }
CompiledCode >> stamp [

	^ self timeStamp
]

{ #category : #'debugger support' }
CompiledCode >> stepIntoQuickMethods [
	^self propertyAt: #stepIntoQuickMethod ifAbsent: [ false ]
]

{ #category : #printing }
CompiledCode >> symbolic [
	"Answer a String that contains a list of all the byte codes in a method with a short description of each."

	^self longPrintString.
]

{ #category : #printing }
CompiledCode >> timeStamp [
	"Answer the authoring time-stamp for the given method, retrieved from the sources or changes file. Answer the empty string if no time stamp is available."
	"(CompiledMethod compiledMethodAt: #timeStamp) timeStamp"

	^ SourceFiles timeStampAt: self sourcePointer.
]

{ #category : #testing }
CompiledCode >> usesPrimaryBytecodeSet [
	^ self header >= 0
]

{ #category : #testing }
CompiledCode >> usesSecondaryBytecodeSet [
	^ self header < 0
]

{ #category : #cleaning }
CompiledCode >> voidCogVMState [
	"Tell the VM to remove all references to any machine code form of the method.
	 This primitive must be called whenever a method is in use and modified.  This is
	 more aggressive (and *much* more costly) than flushCache since it must search
	 through all context objects, making sure that none have a (hidden) machine code pc
	 in the receiver.  Since modifying a method will likely change the generated machine code,
	 modifying a method (rather than redefining it) requires this more aggressive flush."

	<primitive: 215>
	^self flushCache
]

{ #category : #accessing }
CompiledCode >> withAllBlocks [
	| all |
	all := IdentitySet new.
	self withAllBlocksDo: [ :each | all add: each ].
	^all
]

{ #category : #accessing }
CompiledCode >> withAllBlocksDo: aBlock [ 
	
	aBlock value: self.
	self allBlocksDo: aBlock
	
]

{ #category : #accessing }
CompiledCode >> withAllNestedLiteralsDo: aBlockClosure [ 
	"This method traverses all the nested literals.
	As a Block or Method can have literals in the nested blocks. 
	This is used to query all the selectors used in a method for example"
	
	self withAllBlocksDo: [ :aCompiledCode | 
		aCompiledCode literals do: aBlockClosure ]
]

{ #category : #scanning }
CompiledCode >> writesField: varIndex [
	"Answer whether the receiver stores into the instance variable indexed by the argument."

	| varIndexCode scanner |
	varIndexCode := varIndex - 1.
	((scanner := InstructionStream on: self) scanFor: (self encoderClass instVarWriteScanBlockFor: varIndexCode using: scanner)) ifTrue: [ ^ true ].
	^ self innerCompiledBlocksAnySatisfy: [ :cb | cb writesField: varIndex ]
]

{ #category : #scanning }
CompiledCode >> writesRef: literalAssociation [ 
	"Answer whether the receiver stores into the argument."
	(self localWritesRef: literalAssociation) ifTrue: [ ^ true ].
	^ self innerCompiledBlocksAnySatisfy: [ :cb | cb writesRef: literalAssociation ]
]

{ #category : #scanning }
CompiledCode >> writesSlot: aSlot [
	^aSlot isWrittenIn: self
]
