Extension { #name : #Behavior }

{ #category : #'*Polymorph-Widgets' }
Behavior >> systemIconName [

	^self isAbstract 
				ifTrue: [ #classAbstract ] 
				ifFalse: [ super systemIconName ]
]
