"
I am a refactoring operations for finding direct pool variables  references.

I am used by other refactorings, for example to push down/ pull up a method.
Moving a method from class A to class B, that referes to some pool variables of class A, 
this refactoring will add the pool definition to class B.


"
Class {
	#name : #RBExpandReferencedPoolsRefactoring,
	#superclass : #RBRefactoring,
	#instVars : [
		'pools',
		'fromClass',
		'parseTree',
		'toClasses'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBExpandReferencedPoolsRefactoring class >> forMethod: aParseTree fromClass: aClass toClasses: classCollection [ 
	^(self new)
		forMethod: aParseTree
			fromClass: aClass
			toClasses: classCollection;
		yourself
]

{ #category : #'instance creation' }
RBExpandReferencedPoolsRefactoring class >> model: aRBNamespace forMethod: aParseTree fromClass: aClass toClasses: classCollection [ 
	^(self new)
		model: aRBNamespace;
		forMethod: aParseTree
			fromClass: aClass
			toClasses: classCollection;
		yourself
]

{ #category : #transforming }
RBExpandReferencedPoolsRefactoring >> computePoolsToMove [

	| poolVariables searcher |
	poolVariables := self poolVariableNamesFor: fromClass.
	pools := Set new.
	searcher := self parseTreeSearcher.
	searcher
		matches: '`var'
		do: [ :aNode :answer | 
			| varName pool |

			varName := aNode name.
			( aNode whoDefines: varName )
				ifNil: [ ( poolVariables includes: varName )
						ifTrue: [ pool := self whichPoolDefines: varName.
							pool ifNotNil: [ pools add: pool ]
							]
					]
			].
	searcher executeTree: parseTree
]

{ #category : #initialization }
RBExpandReferencedPoolsRefactoring >> forMethod: aParseTree fromClass: aClass toClasses: classCollection [ 
	fromClass := self model classFor: aClass.
	parseTree := aParseTree.
	toClasses := classCollection collect: [:each | self model classFor: each]
]

{ #category : #testing }
RBExpandReferencedPoolsRefactoring >> hasPoolsToMove [
	^pools isNotEmpty
]

{ #category : #transforming }
RBExpandReferencedPoolsRefactoring >> movePool: aSymbol toClass: aClass [ 
	| nonMetaClass |
	nonMetaClass := aClass instanceSide.
	(nonMetaClass definesPoolDictionary: aSymbol) ifFalse: [ nonMetaClass addPoolDictionary: aSymbol ]
]

{ #category : #transforming }
RBExpandReferencedPoolsRefactoring >> movePoolVariables [
	pools 
		do: [:poolDict | toClasses do: [:each | self movePool: poolDict toClass: each]]
]

{ #category : #preconditions }
RBExpandReferencedPoolsRefactoring >> preconditions [

	^ self emptyCondition
]

{ #category : #transforming }
RBExpandReferencedPoolsRefactoring >> transform [
	self computePoolsToMove.
	self hasPoolsToMove 
		ifTrue: 
			[self 
				refactoringWarning: 'This method contains references to pools<n>which may need to be moved.<n>Proceed anyway?' 
						expandMacros].
	self movePoolVariables
]

{ #category : #transforming }
RBExpandReferencedPoolsRefactoring >> whichPoolDefines: varName [ 
	| currentClass |
	currentClass := fromClass.
	[currentClass isNil] whileFalse: 
			[currentClass allPoolDictionaryNames 
				do: [:each | ((self poolVariableNamesIn: each) includes: varName) ifTrue: [^each]].
			currentClass := currentClass superclass].
	^nil
]
