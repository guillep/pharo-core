Class {
	#name : #RBDeprecateMethodTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #tests }
RBDeprecateMethodTest >> testDeprecateMethodUsingMethodWithSameNumberOfArgs [

	| refactoring class oldSelector newSelector |
	oldSelector := #callMethod.
	newSelector := #callFoo.
	refactoring := RBDeprecateMethodRefactoring 
							model: model 
							deprecateMethod: oldSelector 
							in: RBRefactoryTestDataApp 
							using: newSelector .
	
	self executeRefactoring: refactoring .
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self
		assert: ((class parseTreeFor: oldSelector ) statements anySatisfy: 
			[ :e | e isMessage ifTrue: [ e selector = #deprecated:on:in: ] ]).
	
	self
		assert: ((class parseTreeFor: oldSelector ) statements anySatisfy: 
			[ :e | e isReturn ifTrue: [ e value selector = newSelector  ] ifFalse: [ false ] ]).
]

{ #category : #tests }
RBDeprecateMethodTest >> testDeprecateMethodUsingMethodWithoutArgs [

	| refactoring class oldSelector newSelector |
	oldSelector := ('called:', 'on:') asSymbol.
	newSelector := 'callFoo' asSymbol.
	refactoring := RBDeprecateMethodRefactoring 
							model: model 
							deprecateMethod: oldSelector 
							in: RBRefactoryTestDataApp 
							using: newSelector .
	
	self executeRefactoring: refactoring .
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self
		assert: ((class parseTreeFor: oldSelector ) statements anySatisfy: 
			[ :e | e isMessage ifTrue: [ e selector = #deprecated:on:in: ] ]).
	
	self
		assert: ((class parseTreeFor: oldSelector ) statements anySatisfy: 
			[ :e | e isReturn ifTrue: [ e value selector = newSelector  ] ifFalse: [ false ] ]).
]

{ #category : #'failure tests' }
RBDeprecateMethodTest >> testInvalidNumArgsOfSelector [

	| refactoring oldSelector newSelector |
	oldSelector := ('called:', 'on1:') asSymbol.
	newSelector := 'inlineFoo:' asSymbol.
	refactoring := RBDeprecateMethodRefactoring 
							model: model 
							deprecateMethod: oldSelector 
							in: RBRefactoryTestDataApp 
							using: newSelector .
	
	self shouldFail: refactoring
]
