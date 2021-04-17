"
Checks for instance variables that might better be defined as temporary variables. If an instance variable is only used in one method and it is always assigned before it is used, then that method could define that variable as a temporary variable of the method instead (assuming that the method is not recursive).
"
Class {
	#name : #ReVariableReferencedOnceRule,
	#superclass : #ReAbstractRule,
	#category : #'GeneralRules-Migrated'
}

{ #category : #testing }
ReVariableReferencedOnceRule class >> checksClass [
	^ true
]

{ #category : #accessing }
ReVariableReferencedOnceRule class >> uniqueIdentifierName [
	"This number should be unique and should change only when the rule completely change semantics"
	
	^'VariableReferencedOnceRule'
]

{ #category : #running }
ReVariableReferencedOnceRule >> check: aClass forCritiquesDo: aCriticBlock [
		aClass slots do: [ :slot | 
		  | usingMethods |
		  usingMethods := slot usingMethods.
		  usingMethods size = 1 ifFalse:  [ ^ self ].
		  (RBReadBeforeWrittenTester
				  isVariable: slot name
				  writtenBeforeReadIn: usingMethods first ast) ifTrue: [aCriticBlock cull: (self critiqueFor: aClass about: slot  name)   ]]
		

]

{ #category : #accessing }
ReVariableReferencedOnceRule >> group [
	^ 'Design Flaws'
]

{ #category : #accessing }
ReVariableReferencedOnceRule >> name [
	^ 'Variable referenced in only one method and always assigned first'
]

{ #category : #accessing }
ReVariableReferencedOnceRule >> severity [
	^ #information
]
