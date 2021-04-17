"
Example class for ClassTest
"
Class {
	#name : #ObsoleteTest,
	#superclass : #AbstractEnvironmentTestCase,
	#instVars : [
		'classFactory'
	],
	#category : #'ReleaseTests-CleanCode'
}

{ #category : #accessing }
ObsoleteTest >> defaultTimeLimit [ 

	^ 30 seconds
]

{ #category : #running }
ObsoleteTest >> setUp [
	super setUp.
	classFactory := ClassFactoryForTestCase new
]

{ #category : #running }
ObsoleteTest >> tearDown [

	classFactory cleanUp.
	Smalltalk fixObsoleteReferences.
	super tearDown	
]

{ #category : #tests }
ObsoleteTest >> testClassObsolete [
	| aClass |
	testingEnvironment at: #ClassForObsoleteTest ifPresent: [ :cls | cls removeFromSystem ].
	aClass := classFactory newClass.
	
	self deny: aClass isObsolete.
	self deny: aClass class isObsolete.
	aClass removeFromSystem.
	self assert: aClass isObsolete.
	self assert: aClass class isObsolete
]

{ #category : #tests }
ObsoleteTest >> testFixObsoleteSharedPools [
	| poolClass obsoletePoolName testClass preFixObsoleteClassNames postFixObsoleteClassNames |
	poolClass := classFactory newClass.	"provides unique name over time via class variable counter"
	testClass := classFactory
		newSubclassOf: classFactory defaultSuperclass
		uses: {}
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: poolClass name asString
		category: classFactory defaultCategory.
	classFactory deleteClass: poolClass.
	obsoletePoolName := poolClass name.
	poolClass := nil.
	3 timesRepeat: [ Smalltalk garbageCollect ].

	preFixObsoleteClassNames := SystemNavigation default obsoleteClasses collect: [:each | each name].
	self assert: (preFixObsoleteClassNames includes: obsoletePoolName).
	self assert: testClass sharedPoolNames size equals: 1.
	self assert: (testClass sharedPoolNames includes: obsoletePoolName).
	self assert: (testClass sharedPoolsString beginsWith: 'AnObsolete').

	Smalltalk fixObsoleteSharedPools.

	postFixObsoleteClassNames := SystemNavigation default obsoleteClasses collect: #name.
	self deny: (postFixObsoleteClassNames includes: obsoletePoolName).
	self assertEmpty: testClass sharedPoolNames.
	self assertEmpty: testClass sharedPoolsString
]

{ #category : #tests }
ObsoleteTest >> testTraitObsolete [
	| aClass aTrait |
	testingEnvironment at: #ClassForObsoleteTest ifPresent: [ :cls | cls removeFromSystem ].
	testingEnvironment at: #TraitForObsoleteTest ifPresent: [ :tr | tr removeFromSystem ].
	
	aTrait := classFactory newTrait.
	aClass := classFactory newClassUsing: aTrait.
 
	self deny: aTrait isObsolete.
	aTrait removeFromSystem.
	self assert: aTrait isObsolete.
	self deny: aClass isObsolete

]
