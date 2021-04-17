"
I'm a refactoring operation for replace one method call by another one.

The new method's name can have a different number of arguments than the original method, if it has more arguments a list of initializers will be needed for them.

All senders of this method are changed by the other.

Example
-------
Script:
```
(RBReplaceMethodRefactoring  
	model: model
	replaceMethod: #anInstVar:
	in: RBBasicLintRuleTestData
	to: #newResultClass: 
	permutation: (1 to: 1)
	inAllClasses: true) execute
```
"
Class {
	#name : #RBReplaceMethodRefactoring,
	#superclass : #RBChangeMethodNameRefactoring,
	#instVars : [
		'replaceInAllClasses',
		'initializers'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBReplaceMethodRefactoring class >> model: aRBSmalltalk replaceMethod: aSelector in: aClass to: newSelector permutation: aMap [ 
	^ self new
		model: aRBSmalltalk;
		replaceCallMethod: aSelector
			in: aClass
			to: newSelector
			permutation: aMap;
		yourself
]

{ #category : #'instance creation' }
RBReplaceMethodRefactoring class >> model: aRBSmalltalk replaceMethod: aSelector in: aClass to: newSelector permutation: aMap inAllClasses: aBoolean [
	^ self new
		model: aRBSmalltalk;
		replaceCallMethod: aSelector
			in: aClass
			to: newSelector
			permutation: aMap
			inAllClasses: aBoolean;
		yourself
]

{ #category : #'instance creation' }
RBReplaceMethodRefactoring class >> replaceCallMethod: aSelector in: aClass to: newSelector permutation: aMap [ 
	^self new replaceCallMethod: aSelector
		in: aClass
		to: newSelector
		permutation: aMap
]

{ #category : #'instance creation' }
RBReplaceMethodRefactoring class >> replaceCallMethod: aSelector in: aClass to: newSelector permutation: aMap inAllClasses: aBoolean [
	^self new replaceCallMethod: aSelector
		in: aClass
		to: newSelector
		permutation: aMap
		inAllClasses: aBoolean
]

{ #category : #accessing }
RBReplaceMethodRefactoring >> initializers [

	^ initializers ifNil: [ initializers := {  } ]
]

{ #category : #accessing }
RBReplaceMethodRefactoring >> initializers: anObject [

	initializers := anObject
]

{ #category : #private }
RBReplaceMethodRefactoring >> newSelectorString [
	| stream keywords |
	stream := WriteStream on: String new.
	permutation ifEmpty: [ stream nextPutAll: newSelector ].
	keywords := newSelector keywords.
	permutation
		doWithIndex: 
			[:each :index | 
			stream nextPutAll: (keywords at: index).
			each < 0
				ifTrue: 
					[stream
						nextPut: $(;
						nextPutAll: (initializers at: each abs);
						nextPut: $)]
				ifFalse: 
					[stream
						nextPutAll: ' ``@arg';
						nextPutAll: each printString].
			stream nextPut: $ ].
	^stream contents
]

{ #category : #private }
RBReplaceMethodRefactoring >> parseTreeRewriter [
	| rewriteRule oldString newString |
	rewriteRule := self parseTreeRewriterClass new.
	oldString := self buildSelectorString: oldSelector.
	newString := self newSelectorString.
	rewriteRule replace: '``@object ' , oldString
		with: '``@object ' , newString.
	^rewriteRule
]

{ #category : #transforming }
RBReplaceMethodRefactoring >> preconditions [ 
	|conditions|
	
	conditions := (RBCondition withBlock: [ oldSelector numArgs < newSelector numArgs ifTrue: [ 
				(oldSelector numArgs + self initializers size) = newSelector numArgs 
					ifFalse: [ self refactoringFailure: 'You don''t have the necessary initializers to replace senders.' ] ]. true ])
						&(RBCondition definesSelector: oldSelector in: class )
						& (RBCondition definesSelector: newSelector in: class ).
	
	^ conditions & (RBCondition withBlock: 
		[ |senders|
		senders := self replaceInAllClasses 
			ifTrue: [ self model allReferencesTo: oldSelector ]
			ifFalse: [ self model allReferencesTo: oldSelector in: {class} ].
		senders size > 1 
			ifTrue: 
				[self refactoringWarning: ('This will modify all <1p> senders.<n>Proceed anyway?' 
							expandMacrosWith: senders size)].
		true])
]

{ #category : #initialization }
RBReplaceMethodRefactoring >> replaceCallMethod: aSelector in: aClass to: newSel permutation: aMap [
	oldSelector := aSelector asSymbol.
	newSelector := newSel asSymbol.
	class := self classObjectFor: aClass.
	permutation := aMap.
]

{ #category : #initialization }
RBReplaceMethodRefactoring >> replaceCallMethod: aSelector in: aClass to: newSel permutation: aMap inAllClasses: aBoolean [
	oldSelector := aSelector asSymbol.
	newSelector := newSel asSymbol.
	class := self classObjectFor: aClass.
	permutation := aMap.
	replaceInAllClasses := aBoolean.
]

{ #category : #accessing }
RBReplaceMethodRefactoring >> replaceInAllClasses [
	^ replaceInAllClasses ifNil: [ replaceInAllClasses := false ]
]

{ #category : #transforming }
RBReplaceMethodRefactoring >> transform [
	self replaceInAllClasses 
		ifTrue: [ self renameMessageSends ]
		ifFalse: [ self renameMessageSendsIn: {class} ]
]
