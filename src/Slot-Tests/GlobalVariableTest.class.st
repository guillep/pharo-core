"
Tests for GlobalVariable
"
Class {
	#name : #GlobalVariableTest,
	#superclass : #TestCase,
	#category : #'Slot-Tests-VariablesAndSlots'
}

{ #category : #'tests  - properties' }
GlobalVariableTest >> testIsReadInMethod [

	self assert: (Object binding isReadIn: self class >> testSelector).
	self deny: ((self class environment classNamed: #String) binding 
							isReadIn: self class >> testSelector).
]

{ #category : #tests }
GlobalVariableTest >> testIsShadowing [
	self deny: Object binding isShadowing
]

{ #category : #'tests  - properties' }
GlobalVariableTest >> testNotWrittenInMethod [

	self deny: (Object binding isWrittenIn: self class >> testSelector)
]

{ #category : #'tests  - properties' }
GlobalVariableTest >> testPropertyAtPut [

	| testValue |
	
	testValue := Date today.
	self class binding propertyAt: #testKeySelector put: testValue.
	self
		assert: (self class binding propertyAt: #testKeySelector)
		equals: testValue.
	self class binding removeProperty: #testKeySelector.
	self assert: self class binding properties isNil.
]

{ #category : #'tests  - properties' }
GlobalVariableTest >> testRemoveProperty [

	self class binding propertyAt: #testKeySelector put: 1.
		
	self class binding removeProperty: #testKeySelector.
	self
		assert: (self class binding propertyAt: #testKeySelector)
		equals: nil.
		
	self assert: self class binding properties isNil.
]

{ #category : #'tests  - properties' }
GlobalVariableTest >> testScope [

	self assert: Object binding scope equals: Object environment.
	self assert: (Object binding scope lookupVar: Object binding name) equals: Object binding.
]
