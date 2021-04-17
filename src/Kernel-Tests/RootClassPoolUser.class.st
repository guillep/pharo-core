"
I'm a class using a single shared pool (which hides a system class). My subclasses should be able to 
access the class variable defined in the pool I use. 
"
Class {
	#name : #RootClassPoolUser,
	#superclass : #Object,
	#pools : [
		'PoolDefiner'
	],
	#category : #'Kernel-Tests-Classes'
}

{ #category : #accessing }
RootClassPoolUser class >> author [

	^  AnAuthor
]

{ #category : #accessing }
RootClassPoolUser class >> gloups [

	^  Gloups
]
