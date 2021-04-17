Class {
	#name : #RBFindAndReplaceTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #running }
RBFindAndReplaceTest >> setUp [ 
	super setUp.
	model := self extractMethodTestData.
]

{ #category : #'failure tests' }
RBFindAndReplaceTest >> testBadSelector [
	|class|
	class := model classNamed: #MyClassA.
	self
		shouldFail:
			(RBFindAndReplaceRefactoring 
				model: model find: #unexitingMethod of: class inWholeHierarchy: true)
]

{ #category : #'failure tests' }
RBFindAndReplaceTest >> testFindOcurrencesFailureInHierarchy [
	|class refactoring|
	class := model classNamed: #MyClassA.
	class 
		compile: 'simpleMethod
			^ currentChar isLetter'
		classified: #(#accessing).
	(model classNamed: #MyClassB) 
		compile: 'simpleMethod
			^ nil'
		classified: #(#accessing).
	refactoring := RBFindAndReplaceRefactoring 
				model: model find: #simpleMethod of: class inWholeHierarchy: true.
	self shouldFail: refactoring.
]

{ #category : #tests }
RBFindAndReplaceTest >> testFindOcurrencesInClass [
	|class refactoring|
	class := model classNamed: #MyClassA.
	class 
		compile: 'simpleMethod
			^ currentChar isLetter'
		classified: #(#accessing).
	refactoring := RBFindAndReplaceRefactoring 
				model: model find: #simpleMethod of: class inWholeHierarchy: false.
	self executeRefactoring: refactoring.
	self assert: (class parseTreeFor: #myMethod) equals: (self parseMethod: 'myMethod

	| token |
	token := (String new: 100) writeStream.
	[ self simpleMethod ] whileTrue: [ 
		token nextPut: currentChar.
		self methodWithArg: self simpleMethod.
		self bar ].
	self simpleMethod.
	$3 isLetter.
	self simpleMethod.
	token := self simpleMethod.
	token := self simpleMethod example.
	^ token contents').
	class := model classNamed: #MyClassB.
	self assert: (class parseTreeFor: #exampleMethod) equals: (self parseMethod: 'exampleMethod

	^ currentChar isLetter not').
	class := model classNamed: #MyClassC.
	self assert: (class parseTreeFor: #methodWithArg:) equals: (self parseMethod: 'methodWithArg: anArg

	(currentChar isLetter and: [ anArg isDecimal ]) ifTrue: [ ^ self ].
	^ nil')
]

{ #category : #tests }
RBFindAndReplaceTest >> testFindOcurrencesInHierarchy [
	|class refactoring|
	class := model classNamed: #MyClassA.
	class 
		compile: 'simpleMethod
			^ currentChar isLetter'
		classified: #(#accessing).
	refactoring := RBFindAndReplaceRefactoring 
				model: model find: #simpleMethod of: class inWholeHierarchy: true.
	self executeRefactoring: refactoring.
	self assert: (class parseTreeFor: #myMethod) equals: (self parseMethod: 'myMethod

	| token |
	token := (String new: 100) writeStream.
	[ self simpleMethod ] whileTrue: [ 
		token nextPut: currentChar.
		self methodWithArg: self simpleMethod.
		self bar ].
	self simpleMethod.
	$3 isLetter.
	self simpleMethod.
	token := self simpleMethod.
	token := self simpleMethod example.
	^ token contents').
	class := model classNamed: #MyClassB.
	self assert: (class parseTreeFor: #exampleMethod) equals: (self parseMethod: 'exampleMethod

	^ self simpleMethod not').
	class := model classNamed: #MyClassC.
	self assert: (class parseTreeFor: #methodWithArg:) equals: (self parseMethod: 'methodWithArg: anArg

	(self simpleMethod and: [ anArg isDecimal ]) ifTrue: [ ^ self ].
	^ nil')
]

{ #category : #tests }
RBFindAndReplaceTest >> testFindOcurrencesWithArgInHierarchy [
	|class refactoring|
	class := model classNamed: #MyClassA.
	class 
		compile: 'simpleMethod
			^ currentChar isLetter'
		classified: #(#accessing).
	refactoring := RBFindAndReplaceRefactoring 
				model: model find: #methodWithArg:andArg: of: class inWholeHierarchy: true.
	self executeRefactoring: refactoring.
	class := model classNamed: #MyClassB.
	self assert: (class parseTreeFor: #dummyMethod) equals: (self parseMethod: 
	'dummyMethod self methodWithArg: 3 andArg: self someMethod')
]
