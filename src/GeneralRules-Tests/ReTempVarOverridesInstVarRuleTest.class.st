"
A RBTempVarOverridesInstVarRuleTest is a test class for testing the behavior of RBTempVarOverridesInstVarRule
"
Class {
	#name : #ReTempVarOverridesInstVarRuleTest,
	#superclass : #ReAbstractRuleTestCase,
	#instVars : [
		'dummy1',
		'dummy2',
		'dummy3',
		'dummy4'
	],
	#category : #'GeneralRules-Tests-Migrated'
}

{ #category : #accessing }
ReTempVarOverridesInstVarRuleTest >> dummy1 [
	^ dummy1
]

{ #category : #accessing }
ReTempVarOverridesInstVarRuleTest >> dummy2 [
	^ dummy2
]

{ #category : #accessing }
ReTempVarOverridesInstVarRuleTest >> dummy3 [
	^ dummy3
]

{ #category : #accessing }
ReTempVarOverridesInstVarRuleTest >> dummy4 [
	^ dummy4
]

{ #category : #'test-help' }
ReTempVarOverridesInstVarRuleTest >> sampleMethod: dummy1 [
	"I override dummy1, dummy2, dummy3  "
	| dummy2 |
	dummy2 := [ :dummy3 | dummy4 := dummy1 + dummy3 ].
	^ dummy2 value: dummy1.
	
]

{ #category : #tests }
ReTempVarOverridesInstVarRuleTest >> testRule [
	| critiques |
	critiques := self myCritiquesOnMethod: self class >> #sampleMethod:.
	
	self assert: critiques size equals: 3.
	self assert: (self sourceAtChritique:  critiques first) equals: 'dummy1'.
	self assert: (self sourceAtChritique:  critiques second) equals: 'dummy2'.
	self assert: (self sourceAtChritique:  critiques third) equals: 'dummy3'.
]
