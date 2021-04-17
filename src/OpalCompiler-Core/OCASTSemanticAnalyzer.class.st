"
I visit each node in the abstract syntax tree while growing and shrinking a scope chain. Each method and block node is linked with its corresponding scope object, and each variable def and ref is linked with its corresponding OCVariable. Exceptions are raised for undefined variable references and so on (see subclasses of OCSemanticWarning).

"
Class {
	#name : #OCASTSemanticAnalyzer,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'scope',
		'blockcounter',
		'compilationContext'
	],
	#category : #'OpalCompiler-Core-Semantics'
}

{ #category : #variables }
OCASTSemanticAnalyzer >> analyseEscapingRead: var [
	var markRead.
	(var scope outerNotOptimizedScope ~= scope outerNotOptimizedScope ) ifFalse: [ ^self ].
	"only escaping when they will end up in different closures"
	var markEscapingRead.
	"if we read a variable in a loop that is a repeated write, it need to be marked as escaping write"	
	(scope isInsideOptimizedLoop and: [var isRepeatedWrite])
				ifTrue: [var markEscapingWrite]
]

{ #category : #variables }
OCASTSemanticAnalyzer >> analyseEscapingWrite: var [
	(var scope outerNotOptimizedScope ~= scope outerNotOptimizedScope) 
	"only escaping when they will end up in different closures"
			ifTrue: [ var markEscapingWrite].
	"if we write a variable in a loop, mark it as a repeated Write"	
	scope isInsideOptimizedLoop
					ifTrue: [ var markRepeatedWrite ]
					ifFalse: [ var markWrite ]
]

{ #category : #api }
OCASTSemanticAnalyzer >> analyze: aNode [
	self visitNode: aNode.
	OCASTClosureAnalyzer new visitNode: aNode.
	OCASTMethodMetadataAnalyser new visitNode: aNode
]

{ #category : #accessing }
OCASTSemanticAnalyzer >> blockcounter [
	^blockcounter ifNil: [0]
]

{ #category : #accessing }
OCASTSemanticAnalyzer >> compilationContext [
	^ compilationContext
]

{ #category : #accessing }
OCASTSemanticAnalyzer >> compilationContext: aCompilationContext [
	compilationContext := aCompilationContext
]

{ #category : #variables }
OCASTSemanticAnalyzer >> declareArgumentNode: aVariableNode [
	^self declareVariableNode: aVariableNode as: (ArgumentVariable named: aVariableNode name) 
]

{ #category : #variables }
OCASTSemanticAnalyzer >> declareTemporaryNode: aVariableNode [
	^self declareVariableNode: aVariableNode as: (TemporaryVariable named: aVariableNode name)
]

{ #category : #variables }
OCASTSemanticAnalyzer >> declareVariableNode: aVariableNode as: anOCTempVariable [
	| name var shadowing |
	name := aVariableNode name. 
	var := scope lookupVarForDeclaration: name.
	"check if another variable with same name is visible"
	var ifNotNil: [ shadowing := var].
	var := scope addTemp: anOCTempVariable.
	aVariableNode binding: var.
	shadowing ifNotNil: [self shadowingVariable: aVariableNode].
	^ var
]

{ #category : #variables }
OCASTSemanticAnalyzer >> lookupVariableForRead: aVariableNode [

	| var |
	
	var := scope lookupVar: aVariableNode name.
	
	var ifNil: [^var].
	var isLocalVariable ifTrue: [ self analyseEscapingRead: var].
	^var
]

{ #category : #variables }
OCASTSemanticAnalyzer >> lookupVariableForWrite: aVariableNode [

	| var |
	
	var := scope lookupVar: aVariableNode name.

	var ifNil: [^var].
	var isReservedVariable ifTrue: [ self storeIntoReservedVariable: aVariableNode ].
	var isWritable ifFalse: [ self storeIntoReadOnlyVariable: aVariableNode ].
	var isLocalVariable ifTrue: [ self analyseEscapingWrite: var ].
	^var
]

{ #category : #initialization }
OCASTSemanticAnalyzer >> scope: aSemScope [
	scope := aSemScope
]

{ #category : #'error handling' }
OCASTSemanticAnalyzer >> shadowingVariable: aNode [
	compilationContext optionSkipSemanticWarnings ifTrue: [ ^aNode ].
	^ OCShadowVariableWarning new
		node: aNode;
		compilationContext: compilationContext;
		signal
]

{ #category : #'error handling' }
OCASTSemanticAnalyzer >> storeIntoReadOnlyVariable: variableNode [
	compilationContext optionSkipSemanticWarnings ifTrue: [ ^ self ].
		
	^ OCStoreIntoReadOnlyVariableError new
		node: variableNode;
		compilationContext: compilationContext;
		messageText: 'Cannot store into';
		signal
]

{ #category : #'error handling' }
OCASTSemanticAnalyzer >> storeIntoReservedVariable: variableNode [
	compilationContext optionSkipSemanticWarnings ifTrue: [ ^ self ].
	^ OCStoreIntoReservedVariableError new
		node: variableNode;
		compilationContext: compilationContext;
		messageText: 'Cannot store into';
		signal
]

{ #category : #'error handling' }
OCASTSemanticAnalyzer >> undeclaredVariable: variableNode [
	compilationContext optionSkipSemanticWarnings
		ifTrue: [ ^UndeclaredVariable named: variableNode name asSymbol ].
	^ OCUndeclaredVariableWarning new
		node: variableNode;
		compilationContext: compilationContext;
		signal
]

{ #category : #'error handling' }
OCASTSemanticAnalyzer >> uninitializedVariable: variableNode [
	variableNode propertyAt: #semanticWarning put: #unitialized.
]

{ #category : #'error handling' }
OCASTSemanticAnalyzer >> unusedVariable: variableNode [

	variableNode propertyAt: #semanticWarning put: 'unused variable'
]

{ #category : #visiting }
OCASTSemanticAnalyzer >> visitAssignmentNode: anAssignmentNode [
	| var |
	self visitNode: anAssignmentNode value.
	var := (self lookupVariableForWrite: anAssignmentNode variable)
		ifNil: [ self undeclaredVariable: anAssignmentNode variable ].
	anAssignmentNode variable binding: var
]

{ #category : #visiting }
OCASTSemanticAnalyzer >> visitBlockNode: aBlockNode [
	blockcounter := self blockcounter + 1.

	aBlockNode isInlined ifTrue: [^ self visitInlinedBlockNode: aBlockNode ].	
	scope := scope newBlockScope: blockcounter. 
	aBlockNode scope: scope. scope node: aBlockNode.
	
	aBlockNode arguments do: [:node | self declareArgumentNode: node ].
	self visitNode: aBlockNode body.
	scope := scope popScope.
]

{ #category : #visiting }
OCASTSemanticAnalyzer >> visitInlinedBlockNode: aBlockNode [

	scope := scope newOptimizedBlockScope: blockcounter.
	aBlockNode isInlinedLoop ifTrue: [scope markInlinedLoop]. 
	aBlockNode scope: scope. scope node: aBlockNode.
	aBlockNode arguments do: [:node | self declareArgumentNode: node ].
	self visitNode: aBlockNode body.
	scope := scope popScope.
]

{ #category : #visiting }
OCASTSemanticAnalyzer >> visitMethodNode: aMethodNode [

	scope := OCMethodScope new outerScope: compilationContext scope.
	aMethodNode scope: scope.  scope node: aMethodNode.
	aMethodNode arguments do: [:node | self declareArgumentNode: node ].
	aMethodNode pragmas do: [:each | self visitNode: each].
	self visitNode: aMethodNode body.

]

{ #category : #visiting }
OCASTSemanticAnalyzer >> visitPragmaNode: aPragmaNode [

	| varNode |
	super visitPragmaNode: aPragmaNode.
	aPragmaNode selector = #compilerOptions: ifTrue: [ 
		aPragmaNode asPragma sendTo:
			aPragmaNode methodNode compilationContext ].
	
	"if the pragma is a primitive that defines an error variable, we need to declare a temp
	for it"	
	aPragmaNode isPrimitiveError ifFalse: [ ^ self ].
	varNode := RBVariableNode named: aPragmaNode primitiveErrorVariableName.
	self declareVariableNode: varNode as: (PrimitiveErrorVariable node: varNode).
]

{ #category : #visiting }
OCASTSemanticAnalyzer >> visitSequenceNode: aSequenceNode [
	
	aSequenceNode temporaries do: [ :node | self declareTemporaryNode: node ].
	aSequenceNode statements do: [ :each | self visitNode: each ].
	aSequenceNode temporaries reverseDo: [ :node | 
			node variable isUsed
				ifFalse: [ self unusedVariable: node ] ]
]

{ #category : #visiting }
OCASTSemanticAnalyzer >> visitVariableNode: aVariableNode [
	| var |
	var := (self lookupVariableForRead: aVariableNode) 
		ifNil: [(self undeclaredVariable: aVariableNode)].
	aVariableNode binding: var.
	var isUninitialized ifTrue: [self uninitializedVariable: aVariableNode].
]
