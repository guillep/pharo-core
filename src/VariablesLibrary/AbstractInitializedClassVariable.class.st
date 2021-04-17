"
Intialized Class Variables define a default value as part of their definition.

The default parameter can be literal or a block.

There are two subclasses: setting the default value on class creation and lazy initialization on read.
"
Class {
	#name : #AbstractInitializedClassVariable,
	#superclass : #ClassVariable,
	#instVars : [
		'default'
	],
	#category : #'VariablesLibrary-ClassVariables'
}

{ #category : #testing }
AbstractInitializedClassVariable class >> isAbstract [

	^self == AbstractInitializedClassVariable
]

{ #category : #accessing }
AbstractInitializedClassVariable >> default: anObject [
	default := anObject
]

{ #category : #printing }
AbstractInitializedClassVariable >> printOn: aStream [
	aStream 
		store: self name;
		nextPutAll: ' => ';
		nextPutAll: self class name;
		nextPutAll: ' default: '.
	default printOn: aStream
]
