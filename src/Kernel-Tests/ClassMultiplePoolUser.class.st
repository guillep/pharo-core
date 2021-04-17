"
I'm a class using two shared pools. 
"
Class {
	#name : #ClassMultiplePoolUser,
	#superclass : #Object,
	#pools : [
		'PoolDefiner',
		'PoolDefiner2'
	],
	#category : #'Kernel-Tests-Classes'
}

{ #category : #accessing }
ClassMultiplePoolUser class >> author [

	^ AnAuthor
]

{ #category : #accessing }
ClassMultiplePoolUser class >> gloups [

	^ Gloups
]

{ #category : #accessing }
ClassMultiplePoolUser class >> variableInPoolDefiner2 [

	^ VariableInPoolDefiner2
]
