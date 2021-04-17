"
I am example of abstact class which is subclass of another abstract class.
I define new extra abstract methods
"
Class {
	#name : #ClyAbstractSubclassExample,
	#superclass : #ClyAbstractClassExample,
	#category : #'Calypso-SystemPlugins-InheritanceAnalysis-Queries-Tests'
}

{ #category : #protocol }
ClyAbstractSubclassExample >> abstractMethod1 [
]

{ #category : #protocol }
ClyAbstractSubclassExample >> abstractSubclassMethod [
	self subclassResponsibility 
]
