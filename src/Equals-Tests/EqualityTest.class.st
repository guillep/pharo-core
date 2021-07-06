Class {
	#name : #EqualityTest,
	#superclass : #TestCase,
	#instVars : [
		'classFactory'
	],
	#category : #'Equals-Tests'
}

{ #category : #'setUp-tearDown' }
EqualityTest >> setUp [
	super setUp.
	classFactory := ClassFactoryForTestCase new.

]

{ #category : #'setUp-tearDown' }
EqualityTest >> tearDown [
	super tearDown.
	classFactory cleanUp

]

{ #category : #testing }
EqualityTest >> testSetContainsOnlyOneInstanceOfAClassWithIVs [
	| set object class |
	class  := classFactory newSubclassOf: ComparableObjectForEqualityTest  instanceVariableNames: 'x y' classVariableNames:  ''.
	class compile: 'x: newX y: newY
		x := newX.
		y := newY'.
	class class compile: 'x: newX y: newY
		^self new
			x: newX y: newY;
			yourself'.
	set := Set new.
	10 timesRepeat: [
		object  := class x: 1 y: 2.
		set add: object].
	self assert: set size = 1.

]

{ #category : #testing }
EqualityTest >> testSetContainsOnlyOneInstanceOfAClassWithNoIVs [
	| set |
	set := Set new.
	10 timesRepeat: [set add: ComparableObjectForEqualityTest new].
	self assert: set size = 1.
	self assert: (set includes: ComparableObjectForEqualityTest new)

]

{ #category : #testing }
EqualityTest >> testSetContainsTwoInstancesOfTwoDiffrentClassesWithIVs [
	| set otherClass yetAnotherClass |
	otherClass := classFactory newSubclassOf: ComparableObjectForEqualityTest  instanceVariableNames: 'x y' classVariableNames:  ''.
	yetAnotherClass := classFactory newSubclassOf: ComparableObjectForEqualityTest  instanceVariableNames: 'x y' classVariableNames:  ''.
	{otherClass. yetAnotherClass} do: [:class|
		class compile: 'x: newX y: newY
			x := newX.
			y := newY'.
		class class compile: 'x: newX y: newY
			^self new
				x: newX y: newY;
				yourself'.
	].
	set := Set with: (otherClass x: 'abc' y: 123) with: (yetAnotherClass x: 'abc' y: 123).
	self assert: set size = 2.
	self assert: (set includes: (otherClass x: 'abc' y: 123)).
	self assert: (set includes: (yetAnotherClass x: 'abc' y: 123)).

]

{ #category : #testing }
EqualityTest >> testSetContainsTwoInstancesOfTwoDiffrentClassesWithNoIVs [
	| set otherClass |
	otherClass := classFactory newSubclassOf: ComparableObjectForEqualityTest  instanceVariableNames: '' classVariableNames:  ''.
	set := Set with: ComparableObjectForEqualityTest new with: otherClass new.
	self assert: set size = 2.
	self assert: (set includes: ComparableObjectForEqualityTest new).
	self assert: (set includes: otherClass new).


]

{ #category : #testing }
EqualityTest >> testTwoInstancesOfTheSameClassWithDifferentIvValuessAreNOTEqual [
	| class |
	class  := classFactory newSubclassOf: ComparableObjectForEqualityTest  instanceVariableNames: 'x y' classVariableNames:  ''.
	class compile: 'x: newX y: newY
		x := newX.
		y := newY'.
	class class compile: 'x: newX y: newY
		^self new
			x: newX y: newY;
			yourself'.
	self deny: (class x: 1 y: 'abc') = (class x: 1 y: 'zyx').
]

{ #category : #testing }
EqualityTest >> testTwoInstancesOfTheSameClassWithNoIVsAreEqual [
	self assert: ComparableObjectForEqualityTest new = ComparableObjectForEqualityTest new
	
]

{ #category : #testing }
EqualityTest >> testTwoInstancesOfTheSameClassWithSameIvValuessAreEqual [
	| class |
	class  := classFactory newSubclassOf: ComparableObjectForEqualityTest  instanceVariableNames: 'x y' classVariableNames:  ''.
	class compile: 'x: newX y: newY
		x := newX.
		y := newY'.
	class class compile: 'x: newX y: newY
		^self new
			x: newX y: newY;
			yourself'.
	self assert: (class x: 1 y: 'abc') = (class x: 1 y: 'abc').
]

{ #category : #testing }
EqualityTest >> testTwoInstancesOfTowDifferentClassesWithNoIVsAreNOTEqual [
	| otherClass |
	otherClass := classFactory newSubclassOf: ComparableObjectForEqualityTest  instanceVariableNames: '' classVariableNames:  ''.
	self deny: otherClass new = ComparableObjectForEqualityTest new
]
