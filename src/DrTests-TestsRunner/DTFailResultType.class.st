"
I model the fact that a test failed.
"
Class {
	#name : #DTFailResultType,
	#superclass : #DTTestResultType,
	#category : #'DrTests-TestsRunner-Results'
}

{ #category : #factory }
DTFailResultType class >> backgroundColor [
	^ TestResult defaultColorBackGroundForFailureTest
]

{ #category : #testing }
DTFailResultType >> isFail [
	<generated>
	^ true
]

{ #category : #accessing }
DTFailResultType >> name [
	^ 'Failure'
]
