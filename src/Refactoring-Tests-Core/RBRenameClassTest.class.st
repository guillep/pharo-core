Class {
	#name : #RBRenameClassTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #refactoring }
RBRenameClassTest >> rename: anObject to: aSymbol using: aModel [
	^ RBRenameClassRefactoring 
				model: aModel
				rename: anObject
				to: aSymbol
]

{ #category : #refactoring }
RBRenameClassTest >> renameClassNamed: aSymbol1 to: aSymbol2 [
	^ RBRenameClassRefactoring new
		model: model;
		className: aSymbol1 newName: aSymbol2;
		yourself.
]

{ #category : #'failure tests' }
RBRenameClassTest >> testBadName [
	self
		shouldFail: (RBRenameClassRefactoring 
				rename: RBLintRuleTestData
				to: self objectClassVariable);
		shouldFail: (RBRenameClassRefactoring 
				rename: RBLintRuleTestData
				to: #'Ob ject')
]

{ #category : #'failure tests' }
RBRenameClassTest >> testExistingName [
	self shouldFail: (RBRenameClassRefactoring rename: self class to: #Object)
]

{ #category : #'failure tests' }
RBRenameClassTest >> testMetaClassFailure [
	self 
		shouldFail: (RBRenameClassRefactoring rename: self class class to: #Foo)
]

{ #category : #tests }
RBRenameClassTest >> testModelRenameClass [
	| refactoring class |
	
	model 
		defineClass: 'Object subclass: #Foo instanceVariableNames: ''a'' classVariableNames: '''' poolDictionaries: '''' category: #''Refactory-Test data'''.
	class := model classNamed: #Foo.
	class
		compile: 'foo	^Object' classified: #(#accessing);
		compile: 'objectName ^#(Object)' classified: #(#accessing).
	refactoring := self rename: Object to: #Thing using: model.
	self executeRefactoring: refactoring.
	self assert: (model includesClassNamed: #Thing).
	self deny: (model includesClassNamed: #Object).
	self 
		assert: (class parseTreeFor: #foo) equals:  (self parseMethod: 'foo ^Thing').
	self assert: (class parseTreeFor: #objectName) 
				equals: (self parseMethod: 'objectName ^#(Thing)').
	self assert: class superclass name equals: #Thing
]

{ #category : #tests }
RBRenameClassTest >> testModelRenameSequenceClass [
	model 
		defineClass: 'Object subclass: #Foo1 
			instanceVariableNames: '''' 
			classVariableNames: '''' poolDictionaries: ''''
			category: #''Refactory-Test data'''.
	(model classNamed: #Foo1)
		compile: 'foo	 ^ Foo1' classified: #(accessing);
		compile: 'objectName ^ #(Foo1)' classified: #(accessing).
	self executeRefactoring: (self rename: (model classNamed: #Foo1) to: #Foo2 using: model).
	self executeRefactoring: (self rename: (model classNamed: #Foo2) to: #Foo3 using: model).
	self deny: (model includesClassNamed: #Foo1).
	self deny: (model includesClassNamed: #Foo2).
	self assert: (model includesClassNamed: #Foo3).
	self assert: ((model classNamed: #Foo3) parseTreeFor: #foo) 
		equals: (self parseMethod: 'foo ^ Foo3').
	self assert: ((model classNamed: #Foo3) parseTreeFor: #objectName) 
		equals: (self parseMethod: 'objectName ^ #(Foo3)')
]

{ #category : #tests }
RBRenameClassTest >> testRenameClass [
	| refactoring class classA classB classC aModel |
	
	classA := ('RBClass', 'ToRename') asSymbol.
	classB := ('RBNew', 'ClassName') asSymbol.
	classC := #RBSubclassOfClassToRename.
	refactoring := self rename: (testingEnvironment at: classA) to: classB using: nil.
	self executeRefactoring: refactoring.
	
	aModel := refactoring model.
	self assert: ((aModel classNamed: classB) parseTreeFor: #method1) 		
		  		equals: (self parseMethod: 'method1
	^self method2').
	self deny: (aModel includesClassNamed: classA).
	class := aModel classNamed: classC.
	self assert: class superclass equals: (aModel classNamed: classB).
	self assert: (class parseTreeFor: #symbolReference) 
				equals: (self parseMethod: 'symbolReference
								^#RBNewClassName').
	self assert: (class parseTreeFor: #reference) 
				equals: (self parseMethod: 'reference
								^RBNewClassName new')
]

{ #category : #tests }
RBRenameClassTest >> testRenameClassFromTrait [
	| refactoring class classA classB classC aModel |
	
	classA := ('RBClass', 'ToRename') asSymbol.
	classB := ('RBNew', 'ClassName') asSymbol.
	classC := #RBDummy.
	refactoring := self rename: (testingEnvironment at: classA) to: classB using: nil.
	self executeRefactoring: refactoring.
	aModel := refactoring model.
	self assert: (aModel includesClassNamed: classB).
	self deny: (aModel includesClassNamed: classA).
	class := aModel classNamed: classC.
	self assert: (class parseTreeFor: #methodFromTrait) 
				equals: (self parseMethod: 'methodFromTrait
	RBNewClassName justForTest').
	self assert: ((refactoring model classNamed: #RBClassUsingSharedPoolForTestData) methodFor: #methodFromTrait) modelClass name equals: #RBDummy
]

{ #category : #tests }
RBRenameClassTest >> testUnmarkRemovedClassIfRenameTargetClass [
	"Unmark a removed class if we rename another class to the removed class name.
rename class A to C (class A is marked as removed)
rename class B to A
-> class A is not marked as removed (model includesClassNamed:#A -> true"

	| addClass renameClass classA classB classC |
	
	classA := ('RBClass' , 'ToRename') asSymbol.
	classB := 'TestUnmarkClassRenameSource' asSymbol.
	classC := 'TestUnmarkClassRenameTarget' asSymbol.
	addClass := RBAddClassRefactoring
		model: model
		addClass: classB
		superclass: Object
		subclasses: {}
		category: self class package name.
	self executeRefactoring: addClass.
	self assert: (model includesClassNamed: classA).
	renameClass := self renameClassNamed: classA to: classC.
	self executeRefactoring: renameClass.
	self deny: (model includesClassNamed: classA).
	self assert: (model includesClassNamed: classC).
	renameClass :=self renameClassNamed: classB to: classA.
	self executeRefactoring: renameClass.
	self deny: (model includesClassNamed: classB).
	self assert: (model includesClassNamed: classC).
	self assert: (model includesClassNamed: classA)
]
