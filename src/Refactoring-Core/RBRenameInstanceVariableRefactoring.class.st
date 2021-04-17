"
I am a refactoring for rename instance variables.

I rename the instance variable in the class definition, in all methods refering to this variable and rename the old accessors.

My precondition verifies that the new variable is valid and not yet used in the whole class hierarchy.
"
Class {
	#name : #RBRenameInstanceVariableRefactoring,
	#superclass : #RBVariableRefactoring,
	#instVars : [
		'newName',
		'browsedEnvironment',
		'renameAccessors'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBRenameInstanceVariableRefactoring class >> model: aRBSmalltalk rename: aVarName to: aName in: aClass [ 
	^(self new)
		model: aRBSmalltalk;
		rename: aVarName
			to: aName
			in: aClass;
		yourself
]

{ #category : #'instance creation' }
RBRenameInstanceVariableRefactoring class >> model: aRBSmalltalk rename: aVarName to: aName in: aClass renameAccessors: aBoolean [
	^(self new)
		model: aRBSmalltalk;
		rename: aVarName
			to: aName
			in: aClass
			renameAccessors: aBoolean;
		yourself
]

{ #category : #'instance creation' }
RBRenameInstanceVariableRefactoring class >> rename: aVarName to: aName in: aClass [
	^self new
		rename: aVarName
		to: aName
		in: aClass
]

{ #category : #'instance creation' }
RBRenameInstanceVariableRefactoring class >> rename: aVarName to: aName in: aClass renameAccessors: aBoolean [
	^self new
		rename: aVarName
		to: aName
		in: aClass
		renameAccessors: aBoolean
]

{ #category : #transforming }
RBRenameInstanceVariableRefactoring >> addNewAccessors [
	| refactoring |
	refactoring := RBCreateAccessorsForVariableRefactoring
		model: self
		variable: newName asString
		class: class
		classVariable: false.
	refactoring
		createGetterAccessor;
		createSetterAccessor
]

{ #category : #refactoring }
RBRenameInstanceVariableRefactoring >> browsedEnvironment [
	^ browsedEnvironment ifNil: [ browsedEnvironment := RBBrowserEnvironment new ]
]

{ #category : #refactoring }
RBRenameInstanceVariableRefactoring >> executeRefactoring: aRefactoring [
	aRefactoring primitiveExecute.
	self parserClass parseExpression: aRefactoring storeString
]

{ #category : #initialization }
RBRenameInstanceVariableRefactoring >> initialize [
	super initialize.
	renameAccessors := false
]

{ #category : #accessing }
RBRenameInstanceVariableRefactoring >> newName [
	^ newName
]

{ #category : #accessing }
RBRenameInstanceVariableRefactoring >> newName: anObject [
	newName := anObject
]

{ #category : #preconditions }
RBRenameInstanceVariableRefactoring >> preconditions [
	^(RBCondition isValidInstanceVariableName: newName for: class) 
		& (RBCondition definesInstanceVariable: variableName in: class) 
			& (RBCondition hierarchyOf: class definesVariable: newName) not 
			& (RBCondition isGlobal: newName in: self model) not
]

{ #category : #transforming }
RBRenameInstanceVariableRefactoring >> removeOldAccessors [
	| oldAccessors |
	oldAccessors := (class allSelectors
		select: [ :each | each = variableName asSymbol or: [ each = (variableName , ':') asSymbol ] ]
		thenCollect: [ :each | class methodFor: each ]) asOrderedCollection.
	oldAccessors do: [ :each | class removeMethod: each selector ]
]

{ #category : #initialization }
RBRenameInstanceVariableRefactoring >> rename: aVarName to: aName in: aClass [
	self rename: aVarName to: aName in: aClass renameAccessors: false

]

{ #category : #initialization }
RBRenameInstanceVariableRefactoring >> rename: aVarName to: aName in: aClass renameAccessors: aBoolean [
	self variable: aVarName class: aClass.
	newName := aName.
	renameAccessors := aBoolean
]

{ #category : #accessing }
RBRenameInstanceVariableRefactoring >> renameAccessors [
	^ renameAccessors
]

{ #category : #accessing }
RBRenameInstanceVariableRefactoring >> renameAccessors: anObject [
	renameAccessors := anObject
]

{ #category : #transforming }
RBRenameInstanceVariableRefactoring >> renameAccessorsReferences [
	| methods senders |
	methods := (class allSelectors select: [ :each | (class methodFor: each) isNotNil ] thenCollect: [ :each | each ])
		asOrderedCollection.
	senders := (methods
		select: [ :each | (class methodFor: each) source includesSubstring: variableName asString ]
		thenCollect: [ :each | class methodFor: each ]) asOrderedCollection.
	senders
		do: [ :each | each source: (each source copyReplaceAll: variableName asString with: newName asString asTokens: false) ].
	senders
		do: [ :each | 
			(each selector = newName or: [ each selector asString = (newName asString , ':') ])
				ifFalse: [ (model classNamed: class name) compile: each source classified: each protocols ] ]
]

{ #category : #transforming }
RBRenameInstanceVariableRefactoring >> renameReferences [
	| replacer classes |
	replacer := self parseTreeRewriterClass 
				rename: variableName
				to: newName
				handler: 
					[self 
						refactoringError: ('<1s> is already defined as a method or block temporary <n> variable in this class or one of its subclasses' 
								expandMacrosWith: newName)].
	classes := class withAllSubclasses, (class isTrait ifTrue: [class users asArray ] ifFalse: [{}]).
	self 
		convertClasses: classes
		select: [:aClass | aClass whichSelectorsReferToInstanceVariable: variableName]
		using: replacer
]

{ #category : #printing }
RBRenameInstanceVariableRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' rename: ''';
		nextPutAll: variableName;
		nextPutAll: ''' to: ''';
		nextPutAll: newName;
		nextPutAll: ''' in: '.
	class storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #transforming }
RBRenameInstanceVariableRefactoring >> transform [
	renameAccessors ifTrue: [ 
		self removeOldAccessors 
	].
	
	class renameInstanceVariable: variableName to: newName around: [ self renameReferences ].
	
	renameAccessors ifFalse: [ ^ self ].
	self addNewAccessors.
	self renameAccessorsReferences.
]
