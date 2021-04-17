Class {
	#name : #T2TraitChangesTest,
	#superclass : #T2AbstractTest,
	#category : #'TraitsV2-Tests'
}

{ #category : #tests }
T2TraitChangesTest >> testGeneratingTheSameTraitDoesNotProduceChanges [
	
	| t1 builder | 
	
	t1 := self newTrait: #T1 with: {}. 
	
	builder := ShiftClassBuilder new.
	builder buildEnvironment: ShSmalltalkGlobalsEnvironment new.

	Trait configureBuilder: builder withName: #T1 traitComposition: TEmpty slots: {}  packageName: 'TraitsV2-Tests-TestClasses'.
				
	builder tryToFillOldClass.
	builder detectBuilderEnhancer.
	builder builderEnhancer validateRedefinition: builder oldClass. 
	
	builder validateSuperclass.
	builder compareWithOldClass.
	
	self assertEmpty: builder changes.
]

{ #category : #tests }
T2TraitChangesTest >> testUpdatingTheSameTraitDoesNotProduceChanges [
	
	| t1 builder | 
	
	t1 := self newTrait: #T1 with: {}. 
	
	builder := ShiftClassBuilder new.
	builder buildEnvironment: ShSmalltalkGlobalsEnvironment new.

	Trait configureBuilder: builder withName: #T1 traitComposition: TEmpty slots: {}  packageName: 'TraitsV2-Tests-TestClasses'.

	builder oldClass: t1.
				
	builder tryToFillOldClass.
	builder detectBuilderEnhancer.
	builder builderEnhancer validateRedefinition: builder oldClass. 
	
	builder validateSuperclass.
	builder compareWithOldClass.
	
	self assertEmpty: builder changes.
]

{ #category : #tests }
T2TraitChangesTest >> testconfigureBuilderWithNameTraitCompositionInstanceVariableNamesPackageName [
	
	| builder | 
		
	builder := ShiftClassBuilder new.
	builder buildEnvironment: ShSmalltalkGlobalsEnvironment new.
	Trait configureBuilder: builder withName: #T1 traitComposition: {} instanceVariableNames: 'a b'  packageName: 'TraitsV2-Tests-TestClasses'.
				
	self assert: builder slots size equals: 2.
	self assert: builder slots first name equals: 'a'.
	self assert: builder slots second name equals: 'b'.
]
