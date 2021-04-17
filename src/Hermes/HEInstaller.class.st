"
I am the entry point to load a package of Hermes.

I am the basic implementation, I can only handle basic cases:
- If there is a new undeclared I produce an error.
- If there is an existing element I produce an error.

For more extended options check HEExtendedEnvironment

Example: 

	file := 'aFile.hermes'.
	installer := HEInstaller new.
	
	reader := HEBinaryReader new
		stream: (File named: file) readStream;
		yourself.

	readPackage := HEPackage readFrom: reader.

	installer installPackage: readPackage
"
Class {
	#name : #HEInstaller,
	#superclass : #Object,
	#instVars : [
		'environment',
		'originalUndeclareds',
		'hasTraits'
	],
	#category : #'Hermes-ClassInstaller'
}

{ #category : #converting }
HEInstaller >> asClassVariables: aString [
	| trimmed |
	trimmed := aString trimBoth.

	trimmed isEmpty
		ifTrue: [ ^ #() ].

	^ (trimmed substrings: ' ') collect: [:x | x asSymbol => ClassVariable]
]

{ #category : #converting }
HEInstaller >> asSlots: aString [
	| trimmed |
	trimmed := aString trimBoth.

	trimmed isEmpty
		ifTrue: [ ^ #() ].

	^ (trimmed splitOn: ' ') collect: [ :e | e asSymbol asSlot ] as: Array
]

{ #category : #'creating classes' }
HEInstaller >> build: aHEClass [
	| newClass superclass layoutType  |

	(self existingClass: aHEClass) ifNotNil: [ :x | ^ x ].

	superclass := self classNamed: aHEClass superclass.
	layoutType := self classNamed: aHEClass layoutClass.

	newClass := self class classInstaller make: [ :builder |
		builder name: aHEClass className;
		superclass: superclass;
		layoutClass: layoutType;
		slots: (self asSlots: aHEClass instanceVariables);
		sharedVariables:  (self asClassVariables:aHEClass classVariables);
		sharedPools: aHEClass sharedPools;
		category: aHEClass category;
		classSlots: (self asSlots: aHEClass classInstancevariables) ].
	
	self processTraitsFrom: aHEClass in: newClass.
	
	^newClass.

]

{ #category : #'creating traits' }
HEInstaller >> buildTrait: aTraitDefinition [
	| newTrait traitComposition traitClass|
	
	(self existingTrait: aTraitDefinition) ifNotNil: [:x | ^ x ].
	
	traitClass := Smalltalk globals at: #Trait ifAbsent: [ self error: 'Trait support is not installed' ].
	
	traitComposition := self buildTraitCompositionFor: aTraitDefinition traitComposition.	
	
	newTrait := traitClass
		named: aTraitDefinition traitName
		uses: traitComposition
		package: aTraitDefinition category
		env: environment.

	newTrait classTrait traitComposition: (self buildTraitCompositionFor: aTraitDefinition classTraitComposition).

	^ newTrait
]

{ #category : #'creating traits' }
HEInstaller >> buildTraitCompositionFor: traitComposition [

	^ (traitComposition asLiteralIn: environment) asTraitComposition
]

{ #category : #accessing }
HEInstaller >> classNamed: aSymbol [
	aSymbol ifNil: [ ^ nil ].
	^ self environment at: aSymbol
]

{ #category : #'reporting undeclared' }
HEInstaller >> createdUndeclared [
	^ (Undeclared associations reject: [ :asoc | originalUndeclareds associations includes: asoc]) asDictionary 
]

{ #category : #'installing package' }
HEInstaller >> doInstallPackage: aHEPackage [
	| newTraits newClasses |
	"Creating the package. It requires a number of steps.
	1. Register the package in the organizer."
	RPackageOrganizer default registerPackageNamed: aHEPackage packageName.

	"2. Install the traits"
	newTraits := aHEPackage traits collect: [ :exportedTrait | self buildTrait: exportedTrait ].

	"3. Install traits methods"
	aHEPackage traits with: newTraits do: [ :exportedTrait :newTrait | self installMethods: exportedTrait into: newTrait ].

	"4. Install classes"
	newClasses := aHEPackage classes
		collect: [ :exportedClass | self build: exportedClass ].

	"5. Install class methods"
	aHEPackage classes with: newClasses do: [ :exportedClass :newClass | self installMethods: exportedClass into: newClass ].

	"6. Install extension methods"
	aHEPackage extensionMethods do: [ :e | self installExtensionMethod: e ].
	
	"7. After all I validate if there are no new undeclared variables created in the environment.
	A new undeclared is a sign of an improper modularization."
	self validateNoNewUndeclared
]

{ #category : #accessing }
HEInstaller >> environment [
	^ environment
]

{ #category : #accessing }
HEInstaller >> environment: anObject [
	environment := anObject
]

{ #category : #'validating existance' }
HEInstaller >> existingClass: aHEClass [
	(environment hasClassNamed: aHEClass className) ifTrue:[
		self error: (self messageExistingClass: aHEClass)
	].
	^ nil
]

{ #category : #'validating existance' }
HEInstaller >> existingTrait: aHETrait [
	(environment includesKey: aHETrait traitName) ifTrue:[ 
		self error: (self messageExistingTrait: aHETrait)
	].
	
	^nil
]

{ #category : #initialization }
HEInstaller >> initialize [
	environment := self class environment.
	originalUndeclareds := Undeclared copy.
	hasTraits := Smalltalk globals hasClassNamed: #Trait.
]

{ #category : #'installing methods' }
HEInstaller >> installExtensionMethod: extensionMethod [
	| aClass |
	aClass := self environment classNamed: extensionMethod className.
	
	aClass ifNil: [ self error: 'Required class named: ' , extensionMethod className, ' does not exists.' ].
	
	self rebuildMethod: extensionMethod into: aClass.
]

{ #category : #'installing methods' }
HEInstaller >> installMethods: exportedClass into: aClass [
	exportedClass methods do: [ :e | self rebuildMethod: e into: aClass ].
	exportedClass classSideMethods
		do:
			[ :e | self rebuildMethod: e into: aClass classSide ]
]

{ #category : #'installing package' }
HEInstaller >> installPackage: aHEPackage [
	| storedAnnouncements |
	
	storedAnnouncements := SystemAnnouncer uniqueInstance suspendAllWhileStoring: [ self doInstallPackage: aHEPackage ].	
	storedAnnouncements do: [ :e | SystemAnnouncer uniqueInstance announce: e ].
]

{ #category : #messages }
HEInstaller >> messageExistingClass: aHEClass [
	^ 'The class ' , aHEClass className asString
		, ' already exists. Should not be overwritten'
]

{ #category : #messages }
HEInstaller >> messageExistingTrait: aHETrait [
	^ 'The trait ' , aHETrait traitName asString
		, ' already exists. Should not be overwritten'
]

{ #category : #messages }
HEInstaller >> messageMethod: aHEMethod alreadyExistsIn: aClass [
	^ 'The method ' , aHEMethod name asString , ' already exists in class ' , aClass name asString
]

{ #category : #'creating classes' }
HEInstaller >> processTraitsFrom: aHEClass in: newClass [

	hasTraits ifFalse: [ ^ self ].

	newClass setTraitComposition: (self buildTraitCompositionFor: aHEClass traitComposition).
	newClass class setTraitComposition: (self buildTraitCompositionFor: aHEClass classTraitComposition).

]

{ #category : #'installing methods' }
HEInstaller >> rebuildMethod: aMethod into: aClass [
	| newMethod literalSpace extendedEnvironment |
	
	(self shouldBuildMethod: aMethod in: aClass) ifFalse: [ ^ self ].	

	extendedEnvironment := HEExtendedEnvironment new.
	extendedEnvironment inner: environment.
	extendedEnvironment newClass: aClass.
	extendedEnvironment newSelector: aMethod name.

	newMethod := CompiledMethod newMethod: aMethod bytecode size header: (aMethod headerFor: extendedEnvironment).

	extendedEnvironment newMethod: newMethod.

	aMethod literals
		doWithIndex:
			[ :literal :idx | newMethod literalAt: idx put: (literal asLiteralIn: extendedEnvironment) ].

	newMethod classBinding: aClass binding.
	literalSpace := (aMethod literals size + 1) * Smalltalk wordSize.

	aMethod bytecode doWithIndex: [ :e :idx | newMethod at: idx + literalSpace put: e ].

	aClass
		addAndClassifySelector: aMethod name
		withMethod: newMethod
		inProtocol: aMethod protocol
]

{ #category : #'reporting undeclared' }
HEInstaller >> reportNewUndeclareds: newUndeclareds [
	newUndeclareds ifNotEmpty: [ self error: 'New Undeclared created... check dependencies: ' , newUndeclareds keys printString ]
]

{ #category : #'validating existance' }
HEInstaller >> shouldBuildMethod: aHEMethod in: aClass [
	aClass
		compiledMethodAt: aHEMethod name
		ifPresent: [ :m | 
			(m isFromTrait and:[aClass isTrait not]) ifTrue:[ ^ true ].  	
			self error: (self messageMethod: aHEMethod alreadyExistsIn: aClass ) ]
		ifAbsent: [ ^ true ]
]

{ #category : #'reporting undeclared' }
HEInstaller >> validateNoNewUndeclared [
	self reportNewUndeclareds: self createdUndeclared.
	
	SystemNotification signal: ('[Hermes] Remaining Undeclared variables in the system: '
		, Undeclared keys printString)
]
