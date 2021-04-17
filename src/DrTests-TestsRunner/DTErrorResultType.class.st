"
I model the fact that a test generated an error.
"
Class {
	#name : #DTErrorResultType,
	#superclass : #DTTestResultType,
	#category : #'DrTests-TestsRunner-Results'
}

{ #category : #factory }
DTErrorResultType class >> backgroundColor [
	^ TestResult defaultColorBackGroundForErrorTest
]

{ #category : #testing }
DTErrorResultType >> isError [
	<generated>
	^ true
]

{ #category : #accessing }
DTErrorResultType >> name [
	^ 'Error'
]
