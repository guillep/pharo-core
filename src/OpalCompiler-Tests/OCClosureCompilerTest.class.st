Class {
	#name : #OCClosureCompilerTest,
	#superclass : #TestCase,
	#instVars : [
		'currentCompiler'
	],
	#category : #'OpalCompiler-Tests-FromOld'
}

{ #category : #accessing }
OCClosureCompilerTest class >> compilerClass [
	^OpalCompiler
]

{ #category : #'code examples' }
OCClosureCompilerTest class >> methodWithCopiedAndAssignedTemps [
	| blk "0w" a "0w" b "0w" c "0w" t "0w" r1 "0w" r2 "0w" |
	a := 1. "1w"
	b := 2. "1w"
	c := 4. "1w"
	t := 0. "1w"
	blk "5w" := ["2" t  "3w" := t "3r" + a "3r" + b "3r" + c "3r" ] "4".
	r1 "5w" := blk "5r" value.
	b "5w" := -100.
	r2 "5w" := blk "5r" value.
	^r1 "5r" -> r2 "5r" -> t "5r"

	"a: main(read(),write(0,1)), block(read(3),write()) => copy; no writes follow read
	 b: main(read(),write(0,1,5)), block(read(3),write()) => remote; write follows contained read
	 blk: main(read(5),write(0,5)), block(read(),write()) => no copy in blocks < 5
	 c: main(read(),write(0,1)), block(read(3),write()) => copy; no writes follow read
	 r1: main(read(5),write(0,5)), block(read(),write()) => no copy in blocks < 5
	 r2: main(read(5),write(0,5)), block(read(),write()) => no copy in blocks < 5
	 t: main(read(5),write(0,1)), block(read(3),write(3)) => remote; read follows contained write"


	"(Parser new
		encoderClass: EncoderForV3;
		parse: (self class sourceCodeAt: #methodWithCopiedAndAssignedTemps)
		class: self class) generateUsingClosures: #(0 0 0 0)"
]

{ #category : #'code examples' }
OCClosureCompilerTest class >> methodWithCopiedAndPostClosedOverAssignedTemps [
	| blk a b c r1 r2 |
	a := 1.
	b := 2.
	c := 4.
	blk := [a + b + c].
	r1 := blk value.
	b := nil.
	r2 := blk value.
	r1 -> r2

	"(Parser new
		encoderClass: EncoderForV3;
		parse: (self class sourceCodeAt: #methodWithCopiedAndPostClosedOverAssignedTemps)
		class: self class) generateUsingClosures: #(0 0 0 0)"
]

{ #category : #'code examples' }
OCClosureCompilerTest class >> methodWithCopiedTemps [
	| a b c r |
	a := 1.
	b := 2.
	c := 4.
	r := [a + b + c] value.
	b := nil.
	r

	"Parser new
		parse: (self class sourceCodeAt: #methodWithCopiedTemps)
		class: self class"

	"(Parser new
		encoderClass: EncoderForV3;
		parse: (self class sourceCodeAt: #methodWithCopiedTemps)
		class: self class) generateUsingClosures: #(0 0 0 0)"
]

{ #category : #'code examples' }
OCClosureCompilerTest class >> methodWithOptimizedBlocks [
	| s c |
	s := self isNil
			ifTrue: [| a | a := 'isNil'. a]
			ifFalse: [| b | b := 'notNil'. b].
	c := String new: s size.
	1 to: s size do:
		[:i| c at: i put: (s at: i)].
	^c

	"Parser new
		parse: (self class sourceCodeAt: #methodWithOptimizedBlocks)
		class: self class"
]

{ #category : #'code examples' }
OCClosureCompilerTest class >> methodWithOptimizedBlocksA [
	| s c |
	s := self isNil
			ifTrue: [| a | a := 'isNil'. a]
			ifFalse: [| a | a := 'notNil'. a].
	c := String new: s size.
	1 to: s size do:
		[:i| c at: i put: (s at: i)].
	^c

	"Parser new
		parse: (self class sourceCodeAt: #methodWithOptimizedBlocksA)
		class: self class"
]

{ #category : #'code examples' }
OCClosureCompilerTest class >> methodWithVariousTemps [
	| classes total totalLength |
	classes := self withAllSuperclasses.
	total := totalLength := 0.
	classes do: [:class| | className |
		className := class name.
		total := total + 1.
		totalLength := totalLength + className size].
	^total -> totalLength

	"Parser new
		parse: (self class sourceCodeAt: #methodWithVariousTemps)
		class: self class"
]

{ #category : #source }
OCClosureCompilerTest >> closureCases [
	^#(
'| n |
n := 1.
^n + n'

'[:c :s| | mn |
mn := Compiler new
		compile: (c sourceCodeAt: s)
		in: c
		notifying: nil
		ifFail: [self halt].
mn generate: #(0 0 0 0).
{mn blockExtentsToTempsMap.
  mn encoder schematicTempNames}]
			value: AbstractInstructionTests
			value: #runBinaryConditionalJumps:'

'inject: thisValue into: binaryBlock
	| nextValue |
	nextValue := thisValue.
	self do: [:each | nextValue := binaryBlock value: nextValue value: each].
	^nextValue'

'mapFromBlockStartsIn: aMethod toTempVarsFrom: schematicTempNamesString constructor: aDecompilerConstructor
	| map |
	map := aMethod
				mapFromBlockKeys: aMethod startpcsToBlockExtents keys asSortedCollection
				toSchematicTemps: schematicTempNamesString.
	map keysAndValuesDo:
		[:startpc :tempNameTupleVector| | subMap tempVector numTemps |
		subMap := Dictionary new.
		tempNameTupleVector do:
			[:tuple|
			tuple last isArray
				ifTrue:
					[subMap at: tuple last first put: tuple last last.
					 numTemps := tuple last first]
				ifFalse:
					[numTemps := tuple last]].
		tempVector := Array new: numTemps.
		subMap keysAndValuesDo:
			[:index :size|
			tempVector at: index put: (Array new: size)].
		tempNameTupleVector do:
			[:tuple| | itv |
			tuple last isArray
				ifTrue:
					[itv := tempVector at: tuple last first.
					 itv at: tuple last last
						put: (aDecompilerConstructor
								codeTemp: tuple last last - 1
								named: tuple first)]
				ifFalse:
					[tempVector
						at: tuple last
						put: (aDecompilerConstructor
								codeTemp: tuple last - 1
								named: tuple first)]].
		subMap keysAndValuesDo:
			[:index :size|
			tempVector
				at: index
				put: (aDecompilerConstructor
						codeRemoteTemp: index
						remoteTemps: (tempVector at: index))].
		map at: startpc put: tempVector].
	^map'

 'gnuifyFrom: inFileStream to: outFileStream

	| inData beforeInterpret inInterpret inInterpretVars beforePrimitiveResponse inPrimitiveResponse |

	inData := inFileStream upToEnd withSqueakLineEndings.
	inFileStream close.

	outFileStream
		nextPutAll: ''/* This file has been post-processed for GNU C */'';
		cr; cr; cr.

	beforeInterpret := true.    "whether we are before the beginning of interpret()"
	inInterpret := false.     "whether we are in the middle of interpret"
	inInterpretVars := false.    "whether we are in the variables of interpret"
	beforePrimitiveResponse := true.  "whether we are before the beginning of primitiveResponse()"
	inPrimitiveResponse := false.   "whether we are inside of primitiveResponse"
	''Gnuifying''
		displayProgressAt: Sensor cursorPoint
		from: 1 to: (inData occurrencesOf: Character cr)
		during:
			[:bar | | lineNumber |
			lineNumber := 0.
			inData linesDo:
				[ :inLine | | outLine extraOutLine caseLabel |
				bar value: (lineNumber := lineNumber + 1).
				outLine := inLine. 	"print out one line for each input line; by default, print out the line that was input, but some rules modify it"
				extraOutLine := nil.   "occasionally print a second output line..."
				beforeInterpret ifTrue: [
					inLine = ''#include "sq.h"'' ifTrue: [
						outLine := ''#include "sqGnu.h"'' ].
					inLine = ''interpret(void) {'' ifTrue: [
						"reached the beginning of interpret"
						beforeInterpret := false.
						inInterpret := true.
						inInterpretVars := true ] ]
				ifFalse: [
				inInterpretVars ifTrue: [
					(inLine findString: ''register struct foo * foo = &fum;'') > 0 ifTrue: [
						outLine := ''register struct foo * foo FOO_REG = &fum;'' ].
					(inLine findString: '' localIP;'') > 0 ifTrue: [
						outLine := ''    char* localIP IP_REG;'' ].
					(inLine findString: '' localFP;'') > 0 ifTrue: [
						outLine := ''    char* localFP FP_REG;'' ].
					(inLine findString: '' localSP;'') > 0 ifTrue: [
						outLine := ''    char* localSP SP_REG;'' ].
					(inLine findString: '' currentBytecode;'') > 0 ifTrue: [
						outLine := ''    sqInt currentBytecode CB_REG;'' ].
					inLine isEmpty ifTrue: [
						"reached end of variables"
						inInterpretVars := false.
						outLine := ''    JUMP_TABLE;''.
						extraOutLine := inLine ] ]
				ifFalse: [
				inInterpret ifTrue: [
					"working inside interpret(); translate the switch statement"
					(inLine beginsWith: ''		case '') ifTrue: [
						caseLabel := (inLine findTokens: ''	 :'') second.
						outLine := ''		CASE('', caseLabel, '')'' ].
					inLine = ''			break;'' ifTrue: [
						outLine := ''			BREAK;'' ].
					inLine = ''}'' ifTrue: [
						"all finished with interpret()"
						inInterpret := false ] ]
				ifFalse: [
				beforePrimitiveResponse ifTrue: [
					(inLine beginsWith: ''primitiveResponse('') ifTrue: [
						"into primitiveResponse we go"
						beforePrimitiveResponse := false.
						inPrimitiveResponse := true.
						extraOutLine := ''    PRIM_TABLE;'' ] ]
				ifFalse: [
				inPrimitiveResponse ifTrue: [
					inLine = ''	switch (primitiveIndex) {'' ifTrue: [
						extraOutLine := outLine.
						outLine := ''	PRIM_DISPATCH;'' ].
					inLine = ''	switch (GIV(primitiveIndex)) {'' ifTrue: [
						extraOutLine := outLine.
						outLine := ''	PRIM_DISPATCH;'' ].
					(inLine beginsWith: ''	case '') ifTrue: [
						caseLabel := (inLine findTokens: ''	 :'') second.
						outLine := ''	CASE('', caseLabel, '')'' ].
					inLine = ''}'' ifTrue: [
						inPrimitiveResponse := false ] ]
				] ] ] ].

				outFileStream nextPutAll: outLine; cr.
				extraOutLine ifNotNil: [
					outFileStream nextPutAll: extraOutLine; cr ]]].

	outFileStream close' )
]

{ #category : #tests }
OCClosureCompilerTest >> doTestDebuggerTempAccessWith: one with: two [
	"Test debugger access for temps"

	| outerContext local1 remote1 |
	outerContext := thisContext.
	local1 := 3.
	remote1 := 1 / 2.
	self assert: (self evaluate: 'one' in: thisContext to: self) identicalTo: one.
	self assert: (self evaluate: 'two' in: thisContext to: self) identicalTo: two.
	self assert: (self evaluate: 'local1' in: thisContext to: self) identicalTo: local1.
	self assert: (self evaluate: 'remote1' in: thisContext to: self) identicalTo: remote1.
	self evaluate: 'local1 := -3.0' in: thisContext to: self.
	self assert: local1 equals: -3.0.
	(1 to: 2)
		do: [ :i | 
			| local2 r1 r2 r3 r4 |
			local2 := i * 3.
			remote1 := local2 / 7.
			self assert: thisContext ~~ outerContext.
			self assert: (r1 := self evaluate: 'one' in: thisContext to: self) identicalTo: one.
			self assert: (r2 := self evaluate: 'two' in: thisContext to: self) identicalTo: two.
			self assert: (r3 := self evaluate: 'i' in: thisContext to: self) identicalTo: i.
			self assert: (r4 := self evaluate: 'local2' in: thisContext to: self) identicalTo: local2.
			self assert: (r4 := self evaluate: 'remote1' in: thisContext to: self) identicalTo: remote1.
			self assert: (r4 := self evaluate: 'remote1' in: outerContext to: self) identicalTo: remote1.
			self evaluate: 'local2 := 15' in: thisContext to: self.
			self assert: local2 equals: 15.
			self evaluate: 'local1 := 25' in: thisContext to: self.
			self assert: local1 equals: 25.
			{r1 . r2 . r3 . r4}	"placate the compiler" ].
	self assert: local1 equals: 25.
	"this is 25 even though the var is a local, non escaping variable that was copied into the block.
	But the DoIt compiles temp acces using #tempAt:put:, which updates the copies and the original"
	self assert: remote1 equals: 6 / 7
]

{ #category : #running }
OCClosureCompilerTest >> evaluate: aString in: aContext to: anObject [
	^self class compiler source: aString;
		context: aContext;
		receiver: anObject;
		evaluate
]

{ #category : #running }
OCClosureCompilerTest >> setUp [
	super setUp.
	currentCompiler := SmalltalkImage compilerClass.
	SmalltalkImage compilerClass: OpalCompiler.
]

{ #category : #running }
OCClosureCompilerTest >> tearDown [
	SmalltalkImage compilerClass: currentCompiler.
	super tearDown
]

{ #category : #tests }
OCClosureCompilerTest >> testDebuggerTempAccess [
	self doTestDebuggerTempAccessWith: 1 with: 2
]

{ #category : #tests }
OCClosureCompilerTest >> testInlineBlockCollectionEM1 [
	| a1 b1 i1 a2 b2 i2 we wb |
	b1 := OrderedCollection new.
	i1 := 1.
	[ a1 := i1.
	i1 <= 3 ]
		whileTrue: [ b1 add: [ a1 ].
			i1 := i1 + 1 ].
	b1 := b1 asArray collect: [ :b | b value ].
	b2 := OrderedCollection new.
	i2 := 1.
	we := [ a2 := i2.
	i2 <= 3 ].
	wb := [ b2 add: [ a2 ].
	i2 := i2 + 1 ].
	we whileTrue: wb.	"defeat optimization"
	b2 := b2 asArray collect: [ :b | b value ].
	self assert: b1 equals: b2
]

{ #category : #tests }
OCClosureCompilerTest >> testInlineBlockCollectionLR1 [
	"Test case from Lukas Renggli"

	| col |
	col := OrderedCollection new.
	1 to: 11 do: [ :each | col add: [ each ] ].
	self assert: (col collect: [ :each | each value ]) asArray equals: (1 to: 11) asArray
]

{ #category : #tests }
OCClosureCompilerTest >> testInlineBlockCollectionLR2 [
	"Test case from Lukas Renggli"

	| col |
	col := OrderedCollection new.
	1 to: 11 do: [ :each | #(1) do: [ :ignored | col add: [ each ] ] ].
	self assert: (col collect: [ :each | each value ]) asArray equals: (1 to: 11) asArray
]

{ #category : #tests }
OCClosureCompilerTest >> testInlineBlockCollectionLR3 [
	| col |
	col := OrderedCollection new.
	1 to: 11 do: [ :each | 
		| i |
		i := each.
		col add: [ i ].
		i := i + 1 ].
	self assert: (col collect: [ :each | each value ]) asArray equals: (2 to: 12) asArray
]

{ #category : #tests }
OCClosureCompilerTest >> testInlineBlockCollectionSD1 [
	| a1 b1 a2 b2 |
	b1 := OrderedCollection new.
	1 to: 3 do: [ :i | 
		a1 := i.
		b1 add: [ a1 ] ].
	b1 := b1 asArray collect: [ :b | b value ].
	b2 := OrderedCollection new.
	1 to: 3 do:
		[ :i | 
		a2 := i.
		b2 add: [ a2 ] ] yourself.	"defeat optimization"
	b2 := b2 asArray collect: [ :b | b value ].
	self assert: b1 equals: b2
]

{ #category : #tests }
OCClosureCompilerTest >> testOptimizedBlockLocalNilling1 [
	"Whether a block is optimized or not a block-local temp
	 should be nil at the start of each evaluation of the block."

	1 to: 3 do: [:i| | j |
		self assert: j isNil.
		j := i + 1.
		self assert: j isNil not]
]

{ #category : #tests }
OCClosureCompilerTest >> testOptimizedBlockLocalNilling2 [
	"Whether a block is optimized or not a block-local temp
	 should be nil at the start of each evaluation of the block."

	1 to: 6 do: [:i| | j k |
		self assert: j isNil.
		self assert: k isNil.
		i even
			ifTrue: [j := i + 2]
			ifFalse: [k := i + 1].
		self assert: (j isNil or: [k isNil]).
		self assert: (j isNil not or: [k isNil not])]
]
