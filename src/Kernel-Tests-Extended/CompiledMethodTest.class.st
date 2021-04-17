"
This is the unit test for the class CompiledMethod. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- there is a chapter in the PharoByExample book (http://pharobyexample.org)
	- the sunit class category
"
Class {
	#name : #CompiledMethodTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'x',
		'y'
	],
	#category : #'Kernel-Tests-Extended-Methods'
}

{ #category : #'tests - performing' }
CompiledMethodTest >> a1: a1 a2: a2 a3: a3 a4: a4 a5: a5 a6: a6 a7: a7 a8: a8 a9: a9 a10: a10 a11: a11 a12: a12 a13: a13 a14: a14 a15: a15 [
	"I'm a method with the maximum size of arguments that can be executed via normal send but crash on perform :)"
	
	^ a1 + a2 - a2
]

{ #category : #examples }
CompiledMethodTest >> abstractMethod [
	"I am an abstract method"
	
	^ self subclassResponsibility
]

{ #category : #'private - accessing' }
CompiledMethodTest >> categoryNameForTemporaryClasses [
	"Answer the category where to classify temporarily created classes"

	^'Dummy-Tests-Class'
]

{ #category : #coverage }
CompiledMethodTest >> classToBeTested [
	
	^ CompiledMethod
]

{ #category : #examples }
CompiledMethodTest >> deprecatedMethod [
	"Used to test sends of deprecation messages;
	do not recategorize in one of the 'deprecated' categories."

	self deprecated: 'example of a deprecated method'
]

{ #category : #examples }
CompiledMethodTest >> deprecatedMethod2 [
	"Used to test sends of deprecation messages;
	do not recategorize in one of the 'deprecated' categories."

	self deprecated: 'example of a deprecated method' on: 'date' in: 'someversion'.
]

{ #category : #examples }
CompiledMethodTest >> deprecatedMethod3 [
	"Used to test sends of deprecation messages;
	do not recategorize in one of the 'deprecated' categories."

	self
		deprecated: 'Example of a deprecated method with transform'
		transformWith: '`@receiver deprecatedMethod3' 
						-> '`@receiver deprecatedMethod3'.

]

{ #category : #examples }
CompiledMethodTest >> deprecatedMethod4 [
	"Used to test sends of deprecation messages;
	do not recategorize in one of the 'deprecated' categories."

	self
	
		deprecated: 'Example of a deprecated method with transform'
		on: '01/01/1970'
		in: #Pharo6
		transformWith: '`@receiver deprecatedMethod4' 
						-> '`@receiver deprecatedMethod4'.

]

{ #category : #deprecated }
CompiledMethodTest >> deprecatedMethod5 [
]

{ #category : #'category - deprecated' }
CompiledMethodTest >> deprecatedMethod6 [
]

{ #category : #'deprecated - category' }
CompiledMethodTest >> deprecatedMethod7 [
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locComplex [

	"A multiline
	comment"
	
"Non-indented Comment"
	
	| a b |
	a := 1.
	b :=
	a + 2.
	
	10 timesRepeat: [ 
		"Comment inside a block"
		#(1 2 3) collect: [ :each |
			| c |
			c := each + b.
			c "Comment at the end of a line" ] ].
	

]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locEmptyLineInTheEnd [
	| a |
	a := 1.
	^ a

]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locEmptyLineInTheMiddle [
	| a |
	a := 1.

	^ a
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locEmptyLineWithTabInTheEnd [
	| a |
	a := 1.
	^ a
	
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locEmptyLineWithTabInTheMiddle [
	| a |
	a := 1.
	
	^ a
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locEmptyMethod [
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locEmptyMethodWithNewline [

]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locEmptyMethodWithNewlineAndTab [
	
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locMultilineComment [
	^ 1
	"Multiline
	comment"
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locMultilineCommentWithoutWhitespace [
	^ 1
"Multiline
comment
without
whitespaces"
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locMultilineMethodComment [
	"Multiline
	comments"
	^ 1
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locMultilineMethodCommentWithoutWhitespace [
"Comment"
	^ 1
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locSimple [
	| a b c |
	a := 1.
	b := a + 2.
	c := b * 3.
	^ 1 / c
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locSingleLineComment [
	^ 1
	"Comment"
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locSingleLineCommentWithoutWhitespace [
	^ 1
"Comment"
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locSingleLineMethodComment [
	"Comment"
	^ 1
]

{ #category : #'examples - linesofcode' }
CompiledMethodTest >> locSingleLineMethodCommentWithoutWhitespace [
"Comment"
	^ 1
]

{ #category : #examples }
CompiledMethodTest >> nonAbstractMethod [
	"I am not an abstract method"
	
	^ 4 + 5
]

{ #category : #examples }
CompiledMethodTest >> readX [
	| tmp |
	tmp := x.
	^ tmp
]

{ #category : #examples }
CompiledMethodTest >> readXandY [
	
	^ x + y
	
]

{ #category : #examples }
CompiledMethodTest >> returnPlusOne: anInteger [
	^anInteger + 1. 
]

{ #category : #examples }
CompiledMethodTest >> returnTrue [
	^true  
]

{ #category : #examples }
CompiledMethodTest >> shouldNotImplementMethod [
	"I am not an abstract method"
	
	^ self shouldNotImplement
]

{ #category : #running }
CompiledMethodTest >> tearDown [
	RPackage organizer unregisterPackageNamed: self categoryNameForTemporaryClasses.
	super tearDown
]

{ #category : #'tests - instance variable' }
CompiledMethodTest >> testAccessesField [		
	| method |
	method := self class compiledMethodAt: #readX.
	self assert: (method accessesField: 4).
	
	method := self class compiledMethodAt: #readXandY.
	self assert: (method accessesField: 5).
	
	
	"read is not write"
	method := self class compiledMethodAt: #writeX.
	self assert: (method accessesField: 4).
	
	method := self class compiledMethodAt: #writeXandY.
	self assert: (method accessesField: 4).
	
	method := self class compiledMethodAt: #writeXandY.
	self assert: (method accessesField: 5)
]

{ #category : #'tests - slots' }
CompiledMethodTest >> testAccessesSlot [

	"Check the source code availability to do not fail on images without sources"
	({ Point>>#x. Point>>#setX:setY: } allSatisfy: #hasSourceCode) 
		ifFalse: [ ^ self ].
	
	self assert: ((Point>>#x) accessesSlot: (Point slotNamed: #x)).
	self deny: ((Point>>#x) accessesSlot: (Point slotNamed: #y)).
	self assert: ((Point>>#setX:setY:) accessesSlot: (Point slotNamed: #y)).
	
	
]

{ #category : #'tests - converting' }
CompiledMethodTest >> testAsString [

	self assert: thisContext method asString isString
]

{ #category : #'tests - accessing' }
CompiledMethodTest >> testBytecode [
	"The result of this test depends on the used bytecode set. 
	
	 Because there are multiple versions of the encoders currently depending on the compiler used, we test the class name instead of the encoder class itself"
	| method expectedResult |
	method := Object>>#halt.
	expectedResult := (method encoderClass name endsWith: 'SistaV1')
		ifTrue: [#[16 129 216 88]]
		ifFalse: [#[64 209 135 120]].
	self assertCollection: (Object>>#halt) bytecode equals: expectedResult
]

{ #category : #'tests - accessing' }
CompiledMethodTest >> testComments [
	"I am the first comment to be found in this test"
	self
		assert: (CompiledMethodTest >> #testComments) comments first 
	"And I am the second comment to be found in this test"
		equals: 'I am the first comment to be found in this test'.
	self
		assert: (CompiledMethodTest >> #testComments) comments second
		equals: 'And I am the second comment to be found in this test'.
	"Next test assumes #compiledMethod has no comment..."
	self assert: (CompiledMethod >> #compiledMethod) comments isEmpty
]

{ #category : #'tests - accessing' }
CompiledMethodTest >> testComparison [
	| method1 method2 |
	method1 := Float class >> #nan.
	method2 := thisContext method.

	self assert: method1 equals: method1.
	self assert: method2 equals: method2.
	self deny: method1 equals: method2.
	self deny: method2 equals: method1.

	Object methods
		do: [ :each | 
			self deny: method1 equals: each.
			self deny: each equals: method1.
			self deny: method2 equals: each.
			self deny: each equals: method2 ]
]

{ #category : #tests }
CompiledMethodTest >> testCopy [
	<pragma: #pragma>
	| method copy |
	method := thisContext method.
	self assert: method pragmas notEmpty.
	copy := method copy.
	self assert: (method equivalentTo: copy).
	self assert: method header equals: copy header.
	self assert: method equals: copy.
	self assert: method ~~ copy.
	self assert: copy penultimateLiteral method identicalTo: copy.
	self assert: method penultimateLiteral method identicalTo: method.
	method pragmas do: [ :p | self assert: p method identicalTo: method ].
	copy pragmas do: [ :p | self assert: p method identicalTo: copy ]
]

{ #category : #tests }
CompiledMethodTest >> testCopyWithTrailerBytes [
	<pragma: #pragma>
	| method copy |
	method := thisContext method.
	self assert: method pragmas notEmpty.
	copy := method copyWithTrailerBytes: method trailer.
	self assert: (method equivalentTo: copy).
	self deny: method identicalTo: copy.
	self assert: method symbolic equals: copy symbolic.	"but their bytecode should be the same"
	self assert: method ~~ copy.
	self assert: copy penultimateLiteral method identicalTo: copy.
	self assert: method penultimateLiteral method identicalTo: method.
	method pragmas do: [ :p | self assert: p method identicalTo: method ].
	copy pragmas do: [ :p | self assert: p method identicalTo: copy ]
]

{ #category : #'tests - comparing' }
CompiledMethodTest >> testEqualityClassSideMethod [
   	| method1 method2 |

	method1 := TestCase class compiler
			compile: 'aMethod'.
		
	method2 := TestCase class compiler
			compile: 'aMethod'.
			
 	self assert: method1 equals: method2.


]

{ #category : #'tests - comparing' }
CompiledMethodTest >> testEqualityInstanceSideMethod [
	| method1 method2 |
	method1 := TestCase compiler compile: 'aMethod'.
	method2 := TestCase compiler compile: 'aMethod'.

	self assert: (method1 literalAt: method1 numLiterals) identicalTo: (method2 literalAt: method2 numLiterals).
	self assert: method1 equals: method2
]

{ #category : #'tests - testing' }
CompiledMethodTest >> testHasComment [
	self assert: (CompiledMethod>>#hasComment) hasComment
]

{ #category : #'tests - instance variable' }
CompiledMethodTest >> testHasInstVarRef [
		
	| method  |
	method := self class compiledMethodAt: #readX.
	self assert: (method hasInstVarRef).

	method := self class compiledMethodAt: #readXandY.
	self assert: (method hasInstVarRef).
	
	method := self class compiledMethodAt: #writeX.
	self assert: (method hasInstVarRef).
	
	method := self class compiledMethodAt: #writeXandY.
	self assert: (method hasInstVarRef).
	
]

{ #category : #'tests - literals' }
CompiledMethodTest >> testHasLiteralSuchThat [
	"#literals should not expose implementation hack that the last two literals are 
	used for name of method and class"

	self deny: (Object >> #yourself hasLiteralSuchThat: [ :lit | lit == #yourself ]).
	self assert: (Object >> #halt hasLiteralSuchThat: [ :lit | lit == #now ]).
]

{ #category : #'tests - testing' }
CompiledMethodTest >> testHasPragma [

	| methodWithPragma methodWithOutPragma |
	methodWithPragma := (SmallInteger >> #+).
	methodWithOutPragma := thisContext method.
	
	self assert: methodWithPragma hasPragma.
	self deny: methodWithOutPragma hasPragma
]

{ #category : #'tests - abstract' }
CompiledMethodTest >> testIsAbstract [

	self assert: (self class >> #abstractMethod) isAbstract.
	self deny: (self class >> #nonAbstractMethod) isAbstract.
	self deny: (self class >> #shouldNotImplementMethod) isAbstract
]

{ #category : #'tests - testing' }
CompiledMethodTest >> testIsDeprecated [
	| deprecatedSelectors |
	deprecatedSelectors := #(deprecatedMethod deprecatedMethod2 deprecatedMethod3 deprecatedMethod4 deprecatedMethod5 deprecatedMethod6 deprecatedMethod7).
	self class selectorsDo: [ :each |
		(deprecatedSelectors includes: each)
			ifTrue: [ self assert: (self class >> each) isDeprecated ]
			ifFalse: [ self deny: (self class >> each) isDeprecated ] ].

	DeprecatedClassForTest selectorsDo: [ :each | self assert: (DeprecatedClassForTest >> each) isDeprecated ]
]

{ #category : #'tests - testing' }
CompiledMethodTest >> testIsFaulty [
	|  cm |
	cm := OpalCompiler new
				source: 'method 3+';
				options: #(+ optionParseErrors +optionEmbeddSources);
				compile.
	self assert: cm isFaulty.
	self deny: (OCASTTranslator>>#visitParseErrorNode:) isFaulty
]

{ #category : #'tests - testing' }
CompiledMethodTest >> testIsInstalled [
|  method cls |

	method := (self class)>>#returnTrue.
	self assert: method isInstalled.

	

	Smalltalk removeClassNamed: #TUTU.

	cls := self class classInstaller make: [ :aBuilder | 
		aBuilder 
			name: #TUTU;
			package: self categoryNameForTemporaryClasses].

	cls compile: 'foo ^ 10'.
	method := cls >> #foo.

	"now make an orphaned method by just deleting the method."
	cls removeSelector: #foo.
	
	self deny: method isInstalled. 
	Smalltalk removeClassNamed: #TUTU.
]

{ #category : #'tests - testing' }
CompiledMethodTest >> testIsQuick [
	| method  |

	method := self class compiledMethodAt: #returnTrue.
	self assert: (method isQuick).

	method := self class compiledMethodAt: #returnPlusOne:.
	self deny: (method isQuick).

	
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeAllInOne [
	| method |
	method := self class >> #locComplex.
	self assert: method linesOfCode equals: 14.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeEmptyLineInTheEnd [
	| method |
	method := self class >> #locEmptyLineInTheEnd.
	self assert: method linesOfCode equals: 4.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeEmptyLineInTheMiddle [
	| method |
	method := self class >> #locEmptyLineInTheMiddle.
	self assert: method linesOfCode equals: 4.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeEmptyLineWithTabInTheEnd [
	| method |
	method := self class >> #locEmptyLineWithTabInTheEnd.
	self assert: method linesOfCode equals: 4.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeEmptyLineWithTabInTheMiddle [
	| method |
	method := self class >> #locEmptyLineWithTabInTheMiddle.
	self assert: method linesOfCode equals: 4.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeEmptyMethod [
	| method |
	method := self class >> #locEmptyMethod.
	self assert: method linesOfCode equals: 1.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeEmptyMethodWithNewline [
	| method |
	method := self class >> #locEmptyMethodWithNewline.
	self assert: method linesOfCode equals: 1.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeEmptyMethodWithNewlineAndTab [
	| method |
	method := self class >> #locEmptyMethodWithNewlineAndTab.
	self assert: method linesOfCode equals: 1.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeMultilineComment [
	| method |
	method := self class >> #locMultilineComment.
	self assert: method linesOfCode equals: 4.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeMultilineCommentWithoutWhitespace [
	| method |
	method := self class >> #locMultilineCommentWithoutWhitespace.
	self assert: method linesOfCode equals: 6.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeMultilineMethodComment [
	| method |
	method := self class >> #locMultilineMethodComment.
	self assert: method linesOfCode equals: 4.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeMultilineMethodCommentWithoutWhitespace [
	| method |
	method := self class >> #locMultilineMethodCommentWithoutWhitespace.
	self assert: method linesOfCode equals: 3.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeSimpleCase [
	| method |
	method := self class >> #locSimple.
	self assert: method linesOfCode equals: 6.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeSingleLineComment [
	| method |
	method := self class >> #locSingleLineComment.
	self assert: method linesOfCode equals: 3.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeSingleLineCommentWithoutWhitespace [
	| method |
	method := self class >> #locSingleLineCommentWithoutWhitespace.
	self assert: method linesOfCode equals: 3.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeSingleLineMethodComment [
	| method |
	method := self class >> #locSingleLineMethodComment .
	self assert: method linesOfCode equals: 3.
]

{ #category : #'tests - linesofcode' }
CompiledMethodTest >> testLinesOfCodeSingleLineMethodCommentWithoutWhitespace [
	| method |
	method := self class >> #locSingleLineMethodCommentWithoutWhitespace.
	self assert: method linesOfCode equals: 3.
]

{ #category : #'tests - literals' }
CompiledMethodTest >> testLiterals [
	"#literals should not expose implementation hack that the last two literals are 
	used for name of method and class"

	self assertEmpty: (Object >> #yourself) literals.
	self assert: (Object >> #yourself) allLiterals size equals: 2.
	self deny: (Object >> #yourself hasLiteral: #yourself)
]

{ #category : #'tests - accessing' }
CompiledMethodTest >> testMethodClass [
	| method cls |
	method := self class >> #returnTrue.
	self assert: method selector equals: #returnTrue.
	"now make an orphaned method by just deleting the class.
	old: #unknown
	new semantics: return Absolete class"
	Smalltalk removeClassNamed: #TUTU.

	cls := self class classInstaller make: [ :aBuilder | 
		aBuilder 
			name: #TUTU;
			package: self categoryNameForTemporaryClasses].

	cls compile: 'foo ^ 10'.
	method := cls >> #foo.
	Smalltalk removeClassNamed: #TUTU.
	self assert: method methodClass equals: cls
]

{ #category : #'tests - comparing' }
CompiledMethodTest >> testMethodsThatHaveOnlyDifferentSelectorsShouldBeDifferent [
	| method1 method2 |
	method1 := TestCase compiler compile: 'aMethod'.
	method2 := TestCase compiler compile: 'aMethod2'.

	self assert: (method1 literalAt: method1 numLiterals) identicalTo: (method2 literalAt: method2 numLiterals).
	self deny: method1 equals: method2
]

{ #category : #'tests - accessing' }
CompiledMethodTest >> testOrigin [
	| regularMethod methodFromTrait |
	"Regular method"
	regularMethod := Behavior >> #name.

	"Method from a trait without alias "
	methodFromTrait := Behavior >> #adoptInstance:.

	self assert: regularMethod origin identicalTo: regularMethod originMethod methodClass.
	self assert: methodFromTrait origin identicalTo: methodFromTrait originMethod methodClass
]

{ #category : #'tests - performing' }
CompiledMethodTest >> testPerformCanExecutelongMethodWithTemps [	
	"the perform: primitive reuses the context of the method calling it. The primitive adds performed selector arguments to the context variables list. So this means that you can execute some methods but not performed them if the calling methods defined too many temps "
	
	| temp1 temp2 temp3 |
	temp1 := 33.
	temp2 := 666.
	temp3 := 42. 
	self assert: (self perform: #a1:a2:a3:a4:a5:a6:a7:a8:a9:a10:a11:a12:a13:a14:a15: withArguments: #(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)) equals: 1.
	self assert: (self class>>#testPerformCanExecutelongMethodWithTemps) frameSize equals: CompiledMethod smallFrameSize.
	self assert: (self class>>#a1:a2:a3:a4:a5:a6:a7:a8:a9:a10:a11:a12:a13:a14:a15:) frameSize equals: CompiledMethod fullFrameSize.
]

{ #category : #'tests - performing' }
CompiledMethodTest >> testPerformInSuperclassCanExecutelongMethodWithTemps [	
	"the perform: primitive reuses the context of the method calling it. The primitive adds performed selector arguments to the context variables list. So this means that you can execute some methods but not performed them if the calling methods defined too many temps "
	
	| temp1 temp2 temp3 |
	temp1 := 33.
	temp2 := 666.
	temp3 := 42. 
	self assert: (self perform: #a1:a2:a3:a4:a5:a6:a7:a8:a9:a10:a11:a12:a13:a14:a15: withArguments: #(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15) inSuperclass: self class) equals: 1
]

{ #category : #'tests - pragmas' }
CompiledMethodTest >> testPragmaAt [

	| method |
	method := (SmallInteger >> #+) copy.
	self
		assert: (method pragmaAt: #primitive:) selector
		equals: #primitive:.
	self assert: (method pragmaAt: #hello) equals: nil.
	method propertyAt: #hello put: true.
	"Pragmas are not Properties!"
	self assert: (method pragmaAt: #hello) equals: nil
]

{ #category : #'tests - instance variable' }
CompiledMethodTest >> testReadsField [		
	| method |
	method := self class compiledMethodAt: #readX.
	self assert: (method readsField: 4).
	
	method := self class compiledMethodAt: #readXandY.
	self assert: (method readsField: 5).
	
	
	"read is not write"
	method := self class compiledMethodAt: #writeX.
	self deny: (method readsField: 4).
	
	method := self class compiledMethodAt: #writeXandY.
	self deny: (method readsField: 4).
	
	method := self class compiledMethodAt: #writeXandY.
	self deny: (method readsField: 5)
]

{ #category : #'tests - slots' }
CompiledMethodTest >> testReadsSlot [

	"Check the source code availability to do not fail on images without sources"
	({ Point>>#x. Point>>#setX:setY: } allSatisfy: #hasSourceCode) 
		ifFalse: [ ^ self ].

	self assert: ((Point>>#x) readsSlot: (Point slotNamed: #x)).
	self deny: ((Point>>#x) readsSlot: (Point slotNamed: #y)).
	self deny: ((Point>>#setX:setY:) readsSlot: (Point slotNamed: #y)).
	
	
]

{ #category : #'tests - accessing' }
CompiledMethodTest >> testSelector [
	Author
		useAuthor: 'TUTU_TEST'
		during: [ | method cls |
			method := self class >> #returnTrue.
			self assert: method selector equals: #returnTrue.

			"now make an orphaned method. new semantics: return corrent name"
			Smalltalk removeClassNamed: #TUTU.

			cls := self class classInstaller make: [ :aBuilder | 
				aBuilder 
					name: #TUTU;
					package: self categoryNameForTemporaryClasses].

			cls compile: 'foo ^ 10'.

			method := cls >> #foo.

			Smalltalk removeClassNamed: #TUTU.

			self assert: method selector equals: #foo ]
]

{ #category : #'tests - testing' }
CompiledMethodTest >> testSendsSelector [
	self assert: ((CompiledCode >> #sendsSelector:) sendsSelector: #includes:).
	self deny: ((CompiledCode >> #sendsSelector:) sendsSelector: #doBreakfastForMe)
]

{ #category : #'tests - testing' }
CompiledMethodTest >> testUsesUndeclareds [
	| method |
	method := self class compiler compile: 'x ^x'.
	self deny: method usesUndeclareds.
	method := self class compiler compile: 'z ^z'.
	self assert: method usesUndeclareds.
	method := self class compiler compile: 'msg self in: [ :anObject | var1 := 1 ]'.
	self assert: method usesUndeclareds.
]

{ #category : #'tests - evaluating' }
CompiledMethodTest >> testValueWithReceiverArguments [
	
	| method value |

	method := self class compiledMethodAt: #returnTrue.

	value := method valueWithReceiver: nil arguments: #().
	self assert: value equals: true.

	method := self class compiledMethodAt: #returnPlusOne:.
	value := method valueWithReceiver: nil arguments: #(1).
	self assert: value equals: 2.	
]

{ #category : #'tests - instance variable' }
CompiledMethodTest >> testWritesField [	
	| method |
	method := self class compiledMethodAt: #writeX.
	self assert: (method writesField: 4).
	
	method := self class compiledMethodAt: #writeXandY.
	self assert: (method writesField: 4).
	
	method := self class compiledMethodAt: #writeXandY.
	self assert: (method writesField: 5).
	
	"write is not read"
	
	method := self class compiledMethodAt: #readX.
	self deny: (method writesField: 4).
	
	method := self class compiledMethodAt: #readXandY.
	self deny: (method writesField: 4).
	
	method := self class compiledMethodAt: #readXandY.
	self deny: (method writesField: 5).
]

{ #category : #'tests - slots' }
CompiledMethodTest >> testWritesSlot [

	"Check the source code availability to do not fail on images without sources"
	({ Point>>#x. Point>>#setX:setY: } allSatisfy: #hasSourceCode) 
		ifFalse: [ ^ self ].

	self deny: ((Point>>#x) writesSlot: (Point slotNamed: #x)).
	self deny: ((Point>>#x) writesSlot: (Point slotNamed: #y)).
	
	self assert: ((Point>>#setX:setY:) writesSlot: (Point slotNamed: #y)).
	self assert: ((Point>>#setX:setY:) writesSlot: (Point slotNamed: #x)).
	
]

{ #category : #examples }
CompiledMethodTest >> writeX [
	
	x := 33
	
]

{ #category : #examples }
CompiledMethodTest >> writeXandY [
	
	x := 33.
	y := 66
	
]
