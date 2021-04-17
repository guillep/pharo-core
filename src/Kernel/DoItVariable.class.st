"
I model an access to variables from DoIt scripts. Following example demonstrates an idea:

	| temp |
	temp := 100.
	doItVar := DoItVariable named: #temp fromContext: thisContext.	
	Smalltalk compiler
		bindings: {doItVar};
		evaluate: '1+temp'.

I capture a given variable and a context and compile a method nodes using unified reflective API as:

	doItVariable read.
	doItVariable write: newValue.
	
This way variables visible from one context are indirectly accessible from another environment (from doit expressions).

For example in ""debugIt expressions"" in Debugger the temp variables from original context are shown as normal variables without any tricks.

To create my instances use following messages:

	DoItVariable named: #temp fromContext: thisContext.
	DoItVariable fromContext: thisContext variable: aVariable.

Or use a variable message: 

	aVariable asDoItVariableFrom: aContext
 
Internal Representation and Key Implementation Points.

    Instance Variables
	actualVariable:		<Variable>
	doItContext:		<Context>
"
Class {
	#name : #DoItVariable,
	#superclass : #Variable,
	#instVars : [
		'actualVariable',
		'doItContext'
	],
	#category : #'Kernel-Variables'
}

{ #category : #'instance creation' }
DoItVariable class >> fromContext: aContext variable: aVariable [

	^self new 
		doItContext: aContext;
		actualVariable: aVariable
]

{ #category : #'instance creation' }
DoItVariable class >> named: aString fromContext: aContext [ 
	^self 
		fromContext: aContext 
		variable: (aContext lookupVar: aString)
]

{ #category : #accessing }
DoItVariable >> actualVariable [
	^ actualVariable
]

{ #category : #accessing }
DoItVariable >> actualVariable: aVariable [
	actualVariable := aVariable.
	name := actualVariable name
]

{ #category : #converting }
DoItVariable >> asDoItVariableFrom: aContext [
	^self
]

{ #category : #accessing }
DoItVariable >> doItContext [
	^ doItContext
]

{ #category : #accessing }
DoItVariable >> doItContext: anObject [
	doItContext := anObject
]

{ #category : #'code generation' }
DoItVariable >> emitStore: aMethodBuilder [
	"generate bytecode to call the reflective write method of the Slot"
	| tempName |
	tempName := '0slotTempForStackManipulation'.  
	aMethodBuilder
		addTemp: tempName;
		storeTemp: tempName;
		popTop;
		pushLiteral: self;
		pushTemp: tempName;
		send: #write:
]

{ #category : #'code generation' }
DoItVariable >> emitValue: aMethodBuilder [
	aMethodBuilder
		pushLiteral: self;
		send: #read
]

{ #category : #testing }
DoItVariable >> isArgumentVariable [
	^actualVariable isArgumentVariable
]

{ #category : #testing }
DoItVariable >> isClassVariable [
	^actualVariable isClassVariable 
]

{ #category : #testing }
DoItVariable >> isGlobalVariable [
	^actualVariable isGlobalVariable 
]

{ #category : #testing }
DoItVariable >> isInstanceVariable [
	^actualVariable isInstanceVariable 
]

{ #category : #testing }
DoItVariable >> isLiteralVariable [
	^actualVariable isLiteralVariable
]

{ #category : #testing }
DoItVariable >> isLocalVariable [
	^actualVariable isLocalVariable 
]

{ #category : #testing }
DoItVariable >> isReservedVariable [
	^actualVariable isReservedVariable 
]

{ #category : #testing }
DoItVariable >> isSelfVariable [
	^actualVariable isSelfVariable 
]

{ #category : #testing }
DoItVariable >> isSuperVariable [
	^actualVariable isSuperVariable 
]

{ #category : #testing }
DoItVariable >> isTempVariable [
	^actualVariable isTempVariable 
]

{ #category : #testing }
DoItVariable >> isThisContextVariable [
	^actualVariable isThisContextVariable 
]

{ #category : #testing }
DoItVariable >> isUndeclaredVariable [
	^actualVariable isUndeclaredVariable 
]

{ #category : #testing }
DoItVariable >> isUninitialized [
	^actualVariable isUninitialized 
]

{ #category : #testing }
DoItVariable >> isWorkspaceVariable [
	^actualVariable isWorkspaceVariable 
]

{ #category : #accessing }
DoItVariable >> key [ 
	^self name
]

{ #category : #'read/write usage' }
DoItVariable >> markEscapingRead [
	"ignored, the escape status of the actualVariable does not change"
]

{ #category : #'read/write usage' }
DoItVariable >> markEscapingWrite [
	"ignored, the escape status of the actualVariable does not change"
]

{ #category : #'read/write usage' }
DoItVariable >> markRead [
	"ignored, the escape status of the actualVariable does not change"
]

{ #category : #'read/write usage' }
DoItVariable >> markRepeatedWrite [
	"ignored, the escape status of the actualVariable does not change"
]

{ #category : #'read/write usage' }
DoItVariable >> markWrite [
	"ignored, the escape status of the actualVariable does not change"
]

{ #category : #printing }
DoItVariable >> printOn: aStream [ 
	super printOn: aStream.
	
	aStream nextPut: $(.
	actualVariable printOn: aStream.
	aStream nextPut: $)
]

{ #category : #'meta-object-protocol' }
DoItVariable >> read [
	^actualVariable readInContext: doItContext 
]

{ #category : #debugging }
DoItVariable >> readInContext: aContext [
	^self read
]

{ #category : #accessing }
DoItVariable >> scope [ 
	^ actualVariable scope
]

{ #category : #queries }
DoItVariable >> usingMethods [
	^actualVariable usingMethods
]

{ #category : #'meta-object-protocol' }
DoItVariable >> write: aValue [
	^actualVariable write: aValue inContext: doItContext 
]

{ #category : #debugging }
DoItVariable >> write: aValue inContext: aContext [
	self write: aValue
]
