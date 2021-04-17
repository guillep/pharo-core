Extension { #name : #Behavior }

{ #category : #'*OpalCompiler-Core' }
Behavior >> allTemps [
	^#()
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> compile: code [ 
	"Compile the argument, code, as source code in the context of the 
	receiver. Create an error notification if the code can not be compiled. 
	The argument is either a string or an object that converts to a string or a 
	PositionableStream on an object that converts to a string."

	^self compile: code notifying: nil
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> compile: code notifying: requestor [ 
	"Compile the argument, code, as source code in the context of the 
	receiver and insEtall the result in the receiver's method dictionary. The 
	second argument, requestor, is to be notified if an error occurs. The 
	argument code is either a string or an object that converts to a string or 
	a PositionableStream. This method also saves the source code."
	
	| method |
	method  := self compiler
		source: code;
		requestor: requestor;
		failBlock: [ ^nil ];
		compile.
		
	method putSource: code
			withPreamble: [:f | f cr; nextPut: $!; nextChunkPut: 'Behavior method'; cr].
	self addSelector: method selector withMethod: method.
	^ method selector
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> compileAll [
	^ self compileAllFrom: self
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> compileAllFrom: oldClass [
	"Compile all the methods in the receiver's method dictionary.
	This validates sourceCode and variable references and forces
	all methods to use the current bytecode set"
	oldClass localSelectors do: [:sel | self recompile: sel from: oldClass].
	
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> compiler [
	"Answer a compiler appropriate for source methods of this class."

	^self compilerClass new
		environment: self environment;
		class: self
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> compilerClass [
	"Answer a compiler class appropriate for source methods of this class."

	^Smalltalk compilerClass
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> evaluate: aString [
	^self compiler evaluate: aString
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> lookupVar: aName [
	^ self classLayout 
		resolveSlot: aName asSymbol 
		ifFound: [:var | var] 
		ifNone: [self bindingOf: aName]
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> lookupVarForDeclaration: name [
	"This is a version of #lookupVar: that skips the OCRequestorScope, from here on it is the same as lookupVar:"
	^ self lookupVar: name
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> outerScope [
	^self environment
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> recompile [
	self compileAll
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> recompile: selector [
	"Compile the method associated with selector in the receiver's method dictionary."
	^self recompile: selector from: self
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> recompile: selector from: oldClass [
	"Compile the method associated with selector in the receiver's method dictionary."

	| method newMethod |
	method := oldClass compiledMethodAt: selector.
	newMethod := self compiler
				source: (oldClass sourceCodeAt: selector);
				class: self;
				failBlock: [^ self];
				compiledMethodTrailer: method trailer;
				compile.   "Assume OK after proceed from SyntaxError"
	selector == newMethod selector ifFalse: [self error: 'selector changed!'].
	self addSelector: selector withRecompiledMethod: newMethod.
]

{ #category : #'*OpalCompiler-Core' }
Behavior >> scopeLevel [
	"For debugging we print a counter for all scopes, starting from the Method as 1, so we are 0"
	^ 0
]
