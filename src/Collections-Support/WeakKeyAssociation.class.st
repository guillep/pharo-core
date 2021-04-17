"
I am an association holding only weakly on my key.
"
Class {
	#name : #WeakKeyAssociation,
	#superclass : #Magnitude,
	#type : #weak,
	#instVars : [
		'value'
	],
	#category : #'Collections-Support-Associations'
}

{ #category : #'instance creation' }
WeakKeyAssociation class >> expired [
	"Answer an object that is already expired. Used for printing"
	^(self key: nil value: nil)
		expire;
		yourself
]

{ #category : #'instance creation' }
WeakKeyAssociation class >> key: newKey value: newValue [
	"Answer an instance of me with the arguments as the key and value of 
	the association."

	^(self basicNew: 1) key: newKey value: newValue
]

{ #category : #testing }
WeakKeyAssociation >> < aLookupKey [ 
	"Refer to the comment in Magnitude|<."

	^self key < aLookupKey key
]

{ #category : #comparing }
WeakKeyAssociation >> = aLookupKey [
	"XXX why doesn't this consider the value? mvl"

	^ self species = aLookupKey species
		ifTrue: [ self key = aLookupKey key ]
		ifFalse: [ false ]
]

{ #category : #accessing }
WeakKeyAssociation >> expire [
    "Release the value if the key has gone. Return true if a modification was made."
	(self basicAt: 1) ifNil:[
		value == self ifTrue:[^false].
		value := self.
		^true
	].
	^false
]

{ #category : #accessing }
WeakKeyAssociation >> expired [
	^value == self
]

{ #category : #comparing }
WeakKeyAssociation >> hash [
	"Hash is reimplemented because = is implemented."

	^self key hash
]

{ #category : #generated }
WeakKeyAssociation >> isVariableBinding [

	"Return true if I represent a literal variable binding"

	self
		deprecated: 'Use #isAssociation instead'
		transformWith: '`@rec isVariableBinding' -> '`@rec isAssociation'.
	^ self isAssociation
]

{ #category : #accessing }
WeakKeyAssociation >> key [
	"Answer the lookup key of the receiver."

	^self basicAt: 1
]

{ #category : #accessing }
WeakKeyAssociation >> key: anObject [ 
	"Store the argument, anObject, as the lookup key of the receiver."

	self basicAt: 1 put:  anObject
]

{ #category : #accessing }
WeakKeyAssociation >> key: aKey value: anObject [ 
	"Store the arguments as the variables of the receiver."

	self basicAt: 1 put: aKey.
	value := anObject
]

{ #category : #accessing }
WeakKeyAssociation >> name [

	^ self key isString
		ifTrue: [self key]
		ifFalse: [self key printString]
]

{ #category : #printing }
WeakKeyAssociation >> printOn: aStream [

	self key printOn: aStream.
	aStream nextPutAll: '->'.
	value printOn: aStream
]

{ #category : #printing }
WeakKeyAssociation >> storeOn: aStream [
	"Store in the format (WeakKeyAssociation key: theKey value: theValue)"
	aStream 
		nextPut: $(;
		nextPutAll: self class name.
	self expired ifTrue:[
		aStream nextPutAll: ' expired'
	] ifFalse: [
		aStream nextPutAll:' key: '.
		self key storeOn: aStream.
		aStream nextPutAll: ' value:'.
		value storeOn: aStream.
	].
	aStream nextPut: $)
]

{ #category : #accessing }
WeakKeyAssociation >> value [
	"Answer the value of the receiver."

	^ value == self ifTrue:[nil] ifFalse:[value]
]

{ #category : #accessing }
WeakKeyAssociation >> value: anObject [ 
	"Store the argument, anObject, as the value of the receiver."

	anObject == self ifTrue: [self error: 'Using the WeakAssociation as its own value'].
	value := anObject
]
