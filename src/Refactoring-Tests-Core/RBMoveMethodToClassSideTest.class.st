Class {
	#name : #RBMoveMethodToClassSideTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBMoveMethodToClassSideTest >> testClassIsNotMeta [
	| method someClass className refactoring |
	className := RBRefactoryTestDataApp class.
	someClass := model classNamed: className name.
	someClass compile: 'threeElementPoint ^ self new' classified: {#example}.
	method := someClass methodFor: ('threeElement', 'Point') asSymbol.
	refactoring := RBMoveMethodToClassSideRefactoring model: model method: method class: className.
	self shouldFail: refactoring.
]

{ #category : #'failure tests' }
RBMoveMethodToClassSideTest >> testExistsMethodInClassSide [
	| method someClass className refactoring |
	className := RBRefactoryTestDataApp.
	method := className >> ('threeElement', 'Point') asSymbol.
	refactoring := RBMoveMethodToClassSideRefactoring method: method class: className.
	model := refactoring model.
	someClass := model classNamed: className name, ' class'.
	someClass compile: 'threeElementPoint ^ self new' classified: {#example}.
	self shouldFail: refactoring.
]

{ #category : #tests }
RBMoveMethodToClassSideTest >> testMoveMethodToClassSide [
	| method someClass className refactoring |
	className := RBRefactoryTestDataApp.
	method := className >> ('threeElement', 'Point') asSymbol.
	refactoring := RBMoveMethodToClassSideRefactoring method: method class: className.
	self executeRefactoring: refactoring.
	model := refactoring model.
	someClass := model classNamed: className name.
	self assert: (someClass parseTreeFor: ('threeElement', 'Point') asSymbol) equals: (self parseMethod: 'threeElementPoint ^ self class threeElementPoint').
	someClass := model classNamed: className name, ' class'.
	self assert: (someClass parseTreeFor: ('threeElement', 'Point') asSymbol) equals: (self parseMethod: 'threeElementPoint ^5 @ 5 + 6 @ 6').
]

{ #category : #tests }
RBMoveMethodToClassSideTest >> testMoveMethodToClassSideWithInsAndMetReferences [
	| method someClass className refactoring |
	className := RBTransformationRuleTestData.
	method := className >> ('rewrite', 'Using:') asSymbol.
	refactoring := RBMoveMethodToClassSideRefactoring method: method class: className.
	self executeRefactoring: refactoring.
	model := refactoring model.
	someClass := model classNamed: className name.
	self assert: (someClass parseTreeFor: ('rewrite', 'Using:') asSymbol) equals: (self parseMethod: 'rewriteUsing: searchReplacer
	^ self class rewriteUsing: searchReplacer').
	someClass := model classNamed: className name, ' class'.
	self assert: (someClass parseTreeFor: ('rewrite', 'Using:') asSymbol) equals: (self parseMethod: 'rewriteUsing: searchReplacer

	| aRBTransformationRuleTestData |
	aRBTransformationRuleTestData := self new.
	aRBTransformationRuleTestData rewriteRule: searchReplacer.
	aRBTransformationRuleTestData resetResult').
]
