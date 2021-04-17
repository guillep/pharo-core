"
I model the fact that a test passed.
"
Class {
	#name : #DTPassResultType,
	#superclass : #DTTestResultType,
	#category : #'DrTests-TestsRunner-Results'
}

{ #category : #factory }
DTPassResultType class >> backgroundColor [
	^ TestResult defaultColorBackGroundForPassingTest
]

{ #category : #testing }
DTPassResultType >> isPass [
	<generated>
	^ true
]

{ #category : #accessing }
DTPassResultType >> name [
	^ 'Passing test'
]
