Class {
	#name : #RBInlineAllMethodTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBInlineAllMethodTest >> testInlineMethodCanNotUnderstandSelectorInClass [
	| refactoring |
	refactoring := RBInlineAllSendersRefactoring 
		sendersOf: #caller3
		in: RBRefactoryTestDataApp.
	self shouldFail: refactoring.
]

{ #category : #tests }
RBInlineAllMethodTest >> testInlineMethodWithMultipleArgs [
	| class |
	model := RBClassModelFactory rbNamespace new.
	class := model classNamed: self class name.
	class
		compile: 'foo: arg1 bar: arg2 ^ arg1 + arg2' classified: #(#accessing);
		compile: 'exampleInline | x | x := 3 + (self foo: a bar: b). ^ (self foo: 5 bar: 7)' 
		classified: #(#accessing).
	self executeRefactoring: (RBInlineAllSendersRefactoring 
				model: model
				sendersOf: #foo:bar:
				in: class).
	self assert: (class parseTreeFor: #exampleInline) 
			equals: (self parseMethod: 'exampleInline
	| x |
	x := 3 + (a + b).
	^ 5 + 7').
]

{ #category : #tests }
RBInlineAllMethodTest >> testInlineMethodWithMultipleSendersInMethod [
	| refactoring methodName |
	methodName := ('caller', '2') asSymbol.
	refactoring := RBInlineAllSendersRefactoring 
		sendersOf: methodName
		in: RBRefactoryTestDataApp.
	self executeRefactoring: refactoring.
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: #inlineLast) equals: (self parseMethod: 'inlineLast
	5 = 3 ifTrue: [^self caller] ifFalse: [^(1 to: 10) inject: 1 into: [:sum :each | sum * (self foo: each)]] ').
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: #multipleCalls) equals: (self parseMethod: 'multipleCalls
	(1 to: 10) inject: 1 into: [:sum :each | sum * (self foo: each)].
	(1 to: 10) inject: 1 into: [:sum1 :each1 | sum1 * (self foo: each1)]')
]

{ #category : #tests }
RBInlineAllMethodTest >> testRecursiveMethod [
	| class |
	model := RBClassModelFactory rbNamespace new.
	class := model classNamed: self class name.
	class
		compile: 'foo ^self foo' classified: #(#accessing);
		compile: 'bar ^self foo' classified: #(#accessing).
	self executeRefactoring: (RBInlineAllSendersRefactoring 
				model: model
				sendersOf: #foo
				in: class).
	self assert: (class parseTreeFor: #foo) 
			equals: (self parseMethod: 'foo ^self foo').
	self assert: (class parseTreeFor: #bar) 
			equals: (self parseMethod: 'bar ^self foo')
]
