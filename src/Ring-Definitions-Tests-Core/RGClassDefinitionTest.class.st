"
SUnit tests for class definitions
"
Class {
	#name : #RGClassDefinitionTest,
	#superclass : #TestCase,
	#category : #'Ring-Definitions-Tests-Core-Base'
}

{ #category : #testing }
RGClassDefinitionTest >> testAddingMethods [
	| newMethod newClass |
	newClass := RGClassDefinition named: #OrderedCollection.
	newMethod := (RGMethodDefinition named: #add:)
		parent: newClass;
		protocol: 'adding';
		sourceCode:
			'add: newObject
									^self addLast: newObject'.

	self assert: newMethod isMetaSide not.
	self assert: newClass hasMethods not.

	newClass addMethod: newMethod.
	newClass
		addSelector: #size
		classified: 'accessing'
		sourced:
			'fakeMethod
							^lastIndex - firstIndex + 1'.

	self assert: newClass hasMethods.
	self assert: newClass selectors asSet equals: #(add: size) asSet.
	self assert: (newClass includesSelector: #add:).
	self assert: (newClass methodNamed: #add:) equals: newMethod.
	self assert: newClass methods size equals: 2.
	self assert: newClass selectors size equals: 2.
	self assert: newClass allSelectors size equals: 2.	"no hierarchy"

	newMethod := newClass methodNamed: #size.
	self assert: newMethod parent equals: newClass.

	self assert: (newClass compiledMethodNamed: #size) notNil.
	self assert: (newClass compiledMethodNamed: #fakeMethod) isNil
]

{ #category : #testing }
RGClassDefinitionTest >> testAsClassDefinition [
	| newClass |
	newClass := OrderedCollection asRingDefinition.

	self assert: newClass isRingObject.
	self assert: newClass isClass.
	self assert: newClass name identicalTo: #OrderedCollection.
	self assert: newClass category notNil.
	self assert: newClass superclassName notNil.

	self assert: newClass classSide isRingObject.
	self assert: newClass classSide isClass
]

{ #category : #testing }
RGClassDefinitionTest >> testAsClassDefinition2 [
	| newClass |
	newClass := MOPTestClassC asRingDefinition.

	self assert: newClass isRingObject.
	self assert: newClass isClass.
	self assert: newClass name identicalTo: #MOPTestClassC.
	self assert: newClass category notNil.
	self assert: newClass superclassName notNil.
	self assert: newClass traitCompositionSource equals: 'Trait2'.

	self assert: newClass classSide isRingObject.
	self assert: newClass classSide isClass.
	self assert: newClass classSide traitCompositionSource equals: 'Trait2 classTrait'
]

{ #category : #testing }
RGClassDefinitionTest >> testAsClassDefinitionSourceDefinition [
	| newClass |
	newClass := MOPTestClassC asRingDefinition.
	self
		assert: newClass definitionSource 
		equals: (ClassDefinitionPrinter new for: MOPTestClassC) definitionString.

	self
		assert: newClass classSide definitionSource
		equals: (ClassDefinitionPrinter new for: MOPTestClassC class) definitionString
]

{ #category : #testing }
RGClassDefinitionTest >> testAsRingDefinition [
	self assert: OrderedCollection asRingDefinition asRingDefinition isRingObject
]

{ #category : #testing }
RGClassDefinitionTest >> testClassEquality [
	| newClass |
	self assert: OrderedCollection asRingDefinition equals: OrderedCollection asRingDefinition.

	newClass := OrderedCollection asRingDefinition category: #Kernel.
	self assert: OrderedCollection asRingDefinition equals: newClass
]

{ #category : #testing }
RGClassDefinitionTest >> testExistingClass [
	| newClass metaClass |
	newClass := RGClassDefinition named: #OrderedCollection.
	self assert: newClass isClass.
	self assert: newClass isDefined.
	self assert: newClass realClass equals: OrderedCollection.
	self assert: newClass isMeta not.

	newClass withMetaclass.
	self assert: newClass hasMetaclass.
	metaClass := newClass classSide.
	self assert: metaClass isMeta.
	self assert: metaClass name equals: 'OrderedCollection class'.
	self assert: metaClass instanceSide equals: newClass.
	self assert: metaClass realClass equals: OrderedCollection class
]

{ #category : #testing }
RGClassDefinitionTest >> testNonExistingClass [
	| newClass |
	newClass := RGClassDefinition named: #Connection.
	self assert: newClass isClass.
	self assertEmpty: newClass instanceVariables.
	self assertEmpty: newClass classVariables.
	self assertEmpty: newClass sharedPools.
	self assert: newClass hasMetaclass not.
	self assert: newClass hasComment not.
	self assert: newClass hasStamp not.
	self assert: newClass parent equals: Smalltalk globals.
	self assert: newClass package isNil.
	self assert: newClass category isNil.
	self assert: newClass hasMethods not.
	self assert: newClass hasSuperclass not.
	self assert: newClass hasTraitComposition not.
	self assert: newClass isDefined not.
	self assert: newClass hasProtocols not
]

{ #category : #testing }
RGClassDefinitionTest >> testReadFrom [
	| st rg |
	rg := Point asRingDefinition.
	st := String
		streamContents: [ :s | 
			rg storeOn: s.
			s contents ].
	self assert: (Object readFrom: st) equals: rg.

	rg := Point class asRingDefinition.
	st := String
		streamContents: [ :s | 
			rg storeOn: s.
			s contents ].
	self assert: (Object readFrom: st) equals: rg
]

{ #category : #testing }
RGClassDefinitionTest >> testRemovingMethods [
	| newMethod newClass |
	newClass := RGClassDefinition named: #OrderedCollection.
	newMethod := (RGMethodDefinition named: #add:)
		parent: newClass;
		protocol: 'adding';
		sourceCode:
			'add: newObject
									^self addLast: newObject'.
	self assert: newClass hasMethods not.

	newClass addMethod: newMethod.
	newClass
		addSelector: #size
		classified: 'accessing'
		sourced:
			'size
							^ lastIndex - firstIndex + 1'.

	self assert: newClass selectors asSet equals: #(add: size) asSet.
	newClass removeSelector: #join:.
	self assert: newClass selectors asSet equals: #(add: size) asSet.
	newClass removeMethod: newMethod.
	self assert: (newClass includesSelector: #add:) not.
	newClass removeSelector: #size.
	self assert: newClass hasMethods not
]

{ #category : #testing }
RGClassDefinitionTest >> testStoreOn [
	| st |
	st := String
		streamContents: [ :s | 
			Point asRingDefinition storeOn: s.
			s contents ].
	self assert: st equals: '(RGClassDefinition named: #Point)'.

	st := String
		streamContents: [ :s | 
			Point class asRingDefinition storeOn: s.
			s contents ].
	self assert: st equals: '((RGMetaclassDefinition named: #''Point class'') baseClass:(RGClassDefinition named: #Point))'
]

{ #category : #testing }
RGClassDefinitionTest >> testWithCategory [
	| newClass |
	newClass := (RGClassDefinition named: #Object)
		category: 'Kernel-Objects';
		yourself.

	self assert: newClass package isNil.
	self assert: newClass category equals: 'Kernel-Objects'
]

{ #category : #testing }
RGClassDefinitionTest >> testWithClassInstanceVariables [
	| newClass metaClass classInstVar |
	newClass := RGClassDefinition named: #HashTableSizes.
	newClass withMetaclass.
	metaClass := newClass classSide.
	metaClass addInstanceVariables: #(sizes).

	self assert: metaClass instanceVariables size equals: 1.
	self assert: metaClass instVarNames size equals: 1.
	self assert: metaClass allInstVarNames size equals: 1.

	classInstVar := metaClass instanceVariableNamed: #sizes.
	self assert: classInstVar notNil.
	self assert: classInstVar parent equals: metaClass.
	self assert: classInstVar isClassInstanceVariable.
	self assert: classInstVar isVariable.
	self assert: classInstVar parentName equals: metaClass name.
	self assert: classInstVar realClass equals: HashTableSizes class.

	metaClass removeInstVarNamed: #sizes.
	self assertEmpty: metaClass instanceVariables.
	self assert: (metaClass instanceVariableNamed: #sizes) isNil
]

{ #category : #testing }
RGClassDefinitionTest >> testWithClassVariables [
	| newClass classVar |
	newClass := (RGClassDefinition named: #Object)
		addClassVariables: #(DependentsFields);
		addClassVarNamed: #FakeVariable;
		yourself.

	self assert: newClass classVariables size equals: 2.
	self assert: newClass classVarNames size equals: 2.
	self assert: newClass allClassVarNames size equals: 2.	"no hierarchy"

	classVar := newClass classVarNamed: #DependentsFields.
	self assert: classVar notNil.
	self assert: classVar isClassVariable.
	self assert: classVar isVariable.
	self assert: classVar parent equals: newClass.
	self assert: classVar parentName identicalTo: newClass name.
	self assert: classVar realClass equals: Object.

	newClass withMetaclass.
	self assert: newClass classSide allClassVarNames size equals: 2.

	newClass removeClassVarNamed: #DependentsFields.
	self assert: newClass classVariables size equals: 1
]

{ #category : #testing }
RGClassDefinitionTest >> testWithComment [
	| newClass newComment |
	newClass := RGClassDefinition named: #Object.
	newComment := RGCommentDefinition new
		parent: newClass;
		content: 'This is a comment for test';
		stamp: 'VeronicaUquillas 3/22/2011 14:51';
		yourself.
	newClass comment: newComment.

	self assert: newClass hasComment.
	self assert: newClass hasStamp.
	self assert: newClass equals: newComment parent.
	self assert: newComment content equals: 'This is a comment for test'.
	self assert: newComment author equals: 'VeronicaUquillas'.
	self assert: newComment timeStamp equals: '3/22/2011 14:51' asDateAndTime.

	newClass comment: nil.
	self assert: newClass hasComment not.

	newClass
		comment: 'This is a comment for test';
		stamp: 'VeronicaUquillas 3/22/2011 14:51'.

	self assert: newClass comment isRingObject
]

{ #category : #testing }
RGClassDefinitionTest >> testWithDefaultNamespace [
	| newClass |
	newClass := RGClassDefinition named: #Object.

	self assert: newClass parent equals: Smalltalk globals.
	self assert: newClass realClass equals: Object
]

{ #category : #testing }
RGClassDefinitionTest >> testWithInstanceVariables [
	| newClass instVar |
	newClass := RGClassDefinition named: #OrderedCollection.
	newClass addInstanceVariables: #(array firstIndex).
	newClass addInstVarNamed: #lastIndex.

	self assert: newClass instanceVariables size equals: 3.
	self assert: newClass instVarNames size equals: 3.
	self assert: newClass allInstVarNames size equals: 3.

	instVar := newClass instanceVariableNamed: #firstIndex.
	self assert: instVar notNil.
	self assert: instVar parent equals: newClass.
	self assert: instVar isInstanceVariable.
	self assert: instVar isVariable.
	self assert: instVar parentName identicalTo: newClass name.
	self assert: instVar realClass equals: OrderedCollection.

	newClass removeInstVarNamed: #array.
	self assert: newClass instanceVariables size equals: 2.
	self assert: (newClass instanceVariableNamed: #array) isNil
]

{ #category : #testing }
RGClassDefinitionTest >> testWithPoolDictionaries [
	| newClass poolVar |
	newClass := (RGClassDefinition named: #Text)
		addSharedPoolNamed: #TextConstants;
		yourself.

	self assert: newClass sharedPools size equals: 1.
	self assert: newClass sharedPoolNames size equals: 1.
	self assert: newClass allSharedPools size equals: 1.	"no hierarchy"
	self assert: newClass allSharedPoolNames size equals: 1.

	poolVar := newClass sharedPoolNamed: #TextConstants.
	self assert: poolVar notNil.
	self assert: poolVar isPoolVariable.
	self assert: poolVar isVariable.
	self assert: poolVar parent equals: newClass.
	self assert: poolVar parentName identicalTo: newClass name.
	self assert: poolVar realClass equals: Text.

	newClass withMetaclass.
	self assert: newClass classSide allSharedPoolNames size equals: 1.

	newClass removeSharedPoolNamed: #TextConstants.
	self assertEmpty: newClass sharedPools
]

{ #category : #testing }
RGClassDefinitionTest >> testWithProtocols [
	| newMethod newClass |
	newClass := RGClassDefinition named: #OrderedCollection.
	newMethod := (RGMethodDefinition named: #add:)
		parent: newClass;
		protocol: 'adding';
		sourceCode:
			'add: newObject
									^self addLast: newObject'.

	newClass addMethod: newMethod.
	newClass addProtocol: 'accessing'.

	self assert: newClass hasProtocols.
	self assert: newClass protocols size equals: 2.
	self assert: (newClass includesProtocol: 'accessing').
	self assert: (newClass methodsInProtocol: 'adding') size equals: 1.
	self assertEmpty: (newClass methodsInProtocol: 'accessing')
]

{ #category : #testing }
RGClassDefinitionTest >> testWithSuperclass [
	| newClass supClass |
	supClass := (RGClassDefinition named: #Object)
		superclassName: #ProtoObject;
		yourself.

	self assert: supClass hasSuperclass not.
	self assert: supClass superclassName identicalTo: #ProtoObject.	"kept as annotation"
	self assert: supClass annotations size equals: 1.

	newClass := (RGClassDefinition named: #OrderedCollection) superclass: supClass.
	self assert: newClass superclass equals: supClass.
	self assert: newClass superclassName identicalTo: #Object.
	self assert: newClass withAllSuperclasses size equals: 2.
	self assert: newClass allSuperclasses size equals: 1.

	self assert: supClass subclasses size equals: 1.
	self assert: supClass withAllSubclasses size equals: 2.
	self assert: supClass allSubclasses size equals: 1
]
