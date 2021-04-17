"
Specific version of compiled code for block's.

CompiledBlock are used only in the recent BlockClosure implementation by Eliot Miranda and Clement Bera, also known as FullBlockClosure. This new representation makes possible heavier runtime optimisations while simplifying a lot of code, both image-side and VM-side.

In addition the execution mechanics, a compiled block have an extra optional literal. The last literal is the compiled code referring to the compiled block. 



"
Class {
	#name : #CompiledBlock,
	#superclass : #CompiledCode,
	#type : #compiledMethod,
	#category : #'Kernel-Methods'
}

{ #category : #printing }
CompiledBlock >> displayStringOn: stream [
	self printOn: stream
]

{ #category : #accessing }
CompiledBlock >> endPC [
	"Answer the index of the last bytecode."
	^ self size
]

{ #category : #scanning }
CompiledBlock >> hasMethodReturn [
	"Answer whether the receiver has a method-return ('^') in its code."
	^ (InstructionStream on: self) scanFor: [:byte | 
		 self encoderClass methodReturnBytecodes includes: byte]
]

{ #category : #testing }
CompiledBlock >> hasPragmaNamed: aSymbol [
	^ false
]

{ #category : #properties }
CompiledBlock >> hasProperty: aString [ 
	
	^ false
]

{ #category : #testing }
CompiledBlock >> hasSourceCode [
	^ self method hasSourceCode
]

{ #category : #comparing }
CompiledBlock >> hash [
	"CompiledMethod>>#= compares code, i.e. same literals and same bytecode.
	 So we look at the header, methodClass and some bytes between initialPC and endPC,
	 but /not/ the selector because the equal method does not compare selectors.
	 Note that we must override ByteArray>hash which looks at all bytes of the receiver.
	 Using bytes from the pointer part of a COmpiledmethod can lead to a variable hash
	 if and when when the GC moves literals in the receiver."
	| initialPC endPC hash |
	initialPC := self initialPC.
	endPC := self endPC.
	hash := self species hash + self header + initialPC + endPC.
	"sample approximately 20 bytes"
	initialPC to: endPC by: (endPC - initialPC // 20 max: 1) do:
		[:i| hash := hash + (self at: i)].
	^hash

	"(CompiledMethod>>#hash) hash"

]

{ #category : #testing }
CompiledBlock >> isCompiledBlock [
	^ true
]

{ #category : #testing }
CompiledBlock >> isEmbeddedBlock [
	^ true
]

{ #category : #testing }
CompiledBlock >> isInstalled [
	
	^ self method isInstalled
]

{ #category : #testing }
CompiledBlock >> isTestMethod [
	^ false
]

{ #category : #literals }
CompiledBlock >> literalsToSkip [

	^ 1
]

{ #category : #accessing }
CompiledBlock >> method [
	"answer the compiled method that I am installed in, or nil if none."
	^self outerCode method
]

{ #category : #accessing }
CompiledBlock >> methodClass [
	"answer the compiled method that I am installed in, or nil if none."
	^self outerCode methodClass
]

{ #category : #accessing }
CompiledBlock >> methodNode [
	^ self outerCode methodNode
]

{ #category : #accessing }
CompiledBlock >> outerCode [
	"answer the compiled code that I am installed in, or nil if none."
	^self literalAt: self numLiterals
]

{ #category : #accessing }
CompiledBlock >> outerCode: aCompiledCode [
	^self literalAt: self numLiterals put: aCompiledCode
]

{ #category : #accessing }
CompiledBlock >> pragmas [
	^ #()
]

{ #category : #accessing }
CompiledBlock >> primitive [
	^ 0
]

{ #category : #printing }
CompiledBlock >> printOn: anStream [
	
	anStream 
		nextPutAll: 'a CompiledBlock: ';
		nextPutAll: self sourceNode sourceCode 
]

{ #category : #compatibility }
CompiledBlock >> properties [
	^ nil->nil
]

{ #category : #properties }
CompiledBlock >> propertyAt: aString [ 
	
	^ nil
]

{ #category : #comparing }
CompiledBlock >> sameLiteralsAs: method [
	"Compare my literals to those of method. This is needed to compare compiled methods."

	| numLits literal1 literal2 |
	(numLits := self numLiterals) ~= method numLiterals
		ifTrue: [ ^ false ].
	"The last literal requires special checking instead of using #literalEqual:"
	1 to: numLits - 1 do: [ :index | 
		literal1 := self literalAt: index.
		literal2 := method literalAt: index.
		(literal1 == literal2 or: [ literal1 literalEqual: literal2 ])
			ifFalse: [ ^ false ] ].
	"we can't do = on outer code or it will recursively call this code"
	^ true
]

{ #category : #accessing }
CompiledBlock >> selector [
	^ self outerCode selector
]

{ #category : #accessing }
CompiledBlock >> sourceCode [
	^ self outerCode sourceCode
]

{ #category : #'source code management' }
CompiledBlock >> sourcePointer [
	^self outerCode sourcePointer
]
