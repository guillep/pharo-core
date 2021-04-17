"
I am example of class with abstract methods
"
Class {
	#name : #ClyAbstractClassExample,
	#superclass : #Object,
	#category : #'Calypso-SystemPlugins-InheritanceAnalysis-Queries-Tests'
}

{ #category : #protocol }
ClyAbstractClassExample >> abstractMethod1 [
	self subclassResponsibility 
]

{ #category : #protocol }
ClyAbstractClassExample >> abstractMethod2 [
	self subclassResponsibility 
]

{ #category : #protocol }
ClyAbstractClassExample >> overriddenMethod [
	^#originalValue
]
