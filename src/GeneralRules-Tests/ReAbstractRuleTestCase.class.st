Class {
	#name : #ReAbstractRuleTestCase,
	#superclass : #TestCase,
	#category : #'GeneralRules-Tests-Migrated'
}

{ #category : #testing }
ReAbstractRuleTestCase class >> isAbstract [ 

	^self == ReAbstractRuleTestCase 
]

{ #category : #'test-support' }
ReAbstractRuleTestCase >> critiguesFor: ruleClass onMethod: method [
	| critiques |
	critiques := OrderedCollection new.
	ruleClass new 
		check: method forCritiquesDo:[:critique | critiques add: critique].
	^critiques 
]

{ #category : #'test-support' }
ReAbstractRuleTestCase >> myCritiques [
	| critiques |
	critiques := OrderedCollection new.
	self subjectUnderTest  new 
		check: (self class >> #sampleMethod ) forCritiquesDo:[:critique | critiques add: critique].
	^critiques 
]

{ #category : #'test-support' }
ReAbstractRuleTestCase >> myCritiquesOnClass: aClass [
	| critiques |
	critiques := OrderedCollection new.
	self subjectUnderTest new 
		check: aClass forCritiquesDo:[:critique | critiques add: critique].
	^critiques 
]

{ #category : #'test-support' }
ReAbstractRuleTestCase >> myCritiquesOnMethod: method [
	| critiques |
	critiques := OrderedCollection new.
	self subjectUnderTest  new 
		check: method forCritiquesDo:[:critique | critiques add: critique].
	^critiques 
]

{ #category : #'test-support' }
ReAbstractRuleTestCase >> sourceAtChritique: critique [
	^ critique sourceAnchor in: [ :anchor | anchor entity sourceCode atAll: anchor interval ]
]

{ #category : #'test-support' }
ReAbstractRuleTestCase >> subjectUnderTest [ 
	^(self class name allButLast: 4) asClass
]
