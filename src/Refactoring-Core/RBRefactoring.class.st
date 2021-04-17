"
I am the abstract base class for refactoring operations. 

I define the common workflow for a refactoring:
check precondition, 
primitive execute - a dry run collecting the changes without applying them,
and execute - run and apply changes.

I provide many utility methods used by my subclasses. 
Every  concrete subclass implements a single refactoring. They have to implement the methods
preconditions and transform.


Instance Variables

options:
Some refactorings may need user interactions or some extra data for performing
the operation, the code for requesting this data is stored in a block associated with a ""refacotring option""
(see RBRefactoring>>#setOption:toUse:  and RBRefactoring class>>#initializeRefactoringOptions).

model:
My model - a RBNamespace - defines the environment in which my refactoring is applied and collects all changes (RBRefactoryChange).

A RBRefactoringManager  is used to collect the executed refactorings and provides an undo and redo facility.

"
Class {
	#name : #RBRefactoring,
	#superclass : #Object,
	#instVars : [
		'model',
		'options'
	],
	#classVars : [
		'RefactoringOptions'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #cleaning }
RBRefactoring class >> cleanUp [
	"RefactoringOptions holds on to blocks, we should make sure to recreate them so the block references the current method"
	self initializeRefactoringOptions.
]

{ #category : #initialization }
RBRefactoring class >> initialize [
	self initializeRefactoringOptions
]

{ #category : #initialization }
RBRefactoring class >> initializeRefactoringOptions [
	RefactoringOptions := IdentityDictionary new.
	RefactoringOptions
		at: #implementorToInline
		put: [ :ref :imps | self error: #implementorToInline ];
		
		at: #methodName
		put: [ :ref :methodName | self error: #methodName ];
		
		at: #selfArgumentName
		put: [ :ref | self error: #selfArgumentName ];
		
		at: #selectVariableToMoveTo
		put: [ :ref :class :selector | self error: #selectVariableToMoveTo ];	
			
		at: #variableTypes
		put: [ :ref :types :selected | self error: #variableTypes ];
		
		at: #extractAssignment
		put: [ :ref :varName | self error: #extractAssignment ];
		
		at: #inlineExpression
		put: [ :ref :string | self error: #inlineExpression ];
		
		at: #alreadyDefined
		put: [ :ref :cls :selector |  self error: #alreadyDefined ];
		
		at: #useExistingMethod
		put: [ :ref :selector |  self error: #useExistingMethod ];
		
		at: #openBrowser
		put: [ :ref :env |  self error: #openBrowser ];
		
		at: #searchInWholeHierarchy
		put: [ self error: #searchInWholeHierarchy ]
]

{ #category : #'accessing signal' }
RBRefactoring class >> preconditionSignal [
	^ RBRefactoringError , RBRefactoringWarning
]

{ #category : #accessing }
RBRefactoring class >> refactoringOptions [
	^ RefactoringOptions
]

{ #category : #accessing }
RBRefactoring class >> setDefaultOption: aSymbol to: aBlock [ 
	self refactoringOptions at: aSymbol put: aBlock
]

{ #category : #utilities }
RBRefactoring >> associationForClassVariable: aName in: aClass ifAbsent: aBlock [
	"Return the class variable association of class aClass"
	 
	^aClass realClass classPool associationAt: aName asSymbol
		ifAbsent: [aClass realClass classPool associationAt: aName asString ifAbsent: aBlock]
]

{ #category : #testing }
RBRefactoring >> canReferenceVariable: aString in: aClass [ 
	(aClass definesVariable: aString) ifTrue: [^true].
	(self model includesGlobal: aString asSymbol) ifTrue: [^true].
	^(self poolVariableNamesFor: aClass) includes: aString
]

{ #category : #accessing }
RBRefactoring >> changes [
	^self model changes
]

{ #category : #support }
RBRefactoring >> checkClass: aRBClass selector: aSelector using: aMatcher [ 
	| parseTree |
	parseTree := aRBClass parseTreeFor: aSelector.
	parseTree ifNotNil: [aMatcher executeTree: parseTree].
	^aMatcher answer
]

{ #category : #utilities }
RBRefactoring >> checkInstanceVariableName: aName in: aClass [ 
	^RBCondition checkInstanceVariableName: aName in: aClass
]

{ #category : #utilities }
RBRefactoring >> checkMethodName: aName in: aClass [ 
	^RBCondition checkMethodName: aName in: aClass
]

{ #category : #preconditions }
RBRefactoring >> checkPreconditions [
	| conditions block |
	conditions := self preconditions.
	conditions check
		ifFalse: [ block := conditions errorBlock.
			block
				ifNotNil: [ self refactoringError: conditions errorString with: block ]
				ifNil: [ self refactoringError: conditions errorString ] ]
]

{ #category : #private }
RBRefactoring >> classObjectFor: anObject [ 
	(anObject isBehavior or: [anObject isTrait]) ifTrue: [^self model classFor: anObject].
	anObject isSymbol ifTrue: [^self model classNamed: anObject].
	^anObject
]

{ #category : #support }
RBRefactoring >> convertAllReferencesTo: aSymbol of: classes using: searchReplacer [ 
	(self model allReferencesTo: aSymbol in: classes)
		do: 
			[:method | 
			self 
				convertMethod: method selector
				for: method modelClass
				using: searchReplacer]
]

{ #category : #support }
RBRefactoring >> convertAllReferencesTo: aSymbol using: searchReplacer [ 
	|aBlock|
	aBlock := [:method | 
			self 
				convertMethod: method selector
				for: method modelClass
				using: searchReplacer].
	self model allReferencesTo: aSymbol do: aBlock
]

{ #category : #support }
RBRefactoring >> convertAllReferencesToClass: aRBClass using: searchReplacer [ 
	self model allReferencesToClass: aRBClass
		do: 
			[:method | 
			self 
				convertMethod: method selector
				for: method modelClass
				using: searchReplacer]
]

{ #category : #support }
RBRefactoring >> convertClasses: classSet select: aBlock using: searchReplacer [ 
	classSet do: 
			[:aClass | 
			(aBlock value: aClass) do: 
					[:selector | 
					self 
						convertMethod: selector
						for: aClass
						using: searchReplacer]]
]

{ #category : #support }
RBRefactoring >> convertMethod: selector for: aClass using: searchReplacer [

	"Convert the parse tree for selector using the searchReplacer. If a
	change is made then compile it into the changeBuilder."

	| parseTree |

	parseTree := aClass parseTreeFor: selector.
	parseTree ifNil: [ ^ self ].
	( searchReplacer executeTree: parseTree )
		ifTrue: [ aClass compileTree: searchReplacer tree ]
]

{ #category : #accessing }
RBRefactoring >> copyOptionsFrom: aDictionary [ 
	| dict |
	dict := self options.
	dict == self class refactoringOptions 
		ifTrue: [^self options: aDictionary copy].
	dict keysAndValuesDo: 
			[:key :value | 
			value == (self class refactoringOptions at: key ifAbsent: [nil]) 
				ifTrue: [ dict at: key put: (aDictionary at: key) ]].
	(aDictionary keys difference: dict keys) do: 
		[ :e | dict at: e put: (aDictionary at: e) ].
	self options: dict
]

{ #category : #transforming }
RBRefactoring >> defaultEnvironment [
	^RBBrowserEnvironment new
]

{ #category : #utilities }
RBRefactoring >> emptyCondition [
	^ RBCondition empty
]

{ #category : #transforming }
RBRefactoring >> execute [
	self primitiveExecute.
	RBRefactoryChangeManager instance 
		performChange: self changes; 
		addUndoPointer: (RBRefactoryChangeManager nextCounter)
]

{ #category : #transforming }
RBRefactoring >> model [

	^ model
		ifNil: [ model := ( RBClassModelFactory rbNamespace onEnvironment: self defaultEnvironment )
				name: self printString;
				yourself
			]
		ifNotNil: [ model ]
]

{ #category : #initialization }
RBRefactoring >> model: aRBNamespace [ 
	model := aRBNamespace
]

{ #category : #private }
RBRefactoring >> onError: aBlock do: errorBlock [ 
	^aBlock on: self class preconditionSignal
		do: 
			[:ex | 
			errorBlock value.
			ex return: nil]
]

{ #category : #requests }
RBRefactoring >> openBrowserOn: anEnvironment [ 
	^(self options at: #openBrowser) value: self value: anEnvironment
]

{ #category : #accessing }
RBRefactoring >> options [

	^ options ifNil: [ self class refactoringOptions ] ifNotNil: [ options ]
]

{ #category : #accessing }
RBRefactoring >> options: aDictionary [ 
	options := aDictionary
]

{ #category : #parsing }
RBRefactoring >> parseTreeRewriter [
	^ self parseTreeRewriterClass new
]

{ #category : #parsing }
RBRefactoring >> parseTreeRewriterClass [
	^ RBParseTreeRewriter
]

{ #category : #utilities }
RBRefactoring >> parseTreeSearcher [
	^ self parseTreeSearcherClass new
]

{ #category : #transforming }
RBRefactoring >> parseTreeSearcherClass [
	^ RBParseTreeSearcher
]

{ #category : #refactoring }
RBRefactoring >> parserClass [
	^ RBParser
]

{ #category : #transforming }
RBRefactoring >> performCompositeRefactoring: aRefactoring [ 
	aRefactoring copyOptionsFrom: self options.
	aRefactoring primitiveExecute
]

{ #category : #transforming }
RBRefactoring >> performCompositeRefactoringThroughWarning: aRefactoring [ 
	[ aRefactoring copyOptionsFrom: self options.
	aRefactoring primitiveExecute ]
	on: RBRefactoringError do: [ :ex | ex resume ]

	
]

{ #category : #utilities }
RBRefactoring >> poolVariableNamesFor: aClass [ 
	| pools |
	pools := Set new.
	aClass withAllSuperclasses do: 
			[:each | 
			each allPoolDictionaryNames do: 
					[:pool |
					pools addAll: (self poolVariableNamesIn: pool asSymbol) ] ].
	^pools
]

{ #category : #transforming }
RBRefactoring >> poolVariableNamesIn: poolName [ 
	^(model classNamed: poolName) classPool keys
]

{ #category : #preconditions }
RBRefactoring >> preconditions [
	self subclassResponsibility
]

{ #category : #private }
RBRefactoring >> primitiveExecute [
	self checkPreconditions.
	self transform
]

{ #category : #private }
RBRefactoring >> refactoringConfirmWarning: aString [
	| ret |
	ret := UIManager default confirm: aString orCancel: [ ^ RBRefactoringFailure signal: 'aborted' ].
	^ ret
]

{ #category : #private }
RBRefactoring >> refactoringError: aString [ 
	^ RBRefactoringError signal: aString
]

{ #category : #private }
RBRefactoring >> refactoringError: aString with: aBlock [ 
	^ RBRefactoringError signal: aString with: aBlock
]

{ #category : #private }
RBRefactoring >> refactoringFailure: aString [ 
	^ RBRefactoringFailure signal: aString
]

{ #category : #private }
RBRefactoring >> refactoringFailure: aString with: aBlock [
	^ RBRefactoringFailure signal: aString with: aBlock
]

{ #category : #private }
RBRefactoring >> refactoringWarning: aString [ 
	^ RBRefactoringWarning signal: aString
]

{ #category : #requests }
RBRefactoring >> requestImplementorToInline: implementorsCollection [ 
	^(self options at: #implementorToInline) value: self
		value: implementorsCollection
]

{ #category : #requests }
RBRefactoring >> requestMethodNameFor: aMethodName [ 
	^(self options at: #methodName) value: self value: aMethodName
]

{ #category : #requests }
RBRefactoring >> requestSelfArgumentName [
	^(self options at: #selfArgumentName) value: self
]

{ #category : #utilities }
RBRefactoring >> safeMethodNameFor: aClass basedOn: aString [ 
	"Creates an unused method name containing aString"

	| baseString newString hasParam i |
	baseString := aString copy.
	baseString at: 1 put: baseString first asLowercase.
	newString := baseString.
	hasParam := newString last = $:.
	hasParam 
		ifTrue: [baseString := newString copyFrom: 1 to: newString size - 1].
	i := 0.
	[aClass hierarchyDefinesMethod: newString asSymbol] whileTrue: 
			[i := i + 1.
			newString := baseString , i printString 
						, (hasParam ifTrue: [':'] ifFalse: [''])].
	^newString asSymbol
]

{ #category : #private }
RBRefactoring >> safeVariableNameFor: aClass temporaries: allTempVars basedOn: aString [
	| baseString i newString |
	newString := baseString := aString.
	i := 0.
	[ (allTempVars includes: newString) or: [ aClass definesInstanceVariable: newString ] ] 
		whileTrue: [ 
			i := i + 1.
			newString := baseString , i printString ].
	^ newString
]

{ #category : #requests }
RBRefactoring >> selectVariableToMoveMethodTo: aSelector class: aClass [ 
	^(self options at: #selectVariableToMoveTo) 
		value: self
		value: aClass
		value: aSelector
]

{ #category : #requests }
RBRefactoring >> selectVariableTypesFrom: initialTypeCollection selected: selectedTypeCollection [ 
	^ (self options at: #variableTypes) 
		value: self
		value: initialTypeCollection
		value: selectedTypeCollection

]

{ #category : #accessing }
RBRefactoring >> setOption: aSymbol toUse: aBlock [ 
	| dict |
	dict := self options.
	dict == self class refactoringOptions ifTrue: [dict := dict copy].
	dict at: aSymbol put: aBlock.
	self options: dict
]

{ #category : #requests }
RBRefactoring >> shouldExtractAssignmentTo: aString [ 
	^(self options at: #extractAssignment) value: self value: aString
]

{ #category : #requests }
RBRefactoring >> shouldInlineExpression: aString [ 
	^(self options at: #inlineExpression) value: self value: aString
]

{ #category : #requests }
RBRefactoring >> shouldOverride: aSelector in: aClass [ 
	^(self options at: #alreadyDefined) 
		value: self
		value: aClass
		value: aSelector
]

{ #category : #requests }
RBRefactoring >> shouldUseExistingMethod: aSelector [ 
	^(self options at: #useExistingMethod) value: self value: aSelector
]

{ #category : #transforming }
RBRefactoring >> transform [
	self subclassResponsibility
]

{ #category : #private }
RBRefactoring >> uniqueMethodNameFor: anInteger [ 
	| before after index name |
	before := 'a'.
	after := ''.
	anInteger timesRepeat: [after := after , 'z:'].
	index := 0.
	
	[name := before , index printString , after.
	(Symbol findInterned: name) notNil] 
			whileTrue: [index := index + 1].
	^name asSymbol
]

{ #category : #utilities }
RBRefactoring >> whichVariableNode: aParseTree inInterval: anInterval name: aName [
	| matcher block |
	matcher := self parseTreeSearcher.
	block := [ :aNode :answer | 
	(aNode intersectsInterval: anInterval)
		ifTrue: [ aNode ]
		ifFalse: [ answer ] ].
	matcher
		matches: aName do: block;
		matchesArgument: aName do: block.
	^ matcher executeTree: aParseTree initialAnswer: nil
]
