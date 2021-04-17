"
I am a refactoring used by other refactoring operations for extracting direct inst var and pool var 
access to accessor methods.

For example RBMoveMethodRefactoring uses me.
"
Class {
	#name : #RBAbstractVariablesRefactoring,
	#superclass : #RBRefactoring,
	#instVars : [
		'tree',
		'fromClass',
		'instVarReaders',
		'instVarWriters',
		'classVarReaders',
		'classVarWriters',
		'toClasses',
		'ignore'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBAbstractVariablesRefactoring class >> model: aRBModel abstractVariablesIn: aBRProgramNode from: fromBehavior toAll: behaviorCollection [ 
	^self 
		model: aRBModel
		abstractVariablesIn: aBRProgramNode
		from: fromBehavior
		toAll: behaviorCollection
		ignoring: nil
]

{ #category : #'instance creation' }
RBAbstractVariablesRefactoring class >> model: aRBSmalltalk abstractVariablesIn: aBRProgramNode from: fromBehavior toAll: behaviorCollection ignoring: aVariableName [ 
	^(self new)
		model: aRBSmalltalk;
		abstractVariablesIn: aBRProgramNode
			from: fromBehavior
			toAll: behaviorCollection
			ignoring: aVariableName;
		yourself
]

{ #category : #transforming }
RBAbstractVariablesRefactoring >> abstractClassVariable: aString [ 
	| refactoring rewriter nonMetaClass |
	nonMetaClass := fromClass instanceSide.
	refactoring := RBCreateAccessorsForVariableRefactoring 
		model: self model
		variable: aString
		class: nonMetaClass
		classVariable: true.
	self performCompositeRefactoring: refactoring.
	rewriter := self parseTreeRewriter.
	fromClass isMeta 
		ifTrue: 
			[ rewriter
				replace: aString , ' := ``@object'
					with: ('self <1s> ``@object' expandMacrosWith: refactoring setterMethod);
				replace: aString
					with: 'self ' , refactoring getterMethod ]
		ifFalse: 
			[ rewriter
				replace: aString , ' := ``@object'
					with: ('self class <1s> ``@object' expandMacrosWith: refactoring setterMethod);
				replace: aString
					with: 'self class ' , refactoring getterMethod ].
	(rewriter executeTree: tree) ifTrue: [ tree := rewriter tree ]
]

{ #category : #transforming }
RBAbstractVariablesRefactoring >> abstractClassVariables [
	| variables |
	(classVarReaders isEmpty and: [ classVarWriters isEmpty ])
		ifTrue: [ ^ self ].
	variables := Set new.
	variables
		addAll: classVarReaders;
		addAll: classVarWriters.
	variables do: [ :each | self abstractClassVariable: each ]
]

{ #category : #transforming }
RBAbstractVariablesRefactoring >> abstractInstanceVariable: aString [ 
	| refactoring rewriter |
	refactoring := RBCreateAccessorsForVariableRefactoring 
				model: self model
				variable: aString
				class: fromClass
				classVariable: false.
	self performCompositeRefactoring: refactoring.
	rewriter := self parseTreeRewriter.
	rewriter
		replace: aString , ' := ``@object'
			with: ('self <1s> ``@object' expandMacrosWith: refactoring setterMethod);
		replace: aString with: 'self ' , refactoring getterMethod.
	(rewriter executeTree: tree) ifTrue: [tree := rewriter tree]
]

{ #category : #transforming }
RBAbstractVariablesRefactoring >> abstractInstanceVariables [
	| variables |
	(instVarReaders isEmpty and: [ instVarWriters isEmpty ])
		ifTrue: [ ^ self].
	variables := Set new.
	variables
		addAll: instVarReaders;
		addAll: instVarWriters.
	variables do: [ :each | self abstractInstanceVariable: each ]
]

{ #category : #initialization }
RBAbstractVariablesRefactoring >> abstractVariablesIn: aBRProgramNode from: fromBehavior toAll: behaviorCollection ignoring: aVariableName [ 
	| poolRefactoring |
	tree := aBRProgramNode.
	fromClass := self classObjectFor: fromBehavior.
	toClasses := behaviorCollection 
				collect: [:each | self classObjectFor: each].
	ignore := aVariableName.
	poolRefactoring := RBExpandReferencedPoolsRefactoring 
				model: self model
				forMethod: tree
				fromClass: fromClass
				toClasses: toClasses.
	self performCompositeRefactoring: poolRefactoring.
	self computeVariablesToAbstract
]

{ #category : #transforming }
RBAbstractVariablesRefactoring >> classVariableNames [
	| nonMetaClass |
	nonMetaClass := fromClass instanceSide.
	^ (nonMetaClass allClassVariableNames collect: [ :each | each asString ]) asSet
]

{ #category : #transforming }
RBAbstractVariablesRefactoring >> computeVariablesToAbstract [
	| searcher |
	instVarReaders := Set new.
	instVarWriters := Set new.
	classVarReaders := Set new.
	classVarWriters := Set new.
	searcher := self parseTreeSearcher.
	searcher
		matches: '`var := ``@anything'
			do: [ :aNode :answer | self processAssignmentNode: aNode ];
		matches: '`var'
			do: [ :aNode :answer | self processReferenceNode: aNode ].
	searcher executeTree: tree.
	self removeDefinedClassVariables
]

{ #category : #testing }
RBAbstractVariablesRefactoring >> hasVariablesToAbstract [
	^ instVarReaders notEmpty or: [ instVarWriters notEmpty or: [ classVarReaders notEmpty or: [ classVarWriters notEmpty ] ] ]
]

{ #category : #transforming }
RBAbstractVariablesRefactoring >> instanceVariableNames [
	^fromClass allInstanceVariableNames asSet
]

{ #category : #accessing }
RBAbstractVariablesRefactoring >> parseTree [
	^tree
]

{ #category : #preconditions }
RBAbstractVariablesRefactoring >> preconditions [

	^ self emptyCondition
]

{ #category : #transforming }
RBAbstractVariablesRefactoring >> processAssignmentNode: aNode [ 
	| varName |
	varName := aNode variable name.
	ignore = varName ifTrue: [^self].
	(aNode whoDefines: varName) ifNotNil: [^self].
	(self instanceVariableNames includes: varName) 
		ifTrue: [instVarWriters add: varName].
	(self classVariableNames includes: varName) 
		ifTrue: [classVarWriters add: varName]
]

{ #category : #transforming }
RBAbstractVariablesRefactoring >> processReferenceNode: aNode [ 
	| varName |
	varName := aNode name.
	ignore = varName ifTrue: [^self].
	(aNode whoDefines: varName) ifNotNil: [^self].
	(self instanceVariableNames includes: varName) 
		ifTrue: [instVarReaders add: varName].
	(self classVariableNames includes: varName) 
		ifTrue: [classVarReaders add: varName]
]

{ #category : #transforming }
RBAbstractVariablesRefactoring >> removeDefinedClassVariables [
	| selectionBlock nonMetaClass |
	nonMetaClass := fromClass instanceSide.
	selectionBlock := 
	[ :varName | 
	(toClasses 
		detect: 
			[ :each | 
			(each instanceSide includesClass: (nonMetaClass whoDefinesClassVariable: varName)) not ]
		ifNone: [ nil ]) notNil ].
	classVarReaders := classVarReaders select: selectionBlock.
	classVarWriters := classVarWriters select: selectionBlock
]

{ #category : #transforming }
RBAbstractVariablesRefactoring >> transform [
	self hasVariablesToAbstract 
		ifTrue: 
			[self 
				refactoringWarning: 'This method has direct variable references which<n>will need to be converted to getter/setters.<n>Proceed anyway?' 
						expandMacros].
	self abstractInstanceVariables.
	self abstractClassVariables
]
