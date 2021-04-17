"
RBValueToken is the abstract superclass of all tokens that have additional information attached. For example, the BinarySelector token holds onto the actual character (e.g. $+).

Instance Variables:
	value	<String>	The value of this token


"
Class {
	#name : #RBValueToken,
	#superclass : #RBToken,
	#instVars : [
		'value'
	],
	#category : #'AST-Core-Tokens'
}

{ #category : #testing }
RBValueToken class >> isAbstract [

	^ self == RBValueToken
]

{ #category : #'instance creation' }
RBValueToken class >> value: aString start: anInteger [ 
	^self new value: aString start: anInteger
]

{ #category : #private }
RBValueToken >> length [
	^value size
]

{ #category : #printing }
RBValueToken >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	value printOn: aStream.
	aStream nextPutAll: ')'
]

{ #category : #accessing }
RBValueToken >> source [
	^ self value
]

{ #category : #accessing }
RBValueToken >> value [
	^value
]

{ #category : #accessing }
RBValueToken >> value: anObject [
	value := anObject
]

{ #category : #initialization }
RBValueToken >> value: aString start: anInteger [ 
	value := aString.
	sourcePointer := anInteger
]
