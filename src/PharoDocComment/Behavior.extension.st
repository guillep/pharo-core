Extension { #name : #Behavior }

{ #category : #'*PharoDocComment' }
Behavior >> hasDocComment [
	^ self methods anySatisfy: [:method | method hasDocComment ]
]
