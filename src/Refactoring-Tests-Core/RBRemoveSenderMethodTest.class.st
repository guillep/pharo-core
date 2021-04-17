Class {
	#name : #RBRemoveSenderMethodTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBRemoveSenderMethodTest >> testIsDirectlyUsed [
	| refactoring methodName |
	methodName := ('caller', '2') asSymbol.
	refactoring := RBRemoveSenderRefactoring
		remove: (58 to: 73)
		inMethod: methodName
		forClass: RBRefactoryTestDataApp.
	self setupInlineExpressionFor: refactoring toReturn: false.
	self shouldFail: refactoring.
]

{ #category : #'failure tests' }
RBRemoveSenderMethodTest >> testIsDirectlyUsed2 [
	| refactoring |
	refactoring := RBRemoveSenderRefactoring
		remove: (25 to: 39)
		inMethod: #returnsBooleanAndOther
		forClass: RBRefactoryTestDataApp.
	self setupInlineExpressionFor: refactoring toReturn: false.
	self shouldFail: refactoring.
]

{ #category : #'failure tests' }
RBRemoveSenderMethodTest >> testNonExistantSelector [
	self shouldFail: (RBRemoveSenderRefactoring 
			remove: (14 to: 17)
			inMethod: #checkClass1:
			forClass: RBRefactoryTestDataApp)
]

{ #category : #tests }
RBRemoveSenderMethodTest >> testRemoveMessageInsideBlock [
	| refactoring methodName |
	methodName := ('caller', '1') asSymbol.
	refactoring := RBRemoveSenderRefactoring 
			remove: (	90 to: 105)
			inMethod: methodName
			forClass: RBRefactoryTestDataApp.
			
	self setupInlineExpressionFor: refactoring toReturn: false.
	self executeRefactoring: refactoring .

	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: methodName) equals: (self parseMethod: 'caller1
	| anObject |
	anObject := 5.
	self called: anObject + 1
		on1: 
			[:each | 
			^anObject]')
]

{ #category : #tests }
RBRemoveSenderMethodTest >> testRemoveSenderIntoCascaded2Message [
	| refactoring |
	self proceedThroughWarning: 
		[ refactoring := RBRemoveSenderRefactoring 
			remove: (	33 to: 62)
			inMethod: #inlineMethod
			forClass: RBRefactoryTestDataApp.
			
	self setupInlineExpressionFor: refactoring toReturn: false.
	self executeRefactoring: refactoring ].
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) 
	parseTreeFor: #inlineMethod) equals: (self parseMethod: 'inlineMethod
	| temp |
	self foo.
	temp := self bar.
	^ temp')
]

{ #category : #tests }
RBRemoveSenderMethodTest >> testRemoveSenderIntoCascaded3Message [
	| refactoring |
	self proceedThroughWarning: 
		[ refactoring := RBRemoveSenderRefactoring 
			remove: (	64 to: 461)
			inMethod: #referencesConditionFor:
			forClass: RBRefactoryTestDataApp.
			
	self setupInlineExpressionFor: refactoring toReturn: false.
	self executeRefactoring: refactoring ].
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) 
	parseTreeFor: #referencesConditionFor:) equals: (self parseMethod: 'referencesConditionFor: aClass
	| environment association anObject |
	anObject := RBCondition withBlock: [ 
		            association := Smalltalk globals
			                           associationAt: aClass name
			                           ifAbsent: [ 
			                           self refactoringError:
				                           ''Could not find class'' ].
		            environment := (self environment referencesTo:
			                            association)
		                           |
		                           (self environment referencesTo:
			                            aClass name).
		            environment isEmpty ].
	anObject errorMacro: aClass , '' is referenced.<n>Browse references?''.
	^ anObject yourself')
]

{ #category : #tests }
RBRemoveSenderMethodTest >> testRemoveSenderIntoCascadedMessage [
	| refactoring |
	self proceedThroughWarning: 
		[ refactoring := RBRemoveSenderRefactoring 
			remove: (	31 to: 75)
			inMethod: ('called:', 'on:') asSymbol
			forClass: RBRefactoryTestDataApp.
			
	self setupInlineExpressionFor: refactoring toReturn: false.
	self executeRefactoring: refactoring ].
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: ('called:', 'on:') asSymbol) equals: (self parseMethod: 'called: anObject on: aBlock 
	Transcript show: anObject printString.
	aBlock value')
]

{ #category : #tests }
RBRemoveSenderMethodTest >> testRemoveSimpleSenderOfMessage [
	| refactoring methodName |
	methodName := ('caller', '1') asSymbol.
	refactoring := RBRemoveSenderRefactoring 
			remove: (	40 to: 120)
			inMethod: methodName
			forClass: RBRefactoryTestDataApp.
			
	self setupInlineExpressionFor: refactoring toReturn: false.
	self executeRefactoring: refactoring .

	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: methodName) equals: (self parseMethod: 'caller1
	| anObject arg1 |
	anObject := 5.
	arg1 := anObject + 1')
]
