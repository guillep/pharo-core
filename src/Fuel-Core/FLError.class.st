"
I represent an error produced during Fuel operation.
"
Class {
	#name : #FLError,
	#superclass : #Error,
	#category : #'Fuel-Core-Errors'
}

{ #category : #private }
FLError >> isResumable [ 
	^true
]
