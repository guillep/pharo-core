Class {
	#name : #RBDataTest,
	#superclass : #TestCase,
	#category : #'Refactoring-Tests-Core-Data'
}

{ #category : #tests }
RBDataTest >> someMethod [
	#'some.initializations'
]

{ #category : #tests }
RBDataTest >> testExample [
	self someMethod.
	self assert: true
]

{ #category : #tests }
RBDataTest >> testExample1 [
	| aString aNumber |
	aString := 'Some string'.
	self someMethod.
	aNumber := 4.
	self assert: aString isNotEmpty.
	self deny: (aString, aNumber asString) isEmpty.
	self assert: true
]

{ #category : #tests }
RBDataTest >> testExample2 [
	| aString aNumber |
	aString := 'sa'.
	self someMethod.
	aNumber := 4.
	self assert: aString isNotEmpty.
]
