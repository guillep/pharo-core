"
Used to create intentional hash collisions in tests, to test that collision handling is done correctly.
"
Class {
	#name : #ObjectWithSettableHash,
	#superclass : #Object,
	#instVars : [
		'hash'
	],
	#category : #'Collections-Unordered-Tests-Dictionaries'
}

{ #category : #comparing }
ObjectWithSettableHash >> hash [

	^ hash
]

{ #category : #accessing }
ObjectWithSettableHash >> hash: anObject [

	hash := anObject
]

{ #category : #initialization }
ObjectWithSettableHash >> initialize [

	"Make sure hash answers a SmallInteger, even if we haven't set it yet."

	super initialize.
	hash := 0
]
