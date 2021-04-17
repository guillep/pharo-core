"
I am an abstract base class for refactorings changing a method name.

Doing a method rename involves:
- rename implementors
- rename message sends and
- remove renamed implementors.

I implement the above precedures and provide helper functions for finding and renaming references.
Every concrete subclass has to add its own precondition (see `myPrecondition`).

"
Class {
	#name : #RBChangeMethodNameRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'newSelector',
		'oldSelector',
		'permutation',
		'implementors'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #testing }
RBChangeMethodNameRefactoring >> hasPermutedArguments [
	oldSelector numArgs = newSelector numArgs ifFalse: [^true].
	1 to: oldSelector numArgs
		do: [:i | (permutation at: i) = i ifFalse: [^true]].
	^false
]

{ #category : #private }
RBChangeMethodNameRefactoring >> implementors [

	implementors ifNil: [ implementors := self model allImplementorsOf: oldSelector ].
	^ implementors
]

{ #category : #testing }
RBChangeMethodNameRefactoring >> implementorsCanBePrimitives [
	^false
]

{ #category : #private }
RBChangeMethodNameRefactoring >> modifyImplementorParseTree: parseTree in: aClass [ 
	| oldArgs |
	oldArgs := parseTree arguments.
	parseTree renameSelector: newSelector andArguments: (permutation collect: [:each | oldArgs at: each]) 
]

{ #category : #preconditions }
RBChangeMethodNameRefactoring >> myConditions [
	"^self subclassResponsibility"
]

{ #category : #accessing }
RBChangeMethodNameRefactoring >> newSelector [
	^newSelector
]

{ #category : #private }
RBChangeMethodNameRefactoring >> parseTreeRewriter [
	| rewriteRule oldString newString |
	rewriteRule := self parseTreeRewriterClass new.
	oldString := self buildSelectorString: oldSelector.
	newString := self buildSelectorString: newSelector
				withPermuteMap: permutation.
	rewriteRule replace: '``@object ' , oldString
		with: '``@object ' , newString.
	^rewriteRule
]

{ #category : #preconditions }
RBChangeMethodNameRefactoring >> preconditions [
	"This refactoring only preserves behavior if all implementors are renamed."

	| conditions |
	conditions := self myConditions 
				& (RBCondition definesSelector: oldSelector in: class) 
				& (RBCondition isValidMethodName: newSelector for: class).
					
	conditions := self implementors 
		inject: conditions into: [ :condition :each | 
			condition & (RBCondition hierarchyOf: each canUnderstand: newSelector) not ].
		
	^conditions & (RBCondition withBlock: 
		[self implementors size > 1 
			ifTrue: 
				[self refactoringWarning: ('This will modify all <1p> implementors. Proceed anyway?' 
							expandMacrosWith: self implementors size)].
		true])
]

{ #category : #transforming }
RBChangeMethodNameRefactoring >> removeRenamedImplementors [
	oldSelector = newSelector
		ifTrue: [ ^ self ].
	self implementors 
		do: [ :each | each removeMethod: oldSelector ]
]

{ #category : #transforming }
RBChangeMethodNameRefactoring >> renameImplementors [

	self implementors
		do: [ :each | 
			| parseTree |

			parseTree := each parseTreeFor: oldSelector.
			parseTree ifNil: [ self refactoringFailure: 'Could not parse source code.' ].
			self implementorsCanBePrimitives
				ifFalse: [ parseTree isPrimitive
						ifTrue: [ self
								refactoringFailure:
									( '<1p>''s implementation of #<2s> is a primitive' expandMacrosWith: each with: oldSelector )
							]
					].
			self modifyImplementorParseTree: parseTree in: each.
			( each methodFor: oldSelector ) compileTree: parseTree
			]
]

{ #category : #transforming }
RBChangeMethodNameRefactoring >> renameMessageSends [
	self convertAllReferencesTo: oldSelector using: self parseTreeRewriter
]

{ #category : #transforming }
RBChangeMethodNameRefactoring >> renameMessageSendsIn: classes [
	self convertAllReferencesTo: oldSelector of: classes using: self parseTreeRewriter
]

{ #category : #initialization }
RBChangeMethodNameRefactoring >> renameMethod: aSelector in: aClass to: newSel permutation: aMap [ 
	oldSelector := aSelector asSymbol.
	newSelector := newSel asSymbol.
	class := self classObjectFor: aClass.
	permutation := aMap
]

{ #category : #transforming }
RBChangeMethodNameRefactoring >> transform [
	self renameImplementors.
	self renameMessageSends.
	self removeRenamedImplementors
]
