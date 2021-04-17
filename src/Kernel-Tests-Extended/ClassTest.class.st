"
SUnit tests for classes
"
Class {
	#name : #ClassTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'className',
		'testEnvironment'
	],
	#category : #'Kernel-Tests-Extended-Classes'
}

{ #category : #setup }
ClassTest >> categoryNameForTemporaryClasses [
	"Answer the category where to classify temporarily created classes"

	^'Dummy-Tests-Class' 
]

{ #category : #coverage }
ClassTest >> classToBeTested [
	
	^ Class
]

{ #category : #setup }
ClassTest >> deleteClass [
	| cl |
	cl := testEnvironment at: className ifAbsent: [ ^ self ].
	
	testingEnvironment at: #ChangeSet ifPresent: [ 
		cl removeFromChanges ].
	
	cl removeFromSystemUnlogged
]

{ #category : #'referencing methods' }
ClassTest >> referencingMethod1 [

	^ ExampleForTest1
]

{ #category : #'referencing methods' }
ClassTest >> referencingMethod2 [

	^ {ExampleForTest12. ExampleForTest1}
]

{ #category : #'referencing methods' }
ClassTest >> referencingMethod3 [
	"no reference"

	^ self
]

{ #category : #running }
ClassTest >> setUp [
	super setUp.
	className := #TUTU.
	testEnvironment:= Smalltalk globals.
	self deleteClass.
	
	self class classInstaller make: [ :aBuilder |
		aBuilder 
			name: className;
			package: self categoryNameForTemporaryClasses]

]

{ #category : #running }
ClassTest >> tearDown [
	self deleteClass.
	{self unclassifiedCategory. self categoryNameForTemporaryClasses} do: [:category|
			RPackage organizer unregisterPackageNamed: category].
	super tearDown	
]

{ #category : #tests }
ClassTest >> testAddClassSlot [
	| tutu slot1 slot2 |
	tutu := testEnvironment at: #TUTU.
	slot1 := #X => InstanceVariableSlot.
	slot2 := #Y => InstanceVariableSlot.
	tutu addClassSlot: slot1.
	self assert: tutu class instVarNames equals: #(#X).
	tutu addClassSlot: slot2.
	self assert: tutu class instVarNames equals: #(#X #Y)
]

{ #category : #tests }
ClassTest >> testAddInstVarName [

	| tutu |
	tutu := testEnvironment at: #TUTU.
	tutu addInstVarNamed: 'x'.
	self assert: tutu instVarNames equals: #('x').
	tutu addInstVarNamed: 'y'.
	self assert: tutu instVarNames equals: #('x' 'y')
]

{ #category : #tests }
ClassTest >> testAddSlot [

	| tutu |
	tutu := testEnvironment at: #TUTU.
	tutu addSlot: #x => InstanceVariableSlot.
	self assert: tutu instVarNames equals: #('x').
	self assert: tutu name equals: #TUTU.
	tutu addSlot: #y => InstanceVariableSlot.
	self assert: tutu instVarNames equals: #('x' 'y')
]

{ #category : #tests }
ClassTest >> testAddSlotAnonymous [

	| tutu |
	tutu := Object newAnonymousSubclass.
	self assert: tutu getName isNil.
	tutu := tutu addSlot: #x => InstanceVariableSlot.
	self assert: tutu instVarNames equals: #('x').
	self assert: tutu getName isNil.
	tutu := tutu addSlot: #y => InstanceVariableSlot.
	self assert: tutu getName isNil.
	self assert: tutu instVarNames equals: #('x' 'y')
]

{ #category : #'tests - access' }
ClassTest >> testAllSharedPools [
	self assert: Point allSharedPools equals: OrderedCollection new.
	self assert: Date sharedPools first equals: ChronologyConstants.
	self assert: Date sharedPools size equals: 1.	"a metaclass does not have shared pools since only classes have shared pools"

	self assert: RootClassPoolUser sharedPools size equals: 1.
	self assert: ClassMultiplePoolUser sharedPools size equals: 2.	"has shared pools does not take into account the fact that a superclass may use some shared pools"
	self assertEmpty: SubclassPoolUser sharedPools
]

{ #category : #tests }
ClassTest >> testChangingShapeDoesNotPutNilInMethodsLastLiteralKey [
	"Test that when the shape of a class changes, the key of the last literal of the methods is not nil"
	| tutu |
	tutu := testEnvironment at: #TUTU.
	tutu compile: 'foo'.
	self deny: (tutu >> #foo) allLiterals last key isNil.
	tutu addInstVarNamed: 'x'.
	self deny: (tutu >> #foo) allLiterals last key isNil.
]

{ #category : #'test - accessing parallel hierarchy' }
ClassTest >> testClassSide [

	self assert: Point classSide equals: Point class. 
	self assert: Point class classSide equals: Point class. 
]

{ #category : #tests }
ClassTest >> testClassVariableEntanglement [ 
	| firstClassName firstClass secondClassName secondClass thirdClassName thirdClass |

	firstClassName := 'MyFirstClass'.

	firstClass := self class classInstaller make: [ :aBuilder |
		aBuilder 
			name: firstClassName;
			sharedVariablesFromString: 'MyVar';
			package: self categoryNameForTemporaryClasses ].
		
	[ 

		firstClass class compile: 'myVar
	^ MyVar'.
		firstClass class compile: 'myVar: anObject
	MyVar := anObject'.

		secondClassName := 'MySecondClass'.

		secondClass := self class classInstaller make: [ :aBuilder |
			aBuilder 
				name: secondClassName;
				sharedVariablesFromString: 'MyVar';
				package: self categoryNameForTemporaryClasses ].
			
		[ 

			secondClass class compile: 'myVar
	^ MyVar'.
			secondClass class compile: 'myVar: anObject
		MyVar := anObject'.

			thirdClassName := 'MyThirdClass'.
			thirdClass := secondClass duplicateClassWithNewName: thirdClassName.
			[ 

				self assert: firstClass myVar equals: nil.
				self assert: secondClass myVar equals: nil.
				self assert: thirdClass myVar equals: nil.
	
				firstClass myVar: 123.
				self assert: firstClass myVar equals: 123.
				self assert: secondClass myVar equals: nil.
				self assert: thirdClass myVar equals: nil.

				secondClass myVar: 456.
				self assert: firstClass myVar equals: 123.
				self assert: secondClass myVar equals: 456.
				self assert: thirdClass myVar equals: nil.

				thirdClass myVar: 789.
				self assert: firstClass myVar equals: 123.
				self assert: secondClass myVar equals: 456.
				self assert: thirdClass myVar equals: 789.

			 ] ensure: [ 
				thirdClass 
					removeFromChanges;
					removeFromSystemUnlogged ].
		 ] ensure: [ 
			secondClass 
				removeFromChanges;
				removeFromSystemUnlogged ].
	 ] ensure: [ 
		firstClass 
			removeFromChanges;
			removeFromSystemUnlogged ].

]

{ #category : #tests }
ClassTest >> testCommonSuperclassWith [
	self assert: (OrderedCollection commonSuperclassWith: Array) equals: SequenceableCollection.
	self assert: (OrderedCollection commonSuperclassWith: OrderedCollection) equals: SequenceableCollection.
	"if the reveiver is the common superclass, return it"
	self assert: (ProtoObject commonSuperclassWith: Object) equals: ProtoObject.
	"but the other way this is not true"
	self assert: (Object commonSuperclassWith: ProtoObject) equals: nil.
	"as nil is the terminator of the hierarchy, we have to support it"
	self assert: (nil commonSuperclassWith: ProtoObject) equals: nil.
]

{ #category : #tests }
ClassTest >> testCompileAll [
	ClassTest compileAll
]

{ #category : #'tests - dependencies' }
ClassTest >> testDependencies [
	self assert: (self class dependentClasses includes: self class superclass).
	self assert: (self class dependentClasses includes: Date)
]

{ #category : #accessing }
ClassTest >> testEnvironment [
	^ testEnvironment
]

{ #category : #accessing }
ClassTest >> testEnvironment: anObject [
	testEnvironment := anObject
]

{ #category : #tests }
ClassTest >> testHasBindingThatBeginsWith [
	self assert: (SmalltalkImage hasBindingThatBeginsWith: 'Compiler').
	self assert: (SmalltalkImage hasBindingThatBeginsWith: 'Object').
	
	"Pools are looked up, too"
	self assert: (TimeZone hasBindingThatBeginsWith: 'DaysInMo').
	
	"CompiledMethodLayout works, too"
	self deny: (CompiledMethod hasBindingThatBeginsWith: 'Compiler').

]

{ #category : #'tests - access' }
ClassTest >> testHasPoolVarNamed [	

	self assert: (Date usesLocalPoolVarNamed: 'DayNames').
	"a metaclass does not have shared pools since only classes have shared pools"
	self deny: (Date class usesLocalPoolVarNamed: 'DayNames').
	
	self assert: (RootClassPoolUser usesLocalPoolVarNamed: 'AnAuthor').
	"a subclass does not have the one of its superclass - but it would be good to change that"
	self deny: (SubclassPoolUser usesLocalPoolVarNamed: 'AnAuthor').
]

{ #category : #'tests - access' }
ClassTest >> testHasSharedPools [

	self deny: Point hasSharedPools.
	self assert: Date hasSharedPools.
	
	"a metaclass does not have shared pools since only classes have shared pools"
	self deny: Date class hasSharedPools.
	
	self assert: RootClassPoolUser hasSharedPools.
	
	"has shared pools does not take into account the fact that a superclass may use some shared pools"
	self deny: SubclassPoolUser hasSharedPools.
]

{ #category : #'test - accessing parallel hierarchy' }
ClassTest >> testInstanceSide [

	self assert: Point instanceSide equals: Point. 
	self assert: Point class instanceSide equals: Point. 
]

{ #category : #'test - accessing parallel hierarchy' }
ClassTest >> testIsClassSide [

	self deny: Point isClassSide.
	self assert: Point class isClassSide
]

{ #category : #'test - accessing parallel hierarchy' }
ClassTest >> testIsInstanceSide [

	self assert: Point isInstanceSide.
	self deny: Point class isInstanceSide
]

{ #category : #'tests - navigation' }
ClassTest >> testMethodsReferencingClass [
	self assert: (ClassTest methodsReferencingClass: (Smalltalk classNamed: #ExampleForTest111)) equals: {(ClassTest >> #testOrdersACollectionOfClassesBySuperclass)}.
	self
		assert: ((ClassTest methodsReferencingClass: (Smalltalk classNamed: #ExampleForTest1)) sort: [ :a :b | a name <= b name ]) asArray
		equals: {(ClassTest >> #referencingMethod1) . (ClassTest >> #referencingMethod2) . (ClassTest >> #testOrdersACollectionOfClassesBySuperclass)}.
	self assertEmpty: (ClassTest methodsReferencingClass: (Smalltalk classNamed: #BehaviorTest))
]

{ #category : #'tests - navigation' }
ClassTest >> testMethodsReferencingClasses [

	| collectionOfMethods collectionOfMethodsShouldBe |
	
	collectionOfMethods := ((ClassTest methodsReferencingClasses: {Smalltalk classNamed: #ExampleForTest12. Smalltalk classNamed: #ExampleForTest1}) sort: [ :a :b | a name <= b name]) asArray.
	
	collectionOfMethodsShouldBe := {
		ClassTest>>#referencingMethod1.
		ClassTest>>#referencingMethod2.
		ClassTest>>#testOrdersACollectionOfClassesBySuperclass}.
		
	self assert: collectionOfMethods asSet equals: collectionOfMethodsShouldBe asSet
]

{ #category : #'tests - class creation' }
ClassTest >> testNewSubclass [
	| cls |
	cls := Point newSubclass.
	self assert: cls isBehavior.
	self assert: cls superclass identicalTo: Point.
	self assert: (Point allSubclasses includes: cls).
	self assert: cls instVarNames equals: #().
	self assert: cls category equals: self unclassifiedCategory.
	self assert: cls classVarNames equals: #().

	cls removeFromSystem
]

{ #category : #'tests - file in/out' }
ClassTest >> testOrdersACollectionOfClassesBySuperclass [	
	| ordered |
	ordered := (Class superclassOrder:  
		(OrderedCollection 
				with: ExampleForTest11 class 
				with: ExampleForTest111 class 
				with: ExampleForTest12 class 
				with: ExampleForTest1 class 
				with: ExampleForTest12 class 
				with: ExampleForTest112 class)).
	
	self assert: (ordered indexOf: ExampleForTest1 class) < (ordered indexOf: ExampleForTest11 class).
	self assert: (ordered indexOf: ExampleForTest11 class) < (ordered indexOf: ExampleForTest111 class).
	self assert: (ordered indexOf: ExampleForTest11 class) < (ordered indexOf: ExampleForTest112 class).
	self assert: (ordered indexOf: ExampleForTest1 class) < (ordered indexOf: ExampleForTest12 class).
	
]

{ #category : #'tests - file in/out' }
ClassTest >> testOrdersMetaClassAfterItsClassInstance [
	| ordered |
	ordered := (Class superclassOrder:  
		(OrderedCollection 
				with: Boolean class
				with: True
				with: Boolean
				with: True class)).
	
	self assert: (ordered indexOf: Boolean) < (ordered indexOf: Boolean class).
	self assert: (ordered indexOf: True) < (ordered indexOf: True class).
	self assert: (ordered indexOf: Boolean class) < (ordered indexOf: True class).
	self assert: (ordered indexOf: Boolean) < (ordered indexOf: True).

]

{ #category : #'tests - pools' }
ClassTest >> testPoolVariableAccessibleInClassUser [
	"This test shows that a Pool Variable is accessible from the class that declare the Pool usage: here the superclass"

	PoolDefiner initialize.
	RootClassPoolUser compileAll.

	self assert: RootClassPoolUser gloups equals: 42.
	self assert: RootClassPoolUser author equals: 'Ducasse'
]

{ #category : #'tests - pools' }
ClassTest >> testPoolVariableAccessibleInSubclassOfClassUser [
	"This test shows that a Pool Variable is not accessible from a subclass that declare the Pool usage: here SubFlop subclass of Flop and this is a bug. "

	PoolDefiner initialize.
	SubclassPoolUser compileAll.

	self assert: SubclassPoolUser gloups equals: 42.
	self assert: SubclassPoolUser author equals: 'Ducasse'
]

{ #category : #'tests - navigation' }
ClassTest >> testReferencedClasses [
	{(ExceptionTester -> { MyTestNotification. Warning. String. MyResumableTestError. OrderedCollection. MyTestError}). 
	 (CollectionCombinator -> {Array}).
	 (ExecutionEnvironmentStub -> {OrderedCollection}).
	 (ReferencedClassesTestClass -> {Array. OrderedCollection. Object})
	}
		do: [ :assoc | 
			self assert: assoc key referencedClasses notEmpty.
			self assert: (assoc key referencedClasses asSet includesAll: assoc value asSet)].
		
	"classes referenced from class variables should not be seen as referenced statically"
	self assert: (SmalltalkImage class>>#compilerClass ) referencedClasses isEmpty.
	
]

{ #category : #tests }
ClassTest >> testRemoveClassSlot [
	| tutu slot1 slot2 |
	tutu := testEnvironment at: #TUTU.
	slot1 := #X => InstanceVariableSlot.
	slot2 := #Y => InstanceVariableSlot.
	tutu addClassSlot: slot1.
	self assert: tutu class instVarNames equals: #(#X).
	tutu addClassSlot: slot2.
	self assert: tutu class instVarNames equals: #(#X #Y).
	tutu removeClassSlot: slot2.
	self assert: tutu class instVarNames equals: #(#X).
	tutu removeClassSlot: slot1.
	self assert: tutu class instVarNames equals: #().
]

{ #category : #'tests - access' }
ClassTest >> testSharedPoolOfVarNamed [	

	self assert: (Date sharedPoolOfVarNamed: 'DayNames') equals: ChronologyConstants.
	"a metaclass does not have shared pools since only classes have shared pools"
	self assert: (Date class sharedPoolOfVarNamed: 'DayNames') isNil.
	
	self assert: (RootClassPoolUser sharedPoolOfVarNamed: 'AnAuthor') equals: PoolDefiner.
	self assert: (RootClassPoolUser sharedPoolOfVarNamed: 'Gloups') equals: PoolDefiner.
	self assert: (SubclassPoolUser sharedPoolOfVarNamed: 'AnAuthor') equals: PoolDefiner.
	
	self assert: (ClassMultiplePoolUser sharedPoolOfVarNamed: 'AnAuthor') equals: PoolDefiner.
	self assert: (ClassMultiplePoolUser sharedPoolOfVarNamed: 'VariableInPoolDefiner2') equals: PoolDefiner2.
	self assert: (ClassMultiplePoolUser sharedPoolOfVarNamed: 'Gloups') equals: PoolDefiner
]

{ #category : #'tests - access' }
ClassTest >> testSharedPools [
	self assert: Point sharedPools equals: OrderedCollection new.
	self assert: Date sharedPools first equals: ChronologyConstants.
	self assert: Date sharedPools size equals: 1.	"a metaclass does not have shared pools since only classes have shared pools"
	Date class sharedPools.
	self assert: RootClassPoolUser sharedPools size equals: 1.
	self assert: ClassMultiplePoolUser sharedPools size equals: 2.	"has shared pools does not take into account the fact that a superclass may use some shared pools"
	self assertEmpty: SubclassPoolUser sharedPools
]

{ #category : #'tests - class creation' }
ClassTest >> testSubclass [
	| cls |
	(testEnvironment includesKey: #SubclassExample) ifTrue: [ (testEnvironment at: #SubclassExample) removeFromSystem ].

	self deny: (testEnvironment includesKey: #SubclassExample).
	cls := self class classInstaller make: [ :aBuilder | aBuilder name: #SubclassExample ].
	
	self assert: (testEnvironment includesKey: #SubclassExample).

	self assert: (testEnvironment at: #SubclassExample) identicalTo: cls.
	self assert: cls category equals: self unclassifiedCategory.
	self assert: cls instVarNames equals: #().

	cls removeFromSystem
]

{ #category : #'tests - class creation' }
ClassTest >> testSubclassInstanceVariableNames [
	| cls |
	(testEnvironment includesKey: #SubclassExample) ifTrue: [ (testEnvironment at: #SubclassExample) removeFromSystem ].

	self deny: (testEnvironment includesKey: #SubclassExample).

	cls := self class classInstaller make: [ :aBuilder | 
		aBuilder 
			name: #SubclassExample;
			slots: 'x y' asSlotCollection].

	self assert: (testEnvironment includesKey: #SubclassExample).

	self assert: (testEnvironment at: #SubclassExample) identicalTo: cls.
	self assert: cls category equals: self unclassifiedCategory.
	self assert: cls instVarNames equals: #('x' 'y').

	cls removeFromSystem
]

{ #category : #'tests - file in/out' }
ClassTest >> testSuperclassOrder [
	|  ordered orderedSuperclasses shuffledSuperclasses |
	orderedSuperclasses := {ProtoObject. Object. Collection. SequenceableCollection}.
	
	"a shuffled collection of superclasses of OrderedCollection"
	shuffledSuperclasses := {Collection. SequenceableCollection. ProtoObject. Object}.
	
	ordered := Class superclassOrder: shuffledSuperclasses.
	
	"should not affect the order as there is no dependencies"
	self assert: ordered equals: orderedSuperclasses asOrderedCollection
]

{ #category : #'tests - file in/out' }
ClassTest >> testSuperclassOrderPreservingOrder [
	| noHierarchicalRelationship ordered |
	"a shuffled collection of direct subclasses of Collection"
	noHierarchicalRelationship := {CharacterSet. WideCharacterSet. OrderedDictionary. DependentsArray. Bag. SmallDictionary. SequenceableCollection. HashedCollection. WeakRegistry. Heap}.
	
	ordered := Class superclassOrder: noHierarchicalRelationship.
	
	"should not affect the order as there is no dependencies"
	self assert: ordered equals: noHierarchicalRelationship asOrderedCollection
	
	
]

{ #category : #'tests - access' }
ClassTest >> testUsesPoolVarNamed [	

	self assert: (Date usesPoolVarNamed: 'DayNames').
	"a metaclass does not have shared pools since only classes have shared pools"
	self deny: (Date class usesPoolVarNamed: 'DayNames').
	
	self assert: (RootClassPoolUser usesPoolVarNamed: 'AnAuthor').
	"a subclass  has  the one of its superclass"
	self assert: (SubclassPoolUser usesPoolVarNamed: 'AnAuthor')
]

{ #category : #'tests - class variables' }
ClassTest >> testallClassVariables [

	self assert: SmalltalkImage allClassVariables last name equals: #DependentsFields
]

{ #category : #'tests - class variables' }
ClassTest >> testclassVarNames [

	self assert: (Object classVarNames includes: #DependentsFields).
	
	"A class and it's meta-class share the class variables"
	self assert: Object classVarNames equals: Object class classVarNames
]

{ #category : #'tests - class variables' }
ClassTest >> testclassVariables [

	self assert: Object classVariables first name equals: #DependentsFields.
	
	"A class and it's meta-class share the class variables"
	self assert: Object classVariables equals: Object class classVariables
]

{ #category : #'tests - class creation' }
ClassTest >> unclassifiedCategory [
	^#Unclassified
]
