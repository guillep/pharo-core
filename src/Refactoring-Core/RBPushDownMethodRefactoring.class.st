"
I am a refactoring for moving a method down to all direct subclasses.

My preconditions verify that this method isn't refered  as a super send in the subclass. And the class defining this method is abstract or not referenced anywhere.


"
Class {
	#name : #RBPushDownMethodRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'selectors'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBPushDownMethodRefactoring class >> model: aRBSmalltalk pushDown: selectorCollection from: aClass [ 
	^(self new)
		model: aRBSmalltalk;
		pushDown: selectorCollection from: aClass;
		yourself
]

{ #category : #'instance creation' }
RBPushDownMethodRefactoring class >> pushDown: selectorCollection from: aClass [ 
	^self new pushDown: selectorCollection from: aClass
]

{ #category : #preconditions }
RBPushDownMethodRefactoring >> preconditions [

	| condition |
	condition := selectors
		             inject: self emptyCondition
		             into: [ :cond :each | 
			             cond & (RBCondition definesSelector: each in: class)
			             &
			             (RBCondition subclassesOf: class referToSelector: each)
				             not ].
	^ condition & (RBCondition isAbstractClass: class)
]

{ #category : #transforming }
RBPushDownMethodRefactoring >> pushDown: aSelector [ 
	| code protocols refactoring |
	code := class sourceCodeFor: aSelector.
	protocols := class protocolsFor: aSelector.
	refactoring := RBExpandReferencedPoolsRefactoring 
				model: self model
				forMethod: (class parseTreeFor: aSelector)
				fromClass: class
				toClasses: class subclasses.
	self performCompositeRefactoring: refactoring.
	class subclasses do: 
			[:each | 
			(each directlyDefinesMethod: aSelector) 
				ifFalse: [each compile: code classified: protocols]]
]

{ #category : #initialization }
RBPushDownMethodRefactoring >> pushDown: selectorCollection from: aClass [ 
	class := self classObjectFor: aClass.
	selectors := selectorCollection
]

{ #category : #transforming }
RBPushDownMethodRefactoring >> selectors [
	^ selectors
]

{ #category : #transforming }
RBPushDownMethodRefactoring >> selectors: aList [
	selectors := aList
]

{ #category : #printing }
RBPushDownMethodRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' pushDown: '.
	selectors asArray storeOn: aStream.
	aStream nextPutAll: ' from: '.
	class storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #preconditions }
RBPushDownMethodRefactoring >> targetClass [
	^ class
]

{ #category : #transforming }
RBPushDownMethodRefactoring >> transform [
	selectors do: [:each | self pushDown: each].
	selectors do: [:each | class removeMethod: each]
]
