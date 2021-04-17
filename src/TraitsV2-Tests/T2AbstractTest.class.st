"
Abstract Test of all the TraitsV2 tests
"
Class {
	#name : #T2AbstractTest,
	#superclass : #TestCase,
	#instVars : [
		'createdClasses'
	],
	#category : #'TraitsV2-Tests'
}

{ #category : #testing }
T2AbstractTest class >> isAbstract [

	^self == T2AbstractTest
]

{ #category : #'instance creation' }
T2AbstractTest >> newClass: aName [ 
	^self newClass: aName with: #() trait: TEmpty
]

{ #category : #'instance creation' }
T2AbstractTest >> newClass: aName superclass: aSuperclass with: slots trait: aComposition [
	
	^ self newClass: aName superclass: aSuperclass with: slots uses: aComposition category: 'TraitsV2-Tests-TestClasses' 
]

{ #category : #'instance creation' }
T2AbstractTest >> newClass: aName superclass: aSuperclass with: slots trait: aComposition category: category [
	
	| class |

	class := self class classInstaller make: [ :aClassBuilder | 
		aClassBuilder 
			name: aName;
			superclass: aSuperclass;
			slots: slots;
			traitComposition: aComposition asTraitComposition;
			package: category ].
	
	createdClasses add:class.
	
	^class.
]

{ #category : #'instance creation' }
T2AbstractTest >> newClass: aName superclass: aSuperclass with: slots uses: aComposition [
	
	^ self newClass: aName superclass: aSuperclass with: slots uses: aComposition category: 'TraitsV2-Tests-TestClasses' 
]

{ #category : #'instance creation' }
T2AbstractTest >> newClass: aName superclass: aSuperclass with: slots uses: aComposition category: category [
	
	| class |

	class := self class classInstaller make: [ :aClassBuilder | 
		aClassBuilder 
			name: aName;
			superclass: aSuperclass;
			slots: slots;
			traitComposition: aComposition asTraitComposition;
			package: category ].
	
	createdClasses add:class.
	
	^class.
]

{ #category : #'instance creation' }
T2AbstractTest >> newClass: aName with: slots trait: aComposition [
	^ self newClass: aName superclass: Object with: slots trait: aComposition
]

{ #category : #'instance creation' }
T2AbstractTest >> newClass: aName with: slots uses: aComposition [
	^ self newClass: aName superclass: Object with: slots uses: aComposition
]

{ #category : #'instance creation' }
T2AbstractTest >> newTrait: aName with: slots [
	^ self newTrait: aName with: slots trait: TEmpty
]

{ #category : #'instance creation' }
T2AbstractTest >> newTrait: aName with: slots trait: aComposition [
	^ self newTrait: aName with: slots trait: aComposition category: 'TraitsV2-Tests-TestClasses'
]

{ #category : #'instance creation' }
T2AbstractTest >> newTrait: aName with: slots trait: aComposition category: category [
	| class |
	class := self class classInstaller make: [ :aBuilder |
		aBuilder 
			name: aName;
			traitComposition: aComposition asTraitComposition;
			slots: slots;
			package: category;
			beTrait ].			
	
	createdClasses add:class.
	
	^class.
]

{ #category : #'instance creation' }
T2AbstractTest >> newTrait: aName with: slots uses: aComposition [
	^ self newTrait: aName with: slots trait: aComposition category: 'TraitsV2-Tests-TestClasses'
]

{ #category : #'instance creation' }
T2AbstractTest >> newTrait: aName with: slots uses: aComposition category: category [
	| class |
	class := self class classInstaller make: [ :aBuilder |
		aBuilder 
			name: aName;
			traitComposition: aComposition asTraitComposition;
			slots: slots;
			package: category;
			beTrait ].			
	
	createdClasses add:class.
	
	^class.
]

{ #category : #running }
T2AbstractTest >> setUp [
	super setUp.
	createdClasses := OrderedCollection new
]

{ #category : #running }
T2AbstractTest >> tearDown [
	createdClasses reverseDo: #removeFromSystem.
	createdClasses := nil.

	super tearDown
]
