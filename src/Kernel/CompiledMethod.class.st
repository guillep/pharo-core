"
Specific version of compiled code for method's.

CompiledMethod instances can be in two forms:
- up until Pharo 6, they encode both the method and the inner closures bytecodes and literals.
- since Pharo 6, they encode only the method's bytecodes and literals.

In addition the execution mechanics, a compiled method have two extra optional literals. The last literal, optional if there are no super sends, is the class in which the method is installed. The last but one literal is either the method's selector or an AdditionalMethodState instance. AdditionalMethodState instances are used to encode additional state to a method, as for example the pragmas.

The bytecode encodes the trailer at the end, in most cases it has 4 bytes encoding the sourcer pointer (see CompiledMethodTrailer).
Thus endPC of a compiled method is not the size of the bytecode, but the size minus the length of the trailer.

"
Class {
	#name : #CompiledMethod,
	#superclass : #CompiledCode,
	#type : #compiledMethod,
	#category : #'Kernel-Methods'
}

{ #category : #constants }
CompiledMethod class >> abstractMarker [
	^ #subclassResponsibility
]

{ #category : #'instance creation' }
CompiledMethod class >> basicNew [

	self error: 'CompiledMethods may only be created with newMethod:header:' 
]

{ #category : #'instance creation' }
CompiledMethod class >> basicNew: size [

	self error: 'CompiledMethods may only be created with newMethod:header:' 
]

{ #category : #'class initialization' }
CompiledMethod class >> checkBytecodeSetConflictsInMethodsWith: aBlock [

	self allSubInstances
		detect: aBlock
		ifFound: [ Warning signal: 'There are existing CompiledMethods with a different encoderClass.' ]
]

{ #category : #'class initialization' }
CompiledMethod class >> checkIsValidBytecodeEncoder: aBytecodeEncoderSubclass [
	(aBytecodeEncoderSubclass inheritsFrom: BytecodeEncoder) ifFalse:
		[self error: 'A bytecode set encoder is expected to be a subclass of BytecodeEncoder'].
]

{ #category : #'instance creation' }
CompiledMethod class >> cleanUpSourceInTrailers [

	self allInstances do: [:e | e isInstalled ifFalse: [e embeddSourceInTrailer]].  
	"pay attention since embeddSourceInTrailer creates a new compiled method. So iterating while
	changing it is a bad idea. This is why we use allInstances do and not allInstancesDo:"
]

{ #category : #constants }
CompiledMethod class >> conflictMarker [
	^ #traitConflict
]

{ #category : #constants }
CompiledMethod class >> disabledMarker [
	^ #shouldNotImplement
]

{ #category : #constants }
CompiledMethod class >> explicitRequirementMarker [
	^ #explicitRequirement
]

{ #category : #'class initialization' }
CompiledMethod class >> fullFrameSize [  "CompiledMethod fullFrameSize"
	^ LargeFrame
]

{ #category : #private }
CompiledMethod class >> handleFailingFailingNewMethod: numberOfBytes header: headerWord [
	"This newMethod:header: gets sent after handleFailingBasicNew: has done a full
	 garbage collection and possibly grown memory.  If this basicNew: fails then the
	 system really is low on space, so raise the OutOfMemory signal.

	 Primitive. Answer an instance of this class with the number of indexable variables
	 specified by the argument, headerWord, and the number of bytecodes specified
	 by numberOfBytes.  Fail if this if the arguments are not Integers, or if numberOfBytes
	 is negative, or if the receiver is not a CompiledMethod class, or if there is not enough
	 memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 79>
	"space must be low."
	OutOfMemory signal.
	"retry if user proceeds"
	^self newMethod: numberOfBytes header: headerWord
]

{ #category : #private }
CompiledMethod class >> handleFailingNewMethod: numberOfBytes header: headerWord [
	"This newMethod:header: gets sent after newMethod:header: has failed
	 and allowed a scavenging garbage collection to occur.  The scavenging
	 collection will have happened as the VM is activating the (failing) basicNew:.
	 If handleFailingBasicNew: fails then the scavenge failed to reclaim sufficient
	 space and a global garbage collection is required.  Retry after garbage
	 collecting and growing memory if necessary.

	 Primitive. Answer an instance of this class with the number of indexable variables
	 specified by the argument, headerWord, and the number of bytecodes specified
	 by numberOfBytes.  Fail if this if the arguments are not Integers, or if numberOfBytes
	 is negative, or if the receiver is not a CompiledMethod class, or if there is not enough
	 memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 79>
	| bytesRequested |
	bytesRequested := (headerWord bitAnd: 16rFFFF) + 1 * Smalltalk wordSize + numberOfBytes + 16.
	Smalltalk garbageCollect < bytesRequested ifTrue:
		[Smalltalk growMemoryByAtLeast: bytesRequested].
	"retry after global garbage collect and possible grow"
	^self handleFailingFailingNewMethod: numberOfBytes header: headerWord
]

{ #category : #'instance creation' }
CompiledMethod class >> headerFlagForEncoder: anEncoderClass [
	anEncoderClass == PrimaryBytecodeSetEncoderClass ifTrue: [ ^ 0 ].
	anEncoderClass == SecondaryBytecodeSetEncoderClass ifTrue: [ ^ SmallInteger minVal ].
	self error: 'The encoder is not one of the two installed bytecode sets'
]

{ #category : #'class initialization' }
CompiledMethod class >> initialize [    "CompiledMethod initialize"
	"Initialize class variables specifying the size of the temporary frame
	needed to run instances of me."

	SmallFrame := 16.	"Context range for temps+stack"
	LargeFrame := 56.
	PrimaryBytecodeSetEncoderClass := EncoderForV3PlusClosures.
	SecondaryBytecodeSetEncoderClass := EncoderForSistaV1
]

{ #category : #'class initialization' }
CompiledMethod class >> installPrimaryBytecodeSet: aBytecodeEncoderSubclass [
	PrimaryBytecodeSetEncoderClass == aBytecodeEncoderSubclass ifTrue:
		[ ^self ].
	self checkIsValidBytecodeEncoder: aBytecodeEncoderSubclass.
	self checkBytecodeSetConflictsInMethodsWith: [:m| 
		m usesPrimaryBytecodeSet and: [m encoderClass ~~ aBytecodeEncoderSubclass]].
	PrimaryBytecodeSetEncoderClass := aBytecodeEncoderSubclass
]

{ #category : #'class initialization' }
CompiledMethod class >> installSecondaryBytecodeSet: aBytecodeEncoderSubclass [
	PrimaryBytecodeSetEncoderClass == aBytecodeEncoderSubclass ifTrue:
		[ ^ self ].
	self checkIsValidBytecodeEncoder: aBytecodeEncoderSubclass.
	self checkBytecodeSetConflictsInMethodsWith: [ :m | 
		m usesSecondaryBytecodeSet and: [ m encoderClass ~~ aBytecodeEncoderSubclass ] ].
	SecondaryBytecodeSetEncoderClass := aBytecodeEncoderSubclass
]

{ #category : #'accessing class hierarchy' }
CompiledMethod class >> methodPropertiesClass [
	"Answer the class to use to create a method's properties, which can be a poor man's way
	 to add instance variables to subclassses of CompiledMethod.  Subclasses of CompiledMethod
	 should define a corresponding subclass of AdditionalMethodState that adds any instance variables
	 required, and override this method to answer that class."
	^AdditionalMethodState
]

{ #category : #'instance creation' }
CompiledMethod class >> new [
	"This will not make a meaningful method, but it could be used
	to invoke some otherwise useful method in this class."
	^self newMethod: 2 header: 1024
]

{ #category : #'instance creation' }
CompiledMethod class >> newBytes: numberOfBytes trailerBytes: trailer nArgs: nArgs nTemps: nTemps nStack: stackSize nLits: nLits primitive: primitiveIndex [
	"Answer an instance of me. The header is specified by the message 
	 arguments. The remaining parts are not as yet determined."
	| method pc |
	nArgs > 15 ifTrue:
		[^self error: 'Cannot compile -- too many arguments'].
	nTemps > 63 ifTrue:
		[^self error: 'Cannot compile -- too many temporary variables'].	
	nLits > 65535 ifTrue:
		[^self error: 'Cannot compile -- too many literals'].

	method := trailer
				createMethod: numberOfBytes
				class: self
				header:    (nArgs bitShift: 24)
						+ (nTemps bitShift: 18)
						+ ((nTemps + stackSize) > SmallFrame ifTrue: [1 bitShift: 17] ifFalse: [0])
						+ nLits
						+ (primitiveIndex > 0 ifTrue: [1 bitShift: 16] ifFalse: [0]).
	primitiveIndex > 0 ifTrue:
		[pc := method initialPC.
		 method
			at: pc + 0 put: method encoderClass callPrimitiveCode;
			at: pc + 1 put: (primitiveIndex bitAnd: 16rFF);
			at: pc + 2 put: (primitiveIndex bitShift: -8)].
	^method
]

{ #category : #'instance creation' }
CompiledMethod class >> newBytes: numberOfBytes trailerBytes: trailer nArgs: nArgs nTemps: nTemps nStack: stackSize nLits: nLits primitive: primitiveIndex flag: flag [
	"Answer an instance of me. The header is specified by the message 
	 arguments. The remaining parts are not as yet determined."
	| method pc |
	nArgs > 15 ifTrue:
		[^self error: 'Cannot compile -- too many arguments'].
	nTemps > 63 ifTrue:
		[^self error: 'Cannot compile -- too many temporary variables'].	
	nLits > 65535 ifTrue:
		[^self error: 'Cannot compile -- too many literals'].

	method := trailer
				createMethod: numberOfBytes
				class: self
				header:    (nArgs bitShift: 24)
						+ (nTemps bitShift: 18)
						+ ((nTemps + stackSize) > SmallFrame ifTrue: [1 bitShift: 17] ifFalse: [0])
						+ nLits
						+ (primitiveIndex > 0 ifTrue: [1 bitShift: 16] ifFalse: [0])
						+ (flag ifTrue: [1 bitShift: 29] ifFalse: [0]).
	primitiveIndex > 0 ifTrue:
		[pc := method initialPC.
		 method
			at: pc + 0 put: method encoderClass callPrimitiveCode;
			at: pc + 1 put: (primitiveIndex bitAnd: 16rFF);
			at: pc + 2 put: (primitiveIndex bitShift: -8)].
	^method
]

{ #category : #'instance creation' }
CompiledMethod class >> newFrom: aCompiledMethod [
	| inst |
	inst := super basicNew: aCompiledMethod size.
	1 to: aCompiledMethod size do: [:index |
		inst at: index put: (aCompiledMethod at: index)].
	^ inst.
]

{ #category : #'instance creation' }
CompiledMethod class >> newInstanceFrom: oldInstance variable: variable size: instSize map: map [
	"Create a new instance of the receiver based on the given old instance.
	The supplied map contains a mapping of the old instVar names into
	the receiver's instVars"
	| new |
	new := self newFrom: oldInstance.
	1 to: instSize do: 
		[:offset |  (map at: offset) > 0 ifTrue:
			[new instVarAt: offset
					put: (oldInstance instVarAt: (map at: offset))]].
	^new
]

{ #category : #'instance creation' }
CompiledMethod class >> primitive: primNum numArgs: numArgs numTemps: numTemps stackSize: stackSize literals: literals bytecodes: bytecodes trailer: trailerBytes [
	"Create method with given attributes.  numTemps includes numArgs.  stackSize does not include numTemps."

	| compiledMethod |
	compiledMethod := self
		newBytes: bytecodes size
		trailerBytes: trailerBytes 
		nArgs: numArgs
		nTemps: numTemps
		nStack: 0
		nLits: literals size
		primitive: primNum.
	(WriteStream with: compiledMethod)
		position: compiledMethod initialPC - 1;
		nextPutAll: bytecodes.
	literals withIndexDo: [:obj :i | compiledMethod literalAt: i put: obj].
	compiledMethod needsFrameSize: stackSize.
	^ compiledMethod
]

{ #category : #'class initialization' }
CompiledMethod class >> smallFrameSize [

	^ SmallFrame
]

{ #category : #constants }
CompiledMethod class >> subclassResponsibilityMarker [
	^ #subclassResponsibility
]

{ #category : #'instance creation' }
CompiledMethod class >> toReturnConstant: index trailerBytes: trailer [
	"Answer an instance of me that is a quick return of the constant
	indexed in (true false nil -1 0 1 2)."

	^self newBytes: 3 trailerBytes: trailer nArgs: 0 nTemps: 0 nStack: 0 nLits: 2 primitive: 256 + index
]

{ #category : #'instance creation' }
CompiledMethod class >> toReturnField: field trailerBytes: trailer [
	"Answer an instance of me that is a quick return of the instance variable 
	indexed by the argument, field."

	^self newBytes: 3 trailerBytes: trailer nArgs: 0 nTemps: 0 nStack: 0 nLits: 2 primitive: 264 + field
]

{ #category : #'instance creation' }
CompiledMethod class >> toReturnSelf [
	"Answer an instance of me that is a quick return of the instance (^self)."

	^ self toReturnSelfTrailerBytes: CompiledMethodTrailer empty
]

{ #category : #'instance creation' }
CompiledMethod class >> toReturnSelfTrailerBytes: trailer [
	"Answer an instance of me that is a quick return of the instance (^self)."

	^self newBytes: 3 trailerBytes: trailer nArgs: 0 nTemps: 0 nStack: 0 nLits: 2 primitive: 256
]

{ #category : #'source code management' }
CompiledMethod >> argumentNames [
	^ self propertyAt: #argumentNames ifAbsent: [ super argumentNames ]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> cachePragmas [

	self pragmas do: [ :pragma | pragma class addToCache: pragma ]
]

{ #category : #'accessing-backward compatible' }
CompiledMethod >> category [
	"Please favor protocol instead of category. We want to have method protocol and class package and tag = a category"
	^ self methodClass organization categoryOfElement: self selector
]

{ #category : #accessing }
CompiledMethod >> classBinding [
	"answer the association to the class that I am installed in, or nil if none."
	^self literalAt: self numLiterals
]

{ #category : #accessing }
CompiledMethod >> classBinding: aBinding [
       "sets the association to the class that I am installed in"
       ^self literalAt: self numLiterals put: aBinding.
]

{ #category : #accessing }
CompiledMethod >> codeForNoSource [
	"if everything fails, decompile the bytecode"
	"If there is no compiler, we cannot decompile it"	
	Smalltalk hasCompiler ifFalse: [ ^ nil ].
	
	 ^(self compiler decompileMethod: self) formattedCode
]

{ #category : #testing }
CompiledMethod >> containsHalt [

	^ self hasProperty: #containsHalt
]

{ #category : #'source code management' }
CompiledMethod >> copyWithSource: aString [
	^self copyWithTrailerBytes: (CompiledMethodTrailer new sourceCode: aString) 
]

{ #category : #initialization }
CompiledMethod >> copyWithTrailerBytes: trailer [
"Testing:
	(CompiledMethod compiledMethodAt: #copyWithTrailerBytes:)
		tempNamesPut: 'copy end '
"
	| copy end start penultimateLiteral |
	start := self initialPC.
	end := self endPC.
	copy := trailer createMethod: end - start + 1 class: self class header: self header.
	1 to: self numLiterals do: [:i | copy literalAt: i put: (self literalAt: i)].
	(penultimateLiteral := self penultimateLiteral) isMethodProperties ifTrue:
		[copy penultimateLiteral: (penultimateLiteral copy
									setMethod: copy;
									yourself)].
	start to: end do: [:i | copy at: i put: (self at: i)].
	^copy
]

{ #category : #accessing }
CompiledMethod >> defaultSelector [ 
	"Invent and answer an appropriate message selector (a Symbol) for me, 
	that is, one that will parse with the correct number of arguments."

	^ #DoIt numArgs: self numArgs
]

{ #category : #printing }
CompiledMethod >> displayStringOn: aStream [
	aStream print: self methodClass; nextPutAll: '>>'; store: self selector.
]

{ #category : #'source code management' }
CompiledMethod >> embeddSourceInTrailer [
	"When receiver is deinstalled from its class, its not managed anymore by development tools
	and it's hard to predict, how long a method could stay in the image, because if it contains blocks,
	they could still reference it. 
	Therefore we trying to preserve as much as we can , actually by embedding the method's source code into its trailer
	"
	self trailer hasSourcePointer ifTrue: [
		^self becomeForward: (self copyWithSource: self sourceCode)]

]

{ #category : #accessing }
CompiledMethod >> endPC [
	"Answer the index of the last bytecode, as the trailer size varies we have to delegate"
	^ self trailer endPC
]

{ #category : #accessing }
CompiledMethod >> flushCache [
	"Tell the virtual machine to remove all references to this method from its method lookup caches, and to discard any optimized version 	of the method, if it has any of these.  This must be done whenever a method is modified in place, such as modifying its literals or 	machine code, to reflect the revised code.  c.f. Behavior>>flushCache & Symbol>>flushCache.  Essential.	 See MethodDictionary class 	comment."

	<primitive: 116>

]

{ #category : #'source code management' }
CompiledMethod >> getPreambleFrom: aFileStream at: position [
	^ SourceFiles getPreambleFrom: aFileStream at: position
]

{ #category : #'source code management' }
CompiledMethod >> getSourceFromFile [
	"PLEASE Note: clients should always call #sourceCode"
	"Read the source code from file, determining source file index and
	file position from the last 3 bytes of this method."

	^ [ SourceFiles sourceCodeAt: self sourcePointer ] on: Error do: [ '' ]
]

{ #category : #'source code management' }
CompiledMethod >> getSourceReplacingSelectorWith: newSelector [
	| oldKeywords newKeywords source newSource oldSelector start |
	source := self sourceCode.
	
	source ifNil: [ ^ nil ].
	
	oldSelector := self selector.
	oldSelector = newSelector ifTrue: [ ^ source ].
	
	oldKeywords := oldSelector keywords.
	newKeywords := (newSelector ifNil: [self defaultSelector]) keywords.
	[oldKeywords size = newKeywords size] assert.
	
	newSource := source.
	start := 1.
	oldKeywords with: newKeywords do: [:oldKey :newKey| |pos|
		pos := newSource findString: oldKey startingAt: start .
		newSource := newSource copyReplaceFrom: pos to: (pos + oldKey size -1) with: newKey.
		start := pos + newKey size ].

	^newSource
]

{ #category : #testing }
CompiledMethod >> hasComment [
	"check if this method has a method comment"
	^self comment isEmptyOrNil not
]

{ #category : #testing }
CompiledMethod >> hasPragma [
	^ self hasProperties and: [self pragmas isNotEmpty]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> hasPragmaNamed: aSymbol [
	^ self pragmas anySatisfy: [ :pragma | pragma selector = aSymbol ]
]

{ #category : #testing }
CompiledMethod >> hasProperties [
	^ self penultimateLiteral isMethodProperties
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> hasProperty: aKey [

	| extendedMethodState |
	^ (extendedMethodState := self penultimateLiteral) isMethodProperties
		  ifTrue: [  extendedMethodState includesProperty: aKey ]
		  ifFalse: [ false ]
]

{ #category : #accessing }
CompiledMethod >> hasSourceCode [

	"Retrieve or reconstruct the source code for this method."
	| trailer source |
	trailer := self trailer.
	trailer sourceCode ifNotNil: [:code | ^ true ].
	trailer hasSourcePointer ifFalse: [^ false].

	"Situation normal;  read the sourceCode from the file"
	source := [self getSourceFromFile]
				on: Error
				do: [ :ex | ex return: nil].
	source isEmptyOrNil ifTrue: [^ false].			
	^ true
]

{ #category : #testing }
CompiledMethod >> hasSourcePointer [
	^ self trailer hasSourcePointer
]

{ #category : #testing }
CompiledMethod >> isAbstract [
	"Answer true if I am abstract"
	
	| marker |
	marker := self markerOrNil ifNil: [^false].
	
	^marker == self class subclassResponsibilityMarker 
		or: [ marker == self class explicitRequirementMarker ]

]

{ #category : #testing }
CompiledMethod >> isBinarySelector [
	^self selector
		allSatisfy: [:each | each isSpecial]
]

{ #category : #testing }
CompiledMethod >> isCompiledMethod [

	^ true
]

{ #category : #testing }
CompiledMethod >> isConflict [
	^ self markerOrNil == self class conflictMarker
]

{ #category : #testing }
CompiledMethod >> isDeprecated [
	"Object selectorsInProtocol: #deprecation"
	self methodClass isDeprecated ifTrue: [ ^ true ].

	(self
		sendsAnySelectorOf:
			#(#deprecated: #deprecated:on:in: #deprecated:on:in:transformWith: #deprecated:transformWith:))
		ifTrue: [ ^ true ].
	$-
		split: self protocol asString
		do: [ :each | 
			each withBlanksCondensed = 'deprecated'
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #testing }
CompiledMethod >> isDisabled [
	^ self isDisabled: self markerOrNil
]

{ #category : #testing }
CompiledMethod >> isDisabled: marker [
	^ marker == self class disabledMarker
]

{ #category : #testing }
CompiledMethod >> isDoIt [
	^self selector isDoIt.
]

{ #category : #testing }
CompiledMethod >> isExplicitlyRequired [
	^ self isExplicitlyRequired: self markerOrNil
]

{ #category : #testing }
CompiledMethod >> isExplicitlyRequired: marker [
	^ marker == self class explicitRequirementMarker
]

{ #category : #testing }
CompiledMethod >> isFaulty [
 	"check if this method was compiled from syntactically wrong code"
	| ast |
	"fast pre-check: all methods with syntax errors reference this symbol"
  	(self refersToLiteral: #signalSyntaxError:) ifFalse: [ ^false].
	"we have to parse the ast here as #ast does not know that this needs optionParseErrors"
	ast := self methodClass compiler 
				source: self sourceCode;
				options: #(+ optionParseErrors);
				parse.
	^ ast isFaulty.
]

{ #category : #testing }
CompiledMethod >> isFromTrait [
	"Return true for methods that have been included from Traits"
	^ self origin isTrait and: [ self origin ~= self methodClass ]
]

{ #category : #testing }
CompiledMethod >> isInstalled [
	self methodClass ifNotNil:
		[:class|
		self selector ifNotNil:
			[:selector|
			^self == (class compiledMethodAt: selector ifAbsent: nil)]].
	^false
]

{ #category : #testing }
CompiledMethod >> isOverridden [
	| selector| 
	selector := self selector.
	self methodClass allSubclassesDo: [:each | 
		(each includesSelector: selector)
			ifTrue: [ ^ true ]].
	^ false
	
]

{ #category : #testing }
CompiledMethod >> isProvided [
	^ self isProvided: self markerOrNil
]

{ #category : #testing }
CompiledMethod >> isProvided: marker [
	marker ifNil: [^ true].
	^ (self isRequired: marker) not and: [(self isDisabled: marker) not]
]

{ #category : #testing }
CompiledMethod >> isRequired [
	"A method is required if it is a method declaring a subclass responsibility or an explicit requirement. This mean the method needs to be overriden (in case of subclass reponsibility) or implemented (in case of explicit requirement)."

	^ self isRequired: self markerOrNil
]

{ #category : #testing }
CompiledMethod >> isRequired: marker [
	marker ifNil: [^ false].
	(self isExplicitlyRequired: marker) ifTrue: [^ true]. 
	(self isSubclassResponsibility: marker) ifTrue: [^ true]. 
	^ false
]

{ #category : #testing }
CompiledMethod >> isReturnField [
	"Answer whether the receiver is a quick return of an instance variable."
	^ self primitive between: 264 and: 519
]

{ #category : #testing }
CompiledMethod >> isReturnSpecial [
	"Answer whether the receiver is a quick return of self or constant."

	^ self primitive between: 256 and: 263
]

{ #category : #printing }
CompiledMethod >> isSelfEvaluating [

	^self methodClass notNil and: [self isDoIt not]
]

{ #category : #testing }
CompiledMethod >> isSubclassResponsibility [
	^ self isSubclassResponsibility: self markerOrNil
]

{ #category : #testing }
CompiledMethod >> isSubclassResponsibility: marker [
	^ marker == self class subclassResponsibilityMarker
]

{ #category : #testing }
CompiledMethod >> isTaggedWith: aSymbol [
	"Not methods tags implemented by protocols. Look #tags comment"
	^self protocol == aSymbol
]

{ #category : #'source code management' }
CompiledMethod >> linesOfCode [
	"An approximate measure of lines of code.
	Includes method's name and comments, but excludes empty lines."
	| lines |
	lines := 0.
	self sourceCode lineIndicesDo: [:start :endWithoutDelimiters :end |
		endWithoutDelimiters > start ifTrue: [lines := lines+1]].
	^lines
]

{ #category : #literals }
CompiledMethod >> literalsToSkip [

	^ 2
]

{ #category : #scanning }
CompiledMethod >> localReadsSelf [
	"methods that are compiled with FFI have a self in the source but not in the bytecode"
	^self isFFIMethod or: [ super localReadsSelf ]
]

{ #category : #lookup }
CompiledMethod >> lookupVar: aString [ 
	^self ast scope lookupVar: aString
]

{ #category : #private }
CompiledMethod >> markerOrNil [
	^ self encoderClass markerOrNilFor: self
]

{ #category : #accessing }
CompiledMethod >> method [
	"polymorphic with closure"

	^ self
]

{ #category : #accessing }
CompiledMethod >> methodClass [
	"answer the class that I am installed in"
	^self classBinding value
]

{ #category : #accessing }
CompiledMethod >> methodClass: aClass [
	"set the class binding in the last literal to aClass"
	^self numLiterals > 0
		ifTrue: [ self literalAt: self numLiterals put: aClass binding ]	
]

{ #category : #accessing }
CompiledMethod >> name [
	^ self printString
]

{ #category : #private }
CompiledMethod >> penultimateLiteral [
	"Answer the penultimate literal of the receiver, which holds either
	 the receiver's selector or its properties (which will hold the selector)."
	| pIndex |
	^(pIndex := self numLiterals - 1) > 0 
		ifTrue: [self literalAt: pIndex]
		ifFalse: [nil]
]

{ #category : #private }
CompiledMethod >> penultimateLiteral: anObject [
	"Answer the penultimate literal of the receiver, which holds either
	 the receiver's selector or its properties (which will hold the selector)."
	| pIndex |
	(pIndex := self numLiterals - 1) > 0 
		ifTrue: [self literalAt: pIndex put: anObject]
		ifFalse: [self error: 'insufficient literals']
]

{ #category : #copying }
CompiledMethod >> postCopy [
	| penultimateLiteral |
	(penultimateLiteral := self penultimateLiteral) isMethodProperties ifTrue:
		[self penultimateLiteral: (penultimateLiteral copy
									method: self;
									yourself).
		 self penultimateLiteral pragmas do:
			[:p| p method: self]]

]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> pragmaAt: aKey [
	"Answer the first pragma with selector aKey, or nil if none."
	^ self pragmas detect: [ :pragma | pragma selector == aKey ] ifNone: nil
]

{ #category : #literals }
CompiledMethod >> pragmaRefersToLiteral: literal [

	^ self penultimateLiteral isMethodProperties and: [ 
		  self pragmas anySatisfy: [ :pragma | pragma refersToLiteral: literal ] ]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> pragmas [
	| selectorOrProperties |
	^(selectorOrProperties := self penultimateLiteral) isMethodProperties
		ifTrue: [selectorOrProperties pragmas]
		ifFalse: [#()]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> pragmasDo: aBlock [
	| selectorOrProperties |
	(selectorOrProperties := self penultimateLiteral) isMethodProperties
		ifTrue: [selectorOrProperties pragmasDo: aBlock]
]

{ #category : #'debugger support' }
CompiledMethod >> prepareForSimulationWith: numArgs [
	"This method changes the argument count of a CompiledMethod header to numArgs, its temporary count to numArgs + 1 and change the code handling primitive error to store the error code in the unique temporary of the method"
			
	| newHeader |
	newHeader := (((self header bitAnd: 2r01110000000000111111111111111111) 
			bitOr: (numArgs bitShift: 24))
			bitOr: (numArgs + 1 bitShift: 18)).
	newHeader := newHeader + (self class headerFlagForEncoder: self encoderClass).
	self objectAt: 1 put: newHeader.
	
	self encoderClass prepareMethod: self forSimulationWith: numArgs
]

{ #category : #accessing }
CompiledMethod >> primitive [
	"Answer the primitive index associated with the receiver.
	 Zero indicates that this is not a primitive method."
	| initialPC |
	^(self header anyMask: 65536) "Is the hasPrimitive? flag set?"
		ifTrue: [(self at: (initialPC := self initialPC) + 1) + ((self at: initialPC + 2) bitShift: 8)]
		ifFalse: [0]
]

{ #category : #printing }
CompiledMethod >> printOn: aStream [ 
	"Overrides method inherited from the byte arrayed collection."

	aStream print: self methodClass; nextPutAll: '>>'; print: self selector.
]

{ #category : #printing }
CompiledMethod >> printPrimitiveOn: aStream [
	"Print the primitive on aStream"
	| primDecl |
	self isPrimitive ifFalse: [ ^self ].

	self isExternalCallPrimitive ifTrue:
		[^aStream print: (self literalAt: 1); cr].
	aStream nextPutAll: '<primitive: '.
	self isNamedPrimitive
		ifTrue:
			[primDecl := self literalAt: 1.
			 (primDecl at: 2) asString printOn: aStream.
			 (primDecl at: 1) ifNotNil:
				[:moduleName|
				aStream nextPutAll:' module: '.
				moduleName asString printOn: aStream]]
		ifFalse:
			[aStream print: self primitive].
	self primitiveErrorVariableName ifNotNil:
		[:primitiveErrorVariableName|
		 aStream nextPutAll: ' error: '; nextPutAll: primitiveErrorVariableName].
	aStream nextPut: $>; cr
]

{ #category : #accessing }
CompiledMethod >> properties [
	"Answer the method properties of the receiver."
	| propertiesOrSelector |
	^(propertiesOrSelector := self penultimateLiteral) isMethodProperties
		ifTrue: [propertiesOrSelector]
		ifFalse: [self class methodPropertiesClass forMethod: self selector: propertiesOrSelector]
]

{ #category : #accessing }
CompiledMethod >> properties: aMethodProperties [
	"Set the method-properties of the receiver to aMethodProperties."
	self literalAt: self numLiterals - 1
		put: (aMethodProperties isEmpty
				ifTrue: [aMethodProperties selector]
				ifFalse: [aMethodProperties
							setMethod: self;
							yourself])
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> propertyAt: propName [
	| propertiesOrSelector |
	^(propertiesOrSelector := self penultimateLiteral) isMethodProperties
		ifTrue: [propertiesOrSelector propertyAt: propName ifAbsent: [nil]]
		ifFalse: [nil]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> propertyAt: propName ifAbsent: aBlock [
	| propertiesOrSelector |
	^(propertiesOrSelector := self penultimateLiteral) isMethodProperties
		ifTrue: [propertiesOrSelector propertyAt: propName ifAbsent: aBlock]
		ifFalse: [aBlock value]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> propertyAt: aKey ifAbsentPut: aBlock [
	"Answer the property associated with aKey or, if aKey isn't found store the result of evaluating aBlock as new value."
	
	^ self propertyAt: aKey ifAbsent: [ self propertyAt: aKey put: aBlock value ]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> propertyAt: propName put: propValue [
	"Set or add the property with key propName and value propValue.
	 If the receiver does not yet have a method properties create one and replace
	 the selector with it.  Otherwise, either relace propValue in the method properties
	 or replace method properties with one containing the new property."
	| propertiesOrSelector |
	(propertiesOrSelector := self penultimateLiteral) isMethodProperties ifFalse:
		[self penultimateLiteral: ((self class methodPropertiesClass
									selector: propertiesOrSelector
									with: (Association
											key: propName asSymbol
											value: propValue))
									setMethod: self;
									yourself).
		^propValue].
	(propertiesOrSelector includesProperty: propName) ifTrue:
		[^propertiesOrSelector at: propName put: propValue].
	self penultimateLiteral: (propertiesOrSelector
								copyWith: (Association
												key: propName asSymbol
												value: propValue)).
	^propValue
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> propertyKeysAndValuesDo: aBlock [
	"Enumerate the receiver with all the keys and values."

	| propertiesOrSelector |
	(propertiesOrSelector := self penultimateLiteral) isMethodProperties ifTrue:
		[propertiesOrSelector propertyKeysAndValuesDo: aBlock]
]

{ #category : #accessing }
CompiledMethod >> protocol [
	"Return in which protocol (conceptual groups of methods) the receiver is grouped into."

	^ self category
]

{ #category : #accessing }
CompiledMethod >> protocol: aString [
	^ self methodClass organization classify: self selector under: aString
]

{ #category : #scanning }
CompiledMethod >> readsField: varIndex [ 
	"Answer whether the receiver loads the instance variable indexed by the argument."
	self isReturnField ifTrue: [^self returnField = (varIndex - 1)].
	^ super readsField: varIndex 
]

{ #category : #literals }
CompiledMethod >> refersToLiteral: aLiteral [
	"Answer true if any literal in this method is literal, even if embedded in array structure."
	
	^(self pragmaRefersToLiteral: aLiteral) or: [ super refersToLiteral: aLiteral]
]

{ #category : #initialization }
CompiledMethod >> removeFromSystem [
	^ self methodClass removeSelector: self selector
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> removeProperty: propName [
	"Remove the property propName if it exists.
	 Do _not_ raise an error if the property is missing."
	| value |
	value := self propertyAt: propName ifAbsent: [^nil].
	self penultimateLiteral: (self penultimateLiteral copyWithout:
									(Association
										key: propName
										value: value)).
	^value
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> removeProperty: propName ifAbsent: aBlock [
	"Remove the property propName if it exists.
	 Answer the evaluation of aBlock if the property is missing."
	| value |
	value := self propertyAt: propName ifAbsent: [^aBlock value].
	self penultimateLiteral: (self penultimateLiteral copyWithout:
									(Association
										key: propName
										value: value)).
	^value
]

{ #category : #accessing }
CompiledMethod >> returnField [
	"Answer the index of the instance variable returned by a quick return 
	method."
	| prim |
	prim := self primitive.
	prim < 264
		ifTrue: [self error: 'only meaningful for quick-return']
		ifFalse: [^ prim - 264]
]

{ #category : #accessing }
CompiledMethod >> selector [
	"Answer a method's selector.  This is either the penultimate literal,
	 or, if the method has any properties or pragmas, the selector of
	 the MethodProperties stored in the penultimate literal."
	| penultimateLiteral | 
	^(penultimateLiteral := self penultimateLiteral) isMethodProperties
		ifTrue: [penultimateLiteral selector]
		ifFalse: [penultimateLiteral]
]

{ #category : #accessing }
CompiledMethod >> selector: aSelector [
	"Set a method's selector.  This is either the penultimate literal,
	 or, if the method has any properties or pragmas, the selector of
	 the MethodProperties stored in the penultimate literal."
	| penultimateLiteral nl | 
	Symbol internSelector:  aSelector.
	(penultimateLiteral := self penultimateLiteral) isMethodProperties
		ifTrue: [penultimateLiteral selector: aSelector]
		ifFalse: [(nl := self numLiterals) < 2 ifTrue:
					[self error: 'insufficient literals to hold selector'].
				self literalAt: nl - 1 put: aSelector]
]

{ #category : #'source code management' }
CompiledMethod >> setSourcePointer: srcPointer [
	"We can't change the trailer of existing method, since it could have completely different format. 	
	Therefore we need to generate a copy with new trailer, containing scrPointer, and then become it."

	| trailer copy |
	trailer := CompiledMethodTrailer new sourcePointer: srcPointer.
	copy := self copyWithTrailerBytes: trailer.
	"If possible do a replace in place as an optimization"
	(self trailer class == trailer class and: [ self size = copy size ])
		ifTrue: [ 
			| start |
			start := self endPC + 1.
			self replaceFrom: start to: self size with: copy startingAt: start ]
		ifFalse: [ self becomeForward: copy ].
	^ self

]

{ #category : #accessing }
CompiledMethod >> sourceCode [
	"Retrieve or reconstruct the source code for this method."

	| trailer |
	trailer := self trailer.
	trailer sourceCode ifNotNil: [:code | ^ code ].
	trailer hasSourcePointer ifFalse: [ ^ self codeForNoSource ].

	^ self getSourceFromFile ifEmpty: [ self codeForNoSource ]
]

{ #category : #'source code management' }
CompiledMethod >> sourcePointer [
	"Answer the integer which can be used to find the source file and position for this method.
	The actual interpretation of this number is up to the SourceFileArray stored in the global variable SourceFiles."

	^ self trailer sourcePointer

]

{ #category : #'debugger support' }
CompiledMethod >> stepIntoQuickMethods: aBoolean [
	^self propertyAt: #stepIntoQuickMethod put: aBoolean
]

{ #category : #printing }
CompiledMethod >> storeOn: aStream [
	| noneYet |
	aStream nextPutAll: '(('.
	aStream nextPutAll: self class name.
	aStream nextPutAll: ' newMethod: '.
	aStream store: self size - self initialPC + 1.
	aStream nextPutAll: ' header: '.
	aStream store: self header.
	aStream nextPut: $).
	noneYet := self storeElementsFrom: self initialPC to: self endPC on: aStream.
	1 to: self numLiterals do:
		[:index |
		noneYet
			ifTrue: [noneYet := false]
			ifFalse: [aStream nextPut: $;].
		aStream nextPutAll: ' literalAt: '.
		aStream store: index.
		aStream nextPutAll: ' put: '.
		aStream store: (self literalAt: index)].
	noneYet ifFalse: [aStream nextPutAll: '; yourself'].
	aStream nextPut: $)
]

{ #category : #'accessing-tags' }
CompiledMethod >> tagWith: aSymbol [
	"Any method could be tagged with multiple symbols for user purpose. 
	This method should apply new tag. All existing tags should not be changed. 
	But now we could only implemented tags with protocols. 	
	So tagging method with tag removes all existing tags and add new one. 
	It should not be problem with single tag scenario which are now defined by single protocol"
	
	self protocol: aSymbol
]

{ #category : #'accessing-tags' }
CompiledMethod >> tags [
	"Any method could be tagged with multiple symbols for user purpose. 
	For now we only define API to manage them implemented on top of method protocols.
	Protocol unclassified means that method is not tagged by anything"
	| protocol |
	protocol := self protocol.
	protocol ifNil: [ ^#() ].
	protocol = Protocol unclassified ifTrue: [ ^#() ].
	^{protocol}
]

{ #category : #'source code management' }
CompiledMethod >> tempNames [
	"on the level of the compiled method, tempNames includes argument names"
	^self ast argumentNames, self ast temporaryNames
]

{ #category : #accessing }
CompiledMethod >> trailer [
	"Answer the receiver's trailer"
	^ CompiledMethodTrailer new method: self
]

{ #category : #'accessing-tags' }
CompiledMethod >> untagFrom: aSymbol [
	"Any method could be tagged with multiple symbols for user purpose. 
	This method should remove given tag from it. All other tags should not be changed. 
	But now we could implemented tags with protocols which allow only tag for method.
	And to remove tag from method we must change it protocol to Protocol unclassified"
	self protocol = aSymbol ifTrue: [ 
		self protocol: Protocol unclassified]
]

{ #category : #testing }
CompiledMethod >> usesUndeclareds [
	"this is mixing Undeclareds and Obsoletes, maybe we should have two methods"	
	self withAllNestedLiteralsDo: [ :literal | 
		literal class == UndeclaredVariable ifTrue: [ ^ true ].
		(literal isBlock not and: [ 
			 literal value isBehavior and: [ literal value isObsolete ] ]) 
			ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #evaluating }
CompiledMethod >> valueWithReceiver: aReceiver arguments: anArray [ 
	"This should be changed when all the VM will support passign of extra arguments
		^self receiver: aReceiver withArguments: anArray executeMethod: self"
	
	^ aReceiver withArgs: anArray executeMethod: self
]

{ #category : #copying }
CompiledMethod >> veryDeepCopyWith: deepCopier [
	"Return self.  I am always shared.  Do not record me.  Only use this for blocks.  Normally methodDictionaries should not be copied this way."
]

{ #category : #scanning }
CompiledMethod >> writesField: varIndex [
	"Answer whether the receiver stores into the instance variable indexed by the argument."
	self isQuick ifTrue: [^false].
	^ super writesField: varIndex
]
