"
I am a leaf of the results tree for the test-runner plugin.

Additionally to my superclass, I store the type of the result.
"
Class {
	#name : #DTTestLeafNode,
	#superclass : #DTTreeLeafNode,
	#instVars : [
		'type'
	],
	#category : #'DrTests-TestsRunner-Base'
}

{ #category : #'instance creation' }
DTTestLeafNode class >> content: anObject type: aTestResultType [
	^ (self content: anObject)
		type: aTestResultType;
		yourself
]

{ #category : #accessing }
DTTestLeafNode >> type [
	^ type
]

{ #category : #accessing }
DTTestLeafNode >> type: anObject [
	type := anObject
]
