"
Unit test for trait handling
"
Class {
	#name : #T2TraitTest,
	#superclass : #T2AbstractTest,
	#category : #'TraitsV2-Tests'
}

{ #category : #tests }
T2TraitTest >> createT1 [
	| t1 |
	t1 := self newTrait: #T1 with: 'a b c' asSlotCollection.
	t1
		compile:
			'setValues
		a := 1.
		b := 2.
		c := 3.
	'.
	t1
		compile:
			'getValues
		^ a + b + c
	'.
	^ t1
]

{ #category : #tests }
T2TraitTest >> createT2 [
	| t2 |
	t2 := self newTrait: #T2 with: 'd e f' asSlotCollection.
	t2
		compile:
			'setValues2
		d := 1.
		e := 2.
		f := 3.
	'.
	t2
		compile:
			'getValues2
		^ d + e + f + self getValues
	'.
	^ t2
]

{ #category : #tests }
T2TraitTest >> createT3 [
	| t3 |
	
	"This is a trait with a method with a pragma"
	t3 := self newTrait: #T3 with: #().
	t3
		compile:
			'aMethod
			<aPragma>
			
			^ 42
				'.

	t3 class
		compile:
			'aClassMethod
			<aPragma>
			
			^ 42
				'.

	^ t3
]

{ #category : #tests }
T2TraitTest >> testClassHavingAnInstanceVariableUsersDifferenThanUsers [
	| t1 aClass |

	t1 := self newTrait: #T1 with: #(users).

	aClass := self newClass: #C1 superclass: Object with: #() uses: {}.
	aClass class setTraitComposition: { t1 }.
	
	self assert: (aClass class allSlots anySatisfy: [:e | e name = #users]).
	self assert: (aClass class slotNamed: #users) definingClass equals: t1

]

{ #category : #tests }
T2TraitTest >> testClassTraitThatHasAPragmaHasCorrectTraitSourceAfterRecompile [
	| t3 aClass |

	t3 := self createT3.

	aClass := self newClass: #C1 superclass: Object with: #() uses: {t3}.
	
	self assert: (aClass class >> #aClassMethod) traitSource equals: t3 class asTraitComposition.
	
	(aClass class >> #aClassMethod) recompile.
	
	self assert: (aClass class >> #aClassMethod) traitSource equals: t3 class asTraitComposition.

]

{ #category : #tests }
T2TraitTest >> testClassTraits [
	| t1 t2 aClass |

	t1 := self newTrait: #T1 with: #().
	t2 := self newTrait: #T2 with: #().

	t1 classTrait compile: 'aSelector ^ 21'.
	t1 classTrait compile: 'otherSelector ^ 42'.
	
	t2 classTrait compile: 'otherSelector2 ^ 42'.

	aClass := self newClass: #C1 superclass: Object with: #() uses: {}.
	aClass class setTraitComposition: t1 classSide - { #aSelector }. 
	
	self assert: aClass otherSelector equals: 42.	

	aClass := self newClass: #C1 superclass: Object with: #() uses: {}.
	aClass class setTraitComposition: t1 classSide + t2 classSide. 
	
	self assert: aClass otherSelector equals: 42.
	self assert: aClass otherSelector2 equals: 42.
	self assert: aClass aSelector equals: 21.
	

	aClass := self newClass: #C1 superclass: Object with: #() uses: {}.
	aClass class setTraitComposition: t1 classSide @ {#anAlias -> #aSelector}. 
	
	self assert: aClass anAlias equals: 21.
	self assert: aClass aSelector equals: 21.
]

{ #category : #tests }
T2TraitTest >> testClassUsesTrait [
	| t1 superclass subclass |
	t1 := self newTrait: #T1 with: {}.
	superclass := self newClass: #Superclass with:#() uses: t1.
	subclass := self newClass: #Subclass superclass: superclass with: #() uses: {}.
	
	self assert: (superclass usesTrait: t1).
	self assert: (superclass usesTraitLocally: t1).
	self assert: (subclass usesTrait: t1).
	self assert: (subclass usesTraitLocally: t1) not.
]

{ #category : #tests }
T2TraitTest >> testClassUsingTraitsDoesNotHaveUsers [
	| t1 aClass |

	t1 := self newTrait: #T1 with: #().

	aClass := self newClass: #C1 superclass: Object with: #() uses: {t1}.
	
	self assert: (aClass class allSlots noneSatisfy: [:e | e name = #users])

]

{ #category : #'tests - empty' }
T2TraitTest >> testEmptyCompositionManagesTEmpty [
	
	| t1 |
	t1 := self newTrait: #T1 with: {} trait: TEmpty.
	
	self assert: t1 hasEmptyComposition

]

{ #category : #tests }
T2TraitTest >> testIndirectSequence [
	| t1 t2 t3 c1 obj |
	
	t1 := self createT1.
	t2 := self createT2.
	t3 := self newTrait: #T3 with: #() uses: t1 + t2.
		
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t3.

	obj := c1 new.
	obj setValues.
	obj setValues2.
	
	self assert: (TraitedClass basicUsers includesAll:  { t1 class. t2 class. t3 class. c1 class}).
	
	self assert: obj getValues equals: 6.
	self assert: obj getValues2 equals: 12
]

{ #category : #tests }
T2TraitTest >> testMethodsAddedInMetaclass [
	| t1 c1 |
	
	t1 := self createT1.
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1.
	
	self assertCollection: c1 class selectors sorted equals: TraitedClass selectors sorted.

]

{ #category : #tests }
T2TraitTest >> testMethodsAddedInMetaclassNotPresentInSubclasses [
	| t1 c1 c2 |
	
	t1 := self createT1.
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1.
	c2 := self newClass: #C2 superclass: c1 with: #() uses: {}.
	
	self assertCollection: c2 class selectors sorted equals: #().

]

{ #category : #tests }
T2TraitTest >> testMethodsAddedInMetaclassPresentInSubclassesAfterChangingSuperclass [
	| t1 c1 c2 t2 |
	
	t1 := self createT1.
	t2 := self createT2.
	
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1.
	c2 := self newClass: #C2 superclass: c1 with: #() uses: {t2}.
	
	self assertCollection: c2 class selectors sorted equals: #().
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: {}.

	self assertCollection: c2 class selectors sorted equals: TraitedClass selectors sorted.

]

{ #category : #tests }
T2TraitTest >> testMethodsAddedInMetaclassPresentInSubclassesAfterRemovingSuperclass [
	| t1 c1 c2 t2 |
	
	t1 := self createT1.
	t2 := self createT2.
	
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1.
	c2 := self newClass: #C2 superclass: c1 with: #() uses: {t2}.
	
	self assertCollection: c2 class selectors sorted equals: #().
	c1 removeFromSystem.

	self assertCollection: c2 class selectors sorted equals: TraitedClass selectors sorted.

]

{ #category : #tests }
T2TraitTest >> testRedefiningAClassAsTraitShouldRaiseError [

	self newClass: #C1.
	self should: [ self newTrait: #C1 with: #() ] raise: Error 
]

{ #category : #tests }
T2TraitTest >> testRedefiningATraitAsAClassShouldRaiseError [
	
	self newTrait: #C1 with: #().
	self should: [ 	self newClass: #C1 ] raise: Error 
]

{ #category : #tests }
T2TraitTest >> testRemovingTraitsRemoveTraitedClassMethods [
	| t1 t2 c1 |
	
	t1 := self createT1.
	t2 := self createT2.
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1 + t2.

	self assert: (c1 class includesSelector: #traits).

	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: {}.		

	self deny: (c1 class includesSelector: #traits)
]

{ #category : #tests }
T2TraitTest >> testRemovingTraitsRemoveTraitedClassMethodsWithSubclasses [
	| t1 t2 c2 c1 |
	
	t1 := self createT1.
	t2 := self createT2.
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1.
	c2 := self newClass: #C2 superclass: c1 with: '' asSlotCollection uses: t2.

	self assert: (c1 class includesSelector: #traits).
	self deny: (c2 class includesSelector: #traits).
	
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: {}.		

	self deny: (c1 class includesSelector: #traits).
	self assert: (c2 class includesSelector: #traits).
	
]

{ #category : #tests }
T2TraitTest >> testRemovingTraitsUpdatesCategories [
	| t1 t2 c1 |
	
	t1 := self createT1.
	t2 := self createT2.
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1 + t2.
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: {}.		

	c1 organization allMethodSelectors do: [:each | self assert: (c1 includesSelector: each) ].
	c1 class organization allMethodSelectors do: [:each | 
		self assert: (c1 class includesSelector: each) ]
]

{ #category : #tests }
T2TraitTest >> testSelectorsWithExplicitOrigin [
	"Obtain the subset of selectors that are defined either locally or inherited from traits. But, exclude selectors of methods from implicit traits such as TraitedClass"
	| t1 c1 |
	
	t1 := self newTrait: #T1 with: #().	
	t1 compile: 'instanceSideMethod'.
	t1 class compile: 'classSideMethod'.
	c1 := self newClass: #C1 with: #() uses: t1.
	self assertCollection: c1 selectorsWithExplicitOrigin hasSameElements: #(instanceSideMethod).
	self assertCollection: c1 class selectorsWithExplicitOrigin hasSameElements: #(classSideMethod).

]

{ #category : #tests }
T2TraitTest >> testSelectorsWithExplicitOriginNoTrait [
	"Obtain the subset of selectors that are defined either locally or inherited from traits. But, exclude selectors of methods from implicit traits such as TraitedClass"
	| c1 |	
	c1 := self newClass: #C1.
	c1 compile: 'instanceSideMethod'.
	c1 class compile: 'classSideMethod'.
	self assertCollection: c1 selectorsWithExplicitOrigin hasSameElements: #(instanceSideMethod).
	self assertCollection: c1 class selectorsWithExplicitOrigin hasSameElements: #(classSideMethod).

]

{ #category : #tests }
T2TraitTest >> testSequence [
	| t1 t2 c1 obj |
	
	t1 := self createT1.
	t2 := self createT2.
	c1 := self newClass: #C1 with: 'g h' asSlotCollection uses: t1 + t2.

	obj := c1 new.
	obj setValues.
	obj setValues2.
	
	
	self assert: (TraitedClass basicUsers includesAll:  { t1 class. t2 class. c1 class}).
	
	self assert: obj getValues equals: 6.
	self assert: obj getValues2 equals: 12
]

{ #category : #tests }
T2TraitTest >> testSettingAClassInAClassTraitCompositionShouldRaiseAnError [

	| t1 c1 |
	t1 :=  self newTrait: #T1 with: 'a' asSlotCollection.
	c1 := self newClass: #C1 with: '' asSlotCollection uses: #().

	self should: [ t1 traitComposition: c1 ] raise: Error.
	self should: [ t1 classTrait traitComposition: c1 ] raise: Error.	
]

{ #category : #tests }
T2TraitTest >> testSlotsAreNotDuplicated [
	| t1 t2 c1 |
	t1 :=  self newTrait: #T1 with: 'a' asSlotCollection.
	t2 :=  self newTrait: #T2 with: '' asSlotCollection uses: t1.
	c1 := self newClass: #C1 with: '' asSlotCollection uses: t1 + t2.

	self assert: c1 traitComposition slots size equals: c1 traitComposition slots asSet size.
	self assert: c1 traitComposition slots size equals: 1
]

{ #category : #tests }
T2TraitTest >> testSubclasses [
	| t1 t2 |
		
	t1 := self createT1.
	t2 := self newTrait: #T2 with: #(aa bb) uses: t1.

	self deny: t1 hasSubclasses.
	self deny: t2 hasSubclasses.	

	self assert: t1 subclasses isEmpty.
	self assert: t2 subclasses isEmpty.	
		
	self deny: t1 hasSubclasses.
	self deny: t2 hasSubclasses.	


]

{ #category : #tests }
T2TraitTest >> testTraitHaveUsersInstanceVariable [
	| t1 aClass |

	t1 := self newTrait: #T1 with: #(users).

	aClass := self newClass: #C1 superclass: Object with: #() uses: {t1}.
	
	self assert: (aClass allSlots anySatisfy: [:e | e name = #users]).
	self assert: (aClass slotNamed: #users) definingClass equals: t1

]

{ #category : #tests }
T2TraitTest >> testTraitThatHasAPragmaHasCorrectTraitSourceAfterRecompile [
	| t3 aClass |

	t3 := self createT3.

	aClass := self newClass: #C1 superclass: Object with: #() uses: {t3}.
	
	self assert: (aClass >> #aMethod) traitSource equals: t3 asTraitComposition.
	
	(aClass >> #aMethod) recompile.
	
	self assert: (aClass >> #aMethod) traitSource equals: t3 asTraitComposition.
]

{ #category : #tests }
T2TraitTest >> testUsingTraitInAnonymousSubClassAndRedefiningIt [
	| t1 aClass |

	t1 := self newTrait: #T1 with: #().

	aClass := Smalltalk anonymousClassInstaller make: [ :builder |
		builder superclass: Object.
		builder traitComposition: t1.
	].

	self deny: (Object subclasses includes: aClass).
	
	t1 := self newTrait: #T1 with: #(aSlot).
	self assert: (aClass hasSlotNamed: #aSlot).
	
	self deny: (Object subclasses includes: aClass).

]
