"
I model Class Variables and therefore Pool Variables, too. I am stored as a binding in the classPool of the class defining me.

The compiler forwards bytecode generation to me for accessing the variable.

You can subclass me and implement #read and #write: for creating special kinds of globals that can be used as special class Variables (similar to special Slots).

Note: PoolVariable is not modeled as it's own subclass to allow all special kinds of globals to be used
as pool variables.
"
Class {
	#name : #ClassVariable,
	#superclass : #LiteralVariable,
	#instVars : [
		'owningClass',
		'definingClass'
	],
	#category : #'Kernel-Variables'
}

{ #category : #visiting }
ClassVariable >> acceptVisitor: aProgramNodeVisitor node: aNode [
	^ aProgramNodeVisitor visitClassVariableNode: aNode
]

{ #category : #accessing }
ClassVariable >> definingClass [
	"if a Variable is from a Trait is installed in a class, we store the orginal class of the trait here"
	^ definingClass ifNil: [ self owningClass ]
]

{ #category : #accessing }
ClassVariable >> definingClass: anObject [
	definingClass := anObject
]

{ #category : #printing }
ClassVariable >> definitionString [
	"non special globals are defined by the symbol"
	^ self needsFullDefinition
		ifTrue: [ super definitionString ]
		ifFalse: [ self name printString ]

]

{ #category : #'code generation' }
ClassVariable >> emitStore: methodBuilder [

	methodBuilder storeIntoLiteralVariable: self.


]

{ #category : #'code generation' }
ClassVariable >> emitValue: methodBuilder [

	methodBuilder pushLiteralVariable: self
]

{ #category : #testing }
ClassVariable >> isClassVariable [
	^ true
]

{ #category : #testing }
ClassVariable >> isDefinedByOwningClass [

	^ self owningClass = self definingClass
]

{ #category : #testing }
ClassVariable >> isPoolVariable [
	^ self definingClass isPool 
]

{ #category : #testing }
ClassVariable >> isReferenced [
	"A class variable can only be accessed in the defintionClass and its subclasses (both class and instance side)"

	^ self definingClass withAllSubclasses anySatisfy: [ :behavior | 
		  (behavior class hasMethodAccessingVariable: self) or: [ behavior hasMethodAccessingVariable: self ] ]
]

{ #category : #testing }
ClassVariable >> needsFullDefinition [
	"only ClassVariable can use a simplified definition"

	^ self class ~= ClassVariable
]

{ #category : #accessing }
ClassVariable >> owningClass [
	^ owningClass
]

{ #category : #accessing }
ClassVariable >> owningClass: anObject [
	owningClass := anObject
]

{ #category : #queries }
ClassVariable >> usingMethods [
	self definingClass isPool ifTrue: [ ^ super usingMethods ].
	"if we are a class variable, we only need to search the sublasses and metaclasses"
	^ self definingClass withAllSubclasses flatCollect: [ :class | 
			(class whichMethodsReferTo: self), (class class whichMethodsReferTo: self) ]
]
