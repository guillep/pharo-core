"
I am abstract. Subclasses of me model meta objects for global variables (Class, Global, Pool), called ""Literal Variables"" in Smalltalk.

I am polymorphic with Association, modeling the binding of the global in either the Smalltalk globals, Undeclared or classPools. Previously I was a subclass of Associations but it leaded to many duplicated methods with other non literal variables (slots and temps).

When chaning emit* methods, do not forget to recompile exisiting code:

aGlobal usingMethods do: #recompile 

***NOTE***
When moving binding from Undeclared, we change the class of that binding to either ClassVariable or GlobalVariable.

==> when we use Global subclasses, we will either need to restrict adding variables or add a slow path where we create a new binding and update all users. But this can be done later.
"
Class {
	#name : #LiteralVariable,
	#superclass : #Variable,
	#instVars : [
		'value'
	],
	#category : #'Kernel-Variables'
}

{ #category : #validating }
LiteralVariable class >> checkValidName: aString [ 
	"aString first canBeGlobalVarInitial
		ifFalse: [InvalidGlobalName signal: 'Class name does not start with a valid Global Var Initial' for: aString]"
]

{ #category : #'gt-inspector-extension' }
LiteralVariable class >> gtInspectorAllVariablesIn: composite [
 	"This provides a list of all defined Class or Global Variables"
 	<gtInspectorPresentationOrder: 20>
 	composite list 
 		title: 'All Defined Variables';
 		display: [ self allSubclasses sorted: #name ascending ];
 		tags: [ :each | { each package name } ];
 		when: [self == LiteralVariable  ].
]

{ #category : #'instance creation' }
LiteralVariable class >> key: aKey [ 
	"Answer an instance of me with the argument as the lookup up."

	^self basicNew key: aKey
]

{ #category : #'instance creation' }
LiteralVariable class >> key: newKey value: newValue [
	"Answer an instance of me with the arguments as the key and value of 
	the association."

	^self basicNew key: newKey value: newValue
]

{ #category : #comparing }
LiteralVariable >> = anAssociation [

	^ super = anAssociation and: [value = anAssociation value]
]

{ #category : #visiting }
LiteralVariable >> acceptVisitor: aProgramNodeVisitor node: aNode [
	^ aProgramNodeVisitor visitLiteralVariableNode: aNode
]

{ #category : #testing }
LiteralVariable >> analogousCodeTo: anAssociation [
	^ self = anAssociation
]

{ #category : #converting }
LiteralVariable >> asClassVariable [	
	^self
]

{ #category : #queries }
LiteralVariable >> definingClass [
	"The class defining the variable. For Globals, return nil"
	^Smalltalk globals allClasses detect: [ :class | class hasClassVariable: self ] ifNone: [ nil ]
]

{ #category : #printing }
LiteralVariable >> definitionString [
	"Every subclass that adds state must redefine either this method or #printOn:"
	^ self printString
]

{ #category : #'code generation' }
LiteralVariable >> emitStore: aMethodBuilder [
	| tempName |
	tempName := '0TempForStackManipulation'.
	aMethodBuilder
		addTemp: tempName;
		storeTemp: tempName;
		popTop;
		pushLiteral: self;
		pushTemp: tempName;
		send: #write:
]

{ #category : #'code generation' }
LiteralVariable >> emitValue: aMethodBuilder [
	aMethodBuilder
		pushLiteral: self;
		send: #read
]

{ #category : #comparing }
LiteralVariable >> hash [
	"Hash is reimplemented because = is implemented."

	^name hash
]

{ #category : #'class building' }
LiteralVariable >> installingIn: aClass [
	"I am called by the class builder. This way a class variable can change the class it is installed in"
]

{ #category : #testing }
LiteralVariable >> isAccessedIn: aMethod [ 
	
	^aMethod accessesRef: self
]

{ #category : #generated }
LiteralVariable >> isGlobal [

	self
		deprecated: 'Use #isGlobalVariable instead'
		transformWith: '`@rec isGlobal' -> '`@rec isGlobalVariable'.
	^ self isGlobalVariable
]

{ #category : #testing }
LiteralVariable >> isGlobalClassNameBinding [
	^ self value isClassOrTrait
		and: [ (name == self value name) or: [ self value isObsolete ] ]
]

{ #category : #testing }
LiteralVariable >> isLiteralVariable [
	^true
]

{ #category : #testing }
LiteralVariable >> isReadIn: aCompiledCode [
	^aCompiledCode readsRef: self
]

{ #category : #testing }
LiteralVariable >> isReferenced [
	"my subclasses override this if they know better"

	^ Smalltalk globals allBehaviors anySatisfy: [ :behavior | 
		  behavior hasMethodAccessingVariable: self ]
]

{ #category : #testing }
LiteralVariable >> isSelfEvaluating [
	^ self key isSelfEvaluating and: [self value isSelfEvaluating]
]

{ #category : #testing }
LiteralVariable >> isVariableBinding [
	"Maybe we should deprecate this and use isLiteralVariable instead"
	^true
]

{ #category : #testing }
LiteralVariable >> isWritable [
	"Literal variables are writable, if they aren't global bindings for class names, like
 #Object -> Object "

	^ (self isGlobalVariable and: [ self isGlobalClassNameBinding ]) not
]

{ #category : #testing }
LiteralVariable >> isWrittenIn: aCompiledCode [
	^aCompiledCode writesRef: self
]

{ #category : #accessing }
LiteralVariable >> key [ 
	^name
]

{ #category : #accessing }
LiteralVariable >> key: anObject [ 
	name := anObject
]

{ #category : #accessing }
LiteralVariable >> key: aKey value: anObject [ 
	"Store the arguments as the variables of the receiver."

	name := aKey.
	value := anObject
]

{ #category : #comparing }
LiteralVariable >> literalEqual: otherLiteral [
	"Answer true if the receiver and otherLiteral represent the same literal.
	Variable bindings are literally equals only if identical.
	This is how variable sharing works, by preserving identity and changing only the value."
	^self == otherLiteral
]

{ #category : #accessing }
LiteralVariable >> name: aString [ 
	self key: aString asSymbol
]

{ #category : #printing }
LiteralVariable >> printOn: aStream [

	name printOn: aStream.
	aStream nextPutAll: '->'.
	value printOn: aStream
]

{ #category : #'meta-object-protocol' }
LiteralVariable >> read [
	^self value
]

{ #category : #debugging }
LiteralVariable >> readInContext: aContext [
	^self value
]

{ #category : #accessing }
LiteralVariable >> scope [
	^self definingClass
]

{ #category : #printing }
LiteralVariable >> storeOn: aStream [
	"Store in the format (key->value)"
	aStream nextPut: $(.
	name storeOn: aStream.
	aStream nextPutAll: '->'.
	value storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #queries }
LiteralVariable >> usingMethods [
	^SystemNavigation new allReferencesToBinding: self
]

{ #category : #accessing }
LiteralVariable >> value [
	^ value
]

{ #category : #accessing }
LiteralVariable >> value: anObject [
	value := anObject
]

{ #category : #'meta-object-protocol' }
LiteralVariable >> write: anObject [
	self value: anObject.
	^anObject
]

{ #category : #debugging }
LiteralVariable >> write: aValue inContext: aContext [
	self isWritable ifFalse: [ 
		^self error: 'Variable ' , name, ' is read only'].

	^value := aValue
]
