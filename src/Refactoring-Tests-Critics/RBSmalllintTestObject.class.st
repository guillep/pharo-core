"
This class is used to test method critics.
"
Class {
	#name : #RBSmalllintTestObject,
	#superclass : #RBSmalllintTestSuperclassObject,
	#instVars : [
		'temporaryVariable'
	],
	#category : #'Refactoring-Tests-Critics'
}

{ #category : #'accessing - good' }
RBSmalllintTestObject >> abstractUnaryAccessingMethodWithoutReturn [
	"shouldn't trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	self subclassResponsibility
]

{ #category : #methods }
RBSmalllintTestObject >> anySatisfy [
	^((1 to: 10) detect: [:each | each > 2] ifNone: [nil]) isNil
]

{ #category : #methods }
RBSmalllintTestObject >> asOrderedCollectionNotNeeded [
	self foo addAll: (1 to: 10) asOrderedCollection
]

{ #category : #methods }
RBSmalllintTestObject >> assignmentInBlock [
	[^self printString] ensure: [self close]
]

{ #category : #methods }
RBSmalllintTestObject >> assignmentInIfTrue [
	| variable |
	self isVariable 
		ifTrue: [variable := self]
		ifFalse: [variable := self printString].
	^variable
]

{ #category : #methods }
RBSmalllintTestObject >> assignmentWithoutEffect [
	| a |
	a := 1.
	a := a
]

{ #category : #methods }
RBSmalllintTestObject >> atIfAbsent [
	^ Smalltalk at: #MyTest
		ifAbsent: 
			[| collection |
			collection := #().
			Smalltalk at: #MyTest put: collection]
]

{ #category : #methods }
RBSmalllintTestObject >> badMessage [
	self become: String new
]

{ #category : #methods }
RBSmalllintTestObject >> booleanPrecedence [
	^true & 4 = 45
]

{ #category : #methods }
RBSmalllintTestObject >> codeCruftLeftInMethods [
	<haltOrBreakpointForTesting>
	| a b c |
	a := b := c := 2.
	self halt.
	^ a > 0
		ifTrue: [ b ]
		ifFalse: [ c ]
		
]

{ #category : #methods }
RBSmalllintTestObject >> collectSelectNotUsed [
	(1 to: 10) select: [:each | each = 4]
]

{ #category : #methods }
RBSmalllintTestObject >> collectionAtCollectionSize [
	^self at: self size
]

{ #category : #methods }
RBSmalllintTestObject >> collectionMessagesToExternalObject [
	self someObject collection remove: 10
]

{ #category : #methods }
RBSmalllintTestObject >> collectionProtocol [
	| newCollection |
	newCollection := OrderedCollection new.
	(1 to: 10) asOrderedCollection do: 
			[:each | 
			| new |
			new := each * 2.
			newCollection add: new].
	^newCollection
]

{ #category : #methods }
RBSmalllintTestObject >> consistencyCheck [
	^(1 to: 10) size > 0
]

{ #category : #methods }
RBSmalllintTestObject >> debbuggingMessageSent [
	self rearmOneShot
]

{ #category : #methods }
RBSmalllintTestObject >> detectContains [
	^(1 to: 10) do: [:each | each > 2 ifTrue: [^each]]
]

{ #category : #methods }
RBSmalllintTestObject >> emptyExceptionHandler [
	[ ] on: Error do: [ :err | ]
]

{ #category : #methods }
RBSmalllintTestObject >> endTrueFalse [
	self isVariable 
		ifTrue: 
			[self printString.
			self isVariable printString]
		ifFalse: 
			[self printString.
			^4]
]

{ #category : #methods }
RBSmalllintTestObject >> equalNotUsed [
	| string |
	string = '' yourself.
	(1 to: 10) do: [:i | string := i printString].
	^string
]

{ #category : #methods }
RBSmalllintTestObject >> equalsTrue [
	^true == self
]

{ #category : #methods }
RBSmalllintTestObject >> equivalentSuperclassMethods [
	"comments and formatting are ignored when comparing methods"
	^ (
		self
		identityHash
		).
]

{ #category : #methods }
RBSmalllintTestObject >> extraBlock [
	^[:arg | arg + 43] value: 45
]

{ #category : #methods }
RBSmalllintTestObject >> fileBlocks [
	| file |
	^
	[file := 'asdf' asFileReference readStream.
	file contents] ensure: [file close]
]

{ #category : #methods }
RBSmalllintTestObject >> flagged [
	self flag: #pharoTodo
]

{ #category : #methods }
RBSmalllintTestObject >> floatEqualityComparison [
	^ 1.0 = 1
]

{ #category : #methods }
RBSmalllintTestObject >> fullBlocks [
	^[thisContext]
]

{ #category : #methods }
RBSmalllintTestObject >> guardingClause [
	self isSymbol 
		ifFalse: 
			[self printString.
			self isSymbol printString]
]

{ #category : #methods }
RBSmalllintTestObject >> haltClassMentioned [
	<haltOrBreakpointForTesting>
	Halt now
]

{ #category : #methods }
RBSmalllintTestObject >> ifTrueBlocks [
	^ true ifFalse: self foo
]

{ #category : #methods }
RBSmalllintTestObject >> ifTrueReturns [
	self isSymbol ifFalse: [^true].
	^false
]

{ #category : #methods }
RBSmalllintTestObject >> inlineTemporary [
	| temp |
	self isNil ifTrue: [temp := 4].
	^temp
]

{ #category : #methods }
RBSmalllintTestObject >> justSendsSuper [
	super justSendsSuper
]

{ #category : #methods }
RBSmalllintTestObject >> literalArrayCharacters [
	^#($a $b $c) includes: $a
]

{ #category : #methods }
RBSmalllintTestObject >> literalArrayContainsComma [
	^ #(#,)
]

{ #category : #'accessing - bad' }
RBSmalllintTestObject >> literalArrayContainsSuspiciousTrueFalseOrNil [
	^#(#nil)
]

{ #category : #methods }
RBSmalllintTestObject >> longMethods [
	self printString.
	self printString.
	self printString.
	self printString.
	self printString.
	self printString.
	self printString.
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString]
]

{ #category : #methods }
RBSmalllintTestObject >> minMax [
	"Bug in 3<5 ifTrue: [3]  ifFalse: [5]"

^3<5 ifTrue: [3]  ifFalse: [5]
"	| var |
	var := 4.
	var < 5 ifTrue: [var := 5].
	^var"
]

{ #category : #methods }
RBSmalllintTestObject >> missingYourself [
	^(OrderedCollection new)
		add: 1;
		add: 2;
		removeFirst
]

{ #category : #methods }
RBSmalllintTestObject >> modifiesCollection [
	| collection |
	collection := (1 to: 10) asOrderedCollection.
	collection do: [:each | each > 5 ifTrue: [collection remove: each]].
	^collection
]

{ #category : #methods }
RBSmalllintTestObject >> multiplePeriodsTerminatingAssignmentStatement [
	| strings |

	strings := OrderedCollection..
	strings
		add: 'one';
		add: 'two'.
	^ strings.
	
]

{ #category : #methods }
RBSmalllintTestObject >> multiplePeriodsTerminatingStatement [
	^ self..
]

{ #category : #methods }
RBSmalllintTestObject >> noMoveDefinition [
	| temp |
	^(self collect: 
			[:each | 
			temp := each printString.
			temp , temp]) 
		select: [:each | temp := each size + temp]
]

{ #category : #'accessing - good' }
RBSmalllintTestObject >> nonUnaryAccessingBranchingStatementMethodWithoutReturn: anObject [
	"shouldn't trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	self value isString
		ifTrue: [ self value ]
		ifFalse: [ '' ]
]

{ #category : #'accessing - good' }
RBSmalllintTestObject >> nonUnaryAccessingMessageStatementMethodWithoutReturn: anObject [
	"shouldn't trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	self value
]

{ #category : #'accessing - good' }
RBSmalllintTestObject >> nonUnaryAccessingMethodWithoutReturn: anObject [
	"shouldn't trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	
]

{ #category : #methods }
RBSmalllintTestObject >> onlyReadOrWrittenTemporary [
	| a |
	a := 1
]

{ #category : #methods }
RBSmalllintTestObject >> precedence [
	^self isArray ifFalse: [self block + 5 * 34] ifTrue: [self printString = 10]
]

{ #category : #methods }
RBSmalllintTestObject >> referencesConditionFor: aClass [ 
	| environment association |
	^(RBCondition withBlock: 
			[association := Smalltalk globals associationAt: aClass name
						ifAbsent: [self refactoringError: 'Could not find class'].
			environment := (self environment referencesTo: association) 
						| (self environment referencesTo: aClass name).
			environment isEmpty])
		errorMacro: aClass , ' is referenced.<n>Browse references?';
		errorBlock: [environment openEditor];
		yourself
]

{ #category : #methods }
RBSmalllintTestObject >> refersToClass [
	^ RBSmalllintTestObject
]

{ #category : #methods }
RBSmalllintTestObject >> release [
	self printString
]

{ #category : #methods }
RBSmalllintTestObject >> returnInEnsure [
	[self error: 'asdf'] ensure: [^4]
]

{ #category : #methods }
RBSmalllintTestObject >> returnsBooleanAndOther [
	self isVariable ifTrue: [^false].
	self printString
]

{ #category : #methods }
RBSmalllintTestObject >> returnsIfTrue [
	^self isNil ifTrue: [4]
]

{ #category : #methods }
RBSmalllintTestObject >> searchingLiteral [
	^self printString = #a or: [#() = self printString | ( #() == self printString)]
]

{ #category : #methods }
RBSmalllintTestObject >> sendsDifferentSuper [
	super printString
]

{ #category : #methods }
RBSmalllintTestObject >> shouldntRaiseError [
	self shouldnt: [ 0/1 ] raise: Error
]

{ #category : #methods }
RBSmalllintTestObject >> shouldntRaiseException [
	self shouldnt: [ 0/1 ] raise: Exception
]

{ #category : #methods }
RBSmalllintTestObject >> sizeCheck [
	self isEmpty
		ifFalse: [self do: 
					[:each | 
					]]
]

{ #category : #methods }
RBSmalllintTestObject >> stringConcatenation [
	| string |
	string := '' yourself.
	(1 to: 10) do: [:i | string := string , i printString].
	^string
]

{ #category : #methods }
RBSmalllintTestObject >> tempVarOverridesInstVar [
	| temporaryVariable |
	temporaryVariable := 4.
	^temporaryVariable
]

{ #category : #methods }
RBSmalllintTestObject >> temporaryVariableCapitalization [
	| Capital |
	Capital := 'Bern'.
	^ Capital
]

{ #category : #methods }
RBSmalllintTestObject >> tempsReadBeforeWritten [
	| temp |
	self isVariable ifTrue: [temp := 4].
	^temp
]

{ #category : #methods }
RBSmalllintTestObject >> testMethod1 [
	^self testMethod1 
		, ([:each | each testMethod1] value: #(#(#testMethod1) 2 #testMethod1))
]

{ #category : #methods }
RBSmalllintTestObject >> threeElementPoint [
	^5 @ 5 + 6 @ 6
]

{ #category : #methods }
RBSmalllintTestObject >> toDo [
	1 to: self size do: [:i | (self at: i) printString]
]

{ #category : #methods }
RBSmalllintTestObject >> toDoCollect [
	| array |
	array := Array new: 10.
	1 to: 10 do: [:i | array at: i put: i * i].
	^array
]

{ #category : #methods }
RBSmalllintTestObject >> toDoWithIncrement [
	| counter |
	counter := 0.
	1 to: 10
		by: 2
		do: [:i | counter := counter + 2].
	^counter
]

{ #category : #methods }
RBSmalllintTestObject >> transcriptMentioned [
	self trace: 'message' .
]

{ #category : #'accessing - good' }
RBSmalllintTestObject >> unaryAccessingBranchingStatementMethodWithReturn [
	"shouldn't trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	^ self value isString
		ifTrue: [ self value ]
		ifFalse: [ '' ]
]

{ #category : #'accessing - bad' }
RBSmalllintTestObject >> unaryAccessingBranchingStatementMethodWithoutReturn [
	"should trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	self value isString
		ifTrue: [ self value ]
		ifFalse: [ '' ]
]

{ #category : #'accessing - good' }
RBSmalllintTestObject >> unaryAccessingMessageStatementMethodWithReturn [
	"shouldn't trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	^ self value
]

{ #category : #'accessing - bad' }
RBSmalllintTestObject >> unaryAccessingMessageStatementMethodWithoutReturn [
	"should trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	self value
]

{ #category : #'accessing - good' }
RBSmalllintTestObject >> unaryAccessingMethodWithReturn [
	"shouldn't trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	^ self
]

{ #category : #'accessing - bad' }
RBSmalllintTestObject >> unaryAccessingMethodWithoutReturn [
	"should trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	
]

{ #category : #'non-accessing' }
RBSmalllintTestObject >> unaryNonAccessingBranchingStatementMethodWithoutReturn [
	"shouldn't trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	self value isString
		ifTrue: [ self value ]
		ifFalse: [ '' ]
]

{ #category : #'non-accessing' }
RBSmalllintTestObject >> unaryNonAccessingMessageStatementMethodWithoutReturn [
	"shouldn't trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	self value
]

{ #category : #'non-accessing' }
RBSmalllintTestObject >> unaryNonAccessingMethodWithoutReturn [
	"shouldn't trigger the ReUnaryAccessingMethodWithoutReturnRule rule"

	
]

{ #category : #'as yet unclassified' }
RBSmalllintTestObject >> unclassifiedMethods [
	"intentionally unclassified method"
]

{ #category : #methods }
RBSmalllintTestObject >> uncommonMessageSend [
	true false
]

{ #category : #methods }
RBSmalllintTestObject >> uncommonMessageSend2 [
	|a|
	a:=3
	Object new.
	^ a
]

{ #category : #methods }
RBSmalllintTestObject >> unoptimizedAndOr [
	^ (true and: [ false ]) and: [ true ]
]

{ #category : #methods }
RBSmalllintTestObject >> usesAdd [
	^(1 to: 10) asOrderedCollection addAll: (11 to: 20)
]

{ #category : #methods }
RBSmalllintTestObject >> usesTrue [
	^ True
]

{ #category : #methods }
RBSmalllintTestObject >> variableAssignedLiteral [
	temporaryVariable := #() 
]

{ #category : #methods }
RBSmalllintTestObject >> whileTrue [
	| i |
	i := 1.
	[i < self size] whileTrue: 
			[(self at: i) printString.
			i := i + 1]
]

{ #category : #methods }
RBSmalllintTestObject >> yourselfNotUsed [
	self
		printString;
		printString;
		yourself
]
