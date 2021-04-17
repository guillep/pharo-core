"
I am a class variable that can initialize itself class creation.

#name => InitializedClassVariable default: 5.

#name => InitializedClassVariable defaultBlock: [ 'a block' ].

#name => InitializedClassVariable defaultBlock: [ :class | 'a block, parameter is the class' ].
"
Class {
	#name : #InitializedClassVariable,
	#superclass : #AbstractInitializedClassVariable,
	#category : #'VariablesLibrary-ClassVariables'
}

{ #category : #'class building' }
InitializedClassVariable >> installingIn: aClass [
	default isBlock 
		ifTrue: [ self write: (default cull: aClass) ]
		ifFalse: [ self write: default ]
]
