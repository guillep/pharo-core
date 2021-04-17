"
I represent environment of Pharo system. I incapsulate globals (Smalltalk globals), packageOrganizer (RPackageOrganizer  default) and changesAnnouncer (SystemAnnouncer uniqueInstance). I have class side #currentImage instance created with all corresponding globals of current image.

I am used to navigate over system by ClyNavigationEnvironment.

Public API and Key Messages

- packages
- createPackageNamed: aString
- removePackage: aPackage
- includesClassNamed: aString 
- defaultClassCompiler
- subscribe: aNavigationEnvironment
- unsubscribe: aNavigationEnvironment

Internal Representation and Key Implementation Points.

    Instance Variables
	changesAnnouncer:		<SystemAnnouncer>
	globals:		<SmalltalkDictionary> ""Smalltalk globals class""
	name:		<String>
	packageOrganizer:		<RPackageOrganizer>
	projectManager:		<ClyProjectManager>
"
Class {
	#name : #ClySystemEnvironment,
	#superclass : #Object,
	#instVars : [
		'name',
		'globals',
		'changesAnnouncer',
		'packageOrganizer',
		'projectManager'
	],
	#classInstVars : [
		'currentImage'
	],
	#category : #'Calypso-SystemQueries-Domain'
}

{ #category : #accessing }
ClySystemEnvironment class >> currentImage [
	^currentImage ifNil: [
		currentImage := self new
			name: 'current image';
			globals: Smalltalk globals;
			packageOrganizer: RPackageOrganizer default;
			changesAnnouncer: SystemAnnouncer uniqueInstance]
]

{ #category : #initialization }
ClySystemEnvironment class >> reset [
	<script>
	currentImage := nil
]

{ #category : #accessing }
ClySystemEnvironment >> allProcesses [
	^Process allSubInstances 
]

{ #category : #accessing }
ClySystemEnvironment >> asGlobalScopeIn: aNavigationEnvironment [

	
	^ClySystemEnvironmentScope of: self in: aNavigationEnvironment named: name
]

{ #category : #converting }
ClySystemEnvironment >> asRBEnvironment [
	^ self environment asRBEnvironment
]

{ #category : #'class management' }
ClySystemEnvironment >> bindingOf: aSymbol [
	^globals bindingOf: aSymbol
]

{ #category : #accessing }
ClySystemEnvironment >> changesAnnouncer [
	^ changesAnnouncer
]

{ #category : #accessing }
ClySystemEnvironment >> changesAnnouncer: anObject [
	changesAnnouncer := anObject
]

{ #category : #'class compilation' }
ClySystemEnvironment >> classCompilerFor: aClass [

	"Use aClass superclass because it knows the definerClass of aClass."

	^ aClass
		  ifNil: [ self defaultClassCompiler ]
		  ifNotNil: [ aClass superclass subclassDefinerClass new ]
]

{ #category : #'class management' }
ClySystemEnvironment >> classNamed: aString [
	^globals classNamed: aString
]

{ #category : #'class management' }
ClySystemEnvironment >> classNamed: aString ifAbsent: aBlockClosure [ 
	^globals 
		at: aString
		ifPresent: [ :existing | 
			existing isBehavior ifTrue: [ existing ] ifFalse: aBlockClosure] 
		ifAbsent: aBlockClosure
]

{ #category : #'class management' }
ClySystemEnvironment >> classNamed: aString ifPresent: aBlockClosure ifAbsent: anotherBlockClosure [
	^ globals at: aString ifPresent: aBlockClosure ifAbsent: anotherBlockClosure
]

{ #category : #accessing }
ClySystemEnvironment >> classes [
	^ globals allClassesAndTraits
]

{ #category : #compiling }
ClySystemEnvironment >> compileANewClassFrom: newClassDefinitionString notifying: aController startingFrom: oldClass [

	"The receiver's textual content is a request to define a new class. The
	source code is defString. If any errors occur in compilation, notify
	aController."

	| newClassName |
	newClassName := self extractNameFrom: newClassDefinitionString.
	((self
		  isOverridingExistingClassWhenDefiningClassNamed: newClassName
		  startingFrom: oldClass) and: [ 
		 (self confirmToOverrideExistingClassNamed: newClassName) not ]) 
		ifTrue: [ ^ nil ].

	(self isFluidDefinition: newClassDefinitionString)
		ifTrue: [ 
			ClassDefinitionPrinter showFluidClassDefinition: true.
			^ self
				  defineNewFluidClassOrTraitFrom: newClassDefinitionString
				  notifying: aController
				  startingFrom: oldClass ]
		ifFalse: [ 
			(self isTraitDefinition: newClassDefinitionString)
				ifTrue: [ 
					^ self
						  defineTrait: newClassDefinitionString
						  notifying: aController
						  startingFrom: oldClass ]
				ifFalse: [ 
					(self isClassDefinition: newClassDefinitionString)
						ifTrue: [
							^ self
							  defineNewClassFrom: newClassDefinitionString
							  notifying: aController
							  startingFrom: oldClass ]
						ifFalse: [ ^ nil ] ] ]
]

{ #category : #'class management' }
ClySystemEnvironment >> confirmToOverrideExistingClassNamed: newClassName [

	"Attempting to define new class/trait over existing one when not looking at the original one in this browser..."

	^ self confirm:
		((newClassName , ' is an existing class/trait in this system.
Redefining it might cause serious problems.
Is this really what you want to do?') asText
			 makeBoldFrom: 1
			 to: newClassName size)
]

{ #category : #'package management' }
ClySystemEnvironment >> createPackageNamed: packageName [
	^packageOrganizer createPackageNamed: packageName
]

{ #category : #'class compilation' }
ClySystemEnvironment >> defaultClassCompiler [

	^ self class compiler
]

{ #category : #compiling }
ClySystemEnvironment >> defineNewClassFrom: newClassDefinitionString notifying: aController startingFrom: oldClass [

	"Precondition: newClassDefinitionString is not a fluid class"

	| newClass |
	[ 
	newClass := (self classCompilerFor: oldClass)
		            source: newClassDefinitionString;
		            requestor: aController;
		            failBlock: [ ^ nil ];
		            logged: true;
		            evaluate ]
		on: OCUndeclaredVariableWarning
		do: [ :ex | "we are only interested in class definitions"
			ex compilationContext noPattern ifFalse: [ ex pass ].
			"Undeclared Vars should not lead to the standard dialog to define them but instead should not accept"
			self inform: 'Undeclared Variable in Class Definition'.
			^ nil ].

	^ newClass isBehavior
		  ifTrue: [ newClass ]
		  ifFalse: [ nil ]
]

{ #category : #compiling }
ClySystemEnvironment >> defineNewFluidClassOrTraitFrom: newClassDefinitionString notifying: aController startingFrom: oldClass [

	"Precondition: newClassDefinitionString is a fluid class or trait"

	| newClass |
	[ 
	newClass := (self classCompilerFor: oldClass)
		            source: '(' , newClassDefinitionString , ') install';
		            requestor: aController;
		            logged: true;
		            "for now a super ugly patch"evaluate ]
		on: OCUndeclaredVariableWarning
		do: [ :ex | "we are only interested in class definitions"
			ex compilationContext noPattern ifFalse: [ ex pass ].
			"Undeclared Vars should not lead to the standard dialog to define them but instead should not accept"
			self inform: 'Undeclared Variable in Class Definition'.
			^ nil ].

	^ newClass isBehavior
		  ifTrue: [ newClass ]
		  ifFalse: [ nil ]
]

{ #category : #'package management' }
ClySystemEnvironment >> ensureExistAndRegisterPackageNamed: packageName [
	^packageOrganizer ensureExistAndRegisterPackageNamed: packageName
]

{ #category : #accessing }
ClySystemEnvironment >> environment [
	^ RBBrowserEnvironment new
]

{ #category : #'class management' }
ClySystemEnvironment >> extractNameFrom: aDefinitionString [

	| defTokens keywdIx |
	(self isFluidDefinition: aDefinitionString)
		ifFalse: [ 
			defTokens := aDefinitionString findTokens: Character separators.
			(self isTraitDefinition: aDefinitionString)
				ifFalse: [ 
					keywdIx := defTokens findFirst: [ :x | x beginsWith: 'category' ].
					keywdIx := defTokens findFirst: [ :x | '*subclass*' match: x ] ]
				ifTrue: [ 
					keywdIx := defTokens findFirst: [ :x | x = 'category' ].
					keywdIx := defTokens findFirst: [ :x | x = 'named:' ] ].
			^ (defTokens at: keywdIx + 1 ifAbsent: [ '' ]) copyWithoutAll:
				  '#()' ]
		ifTrue: [ 
			defTokens := aDefinitionString findTokens:
				             Character separators , '<#'.
			^ defTokens at: 2 ifAbsent: [ '' ] ]
]

{ #category : #accessing }
ClySystemEnvironment >> globals [
	^ globals
]

{ #category : #accessing }
ClySystemEnvironment >> globals: anObject [
	globals := anObject
]

{ #category : #'class management' }
ClySystemEnvironment >> includesClassNamed: aSymbol [
	^globals includesKey: aSymbol
]

{ #category : #initialization }
ClySystemEnvironment >> initialize [
	super initialize.
	projectManager := ClyProjectManagerRegistry new
]

{ #category : #compiling }
ClySystemEnvironment >> isClassDefinition: newClassDefinitionString [
	| defTokens |
	defTokens := newClassDefinitionString findTokens: Character separators.
	^ (self class environment classNamed: defTokens first) isNotNil.
	
 
]

{ #category : #testing }
ClySystemEnvironment >> isFluidClassDefinition: classDefinitionString [

	| splitted |
	splitted := classDefinitionString splitOn: '<<'.
	^ splitted size = 2 and: [ 
		  splitted first trim ~= 'Trait' and: [ 
			  '#*' match:
				  (splitted second findTokens: Character separators) first ] ]
]

{ #category : #testing }
ClySystemEnvironment >> isFluidDefinition: aDefinitionString [

	^ (self isFluidClassDefinition: aDefinitionString) or: [ 
		  self isFluidTraitDefinition: aDefinitionString ]
]

{ #category : #testing }
ClySystemEnvironment >> isFluidTraitDefinition: traitDefinitionString [

	| splitted |
	splitted := traitDefinitionString splitOn: '<<'.
	^ splitted size = 2 and: [ 
		  splitted first trim = 'Trait' and: [ 
			  '#*' match:
				  (splitted second findTokens: Character separators) first ] ]
]

{ #category : #testing }
ClySystemEnvironment >> isOldTraitDefinition: traitDefinitionString [

	| defTokens |
	defTokens := traitDefinitionString findTokens:
		             Character separators.
	^ defTokens size >= 2 and: [ 
		  (defTokens first = 'Trait' and: [ defTokens second = 'named:' ]) 
			  or: [ defTokens second = 'classTrait' ] ]
]

{ #category : #'class management' }
ClySystemEnvironment >> isOverridingExistingClassWhenDefiningClassNamed: newClassName startingFrom: oldClass [

	"Attempting to define new class over existing one when not looking at the original one in this browser..."

	^ (oldClass isNil or: [ 
		   oldClass instanceSide name asString ~= newClassName ]) and: [ 
		  self includesClassNamed: newClassName asSymbol ]
]

{ #category : #testing }
ClySystemEnvironment >> isTraitDefinition: newClassDefinitionString [

	^ (self isFluidTraitDefinition: newClassDefinitionString) or: [ 
		  self isOldTraitDefinition: newClassDefinitionString ]
]

{ #category : #accessing }
ClySystemEnvironment >> name [
	^ name ifNil: [ super printString ]
]

{ #category : #accessing }
ClySystemEnvironment >> name: anObject [
	name := anObject
]

{ #category : #'package management' }
ClySystemEnvironment >> packageNamed: aString [ 
	^packageOrganizer packageNamed: aString
]

{ #category : #accessing }
ClySystemEnvironment >> packageOrganizer [
	^ packageOrganizer
]

{ #category : #accessing }
ClySystemEnvironment >> packageOrganizer: anObject [
	packageOrganizer := anObject
]

{ #category : #accessing }
ClySystemEnvironment >> packages [
	^ packageOrganizer packages
]

{ #category : #printing }
ClySystemEnvironment >> printOn: aStream [
	super printOn: aStream.
	name ifNil: [ ^self ].
	
	aStream nextPut: $(.
	aStream nextPutAll: name.
	aStream nextPut: $).
]

{ #category : #accessing }
ClySystemEnvironment >> projectManager [
	^ projectManager
]

{ #category : #accessing }
ClySystemEnvironment >> projectManager: anObject [
	projectManager := anObject
]

{ #category : #accessing }
ClySystemEnvironment >> projects [
	^projectManager projects
]

{ #category : #'package management' }
ClySystemEnvironment >> registerProjectManager: aPackageManager [
	aPackageManager systemEnvironment: self.
	projectManager registerProjectManager: aPackageManager
]

{ #category : #'package management' }
ClySystemEnvironment >> removePackage: aPackage [

	packageOrganizer unregisterPackage: aPackage
]

{ #category : #subscription }
ClySystemEnvironment >> subscribe: anObject [
	self subscribe: anObject for: SystemAnnouncement
]

{ #category : #subscription }
ClySystemEnvironment >> subscribe: anObject for: anAnnouncementClass [
	self when: anAnnouncementClass send: #systemChanged: to: anObject 
]

{ #category : #subscription }
ClySystemEnvironment >> unsubscribe: anObject [
	changesAnnouncer unsubscribe: anObject
]

{ #category : #subscription }
ClySystemEnvironment >> when: anAnnouncementClass send: aSelector to: anObject [
	changesAnnouncer weak when: anAnnouncementClass send: aSelector to: anObject
]
