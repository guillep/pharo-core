"
I am example of class which is covered by tests using Tests sufix
 
Internal Representation and Key Implementation Points.

    Instance Variables
	one:		<Object>
	two:		<Object>
"
Class {
	#name : #ClyTestedClass,
	#superclass : #Object,
	#instVars : [
		'two',
		'one'
	],
	#category : #'Calypso-SystemPlugins-SUnit-Queries-Tests'
}

{ #category : #protocol }
ClyTestedClass class >> one: aFirstObject two: aSecondObject [
	^ self new
		one: aFirstObject
		two: aSecondObject
]

{ #category : #protocol }
ClyTestedClass class >> untestedOne: aFirstObject two: aSecondObject [
	^ self new
		one: aFirstObject;
		two: aSecondObject
]

{ #category : #accessing }
ClyTestedClass >> one [
	^ one
]

{ #category : #accessing }
ClyTestedClass >> one: anObject [
	one := anObject 
]

{ #category : #accessing }
ClyTestedClass >> one: aFirstObject two: aSecondObject [
	self
		one: aFirstObject;
		two: aSecondObject
]

{ #category : #accessing }
ClyTestedClass >> oneTwo: anObject [
	self two: anObject
]

{ #category : #accessing }
ClyTestedClass >> two [
	^ two 
]

{ #category : #accessing }
ClyTestedClass >> two: anObject [
	two := anObject
]

{ #category : #accessing }
ClyTestedClass >> untestedOne [
	^ self one
]

{ #category : #accessing }
ClyTestedClass >> untestedOne: anObject [
	self one: anObject
]

{ #category : #accessing }
ClyTestedClass >> untestedOne: aFirstObject two: aSecondObject [
	self
		one: aFirstObject;
		two: aSecondObject
]

{ #category : #accessing }
ClyTestedClass >> untestedOneTwo: anObject [
	self two: anObject
]

{ #category : #accessing }
ClyTestedClass >> untestedTwo [
	^ self two
]

{ #category : #accessing }
ClyTestedClass >> untestedTwo: anObject [
	self two: anObject
]
