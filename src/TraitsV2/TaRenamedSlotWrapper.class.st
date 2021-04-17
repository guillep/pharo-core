"
When renaming Slots in a trait composition, we want to give the trait a new name but else keep the orginal semantics.

This wrapper does exactly that: as a Slot subclass, it has a name. It forwards anything else to the original slot as defined
in the trait.
"
Class {
	#name : #TaRenamedSlotWrapper,
	#superclass : #Slot,
	#instVars : [
		'originalSlot'
	],
	#category : #'TraitsV2-Compositions'
}

{ #category : #'instance creation' }
TaRenamedSlotWrapper class >> for: aSlot [
	^self new originalSlot: aSlot
]

{ #category : #'code generation' }
TaRenamedSlotWrapper >> emitStore: aMethodBuilder [
	originalSlot emitStore: aMethodBuilder
]

{ #category : #'code generation' }
TaRenamedSlotWrapper >> emitValue: aMethodBuilder [
	originalSlot emitValue: aMethodBuilder
]

{ #category : #accessing }
TaRenamedSlotWrapper >> index [
	^ originalSlot index
]

{ #category : #accessing }
TaRenamedSlotWrapper >> index: anInteger [
	originalSlot index: anInteger
]

{ #category : #testing }
TaRenamedSlotWrapper >> isVirtual [
	^originalSlot isVirtual
]

{ #category : #testing }
TaRenamedSlotWrapper >> isVisible [
	^originalSlot isVisible
]

{ #category : #accessing }
TaRenamedSlotWrapper >> originalSlot [

	^ originalSlot
]

{ #category : #accessing }
TaRenamedSlotWrapper >> originalSlot: anObject [

	originalSlot := anObject
]

{ #category : #printing }
TaRenamedSlotWrapper >> printOn: aStream [
	originalSlot printOn: aStream
]

{ #category : #'meta-object-protocol' }
TaRenamedSlotWrapper >> read: anObject [
	^ originalSlot read: anObject
]

{ #category : #'meta-object-protocol' }
TaRenamedSlotWrapper >> wantsInitialization [
	^ originalSlot wantsInitialization
]

{ #category : #'meta-object-protocol' }
TaRenamedSlotWrapper >> write: aValue to: anObject [
	^ originalSlot write: aValue to: anObject
]
