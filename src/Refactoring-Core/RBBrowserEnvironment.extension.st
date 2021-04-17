Extension { #name : #RBBrowserEnvironment }

{ #category : #'*Refactoring-Core' }
RBBrowserEnvironment >> classesInPackages: aColl do: aBlock [ 
	self systemDictionaryClassesDo: [ :each |
		(self includesClass: each) & (aColl anySatisfy: [ :cat | cat , '*' match: each category ])
			ifTrue: [aBlock value: each ] ]
]
