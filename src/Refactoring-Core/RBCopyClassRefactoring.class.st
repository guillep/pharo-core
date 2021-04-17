"
I am a refactoring for copy a class.

My preconditions verify, that the copied class exists (in  the current namespace) and that the new copy class name is valid and not yet used as a global variable name 

The refactoring transformation create a new class and copy all instance and class methods of copied class.

Example
---------------
```
	(RBCopyClassRefactoring 
		copyClass: #RBFooLintRuleTestData 
		withName: #RBFooLintRuleTestData1 in: #Example1) execute. 
```
"
Class {
	#name : #RBCopyClassRefactoring,
	#superclass : #RBClassRefactoring,
	#instVars : [
		'aClass',
		'category'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #copying }
RBCopyClassRefactoring class >> copyClass: cls withName: aSymbol [
	^ self new copyClass: cls withName: aSymbol
]

{ #category : #copying }
RBCopyClassRefactoring class >> copyClass: cls withName: copyName in: aSymbol [
	^ self new
		category: aSymbol;
		copyClass: cls withName: copyName
]

{ #category : #copying }
RBCopyClassRefactoring class >> model: aRBSmalltalk copyClass: cls withName: aSymbol [
	^ self new
		model: aRBSmalltalk;
		copyClass: cls withName: aSymbol
]

{ #category : #copying }
RBCopyClassRefactoring class >> model: aRBSmalltalk copyClass: cls withName: copyName in: aSymbol [
	^ self new
		model: aRBSmalltalk;
		category: aSymbol;
		copyClass: cls withName: copyName
]

{ #category : #accessing }
RBCopyClassRefactoring >> category [

	^ category ifNil: [ category := aClass category ]
]

{ #category : #accessing }
RBCopyClassRefactoring >> category: aSymbol [
	category := aSymbol 
]

{ #category : #transforming }
RBCopyClassRefactoring >> copyClass [
	self performCompositeRefactoring: (RBAddClassRefactoring
		model: self model
		addClass: className
		superclass: aClass superclass
		subclasses: #()
		category: self category).
]

{ #category : #copying }
RBCopyClassRefactoring >> copyClass: cls withName: aName [
	self className: aName.
	aClass := self classObjectFor: cls.
]

{ #category : #transforming }
RBCopyClassRefactoring >> copyMethods [
	| newClass |
	newClass := (self model classNamed: className).
	self copyMethodsOf: aClass in: newClass.
	self copyMethodsOf: aClass classSide in: newClass classSide
]

{ #category : #copying }
RBCopyClassRefactoring >> copyMethodsOf: rbClass1 in: rbClass2 [
	rbClass1 selectors do: [ :symbol | | rbMethod |
		rbMethod := rbClass1 methodFor: symbol.
		self performCompositeRefactoringThroughWarning:
			(RBAddMethodRefactoring 
				model: self model
				addMethod: rbMethod source 
				toClass: rbClass2
				inProtocols: rbMethod protocols)
	]
]

{ #category : #preconditions }
RBCopyClassRefactoring >> preconditions [ 
	^ (RBCondition isValidClassName: className) 
		& (RBCondition isGlobal: className in: self model) not
]

{ #category : #transforming }
RBCopyClassRefactoring >> transform [
	self copyClass.
	self copyMethods.
]
