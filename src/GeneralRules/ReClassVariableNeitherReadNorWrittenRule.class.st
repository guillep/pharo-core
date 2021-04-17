"
This smell arises when a class variable is not both read and written. If a class variable is only read, the reads can be replaced by nil, since it could not have been assigned a value. If the variable is only written, then it does not need to store the result since it is never used.
"
Class {
	#name : #ReClassVariableNeitherReadNorWrittenRule,
	#superclass : #ReAbstractRule,
	#category : #'GeneralRules-Migrated'
}

{ #category : #'testing-interest' }
ReClassVariableNeitherReadNorWrittenRule class >> checksClass [
	^ true
]

{ #category : #running }
ReClassVariableNeitherReadNorWrittenRule >> check: aClass forCritiquesDo: aCriticBlock [
	aClass classVariables
		select: [ :variable | variable isReferenced not ]
		thenDo: [ :variable | aCriticBlock cull: (self critiqueFor: aClass about: variable name) ]
]

{ #category : #accessing }
ReClassVariableNeitherReadNorWrittenRule >> name [

	^ 'Class variable not read or not written'
]

{ #category : #accessing }
ReClassVariableNeitherReadNorWrittenRule >> severity [
	^ #information
]
