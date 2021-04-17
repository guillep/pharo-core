"
I am a refactoring for find occurrences of a method in owner class and in the whole hierarchy if apply.

My precondition verifies that the method exists in specified class, and if occurrences are found in hierarchy this method should not overwritten in hierarchy.

Example script
----------------

```
(RBFindAndReplaceRefactoring 
find: #methodWithArg:andArg: 
of: MyClassA 
inWholeHierarchy: true) execute.
```
Before refactoring:
```
Object subclass: #MyClassA
	instanceVariableNames: ''
	classVariableNames: ''
	category: 'Testing'

MyClassA >> methodWithArg: anArg1 andArg: anArg2
	^ (anArg1 > anArg2) not	

MyClassA subclass: #MyClassB
	instanceVariableNames: ''
	classVariableNames: ''
	category: 'Testing'
	
MyClassB >> someMethod
	^  3
	
MyClassB >> dummyMethod
	(3 > self someMethod) not
```

After refactoring:

```
MyClassB >> dummyMethod 
	self methodWithArg: 3 andArg: self someMethod
```
"
Class {
	#name : #RBFindAndReplaceRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'method',
		'selector',
		'replacesAllHierarchy',
		'matchNodes',
		'occurrences'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBFindAndReplaceRefactoring class >> find: aMethod of: aClass inWholeHierarchy: aBoolean [
	^ self new 
		find: aMethod 
		of: aClass
		inWholeHierarchy: aBoolean;
		yourself
]

{ #category : #'instance creation' }
RBFindAndReplaceRefactoring class >> model: aModel find: aMethod of: aClass inWholeHierarchy: aBoolean [
	^ self new
		model: aModel; 
		find: aMethod 
		of: aClass
		inWholeHierarchy: aBoolean;
		yourself
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> argumentsOf: aDictionary [
	"Return the arguments values of a method ocurrence"
	
	|args limit|
	limit := self method ast arguments size - 1.
	args := OrderedCollection new.
	0 to: limit do: [ :each |
		args add: 
			(aDictionary at: (aDictionary keys detect: 
				[ :e | (e name asString) =  ('`@argMatch', each asString)])) sourceCode
	 ].
	^ args
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> extract: occurrence of: rbMethod [
	[|refactoring |
	refactoring := self extractMethodRefactoring. 
	refactoring model: self model.
	refactoring 	extract: occurrence key from: rbMethod selector in: rbMethod modelClass.
	refactoring setOption: #existingSelector toUse:  [ :ref | 
			ref parameters: (self argumentsOf: occurrence value).
			selector].
	self performCompositeRefactoring: refactoring ] on: Exception do: [ :e | e ]
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> extractMethodRefactoring [
	^ RBExtractMethodRefactoring new
			setOption: #useExistingMethod 
			toUse:  [ :ref :aSelector | 
				true];
			yourself 
]

{ #category : #initialization }
RBFindAndReplaceRefactoring >> find: aSelector of: aClass inWholeHierarchy: aBoolean [
	class := self classObjectFor: aClass.
	selector := aSelector.
	replacesAllHierarchy := aBoolean.
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> findAndReplaceOccurrencesIn: rbMethod [ 
	self findOccurrencesIn: rbMethod
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> findOccurrencesIn: rbMethod [
	|methodNode sourceCode flag |
	flag := false.
	methodNode := rbMethod ast.
	sourceCode := methodNode sourceCode.
	(self nodesOf: methodNode) do: [ :each |
            each first < each last
                ifTrue: [ 
	self matchNodes do: [ :matchNode | matchNode
                      match: (self patternParserClass parseExpression: (sourceCode copyFrom: each first to: each last ))
                      onSuccess: [ :map |
	self extract: ((each first to: each last) -> map) 
	of: rbMethod.
	occurrences := occurrences + 1.
	flag := true. ]
                      onFailure: [  ] .
						flag ifTrue: [ self findOccurrencesIn: (rbMethod modelClass methodFor: rbMethod selector).
							^ self]]]]. 
	methodNode body nodesDo: [ :node |
		self matchNodes do: [ :matchNode | matchNode
                      match: node
                      onSuccess: [ :map |
	self extract: ((node start to: node stop) -> map) 
	of: rbMethod.
	occurrences := occurrences + 1.
	flag := true.]
                      onFailure: [  ] .
						flag ifTrue: [ self findOccurrencesIn: (rbMethod modelClass methodFor: rbMethod selector).
							^ self]]].
]

{ #category : #initialization }
RBFindAndReplaceRefactoring >> initialize [ 
	super initialize.
	occurrences := 0.
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> matchNodes [

	^ matchNodes ifNil: [ 
		  | visitor node sourceCode |
		  visitor := RBMatchVisitor new.
		  node := self methodNode.
		  node acceptVisitor: visitor.
		  sourceCode := self replaceArgumentsByPattern: node newSource.
		  sourceCode := sourceCode
			                copyFrom: (self startLimitOf: sourceCode) + visitor difference
			                to: sourceCode size.
		  matchNodes := OrderedCollection new.
		  matchNodes add:
			  (self patternParserClass parseExpression: sourceCode).
		  node lastIsReturn ifTrue: [ 
			  node hasMultipleReturns ifFalse: [ 
				  sourceCode := sourceCode copyReplaceAll: '^' with: ''.
				  matchNodes add:
					  (self patternParserClass parseExpression: sourceCode) ] ].
		  matchNodes ]
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> method [
	^ method ifNil: [ method := class methodFor: selector ]
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> methodNode [

	^ self method ast copy
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> nodesOf: methodNode [
	|visitor node|
	visitor := RBCombinatorVisitor new.
	node := methodNode copy.
	node acceptVisitor: visitor.
	^ visitor combinations 
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> patternParserClass [
	^ RBPatternParser 
]

{ #category : #preconditions }
RBFindAndReplaceRefactoring >> preconditions [

	| condition rbMethod |

	rbMethod := class methodFor: selector.
	condition := (RBCondition definesSelector: selector in: class)
	             & (replacesAllHierarchy
			              ifFalse: [ self emptyCondition ]
			              ifTrue: [ 
				              class allSubclasses
					              inject: self emptyCondition
					              into: [ :cond :aClass | 
						              cond
						              &
						              (RBCondition definesSelector: selector in: aClass orIsSimilarTo: rbMethod)
							              not ] ]).
	^ condition
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> replaceArgumentsByPattern: sourceCode [ 
	|newSource|
	newSource := sourceCode copyWithRegex: 'tempMatch*' matchesReplacedWith: '`@tempMatch' .
	newSource := newSource copyWithRegex: 'argMatch*' matchesReplacedWith: '`@argMatch'.
	^ newSource 
	
]

{ #category : #preconditions }
RBFindAndReplaceRefactoring >> selectorsFor: cls [
	^ cls selectors copyWithout: selector
]

{ #category : #accessing }
RBFindAndReplaceRefactoring >> startLimitOf: sourceCode [
	^ self method ast body statements first start
]

{ #category : #printing }
RBFindAndReplaceRefactoring >> storeOn: aStream [
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' find: #';
		nextPutAll: selector;
		nextPutAll: ' of: #';
		nextPutAll: class name;
		nextPutAll: ' inAllHierarchy: '.
	replacesAllHierarchy storeOn: aStream.
	aStream nextPut: $).
]

{ #category : #preconditions }
RBFindAndReplaceRefactoring >> transform [
	|classes|
	classes :=replacesAllHierarchy ifFalse: [ { class } ] ifTrue: [ class withAllSubclasses ].
	classes do: [ :cls | (self selectorsFor: cls) do: [ :sel | |rbMethod|
		rbMethod := cls methodFor: sel.
		self findAndReplaceOccurrencesIn: rbMethod] ].
	self inform: occurrences asString, ' occurrences were found and changed.'
]
