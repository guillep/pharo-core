"
I am a refactoring for removing a method and those of its subclasses,
 to remove the methods use RBRemoveMethodRefactoring.

Example
-------
Script
```
(RBRemoveHierarchyMethodRefactoring 
		removeMethods: #(#msg4)
		from: RBSharedPoolForTestData) execute
```
"
Class {
	#name : #RBRemoveHierarchyMethodRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'selectors'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #removing }
RBRemoveHierarchyMethodRefactoring class >> removeMethods: selectorCollection from: aClass [
	^self new removeMethods: selectorCollection from: aClass
]

{ #category : #transforming }
RBRemoveHierarchyMethodRefactoring >> delete: selector in: aClass [
	 (aClass realClass includesSelector: selector) ifTrue: [ 
		 [self performCompositeRefactoring: (RBRemoveMethodRefactoring 
									model: self model
									removeMethods: { selector }
									from: aClass) ]
		on: RBRefactoringError 
			do: [ :ex | ( self confirm: 
				(ex messageText copyReplaceAll: 'Browse references?' with: 'Remove anyway?') )
				ifTrue:[ ex resume ] ] ]
]

{ #category : #transforming }
RBRemoveHierarchyMethodRefactoring >> deleteSelectorInSubclasses [
	class withAllSubclasses do: 
		[ :each | each implements: selectors ]
]

{ #category : #transforming }
RBRemoveHierarchyMethodRefactoring >> deleteSelectors [
	selectors do: [ :selector |
		class withAllSubclasses do: [ :aClass |
			self delete: selector in: aClass
		 ]
	 ]
]

{ #category : #transforming }
RBRemoveHierarchyMethodRefactoring >> preconditions [

	^ selectors inject: self emptyCondition into: [ :cond :selector | 
		  cond & (RBCondition definesSelector: selector in: class) ]
]

{ #category : #removing }
RBRemoveHierarchyMethodRefactoring >> removeMethods: selectorCollection from: aClass [ 
	class := self classObjectFor: aClass.
	selectors := selectorCollection
]

{ #category : #printing }
RBRemoveHierarchyMethodRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' removeMethods: '.
	selectors asArray storeOn: aStream.
	aStream nextPutAll: ' from: '.
	class storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #transforming }
RBRemoveHierarchyMethodRefactoring >> transform [ 
	self deleteSelectors
]
