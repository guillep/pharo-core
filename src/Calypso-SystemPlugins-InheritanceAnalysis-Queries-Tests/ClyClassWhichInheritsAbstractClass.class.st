"
I am example of class which inherits from abstract superclass
"
Class {
	#name : #ClyClassWhichInheritsAbstractClass,
	#superclass : #ClyAbstractClassExample,
	#category : #'Calypso-SystemPlugins-InheritanceAnalysis-Queries-Tests'
}

{ #category : #protocol }
ClyClassWhichInheritsAbstractClass >> abstractMethod1 [
	^#result
]

{ #category : #protocol }
ClyClassWhichInheritsAbstractClass >> notOverriddenMethod [

]

{ #category : #protocol }
ClyClassWhichInheritsAbstractClass >> overriddenMethod [
	^#newValue
]
