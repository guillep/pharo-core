Class {
	#name : #RBRefactoryTestDataApp,
	#superclass : #Object,
	#instVars : [
		'temporaryVariable'
	],
	#category : #'Refactoring-Tests-Core-Data'
}

{ #category : #lint }
RBRefactoryTestDataApp >> asOrderedCollectionNotNeeded [
	self foo addAll: (1 to: 10) asOrderedCollection
]

{ #category : #lint }
RBRefactoryTestDataApp >> assignmentInBlock [
	[^self printString] ensure: [self close]
]

{ #category : #lint }
RBRefactoryTestDataApp >> assignmentInIfTrue [
	| variable |
	self isVariable 
		ifTrue: [variable := self]
		ifFalse: [variable := self printString].
	^variable
]

{ #category : #lint }
RBRefactoryTestDataApp >> atIfAbsent [
	^ Smalltalk at: #MyTest
		ifAbsent: 
			[| collection |
			collection := #().
			Smalltalk at: #MyTest put: collection]
]

{ #category : #lint }
RBRefactoryTestDataApp >> badMessage [
	self become: String new
]

{ #category : #lint }
RBRefactoryTestDataApp >> booleanPrecedence [
	^true & 4 = 45
]

{ #category : #tests }
RBRefactoryTestDataApp >> callFoo [
	^self testFoo: 5
]

{ #category : #tests }
RBRefactoryTestDataApp >> callMethod [
	^self renameThisMethod: 5
]

{ #category : #inline }
RBRefactoryTestDataApp >> called: anObject on1: aBlock [ 
	| each |
	each := anObject printString.
	self traceCr: each .
	aBlock value: each
]

{ #category : #inline }
RBRefactoryTestDataApp >> called: anObject on: aBlock [ 
	self traceCr: anObject printString .
	aBlock value
]

{ #category : #inline }
RBRefactoryTestDataApp >> caller [
	| anObject |
	anObject := 5.
	self 
		called: anObject + 1
		on: [^anObject]
]

{ #category : #inline }
RBRefactoryTestDataApp >> caller1 [
	| anObject |
	anObject := 5.
	self called: anObject + 1
		on1: 
			[:each | 
			each printString.
			^anObject]
]

{ #category : #inline }
RBRefactoryTestDataApp >> caller2 [
	^(1 to: 10) inject: 1 into: [:sum :each | sum * (self foo: each)]
]

{ #category : #lint }
RBRefactoryTestDataApp >> collectSelectNotUsed [
	(1 to: 10) select: [:each | each = 4]
]

{ #category : #lint }
RBRefactoryTestDataApp >> collectionMessagesToExternalObject [
	self someObject collection remove: 10
]

{ #category : #lint }
RBRefactoryTestDataApp >> collectionProtocol [
	| newCollection |
	newCollection := OrderedCollection new.
	(1 to: 10) asOrderedCollection do: 
			[:each | 
			| new |
			new := each * 2.
			newCollection add: new].
	^newCollection
]

{ #category : #lint }
RBRefactoryTestDataApp >> consistencyCheck [
	^(1 to: 10) size > 0
]

{ #category : #lint }
RBRefactoryTestDataApp >> contains [
	^((1 to: 10) detect: [:each | each > 2] ifNone: [nil]) isNil
]

{ #category : #lint }
RBRefactoryTestDataApp >> cruft [
	<haltOrBreakpointForTesting>
	self halt
]

{ #category : #tests }
RBRefactoryTestDataApp >> demoExampleCall [
	^ self demoRenameMethod: 1 PermuteArgs: 2
]

{ #category : #tests }
RBRefactoryTestDataApp >> demoMethodWithDuplicates [
	| a b result1 result2 answer |
	a := 3.
	b := a + 5.
	result1 := a + b.
	result2 := a + 5.
	answer := result1 + result2 + (a + 5).
	^ answer
]

{ #category : #tests }
RBRefactoryTestDataApp >> demoRenameMethod: arg1 PermuteArgs: arg2 [
	self do: arg1. 
	self do: arg2.
	^ arg1 > arg2
]

{ #category : #lint }
RBRefactoryTestDataApp >> detectContains [
	^(1 to: 10) do: [:each | each > 2 ifTrue: [^each]]
]

{ #category : #lint }
RBRefactoryTestDataApp >> endTrueFalse [
	self isVariable 
		ifTrue: 
			[self printString.
			self isVariable printString]
		ifFalse: 
			[self printString.
			^4]
]

{ #category : #lint }
RBRefactoryTestDataApp >> equalNotUsed [
	| string |
	string = '' yourself.
	(1 to: 10) do: [:i | string := i printString].
	^string
]

{ #category : #lint }
RBRefactoryTestDataApp >> equalsTrue [
	^true == self
]

{ #category : #tests }
RBRefactoryTestDataApp >> exampleCall [
	<sampleInstance>
	^self rename: 1 two: 2
]

{ #category : #lint }
RBRefactoryTestDataApp >> extraBlock [
	^[:arg | arg + 43] value: 45
]

{ #category : #lint }
RBRefactoryTestDataApp >> fileBlocks [
	| file |
	^
	[file := 'asdf' asFileReference readStream.
	file contents] ensure: [file close]
]

{ #category : #inline }
RBRefactoryTestDataApp >> foo: aValue [
	^(1 to: 10) inject: aValue into: [:sum :each | sum + each]
]

{ #category : #lint }
RBRefactoryTestDataApp >> fullBlocks [
	^[thisContext]
]

{ #category : #lint }
RBRefactoryTestDataApp >> guardingClause [
	self isSymbol 
		ifFalse: 
			[self printString.
			self isSymbol printString]
]

{ #category : #lint }
RBRefactoryTestDataApp >> ifTrueReturns [
	self isSymbol ifFalse: [^true].
	^false
]

{ #category : #tests }
RBRefactoryTestDataApp >> inlineBar: aSymbol [
	^aSymbol isSymbol
]

{ #category : #inline }
RBRefactoryTestDataApp >> inlineComponent [
	| a |
	a := 5.
	^a class
		superclass;
		hasImmediateInstances;
		yourself
]

{ #category : #inline }
RBRefactoryTestDataApp >> inlineFailed [
	| x y q |
	x := 5.
	y := 10.
	q := x + 1 fooMax: y.
	^q
]

{ #category : #tests }
RBRefactoryTestDataApp >> inlineFoo: aBlock [ 
	| bar baz asdf |
	bar := aBlock value: self.
	baz := bar + bar.
	asdf := baz + bar.
	^asdf
]

{ #category : #tests }
RBRefactoryTestDataApp >> inlineJunk [
	| asdf |
	asdf := self inlineFoo: 
					[:each | 
					| temp |
					temp := each.
					temp , temp].
	^asdf foo: 
			[:bar | 
			| baz |
			baz := bar.
			baz * baz]
]

{ #category : #inline }
RBRefactoryTestDataApp >> inlineLast [
	5 = 3 ifTrue: [^self caller] ifFalse: [^self caller2]
]

{ #category : #inline }
RBRefactoryTestDataApp >> inlineMax [
	| x y q |
	x := 5.
	y := 10.
	q := x + 1 max: y.
	^q
]

{ #category : #tests }
RBRefactoryTestDataApp >> inlineMethod [
	| temp |
	temp := self
				foo;
				inlineMethod;
				bar.
	^temp
]

{ #category : #tests }
RBRefactoryTestDataApp >> inlineParameterMethod: aSymbol [
	^aSymbol isSymbol
]

{ #category : #inline }
RBRefactoryTestDataApp >> inlineTemporary [
	| temp |
	self isNil ifTrue: [temp := 4].
	^temp
]

{ #category : #lint }
RBRefactoryTestDataApp >> justSendsSuper [
	super justSendsSuper
]

{ #category : #lint }
RBRefactoryTestDataApp >> literalArrayCharacters [
	^#($a $b $c) includes: $a
]

{ #category : #lint }
RBRefactoryTestDataApp >> literalArrayWithTrueFalseOrNil [
	| a b c |
	a := #(true false nil).
	b := #(#true #false #nil).
	c := {true. false. nil}.
	^{a. b. c}
]

{ #category : #lint }
RBRefactoryTestDataApp >> literalArrayWithTrueFalseOrNil2 [
	| b c |
	b := #(#true #false #nil).
	c := #(#true (#true #false #nil) #false #nil).
^b
]

{ #category : #lint }
RBRefactoryTestDataApp >> longMethods [
	self printString.
	self printString.
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString].
	self isVariable ifTrue: [self printString]
]

{ #category : #lint }
RBRefactoryTestDataApp >> minMax [
	"Bug in 3<5 ifTrue: [3]  ifFalse: [5]"

^3<5 ifTrue: [3]  ifFalse: [5]
"	| var |
	var := 4.
	var < 5 ifTrue: [var := 5].
	^var"
]

{ #category : #lint }
RBRefactoryTestDataApp >> missingYourself [
	^(OrderedCollection new)
		add: 1;
		add: 2;
		removeFirst
]

{ #category : #lint }
RBRefactoryTestDataApp >> modifiesCollection [
	| collection |
	collection := (1 to: 10) asOrderedCollection.
	collection do: [:each | each > 5 ifTrue: [collection remove: each]].
	^collection
]

{ #category : #tests }
RBRefactoryTestDataApp >> moveDefinition [
	| temp |
	^(self collect: 
			[:each | 
			temp := each printString.
			temp , temp]) 
		select: 
			[:each | 
			temp := each size.
			temp odd]
]

{ #category : #inline }
RBRefactoryTestDataApp >> multipleCalls [
	self caller2.
	self caller2
]

{ #category : #tests }
RBRefactoryTestDataApp >> noMoveDefinition [
	| temp |
	^(self collect: 
			[:each | 
			temp := each printString.
			temp , temp]) 
		select: [:each | temp := each size + temp]
]

{ #category : #lint }
RBRefactoryTestDataApp >> precedence [
	^self isArray ifFalse: [self block + 5 * 34] ifTrue: [self printString = 10]
]

{ #category : #accessing }
RBRefactoryTestDataApp >> referencesConditionFor: aClass [ 
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

{ #category : #lint }
RBRefactoryTestDataApp >> refersToClass [
	^ RBRefactoryTestDataApp
]

{ #category : #lint }
RBRefactoryTestDataApp >> release [
	self printString
]

{ #category : #tests }
RBRefactoryTestDataApp >> rename: this two: argumentMethod [
	^self printString , this , argumentMethod
]

{ #category : #tests }
RBRefactoryTestDataApp >> renameThisMethod: anArg [
	^self
]

{ #category : #rendering }
RBRefactoryTestDataApp >> renderContentOn: html [
	html
		form: [ html text: 'Name:'.
			html textInput on: #name of: self contact.
			
			
			html break.
			html text: 'Email address:'.
			html textInput on: #emailAddress of: self contact.
			
			html break.
			html text: 'Example:'.
			
			html textInput on: #example of: self contact.
			html break.].
	html text: 'Last:'.
			html textInput on: #last of: self contact.
					html break.
]

{ #category : #lint }
RBRefactoryTestDataApp >> returnInEnsure [
	[self error: 'asdf'] ensure: [^4]
]

{ #category : #lint }
RBRefactoryTestDataApp >> returnsBooleanAndOther [
	self isVariable ifTrue: [^false].
	self printString
]

{ #category : #lint }
RBRefactoryTestDataApp >> returnsIfTrue [
	^self isNil ifTrue: [4]
]

{ #category : #lint }
RBRefactoryTestDataApp >> searchingLiteral [
	^self printString = #a or: [#() = self printString | ( #() == self printString)]
]

{ #category : #tests }
RBRefactoryTestDataApp >> selectorNotReferenced [
	^self selectorNotReferenced + 4
]

{ #category : #tests }
RBRefactoryTestDataApp >> sendInlineBar [
	^ self inlineBar: #example1
]

{ #category : #tests }
RBRefactoryTestDataApp >> sendInlineBar2 [
	^ self inlineBar: 'example2'
]

{ #category : #tests }
RBRefactoryTestDataApp >> sendInlineParameterMethod [
	^self inlineParameterMethod: #(#asdf)
]

{ #category : #lint }
RBRefactoryTestDataApp >> sendsDifferentSuper [
	super printString
]

{ #category : #lint }
RBRefactoryTestDataApp >> sizeCheck [
	self isEmpty
		ifFalse: [self do: 
					[:each | self traceCr: each . ]]
]

{ #category : #lint }
RBRefactoryTestDataApp >> stringConcatenation [
	| string |
	string := '' yourself.
	(1 to: 10) do: [:i | string := string , i printString].
	^string
]

{ #category : #tests }
RBRefactoryTestDataApp >> symbolReference [
	^#(#renameThisMethod: #(4 #renameThisMethod:))
]

{ #category : #lint }
RBRefactoryTestDataApp >> tempVarOverridesInstVar [
	| temporaryVariable |
	temporaryVariable := 4.
	^temporaryVariable
]

{ #category : #lint }
RBRefactoryTestDataApp >> tempsReadBeforeWritten [
	| temp |
	self isVariable ifTrue: [temp := 4].
	^temp
]

{ #category : #tests }
RBRefactoryTestDataApp >> testFoo: anObject [
	^self class + anObject
]

{ #category : #tests }
RBRefactoryTestDataApp >> testMethod [
	^self class
]

{ #category : #tests }
RBRefactoryTestDataApp >> testMethod1 [
	^self testMethod1 
		, ([:each | each testMethod1] value: #(#(#testMethod1) 2 #testMethod1))
]

{ #category : #rendering }
RBRefactoryTestDataApp >> textInput: html name: aString symbol: aSymbol [
	html text: aString.
	html textInput on: aSymbol of: self contact.
	html break
]

{ #category : #lint }
RBRefactoryTestDataApp >> threeElementPoint [
	^5 @ 5 + 6 @ 6
]

{ #category : #lint }
RBRefactoryTestDataApp >> toDo [
	1 to: self size do: [:i | (self at: i) printString]
]

{ #category : #lint }
RBRefactoryTestDataApp >> toDoCollect [
	| array |
	array := Array new: 10.
	1 to: 10 do: [:i | array at: i put: i * i].
	^array
]

{ #category : #lint }
RBRefactoryTestDataApp >> toDoWithIncrement [
	| counter |
	counter := 0.
	1 to: 10
		by: 2
		do: [:i | counter := counter + 2].
	^counter
]

{ #category : #lint }
RBRefactoryTestDataApp >> usesAdd [
	^(1 to: 10) asOrderedCollection addAll: (11 to: 20)
]

{ #category : #lint }
RBRefactoryTestDataApp >> variableAssignedLiteral [
	temporaryVariable := #() 
]

{ #category : #lint }
RBRefactoryTestDataApp >> whileTrue [
	| i |
	i := 1.
	[i < self size] whileTrue: 
			[(self at: i) printString.
			i := i + 1]
]

{ #category : #lint }
RBRefactoryTestDataApp >> yourselfNotUsed [
	self
		printString;
		printString;
		yourself
]
