"
A SycRemoveClassStrategyTest is a test class for testing the behavior of SycRemoveClassStrategy
"
Class {
	#name : #SycRemoveClassStrategyTest,
	#superclass : #TestCase,
	#instVars : [
		'factory'
	],
	#category : #'SystemCommands-ClassCommands-Tests'
}

{ #category : #running }
SycRemoveClassStrategyTest >> setUp [
	super setUp.
	
	factory := ClassFactoryForTestCase new.
]

{ #category : #running }
SycRemoveClassStrategyTest >> tearDown [

	factory cleanUp.
	super tearDown.
]

{ #category : #tests }
SycRemoveClassStrategyTest >> testCreateStrategiesForParentClass [

	| browser strategies |
	browser := ClyFullBrowser onDefaultEnvironment.
	strategies := SycRemoveClassStrategy
		              createAllForClasses: { ClyBrowserMorph }
		              browser: browser.
	self
		assert: strategies size > 2;
		assert: (strategies anySatisfy: [ :each | 
					 each userRequestString
					 =
						 ClyNotRemoveAndShowSubclassesClassStrategy new
							 userRequestString ]);
		assert: strategies last userRequestString
		equals: SycNotRemoveClassStrategy new userRequestString
]

{ #category : #tests }
SycRemoveClassStrategyTest >> testCreateStrategiesForReferencedClass [

	| browser strategies |
	browser := ClyFullBrowser onDefaultEnvironment.
	strategies := SycRemoveClassStrategy
		              createAllForClasses: { ClyFullBrowser }
		              browser: browser.
	self
		assert: strategies size equals: 2;
		assert: strategies first userRequestString
		equals:
			ClyNotRemoveAndShowReferencesClassStrategy new userRequestString;
		assert: strategies last userRequestString
		equals: SycNotRemoveClassStrategy new userRequestString
]

{ #category : #tests }
SycRemoveClassStrategyTest >> testCreateStrategiesForRemovableClass [

	| browser class strategies |
	browser := ClyFullBrowser onDefaultEnvironment.
	class := factory newClass.
	strategies := SycRemoveClassStrategy
		              createAllForClasses: { class }
		              browser: browser.
	self
		assert: strategies size equals: 1;
		assert: strategies first userRequestString
		equals: SycSilentlyRemoveClassStrategy new userRequestString
]

{ #category : #tests }
SycRemoveClassStrategyTest >> testCreateStrategiesForUsedTrait [

	| browser strategies |
	browser := ClyFullBrowser onDefaultEnvironment.
	strategies := SycRemoveClassStrategy
		              createAllForClasses: { TRBProgramNodeVisitor }
		              browser: browser.
	self
		assert: strategies size > 2;
		assert: (strategies anySatisfy: [ :each | 
					 each userRequestString
					 = ClyNotRemoveAndShowUsersClassStrategy new userRequestString ]);
		assert: strategies last userRequestString
		equals: SycNotRemoveClassStrategy new userRequestString
]
