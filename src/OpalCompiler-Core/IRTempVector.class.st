"
I model the tempVector.

The tempvector is an array that stores all escaping variables of a block that are written to from outside.
"
Class {
	#name : #IRTempVector,
	#superclass : #IRInstruction,
	#instVars : [
		'name',
		'vars'
	],
	#category : #'OpalCompiler-Core-IR-Nodes'
}

{ #category : #visiting }
IRTempVector >> accept: aVisitor [
	^ aVisitor visitTempVector: self
]

{ #category : #accessing }
IRTempVector >> indexForVarNamed: aName [
	^vars indexOf: aName

]

{ #category : #testing }
IRTempVector >> isTempVector [
	^true
]

{ #category : #accessing }
IRTempVector >> name [
	^ name
]

{ #category : #accessing }
IRTempVector >> name: anObject [
	name := anObject
]

{ #category : #accessing }
IRTempVector >> vars [
	^ vars
]

{ #category : #accessing }
IRTempVector >> vars: anObject [
	vars := anObject.
]
