"
Same as SmalllintManifestChecker but with tweaks for Renraku model 
"
Class {
	#name : #ReSmalllintChecker,
	#superclass : #SmalllintManifestChecker,
	#instVars : [
		'methodRules',
		'nodeRules',
		'classRules',
		'packageRules',
		'critiques'
	],
	#category : #'Renraku-CriticBrowser'
}

{ #category : #adding }
ReSmalllintChecker >> addCritique: aCritique [
		^ critiques add: aCritique
]

{ #category : #private }
ReSmalllintChecker >> checkClass: aClass [

	(environment includesClass: aClass) ifFalse: [ ^ self ].

	self getCritiquesAbout: aClass by: classRules
]

{ #category : #private }
ReSmalllintChecker >> checkMethodsForClass: aClass [
	
	environment
		selectorsForClass: aClass
		do: [ :selector | | method ast |
			method := aClass>>selector.
			self getCritiquesAbout: method by: methodRules.
			nodeRules do: [ :r |
				ast := method ast.
				"for rewrite rules, we run every rule on a copy of the ast"
				r isRewriteRule ifTrue: [ ast := ast copy  ].
				ast nodesDo: [ :node |
						r
							check: node
							forCritiquesDo: [ :crit |
								crit sourceAnchor initializeEnitity: method.
								self addCritique: crit ] ] ]] 
]

{ #category : #private }
ReSmalllintChecker >> checkPackage: aPackage [

	(environment includesPackage: aPackage) ifTrue: [
		self getCritiquesAbout: aPackage by: packageRules ]
]

{ #category : #accessing }
ReSmalllintChecker >> criticsOf: aRule [

	^ critiques
		select: [ :c | c rule class = aRule class ]
]

{ #category : #manifest }
ReSmalllintChecker >> falsePositiveOf: aRule [

	| ruleCritiques rId rV mb |

	ruleCritiques := self criticsOf: aRule.
	rId := aRule class uniqueIdentifierName.
	rV := aRule class identifierMinorVersionNumber.
	^ ruleCritiques
		select: [ :critique | 
			| entity |

			entity := critique sourceAnchor entity.
			mb := self manifestBuilderOf: entity.
			mb ifNil: [ false ] ifNotNil: [ mb isFalsePositive: entity onRule: rId version: rV ]
			]
]

{ #category : #private }
ReSmalllintChecker >> getCritiquesAbout: anEntity by: rules [

	rules do: [ :r |
		[ r
			check: anEntity
			forCritiquesDo: [ :crit |
				self addCritique: crit ] ]
			
			on: Error
			do: [ :er | ReSettings showErrors ifTrue: [ er pass ]  ] ]
]

{ #category : #initialization }
ReSmalllintChecker >> initialize [
	super initialize.
	self resetResult 
]

{ #category : #private }
ReSmalllintChecker >> reParseRule [

	methodRules := Set new.
	nodeRules := Set new.
	classRules := Set new.
	packageRules := Set new.

	self rule do: [ :r | 
		r class checksMethod ifTrue: [ methodRules add: r ].
		r class checksNode ifTrue: [ nodeRules add: r ].
		r class checksClass ifTrue: [ classRules add: r ] ]
]

{ #category : #running }
ReSmalllintChecker >> resetResult [

	critiques := Set new
]

{ #category : #accessing }
ReSmalllintChecker >> rule [
	
	^ (rule isKindOf: RBCompositeLintRule)
		ifTrue: [ rule leaves ]
		ifFalse: [ rule ]
]

{ #category : #actions }
ReSmalllintChecker >> run [
	self reParseRule.
	super run
]

{ #category : #manifest }
ReSmalllintChecker >> toDoOf: aRule [

	| ruleCritiques rId rV mb |

	ruleCritiques := self criticsOf: aRule.
	rId := aRule class uniqueIdentifierName.
	rV := aRule class identifierMinorVersionNumber.
	^ ruleCritiques
		select: [ :critique | 
			| entity |

			entity := critique sourceAnchor entity.
			mb := self manifestBuilderOf: entity.
			mb ifNil: [ false ] ifNotNil: [ mb containsToDo: entity onRule: rId version: rV ]
			]
]
