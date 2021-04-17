Class {
	#name : #RBRenameMethodTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBRenameMethodTest >> testExistingSelector [
	self shouldFail: (RBRenameMethodRefactoring 
			renameMethod: #checkClass:
			in: RBBasicLintRuleTestData
			to: #runOnEnvironment:
			permutation: (1 to: 1))
]

{ #category : #'failure tests' }
RBRenameMethodTest >> testMultipleSelectors [
	self shouldWarn: (RBRenameMethodRefactoring 
			renameMethod: #checkClass:
			in: RBBasicLintRuleTestData
			to: #foo:
			permutation: (1 to: 1))
]

{ #category : #tests }
RBRenameMethodTest >> testRenameMethodFromTrait [
	| refactoring class |
	refactoring := RBRenameMethodRefactoring 
		renameMethod: ('just', 'ForTest') asSymbol
		in: RBClassToRename classSide 
		to: #justForTest1
		permutation: (1 to: 0).
	self proceedThroughWarning: [ self executeRefactoring: refactoring ].
	class := refactoring model classNamed: #'RBClassToRename class'.
	self assert: (class parseTreeFor: #justForTest1) 
		equals: (self parseMethod: 'justForTest1 ^ 42').
	self assert: ((refactoring model classNamed: #RBDummy) parseTreeFor: #methodFromTrait) equals: (self parseMethod: 'methodFromTrait
	RBClassToRename justForTest1').
	self deny: (class directlyDefinesMethod: ('just', 'ForTest') asSymbol).
	self assert: ((refactoring model classNamed: #RBClassUsingSharedPoolForTestData) methodFor: #methodFromTrait) modelClass name equals: #RBDummy
]

{ #category : #tests }
RBRenameMethodTest >> testRenameMethodOnlyInSomePackages [
	| refactoring class |
	model := (RBClassModelFactory rbNamespace onEnvironment: (RBPackageEnvironment packageName: 'Refactoring-Tests-Core')).
	refactoring := RBRenameMethodRefactoring 
		model: model
		renameMethod: ('check', 'Class:') asSymbol
		in: RBBasicLintRuleTestData
		to: #checkClass1:
		permutation: (1 to: 1).
	self proceedThroughWarning: [ self executeRefactoring: refactoring ].
	class := refactoring model classNamed: #RBBasicLintRuleTestData.
	self assert: (class parseTreeFor: #checkClass1:) 
		equals: (self parseMethod: 'checkClass1: aSmalllintContext 
	^classBlock value: aSmalllintContext value: result').
	
]

{ #category : #tests }
RBRenameMethodTest >> testRenameMethodPermuteArgs [
	| refactoring class |
	refactoring := RBRenameMethodRefactoring
		renameMethod: ('demoRenameMethod:' , 'PermuteArgs:') asSymbol
		in: RBRefactoryTestDataApp
		to: ('demoRenameMethod:' , 'PermuteArgs:') asSymbol
		permutation: #(2 1).
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self
		assert:
			(class parseTreeFor: ('demoRenameMethod:' , 'PermuteArgs:') asSymbol)
				equals:
					(self
						parseMethod:
							'demoRenameMethod: arg2 PermuteArgs: arg1 self do: arg1.
	self do: arg2.
	^ arg1 > arg2').
	self
		assert:
			(class parseTreeFor: #demoExampleCall)
				equals: (self parseMethod: 'demoExampleCall ^self demoRenameMethod: 2 PermuteArgs: 1')
]

{ #category : #tests }
RBRenameMethodTest >> testRenamePermuteArgs [
	| refactoring class |
	refactoring := RBRenameMethodRefactoring 
		renameMethod: ('rename:' , 'two:') asSymbol
		in: RBRefactoryTestDataApp
		to: ('rename:' , 'two:') asSymbol
		permutation: #(2 1 ).
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self assert: (class parseTreeFor: ('rename:' , 'two:') asSymbol) 
		equals: (self parseMethod: 'rename: argumentMethod two: this ^self printString, this, argumentMethod').
	self assert: (class parseTreeFor: #exampleCall) 
		equals: (self parseMethod: 'exampleCall <sampleInstance> ^self rename: 2 two: 1')
]

{ #category : #tests }
RBRenameMethodTest >> testRenamePrimitive [
	| refactoring count |
	count := 0.
	model allReferencesTo: #basicAt:put: do: [:method | count := count + 1].
	refactoring := RBRenameMethodRefactoring 
				model: model
				renameMethod: #basicAt:put:
				in: Object
				to: ('at:' , 'bar:') asSymbol
				permutation: (1 to: 2).
	self proceedThroughWarning: [self executeRefactoring: refactoring].
	model allReferencesTo: #basicAt:put:
		do: 
			[:method | 
			count := count - 1.
			self assert: method source isNil].
	model allReferencesTo: ('at:' , 'bar:') asSymbol
		do: [:method | count := count - 1].
	self assert: count equals: 0
]

{ #category : #tests }
RBRenameMethodTest >> testRenameTestMethod [
	| refactoring class |
	refactoring := RBRenameMethodRefactoring 
		renameMethod: ('rename' , 'ThisMethod:') asSymbol
		in: RBRefactoryTestDataApp
		to: #renameThisMethod2:
		permutation: (1 to: 1).
	self proceedThroughWarning: [ self executeRefactoring: refactoring ].
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self assert: (class parseTreeFor: #renameThisMethod2:) equals: (self parseMethod: 'renameThisMethod2: anArg
	^self').
	self assert: (class parseTreeFor: #callMethod) equals: (self parseMethod: 'callMethod
	^(self renameThisMethod2: 5)').
	self assert: (class parseTreeFor: #symbolReference) equals: (self parseMethod: 'symbolReference
		^ #(#renameThisMethod2: #(4 #renameThisMethod2:))').
	self deny: (class directlyDefinesMethod: ('rename' , 'ThisMethod:') asSymbol)
]

{ #category : #tests }
RBRenameMethodTest >> testRenameTestMethod1 [
	| refactoring class |
	refactoring := RBRenameMethodRefactoring 
		renameMethod: ('testMethod1') asSymbol
		in: RBRefactoryTestDataApp
		to: #testMethod2
		permutation: (1 to: 0).
	self proceedThroughWarning: [ self executeRefactoring: refactoring ].
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self assert: (class parseTreeFor: #testMethod2) 
		equals: (self parseMethod: 'testMethod2
	^self testMethod2 , ([:each | each testMethod2] value: #(#(#testMethod2) 2 #testMethod2))').
	self assert: ((refactoring model classNamed: #RBBasicLintRuleTestData) parseTreeFor: #classBlock:) 		equals: (self parseMethod: 'classBlock: aBlock
	classBlock := aBlock testMethod2').
	self deny: (class directlyDefinesMethod: ('test' , 'Method1') asSymbol)
]

{ #category : #'failure tests' }
RBRenameMethodTest >> testWithNonCorrectNumberOfArgs [
	self shouldFail: (RBRenameMethodRefactoring 
			renameMethod: #checkClass:
			in: RBBasicLintRuleTestData
			to: #checkClass
			permutation: (1 to: 1))
]
