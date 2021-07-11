"
Morph and Model subclasses methods should access GUI theme via 'self theme' instead of 'Smalltalk ui theme'.
"
Class {
	#name : #ReThemeAccessRule,
	#superclass : #ReAbstractRule,
	#category : #'Renraku-Rules'
}

{ #category : #'testing-interest' }
ReThemeAccessRule class >> checksMethod [
	^ true
]

{ #category : #'class initialization' }
ReThemeAccessRule class >> initialize [
   " ReRuleManager cleanUp "
]

{ #category : #running }
ReThemeAccessRule >> check: aMethod forCritiquesDo: aCriticBlock [ 
	| problemThemes |
	((aMethod methodClass inheritsFrom: Morph) 
		or: [aMethod methodClass inheritsFrom: Model]) ifFalse: [ ^ self ].
		
	problemThemes := 
		(aMethod sendNodes select: [ :msgSend | msgSend selector = #theme 
				and: [msgSend receiver sourceCode withSeparatorsCompacted = 'Smalltalk ui'] ]).
	
	problemThemes do: [ :msgSend |
			aCriticBlock cull: (self 
				createTrivialCritiqueOn: aMethod 
				intervalOf: msgSend 
				hint: msgSend selector asString) ]
]

{ #category : #running }
ReThemeAccessRule >> group [
	^ 'API Hints'
]

{ #category : #running }
ReThemeAccessRule >> name [
	^ 'Access to UI theme.'
]

{ #category : #running }
ReThemeAccessRule >> severity [
	^ #warning
]
