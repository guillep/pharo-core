"
An RGBehavior is an abstract definition for class-alike entities (e.g. classes, traits)

Instance Variables
	methods:		<Collection>
	protocols:		<Collection>
	superclass:		<Object>
"
Class {
	#name : #RGBehavior,
	#superclass : #RGBehaviorStrategyUser,
	#instVars : [
		'superclass',
		'localMethods',
		'traitComposition',
		'metaclass',
		'tagsForMethods',
		'tags'
	],
	#category : #'Ring-Core-Kernel'
}

{ #category : #'as yet unclassified' }
RGBehavior class >> badInstantiationError [

	RGBadInstantiationError signal: 'I cannot be instantiated this way because every RGBehavior must know its proper behavior strategy. Please use a subclass of RGBehaviorFactory or my methods like #newClass'
]

{ #category : #'as yet unclassified' }
RGBehavior class >> named: aString [

	^ self badInstantiationError
]

{ #category : #'as yet unclassified' }
RGBehavior class >> named: aName behaviorStrategy: anRGBehaviorStrategy [

	| aBehavior |
	
	aBehavior := self basicNew
		behaviorStrategy: anRGBehaviorStrategy;
		initialize.
	anRGBehaviorStrategy initialize.
	^ aBehavior
		pvtName: aName asSymbol;
		yourself		

]

{ #category : #'as yet unclassified' }
RGBehavior class >> named: aString parent: anRGObject [

	^ self badInstantiationError
]

{ #category : #'as yet unclassified' }
RGBehavior class >> named: aName parent: anRGObject behaviorStrategy: anRGBehaviorStrategy [
	
	| aBehavior |

	aBehavior := self basicNew
		behaviorStrategy: anRGBehaviorStrategy;
		parent: anRGObject;
		initialize.
	anRGBehaviorStrategy initialize.
	^ aBehavior
		pvtName: aName asSymbol;
		yourself		

]

{ #category : #'instance creation' }
RGBehavior class >> newClass [

	^ self unnamedWithBehaviorStrategy: RGClassStrategy basicNew
]

{ #category : #'instance creation' }
RGBehavior class >> newMetaclass [

	^ self unnamedWithBehaviorStrategy: RGMetaclassStrategy basicNew
]

{ #category : #'instance creation' }
RGBehavior class >> newMetaclassTrait [

	^ self unnamedWithBehaviorStrategy: RGMetaclassTrait newStrategy
]

{ #category : #'instance creation' }
RGBehavior class >> newTrait [

	^ self unnamedWithBehaviorStrategy: RGTrait newStrategy
]

{ #category : #'as yet unclassified' }
RGBehavior class >> parent: anRGObject behaviorStrategy: anRGBehaviorStrategy [
	
	| aBehavior |

	aBehavior := self basicNew
		behaviorStrategy: anRGBehaviorStrategy;
		parent: anRGObject;
		initialize.
	anRGBehaviorStrategy initialize.
	^ aBehavior

]

{ #category : #'as yet unclassified' }
RGBehavior class >> unnamedWithBehaviorStrategy: anRGBehaviorStrategy [

	| aBehavior |
	
	aBehavior := self basicNew
		behaviorStrategy: anRGBehaviorStrategy;
		initialize.
	anRGBehaviorStrategy initialize.
	^ aBehavior

]

{ #category : #'as yet unclassified' }
RGBehavior class >> unresolvedNamed: aName withParent: anRGObject behaviorStrategy: anRGBehaviorStrategy [
	
	| aBehavior |

	aBehavior := self basicNew
		behaviorStrategy: anRGBehaviorStrategy;
		parent: anRGObject;
		initializeUnresolved.
	anRGBehaviorStrategy initializeUnresolved.
	^ aBehavior
		pvtName: aName asSymbol;
		yourself		

]

{ #category : #'as yet unclassified' }
RGBehavior class >> unresolvedWithBehaviorStrategy: anRGBehaviorStrategy [

	| aBehavior |
	
	aBehavior := self basicNew
		behaviorStrategy: anRGBehaviorStrategy;
		initializeUnresolved.
	anRGBehaviorStrategy initializeUnresolved.
	^ aBehavior

]

{ #category : #'as yet unclassified' }
RGBehavior class >> unresolvedWithParent: anRGObject behaviorStrategy: anRGBehaviorStrategy [
	
	| aBehavior |

	aBehavior := self basicNew
		behaviorStrategy: anRGBehaviorStrategy;
		parent: anRGObject;
		initializeUnresolved.
	anRGBehaviorStrategy initializeUnresolved.
	^ aBehavior

]

{ #category : #'accessing - backend' }
RGBehavior >> addLocalMethod: anRGMethod [

	self backend forBehavior addLocalMethod: anRGMethod to: self.
	
	self announcer methodAdded: anRGMethod.

]

{ #category : #'accessing - backend' }
RGBehavior >> addMethodTag: aSymbol [ 

	self announceDefinitionChangeDuring: [ 
		self backend forBehavior addMethodTag: aSymbol to: self. ].
]

{ #category : #'accessing - backend' }
RGBehavior >> addProtocol: aSymbol [ 

	self addMethodTag: aSymbol

]

{ #category : #'managing container' }
RGBehavior >> addoptToParentStub [

	self isRingResolved ifFalse: [ ^ self ].

	super addoptToParentStub.

	self parent pvtAddBehavior: self.
	


]

{ #category : #'queries - other' }
RGBehavior >> allInstVarNames [
	"Answer an Array of the names of the receiver's instance variables. The 
	Array ordering is the order in which the variables are stored and 
	accessed by the interpreter."

	| vars |
	(self superclass == self or: [ self superclass isNil ])
		ifTrue: [vars := self instVarNames copy]	"Guarantee a copy is answered."
		ifFalse: [vars := self superclass allInstVarNames , self instVarNames].
	^vars
]

{ #category : #announcements }
RGBehavior >> announceDefinitionChangeDuring: aBlock [

	| oldVersion |

	self announcer isSuspended ifTrue: [ 
		aBlock value. 
		^ self ]	.
		
	self announcer  suspendAllWhile: [ 
		oldVersion := self copyForBehaviorDefinition.].
	aBlock value.
	self announcer 	behaviorDefinitionChangedFrom: oldVersion to: self.
	self announcer behaviorModificationAppliedTo: self.

	
	
]

{ #category : #asYetUnclassified }
RGBehavior >> asYetUnclassifiedProtocolName [

	^ 'as yet unclassified' asSymbol
]

{ #category : #testing }
RGBehavior >> canMergeWith: anRGObject visited: visitedDefinitions [

	| newVisited |

	(visitedDefinitions includes: self) ifTrue: [ ^ true ].
	
	(self isRingFullyResolved or: [ anRGObject isRingFullyResolved]) ifTrue: [^ true].

	(super canMergeWith: anRGObject visited: visitedDefinitions) ifFalse: [ ^ false ].

	newVisited := visitedDefinitions copyWith: self.
	
	self superclass ~~ self ifTrue: [ 
		(self superclass canMergeWith: anRGObject superclass visited: newVisited) ifFalse: [ ^ false ]].

	self metaclass ~~ self ifTrue: [ 
		(self metaclass canMergeWith: anRGObject metaclass visited: newVisited) ifFalse: [ ^ false ]].
	
	^ true.
]

{ #category : #'accessing - definition' }
RGBehavior >> classVariablesBindings [

	^ self propertyNamed: #classVariablesBindings ifAbsentPut: [ IdentityDictionary new.]
]

{ #category : #'accessing - definition' }
RGBehavior >> classVariablesString [
	"Answer a string of my class variable names separated by spaces."

	^ self behaviorStrategy classVariablesString
]

{ #category : #'accessing - backend' }
RGBehavior >> cleanLocalMethods [

	| oldMethods |
	
	oldMethods := self localMethods.

	self backend forBehavior cleanLocalMethodsFor: self.

	self cleanProtocols.
	
	oldMethods do: [ :each |
		self announcer methodRemoved: each ]

]

{ #category : #'accessing - backend' }
RGBehavior >> cleanProtocols [
	
	self cleanTagsForMethods
]

{ #category : #'accessing - backend' }
RGBehavior >> cleanTags [

	self announceDefinitionChangeDuring: [ 
		self cleanTagsWithoutAnnouncemnt ].
]

{ #category : #'accessing - backend' }
RGBehavior >> cleanTagsForMethods [

	self backend forPackage cleanTagsForMethodsFor: self
]

{ #category : #'accessing - backend' }
RGBehavior >> cleanTagsWithoutAnnouncemnt [

	self backend forBehavior cleanClassTagsFor: self.
]

{ #category : #accessing }
RGBehavior >> compiler [

	^ self class compiler
]

{ #category : #conversion }
RGBehavior >> convertToMetaclassTrait [

	| metaclassTraitStrategy originalName |
	
	(self resolvedProperties includesAnyOf: #(traitComposition))
		ifTrue: [self error: 'This class cannot be converted to trait'].
		
	"TODO: check empty layout"
"	newMetaclassTrait := RGMetaclassTrait unresolvedWithParent: self parent.
	newMetaclassTrait copyPropertiesFrom: self.
"
	metaclassTraitStrategy := RGMetaclassTrait newStrategyFor: self environment.
	metaclassTraitStrategy owner: self.
	metaclassTraitStrategy pvtBaseTrait: self behaviorStrategy pvtBaseClass.

	self behaviorStrategy: metaclassTraitStrategy.

	originalName := self name.
	
	(self hasResolvedName)
		ifTrue: [ self pvtName: ((self name withoutSuffix: ' class'), ' classTrait') asSymbol ].
		
	self environment ask replaceName: originalName with: self name.

	
	
	
]

{ #category : #conversion }
RGBehavior >> convertToTrait [

	| traitStrategy originalName |
	
	(self resolvedProperties includesAnyOf: #("superclass" traitComposition classVariables sharedPools))
		ifTrue: [self error: 'This class cannot be converted to trait'].
		
	"TODO: check empty layout"
	"newTrait := RGTrait unresolvedWithParent: self parent.
	newTrait copyPropertiesFrom: self.
	newTrait pvtName: name.
	newTrait pvtLocalMethods: localMethods.
	newTrait pvtTags: tags.

	newTrait behaviorStrategy pvtComment: self behaviorStrategy comment.
	newTrait behaviorStrategy pvtPackage: self behaviorStrategy package."

	originalName := self name.

	traitStrategy := RGTrait newStrategyFor: self environment.
	traitStrategy owner: self.
	traitStrategy pvtClassTrait: self pvtMetaclass.
	traitStrategy pvtPackage: self behaviorStrategy pvtPackage.
	traitStrategy pvtComment: self behaviorStrategy pvtComment.
	
	self behaviorStrategy: traitStrategy.

	self environment ask replaceName: originalName with: self name.
	
	
]

{ #category : #copying }
RGBehavior >> copyForBehaviorDefinitionPostCopy [

	super copyForBehaviorDefinitionPostCopy.
	
	superclass := self superclass shallowCopy. "we need the superclass name"
	traitComposition := self traitComposition copyForBehaviorDefinition.
	tagsForMethods := self tagsForMethods copy asSet.
	tags := self tags copy asSet.
	
	behaviorStrategy := behaviorStrategy copyForBehaviorDefinitionWithOwner: self

]

{ #category : #'default model values' }
RGBehavior >> defaultLayout [

	^ self defaultFixedLayoutStubIn: self.
]

{ #category : #'default model values' }
RGBehavior >> defaultLocalMethods [

	^ Set new
]

{ #category : #'managing container' }
RGBehavior >> defaultParentStub [

	^ self defaultEnvironmentStub
]

{ #category : #'default model values' }
RGBehavior >> defaultTags [

	^ Set new
]

{ #category : #'default model values' }
RGBehavior >> defaultTagsForMethods [

	^ Set new
]

{ #category : #'default model values' }
RGBehavior >> defaultTraitComposition [

	^ self defaultTraitCompositionStubIn: self.
]

{ #category : #fileout }
RGBehavior >> definitionStringFor: aConfiguredPrinter [

	^ aConfiguredPrinter classDefinitionString 
]

{ #category : #'queries - methods' }
RGBehavior >> ensureLocalMethodNamed: aSymbol [

	^ self localMethodNamed: aSymbol ifAbsent: [ 
		| newMethod |
		newMethod := RGMethod named: aSymbol asSymbol parent: self.
		self addLocalMethod: newMethod.
		newMethod].
]

{ #category : #'queries - tags' }
RGBehavior >> ensureMethodTagNamed: aSymbol [

	^ self tagsForMethods detect: [ :each | each asSymbol = aSymbol ] ifNone: [ 
		self addMethodTag: aSymbol.
		aSymbol ]
]

{ #category : #'queries - protocols' }
RGBehavior >> ensureProtocolNamed: aSymbol [
 
	^ self ensureMethodTagNamed: aSymbol
]

{ #category : #'queries - methods' }
RGBehavior >> ensureUnresolvedLocalMethod [

	| newMethod |
	newMethod := RGMethod parent: self.
	self addLocalMethod: newMethod.
	^ newMethod
]

{ #category : #documentation }
RGBehavior >> extensions [

	^ self localMethods select: [ :each | each package ~= self package ]
]

{ #category : #testing }
RGBehavior >> hasComment [

	^ self comment isEmptyOrNil not
]

{ #category : #'queries - testing' }
RGBehavior >> hasMethods [
	"validates the existance of methods"

	^ self methods notEmpty
]

{ #category : #testing }
RGBehavior >> hasResolvedSuperclass [

	^ self hasResolved: #superclass
]

{ #category : #'queries - testing' }
RGBehavior >> hasTraitComposition [

	^	self traitComposition transformations isEmpty not
]

{ #category : #'queries - methods' }
RGBehavior >> includesSelector: aString [

	^ self selectors includes: aString
]

{ #category : #'testing class hierarchy' }
RGBehavior >> inheritsFrom: aClass [ 
	"Answer whether the argument, aClass, is on the receiver's superclass 
	chain."

	| aSuperclass |
	aSuperclass := self superclass.
	[aSuperclass == nil]
		whileFalse: 
			[aSuperclass == aClass ifTrue: [^true].
			aSuperclass := aSuperclass superclass].
	^false
]

{ #category : #initialization }
RGBehavior >> initialize [

	super initialize.
	
	"use unresolved value for superclass to avoid infinite recursion. It needs to be set later"
	superclass := RGUnresolvedValue recursive.
	metaclass := RGUnresolvedValue recursive.
	localMethods := self unresolvedValue: self defaultLocalMethods.
	traitComposition := self unresolvedValue: self defaultTraitComposition.
	tagsForMethods := self unresolvedValue: self defaultTagsForMethods.	
	tags := self unresolvedValue: self defaultTags.	

]

{ #category : #initialization }
RGBehavior >> initializeUnresolved [

	super initializeUnresolved.

	superclass := self. "will be set later"
	metaclass := self. "will be set later"
	localMethods := self unresolvedValue: self defaultLocalMethods.
	traitComposition := self unresolvedValue: self defaultTraitComposition.
	tagsForMethods := self unresolvedValue: self defaultTagsForMethods.	
	tags := self unresolvedValue: self defaultTags.	

]

{ #category : #'queries - testing' }
RGBehavior >> isAccessedIn: anRGMethod [
	^ (anRGMethod ast variableNodes select: [ :each | 
		   each isGlobalVariable ]) anySatisfy: [ :each | 
		  each name = self name ]
]

{ #category : #testing }
RGBehavior >> isBehavior [

	^ true
]

{ #category : #'testing - layouts' }
RGBehavior >> isBits [

	^ self layout isBitsLayout
]

{ #category : #'testing - layouts' }
RGBehavior >> isBytes [

	^ self layout isByteLayout 
]

{ #category : #'testing - layouts' }
RGBehavior >> isCompiledMethod [

	^ self layout isCompiledMethodLayout 
]

{ #category : #'testing - layouts' }
RGBehavior >> isEphemeron [

	^ self layout isEphemeronLayout
]

{ #category : #'testing - layouts' }
RGBehavior >> isEphemeronClass [

	^ self layout isEphemeronLayout 
]

{ #category : #'testing - layouts' }
RGBehavior >> isImmediateClass [

	^ self layout isImmediateLayout  
]

{ #category : #testing }
RGBehavior >> isPointers [

	^ self isBits not
]

{ #category : #'queries - testing' }
RGBehavior >> isRootInEnvironment [		
		
	^ self superclass == self or: [ self superclass isNil ] 
]

{ #category : #testing }
RGBehavior >> isTaggedWith: aSymbol [

	^self tags includes: aSymbol 
]

{ #category : #'testing - layouts' }
RGBehavior >> isVariable [

	"is the definition a variable class?"

	^ self layout isVariableLayout
]

{ #category : #testing }
RGBehavior >> isWeak [

	^ self layout isWeakLayout
]

{ #category : #'testing - layouts' }
RGBehavior >> isWords [

	^ self layout isWordLayout 
]

{ #category : #'queries - methods' }
RGBehavior >> localMethodNamed: aSymbol ifAbsent: aBlock [

	self localMethodsDo: [ :each | (each name = aSymbol) ifTrue: [^ each]].
	
	^ aBlock value.
]

{ #category : #'queries - methods' }
RGBehavior >> localMethods [

	^ self localMethodsSet asArray
]

{ #category : #'accessing - backend' }
RGBehavior >> localMethodsDo: aBlock [

	self backend forBehavior localMethodsFor: self do: aBlock
]

{ #category : #'queries - methods' }
RGBehavior >> localMethodsSet [

	| methods |
	
	methods := self defaultLocalMethods.
	self localMethodsDo: [ :each | methods add: each ].
	^ methods
]

{ #category : #'queries - methods' }
RGBehavior >> localSelectors [

	^ self localMethods collect: [ :each | each name ]
]

{ #category : #lookup }
RGBehavior >> lookupVar: aName [
	^ self layout 
		resolveSlot: aName asSymbol 
		ifFound: [:var | var] 
		ifNone: [self bindingOf: aName]
]

{ #category : #lookup }
RGBehavior >> lookupVarForDeclaration: aName [

	"This is a version of #lookupVar: that skips the OCRequestorScope, from here on it is the same as lookupVar:"

	^ self lookupVar: aName
]

{ #category : #resolving }
RGBehavior >> makeResolved [

	superclass := self superclass markAsRingResolved.
	localMethods := self localMethodsSet markAsRingResolved.
	traitComposition := self traitComposition markAsRingResolved.
	metaclass := self metaclass markAsRingResolved.
	tagsForMethods := self tagsForMethodsSet markAsRingResolved.
	tags := self tagsSet markAsRingResolved.
	
	super makeResolved.
]

{ #category : #'accessing - backend' }
RGBehavior >> metaclass [

	^ self backend forBehavior metaclassFor: self
]

{ #category : #'accessing - backend' }
RGBehavior >> metaclass: anRGMetaclass [

	self backend forBehavior setMetaclassFor: self to: anRGMetaclass.
	

]

{ #category : #'queries - methods' }
RGBehavior >> methodNamed: aSymbol [

	| allMethods |
	allMethods := IdentitySet new.
	self methods do: [ :each | each name = aSymbol ifTrue: [^ each]].
	^ nil
]

{ #category : #'queries - methods' }
RGBehavior >> methods [

	| methodsFromTraits methodsDict |
	"TODO: make nicer"
	"^ self propertyNamed: #methods ifAbsentPut: [ "
	methodsFromTraits := self traitComposition methods collect:  [ :each | each copy parent: self ].
	methodsDict := Dictionary new.
	methodsFromTraits do: [ :each |
		methodsDict at: each name put: each ].
	self localMethodsDo: [ :each |
		methodsDict at: each name put: each ].
	^ methodsDict values asArray"]"

]

{ #category : #'queries - tags' }
RGBehavior >> methodsTaggedWith: aSymbol [

	^ self localMethods select: [ :each | each isTaggedWith: aSymbol ]
]

{ #category : #'accessing - backend' }
RGBehavior >> name: aString [

	| oldName subclassesWithOldDefinitions |
	
	oldName := self name.
	
	subclassesWithOldDefinitions := (self subclasses reject: [:each | each isMeta]) collect: [ :each | 
		each -> each copyForBehaviorDefinition ].
	
	self announceDefinitionChangeDuring: [ 
		super name: aString ].
	
	self announcer behaviorRenamed: self from: oldName.

	subclassesWithOldDefinitions do: [ :assoc |
		self announcer behaviorDefinitionChangedFrom: assoc value to: assoc key.
		self announcer behaviorModificationAppliedTo: assoc key.
		self announcer behaviorParentRenamed: assoc key from: oldName ].
]

{ #category : #fileout }
RGBehavior >> oldDefinition [
	
	^ ClassDefinitionPrinter legacy
		for: self;
		definitionString
]

{ #category : #printing }
RGBehavior >> printOn: aStream [ 
	aStream nextPutAll: self name
]

{ #category : #'queries - protocols' }
RGBehavior >> protocols [

	| methodTags |
	
	methodTags := self tagsForMethods.
	^	methodTags
		ifEmpty: [ 
			self methods 
				ifEmpty: [ OrderedCollection new ]
				ifNotEmpty: [  OrderedCollection with: self class asYetUnclassifiedProtocolName   ].
			]
		ifNotEmpty: [ methodTags  ]

]

{ #category : #'private - backend interface' }
RGBehavior >> pvtAddLocalMethod: anRGMethod [

	self environment verifyOwnership: anRGMethod.
	
	localMethods isRingResolved ifFalse: [ 
		self pvtCleanLocalMethods ].

	(self hasResolved: #tagsForMethods) 
		ifFalse: [ self pvtCleanTagsForMethods ].

	anRGMethod tags do: [ :aTag |
		self pvtAddMethodTag: aTag ].

	localMethods add: anRGMethod.	
	
]

{ #category : #'private - backend access' }
RGBehavior >> pvtAddMethodTag: aSymbol [
	
	tagsForMethods isRingResolved ifFalse: [ 
		self pvtCleanTagsForMethods  ].
	
	tagsForMethods add: aSymbol.	
	
]

{ #category : #strategy }
RGBehavior >> pvtAsTrait [

	| traitStrategy |
	
	(self resolvedProperties includesAnyOf: #("superclass" traitComposition classVariables sharedPools))
		ifTrue: [self error: 'This class cannot be converted to trait'].
		
	"TODO: check empty layout"
	"newTrait := RGTrait unresolvedWithParent: self parent.
	newTrait copyPropertiesFrom: self.
	newTrait pvtName: name.
	newTrait pvtLocalMethods: localMethods.
	newTrait pvtTags: tags.

	newTrait behaviorStrategy pvtComment: self behaviorStrategy comment.
	newTrait behaviorStrategy pvtPackage: self behaviorStrategy package."

	traitStrategy := RGTrait newStrategyFor: self environment.

	traitStrategy pvtComment: self behaviorStrategy comment.
	traitStrategy pvtPackage: self behaviorStrategy package.
	
	self behaviorStrategy: traitStrategy.
	
	^ self	
	
]

{ #category : #'private - backend interface' }
RGBehavior >> pvtCleanLocalMethods [

	localMethods := self defaultLocalMethods.
	
]

{ #category : #'private - backend access' }
RGBehavior >> pvtCleanTags [

	tags := self defaultTags.
		
	"TODO:Announce if not empty"
	
	
]

{ #category : #'private - backend access' }
RGBehavior >> pvtCleanTagsForMethods [

	tagsForMethods := self defaultTagsForMethods.
		
	"TODO:Announce if not empty"
	
	
]

{ #category : #private }
RGBehavior >> pvtLocalMethods: aCollection [

	"use only for low-level copying"
	localMethods := aCollection
]

{ #category : #'private - backend interface' }
RGBehavior >> pvtLocalMethodsDo: aBlock [

	^ localMethods value do: aBlock
]

{ #category : #'private - backend access' }
RGBehavior >> pvtMetaclass [

	^ metaclass value
]

{ #category : #'private - backend access' }
RGBehavior >> pvtMetaclass: anRGMetaclass [

	self environment verifyOwnership: anRGMetaclass.

	^ metaclass := anRGMetaclass
]

{ #category : #'private - backend interface' }
RGBehavior >> pvtRemoveLocalMethod: anRGMethod [

	self environment verifyOwnership: anRGMethod.
	
	localMethods remove: anRGMethod.
	

]

{ #category : #'private - backend access' }
RGBehavior >> pvtRemoveMethodTag: aSymbol [
	
	tagsForMethods remove: aSymbol.
	
	"TODO:Announce"
	
	
]

{ #category : #'private - backend interface' }
RGBehavior >> pvtResolvableProperties [

	^ super pvtResolvableProperties, { 
		#superclass -> superclass. 
		#localMethods -> localMethods. 
		#traitComposition -> traitComposition.  
		#metaclass -> metaclass.  
		#tagsForMethods -> tagsForMethods. 
 		#tags -> tags. 
    	}, self behaviorStrategy pvtResolvableProperties
	
	
]

{ #category : #'private - backend interface' }
RGBehavior >> pvtSuperclass [

	^ superclass value
	
]

{ #category : #'private - backend interface' }
RGBehavior >> pvtSuperclass: anRGBehavior [

	anRGBehavior ifNotNil: [ 
		self environment verifyOwnership: anRGBehavior.].

	^ superclass := anRGBehavior
	
]

{ #category : #'private - backend access' }
RGBehavior >> pvtTagWith: aSymbol [
	
	tags isRingResolved ifFalse: [ 
		self pvtCleanTags  ].
	
	tags add: aSymbol.	
	
]

{ #category : #'private - backend access' }
RGBehavior >> pvtTags: aCollection [

	^ tags := aCollection
]

{ #category : #'private - backend access' }
RGBehavior >> pvtTagsDo: aBlock [

	^ tags value do: aBlock
]

{ #category : #'private - backend access' }
RGBehavior >> pvtTagsForMethodsDo: aBlock [

	^ tagsForMethods value do: aBlock
]

{ #category : #'private - backend interface' }
RGBehavior >> pvtTraitComposition [

	^ traitComposition value
]

{ #category : #'private - backend interface' }
RGBehavior >> pvtTraitComposition: anRGTraitComposition [

	self environment verifyOwnership: anRGTraitComposition.

	^ traitComposition := anRGTraitComposition
]

{ #category : #'private - backend access' }
RGBehavior >> pvtUntagFrom: aSymbol [
	
	(tags value includes: aSymbol)
		ifTrue: [ tags remove: aSymbol ].
	
	"TODO:Announce"
	
	
]

{ #category : #'accessing - backend' }
RGBehavior >> removeLocalMethod: anRGMethod [ 

	(anRGMethod package = self package)
		ifFalse: [ anRGMethod package removeExtensionMethod:  anRGMethod ].
		
	self backend forBehavior removeLocalMethod: anRGMethod from: self.
	
	self announcer methodRemoved: anRGMethod.

]

{ #category : #'accessing - backend' }
RGBehavior >> removeMethodTag: aSymbol [

	self backend forPackage removeMethodTag: aSymbol from: self.
	
	self localMethodsDo: [ :method | 
		method untagFrom: aSymbol ].
]

{ #category : #'accessing - backend' }
RGBehavior >> removeProtocol: aSymbol [

	self removeMethodTag: aSymbol.
]

{ #category : #'queries - methods' }
RGBehavior >> selectors [

	^ self methods collect: [ :each | each name ]
]

{ #category : #'accessing - definition' }
RGBehavior >> sharedPoolsString [
	"Answer a string of my class variable names separated by spaces."

	"TODO: check validity"
	^String streamContents: [ :stream | 
		self sharedPools 
			do: [ :each | stream nextPutAll: each name]
			separatedBy: [ stream space ] ]
]

{ #category : #printing }
RGBehavior >> slotDefinitionString [
	"Answer a string that contains an executable description of my Slots"

	"^self slots ifNotEmpty: [self slots asString] ifEmpty: ['{}']"
	
	^String streamContents: [ :str | | special |
		str nextPutAll: '{ '.
		self slots do: [:slot |
				str nextPutAll: slot definitionString.
				special := slot needsFullDefinition]				
			separatedBy: [ 
				str nextPutAll: ' . '.  
				special ifTrue: [ str cr;tab;tab;tab;tab ]].
		str nextPutAll: ' }'. ]

]

{ #category : #slots }
RGBehavior >> slots [		
		
	^ self layout slots 
]

{ #category : #slots }
RGBehavior >> slotsNeedFullDefinition [
	"return true if we define something else than InstanceVariableSlots"
	^self slots anySatisfy: [ :each | each needsFullDefinition ]
]

{ #category : #'accessing class hierarchy' }
RGBehavior >> subclasses [

	| result |
	result := IdentitySet new.
	self environment behaviorsDo: [ :each |
		(each superclass == self) ifTrue: [ result add: each] ].
	^ result asArray
]

{ #category : #'accessing - backend' }
RGBehavior >> superclass [

	^ self backend forBehavior superclassFor: self
]

{ #category : #'accessing - backend' }
RGBehavior >> superclass: anRGBehavior [

	self announceDefinitionChangeDuring: [ 
		self backend forBehavior setSuperclassFor: self to: anRGBehavior ].
]

{ #category : #'accessing - backend' }
RGBehavior >> tagWith: aSymbol [ 

	self announceDefinitionChangeDuring: [ 
		self backend forBehavior tagClass: self with: aSymbol.
		self package addClassTag: aSymbol.
	].
	
]

{ #category : #'accessing - model' }
RGBehavior >> tags [

	^ self tagsSet asArray 

]

{ #category : #'accessing - backend' }
RGBehavior >> tagsDo: aBlock [

	self backend forBehavior tagsForClass: self do: aBlock
]

{ #category : #'accessing - model' }
RGBehavior >> tagsForAllMethods [
	"I act as #tagsForMethods but I also takes into account methods comming from traits"

	^ self methods flatCollect: [ :each  | each tags ] as: Set
]

{ #category : #'accessing - model' }
RGBehavior >> tagsForMethods [
	"Retrieves the traits defined in the receiver"

	| allTags |
	allTags := self defaultTagsForMethods.
	self tagsForMethodsDo: [ :each | allTags add: each].
	^ allTags asArray
]

{ #category : #'accessing - backend' }
RGBehavior >> tagsForMethodsDo: aBlock [

	self backend forBehavior tagsForMethodsFor: self do: aBlock
]

{ #category : #'accessing - model' }
RGBehavior >> tagsForMethodsSet [
	"Retrieves the traits defined in the receiver"

	| allTags |
	allTags := self defaultTagsForMethods.
	self tagsForMethodsDo: [ :each | allTags add: each].
	^ allTags
]

{ #category : #'accessing - model' }
RGBehavior >> tagsSet [

	| allTags |
	allTags := self defaultTags.
	self tagsDo: [ :each | allTags add: each].
	^ allTags 

]

{ #category : #'accessing - backend' }
RGBehavior >> traitComposition [

	^ self backend forBehavior traitCompositionFor: self
]

{ #category : #'accessing - backend' }
RGBehavior >> traitComposition: anRGTraitComposition [

	self announceDefinitionChangeDuring: [ 
		self backend forBehavior setTraitCompositionFor: self to: anRGTraitComposition.].
]

{ #category : #'accessing - definition' }
RGBehavior >> traitCompositionString [
	^ self traitComposition traitCompositionString
		
]

{ #category : #'accessing - backend' }
RGBehavior >> unresolveName [

	| oldName subclassesWithOldDefinitions |
	
	oldName := self name.
	
	subclassesWithOldDefinitions := (self subclasses reject: [:each | each isMeta]) collect: [ :each | 
		each -> each copyForBehaviorDefinition ].
	
	self announceDefinitionChangeDuring: [ 
		super unresolveName ].
	
	self announcer behaviorRenamed: self from: oldName.

	subclassesWithOldDefinitions do: [ :assoc |
		self announcer behaviorDefinitionChangedFrom: assoc value to: assoc key.
		self announcer behaviorModificationAppliedTo: assoc key.
		self announcer behaviorParentRenamed: assoc key from: oldName ].
]

{ #category : #'accessing - backend' }
RGBehavior >> unresolveSuperclass [

	self announceDefinitionChangeDuring: [ 
		self pvtSuperclass: (RGUnresolvedValue recursive) ].
]

{ #category : #'accessing - backend' }
RGBehavior >> untagFrom: aSymbol [

	self backend forPackage untagClass: self from: aSymbol
]

{ #category : #asYetUnclassified }
RGBehavior >> usedTraits [

	^ self traitComposition usedTraits
]

{ #category : #accessing }
RGBehavior >> users [
	^ #()
]

{ #category : #generated }
RGBehavior >> usesSpecialSlot [

	"return true if we define something else than InstanceVariableSlots"

	self
		deprecated: 'Use #slotsNeedFullDefinition instead'
		transformWith:
		'`@rec usesSpecialSlot' -> '`@rec slotsNeedFullDefinition'.
	^ self slotsNeedFullDefinition
]
