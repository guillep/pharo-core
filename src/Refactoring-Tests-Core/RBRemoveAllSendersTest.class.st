Class {
	#name : #RBRemoveAllSendersTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #tests }
RBRemoveAllSendersTest >> testRemoveMessageInsideBlock [
	| refactoring methodName |
	methodName := ('caller', '2') asSymbol.
	refactoring := RBRemoveAllSendersRefactoring  
			removeSendersOf: methodName.
	self setupInlineExpressionFor: refactoring toReturn: false.
	self proceedThroughWarning: [self executeRefactoring: refactoring ].
	"remove 2 senders"
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: #multipleCalls) equals: (self parseMethod: 'multipleCalls').
	"it doesn't remove the sender, because its result is used"
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: #inlineLast) equals: (self parseMethod: 'inlineLast
	5 = 3 ifTrue: [^self caller] ifFalse: [^self caller2]').
	
]
