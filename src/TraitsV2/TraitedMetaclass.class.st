"
All the traited class metaclasses are instances of myself.

I include all the custom behavior to implement traits.
I override a number of methods in Metaclass to implement traits.

Also I have the localMethodDict and the traitComposition of the base class.  
So it is not needed to recompile the methods from TraitedClass. Check #initializeBasicMethods for more details
"
Class {
	#name : #TraitedMetaclass,
	#superclass : #Metaclass,
	#instVars : [
		'localMethods',
		'composition',
		'baseLocalMethods',
		'baseComposition'
	],
	#category : #'TraitsV2-Base'
}

{ #category : #accessing }
TraitedMetaclass class >> traitedClassTrait [
	^ (TaCompositionElement for: TraitedClass)
]

{ #category : #'accessing method dictionary' }
TraitedMetaclass >> addAndClassifySelector: selector withMethod: compiledMethod inProtocol: aCategory [
	
	self localMethodDict at: selector put: compiledMethod.
	
	super
		addAndClassifySelector: selector
		withMethod: compiledMethod
		inProtocol: aCategory.

	TraitChange addSelector: selector on: self.
]

{ #category : #'accessing method dictionary' }
TraitedMetaclass >> addSelector: selector withMethod: compiledMethod [
	self localMethodDict at: selector put: compiledMethod.
	super addSelector: selector withMethod: compiledMethod.
	TraitChange addSelector: selector on: self
]

{ #category : #'accessing method dictionary' }
TraitedMetaclass >> addSelector: selector withRecompiledMethod: compiledMethod [ 

	compiledMethod isFromTrait 
		ifTrue: [ ^ super addSelector: selector withRecompiledMethod: compiledMethod ].

	self localMethodDict at: selector put: compiledMethod.
	super addSelector: selector withRecompiledMethod: compiledMethod.
	TraitChange addSelector: selector on: self
]

{ #category : #querying }
TraitedMetaclass >> allTraits [
	
	^ self traitComposition allTraits
]

{ #category : #accessing }
TraitedMetaclass >> baseComposition [
	^ baseComposition
]

{ #category : #accessing }
TraitedMetaclass >> baseComposition: anObject [
	baseComposition := anObject
]

{ #category : #accessing }
TraitedMetaclass >> baseLocalMethods [
	^ baseLocalMethods
]

{ #category : #accessing }
TraitedMetaclass >> baseLocalMethods: anObject [
	baseLocalMethods := anObject
]

{ #category : #generated }
TraitedMetaclass >> definition [

	"Refer to the comment in ClassDescription|definition."

	self
		deprecated: 'Use #definitionString instead'
		transformWith: '`@rec definition' -> '`@rec definitionString'.
	^ self definitionString
]

{ #category : #fileout }
TraitedMetaclass >> definitionStringFor: aConfiguredPrinter [

	^ aConfiguredPrinter traitedMetaclassDefinitionString 
]

{ #category : #initialization }
TraitedMetaclass >> emptyMethodDictionary [
	^ MethodDictionary new: 64.
]

{ #category : #testing }
TraitedMetaclass >> findOriginClassOf: aMethod [

	"I return the myself or the trait that has the original implementation of a method.
	If the method is an alias, the returned class includes the original aliased method"

	(aMethod hasProperty: #traitSource) 
		ifTrue: [ ^ aMethod traitSource innerClass ]. 

	(self isLocalSelector: aMethod selector)
		ifTrue: [ ^ self ].

	^ (self traitComposition
		traitDefining: aMethod selector
		ifNone: [ self class traitedClassTrait traitDefining: aMethod selector ifNone: [ ^ self ] ]) innerClass
]

{ #category : #testing }
TraitedMetaclass >> findOriginMethodOf: aMethod [

	"I return the original method for a aMethod.
	If this is a local method, the original method is itself.
	If it cames from a trait composition I look for the method in the trait composition.
	First I try with the trait stored in the traitSource. 
	If it is an aliased or conflicting method, the method is look up in the whole trait composition"

	(self isLocalSelector: aMethod selector)
		ifTrue: [ ^ aMethod].

	(aMethod hasProperty: #traitSource)
		ifTrue: [ |newSelector|
			newSelector := self traitComposition originSelectorOf: aMethod selector.
			^ aMethod traitSource compiledMethodAt: newSelector ifAbsent: [aMethod] ].

	^ (self traitComposition
		traitDefining: aMethod selector
		ifNone: [ self class traitedClassTrait traitDefining: aMethod selector ifNone: [ self ] ]) 
		compiledMethodAt: aMethod selector ifAbsent: [ ^ aMethod ]		

]

{ #category : #testing }
TraitedMetaclass >> hasTraitComposition [
	
	^ self traitComposition isEmpty not 
]

{ #category : #'testing method dictionary' }
TraitedMetaclass >> includesLocalSelector: aSymbol [
	^ self isLocalSelector: aSymbol
]

{ #category : #initialization }
TraitedMetaclass >> initialize [
	super initialize.
	localMethods := self emptyMethodDictionary.
	composition := TaEmptyComposition new.
	
	baseComposition := TaEmptyComposition new.
	baseLocalMethods := self emptyMethodDictionary.
]

{ #category : #initialization }
TraitedMetaclass >> initializeBasicMethods [
	| selectors |
	
	"When a traited class is created, the methods from TraitedClass are inserted in the classSide of the new class. 
	So this new class can have traits. The methods are filtered using #isRejectedMethod:"
	
	selectors := self class traitedClassTrait selectors reject: [ :e | self isRejectedMethod: e ].
	selectors do: [ :e | self class traitedClassTrait copyMethod: e into: self replacing: true ]
]

{ #category : #testing }
TraitedMetaclass >> isAliasSelector: aSymbol [
	"Return true if the selector aSymbol is an alias defined
	in my or in another composition somewhere deeper in 
	the tree of traits compositions."

	^ self traitComposition isAliasSelector: aSymbol
]

{ #category : #testing }
TraitedMetaclass >> isLocalAliasSelector: aSymbol [
	"Return true if the selector aSymbol is an alias defined
	in my trait composition."

	^ self traitComposition isLocalAliasSelector: aSymbol
]

{ #category : #testing }
TraitedMetaclass >> isLocalMethodsProtocol: aProtocol [
	"Checks if the given protocol includes any local defined selector"

	aProtocol methodSelectors ifEmpty: [ ^ true ].
	^ aProtocol methodSelectors anySatisfy: [ :each | 
		  self isLocalSelector: each ]
]

{ #category : #testing }
TraitedMetaclass >> isLocalSelector: aSelector [
	
	^ localMethods includesKey: aSelector
]

{ #category : #testing }
TraitedMetaclass >> isRejectedMethod: aSelector [
	"Determine if the method is not to be installed in method dictionary"

	| isFromClass isFromTraitedClass isTheTraitIUseDefinesTheSelector isMySuperclassTraitedClass |
	
	"the selector is one of the local methods"
	(self isLocalSelector: aSelector)
		ifTrue: [ ^ true ].
		
	"If a trait I used define the selector, we do not reject"	
	isTheTraitIUseDefinesTheSelector := self traitComposition traits anySatisfy: [:inTrait | 
		inTrait localMethods anySatisfy: [ :meth | meth selector = aSelector ]].
	isTheTraitIUseDefinesTheSelector ifTrue:[ ^false ].	

	
	isFromClass := Class canUnderstand: aSelector.
	isFromTraitedClass := TraitedClass methodDict includesKey: aSelector.
	isMySuperclassTraitedClass := (superclass isKindOf: TraitedMetaclass) and: [
	superclass isObsolete not].
	
	"It is from Class (we already have them) and they are not overriden in TraitedClass"
	(isFromClass and: [ isFromTraitedClass not ]) ifTrue: [ ^ true ].
	
	"If it is in TraitedClass and it is in my superclass."
	(isFromTraitedClass and: isMySuperclassTraitedClass)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : #testing }
TraitedMetaclass >> isSelectorToKeep: aSelector [
	"I have to keep the local methods and the methods from TraitedClass
	The methods from TraitedClass makes me a class suporting traits, without them I am a normal class"

	^ (self isLocalSelector: aSelector)
		or: [ TraitedClass methodDict includesKey: aSelector ]
]

{ #category : #accessing }
TraitedMetaclass >> localMethodDict [
	^ localMethods
]

{ #category : #accessing }
TraitedMetaclass >> localMethods [
	"returns the methods of classes excluding the ones of the traits that the class uses" 
	 
	^ localMethods values
]

{ #category : #accessing }
TraitedMetaclass >> localSelectors [
	
	^ localMethods keys
]

{ #category : #initialization }
TraitedMetaclass >> rebuildMethodDictionary [
	| selectors removedSelectors modified |
	
		"During the creation of the class or after a change in the traitComposition, the whole method dictionary is calculated.
	If I return true, my users should be updated.
	Check the version in TraitedClass for more details."
	
	modified := false.
	
	self methodDict valuesDo: [ :m | m traitSource ifNil: [ localMethods at: m selector put: m ]].
	
	selectors := self traitComposition selectors reject: [ :e | self isRejectedMethod: e ].
	selectors do: [ :e | modified := modified | (self traitComposition installSelector: e into: self replacing: false) ].
	
	removedSelectors := self methodDict keys reject: [ :aSelector | (selectors includes: aSelector) or: [ self isSelectorToKeep: aSelector ] ].
	modified := modified | (removedSelectors isNotEmpty).
	removedSelectors do: [ :aSelector | self methodDict removeKey: aSelector ].
	removedSelectors do: [ :aSelector | self organization removeElement: aSelector ]. 
	
	^ modified
]

{ #category : #categories }
TraitedMetaclass >> recategorizeSelector: selector from: oldCategory to: newCategory [
	| original |

	"When a method is recategorized I have to classify the method, but also recategorize the aliases pointing to it"
	
	original := self organization categoryOfElement: selector ifAbsent: [ ^ self ].

	"If it is nil is because it is a removal. It will removed when the method is removed."
	newCategory ifNil: [ ^ self ].

	original = oldCategory
		ifTrue: [ self organization classify: selector under: newCategory suppressIfDefault: true ].

	(self traitComposition reverseAlias: selector) do: [ :e | 
		self recategorizeSelector: e from: oldCategory to: newCategory. 
		self notifyOfRecategorizedSelector: e from: oldCategory to: newCategory ].
	
	self organization removeEmptyCategories
]

{ #category : #recompilation }
TraitedMetaclass >> recompile: selector from: oldClass [
	"Compile the method associated with selector in the receiver's method dictionary."

	| method newMethod |
	method := oldClass compiledMethodAt: selector.
	newMethod := self compiler
				source: (oldClass sourceCodeAt: selector);
				class: self;
				failBlock: [^ self];
				compiledMethodTrailer: method trailer;
				compile.   "Assume OK after proceed from SyntaxError"
	selector == newMethod selector ifFalse: [self error: 'selector changed!'].
	
	method properties 
		at: #traitSource 
		ifPresent: [ :aSource | newMethod propertyAt: #traitSource put: aSource].
	
	self addSelector: selector withRecompiledMethod: newMethod.
]

{ #category : #traits }
TraitedMetaclass >> removeFromComposition: aTrait [ 
	self setTraitComposition: (self traitComposition copyWithoutTrait: aTrait asTraitComposition)
]

{ #category : #'accessing method dictionary' }
TraitedMetaclass >> removeSelector: aSelector [

	"When a selector is removed it should be notified to my users.
	Check the class TraitChange for more details"
	super removeSelector: aSelector.
	self localMethodDict removeKey: aSelector ifAbsent: [  ].

	TraitChange removeSelector: aSelector on: self.
]

{ #category : #slots }
TraitedMetaclass >> slots [

	^ super slots reject: [ :e | composition slots includes: e ]
]

{ #category : #accessing }
TraitedMetaclass >> traitComposition [
	^ composition
]

{ #category : #accessing }
TraitedMetaclass >> traitComposition: aComposition [

	aComposition asTraitComposition allTraits do: [ :aMaybeTrait |
		aMaybeTrait isTrait ifFalse: [ 
			self error: 'All the members of the trait composition should be traits' ]].

	composition := aComposition
]

{ #category : #accessing }
TraitedMetaclass >> traitCompositionString [
	^ self traitComposition asString
]

{ #category : #accessing }
TraitedMetaclass >> traitUsers [

	^ #()
]

{ #category : #initialization }
TraitedMetaclass >> traits [
	^ composition traits
]
