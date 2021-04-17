"
I'm an adaptation of RBAbstractClass to Refactoring2. 

"
Class {
	#name : #RBAbstractClass2,
	#superclass : #RBAbstractClass,
	#category : #'Refactoring2-Core-Model'
}

{ #category : #'instance creation' }
RBAbstractClass2 class >> existingNamed: aSymbol [

	^ (self named: aSymbol)
		realName: aSymbol;
		yourself
]

{ #category : #'instance creation' }
RBAbstractClass2 class >> named: aSymbol [

	^ (self new)
		name: aSymbol;
		yourself
]

{ #category : #'method accessing' }
RBAbstractClass2 >> allMethods [

	^ self allSelectors
		collect: [ :selector | self methodFor: selector ]
		thenSelect: #isNotNil
]

{ #category : #accessing }
RBAbstractClass2 >> allSuperclassesUntil: aClass [

	| supers sprClass |
	supers := OrderedCollection new.
	sprClass := self superclass.
	[sprClass notNil and: [sprClass name ~= aClass name]] whileTrue: 
			[supers add: sprClass.
			sprClass := sprClass superclass].
	^supers
]

{ #category : #querying }
RBAbstractClass2 >> checkSelector: aSelector using: aMatcher [ 

	| parseTree |
	parseTree := self parseTreeFor: aSelector.
	parseTree ifNotNil: [aMatcher executeTree: parseTree].
	^ aMatcher answer
]

{ #category : #transforming }
RBAbstractClass2 >> convertMethod: selector using: searchReplacer [

	"Convert the parse tree for selector using the searchReplacer. If a
	change is made then compile it into the changeBuilder."

	| parseTree |

	parseTree := self parseTreeFor: selector.
	parseTree ifNil: [ ^ self ].
	( searchReplacer executeTree: parseTree )
		ifTrue: [ self compileTree: searchReplacer tree ]
]

{ #category : #querying }
RBAbstractClass2 >> getterMethodFor: aVariableName [
	| matcher candidateGetters |
	matcher := self parseTreeSearcherClass getterMethod: aVariableName.
	candidateGetters := (self definesInstanceVariable: aVariableName)
		ifTrue: [ self whichSelectorsReferToInstanceVariable: aVariableName ]
		ifFalse: [ self whichSelectorsReferToClassVariable: aVariableName ].
	candidateGetters := candidateGetters
		select: [ :each | each numArgs == 0 ].
	^ candidateGetters
		detect: [ :each | 
			(self checkSelector: each using: matcher) notNil
				and: [ (self subclassRedefines: each) not ] ]
		ifNone: [ nil ]
]

{ #category : #querying }
RBAbstractClass2 >> parseTreeSearcherClass [
	^ RBParseTreeSearcher
]

{ #category : #accessing }
RBAbstractClass2 >> protocols [

	^ (self allMethods
		flatCollect: [ :each | self protocolsFor: each selector ])
		asOrderedCollection
]

{ #category : #accessing }
RBAbstractClass2 >> realName: aSymbol [

	self subclassResponsibility
]

{ #category : #transforming }
RBAbstractClass2 >> renameInstanceVariable: oldName to: newName around: aBlock [

	self privateInstanceVariableNames 
		at: (self privateInstanceVariableNames indexOf: oldName asString)
		put: newName asString.
		
	^ self model 
		performChange: (changeFactory   
							renameInstanceVariable: oldName
							to: newName
							in: self)
		around: aBlock
]

{ #category : #querying }
RBAbstractClass2 >> setterMethodFor: aVariableName [
	| matcher candidateSetters |
	matcher := self parseTreeSearcherClass setterMethod: aVariableName.
	candidateSetters := (self definesInstanceVariable: aVariableName)
		ifTrue: [ self whichSelectorsReferToInstanceVariable: aVariableName ]
		ifFalse: [ self whichSelectorsReferToClassVariable: aVariableName ].
	candidateSetters := candidateSetters
		select: [ :each | each numArgs == 1 ].
	^ candidateSetters
		detect: [ :each | 
			(self checkSelector: each using: matcher) notNil
				and: [ (self subclassRedefines: each) not ] ]
		ifNone: [ nil ]
]

{ #category : #accessing }
RBAbstractClass2 >> withAllSuperclassesUntil: aClass [

	^ (self allSuperclassesUntil: aClass)
		add: self;
		yourself
]
