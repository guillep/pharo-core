Class {
	#name : #RGBehaviorTest,
	#superclass : #RGTest,
	#category : #'Ring-Tests-Core'
}

{ #category : #tests }
RGBehaviorTest >> behaviorClass [

	^ RGClass
]

{ #category : #tests }
RGBehaviorTest >> testBadInstantiation [

	self should: [ RGBehavior named: #SomeBehavior ] raise: RGBadInstantiationError 
]

{ #category : #tests }
RGBehaviorTest >> testBehaviorWithMethodTags [
	| newBehavior |
	newBehavior := self behaviorClass named: #SomeClass.
	self assert: newBehavior name equals: #SomeClass.
	self assert: (newBehavior hasUnresolvedAll: #(superclass localMethods protocols)).
	self assert: newBehavior methods isEmpty.

	1 to: 10 do: [ :i | newBehavior addMethodTag: ('tag' , i asString) asSymbol ].

	self assert: (newBehavior hasResolved: #tagsForMethods).

	self assert: (newBehavior tagsForMethods allSatisfy: #isSymbol).

	self assert: newBehavior tagsForMethods size equals: 10.
	(newBehavior tagsForMethods first: 4) do: [ :each | newBehavior removeMethodTag: each ].
	self assert: newBehavior tagsForMethods size equals: 6.
	newBehavior cleanTagsForMethods.
	self assert: newBehavior tagsForMethods isEmpty
]

{ #category : #tests }
RGBehaviorTest >> testBehaviorWithProtocols [
	| newBehavior |
	newBehavior := self behaviorClass named: #SomeClass.
	self assert: newBehavior name equals: #SomeClass.
	self assert: (newBehavior hasUnresolvedAll: #(superclass localMethods protocols)).
	self assert: newBehavior methods isEmpty.

	1 to: 10 do: [ :i | newBehavior addMethodTag: ('tag' , i asString) asSymbol ].

	self assert: (newBehavior protocols allSatisfy: #isSymbol).

	self assert: newBehavior protocols size equals: 10.
	(newBehavior protocols first: 4) do: [ :each | newBehavior removeProtocol: each ].
	self assert: newBehavior protocols size equals: 6.
	newBehavior cleanProtocols.
	self assert: newBehavior protocols isEmpty
]

{ #category : #tests }
RGBehaviorTest >> testOldDefinition [
	| newBehavior |
	newBehavior := self behaviorClass named: #SomeClass.
	self assert: newBehavior oldDefinition equals: 'unresolved subclass: #SomeClass
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''
	category: ''unresolved'''
]

{ #category : #tests }
RGBehaviorTest >> testResolvingConsistency [

	| anObject |
	anObject := RGClass unnamed.
	self checkClassesConsistency: anObject and: anObject makeResolved
]

{ #category : #tests }
RGBehaviorTest >> testSiblings [
	| newBehavior |
	
	newBehavior := RGClass named: #SomeBehaivor.
	self assert: newBehavior sibling equals: newBehavior metaclass.
	self assert: newBehavior baseBehavior equals: newBehavior.
	self assert: newBehavior instanceSide equals: newBehavior.
	self assert: newBehavior theNonMetaClass equals: newBehavior.
	
	newBehavior := RGMetaclass named: #SomeBehaivor.
	self assert: newBehavior sibling equals: newBehavior baseClass.
	self assert: newBehavior baseBehavior equals: newBehavior baseClass.
	self assert: newBehavior instanceSide equals: newBehavior baseClass.
	self assert: newBehavior theNonMetaClass equals: newBehavior baseClass.

	newBehavior := RGTrait named: #SomeBehaivor.
	self assert: newBehavior sibling equals: newBehavior classTrait.
	self assert: newBehavior baseBehavior equals: newBehavior.
	self assert: newBehavior instanceSide equals: newBehavior.
	self assert: newBehavior theNonMetaClass equals: newBehavior.

	newBehavior := RGMetaclassTrait named: #SomeBehaivor.
	self assert: newBehavior sibling equals: newBehavior baseTrait.
	self assert: newBehavior baseBehavior equals: newBehavior baseTrait.
	self assert: newBehavior instanceSide equals: newBehavior baseTrait.
	self assert: newBehavior theNonMetaClass equals: newBehavior baseTrait.


]

{ #category : #tests }
RGBehaviorTest >> testUnresolveSuperclass [
	| env class1 class2 |
	
	env := RGEnvironment new.
	class1 := env ensureClassNamed: #Superclass.
	class2 := env ensureClassNamed: #Subclass.
	
	self deny: class2 hasResolvedSuperclass. 
	class2 superclass: class1.
	self assert: class2 hasResolvedSuperclass. 
	class2 unresolveSuperclass.
	self deny: class2 hasResolvedSuperclass. 
	
	self assert: class1 subclasses isEmpty.

]
