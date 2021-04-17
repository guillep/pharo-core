"
I am a refactoring for creating accessors with lazy initialization for variables.

I am used by a couple of other refactorings creating new variables and accessors.

My precondition is that the variable name is defined for this class.

Example
--------
Script
```
(RBCreateAccessorsWithLazyInitializationForVariableRefactoring 
	variable: 'foo1' 
	class: RBLintRuleTestData 
	classVariable: false 
	defaultValue: '123') execute
```

After refactoring we get:
```
RBLintRuleTestData >> foo1 
	^ foo1 ifNil: [foo1 := 123]
	
RBLintRuleTestData >> foo1: anObject
	foo1 := anObject
```
"
Class {
	#name : #RBCreateAccessorsWithLazyInitializationForVariableRefactoring,
	#superclass : #RBCreateAccessorsForVariableRefactoring,
	#instVars : [
		'defaultValue'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBCreateAccessorsWithLazyInitializationForVariableRefactoring class >> model: aRBSmalltalk variable: aVarName class: aClass classVariable: aBoolean defaultValue: aString [
	^(self 
		model: aRBSmalltalk
		variable: aVarName
		class: aClass)
		classVariable: aBoolean;
		defaultValue: aString;
		yourself
]

{ #category : #'instance creation' }
RBCreateAccessorsWithLazyInitializationForVariableRefactoring class >> variable: aVarName class: aClass classVariable: aBoolean defaultValue: aString [
	^(self variable: aVarName class: aClass)
		classVariable: aBoolean;
		defaultValue: aString;
		yourself
]

{ #category : #acccessing }
RBCreateAccessorsWithLazyInitializationForVariableRefactoring >> defaultValue [
	^ defaultValue ifNil: [ defaultValue := 'nil' ]
]

{ #category : #acccessing }
RBCreateAccessorsWithLazyInitializationForVariableRefactoring >> defaultValue: aString [
	defaultValue := aString
]

{ #category : #transforming }
RBCreateAccessorsWithLazyInitializationForVariableRefactoring >> defineGetterMethod [
	| selector definingClass |
	definingClass := self definingClass.
	selector := self safeMethodNameFor: definingClass
				basedOn: variableName asString.
	definingClass 
		compile: ('<1s><r><r><t>^ <2s> ifNil: [ <2s> := <3s> ]' 
			expandMacrosWith: selector 
			with: variableName
			with: self defaultValue)
		classified: #(#accessing).
	^selector
]
