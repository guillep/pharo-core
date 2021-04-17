"
I am a refactoring for creating a method from a code fragment.

You can select an interval of some code in a method and call this refactoring to create a new method implementing that code and replace the code by calling this method instead. 
The new method needs to have as many arguments as the number of (temp)variables, the code refers to.

The preconditions are quite complex. The code needs to be parseable valid code. 
"
Class {
	#name : #RBExtractMethodRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'selector',
		'extractionInterval',
		'extractedParseTree',
		'modifiedParseTree',
		'parameters',
		'needsReturn',
		'parameterMap',
		'newExtractedSelector'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBExtractMethodRefactoring class >> extract: anInterval from: aSelector in: aClass [ 
	^self new
		extract: anInterval
		from: aSelector
		in: aClass
]

{ #category : #'instance creation' }
RBExtractMethodRefactoring class >> model: aRBSmalltalk extract: anInterval from: aSelector in: aClass [ 
	^(self new)
		model: aRBSmalltalk;
		extract: anInterval
			from: aSelector
			in: aClass;
		yourself
]

{ #category : #transforming }
RBExtractMethodRefactoring >> checkAssignments: variableNames [ 
	| node outsideVars removeAssigned |
	removeAssigned := variableNames copy.
	node := self placeholderNode.
	outsideVars := variableNames 
				select: [:each | (node whoDefines: each) references: each].
	outsideVars size == 1 
		ifTrue: [self checkSingleAssignment: outsideVars asArray first].
	outsideVars size > 1 
		ifTrue: 
			[self refactoringError: 'Cannot extract assignment without all references.'].
	removeAssigned removeAll: outsideVars.
	(RBReadBeforeWrittenTester readBeforeWritten: removeAssigned
		in: extractedParseTree) ifNotEmpty: 
			[self refactoringError: 'Cannot extract assignment if read before written.'].
	removeAssigned do: [:each | (node whoDefines: each) removeTemporaryNamed: each].
	self updateTemporariesInExtractedMethodFor: variableNames
]

{ #category : #transforming }
RBExtractMethodRefactoring >> checkReturn [
	needsReturn := self placeholderNode isUsed.
	extractedParseTree containsReturn ifFalse: [^self].
	extractedParseTree lastIsReturn ifTrue: [^self].
	(modifiedParseTree isLast: self placeholderNode) 
		ifFalse: 
			[self refactoringError: 'Couldn''t extract code since it contains a return.'].
	self checkSelfReturns
]

{ #category : #transforming }
RBExtractMethodRefactoring >> checkSelfReturns [
	| searcher |
	searcher := self parseTreeSearcher.
	searcher
		matches: '^self' do: [ :aNode :answer | answer ];
		matches: '^`@anything' do: [ :aNode :answer | true ].
	(searcher executeTree: extractedParseTree initialAnswer: false)
		ifTrue: [ self placeholderNode asReturn ]
]

{ #category : #transforming }
RBExtractMethodRefactoring >> checkSingleAssignment: varName [ 
	((RBReadBeforeWrittenTester isVariable: varName
		readBeforeWrittenIn: extractedParseTree) 
			or: [extractedParseTree containsReturn]) 
			ifTrue: 
				[self 
					refactoringError: 'Cannot extract assignments to temporaries without all references'].
	extractedParseTree 
		addNode: (RBReturnNode value: (RBVariableNode named: varName)).
	modifiedParseTree := self parseTreeRewriterClass 
				replace: self methodDelimiter
				with: varName , ' := ' , self methodDelimiter
				in: modifiedParseTree
]

{ #category : #transforming }
RBExtractMethodRefactoring >> checkSpecialExtractions [
	| node |
	node := self placeholderNode parent.
	node ifNil: [^self].
	(node isAssignment and: [node variable = self placeholderNode]) ifTrue: 
			[self refactoringFailure: 'Cannot extract left hand side of an assignment'].
	node isCascade ifTrue: 
			[self refactoringError: 'Cannot extract first message of a cascaded message']
]

{ #category : #transforming }
RBExtractMethodRefactoring >> checkTemporaries [
	| temps accesses assigned |
	temps := self remainingTemporaries.
	accesses := temps select: [:each | extractedParseTree references: each].
	assigned := accesses select: [:each | extractedParseTree assigns: each].
	assigned ifNotEmpty: [self checkAssignments: assigned].
	^parameters := (accesses asOrderedCollection)
				removeAll: assigned;
				yourself
]

{ #category : #transforming }
RBExtractMethodRefactoring >> compileExtractedMethod [

	| cls |
	self renameAllParameters.
	cls := self classObjectFor: self requestExtractionClass.
	^ cls
		  compile: extractedParseTree newSource
		  withAttributesFrom: (class methodFor: selector)
]

{ #category : #transforming }
RBExtractMethodRefactoring >> existingSelector [
	"Try to find an existing method instead of creating a new one"

	^ self requestExistingSelector
		ifNil: [ self selectorsToSearch
				detect: [ :each | self isMethodEquivalentTo: each ]
				ifNone: [ nil ] ]
]

{ #category : #initialization }
RBExtractMethodRefactoring >> extract: anInterval from: aSelector in: aClass [ 
	class := self classObjectFor: aClass.
	selector := aSelector.
	extractionInterval := anInterval
]

{ #category : #transforming }
RBExtractMethodRefactoring >> extractMethod [
	| parseTree isSequence extractCode subtree newCode errorMessage |
	extractCode := self getExtractedSource.
	extractedParseTree := self parserClass
		parseExpression: extractCode
		onError: [ :string :pos :parser | 
			errorMessage := string.
			parser parseErrorNode: string ].
	extractedParseTree
		ifNil: [ self refactoringFailure: 'Invalid source to extract' ].
	extractedParseTree isFaulty
		ifTrue: [ self
				refactoringFailure: 'Invalid source to extract - ' , errorMessage ].
	(extractedParseTree isSequence
		and: [ extractedParseTree statements isEmpty ])
		ifTrue: [ self refactoringError: 'Select some code to extract' ].
	isSequence := extractedParseTree isSequence
		or: [ extractedParseTree isReturn ].
	extractedParseTree := RBMethodNode
		selector: #value
		arguments: #()
		body:
			(extractedParseTree isSequence
				ifTrue: [ extractedParseTree ]
				ifFalse: [ RBSequenceNode
						temporaries: #()
						statements: (OrderedCollection with: extractedParseTree) ]).
	extractedParseTree body temporaries
		ifNotEmpty: [ extractedParseTree body temporaries: #() ].
	extractedParseTree source: extractCode.
	parseTree := class parseTreeFor: selector.
	parseTree
		ifNil: [ self refactoringFailure: 'Could not parse ' , selector printString ].
	subtree := isSequence
		ifTrue: [ self parseTreeSearcherClass
				treeMatchingStatements: extractedParseTree body formattedCode
				in: parseTree ]
		ifFalse:
			[ self parseTreeSearcherClass treeMatching: extractCode in: parseTree ].
	subtree
		ifNil: [ self refactoringFailure: 'Could not extract code from method' ].
	newCode := self methodDelimiter.
	isSequence
		ifTrue: [ | stmts |
			stmts := extractedParseTree body statements.
			stmts
				ifNotEmpty: [ stmts last isAssignment
						ifTrue: [ | name |
							name := stmts last variable name.
							(self shouldExtractAssignmentTo: name)
								ifFalse: [ newCode := '<1s> := <2s>' expandMacrosWith: name with: newCode.
									stmts at: stmts size put: stmts last value ] ] ] ].
	modifiedParseTree := isSequence
		ifTrue: [ self parseTreeRewriterClass
				replaceStatements: subtree formattedCode
				with: newCode
				in: parseTree
				onInterval: extractionInterval ]
		ifFalse: [ self parseTreeRewriterClass
				replace: subtree formattedCode
				with: newCode
				in: parseTree
				onInterval: extractionInterval ]
]

{ #category : #accessing }
RBExtractMethodRefactoring >> extractedParseTree [
	^ extractedParseTree
]

{ #category : #transforming }
RBExtractMethodRefactoring >> getExtractedSource [
	| source |
	source := class sourceCodeFor: selector.
	((extractionInterval first between: 1 and: (self startLimit: source size)) 
		and: [extractionInterval last between: 1 and: source size]) 
			ifFalse: [self refactoringFailure: 'Invalid interval'].
	^source copyFrom: extractionInterval first to: extractionInterval last
]

{ #category : #transforming }
RBExtractMethodRefactoring >> getNewMethodName [
	| newSelector methodName newMethodName |
	methodName := RBMethodName new.
	methodName arguments: parameters.
	
	[newMethodName := self requestMethodNameFor: methodName.
	newMethodName ifNil: [self refactoringFailure: 'Did not extract code'].
	newSelector := newMethodName selector.
	(self checkMethodName: newSelector in: class) 
		ifFalse: 
			[self refactoringWarning: newSelector , ' is not a valid selector name.'.
			newSelector := nil].
	(class hierarchyDefinesMethod: newSelector asSymbol) 
		ifTrue: 
			[(self shouldOverride: newSelector in: class) ifFalse: [ newSelector := nil ]].
	newSelector isNil] 
			whileTrue: [].
	parameters := newMethodName arguments asOrderedCollection.
	^newSelector asSymbol
]

{ #category : #transforming }
RBExtractMethodRefactoring >> isMethodEquivalentTo: aSelector [ 
	
	selector == aSelector ifTrue: [^false].
	
	aSelector numArgs ~~ parameters size ifTrue: [^false].
	
	(self isParseTreeEquivalentTo: aSelector) ifFalse: [^false].
	self reorderParametersToMatch: aSelector.
	^true
]

{ #category : #transforming }
RBExtractMethodRefactoring >> isParseTreeEquivalentTo: aSelector [ 
	| tree definingClass |
	definingClass := class whoDefinesMethod: aSelector.
	tree := definingClass parseTreeFor: aSelector.
	tree ifNil: [^false].
	tree isPrimitive ifTrue: [^false].
	(tree body equalTo: extractedParseTree body
		exceptForVariables: (tree arguments collect: [:each | each name])) 
			ifFalse: [^false].
	(definingClass = class or: 
			[(tree superMessages anySatisfy: 
					[:each | 
					(class superclass whichClassIncludesSelector: aSelector) 
						~= (definingClass superclass whichClassIncludesSelector: each)]) not]) 
		ifFalse: [^false].
	^self shouldUseExistingMethod: aSelector
]

{ #category : #accessing }
RBExtractMethodRefactoring >> method [ 
	^ class realClass >> selector
]

{ #category : #transforming }
RBExtractMethodRefactoring >> methodDelimiter [
	^'#''place.holder.for.method'''
]

{ #category : #transforming }
RBExtractMethodRefactoring >> nameNewMethod: aSymbol [
	| args newSend |
	newExtractedSelector := aSymbol .
	args := parameters collect: [ :parm | RBVariableNode named: parm ].
	extractedParseTree renameSelector: aSymbol andArguments: args asArray.
	aSymbol numArgs = 0
		ifTrue: [ modifiedParseTree := RBParseTreeRewriter replace: self methodDelimiter with: 'self ' , aSymbol asString in: modifiedParseTree.
			^ self ].
	newSend := String
		streamContents: [ :str | 
			str nextPutAll: 'self '.
			aSymbol keywords
				with: parameters
				do: [ :key :arg | 
					str
						nextPutAll: key asString;
						nextPut: $ ;
						nextPutAll: arg asString;
						nextPut: $  ] ].
	modifiedParseTree := RBParseTreeRewriter replace: self methodDelimiter with: newSend in: modifiedParseTree
]

{ #category : #transforming }
RBExtractMethodRefactoring >> newExtractedSelector [
	^ newExtractedSelector
]

{ #category : #accessing }
RBExtractMethodRefactoring >> parameterMap [
	^ parameterMap
]

{ #category : #accessing }
RBExtractMethodRefactoring >> parameterMap: aDictionary [
	parameterMap := aDictionary 
]

{ #category : #transforming }
RBExtractMethodRefactoring >> parameters: anOrderedCollection [
	parameters := anOrderedCollection 
]

{ #category : #transforming }
RBExtractMethodRefactoring >> placeholderNode [
	| node |
	node := self parseTreeSearcherClass
		treeMatching: self methodDelimiter
		in: modifiedParseTree.
	node ifNil: [ self refactoringFailure: 'Cannot extract code' ].
	^ node
]

{ #category : #preconditions }
RBExtractMethodRefactoring >> preconditions [
	^(RBCondition definesSelector: selector in: class) 
		& (RBCondition withBlock: 
					[self extractMethod.
					self checkSpecialExtractions.
					self checkReturn.
					needsReturn ifTrue: [extractedParseTree addReturn].
					self checkTemporaries.
					true])
]

{ #category : #transforming }
RBExtractMethodRefactoring >> remainingTemporaries [
	| temps |
	temps := modifiedParseTree allDefinedVariables asSet.
	extractedParseTree allDefinedVariables 
		do: [:each | temps remove: each ifAbsent: []].
	^temps
]

{ #category : #transforming }
RBExtractMethodRefactoring >> renameAllParameters [
	parameterMap ifNotNil: [
		parameterMap keysAndValuesDo: [ :key : value | 
			key ~= value ifTrue: [ self renameParameterWith: key to: value ]]
	]
]

{ #category : #renaming }
RBExtractMethodRefactoring >> renameNode: aParseTree withOldName: oldName toWithName: newName [ 
	(self parseTreeRewriterClass rename: oldName to: newName) executeTree: aParseTree
]

{ #category : #renaming }
RBExtractMethodRefactoring >> renameParameterWith: oldName to: newName [
	self renameNode: extractedParseTree withOldName: oldName toWithName: newName.
	
]

{ #category : #transforming }
RBExtractMethodRefactoring >> reorderParametersToMatch: aSelector [ 
	| tree dictionary |
	tree := class parseTreeFor: aSelector.
	dictionary := Dictionary new.
	tree body equalTo: extractedParseTree body withMapping: dictionary.
	parameters := tree arguments collect: 
					[:each | 
					dictionary at: each name
						ifAbsent: 
							[self 
								refactoringFailure: 'An internal error occured, please report this error.']]
]

{ #category : #transforming }
RBExtractMethodRefactoring >> requestExistingSelector [ 
	^ [(self options at: #existingSelector) value: self]
			on: Exception 
			do: [ :e | nil ]
]

{ #category : #transforming }
RBExtractMethodRefactoring >> requestExtractionClass [ 
	^ (self options at: #extractionClass ifAbsent: [ [:ref | class ]]) value: self
]

{ #category : #transforming }
RBExtractMethodRefactoring >> selectorsToSearch [
	^ class allSelectors
]

{ #category : #transforming }
RBExtractMethodRefactoring >> startLimit: aNumber [
	^ aNumber 
]

{ #category : #printing }
RBExtractMethodRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' extract: '.
	extractionInterval storeOn: aStream.
	aStream
		nextPutAll: ' from: #';
		nextPutAll: selector;
		nextPutAll: ' in: '.
	class storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #accessing }
RBExtractMethodRefactoring >> targetClass [ 
	^ class
]

{ #category : #transforming }
RBExtractMethodRefactoring >> transform [

	| existingSelector |
	existingSelector := self existingSelector.
	self nameNewMethod: (existingSelector
			 ifNil: [ newExtractedSelector ifNil: [ self getNewMethodName ] ]
			 ifNotNil: [ existingSelector ]).
	existingSelector ifNil: [ self compileExtractedMethod ].
	class compileTree: modifiedParseTree
]

{ #category : #transforming }
RBExtractMethodRefactoring >> updateTemporariesInExtractedMethodFor: assigned [ 
	"Add temporaries in extract method"
	assigned do: [:each | extractedParseTree body addTemporaryNamed: each]
]

{ #category : #renaming }
RBExtractMethodRefactoring >> validateRenameNode: aParseTree withOldName: oldName toWithName: newName [ 
	|conditions block|
	conditions := ((RBCondition isValidInstanceVariableName: newName for: class)
		& (RBCondition definesSelector: selector in: class)
		& (RBCondition definesInstanceVariable: newName in: class) not 
		& (RBCondition definesClassVariable: newName in: class) not).
	conditions check
		ifFalse: [ block := conditions errorBlock.
			block
				ifNotNil: [ self refactoringError: conditions errorString with: block ]
				ifNil: [ self refactoringError: conditions errorString ] ].
	(parameterMap values includes: newName) ifTrue: [
		self refactoringError: newName asString , ' is already defined as parameter' ].
	(aParseTree whoDefines: newName)
		ifNotNil: [ self refactoringError: newName asString , ' is already defined' ].
	(aParseTree allDefinedVariables includes: newName)
		ifTrue: [ self refactoringError: newName asString , ' is already defined' ]
]

{ #category : #renaming }
RBExtractMethodRefactoring >> validateRenameOf: oldName to: newName [
	self validateRenameNode: extractedParseTree withOldName: oldName toWithName: newName 
]
