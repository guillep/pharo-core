"
A SycRemoveMethodStrategyTest is a test class for testing the behavior of SycRemoveMethodStrategy
"
Class {
	#name : #SycRemoveMethodStrategyTest,
	#superclass : #TestCase,
	#category : #'SystemCommands-MethodCommands-Tests'
}

{ #category : #constants }
SycRemoveMethodStrategyTest >> referencedMethod [
	^self
]

{ #category : #constants }
SycRemoveMethodStrategyTest >> referencingMethod [
	^self referencedMethod
]

{ #category : #tests }
SycRemoveMethodStrategyTest >> testCreateStrategiesForReferencedMethod [

	| browser methods strategies |
	browser := ClyFullBrowser onDefaultEnvironment.
	methods := { (self class >> #referencedMethod) }.
	strategies := SycRemoveMethodStrategy
		              createAllForMethods: methods
		              browser: browser.
	self
		assert: (strategies anySatisfy: [ :each | 
					 each userRequestString
					 = SycSilentlyRemoveMethodStrategy new userRequestString ]);
		assert: (strategies anySatisfy: [ :each | 
					 each userRequestString
					 = ClyRemoveAndShowSendersMethodStrategy new userRequestString ]);
		assert: (strategies anySatisfy: [ :each | 
					 each userRequestString
					 = ClyNotRemoveAndShowSendersMethodStrategy new userRequestString ]);
		assert: (strategies anySatisfy: [ :each | 
					 each userRequestString
					 = SycNotRemoveMethodStrategy new userRequestString ])
]

{ #category : #tests }
SycRemoveMethodStrategyTest >> testCreateStrategiesForRemovableMethod [

	| browser methods strategies |
	browser := ClyFullBrowser onDefaultEnvironment.
	methods := { (self class >> #referencingMethod) }.
	strategies := SycRemoveMethodStrategy
		              createAllForMethods: methods
		              browser: browser.
	self assert: strategies size equals: 1.
	self
		assert: strategies first userRequestString
		equals: SycSilentlyRemoveMethodStrategy new userRequestString
]
