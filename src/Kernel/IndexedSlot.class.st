"
By default each Slot corresponds to an instance variable and vice versa. Hence there is a Slot for each instance variable.


"
Class {
	#name : #IndexedSlot,
	#superclass : #Slot,
	#instVars : [
		'index'
	],
	#category : #'Kernel-Variables'
}

{ #category : #comparing }
IndexedSlot >> = other [
	self == other
		ifTrue: [ ^ true ].
	^ ((self species == other species) 
			and: [ index = other index ])
			and: [ name = other name ]
]

{ #category : #comparing }
IndexedSlot >> hasSameDefinitionAs: other [
	"Definiton does not contain index"
	^super = other
]

{ #category : #comparing }
IndexedSlot >> hash [
	^ (self species hash bitXor: self name hash) bitXor: (self index ifNil: [ 0 ])
]

{ #category : #accessing }
IndexedSlot >> index [
	^ index
]

{ #category : #accessing }
IndexedSlot >> index: anIndex [
	index := anIndex
]

{ #category : #testing }
IndexedSlot >> isVirtual [
	"indexed slots are the only not virtual slots for now"
	^false
]

{ #category : #'meta-object-protocol' }
IndexedSlot >> object: anObject instVarAt: anIndex [
	"Primitive. Answer a fixed variable in an object. The numbering of the 
	 variables corresponds to the named instance variables. Fail if the index 
	 is not an Integer or is not the index of a fixed variable. Essential for the
	 debugger. See  Object documentation whatIsAPrimitive."

	<primitive: 73>
	"instead of copying the fail code here, just call the method that has it"
	^thisContext object: anObject instVarAt: anIndex
]

{ #category : #'meta-object-protocol' }
IndexedSlot >> object: anObject instVarAt: anIndex put: aValue [ 
	"Primitive. Store a value into a fixed variable in the argument anObject.
	 The numbering of the variables corresponds to the named instance
	 variables.  Fail if the index is not an Integer or is not the index of a
	 fixed variable.  Answer the value stored as the result. Using this
	 message violates the  principle that each object has sovereign control
	 over the storing of values into its instance variables. Essential for the
	 debugger. See Object documentation whatIsAPrimitive."

	<primitive: 74>
	"instead of copying the fail code here, just call the method that has it"
	^thisContext object: anObject instVarAt: anIndex put: aValue 
]

{ #category : #'meta-object-protocol' }
IndexedSlot >> read: anObject [
	^ self object: anObject instVarAt: index
]

{ #category : #'meta-object-protocol' }
IndexedSlot >> write: aValue to: anObject [
	^ self object: anObject instVarAt: index put: aValue
]
