"
I am the base class of RBClass and RBMetaclass implementing the common behavior for creating and accessing class and metaclass elements in a refactoring namespace. 

My subclass instances are created in a refactoring namespace when querying the environment for existing 
classes (or metaclasses) and when creating or changing classes during refactoring operations.

RBClass and RBMetaclass are used to model existing, changed or newly added classes before actually applying the refactoring change to the system. 
You can query the class name,  defined methods and  variables. 
They provide a similar interface like the real classes, but only the part that is necessary  for the 
refactoring framework.

They shouldn't be directly used and always be a part of a refacotoring namespace - the model.

Likewise this classes, my methods aren't real methods but models (RBMethod) that representing a real methods.

Changes for my methods during refactoring are stored in a list of
newMethods and removedMethods.
Like a real class I referre to my superclass and subclass, which again are actually RBClasses.

"
Class {
	#name : #RBAbstractClass,
	#superclass : #RBEntity,
	#instVars : [
		'name',
		'newMethods',
		'instanceVariableNames',
		'model',
		'superclass',
		'subclasses',
		'removedMethods',
		'realClass'
	],
	#classVars : [
		'LookupSuperclass'
	],
	#category : #'Refactoring-Core-Model'
}

{ #category : #accessing }
RBAbstractClass class >> existingNamed: aString [
	^ self subclassResponsibility
]

{ #category : #'class initialization' }
RBAbstractClass class >> initialize [
	LookupSuperclass := Object new
]

{ #category : #accessing }
RBAbstractClass class >> named: aString [
	^ self subclassResponsibility
]

{ #category : #comparing }
RBAbstractClass >> = aRBClass [ 
	^self class = aRBClass class 
		and: [self name = aRBClass name and: [self model = aRBClass model]]
]

{ #category : #'variable accessing' }
RBAbstractClass >> addInstanceVariable: aString [ 
	self privateInstanceVariableNames add: aString.
	model addInstanceVariable: aString to: self
]

{ #category : #'method accessing' }
RBAbstractClass >> addMethod: aRBMethod [ 
	self newMethods at: aRBMethod selector put: aRBMethod.
	removedMethods notNil 
		ifTrue: [removedMethods remove: aRBMethod selector ifAbsent: []]
]

{ #category : #private }
RBAbstractClass >> addSubclass: aRBClass [ 
	self subclasses add: aRBClass
]

{ #category : #accessing }
RBAbstractClass >> allClassVariableNames [
	^self subclassResponsibility
]

{ #category : #accessing }
RBAbstractClass >> allInstanceVariableNames [

	| sprClass |

	sprClass := self superclass.
	^ sprClass
		ifNil: [ self instanceVariableNames ]
		ifNotNil: [ sprClass allInstanceVariableNames , self instanceVariableNames ]
]

{ #category : #accessing }
RBAbstractClass >> allPoolDictionaryNames [
	^self subclassResponsibility
]

{ #category : #'method accessing' }
RBAbstractClass >> allSelectors [
	| class selectors |
	class := self.
	selectors := Set new.
	[class notNil] whileTrue: 
			[selectors addAll: class selectors.
			class := class superclass].
	^selectors
]

{ #category : #accessing }
RBAbstractClass >> allSubclasses [
	| allSubclasses index |
	index := 1.
	allSubclasses := OrderedCollection withAll: self subclasses.
	[index <= allSubclasses size] whileTrue: 
			[allSubclasses addAll: (allSubclasses at: index) subclasses.
			index := index + 1].
	^allSubclasses
]

{ #category : #enumerating }
RBAbstractClass >> allSubclassesDo: aBlock [ 
	"Evaluate the argument, aBlock, for each of the receiver's subclasses."

	self subclassesDo: 
		[:cl | 
		aBlock value: cl.
		cl allSubclassesDo: aBlock]
]

{ #category : #accessing }
RBAbstractClass >> allSuperclasses [
	| supers sprClass |
	supers := OrderedCollection new.
	sprClass := self superclass.
	[sprClass notNil] whileTrue: 
			[supers add: sprClass.
			sprClass := sprClass superclass].
	^supers
]

{ #category : #'method accessing' }
RBAbstractClass >> bindingOf: aString [ 
	^self realClass classPool associationAt: aString asSymbol
		ifAbsent: [self realClass classPool associationAt: aString asString ifAbsent: [nil]]
]

{ #category : #testing }
RBAbstractClass >> canUnderstand: aSelector [ 
	^self definesMethod: aSelector
]

{ #category : #printing }
RBAbstractClass >> canonicalArgumentName [
	| prefix |
	prefix := self name first isVowel
		ifTrue: [ 'an' ]
		ifFalse: [ 'a' ].
	^ prefix, self name
]

{ #category : #accessing }
RBAbstractClass >> classBinding [
	^ Smalltalk globals associationAt: self name
]

{ #category : #accessing }
RBAbstractClass >> classSide [
	"Return the metaclass of the couple class/metaclass. Useful to avoid explicit test."
	
	^ model metaclassNamed: self name
]

{ #category : #'method accessing' }
RBAbstractClass >> compile: aString [ 
	^ self compile: aString withAttributesFrom: (self methodFor: (self parserClass parseMethodPattern: aString))
]

{ #category : #'method accessing' }
RBAbstractClass >> compile: aString classified: aSymbolCollection [ 
	| change method |
	change := model 
				compile: aString
				in: self
				classified: aSymbolCollection.
	method := modelFactory rbMethod 
				for: self
				source: aString
				selector: change selector.
	self addMethod: method.
	^ change
]

{ #category : #'method accessing' }
RBAbstractClass >> compile: aString withAttributesFrom: aRBMethod [ 
	| change method |
	change := model 
		compile: aString
		in: self
		classified: aRBMethod protocols.
	method := modelFactory rbMethod  
		for: self
		source: aString
		selector: change selector.
	self addMethod: method.
	^ change
]

{ #category : #'method accessing' }
RBAbstractClass >> compileTree: aRBMethodNode [ 
	^ (self methodFor: aRBMethodNode selector) compileTree: aRBMethodNode
]

{ #category : #testing }
RBAbstractClass >> definesClassVariable: aSymbol [ 
	self realClass isTrait ifTrue: [^false].
	(self directlyDefinesClassVariable: aSymbol) ifTrue: [^true].
	^self superclass notNil 
		and: [self superclass definesClassVariable: aSymbol]
]

{ #category : #testing }
RBAbstractClass >> definesInstanceVariable: aString [ 
	(self directlyDefinesInstanceVariable: aString) ifTrue: [^true].
	^self superclass notNil 
		and: [self superclass definesInstanceVariable: aString]
]

{ #category : #testing }
RBAbstractClass >> definesMethod: aSelector [ 
	(self directlyDefinesMethod: aSelector) ifTrue: [^true].
	^self superclass notNil and: [self superclass definesMethod: aSelector]
]

{ #category : #testing }
RBAbstractClass >> definesPoolDictionary: aSymbol [ 
	(self directlyDefinesPoolDictionary: aSymbol) ifTrue: [^true].
	^ self superclass notNil 
				and: [self superclass definesPoolDictionary: aSymbol]
]

{ #category : #testing }
RBAbstractClass >> definesVariable: aVariableName [ 
	^(self definesClassVariable: aVariableName) 
		or: [self definesInstanceVariable: aVariableName]
]

{ #category : #testing }
RBAbstractClass >> directlyDefinesClassVariable: aString [ 
	self subclassResponsibility
]

{ #category : #testing }
RBAbstractClass >> directlyDefinesInstanceVariable: aString [ 
	^self instanceVariableNames includes: aString
]

{ #category : #testing }
RBAbstractClass >> directlyDefinesLocalMethod: aSelector [ 
	self isDefined 
		ifTrue: 
			[(self hasRemoved: aSelector) ifTrue: [^false].
			(self realClass includesLocalSelector: aSelector) ifTrue: [^true]].
	^newMethods notNil and: [newMethods includesKey: aSelector]
]

{ #category : #testing }
RBAbstractClass >> directlyDefinesMethod: aSelector [ 
	self isDefined 
		ifTrue: 
			[(self hasRemoved: aSelector) ifTrue: [^false].
			(self realClass includesSelector: aSelector) ifTrue: [^true]].
	^newMethods notNil and: [newMethods includesKey: aSelector]
]

{ #category : #testing }
RBAbstractClass >> directlyDefinesPoolDictionary: aString [ 
	self subclassResponsibility
]

{ #category : #testing }
RBAbstractClass >> directlyDefinesVariable: aVariableName [ 
	^(self directlyDefinesClassVariable: aVariableName) 
		or: [self directlyDefinesInstanceVariable: aVariableName]
]

{ #category : #'method accessing' }
RBAbstractClass >> existingMethodsThatReferTo: aSymbol [ 
	| existingMethods |
	existingMethods := self realClass thoroughWhichSelectorsReferTo: aSymbol.
	(newMethods isNil and: [ removedMethods isNil ])
		ifTrue: [ ^ existingMethods ].
	^ existingMethods 
		reject: [ :each | (self hasRemoved: each) or: [ self newMethods includesKey: each ] ]
]

{ #category : #'method accessing' }
RBAbstractClass >> existingMethodsThatReferToClassVariable: aString [
	| binding existingMethods |
	binding := (self bindingOf: aString)
		ifNil: [ ^ #() ].
	existingMethods := self realClass
		whichSelectorsReferTo: binding.
	(newMethods isNil and: [ removedMethods isNil ])
		ifTrue: [ ^ existingMethods ].
	^ existingMethods
		reject: [ :each | (self hasRemoved: each) or: [ self newMethods includesKey: each ] ]
]

{ #category : #'method accessing' }
RBAbstractClass >> existingMethodsThatReferToInstanceVariable: aString [
	| existingMethods |
	existingMethods := self realClass 
		whichSelectorsAccess: aString.
	(newMethods isNil and: [ removedMethods isNil ])
		ifTrue: [ ^ existingMethods ].
	^ existingMethods 
		reject: [ :each | (self hasRemoved: each) or: [ self newMethods includesKey: each ] ]
]

{ #category : #testing }
RBAbstractClass >> hasRemoved: aSelector [ 
	^removedMethods notNil and: [removedMethods includes: aSelector]
]

{ #category : #comparing }
RBAbstractClass >> hash [
	^self name hash bitXor: self class hash
]

{ #category : #testing }
RBAbstractClass >> hierarchyDefinesClassVariable: aString [
	(self definesClassVariable: aString)
		ifTrue: [ ^ true ].
	^ self allSubclasses
		anySatisfy: [ :each | each directlyDefinesClassVariable: aString ]
]

{ #category : #testing }
RBAbstractClass >> hierarchyDefinesInstanceVariable: aString [
	(self definesInstanceVariable: aString)
		ifTrue: [ ^ true ].
	^ self allSubclasses
		anySatisfy: [ :each | each directlyDefinesInstanceVariable: aString ]
]

{ #category : #testing }
RBAbstractClass >> hierarchyDefinesMethod: aSelector [ 
	(self definesMethod: aSelector) ifTrue: [^true].
	^self subclassRedefines: aSelector
]

{ #category : #testing }
RBAbstractClass >> hierarchyDefinesPoolDictionary: aString [
	(self definesPoolDictionary: aString)
		ifTrue: [ ^ true ].
	^ self allSubclasses
		anySatisfy: [ :each | each directlyDefinesPoolDictionary: aString ]
]

{ #category : #testing }
RBAbstractClass >> hierarchyDefinesVariable: aString [
	(self definesVariable: aString)
		ifTrue: [ ^ true ].
	^ self allSubclasses
		anySatisfy: [ :each | each directlyDefinesVariable: aString ]
]

{ #category : #testing }
RBAbstractClass >> includesClass: aRBClass [ 
	| currentClass |
	currentClass := self.
	[currentClass notNil and: [currentClass ~= aRBClass]] 
		whileTrue: [currentClass := currentClass superclass].
	^currentClass = aRBClass
]

{ #category : #initialization }
RBAbstractClass >> initialize [
	super initialize.
	name := #'Unknown Class'
]

{ #category : #accessing }
RBAbstractClass >> instanceSide [
	"Return the class of the couple class/metaclass. Useful to avoid explicit test."

	^ model classNamed: self name
]

{ #category : #accessing }
RBAbstractClass >> instanceVariableNames [
	^self privateInstanceVariableNames copy
]

{ #category : #accessing }
RBAbstractClass >> instanceVariableNames: aCollectionOfStrings [ 
	instanceVariableNames := aCollectionOfStrings asOrderedCollection
]

{ #category : #testing }
RBAbstractClass >> isAbstract [
	(self whichSelectorsReferToSymbol: #subclassResponsibility) ifNotEmpty: [^true].
	model allReferencesToClass: self do: [:each | ^false].
	^true
]

{ #category : #testing }
RBAbstractClass >> isDefined [
	^self realClass notNil
]

{ #category : #testing }
RBAbstractClass >> isMeta [
	self subclassResponsibility
]

{ #category : #testing }
RBAbstractClass >> isTrait [
	^ false
]

{ #category : #'method accessing' }
RBAbstractClass >> methodFor: aSelector [
	^ self newMethods
		at: aSelector
		ifAbsent: [ | compiledMethod class |
			(self hasRemoved: aSelector) ifTrue: [ ^ nil ].
			class := self realClass.
			class ifNil: [ ^ nil ].
			compiledMethod := class compiledMethodAt: aSelector ifAbsent: [ nil ].
			compiledMethod ifNotNil: [ 
				compiledMethod isFromTrait 
					ifTrue: [ (model classNamed: compiledMethod origin name) methodFor: aSelector ]
					ifFalse: [modelFactory rbMethod for: self fromMethod: compiledMethod andSelector: aSelector ]] ]
]

{ #category : #accessing }
RBAbstractClass >> model [
	^model
]

{ #category : #initialization }
RBAbstractClass >> model: aRBSmalltalk [
	model := aRBSmalltalk
]

{ #category : #accessing }
RBAbstractClass >> name [
	^name
]

{ #category : #accessing }
RBAbstractClass >> name: aSymbol [ 
	name := aSymbol
]

{ #category : #accessing }
RBAbstractClass >> newMethods [

	^ newMethods ifNil: [ newMethods := IdentityDictionary new ] ifNotNil: [ newMethods ]
]

{ #category : #'method accessing' }
RBAbstractClass >> parseTreeFor: aSelector [

	| class |

	class := self whoDefinesMethod: aSelector.
	class ifNil: [ ^ nil ].
	^ ( class methodFor: aSelector ) parseTree
]

{ #category : #printing }
RBAbstractClass >> printOn: aStream [ 
	aStream nextPutAll: self name
]

{ #category : #private }
RBAbstractClass >> privateInstanceVariableNames [

	instanceVariableNames
		ifNil: [ self isDefined
				ifTrue: [ self instanceVariableNames: self realClass instVarNames ]
				ifFalse: [ instanceVariableNames := OrderedCollection new ]
			].
	^ instanceVariableNames
]

{ #category : #'method accessing' }
RBAbstractClass >> protocolsFor: aSelector [

	| change |

	change := self isMeta
		ifTrue: [ model changes changeForMetaclass: name selector: aSelector ]
		ifFalse: [ model changes changeForClass: name selector: aSelector ].
	^ change
		ifNil: [ self isDefined
				ifTrue: [ Array with: ( RBBrowserEnvironment new whichProtocolIncludes: aSelector in: self realClass ) ]
				ifFalse: [ #(#accessing) ]
			]
		ifNotNil: [ change protocols ]
]

{ #category : #accessing }
RBAbstractClass >> realClass [
	^realClass
]

{ #category : #accessing }
RBAbstractClass >> realClass: aClass [

	realClass := aClass.
	superclass ifNil: [ superclass := LookupSuperclass ]
]

{ #category : #accessing }
RBAbstractClass >> realName: arg1 [ 
	^ self subclassResponsibility
]

{ #category : #'variable accessing' }
RBAbstractClass >> removeInstanceVariable: aString [ 
	self privateInstanceVariableNames remove: aString.
	model removeInstanceVariable: aString from: self
]

{ #category : #'method accessing' }
RBAbstractClass >> removeMethod: aSelector [ 
	self newMethods removeKey: aSelector ifAbsent: [].
	model removeMethod: aSelector from: self.
	self removedMethods add: aSelector
]

{ #category : #accessing }
RBAbstractClass >> removeSubclass: aRBClass [ 
	self subclasses remove: aRBClass ifAbsent: []
]

{ #category : #accessing }
RBAbstractClass >> removedMethods [

	^ removedMethods ifNil: [ removedMethods := Set new ] ifNotNil: [ removedMethods ]
]

{ #category : #'variable accessing' }
RBAbstractClass >> renameInstanceVariable: oldName to: newName around: aBlock [ 
	self privateInstanceVariableNames 
		at: (self privateInstanceVariableNames indexOf: oldName asString)
		put: newName asString.
	model 
		renameInstanceVariable: oldName
		to: newName
		in: self
		around: aBlock
]

{ #category : #'method accessing' }
RBAbstractClass >> selectors [
	| selectors |
	selectors := Set new.
	selectors addAll: self newMethods keys.
	self isDefined 
		ifTrue: 
			[selectors addAll: self realClass selectors.
			removedMethods ifNotNil: [removedMethods do: [:each | selectors remove: each ifAbsent: []]]].
	^selectors
]

{ #category : #accessing }
RBAbstractClass >> soleInstance [
	^ self instanceSide
]

{ #category : #'method accessing' }
RBAbstractClass >> sourceCodeFor: aSelector [

	| class |

	class := self whoDefinesMethod: aSelector.
	class ifNil: [ ^ nil ].
	^ ( class methodFor: aSelector ) source
]

{ #category : #printing }
RBAbstractClass >> storeOn: aStream [ 
	aStream nextPutAll: self name
]

{ #category : #testing }
RBAbstractClass >> subclassRedefines: aSelector [
	"Return true, if one of your subclasses redefines the method with name, aMethod"

	^ self allSubclasses anySatisfy: [ :each | each directlyDefinesMethod: aSelector ]
]

{ #category : #accessing }
RBAbstractClass >> subclasses [

	^ subclasses
		ifNil: [ subclasses := self isDefined
				ifTrue: [ ( ( self realClass subclasses collect: [ :each | model classFor: each ] )
						reject: [ :each | each isNil ] ) asOrderedCollection
					]
				ifFalse: [ OrderedCollection new ]
			]
		ifNotNil: [ subclasses ]
]

{ #category : #enumerating }
RBAbstractClass >> subclassesDo: aBlock [ 
	self subclasses do: aBlock
]

{ #category : #accessing }
RBAbstractClass >> superclass [
	^superclass == LookupSuperclass 
		ifTrue: [model classFor: self realClass superclass]
		ifFalse: [superclass]
]

{ #category : #private }
RBAbstractClass >> superclass: aRBClass [ 
	self superclass ifNotNil: [self superclass removeSubclass: self].
	superclass := aRBClass.
	superclass ifNotNil: [superclass addSubclass: self].
]

{ #category : #'accessing - deprecated' }
RBAbstractClass >> theMetaClass [
	^ model metaclassNamed: self name
]

{ #category : #'accessing - deprecated' }
RBAbstractClass >> theNonMetaClass [
	^ model classNamed: self name
]

{ #category : #'variable accessing' }
RBAbstractClass >> typeOfClassVariable: aSymbol [ 
	^model classNamed: #Object
]

{ #category : #'method accessing' }
RBAbstractClass >> whichSelectorsReferToClass: aRBClass [

	| selectors |

	selectors := Set new.
	newMethods
		ifNotNil: [ newMethods
				do: [ :each | 
					( each refersToClassNamed: aRBClass name )
						ifTrue: [ selectors add: each selector ]
					]
			].
	( self isDefined and: [ aRBClass isDefined ] )
		ifTrue: [ selectors addAll: ( self existingMethodsThatReferTo: aRBClass classBinding ).
			selectors addAll: ( self existingMethodsThatReferTo: aRBClass name )
			].
	^ selectors
]

{ #category : #'method accessing' }
RBAbstractClass >> whichSelectorsReferToClassVariable: aString [

	| selectors |

	selectors := Set new.
	newMethods
		ifNotNil: [ newMethods
				do: [ :each | 
					( each refersToVariable: aString )
						ifTrue: [ selectors add: each selector ]
					]
			].
	self isDefined
		ifTrue: [ selectors addAll: ( self existingMethodsThatReferToClassVariable: aString ) ].
	^ selectors
]

{ #category : #'method accessing' }
RBAbstractClass >> whichSelectorsReferToInstanceVariable: aString [

	| selectors |
	selectors := Set new.
	newMethods
		ifNotNil: [ newMethods
				do: [ :each | 
					( each refersToVariable: aString )
						ifTrue: [ selectors add: each selector ]
					]
			].
	self isDefined
		ifTrue: [ selectors addAll: ( self existingMethodsThatReferToInstanceVariable: aString ) ].
	^ selectors
]

{ #category : #'method accessing' }
RBAbstractClass >> whichSelectorsReferToSymbol: aSymbol [

	| selectors |

	selectors := Set new.
	newMethods
		ifNotNil: [ newMethods
				do: [ :each | 
					( each refersToSymbol: aSymbol )
						ifTrue: [ selectors add: each selector ]
					]
			].
	self isDefined
		ifTrue: [ selectors addAll: ( self existingMethodsThatReferTo: aSymbol ) ].
	^ selectors
]

{ #category : #'variable accessing' }
RBAbstractClass >> whoDefinesClassVariable: aString [
	| sprClass |
	(self directlyDefinesClassVariable: aString) ifTrue: [ ^ self ].
	sprClass := self superclass.
	^ sprClass ifNotNil: [ sprClass whoDefinesClassVariable: aString ]
]

{ #category : #'variable accessing' }
RBAbstractClass >> whoDefinesInstanceVariable: aString [
	| sprClass |
	(self directlyDefinesInstanceVariable: aString) ifTrue: [ ^ self ].
	sprClass := self superclass.
	^ sprClass ifNotNil: [ sprClass whoDefinesInstanceVariable: aString ]
]

{ #category : #'method accessing' }
RBAbstractClass >> whoDefinesMethod: aSelector [
	| sprClass |
	(self directlyDefinesMethod: aSelector) ifTrue: [ ^ self ].
	sprClass := self superclass.
	^ sprClass ifNotNil: [ sprClass whoDefinesMethod: aSelector ]
]

{ #category : #accessing }
RBAbstractClass >> withAllSubclasses [
	^ self allSubclasses
		add: self;
		yourself
]

{ #category : #accessing }
RBAbstractClass >> withAllSuperclasses [
	^ self allSuperclasses
		add: self;
		yourself
]
