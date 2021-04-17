"
I represent a method for the refactoring framework.

I am used by RBClass / RBMetaclass resp. RBAbstractClass for methods created or changed during a refactoring operation.
I represent the method with a selector, source and if I am created from an existing method, its 
CompiledMethod. 
I know my method class (a RBClass or RBMetaclass). 
You should not directly create instances of me but query or create a method from a RBClass.

I only implement a small part of  CompiledMethod interface, that is used for refactoring operations, like querying symbols, literals or the whole method source.

"
Class {
	#name : #RBMethod,
	#superclass : #RBEntity,
	#instVars : [
		'compiledMethod',
		'class',
		'selector',
		'source',
		'isFromTrait'
	],
	#category : #'Refactoring-Core-Model'
}

{ #category : #'instance creation' }
RBMethod class >> for: aRBClass fromMethod: aCompiledMethod andSelector: aSymbol [ 
	^ self new 
		modelClass: aRBClass;
		method: aCompiledMethod;
		selector: aSymbol;
		yourself
]

{ #category : #'instance creation' }
RBMethod class >> for: aRBClass source: aString selector: aSelector [ 
	^(self new)
		modelClass: aRBClass;
		selector: aSelector;
		source: aString;
		yourself
]

{ #category : #accessing }
RBMethod >> ast [
	^ self parseTree
]

{ #category : #compiling }
RBMethod >> compileTree: aBRMethodNode [
	| method sourceCode change |
	sourceCode := aBRMethodNode newSource.
	change := self modelClass model
		compile: sourceCode
		in: self modelClass
		classified: self protocols.
	method := self class
		for: self modelClass
		source: sourceCode
		selector: aBRMethodNode selector.
	self modelClass addMethod: method.
	^ change
]

{ #category : #accessing }
RBMethod >> isFromTrait [
	^ isFromTrait ifNil: [ isFromTrait := false ]
]

{ #category : #accessing }
RBMethod >> isFromTrait: anObject [
	isFromTrait := anObject
]

{ #category : #private }
RBMethod >> literal: anObject containsReferenceTo: aSymbol [
	anObject = aSymbol
		ifTrue: [ ^ true ].
	anObject class = Array
		ifFalse: [ ^ false ].
	^ anObject anySatisfy: [ :each | self literal: each containsReferenceTo: aSymbol ]
]

{ #category : #accessing }
RBMethod >> method [
	^compiledMethod
]

{ #category : #accessing }
RBMethod >> method: aCompiledMethod [ 
	compiledMethod := aCompiledMethod.
	self isFromTrait: compiledMethod isFromTrait.
]

{ #category : #accessing }
RBMethod >> methodClass [

	^ class
]

{ #category : #accessing }
RBMethod >> modelClass [
	^class
]

{ #category : #accessing }
RBMethod >> modelClass: aRBClass [
	class := aRBClass
]

{ #category : #accessing }
RBMethod >> package [
	compiledMethod ifNotNil: [ ^ compiledMethod package name ].
	^ class category
]

{ #category : #accessing }
RBMethod >> parseTree [
	^ self parserClass parseMethod: self source onError: [:str :pos | ^nil]
]

{ #category : #testing }
RBMethod >> parseTreeSearcherClass [
	^ RBParseTreeSearcher
]

{ #category : #testing }
RBMethod >> parserTreeSearcher [
	^ self parseTreeSearcherClass new
]

{ #category : #printing }
RBMethod >> printOn: aStream [ 
	class printOn: aStream.
	aStream
		nextPutAll: '>>';
		nextPutAll: self selector
]

{ #category : #accessing }
RBMethod >> protocols [
	^ self modelClass protocolsFor: self selector
]

{ #category : #testing }
RBMethod >> refersToClassNamed: aSymbol [
	| searcher |
	searcher := self parserTreeSearcher.
	searcher matches: aSymbol asString do: [ :node :answer | true ].
	^ (searcher executeTree: self parseTree initialAnswer: false)
		or: [ self refersToSymbol: aSymbol ]
]

{ #category : #testing }
RBMethod >> refersToSymbol: aSymbol [
	| searcher |
	searcher := self parserTreeSearcher.
	searcher
		matches: aSymbol printString do: [ :node :answer | true ];
		matches: '`#literal'
			do:
				[ :node :answer | answer or: [ self literal: node value containsReferenceTo: aSymbol ] ].
	aSymbol isValidSelector
		ifTrue: [ searcher
				matches:
					'`@object '
						, (self parseTreeSearcherClass buildSelectorString: aSymbol)
				do: [ :node :answer | true ] ].
	^ searcher executeTree: self parseTree initialAnswer: false
]

{ #category : #testing }
RBMethod >> refersToVariable: aString [
	| searcher tree |
	tree := self parseTree.
	((tree defines: aString) or: [ tree body defines: aString ])
		ifTrue: [ ^ false ].
	searcher := self parserTreeSearcher.
	searcher
		matches: aString do: [ :node :answer | true ];
		matches: '[:`@vars | | `@temps | `@.Stmts]'
			do: [ :node :answer | 
			answer
				or: [ ((node defines: aString) or: [ node body defines: aString ]) not
						and: [ searcher executeTree: node body initialAnswer: false ] ] ].
	^ searcher executeTree: self parseTree initialAnswer: false
]

{ #category : #accessing }
RBMethod >> selector [
	^ selector
]

{ #category : #accessing }
RBMethod >> selector: aSymbol [ 
	selector := aSymbol
]

{ #category : #accessing }
RBMethod >> source [
	^ source ifNil: [ source := (class realClass sourceCodeAt: selector) asString ]
]

{ #category : #accessing }
RBMethod >> source: aString [ 
	source := aString
]
