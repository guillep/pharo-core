"
I am example class which deprecated methods
"
Class {
	#name : #ClyClassWithDeprecatedMethods,
	#superclass : #Object,
	#category : #'Calypso-SystemPlugins-Deprecation-Queries-Tests'
}

{ #category : #'protocol - deprecated' }
ClyClassWithDeprecatedMethods >> deprecatedMethod1 [
	self deprecated: 'it is deprecated method for testing deprecation analyzis'
]

{ #category : #'protocol - deprecated' }
ClyClassWithDeprecatedMethods >> deprecatedMethod2 [
	self deprecated: 'it is deprecated method for testing deprecation analyzis'
]

{ #category : #protocol }
ClyClassWithDeprecatedMethods >> notDeprecatedMethod [

]
