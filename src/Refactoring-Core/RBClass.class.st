"
I represent the instance side of a class in a refactoring namespace. 

You can query methods and (instance) var names, poolDictionaries, class category and comment.

I shouldn't be created directly, but always be part of a refactoring namespace.
My  namespace usally knows me and my meta class.
"
Class {
	#name : #RBClass,
	#superclass : #RBAbstractClass,
	#instVars : [
		'classVariableNames',
		'poolDictionaryNames',
		'category',
		'comment',
		'classPool'
	],
	#classVars : [
		'LookupComment'
	],
	#category : #'Refactoring-Core-Model'
}

{ #category : #'instance creation' }
RBClass class >> existingNamed: aSymbol [ 
	^(self named: aSymbol)
		realName: aSymbol;
		yourself
]

{ #category : #'instance creation' }
RBClass class >> existingNamed: aSymbol model: aRBNamespace [ 
	^ (self named: aSymbol)
		model: aRBNamespace;
		realName: aSymbol;
		yourself
]

{ #category : #'class initialization' }
RBClass class >> initialize [
	LookupComment := Object new
]

{ #category : #'instance creation' }
RBClass class >> named: aSymbol [
	^(self new)
		name: aSymbol;
		yourself
]

{ #category : #'variable accessing' }
RBClass >> addClassVariable: aString [ 
	self privateClassVariableNames add: aString asSymbol.
	model addClassVariable: aString to: self.
	self classPool at: aString put: nil
]

{ #category : #'variable accessing' }
RBClass >> addPoolDictionary: aString [ 
	self privatePoolDictionaryNames add: aString asSymbol.
	model addPool: aString to: self
]

{ #category : #accessing }
RBClass >> allClassVariableNames [

	| sprClass |

	sprClass := self superclass.
	^ sprClass
		ifNil: [ self classVariableNames ]
		ifNotNil: [ sprClass allClassVariableNames , self classVariableNames ]
]

{ #category : #accessing }
RBClass >> allPoolDictionaryNames [

	| sprClass |

	sprClass := self superclass.
	^ sprClass
		ifNil: [ self sharedPoolNames ]
		ifNotNil: [ sprClass allPoolDictionaryNames , self sharedPoolNames ]
]

{ #category : #accessing }
RBClass >> category [

	^ category
		ifNil: [ self isDefined
				ifTrue: [ category := self realClass category ]
				ifFalse: [ model environment whichCategoryIncludes: self name ]
			]
		ifNotNil: [ category ]
]

{ #category : #accessing }
RBClass >> category: aSymbol [ 
	category := aSymbol
]

{ #category : #accessing }
RBClass >> classPool [
	^classPool ifNil: [ classPool := Dictionary new ]
]

{ #category : #accessing }
RBClass >> classVariableNames [
	^self privateClassVariableNames copy
]

{ #category : #accessing }
RBClass >> classVariableNames: aCollectionOfStrings [ 
	classVariableNames := (aCollectionOfStrings 
				collect: [:each | self classPool at: each asSymbol put: nil.
					each asSymbol]) asOrderedCollection
]

{ #category : #accessing }
RBClass >> comment [
	^ comment = LookupComment
		ifTrue: [
			comment := self isDefined
				ifTrue: [ self realClass comment ]
				ifFalse: [ nil ] ]
		ifFalse: [ comment ]
]

{ #category : #accessing }
RBClass >> comment: aString [
	model comment: (comment := aString) in: self
]

{ #category : #accessing }
RBClass >> definitionString [
	^ String
		streamContents:
			[ :definitionStream | 
			definitionStream
				nextPutAll: self superclass printString;
				nextPutAll: ' subclass: #';
				nextPutAll: self name;
				nextPutAll:
					'
	instanceVariableNames: '''.
			self instanceVariableNames
				do: [ :each | 
					definitionStream
						nextPutAll: each;
						nextPut: $  ].
			definitionStream
				nextPutAll:
					'''
	classVariableNames: '''.
			self classVariableNames
				do: [ :each | 
					definitionStream
						nextPutAll: each;
						nextPut: $  ].
			definitionStream
				nextPutAll:
					'''
	poolDictionaries: '''.
			self sharedPoolNames
				do: [ :each | 
					definitionStream
						nextPutAll: each;
						nextPut: $  ].
			definitionStream
				nextPutAll:
					'''
	category: #'''.
			definitionStream nextPutAll: self category asString.
			definitionStream nextPut: $' ]
]

{ #category : #testing }
RBClass >> directlyDefinesClassVariable: aString [ 
	^self classVariableNames includes: aString asSymbol
]

{ #category : #testing }
RBClass >> directlyDefinesPoolDictionary: aString [ 
	^self sharedPoolNames includes: aString asSymbol
]

{ #category : #initialization }
RBClass >> initialize [
	super initialize.
	comment := LookupComment
]

{ #category : #accessing }
RBClass >> instanceSide [

	^ self 
]

{ #category : #testing }
RBClass >> isMeta [
	^false
]

{ #category : #testing }
RBClass >> isSharedPool [
	
	^ (self allSuperclasses collect:  [:each | each name]) includes: #SharedPool
]

{ #category : #querying }
RBClass >> methodsUsingClassVariableNamed: aClassVariableName [
 
	^ (self realClass classVariableNamed: aClassVariableName) usingMethods collect: [ :aMethod | 			
			|modelClass|
			modelClass := self model classNamed: aMethod methodClass name.
			modelClass methodFor: aMethod selector
		]
]

{ #category : #accessing }
RBClass >> poolDictionaryNames: aCollectionOfStrings [ 
	poolDictionaryNames := (aCollectionOfStrings collect: [:each | each asSymbol]) asOrderedCollection
]

{ #category : #private }
RBClass >> privateClassVariableNames [
	(self isDefined and: [classVariableNames isNil]) 
		ifTrue: [self classVariableNames: self realClass classVarNames].
	^classVariableNames
]

{ #category : #private }
RBClass >> privatePoolDictionaryNames [
	(self isDefined and: [poolDictionaryNames isNil]) 
		ifTrue: 
			[self poolDictionaryNames: (self realClass sharedPools 
						collect: [:each | self realClass environment keyAtValue: each])].
	^poolDictionaryNames
]

{ #category : #initialization }
RBClass >> realName: aSymbol [ 
	self realClass: (self model environment at: aSymbol)
]

{ #category : #'variable accessing' }
RBClass >> removeClassVariable: aString [ 
	self privateClassVariableNames remove: aString asSymbol.
	model removeClassVariable: aString from: self
]

{ #category : #'variable accessing' }
RBClass >> removePoolDictionary: aString [ 
	self privatePoolDictionaryNames remove: aString asSymbol
]

{ #category : #'variable accessing' }
RBClass >> renameClassVariable: oldName to: newName around: aBlock [ 
	self privateClassVariableNames 
		at: (self privateClassVariableNames indexOf: oldName asSymbol)
		put: newName asSymbol.
	model 
		renameClassVariable: oldName
		to: newName
		in: self
		around: aBlock
]

{ #category : #accessing }
RBClass >> sharedPoolNames [
	^self privatePoolDictionaryNames copy
]

{ #category : #accessing }
RBClass >> sharedPools [
	^ self allPoolDictionaryNames collect: [ :each | Smalltalk globals at: each asSymbol ifAbsent: [ Dictionary new ] ]
]

{ #category : #'accessing - deprecated' }
RBClass >> theNonMetaClass [
	^ self
]
