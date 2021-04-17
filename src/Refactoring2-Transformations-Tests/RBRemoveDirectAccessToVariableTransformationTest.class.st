Class {
	#name : #RBRemoveDirectAccessToVariableTransformationTest,
	#superclass : #RBTransformationTest,
	#category : #'Refactoring2-Transformations-Tests'
}

{ #category : #running }
RBRemoveDirectAccessToVariableTransformationTest >> setUp [

	super setUp.
	model := self abstractVariableTestData.
]

{ #category : #testing }
RBRemoveDirectAccessToVariableTransformationTest >> testClassVariable [

	| refactoring class |
	refactoring := (RBRemoveDirectAccessToVariableTransformation
						classVariable: 'UndoSize'
						class: #RBRefactoryChangeManager)
						asRefactoring transform.
	
	self assert: refactoring model changes changes size equals: 2.
	
	class := (refactoring model classNamed: #RBRefactoryChangeManager) theMetaClass.
	self assert: (class parseTreeFor: #initialize) 
			equals: (self parseMethod: 'initialize self nuke. self undoSize: 20').
	self assert: (class theNonMetaClass parseTreeFor: #addUndo:) 
			equals: (self parseMethod: 'addUndo: aRefactoringChange
				undo push: aRefactoringChange.
				undo size > self class undoSize
					ifTrue: [ undo removeFirst ].
				redo := OrderedCollection new')
]

{ #category : #testing }
RBRemoveDirectAccessToVariableTransformationTest >> testDoesNotDefineVariable [

	self
		shouldFail: (RBRemoveDirectAccessToVariableTransformation 
						model: model
						instanceVariable: 'instVarName1'
						class: #Bar)
						asRefactoring;
		shouldFail: (RBRemoveDirectAccessToVariableTransformation 
						classVariable: 'Foo1'
						class: #RBFooLintRuleTestData)
						asRefactoring 
]

{ #category : #testing }
RBRemoveDirectAccessToVariableTransformationTest >> testDoesNotUnderstandAccessors [

	self
		shouldFail: (RBRemoveDirectAccessToVariableTransformation 
						model: model
						instanceVariable: 'instVarName1'
						class: #Foo)
						asRefactoring;
		shouldFail: (RBRemoveDirectAccessToVariableTransformation 
						classVariable: 'RecursiveSelfRule'
						class: #RBTransformationRuleTestData)
						asRefactoring 
]

{ #category : #testing }
RBRemoveDirectAccessToVariableTransformationTest >> testInheritedName [

	self
		shouldFail: (RBRemoveDirectAccessToVariableTransformation 
						instanceVariable: 'name'
						class: #RBBasicLintRuleTestData)
						asRefactoring;
		shouldFail: (RBRemoveDirectAccessToVariableTransformation 
						classVariable: #DependentsFields
						class: #RBBasicLintRuleTestData)
						asRefactoring 
]

{ #category : #testing }
RBRemoveDirectAccessToVariableTransformationTest >> testInstanceVariable [

	| class |
	(RBRemoveDirectAccessToVariableTransformation 
		model: model
		instanceVariable: 'instVarName2'
		class: #Foo)
		asRefactoring transform.
	
	class := model classNamed: #Foo.
	self assert: (class parseTreeFor: #foo) 
			equals: (self parseMethod: 'foo ^ self instVarName2: 3')
]

{ #category : #testing }
RBRemoveDirectAccessToVariableTransformationTest >> testMetaclassFailure [

	self shouldFail: (RBRemoveDirectAccessToVariableTransformation 
							classVariable: #RecursiveSelfRule
							class: RBTransformationRuleTestData class)
							asRefactoring 
]

{ #category : #testing }
RBRemoveDirectAccessToVariableTransformationTest >> testNonExistantName [

	self
		shouldFail: (RBRemoveDirectAccessToVariableTransformation 
						instanceVariable: 'foo'
						class: #RBBasicLintRuleTestData)
						asRefactoring;
		shouldFail: (RBRemoveDirectAccessToVariableTransformation 
						classVariable: #Foo
						class: #RBBasicLintRuleTestData)
						asRefactoring 
]

{ #category : #testing }
RBRemoveDirectAccessToVariableTransformationTest >> testRefactoring [

	| refactoring class |
	refactoring := (RBRemoveDirectAccessToVariableTransformation 
						instanceVariable: 'environment'
						class: #RBNamespace)
						asRefactoring transform.
	
	self assert: refactoring model changes changes size equals: 4.

	class := refactoring model classNamed: #RBNamespace.
	self assert: (class parseTreeFor: #includesGlobal:)
		equals: (self parseMethod: 'includesGlobal: aSymbol 
			(self hasRemoved: aSymbol) ifTrue: [^false].
			(self includesClassNamed: aSymbol) ifTrue: [^true].
			self environment at: aSymbol ifAbsent: [^false].
			^ true').
	self assert: (class parseTreeFor: #initialize) 
		equals: (self parseMethod: 'initialize
	super initialize.
	changes := changeFactory compositeRefactoryChange onSystemDictionary: self environment.
	newClasses := IdentityDictionary new.
	newPackages := IdentityDictionary new.
	changedClasses := IdentityDictionary new.
	changedPackages := IdentityDictionary new.
	removedClasses := Set new.
	removedPackages := Set new.
	implementorsCache := IdentityDictionary new.
	sendersCache := IdentityDictionary new')
]

{ #category : #testing }
RBRemoveDirectAccessToVariableTransformationTest >> testTransform [

	| transformation class |
	transformation := (RBRemoveDirectAccessToVariableTransformation
							instanceVariable: 'class'
							class: #RBTransformationRuleTestData)
							transform.
	
	class := transformation model classNamed: #RBTransformationRuleTestData.
	self assert: (class parseTreeFor: #superSends)
		  equals: (self parseMethod: 
	'superSends
		| rule |
		rule := RBParseTreeRewriter new.
		rule addSearch: ''super `@message: ``@args'' 
			-> (
				[:aNode | 
				(self class withAllSubclasses 
					detect: [:each | each includesSelector: aNode selector]
					ifNone: [nil]) isNil] 
						-> ''self `@message: ``@args'').
		self rewriteUsing: rule').
	
	self assert: (class parseTreeFor: #checkMethod:)
		  equals: (self parseMethod:
	'checkMethod: aSmalllintContext 
		self class: aSmalllintContext selectedClass.
		(rewriteRule executeTree: aSmalllintContext parseTree) ifTrue: 
			[(RecursiveSelfRule executeTree: rewriteRule tree initialAnswer: false) ifFalse: 
				[builder 
					compile: rewriteRule tree printString
					in: self class
					classified: aSmalllintContext protocols]]')
]
