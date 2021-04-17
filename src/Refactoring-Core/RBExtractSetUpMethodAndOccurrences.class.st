"
I'm a refactoring to extract a setUp method and then searchs occurrences of it and replaces them.

Example script
--------------
```
(RBExtractSetUpMethodAndOccurrences
	extract: (17 to: 56)
	from: #testExample1
	in: RBTest) execute.
```
Before refactoring:
```
RBDataTest >> testExample1 	
	self someClasses.
	aString := 'Example'.
	self assert: 4 > 5 equals: false.
RBDataTest >> testExample2
	""Example""
	self someClasses.
	aString := 'Example'.
	self assert: true.
	
RBDataTest >> testExample3
	""Example""
	self someClasses.
	""Comment""
	aString := 'Example'.
	self deny: false.
	
RBDataTest >> testExample4
	self assert: true.
	self deny: false.
```
After refactoring:
```
RBDataTest >> setUp ""Added setUp""
	super setUp.
	self someClasses.
	aString := 'Example'.

RBDataTest >> testExample1 ""removes setUp occurrence""
	self assert: 4 > 5 equals: false
	
RBDataTest >> testExample2
	self assert: true.

RBDataTest >> testExample3
	self deny: false.

RBDataTest >> testExample4 ""this method did not change""
	self assert: true.
	self deny: false
```
"
Class {
	#name : #RBExtractSetUpMethodAndOccurrences,
	#superclass : #RBExtractMethodAndOccurrences,
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #transforming }
RBExtractSetUpMethodAndOccurrences >> extractMethodClass [
	^ RBExtractSetUpMethodRefactoring
]

{ #category : #transforming }
RBExtractSetUpMethodAndOccurrences >> findOccurrencesClass [
	^ RBFindAndReplaceSetUpRefactoring
]

{ #category : #transforming }
RBExtractSetUpMethodAndOccurrences >> transform [ 
	self extractMethod.
	self findOccurrencesOf: #setUp
]
