"
I am an abstract class. Subclasses of me model meta objects for any kind of variables: 

- slots (instance variables)
- literal variables (Class, Global, Pool) and 
- local variables of methods (temps and args). 

Being a superclass for LiteralVariable I have a restriction on my layout: I can only have a single instance variable representing the variable #name
								DO NOT ADD ANY NEW STATE TO ME.

This restriction is required because LiteralVariable encodes global references in the method literals and therefore there is an expectation from the VM on particular shape of these objects.

At this step I only pulled a duplicated protocol of properties from my subclasses. But more cleanup is comming:
- breakpoints
- metalinks
- queries
- refactoring commands

Internal Representation and Key Implementation Points.

Instance Variables
	name:		<Symbol>
"
Class {
	#name : #Variable,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#classVars : [
		'Properties'
	],
	#category : #'Kernel-Variables'
}

{ #category : #validating }
Variable class >> checkValidName: aString [ 

]

{ #category : #'class initialization' }
Variable class >> initialize [
	Properties := Properties
		ifNil: [ WeakIdentityKeyDictionary new. ]
		ifNotNil: [ (WeakIdentityKeyDictionary newFrom: Properties) rehash]
]

{ #category : #testing }
Variable class >> isAbstract [ 
	^self = Variable 
]

{ #category : #'instance creation' }
Variable class >> named: aSymbol [
	self checkValidName: aSymbol.
	^ self new
		name: aSymbol;
		yourself
]

{ #category : #comparing }
Variable >> = other [
	"Every subclass that adds state must redefine this method"
	self == other
		ifTrue: [ ^ true ].
	^ (self species == other species) 
			and: [ name = other name ]
]

{ #category : #visiting }
Variable >> acceptVisitor: aProgramNodeVisitor node: aNode [
	^ aProgramNodeVisitor visitVariableNode: aNode
]

{ #category : #converting }
Variable >> asDoItVariableFrom: aContext [
	^ DoItVariable fromContext: aContext variable: self
]

{ #category : #queries }
Variable >> definingNode [
	^ nil
]

{ #category : #'code generation' }
Variable >> emitStore: methodBuilder [

	self subclassResponsibility
]

{ #category : #'code generation' }
Variable >> emitValue: methodBuilder [

	self subclassResponsibility
]

{ #category : #properties }
Variable >> ensureProperties [
	^ Properties at: self ifAbsentPut: WeakKeyDictionary new
]

{ #category : #properties }
Variable >> hasProperty: aKey [
	"Test if the property aKey is present."
	^self properties 
		ifNil: [false]
		ifNotNil: [:prop | prop includesKey: aKey]
]

{ #category : #comparing }
Variable >> hash [
	"Every subclass that adds state must redefine this method"
	^ self species hash bitXor: self name hash
]

{ #category : #testing }
Variable >> isAccessedIn: aMethod [
	^self usingMethods includes: aMethod
]

{ #category : #testing }
Variable >> isArgumentVariable [
	^false
]

{ #category : #testing }
Variable >> isClassVariable [
	^ false
]

{ #category : #testing }
Variable >> isDefinedByBlock [
	"true if a variable node is defined by a block"
	^false

]

{ #category : #testing }
Variable >> isGlobalVariable [
	^ false
]

{ #category : #testing }
Variable >> isInstanceVariable [
	"check if the var is an instance variable (a Slot)"
	^false
]

{ #category : #testing }
Variable >> isLiteralVariable [
	"returns true for Global Variables, Class Variables and some others 
	(e.g. Workspace bindings and Undeclared variables, see subclasses)"
	^false
]

{ #category : #testing }
Variable >> isLocalVariable [
	"temporary variables and arguments are local variables"
	^false
]

{ #category : #testing }
Variable >> isPoolVariable [
	^ false
]

{ #category : #testing }
Variable >> isReadIn: aCompiledCode [
	^aCompiledCode ast readNodes
		 anySatisfy: [ :node | node binding == self ]
]

{ #category : #testing }
Variable >> isReferenced [
	^ self usingMethods isNotEmpty
]

{ #category : #testing }
Variable >> isReservedVariable [
	"thisContext, super, self are reserved variables (true, false and nil are literals)"
	^false
]

{ #category : #testing }
Variable >> isSelfOrSuperVariable [
	^ self isSelfVariable or: [ self isSuperVariable ]
]

{ #category : #testing }
Variable >> isSelfVariable [
	^false
]

{ #category : #testing }
Variable >> isShadowing [
	"I shadow a variable if looking up my name in the outer scope returns a variable"
	^(self scope outerScope ifNotNil: [:outer | outer lookupVar: self name]) notNil
]

{ #category : #testing }
Variable >> isSuperVariable [
	^false
]

{ #category : #testing }
Variable >> isTempVariable [
	^false
]

{ #category : #testing }
Variable >> isThisContextVariable [
	^false
]

{ #category : #testing }
Variable >> isUndeclaredVariable [

	^ false
]

{ #category : #testing }
Variable >> isUninitialized [

	^ false
]

{ #category : #testing }
Variable >> isUsed [ 
	^ self isReferenced
]

{ #category : #testing }
Variable >> isWorkspaceVariable [
	^ false
]

{ #category : #testing }
Variable >> isWritable [
	^ true
]

{ #category : #testing }
Variable >> isWrittenIn: aCompiledCode [
	^aCompiledCode ast variableWriteNodes
		anySatisfy: [ :node | node binding == self ]
]

{ #category : #accessing }
Variable >> name [
	^ name
]

{ #category : #accessing }
Variable >> name: aSymbol [
	name := aSymbol
]

{ #category : #testing }
Variable >> needsFullDefinition [
	"all but InstanceVariableSlot and ClassVariable need to print the full definition"
	^true
]

{ #category : #properties }
Variable >> properties [
	^ Properties at: self ifAbsent: nil
		
]

{ #category : #properties }
Variable >> propertyAt: propName [
	^ self
		propertyAt: propName
		ifAbsent: [ nil ]
		
]

{ #category : #properties }
Variable >> propertyAt: propName ifAbsent: aBlock [
	self properties ifNil: [^aBlock value].
	^ self properties
		at: propName
		ifAbsent: aBlock
		
]

{ #category : #properties }
Variable >> propertyAt: aKey ifAbsentPut: aBlock [
	"Answer the property associated with aKey or, if aKey isn't found store the result of evaluating aBlock as new value."
	
	^ self propertyAt: aKey ifAbsent: [ self propertyAt: aKey put: aBlock value ]
]

{ #category : #properties }
Variable >> propertyAt: propName put: propValue [
	^ self ensureProperties
		at: propName
		put: propValue
]

{ #category : #debugging }
Variable >> readInContext: aContext [
	self subclassResponsibility 
]

{ #category : #properties }
Variable >> removePropertiesIfEmpty [
	^ Properties at: self ifPresent: [ :dict |
		dict ifEmpty: [ Properties removeKey: self ] ]
]

{ #category : #properties }
Variable >> removeProperty: propName [
	^ self
		removeProperty: propName
		ifAbsent: [ nil ]
]

{ #category : #properties }
Variable >> removeProperty: propName ifAbsent: aBlock [
	| property |
	self properties ifNil: [^aBlock value].
	property := self properties
		removeKey: propName
		ifAbsent: aBlock.
	self removePropertiesIfEmpty.
	^ property
]

{ #category : #accessing }
Variable >> scope [
	^self subclassResponsibility
]

{ #category : #queries }
Variable >> usingMethods [
	self subclassResponsibility
]

{ #category : #debugging }
Variable >> write: aValue inContext: aContext [
	"write the value in aContext. All #write:inContext: methods need to return the assigned value,
	as this is the reflective version of assignment which has the assigned value as a value"
	^self subclassResponsibility 
]
