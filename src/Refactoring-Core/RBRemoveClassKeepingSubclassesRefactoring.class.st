"
I am a refactoring for removing classes but keeping subclasses in a safe way. 

My precondition verifies that the class name exists in this namespace and the class has no references, resp. users, if this is used to remove a trait.

If this class is ""not empty"" (has methods and variables), any subclass is reparented to the superclass of this class, and all its methods and variables (instance and class) are push down in its subclasses.

Example
--------
```
(RBRemoveClassKeepingSubclassesRefactoring classNames: { #RBTransformationRuleTestData1 }) execute. 
```

"
Class {
	#name : #RBRemoveClassKeepingSubclassesRefactoring,
	#superclass : #RBRemoveClassRefactoring,
	#instVars : [
		'refactorings'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #preconditions }
RBRemoveClassKeepingSubclassesRefactoring >> initalizeRefactorings [
	
	classNames do: 
			[:each | 
			| class |
			class := self model classNamed: each.
			self pushDownMethodsOf: class. 
			self pushDownInstVarsOf: class.
			self pushDownClassVarsOf: class]
]

{ #category : #preconditions }
RBRemoveClassKeepingSubclassesRefactoring >> initialize [
	refactorings := OrderedCollection new
]

{ #category : #preconditions }
RBRemoveClassKeepingSubclassesRefactoring >> preconditions [

	^ classNames inject: self emptyCondition into: [ :sum :each | 
		  | aClassOrTrait |
		  aClassOrTrait := self model classNamed: each asSymbol.
		  aClassOrTrait ifNil: [ 
			  self refactoringFailure: 'No such class or trait' ].
		  sum & ((self preconditionIsNotMetaclass: aClassOrTrait)
		   & (self preconditionHasNoReferences: each)
		   & (self preconditionHasNoUsers: aClassOrTrait))
		  "& ( self preconditionEmptyOrHasNoSubclasses: aClassOrTrait )" ]
]

{ #category : #preconditions }
RBRemoveClassKeepingSubclassesRefactoring >> pushDownClassVarsOf: class [
	class realClass classVariables do: [ :e |
		refactorings add: (RBPushDownClassVariableRefactoring 
		variable: e key
		class: class).
	]
]

{ #category : #preconditions }
RBRemoveClassKeepingSubclassesRefactoring >> pushDownInstVarsOf: class [
	class realClass instVarNames
		do: [ :e | 
			refactorings
				add:
					(RBPushDownInstanceVariableRefactoring
						variable: e asString
						class: class) ]
]

{ #category : #preconditions }
RBRemoveClassKeepingSubclassesRefactoring >> pushDownMethodsOf: class [
	refactorings add: (RBPushDownMethodRefactoring pushDown: class realClass selectors from: class)
]

{ #category : #preconditions }
RBRemoveClassKeepingSubclassesRefactoring >> removeClasses [
	classNames do: [:each | self model removeClassKeepingSubclassesNamed: each]
]

{ #category : #preconditions }
RBRemoveClassKeepingSubclassesRefactoring >> transform [
	self initalizeRefactorings.
	refactorings do: [ :ref | ref primitiveExecute ].
	self reparentSubclasses.
	self removeClasses	
]
