Class {
	#name : #RBPushDownMethodTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #tests }
RBPushDownMethodTest >> testPushDownMethod [
	| refactoring class |
	refactoring := RBPushDownMethodRefactoring 
		pushDown: #(#name: )
		from: RBLintRuleTestData.
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBLintRuleTestData.
	self deny: (class directlyDefinesMethod: #name:).
	class subclasses do: 
		[ :each | 
		self assert: (each parseTreeFor: #name:) equals: (self parseMethod: 'name: aString name := aString') ]
]

{ #category : #'failure tests' }
RBPushDownMethodTest >> testPushDownMethodOnNonAbstractClass [
	| refactoring |
	refactoring := RBPushDownMethodRefactoring pushDown: #(#isArray) from: Array.
	self shouldFail: refactoring
]

{ #category : #'failure tests' }
RBPushDownMethodTest >> testPushDownMethodSubclassesReferToSelector [
	| refactoring |
	model 
		defineClass: 'Object subclass: #Superclass instanceVariableNames: '''' classVariableNames: '''' poolDictionaries: '''' category: #''Refactory-Test data'''.
	model 
		defineClass: 'Superclass subclass: #Foo1 instanceVariableNames: '''' classVariableNames: '''' poolDictionaries: '''' category: #''Refactory-Test data'''.
	model 
		defineClass: 'Superclass subclass: #Foo2 instanceVariableNames: '''' classVariableNames: '''' poolDictionaries: '''' category: #''Refactory-Test data'''.
	(model classNamed: #Superclass) compile: 'yourself ^1' classified: #(#accessing).
	(model classNamed: #Foo1) compile: 'method1 ^super yourself' classified: #(#accessing).
	
	refactoring := RBPushDownMethodRefactoring 
		model: model
		pushDown: #(#yourself)
		from: (model classNamed: #Superclass).
	self shouldFail: refactoring.
]

{ #category : #tests }
RBPushDownMethodTest >> testPushDownMethodThatReferencesPoolDictionary [
	| refactoring class parseTree |
	parseTree := RBLintRuleTestData parseTreeFor: #junk.
	refactoring := RBPushDownMethodRefactoring 
			pushDown: #(#junk )
			from: RBLintRuleTestData.
		self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBLintRuleTestData.
	self deny: (class directlyDefinesMethod: #junk).
	class subclasses do: 
		[ :each | 
		self assert: (each parseTreeFor: #junk) equals: parseTree.
		self assert: (each definesPoolDictionary: 'TextConstants' asSymbol) ]
]

{ #category : #'failure tests' }
RBPushDownMethodTest >> testPushDownNonExistantMenu [
	| refactoring |
	refactoring := RBPushDownMethodRefactoring 
		pushDown: #(#someMethodThatDoesNotExist )
		from: RBLintRuleTestData.
	self shouldFail: refactoring
]
