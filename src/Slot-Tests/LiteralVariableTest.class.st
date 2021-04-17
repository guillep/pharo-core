Class {
	#name : #LiteralVariableTest,
	#superclass : #TestCase,
	#classVars : [
		'TestVariable'
	],
	#category : #'Slot-Tests-VariablesAndSlots'
}

{ #category : #tests }
LiteralVariableTest >> testComparison [

	| var1 var2 |
	var1 := LiteralVariable key: #var1 value: 'value1'.
	var2 := LiteralVariable key: #var1 value: 'value1' copy.
	self assert: var1 equals: var2.
	self assert: var1 hash equals: var2 hash.

	var2 value: #value2.
	self deny: var1 equals: var2.
	self deny: var1 equals: #var1 -> var1 value

]

{ #category : #tests }
LiteralVariableTest >> testIsReferenced [
	self assert: (SmalltalkImage classVariableNamed: #CompilerClass) isReferenced.
	TestVariable.
	self assert: (self class classVariableNamed: #TestVariable) isReferenced
]

{ #category : #tests }
LiteralVariableTest >> testIsVariableBinding [

	| var1 |
	var1 := LiteralVariable key: #var1 value: #value1.
	
	self assert: var1 isVariableBinding
]

{ #category : #tests }
LiteralVariableTest >> testLiteralEquality [

	| var1 var2 |
	var1 := LiteralVariable key: #var1 value: #value1.
	self assert: (var1 literalEqual: var1).
	
	var2 := LiteralVariable key: #var1 value: #value1.
	self deny: (var1 literalEqual: var2).
]
