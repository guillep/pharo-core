"
I am a namespace for refactoring operations.
I collect changes during refactoring and provide an environment for resolving named entities like
classes, method senders or implementors. 

The default environment for a namespace contains all classes in the system, but you can create 
an instance of me with a scoped environment to apply the refactoring operations only on entities in 
that environment.

Resolving named entities includes classes and methods changed or added during refactoring, before
actually applying this changes to the system. For this, I create model classes - RBClass and RBMetaclass - modeling real classes.

The changes that will be applied to the system are collected as refactoring changes (RBRefactoryChange).

Example: 
This creates a new namespace on the default environment (all system classes):
 model := RBNamespace onEnvironment: RBBrowserEnvironment new.

This creates a Refactoring operation for adding a class, with me as the namespace model:
    refactoring := RBAddClassRefactoring
        model: model
        addClass: #SomeClass
        superclass: #Object
        subclasses: {}
        category: #Category.

This will do a ""dry run"", only collect the changes of this refactoring:
    refactoring primitiveExecute.

Now can ask me for this list of changes:
   model changes.
this acutally gives a composite refactory change that holds a list of all single refacoring changes.

Note, some of my methods for querying method senders and implementors don't work well for Trait methods, because we don't have yet modeling classes for Traits and some refactoring operations don't support refactorings on trait methods.

"
Class {
	#name : #RBNamespace,
	#superclass : #RBEntity,
	#instVars : [
		'changes',
		'environment',
		'newClasses',
		'removedClasses',
		'changedClasses',
		'rootClasses',
		'implementorsCache',
		'sendersCache',
		'newPackages',
		'changedPackages',
		'removedPackages'
	],
	#category : #'Refactoring-Core-Model'
}

{ #category : #'instance creation' }
RBNamespace class >> onEnvironment: aBrowserEnvironment [ 
	^self basicNew
		environment: aBrowserEnvironment;
		initialize;
		yourself
]

{ #category : #'private-changes' }
RBNamespace >> addChangeToClass: aRBClass [
	^ changedClasses 
		at: aRBClass name
		put: (Array 
				with: aRBClass instanceSide
				with: aRBClass classSide)
]

{ #category : #'private-changes' }
RBNamespace >> addClassVariable: aString to: aRBClass [ 
	^changes addClassVariable: aString to: aRBClass
]

{ #category : #'private-changes' }
RBNamespace >> addInstanceVariable: aString to: aRBClass [ 
	^changes addInstanceVariable: aString to: aRBClass
]

{ #category : #'private-changes' }
RBNamespace >> addPackageNamed: aSymbol [
	| change pkg |
	change := changes addPackageNamed: aSymbol.
	self flushCaches.
	pkg := self packageNamed: aSymbol.
	self unmarkPackageAsRemoved: aSymbol.
	newPackages at: aSymbol put: pkg.
	^change
]

{ #category : #'private-changes' }
RBNamespace >> addPool: aString to: aRBClass [ 
	^changes addPool: aString to: aRBClass
]

{ #category : #accessing }
RBNamespace >> allClassesDo: aBlock [

	| seen evalBlock |

	seen := Set new.
	evalBlock := [ :each | 
	seen add: each first name.
	aBlock
		value: each first;
		value: each last
	].
	newClasses do: evalBlock.
	changedClasses do: evalBlock.
	environment
		classesDo: [ :each | 
			each isObsolete
				ifFalse: [ | class |

					class := each instanceSide.
					( ( seen includes: class name ) or: [ self hasRemoved: ( self classNameFor: class ) ] )
						ifFalse: [ ( class := self classFor: each )
								ifNotNil: [ seen add: class name.
									aBlock
										value: class;
										value: class classSide
									]
							]
					]
			]
]

{ #category : #accessing }
RBNamespace >> allClassesInPackages: aColl do: aBlock [

	| seen evalBlock |

	seen := Set new.
	evalBlock := [ :each | 
	seen add: each first name.
	aBlock
		value: each first;
		value: each last
	].
	(newClasses select: [ :e | aColl anySatisfy: [ :cat | cat, '*' match: e first category ]]) do: evalBlock.
	(changedClasses select: [ :e | aColl anySatisfy: [ :cat | cat, '*' match: e first category ]]) do: evalBlock.
	self environment
		classesInPackages: aColl do: [ :each | 
			each isObsolete
				ifFalse: [ | class |

					class := each instanceSide.
					( ( seen includes: class name ) or: [ self hasRemoved: ( self classNameFor: class ) ] )
						ifFalse: [ ( class := self classFor: each )
								ifNotNil: [ seen add: class name.
									aBlock
										value: class;
										value: class classSide
									]
							]
					]
			]
]

{ #category : #accessing }
RBNamespace >> allImplementorsOf: aSelector [ 
	^ implementorsCache at: aSelector ifAbsentPut: [ self privateImplementorsOf: aSelector ]
]

{ #category : #accessing }
RBNamespace >> allImplementorsOf: aSelector do: aBlock [
	(self allImplementorsOf: aSelector) do: aBlock
]

{ #category : #accessing }
RBNamespace >> allImplementorsOf: aSelector inPackages: aColl [
	^ implementorsCache at: aSelector ifAbsentPut: [ self privateImplementorsOf: aSelector in: aColl ]
]

{ #category : #accessing }
RBNamespace >> allReferencesTo: aSymbol [
	^ sendersCache at: aSymbol ifAbsentPut: [ self privateReferencesTo: aSymbol ]
]

{ #category : #accessing }
RBNamespace >> allReferencesTo: aSymbol do: aBlock [
	(self allReferencesTo: aSymbol) do: aBlock
]

{ #category : #accessing }
RBNamespace >> allReferencesTo: aSymbol in: classes [
	| classNames |
	classNames := classes collect: [ :cls | cls name ].
	^ (self allReferencesTo: aSymbol) select: [ :ref | classNames includes: ref modelClass name ]
]

{ #category : #accessing }
RBNamespace >> allReferencesTo: aSymbol inPackages: aColl [
	^ sendersCache at: aSymbol ifAbsentPut: [ self privateReferencesTo: aSymbol inPackages: aColl ]
]

{ #category : #accessing }
RBNamespace >> allReferencesTo: aSymbol inPackages: aColl do: aBlock [
	(self allReferencesTo: aSymbol inPackages: aColl) do: aBlock
]

{ #category : #accessing }
RBNamespace >> allReferencesToClass: aRBClass do: aBlock [ 
	self allClassesDo: 
			[:each |
			(each whichSelectorsReferToClass: aRBClass) 
				do: [:sel | aBlock value: (each methodFor: sel)].
			(each classSide whichSelectorsReferToClass: aRBClass) 
				do: [:sel | aBlock value: (each classSide methodFor: sel)]]
]

{ #category : #accessing }
RBNamespace >> allReferencesToClass: aRBClass inPackages: aColl do: aBlock [ 
	self allClassesInPackages: aColl do:
			[:each |
			(each whichSelectorsReferToClass: aRBClass) 
				do: [:sel | aBlock value: (each methodFor: sel)].
			(each classSide whichSelectorsReferToClass: aRBClass) 
				do: [:sel | aBlock value: (each classSide methodFor: sel)]]
]

{ #category : #'private-changes' }
RBNamespace >> changeClass: aRBClass [ 
	changedClasses 
		at: aRBClass name
		put: (Array 
				with: aRBClass instanceSide
				with: aRBClass classSide).
	self flushCaches
]

{ #category : #accessing }
RBNamespace >> changes [
	^changes
]

{ #category : #'accessing-classes' }
RBNamespace >> classFor: aBehavior [

	aBehavior ifNil: [ ^ nil ].
	^ aBehavior isMeta
		ifTrue: [ self metaclassNamed: aBehavior instanceSide name ]
		ifFalse: [ self classNamed: aBehavior instanceSide name ]
]

{ #category : #private }
RBNamespace >> classNameFor: aBehavior [ 
	^ aBehavior instanceSide name
]

{ #category : #'accessing-classes' }
RBNamespace >> classNamed: aSymbol [
	| class classes index |
	aSymbol ifNil: [ ^ nil ].
	(self hasRemoved: aSymbol) ifTrue: [ ^ nil ].
	(newClasses includesKey: aSymbol) ifTrue: [ ^ (newClasses at: aSymbol) first ].
	(changedClasses includesKey: aSymbol) ifTrue: [ ^ (changedClasses at: aSymbol) first ].
	class := environment at: aSymbol ifAbsent: [ nil ].
	(class isBehavior or: [ class isTrait ])
		ifTrue: [ classes := self createNewClassFor: class.
			^ class isMeta
				ifTrue: [ classes last ]
				ifFalse: [ classes first ] ].
	index := aSymbol indexOfSubCollection: ' class' startingAt: 1 ifAbsent: [ ^ nil ].
	class := self classNamed: (aSymbol copyFrom: 1 to: index - 1) asSymbol.
	^ class ifNotNil: [ class classSide ]
]

{ #category : #changes }
RBNamespace >> comment: aString in: aClass [
	^ changes comment: aString in: aClass
]

{ #category : #'private-changes' }
RBNamespace >> compile: aString in: aRBClass classified: aSymbol [ 
	| change |
	change := changes 
				compile: aString
				in: aRBClass
				classified: aSymbol.
	self flushCaches.
	^change
]

{ #category : #'accessing-classes' }
RBNamespace >> createNewClassFor: aBehavior [ 
	| nonMeta meta className rbType rbMetaType |
	className := aBehavior instanceSide name.
	aBehavior isTrait 
		ifTrue: [ 
			rbType := modelFactory rbTrait.
			rbMetaType := modelFactory rbTraitMetaclass.
		] ifFalse: [ 
			rbType := modelFactory rbClass.
			rbMetaType := modelFactory rbMetaclass.
		].
	nonMeta := rbType existingNamed: className model: self.
	meta := rbMetaType existingNamed: className model: self.
	nonMeta category: aBehavior category.
	^changedClasses at: className put: (Array with: nonMeta with: meta)
]

{ #category : #'accessing-classes' }
RBNamespace >> createNewPackageFor: aPackage [
	| package |
	package := modelFactory rbPackage existingNamed: aPackage model: self.
	^changedPackages at: aPackage put: (Array with: package)
]

{ #category : #changes }
RBNamespace >> defineClass: aString [

	| change newClass newClassName |
	change := changes defineClass: aString.
	newClassName := change changeClassName.
	newClass := self classNamed: newClassName.
	newClass
		ifNil: [ | newMetaclass |

			self unmarkAsRemoved: newClassName.
			newClass := modelFactory rbClass named: newClassName.
			newMetaclass := modelFactory rbMetaclass named: newClassName.
			newClass model: self.
			newMetaclass model: self.
			newClasses at: newClassName put: ( Array with: newClass with: newMetaclass )
			].
	newClass superclass: ( self classNamed: change superclassName ).
	newClass superclass
		ifNil: [ self rootClasses add: newClass.
			newClass classSide superclass: ( self classFor: Object class superclass )
			]
		ifNotNil: [ newClass classSide superclass: newClass superclass classSide ].
	newClass instanceVariableNames: change instanceVariableNames.
	newClass classVariableNames: change classVariableNames.
	newClass poolDictionaryNames: change sharedPoolNames.
	newClass category: change category.
	^ change
]

{ #category : #accessing }
RBNamespace >> description [
	^ self changes name
]

{ #category : #accessing }
RBNamespace >> description: aString [
	self changes name: aString
]

{ #category : #accessing }
RBNamespace >> environment [
	^ environment ifNil: [ environment := RBBrowserEnvironment new].
]

{ #category : #accessing }
RBNamespace >> environment: aBrowserEnvironment [ 
	environment := aBrowserEnvironment
]

{ #category : #'private-changes' }
RBNamespace >> flushCaches [
	implementorsCache := IdentityDictionary new.
	sendersCache := IdentityDictionary new
]

{ #category : #private }
RBNamespace >> hasCreatedClassFor: aBehavior [ 
	| className |
	className := self classNameFor: aBehavior.
	^(newClasses includesKey: className) 
		or: [changedClasses includesKey: className]
]

{ #category : #testing }
RBNamespace >> hasPackageRemoved: aSymbol [ 
	^removedPackages includes: aSymbol
]

{ #category : #testing }
RBNamespace >> hasRemoved: aSymbol [ 
	^removedClasses includes: aSymbol
]

{ #category : #testing }
RBNamespace >> includesClassNamed: aSymbol [ 
	^(self classNamed: aSymbol) notNil
]

{ #category : #testing }
RBNamespace >> includesGlobal: aSymbol [ 
	(self hasRemoved: aSymbol) ifTrue: [^false].
	(self includesClassNamed: aSymbol) ifTrue: [^true].
	environment at: aSymbol ifAbsent: [^false].
	^true
]

{ #category : #testing }
RBNamespace >> includesPackageNamed: aSymbol [ 
	^(self packageNamed: aSymbol) notNil
]

{ #category : #initialization }
RBNamespace >> initialize [
	super initialize.
	changes := changeFactory compositeRefactoryChange onSystemDictionary: self environment.
	newClasses := IdentityDictionary new.
	newPackages := IdentityDictionary new.
	changedClasses := IdentityDictionary new.
	changedPackages := IdentityDictionary new.
	removedClasses := Set new.
	removedPackages := Set new.
	implementorsCache := IdentityDictionary new.
	sendersCache := IdentityDictionary new
]

{ #category : #private }
RBNamespace >> markAsRemoved: aClassName [

	removedClasses
		add: aClassName;
		add: aClassName, ' class'
]

{ #category : #private }
RBNamespace >> markPackageAsRemoved: aPackageName [

	removedPackages
		add: aPackageName
]

{ #category : #'accessing-classes' }
RBNamespace >> metaclassNamed: aSymbol [

	| class |

	aSymbol ifNil: [ ^ nil ].
	( self hasRemoved: aSymbol )
		ifTrue: [ ^ nil ].
	( newClasses includesKey: aSymbol )
		ifTrue: [ ^ ( newClasses at: aSymbol ) last ].
	( changedClasses includesKey: aSymbol )
		ifTrue: [ ^ ( changedClasses at: aSymbol ) last ].

	class := environment at: aSymbol ifAbsent: [ nil ].
	( class isBehavior or: [ class isTrait ] )
		ifTrue: [ ^ ( self createNewClassFor: class ) last ].
	^ nil
]

{ #category : #accessing }
RBNamespace >> name [
	^changes name
]

{ #category : #accessing }
RBNamespace >> name: aString [
	^changes name: aString
]

{ #category : #'accessing-classes' }
RBNamespace >> packageNamed: aSymbol [
	aSymbol ifNil: [ ^ nil ].
	(self hasPackageRemoved: aSymbol) ifTrue: [ ^ nil ].
	(newPackages includesKey: aSymbol) ifTrue: [ ^ newPackages at: aSymbol ].
	(changedPackages includesKey: aSymbol) ifTrue: [ ^ (changedPackages at: aSymbol) first ].
	^ (self createNewPackageFor: aSymbol) first
]

{ #category : #'private-changes' }
RBNamespace >> performChange: aCompositeRefactoryChange around: aBlock [ 
	| oldChanges |
	changes addChange: aCompositeRefactoryChange.
	oldChanges := changes.
	changes := aCompositeRefactoryChange.
	aBlock ensure: [changes := oldChanges].
	^aCompositeRefactoryChange
]

{ #category : #private }
RBNamespace >> privateImplementorsOf: aSelector [ 
	| classes |
	classes := Set new.
	self allClassesDo: [ :class |
		(class directlyDefinesLocalMethod: aSelector)
			ifTrue: [ classes add: class ].
		(class classSide directlyDefinesLocalMethod: aSelector)
			ifTrue: [ classes add: class classSide ] ].
	^ classes
]

{ #category : #private }
RBNamespace >> privateImplementorsOf: aSelector in: packages [
	| classes |
	classes := Set new.
	self allClassesInPackages: packages do: [ :class |
		(class directlyDefinesLocalMethod: aSelector)
			ifTrue: [ classes add: class ].
		(class classSide directlyDefinesLocalMethod: aSelector)
			ifTrue: [ classes add: class classSide ] ].
	^ classes
]

{ #category : #private }
RBNamespace >> privateReferencesTo: aSelector [ 
	| methods |
	methods := OrderedCollection new.
	self allClassesDo: [ :class |
		(class whichSelectorsReferToSymbol: aSelector)
			do: [ :selector |
				methods add: (class methodFor: selector) ] ].
	^ methods
]

{ #category : #private }
RBNamespace >> privateReferencesTo: aSelector in: classes [
	| methods |
	methods := OrderedCollection new.
	classes do: [ :class |
		(class whichSelectorsReferToSymbol: aSelector)
			do: [ :selector |
				methods add: (class methodFor: selector) ] ].
	^ methods
]

{ #category : #private }
RBNamespace >> privateReferencesTo: aSelector inPackages: aColl [
	| methods |
	methods := OrderedCollection new.
	self allClassesInPackages: aColl do: [ :class |
		(class whichSelectorsReferToSymbol: aSelector)
			do: [ :selector |
				methods add: (class methodFor: selector) ] ].
	^ methods
]

{ #category : #private }
RBNamespace >> privateRootClasses [
	| classes |
	classes := OrderedCollection new.
	Class rootsOfTheWorld do: [ :each | 
		| class |
		class := self classFor: each.
		(class notNil and: [ class superclass isNil ]) 
			ifTrue: [ classes add: class ] ].
	^ classes
]

{ #category : #changes }
RBNamespace >> removeClass: aRBClass [ 
	self removeClassNamed: aRBClass name
]

{ #category : #'private-changes' }
RBNamespace >> removeClassKeepingSubclassesNamed: aSymbol [ 
	removedClasses
		add: aSymbol;
		add: aSymbol , ' class'.
	newClasses removeKey: aSymbol ifAbsent: [].
	changedClasses removeKey: aSymbol ifAbsent: [].
	self flushCaches.
	^changes removeClassNamed: aSymbol
]

{ #category : #changes }
RBNamespace >> removeClassNamed: aSymbol [ 
	(self classNamed: aSymbol) subclasses 
		do: [:each | self removeClassNamed: each name].
	removedClasses
		add: aSymbol;
		add: aSymbol , ' class'.
	newClasses removeKey: aSymbol ifAbsent: [].
	changedClasses removeKey: aSymbol ifAbsent: [].
	self flushCaches.
	^changes removeClassNamed: aSymbol
]

{ #category : #'private-changes' }
RBNamespace >> removeClassVariable: aString from: aRBClass [ 
	^changes removeClassVariable: aString from: aRBClass
]

{ #category : #'private-changes' }
RBNamespace >> removeInstanceVariable: aString from: aRBClass [ 
	^changes removeInstanceVariable: aString from: aRBClass
]

{ #category : #'private-changes' }
RBNamespace >> removeMethod: aSelector from: aRBClass [ 
	self flushCaches.
	^changes removeMethod: aSelector from: aRBClass
]

{ #category : #'private-changes' }
RBNamespace >> removePackageNamed: aString [

	self flushCaches.
	^ changes removePackageNamed: aString.
]

{ #category : #changes }
RBNamespace >> renameClass: aRBClass to: aSymbol around: aBlock [
	| change value dict |
	change := changeFactory renameClass: aRBClass to: aSymbol.
	self performChange: change around: aBlock.
	self flushCaches.
	dict := (newClasses includesKey: aRBClass name)
		ifTrue: [ newClasses ]
		ifFalse: [ changedClasses ].
	self markAsRemoved: aRBClass name.
	self unmarkAsRemoved: aSymbol.
	value := dict at: aRBClass name.
	dict removeKey: aRBClass name.
	dict at: aSymbol put: value.
	value first name: aSymbol.
	value last name: aSymbol.
	value first subclasses do: [ :each | each superclass: value first ].
	value last subclasses do: [ :each | each superclass: value last ].
	^ change
]

{ #category : #'private-changes' }
RBNamespace >> renameClassVariable: oldName to: newName in: aRBClass around: aBlock [ 
	^self performChange: (changeFactory  
				renameClassVariable: oldName
				to: newName
				in: aRBClass)
		around: aBlock
]

{ #category : #'private-changes' }
RBNamespace >> renameInstanceVariable: oldName to: newName in: aRBClass around: aBlock [ 
	^self performChange: (changeFactory 
				renameInstanceVariable: oldName
				to: newName
				in: aRBClass)
		around: aBlock
]

{ #category : #changes }
RBNamespace >> renamePackage: aRBPackage to: aSymbol [
	| change value dict |
	change := changeFactory renamePackage: aRBPackage to: aSymbol.
	self performChange: change around: [].
	self flushCaches.
	dict := changedPackages.
	self markPackageAsRemoved: aRBPackage name.
	self unmarkPackageAsRemoved: aSymbol.
	value := dict at: aRBPackage name.
	dict removeKey: aRBPackage name.
	dict at: aSymbol put: value.
	value first name: aSymbol.
	^ change
]

{ #category : #changes }
RBNamespace >> reparentClasses: aRBClassCollection to: newClass [ 
	aRBClassCollection do: 
			[:aClass | 
			self defineClass: (self replaceClassNameIn: aClass definitionString
						to: newClass name)]
]

{ #category : #'private-changes' }
RBNamespace >> replaceClassNameIn: definitionString to: aSymbol [ 
	| parseTree |
	parseTree := self parserClass parseExpression: definitionString.
	parseTree receiver: (RBVariableNode named: aSymbol).
	^parseTree formattedCode
]

{ #category : #accessing }
RBNamespace >> rootClasses [
	^ rootClasses ifNil: [ rootClasses := self privateRootClasses]
]

{ #category : #private }
RBNamespace >> unmarkAsRemoved: newClassName [
	removedClasses
		remove: newClassName ifAbsent: [  ];
		remove: newClassName , ' class' ifAbsent: [  ]
]

{ #category : #private }
RBNamespace >> unmarkPackageAsRemoved: newPackageName [
	removedPackages
		remove: newPackageName ifAbsent: [  ]
]

{ #category : #'accessing-classes' }
RBNamespace >> whichCategoryIncludes: aSymbol [
	^self environment whichCategoryIncludes: aSymbol
]
