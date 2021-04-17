"
I am a refactoring for find occurrences of setUp method in owner class and in the whole hierarchy if apply.

My precondition verifies that setUp method exists in specified class, and if occurrences are found in hierarchy this method should not overwritten in hierarchy.

Example script
----------------
```
(RBFindAndReplaceSetUpRefactoring 
	of: RBTest 
	inWholeHierarchy: false) execute.
```
Before refactoring:
```
TestCase subclass: #RBTest
	instanceVariableNames: 'aString'
	classVariableNames: ''
	package: 'Example'
	
RBTest >> setUp
	self someClasses.
	aString := 'Example'.

RBTest >> someClasses.
	""initialize some classes""
	
RBTest >> testExample1 	
	self someClasses.
	aString := 'Example'.
	self assert: 4 > 5 equals: false.
	
RBTest >> testExample2
	""Example""
	self someClasses.
	aString := 'Example'.
	self assert: true.

RBTest >> testExample4
	self assert: true.
	self deny: false
```

After refactoring: 
```
RBTest >> testExample1 
	self assert: 4 > 5 equals: false.

RBTest >> testExample2
	self assert: true

RBTest >> testExample4
	self assert: true.
	self deny: false
```
"
Class {
	#name : #RBFindAndReplaceSetUpRefactoring,
	#superclass : #RBFindAndReplaceRefactoring,
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBFindAndReplaceSetUpRefactoring class >> model: aModel of: aClass inWholeHierarchy: aBoolean [
	^ self new
		model: aModel;
		of: aClass
		inWholeHierarchy: aBoolean;
		yourself
]

{ #category : #'instance creation' }
RBFindAndReplaceSetUpRefactoring class >> of: aClass inWholeHierarchy: aBoolean [
	^ self new
		of: aClass
		inWholeHierarchy: aBoolean;
		yourself
]

{ #category : #accessing }
RBFindAndReplaceSetUpRefactoring >> extractMethodRefactoring [
	^ RBExtractSetUpMethodRefactoring new
			setOption: #useExistingMethod 
			toUse:  [ :ref :aSelector | 
				true];
			setOption: #extractAssignment 
			toUse:  [ :ref :aSelector | 
				true];
			yourself 
]

{ #category : #accessing }
RBFindAndReplaceSetUpRefactoring >> methodNode [ 
	| node |
	node := super methodNode.
	node body removeNode: (RBParser parseExpression: 'super setUp.').
	^ node
]

{ #category : #accessing }
RBFindAndReplaceSetUpRefactoring >> nodesOf: methodNode [
	| combinations limit |
	
	combinations := super nodesOf: methodNode.
	^ combinations ifEmpty: [ combinations ]
		ifNotEmpty: [ limit :=  methodNode body statements first start.
		combinations select: [ :e | e first <= limit ] ]
	
]

{ #category : #'instance creation' }
RBFindAndReplaceSetUpRefactoring >> of: aClass inWholeHierarchy: aBoolean [
	class := self classObjectFor: aClass.
	selector := #setUp.
	replacesAllHierarchy := aBoolean.
]

{ #category : #preconditions }
RBFindAndReplaceSetUpRefactoring >> selectorsFor: cls [
	^ (cls selectors select: [:e | e isTestSelector]) copyWithout: selector
]

{ #category : #accessing }
RBFindAndReplaceSetUpRefactoring >> startLimitOf: sourceCode [
	^ ((self parserClass parseMethod: sourceCode) body statements first start)
]
