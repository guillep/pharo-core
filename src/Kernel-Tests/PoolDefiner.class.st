"
A pool used for testing purposes
"
Class {
	#name : #PoolDefiner,
	#superclass : #SharedPool,
	#classVars : [
		'AnAuthor',
		'Gloups'
	],
	#category : #'Kernel-Tests-Classes'
}

{ #category : #initialization }
PoolDefiner class >> initialize [
	"self initialize"
	
	Gloups := 42.
	AnAuthor := 'Ducasse'.
]
