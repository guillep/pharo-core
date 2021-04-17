Class {
	#name : #RBTest,
	#superclass : #TestCase,
	#instVars : [
		'aString'
	],
	#category : #'Refactoring-Tests-Core-Data'
}

{ #category : #running }
RBTest >> someClasses [ 
	RBRefactoryTestDataApp new
]

{ #category : #running }
RBTest >> testExample1 [ 	
	self someClasses.
	aString := 'Example'.
	self assert: 4 > 5 equals: false
]

{ #category : #running }
RBTest >> testExample2 [
	"Example"
	self someClasses.
	aString := 'Example'.
	self assert: true
]

{ #category : #running }
RBTest >> testExample3 [
	"Example"
	self someClasses.
	"Comment"
	aString := 'Example'.
	self deny: false
]

{ #category : #running }
RBTest >> testExample4 [
	self assert: true.
	self deny: false
]
