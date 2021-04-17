"
I'm a refactoring for remove a method call.

Example
-------
```
| refactoring options |
refactoring := RBRemoveSenderRefactoring 
			remove: (	90 to: 105)
			inMethod: #caller1
			forClass: RBRefactoryTestDataApp.
options := refactoring options copy.
options at: #inlineExpression put: [:ref :string | false].
refactoring options: options.
refactoring execute.
```

Before refactoring:

```
RBRefactoryTestDataApp >> caller1
	| anObject |
	anObject := 5.
	self called: anObject + 1
		on1: 
			[:each | 
			each printString.
			^anObject]
```

After refactoring:
```
RBRefactoryTestDataApp >> caller1
	| anObject |
	anObject := 5.
	self called: anObject + 1
		on1: 
			[:each | 
			^anObject]
```

"
Class {
	#name : #RBRemoveSenderRefactoring,
	#superclass : #RBInlineMethodFromComponentRefactoring,
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBRemoveSenderRefactoring class >> model: aRBSmalltalk remove: anInterval inMethod: aSelector forClass: aClass [ 
	^(self new)
		model: aRBSmalltalk;
		remove: anInterval
			inMethod: aSelector
			forClass: aClass;
		yourself
]

{ #category : #'instance creation' }
RBRemoveSenderRefactoring class >> remove: anInterval inMethod: aSelector forClass: aClass [ 
	^self new 
		remove: anInterval
		inMethod: aSelector
		forClass: aClass
]

{ #category : #transforming }
RBRemoveSenderRefactoring >> findSelectedMessage [
	super findSelectedMessage.
	sourceMessage isDirectlyUsed
		ifTrue: [ self refactoringFailure: 'The sender is directly used' ].
]

{ #category : #transforming }
RBRemoveSenderRefactoring >> inlineClassName [

	^ 'Object'
]

{ #category : #accessing }
RBRemoveSenderRefactoring >> inlineParseTree [

	| aSymbol |
	aSymbol := sourceMessage selector.
	^ inlineParseTree ifNil: [inlineParseTree := RBMethodNode 
		selector:  aSymbol
		arguments: ( (1 to: aSymbol numArgs) collect: [ :e | RBVariableNode named: 'arg', e asString ])
		body: ( RBSequenceNode statements: #())]
]

{ #category : #preconditions }
RBRemoveSenderRefactoring >> preconditions [
	^(RBCondition definesSelector: sourceSelector in: class) 
		& (RBCondition withBlock: 
					[self findSelectedMessage.
					"self parseInlineMethod."
					self rewriteInlinedTree.
					(sourceMessage parent isReturn or: [self hasMultipleReturns not]) 
						ifFalse: 
							[self 
								refactoringError: 'Cannot inline method since it contains multiple returns that cannot be rewritten'].
					true])
]

{ #category : #removing }
RBRemoveSenderRefactoring >> remove: anInterval inMethod: aSelector forClass: aClass [ 
	sourceSelector := aSelector.
	class := self classObjectFor: aClass.
	sourceInterval := anInterval
]

{ #category : #printing }
RBRemoveSenderRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' remove: '.
	sourceInterval storeOn: aStream.
	aStream
		nextPutAll: ' inMethod: #';
		nextPutAll: sourceSelector;
		nextPutAll: ' forClass: '.
	class storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #transforming }
RBRemoveSenderRefactoring >> transform [
	self inlineParseTree.
	self renameConflictingTemporaries.
	self renameSelfReferences.
	self
		renameConflictingTemporaries;
		insertInlinedMethod;
		compileMethod
]
