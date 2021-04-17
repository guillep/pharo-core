"
This rule checks if a instance or class variable shadows a global
"
Class {
	#name : #ReClassVariablesShadowingRule,
	#superclass : #ReAbstractRule,
	#category : #'GeneralRules-Migrated'
}

{ #category : #'testing-interest' }
ReClassVariablesShadowingRule class >> checksClass [

	^ true
]

{ #category : #running }
ReClassVariablesShadowingRule >> check: aClass forCritiquesDo: aCriticBlock [

	aClass definedVariables
		select: [ :variable | variable isShadowing ]
		thenDo: [ :variable | aCriticBlock cull: (self critiqueFor: aClass about: variable name) ]
]

{ #category : #accessing }
ReClassVariablesShadowingRule >> group [
	^ 'Design Flaws'
]

{ #category : #accessing }
ReClassVariablesShadowingRule >> name [
	^ 'Variable shadows a global variable'
]
