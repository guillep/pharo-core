"
I am a composition of RBRefactoryChanges. I hold a list of changes. 
I implement many ""environment change"" operation like renameClass/removeClass/ rename instance variable that are
actually called on the name space by a refactoring operation and my responsibilty is to create a appropriate refactoring change
and save it in my list of changes.

"
Class {
	#name : #RBCompositeRefactoryChange,
	#superclass : #RBRefactoryChange,
	#instVars : [
		'changes',
		'newName',
		'oldName'
	],
	#category : #'Refactoring-Changes'
}

{ #category : #'instance creation' }
RBCompositeRefactoryChange class >> named: aString [
	^ self new
		name: aString;
		yourself
]

{ #category : #comparing }
RBCompositeRefactoryChange >> = aRefactoryBuilder [ 
	self class = aRefactoryBuilder class
		ifFalse: [ ^ false ].
	changes size = aRefactoryBuilder changes size
		ifFalse: [ ^ false ].
	changes with: aRefactoryBuilder changes do: [ :first :second |
		first = second
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #accessing }
RBCompositeRefactoryChange >> addChange: aRefactoryChange [ 
	changes add: aRefactoryChange.
	^ aRefactoryChange
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> addClassVariable: variableName to: aClass [ 
	^ self addChange: (changeFactory addClassVariable: variableName to: aClass)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> addInstanceVariable: variableName to: aClass [ 
	^ self addChange: (changeFactory addInstanceVariable: variableName to: aClass)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> addPackageNamed: aString [
	^ self addChange: (changeFactory addPackageNamed: aString)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> addPool: aPoolVariable to: aClass [ 
	^ self addChange: (changeFactory addPoolVariable: aPoolVariable to: aClass)
]

{ #category : #accessing }
RBCompositeRefactoryChange >> changeClass [
	^ self subclassResponsibility
]

{ #category : #accessing }
RBCompositeRefactoryChange >> changeForClass: aClassName selector: aSelector [ 
	changes reverseDo: [ :each | 
		| change |
		change := each changeForClass: aClassName selector: aSelector.
		change notNil ifTrue: [ ^ change ] ].
	^ nil
]

{ #category : #accessing }
RBCompositeRefactoryChange >> changeForMetaclass: aClassName selector: aSelector [ 
	changes reverseDo: [ :each | 
		| change |
		change := each changeForMetaclass: aClassName selector: aSelector.
		change notNil ifTrue: [ ^ change ] ].
	^ nil
]

{ #category : #'private-inspector accessing' }
RBCompositeRefactoryChange >> changes [
	^ changes
]

{ #category : #'private-inspector accessing' }
RBCompositeRefactoryChange >> changes: aCollection [ 
	changes := aCollection
]

{ #category : #accessing }
RBCompositeRefactoryChange >> changesSize [
	^ changes inject: 0 into: [ :sum :each | sum + each changesSize ]
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> comment: aString in: aClass [ 
	^ self addChange: (changeFactory comment: aString in: aClass)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> compile: source in: class [ 
	^ self addChange: (changeFactory addMethodSource: source in: class)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> compile: source in: class classified: aProtocol [ 
	^ self addChange: (changeFactory addMethodSource: source in: class classified: aProtocol)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> defineClass: aString [ 
	^ self addChange: (changeFactory addClassDefinition: aString)
]

{ #category : #private }
RBCompositeRefactoryChange >> executeNotifying: aBlock [ 
	| undos undo |
	undos := changes collect: [ :each | each executeNotifying: aBlock ].
	undo := self copy.
	undo changes: undos reversed.
	^ undo
]

{ #category : #comparing }
RBCompositeRefactoryChange >> hash [
	^ self class hash bitXor: self changes size hash
]

{ #category : #initialization }
RBCompositeRefactoryChange >> initialize [
	super initialize.
	changes := OrderedCollection new
]

{ #category : #accessing }
RBCompositeRefactoryChange >> newName [
	^ self subclassResponsibility
]

{ #category : #accessing }
RBCompositeRefactoryChange >> oldName [
	^ self subclassResponsibility
]

{ #category : #copying }
RBCompositeRefactoryChange >> postCopy [
	super postCopy.
	changes := changes collect: [ :each | each copy ]
]

{ #category : #printing }
RBCompositeRefactoryChange >> printOn: aStream [

	name ifNil: [ ^ super printOn: aStream ].
	aStream nextPutAll: name
]

{ #category : #accessing }
RBCompositeRefactoryChange >> problemCount [
	^ self changesSize
]

{ #category : #accessing }
RBCompositeRefactoryChange >> removeChange: aChange [ 
	^ changes remove: aChange ifAbsent: [ nil ]
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> removeClass: aClass [ 
	^ self addChange: (changeFactory removeClassNamed: aClass name)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> removeClassNamed: aSymbol [ 
	^ self addChange: (changeFactory removeClassNamed: aSymbol)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> removeClassVariable: variableName from: aClass [ 
	^ self addChange: (changeFactory removeClassVariable: variableName from: aClass)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> removeInstanceVariable: variableName from: aClass [ 
	^ self addChange: (changeFactory removeInstanceVariable: variableName from: aClass)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> removeMethod: aSelector from: aClass [ 
	^ self addChange: (changeFactory removeMethod: aSelector from: aClass)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> removePool: aPoolVariable from: aClass [ 
	^ self addChange: (changeFactory removePoolVariable: aPoolVariable from: aClass)
]

{ #category : #accessing }
RBCompositeRefactoryChange >> renameChangesForClass: oldClassName to: newClassName [
	^ self copy
		changes: (self changes 
			collect: [ :each | each renameChangesForClass: oldClassName to: newClassName ]);
		yourself
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> renameClass: class to: newNameLocal [ 
	^ self addChange: (changeFactory renameClass: class to: newNameLocal)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> renameClassVariable: oldNameLocal to: newNameLocal in: aClass [
	^ self addChange: (changeFactory renameClassVariable: oldNameLocal to: newNameLocal in: aClass)
]

{ #category : #'refactory-changes' }
RBCompositeRefactoryChange >> renameInstanceVariable: oldNameLocal to: newNameLocal in: aClass [
	^ self addChange: (changeFactory renameInstanceVariable: oldNameLocal to: newNameLocal in: aClass)
]
