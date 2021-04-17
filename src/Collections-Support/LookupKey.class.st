"
I represent a key for looking up entries in a data structure. Subclasses of me, such as Association, typically represent dictionary entries.
"
Class {
	#name : #LookupKey,
	#superclass : #Magnitude,
	#instVars : [
		'key'
	],
	#category : #'Collections-Support-Associations'
}

{ #category : #'instance creation' }
LookupKey class >> key: aKey [ 
	"Answer an instance of me with the argument as the lookup up."

	^self basicNew key: aKey
]

{ #category : #testing }
LookupKey >> < aLookupKey [ 
	"Refer to the comment in Magnitude|<."

	^key < aLookupKey key
]

{ #category : #comparing }
LookupKey >> = aLookupKey [
	^ self species = aLookupKey species
		ifTrue: [ key = aLookupKey key ]
		ifFalse: [ false ]
]

{ #category : #comparing }
LookupKey >> hash [
	"Hash is reimplemented because = is implemented."

	^key hash
]

{ #category : #generated }
LookupKey >> isVariableBinding [

	"Return true if I represent a literal variable binding"

	self
		deprecated: 'Use #isAssociation instead'
		transformWith: '`@rec isVariableBinding' -> '`@rec isAssociation'.
	^ self isAssociation
]

{ #category : #accessing }
LookupKey >> key [
	"Answer the lookup key of the receiver."

	^key
]

{ #category : #accessing }
LookupKey >> key: anObject [ 
	"Store the argument, anObject, as the lookup key of the receiver."

	key := anObject
]

{ #category : #accessing }
LookupKey >> name [

	^ self key isString
		ifTrue: [self key]
		ifFalse: [self key printString]
]

{ #category : #printing }
LookupKey >> printOn: aStream [

	key printOn: aStream
]
