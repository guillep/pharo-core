"
I'm useful when classes needs to be created during the execution of the test. This avoid polluting your unit tests with dummy and mock classes.
A typical usage of it is:

TestCase subclass: #YourTest
       instanceVariableNames: 'classFactory'

YourTest>>setUp
       classFactory := ClassFactoryForTestCase new

YourTest>>tearDown
       classFactory deleteClasses.

YourTest>>testIsBehavior
       | cls |
       cls := classFactory newClass.
       self assert: cls isBehavior

"
Class {
	#name : #ClassFactoryForTestCase,
	#superclass : #Object,
	#instVars : [
		'createdClasses',
		'createdTraits',
		'createdSilently'
	],
	#classVars : [
		'Counter'
	],
	#category : #'SUnit-Core-Extensions'
}

{ #category : #cleaning }
ClassFactoryForTestCase >> cleanUp [
	| createdClassNames createdTraitNames |
	createdClassNames := self createdClassNames.
	createdTraitNames := self createdTraitNames.
	self deleteClasses.
	self deleteTraits.
	self deletePackage.
	self cleanUpChangeSetForClassNames: createdClassNames.
	self cleanUpChangeSetForClassNames: createdTraitNames
]

{ #category : #cleaning }
ClassFactoryForTestCase >> cleanUpChangeSetForClassNames: classeNames [

	self class environment at: #ChangeSet ifPresent: [ :aChangeSetClass |
		| changeSet |
		changeSet := aChangeSetClass current.
		classeNames do: [:name|	
			changeSet 
				removeClassChanges: name;
				removeClassChanges: name, ' class']]
]

{ #category : #accessing }
ClassFactoryForTestCase >> createdClassNames [
	^self createdClasses collect: [ :class| class name ]
]

{ #category : #accessing }
ClassFactoryForTestCase >> createdClasses [
	^createdClasses
]

{ #category : #accessing }
ClassFactoryForTestCase >> createdTraitNames [
	^self createdTraits collect: [ :trait | trait name ]
]

{ #category : #accessing }
ClassFactoryForTestCase >> createdTraits [
	^createdTraits
]

{ #category : #accessing }
ClassFactoryForTestCase >> defaultCategory [
	^ (self packageName , '-', self defaultTagPostfix) asSymbol
]

{ #category : #accessing }
ClassFactoryForTestCase >> defaultSuperclass [ 
	^Object
]

{ #category : #accessing }
ClassFactoryForTestCase >> defaultTagPostfix [
	^ #Default
]

{ #category : #cleaning }
ClassFactoryForTestCase >> delete: aBehavior [
	aBehavior isObsolete
		ifTrue: [ ^ self ].
	self class environment at: #ChangeSet ifPresent: [ 
		aBehavior removeFromChanges ].
	(createdSilently includes: aBehavior)
		ifTrue: [ aBehavior removeFromSystemUnlogged ]
		ifFalse: [ aBehavior removeFromSystem ].
]

{ #category : #cleaning }
ClassFactoryForTestCase >> deleteClass: aClass [
	self createdClasses remove: aClass.
	self delete: aClass.
]

{ #category : #cleaning }
ClassFactoryForTestCase >> deleteClasses [
	self createdClasses do: [:class|
		self delete: class]
]

{ #category : #cleaning }
ClassFactoryForTestCase >> deletePackage [
	| categoriesMatchString |
	categoriesMatchString := self packageName, '-*'.
	SystemOrganization removeCategoriesMatching: categoriesMatchString
]

{ #category : #cleaning }
ClassFactoryForTestCase >> deleteTraits [
	self createdTraits do: [:trait|
		self delete: trait]
]

{ #category : #creating }
ClassFactoryForTestCase >> duplicateClass: aClass withNewName: name [
	| newClass |
	
	newClass := aClass duplicateClassWithNewName: name.
	self createdClasses add: newClass.
	^newClass

]

{ #category : #initialization }
ClassFactoryForTestCase >> initialize [
	super initialize.
	createdClasses := IdentitySet new.
	createdTraits := IdentitySet new.
	createdSilently := IdentitySet new.
]

{ #category : #creating }
ClassFactoryForTestCase >> newClass [

	^ self 
		newSubclassOf: self defaultSuperclass
		instanceVariableNames: ''
		classVariableNames: ''
]

{ #category : #creating }
ClassFactoryForTestCase >> newClassInCategory: category [

	^ self
		newSubclassOf: self defaultSuperclass
		instanceVariableNames: ''
		classVariableNames: ''
		category: category
]

{ #category : #creating }
ClassFactoryForTestCase >> newClassName [

	| postFix |
	postFix := self nextCount printString.
	^ (#ClassForTestToBeDeleted, postFix) asSymbol.
]

{ #category : #creating }
ClassFactoryForTestCase >> newClassUsing: aTraitComposition [
	
	^ self 
		newSubclassOf: self defaultSuperclass 
		uses: aTraitComposition 
		instanceVariableNames: '' 
		classVariableNames: ''
		category: self defaultTagPostfix.
]

{ #category : #creating }
ClassFactoryForTestCase >> newClassWithInstanceVariableNames: aString [

	^ self 
		newSubclassOf: self defaultSuperclass
		instanceVariableNames: aString
		classVariableNames: ''
]

{ #category : #creating }
ClassFactoryForTestCase >> newSubclassOf: aClass [

	^ self 
		newSubclassOf: aClass
		instanceVariableNames: ''
		classVariableNames: ''
]

{ #category : #creating }
ClassFactoryForTestCase >> newSubclassOf: aClass instanceVariableNames: ivNamesString classVariableNames: classVarsString [

	^ self 
		newSubclassOf: aClass 
		uses: { }
		instanceVariableNames: ivNamesString 
		classVariableNames: classVarsString 
		category: self defaultTagPostfix
]

{ #category : #creating }
ClassFactoryForTestCase >> newSubclassOf: aClass instanceVariableNames: ivNamesString classVariableNames:  classVarsString category: category [
	
	^ self 
		newSubclassOf: aClass 
		uses: { } 
		instanceVariableNames: ivNamesString 
		classVariableNames: classVarsString 
		category: category.
]

{ #category : #creating }
ClassFactoryForTestCase >> newSubclassOf: aClass uses: aTraitComposition instanceVariableNames: ivNamesString classVariableNames:  classVarsString category: category [
	
	^ self
		newSubclassOf: aClass 
		uses: aTraitComposition
		instanceVariableNames: ivNamesString 
		classVariableNames: classVarsString 
		poolDictionaries: '' 
		category: category
]

{ #category : #creating }
ClassFactoryForTestCase >> newSubclassOf: aClass 
	uses: aTraitComposition 
	instanceVariableNames: ivNamesString 
	classVariableNames:  classVarsString 
	poolDictionaries: poolNamesString 
	category: category [

	| newClass |
			
	newClass := self class classInstaller make: [ :aBuilder | 
		aBuilder 
			name: self newClassName;
			superclass: aClass;
			traitComposition: aTraitComposition asTraitComposition;
			slots: ivNamesString asSlotCollection;
			sharedVariablesFromString: classVarsString;
			sharedPools: poolNamesString;
			package: (self packageName, '-', category) asSymbol ].	
		
	self createdClasses add: newClass.
	^ newClass
]

{ #category : #creating }
ClassFactoryForTestCase >> newSubclassOf: aClass using: aTraitComposition [

	^ self 
		newSubclassOf: aClass
		uses: aTraitComposition 
		instanceVariableNames: '' 
		classVariableNames: ''
		category: self defaultTagPostfix.
]

{ #category : #creating }
ClassFactoryForTestCase >> newTrait [
	^ self
		newTraitNamed: self newTraitName
		uses: Array new
		tag: self defaultTagPostfix
]

{ #category : #creating }
ClassFactoryForTestCase >> newTraitInTag: aTag [
	^ self
		newTraitNamed: self newTraitName
		uses: Array new
		tag: aTag asSymbol
]

{ #category : #creating }
ClassFactoryForTestCase >> newTraitName [

	| postFix |
	postFix := (self createdTraits size + 1) printString.
	^ (#TraitForTestToBeDeleted, postFix) asSymbol
]

{ #category : #creating }
ClassFactoryForTestCase >> newTraitNamed: aTraitName uses: aTraitComposition tag: aTag [
	
	| newTrait |					
	newTrait := self class classInstaller make: [ :aBuilder |
		aBuilder 
			name: aTraitName;
			traitComposition: aTraitComposition asTraitComposition;
			package: (self packageName, '-', aTag) asSymbol;
			beTrait ].					
					
	self createdTraits add: newTrait.
	^ newTrait
]

{ #category : #creating }
ClassFactoryForTestCase >> newTraitUsing: aTraitComposition [

	^ self 
		newTraitNamed: self newTraitName 
		uses: aTraitComposition 
		tag: self defaultTagPostfix.
]

{ #category : #accessing }
ClassFactoryForTestCase >> nextCount [
	"Global counter to avoid name clash between test runs, in case of some previous failure."
	^ Counter := (Counter ifNil: [ 0 ]) + 1.
]

{ #category : #accessing }
ClassFactoryForTestCase >> packageName [

	^ #CategoryForTestToBeDeleted
]

{ #category : #creating }
ClassFactoryForTestCase >> redefineClass: aClass category: aString [

	^self
		redefineClass: aClass
		subclassOf: aClass superclass
		uses: aClass traitComposition
		instanceVariableNames: aClass instanceVariablesString 
		classVariableNames: aClass classVariablesString
		poolDictionaries: aClass sharedPoolsString
		package: aString
]

{ #category : #creating }
ClassFactoryForTestCase >> redefineClass: aClass instanceVariableNames: aString [ 

	^self
		redefineClass: aClass
		subclassOf: aClass superclass
		uses: aClass traitComposition
		instanceVariableNames: aString
		classVariableNames: aClass classVariablesString
		poolDictionaries: aClass sharedPoolsString
		package: aClass category
]

{ #category : #creating }
ClassFactoryForTestCase >> redefineClass: aClass subclassOf: aSuperclass 
	uses: aTraitComposition 
	instanceVariableNames: ivNamesString 
	classVariableNames:  classVarsString 
	poolDictionaries: poolNamesString 
	package: aPackageName [

	| newClass |
			
	newClass := self class classInstaller make: [ :aBuilder | 
		aBuilder 
			name: aClass name;
			superclass: aSuperclass;
			traitComposition: aTraitComposition asTraitComposition;
			slots: ivNamesString asSlotCollection;
			sharedVariablesFromString: classVarsString;
			sharedPools: poolNamesString;
			package: aPackageName asSymbol ].	
		
	self createdClasses add: newClass.
	^ newClass
]

{ #category : #'creating - silently' }
ClassFactoryForTestCase >> silentlyNewClassInCategory: category [

	^ self
		silentlyNewSubclassOf: self defaultSuperclass
		instanceVariableNames: ''
		classVariableNames: ''
		category: category
]

{ #category : #'creating - silently' }
ClassFactoryForTestCase >> silentlyNewSubclassOf: aClass instanceVariableNames: ivNamesString classVariableNames: classVarsString [
	
	^ self
		silentlyNewSubclassOf: aClass
		instanceVariableNames: ivNamesString
		classVariableNames: classVarsString
		category: self defaultTagPostfix
]

{ #category : #'creating - silently' }
ClassFactoryForTestCase >> silentlyNewSubclassOf: aClass 
	instanceVariableNames: ivNamesString 
	classVariableNames:  classVarsString 
	category: category [

	^ self 
		silentlyNewSubclassOf: aClass 
		instanceVariableNames: ivNamesString
		classVariableNames: classVarsString
		package: (self packageName, '-', category) asSymbol.


]

{ #category : #'creating - silently' }
ClassFactoryForTestCase >> silentlyNewSubclassOf: aClass 
	instanceVariableNames: ivNamesString 
	classVariableNames: classVarsString 
	package: packageName [

	SystemAnnouncer uniqueInstance suspendAllWhile: [ 
		^ self
			  newSubclassOf: aClass
			  uses: #(  )
			  instanceVariableNames: ivNamesString
			  classVariableNames: classVarsString
			  poolDictionaries: ''
			  category: packageName ]
]

{ #category : #creating }
ClassFactoryForTestCase >> withNotificationsNewClass [
	
	^ self withNotificationsNewClassWithInstanceVariableNames: ''
]

{ #category : #creating }
ClassFactoryForTestCase >> withNotificationsNewClassWithInstanceVariableNames: instanceVariableNames [
	
	^ self
		newSubclassOf: Object
		instanceVariableNames: instanceVariableNames
		classVariableNames: ''
		category: self defaultTagPostfix
]
