Class {
	#name : #RBRenameInstanceVariableTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBRenameInstanceVariableTest >> testAlreadyExistingName [
	self shouldFail: (RBRenameInstanceVariableRefactoring 
			rename: 'classBlock'
			to: 'name'
			in: RBBasicLintRuleTestData)
]

{ #category : #'failure tests' }
RBRenameInstanceVariableTest >> testNonExistantName [
	self shouldFail: (RBRenameInstanceVariableRefactoring 
			rename: 'foo'
			to: 'newFoo'
			in: RBBasicLintRuleTestData)
]

{ #category : #tests }
RBRenameInstanceVariableTest >> testRenameInstVar [
	| refactoring class |
	refactoring := RBRenameInstanceVariableRefactoring rename: 'classBlock' to: 'asdf' in: RBBasicLintRuleTestData.
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBBasicLintRuleTestData.
	self assert: (class directlyDefinesInstanceVariable: 'asdf').
	self deny: (class directlyDefinesInstanceVariable: 'classBlock').
	self
		assert:
			(class parseTreeFor: #checkClass:)
				equals:
					(self
						parseMethod:
							'checkClass: aSmalllintContext 
								^asdf value: aSmalllintContext value: result').
	self
		assert:
			(class parseTreeFor: #initialize)
				equals:
					(self
						parseMethod:
							'initialize
	super initialize.
	self anInstVar: 1.
	asdf := [:context :aResult | ].
	methodBlock := [:context :aResult | ].
	self resultClass: RBSelectorEnvironment')
]

{ #category : #tests }
RBRenameInstanceVariableTest >> testRenameInstVarFromTrait [
	| refactoring class |
	refactoring := RBRenameInstanceVariableRefactoring rename: 'var1' to: 'var11' in: RBDummy.
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBDummy.
	self assert: (class directlyDefinesInstanceVariable: 'var11').
	self deny: (class directlyDefinesInstanceVariable: 'var1').
	self
		assert: (class parseTreeFor: #var1)
		equals: (self parseMethod: 'var1 ^ var11').
	class := refactoring model classNamed: #RBClassUsingSharedPoolForTestData.
	self
		assert: (class parseTreeFor: #msg1)
		equals: (self parseMethod: 'msg1 var11 asString').
	"TODO"
	"self
		assert: (class parseTreeFor: #msg2)
		equals: (self parseMethod: 'msg2 var11')"
]

{ #category : #tests }
RBRenameInstanceVariableTest >> testRenameInstVarNotAccessors [
	| refactoring class |
	refactoring := RBRenameInstanceVariableRefactoring rename: 'result' to: 'whatever' in: RBBasicLintRuleTestData renameAccessors: false.
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBBasicLintRuleTestData.
	self assert: (class directlyDefinesInstanceVariable: 'whatever').
	self deny: (class directlyDefinesInstanceVariable: 'result').
	
	self deny: (class definesMethod: #whatever).
	self deny: (class definesMethod: #whatever:).
	self assert: (class definesMethod: #result).

]
