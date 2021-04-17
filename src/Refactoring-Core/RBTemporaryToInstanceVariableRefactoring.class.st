"
I am a refactoring for changing a temporary variable to an instance variable.

My preconditions verify that this variable is not yet used as an instance variable in this class.

The temporary variable is added to the class definition and removed from the temporary declaration in this method .

If this instance variable is already used in a subclass it will be removed from that class, because subclasses already inherit this attribute.

The temporary variables with the same name in hierarchy will be removed, and replaced with the new instance variable.

Example
--------------------

Script refactoring:
```
(RBTemporaryToInstanceVariableRefactoring 
    class: MyClassA
    selector: #someMethod
    variable: 'log') execute
```
Before refactoring:
```
Object subclass: #MyClassA
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'example'

MyClassA >> someMethod 
    |log aNumber|
    log := self newLog.
    log isNil.
    aNumber := 5.

MyClassA >> anotherMethod
    #(4 5 6 7) do: [:e | | log |
        log := e ]

MyClassA subclass: #MyClassB
	instanceVariableNames: 'log'
	classVariableNames: ''
	package: 'example'
```
After refactoring:
```
Object subclass: #MyClassA
	instanceVariableNames: 'log'
	classVariableNames: ''
	package: 'example'

MyClassA >> someMethod 
    | aNumber |
    log := self newLog.
    log isNil.
    aNumber := 5.

MyClassA >> anotherMethod
    #(4 5 6 7) do: [:e | 
        log := e ]

MyClassA subclass: #MyClassB
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'example'
```
"
Class {
	#name : #RBTemporaryToInstanceVariableRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'selector',
		'temporaryVariableName'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBTemporaryToInstanceVariableRefactoring class >> class: aClass selector: aSelector variable: aVariableName [ 
	^self new 
		class: aClass
		selector: aSelector
		variable: aVariableName
]

{ #category : #'instance creation' }
RBTemporaryToInstanceVariableRefactoring class >> model: aRBSmalltalk class: aClass selector: aSelector variable: aVariableName [ 
	^(self new)
		model: aRBSmalltalk;
		class: aClass
			selector: aSelector
			variable: aVariableName;
		yourself
]

{ #category : #preconditions }
RBTemporaryToInstanceVariableRefactoring >> checkForValidTemporaryVariable [
	| parseTree |
	parseTree := class parseTreeFor: selector.
	(parseTree allTemporaryVariables includes: temporaryVariableName) 
		ifFalse: 
			[self refactoringFailure: temporaryVariableName 
						, ' isn''t a valid temporary variable name'].
	(parseTree allArgumentVariables includes: temporaryVariableName) 
		ifTrue: 
			[self refactoringFailure: temporaryVariableName , ' is a block parameter'].
	(RBReadBeforeWrittenTester isVariable: temporaryVariableName
		readBeforeWrittenIn: parseTree) 
			ifTrue: 
				[self 
					refactoringWarning: ('<1s> is read before it is written.<n>Proceed anyway?' 
							expandMacrosWith: temporaryVariableName)]
]

{ #category : #initialization }
RBTemporaryToInstanceVariableRefactoring >> class: aClass selector: aSelector variable: aVariableName [ 
	class := self classObjectFor: aClass.
	selector := aSelector.
	temporaryVariableName := aVariableName
]

{ #category : #preconditions }
RBTemporaryToInstanceVariableRefactoring >> preconditions [
	^(RBCondition definesSelector: selector in: class)
		& (RBCondition definesInstanceVariable: temporaryVariableName asString in: class) not
		& (RBCondition withBlock: [ 
			(class allSubclasses anySatisfy: 
				[ :cls | cls definesInstanceVariable: temporaryVariableName asString ])
			ifTrue: [ self refactoringWarning: 
				('One or more subclasses of <1p> already defines an<n>instance variable with the same name. Proceed anyway?' expandMacrosWith: class name) ].
			true ])
			& (RBCondition withBlock: 
						[self checkForValidTemporaryVariable.
						true])
]

{ #category : #removing }
RBTemporaryToInstanceVariableRefactoring >> removeTemporaryOfClass: aClass [
	aClass selectors do: [ :aSymbol | self removeTemporaryOfMethod: aSymbol in: aClass ]
]

{ #category : #removing }
RBTemporaryToInstanceVariableRefactoring >> removeTemporaryOfMethod: aSelector in: aClass [ 

	| parseTree matcher method |
	method := aClass methodFor: aSelector.
	parseTree := method parseTree.
	parseTree ifNil: [ self refactoringFailure: 'Could not parse method' ].
	( matcher := self parseTreeRewriterClass removeTemporaryNamed: temporaryVariableName )
		executeTree: parseTree.
	method compileTree: matcher tree.
]

{ #category : #printing }
RBTemporaryToInstanceVariableRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' class: '.
	class storeOn: aStream.
	aStream
		nextPutAll: ' selector: #';
		nextPutAll: selector;
		nextPutAll: ' variable: ''';
		nextPutAll: temporaryVariableName;
		nextPut: $'.
	aStream nextPut: $)
]

{ #category : #transforming }
RBTemporaryToInstanceVariableRefactoring >> transform [

	self removeTemporaryOfClass: class.
	class allSubclasses do: [ :cls | 
		(cls definesInstanceVariable: temporaryVariableName) 
			ifTrue: [ cls removeInstanceVariable: temporaryVariableName ]
			ifFalse: [ self removeTemporaryOfClass: cls ] ].
	class addInstanceVariable: temporaryVariableName.
	
]
