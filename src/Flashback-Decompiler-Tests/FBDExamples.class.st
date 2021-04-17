"
The method of this class in the protocols named examples are supposed to represent all the possible smalltalk semantics in the point of view of the Decompiler
"
Class {
	#name : #FBDExamples,
	#superclass : #Object,
	#instVars : [
		'iVar',
		'collection'
	],
	#classVars : [
		'CVar'
	],
	#category : #'Flashback-Decompiler-Tests-Examples'
}

{ #category : #examples }
FBDExamples class >> superCallInBlock [

	^ [ super yourself ] value

]

{ #category : #examples }
FBDExamples >> doubleRemoteAnidatedBlocks [

	| val last |	
	val := 0. 
	1 to: 10 do: [ :i |
		[ :continue |
			i = 4 ifTrue: [continue value].
			val := val + 1.
			last := i
		] valueWithExit.
	].
	self assert: val = 9.
	self assert: last = 10


]

{ #category : #'examples - loops' }
FBDExamples >> example2Loops [

	| t |
	t := 1.
	[ t < 5 ] whileTrue: [ t := t + 1 ].
	[ t > 10 ] whileFalse: [ t := t * 2 ]
]

{ #category : #'examples - loops' }
FBDExamples >> example2Loops2 [

	| t |
	t := 1.
	[ t < 5 ] whileTrue: [ [ t > 10 ] whileFalse: [ t := t * 2 ]. t := t + 1 ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleAnd [
	<sampleInstance>
	
	| tmp1 tmp2 |
	tmp1 := true.
	tmp2 := false.
	tmp1 and: tmp2.
	^ tmp2 and: tmp1
]

{ #category : #'examples - branches' }
FBDExamples >> exampleAnd2 [

	| tmp1 |
	tmp1 := true.
	tmp1 and: [ tmp1 not ]
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleAndOr [

	| t1 t2 |
	t1 := true.
	t2 := false.
	t1 and: [ t2. '1' traceCr ] "effect"   
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleAndOr2 [
	<sampleInstance>
	
	| tmp1 tmp2 |
	tmp1 := true.
	tmp2 := false.
	tmp2
		ifTrue: [ ]
		ifFalse: [ '2' traceCr ].
	^ self
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleAndOr3 [
	<sampleInstance>
	
	| t1 t2 |
	t1 := true.
	t2 := false.  
	^ t1 and: [ t2 ] "value" 
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleAndOr4 [
	<sampleInstance>
	
	| tmp1 tmp2 |
	tmp1 := true.
	tmp2 := false.
	^ tmp2
		ifTrue: [ true ]
		ifFalse: [ tmp1 ]
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleAndOr5 [
	<sampleInstance>
	
	| t1 t2 |
	t1 := true.
	t2 := false.  
	^ t2 or: [ t1 and: [ t2 ] ]
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleAndOr6 [
	<sampleInstance>
	
	| t1 t2 |
	t1 := true.
	t2 := false.  
	^ t1 and: [ t2 or: [ t1 ] ]
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleBlockArgument [
	<sampleInstance>
	
	| block block1 block2 |
	block := [ :arg | | temp | temp := arg. [ temp ] ].
	block1 := block value: 1.
	block2 := block value: 2.
	self assert: block1 value = 1.
	self assert: block2 value = 2.
	^block1 value + block2 value
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleBlockExternal [
	<sampleInstance>
	
	| t |
	t := 1.
	^[t] value
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleBlockExternal2 [
	<sampleInstance>
	
	| t1 t2 |
	t1 :=  t2 := 1.
	^[t1 + t2] value
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleBlockExternalArg [

	<sampleInstance>
	| t  |
	t := 1.
	^[:a | t + a] value: 1
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleBlockExternalNested [
	<sampleInstance>
	
	| t s |
	t := s := 1.
	^[ [s] value + t ] value
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleBlockInternal [
	<sampleInstance>
	
	^[ | t | t := 1. t ] value
]

{ #category : #'examples - blocks' }
FBDExamples >> exampleBlockIntoCascade [
	<sampleInstance>
	
	| t |
	t := {true.
	true.
	false}.
	^ t
		size;
		collect: [ :aBoolean | 
					| tmp2 |
					tmp2 := true.
					aBoolean and: [ tmp2 ] ];
		yourself
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleBlockMethodArgument: arg [
	<sampleInstance>
	
	|  block |
	block := [ :blockarg | blockarg + arg].
	self assert: ((block value: 2) = (arg + 2)).
	^block value: 2
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleBlockNested [
	<sampleInstance>
	
	^[ [1] value ] value
]

{ #category : #'examples - blocks' }
FBDExamples >> exampleBlockNumCopied [
	<sampleInstance>
	
	| t1 |
	t1 := OrderedCollection new.
	iVar := {(1 -> 2.3 -> 4.5 -> 6)}.
	^ iVar keysAndValuesDo: [ :key :value | t1 add: (value -> key) ]
]

{ #category : #'examples - blocks' }
FBDExamples >> exampleBlockWithArg [
	<sampleInstance>
	
	^ {1.2.3} collect: [:aNumber | aNumber + 1 ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCascade [
	<sampleInstance>
	
	^ 1 
		+ 2;
		- 4;
		min: 6;
		yourself
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCascade2 [
	<sampleInstance>
	
	^ true
		ifTrue: [ 1 + 2 ];
		and: [ false ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCascade3 [
	<sampleInstance>
	
	^ true
		asBit;
		xor: false
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCascade4 [
	<sampleInstance>
	| t1 |
	t1 := true
		asBit;
		xor: false.
	^ t1
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCascadeIfFalse [
	<sampleInstance>
	
	| tmp1 |
	tmp1 := true value
		not;
		and: [ false ];
		yourself.
	tmp1
		ifFalse: [ ^ false ]
]

{ #category : #'examples - cascades' }
FBDExamples >> exampleCascadeIfNil [
	<sampleInstance>
	
	^ { true } asOrderedCollection
		size;
		add: (true ifNil: [ false ]);
		yourself
]

{ #category : #'examples - cascades' }
FBDExamples >> exampleCascadeIfTrueIfFalse [
	<sampleInstance>
	^ true 
		not;
		ifTrue: [ 'A' ];
		or: [ true ];
		yourself
]

{ #category : #'examples - cascades' }
FBDExamples >> exampleCascadeIfTrueIfFalse2 [
	<sampleInstance>
	
	^ { true } asOrderedCollection
		size;
		add:
				(1=1
						ifTrue: [ 'A' ]
						ifFalse: [ 'B' ])
]

{ #category : #'examples - cascades' }
FBDExamples >> exampleCascadeIntoBlockIntoCascade [
	<sampleInstance>
	
	| t |
	t := {true.
			true.
			false}.
	^ t
		size;
		collect: [ :aBoolean | aBoolean not; value ]
]

{ #category : #'examples - cascades' }
FBDExamples >> exampleCascadeIntoBlockWithTempIfTrueIfFalse [

	| t |
	t := OrderedCollection new.
	t yourself
		add: {1};
		add: {2};
		add: {3};
		collect: [ :anArray | 
					anArray
						collect: [ :aNumber | 
									aNumber isNumber
										ifFalse: [ anArray first ] ];
						collect: [ :aNumber | 
									aNumber isNumber
										ifTrue: [ 
											aNumber even
												ifTrue: [ #('even') ]
												ifFalse: [ #('odd') ] ]
										ifFalse: [ 0 ] ] ]
]

{ #category : #'examples - cascades' }
FBDExamples >> exampleCascadeIntoBlockWithTempIntoCascade [
	<sampleInstance>
	
	| t |
	t := {{true}.
			{true}.
			{false}}.
	^ t
		size;
		collect: [ :aBooleanArray | 
					aBooleanArray
						size;
						collect: [ :aBoolean | 
									| aSecondBoolean aThirdBoolean |
									aSecondBoolean := true.
									aThirdBoolean := false.
									aBoolean
										not;
										or: [ aSecondBoolean ];
										and: [ aThirdBoolean ];
										value ] ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCascadeNested [
	<sampleInstance>
	
	| tmp1 tmp2 |
	tmp1 := 1.
	tmp2 := #(1 2 3) copy.
	tmp2 at: 2 put: 5.
	tmp1
		+ tmp2 size;
		- 4;
		min: 6.
	^ tmp1 yourself
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCaseOf [
	<sampleInstance>
	
	^ 5
		caseOf:
			{([ 1 ] -> [ #CAIRO_FONT_SLANT_NORMAL ]).
			([ 3 ] -> [ #CAIRO_FONT_SLANT_ITALIC ]).
			([ 5 ] -> [ #CAIRO_FONT_SLANT_OBLIQUE ])}
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCaseOf2 [
	<sampleInstance>
	
	^ 5 caseOf: {([ 5 ] -> [ #CAIRO_FONT_SLANT_OBLIQUE ])}
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCaseOf3 [
	<sampleInstance>
	
	| t1 |
	5
		caseOf:
			{([ 1 ] -> [ t1 := #CAIRO_FONT_SLANT_NORMAL ]).
			([ 3 ] -> [ t1 := #CAIRO_FONT_SLANT_ITALIC ]).
			([ 5 ] -> [ t1 := #CAIRO_FONT_SLANT_OBLIQUE ])}.
	^ t1
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCaseOf4 [
	<sampleInstance>
	
	| t1 |
	5
		caseOf:
			{([ 1 ] -> [ t1 := {#CAIRO_FONT_SLANT_NORMAL} first ]).
			([ 3 ] -> [ t1 := #CAIRO_FONT_SLANT_ITALIC ]).
			([ 5 ] -> [ t1 := #CAIRO_FONT_SLANT_OBLIQUE ])}
		otherwise: [ t1 := #NIL ].
	^ t1
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCaseOf5 [
	<sampleInstance>
	
	| t1 |
	5
		caseOf:
			{([ 1 ] -> [ t1 := #CAIRO_FONT_SLANT_NORMAL ]).
			([ 3 ] -> [ t1 := #CAIRO_FONT_SLANT_ITALIC ]).
			([ 5 ] -> [ t1 := #CAIRO_FONT_SLANT_OBLIQUE ])}
		otherwise: [ ].
	^ t1
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCaseOf6 [
	<sampleInstance>
	
	| t1 |
	5
		caseOf:
			{([ 1 ] -> [ t1 := {#CAIRO_FONT_SLANT_NORMAL} first]).
			([ 3 ] -> [ t1 := #CAIRO_FONT_SLANT_ITALIC ]).
			([ 5 ] -> [ t1 := #CAIRO_FONT_SLANT_OBLIQUE ])}
		otherwise: [ t1 := #NIL ].
	^ t1
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCaseOf7 [
	<sampleInstance>
	
	| t1 |
	5
		caseOf:
			{([ 1 ]
				-> [ 
					t1 := 2.
					t1 := t1 + 1 ]).
			([ 3 ] -> [ t1 := {#CAIRO_FONT_SLANT_ITALIC} first ]).
			([ 5 ] -> [ t1 := #CAIRO_FONT_SLANT_OBLIQUE ])}
		otherwise: [ t1 := #NIL ].
	^ t1
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCaseOf8 [
	<sampleInstance>
	
	9
		caseOf:
			{([ 0 ] -> [ 0 @ 0 ]).
			([ 9 ] -> [ 1 @ 1 ]).
			([ 3 ] -> [ -1 @ 1 ])}.
	^ true
]

{ #category : #'examples - branches' }
FBDExamples >> exampleCaseOfOtherwise [
	<sampleInstance>
	
	^ 5
		caseOf:
			{([ 1 ] -> [ #CAIRO_FONT_SLANT_NORMAL ]).
			([ 3 ] -> [ #CAIRO_FONT_SLANT_ITALIC ]).
			([ 5 ] -> [ #CAIRO_FONT_SLANT_OBLIQUE ])}
		otherwise: [ #NULL ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleClassVar [
	<sampleInstance>
	
	CVar := 1.
	^ CVar
]

{ #category : #'examples - blocks' }
FBDExamples >> exampleCopyingBlock [
	<sampleInstance>
	
	| t |
	t := true.
	^ [ t ifTrue: [ 5 + t asBit ]. t ].
]

{ #category : #'examples-pragmas' }
FBDExamples >> exampleDoublePrimitive [
	<primitive: 1>
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleEffectValues [

	#getMe.
	#( got that ? ).
	Class.
	
]

{ #category : #'examples-simple' }
FBDExamples >> exampleEmptyMethod [
]

{ #category : #'examples - blocks' }
FBDExamples >> exampleFullBlock [
	<sampleInstance>
	
	| t |
	t := true.
	^ [ t := false ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIV [
	<sampleInstance>
	
	iVar := 5.
	^ iVar
	
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleIfFalse [
	<sampleInstance>
	
	true
		ifTrue: [  ]
		ifFalse: [ ^ 1 ].
	^ 2
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfFalse2 [
	<sampleInstance>
	
	^ true ifFalse: [ ^ 'result' ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfFalse3 [
	<sampleInstance>
	
	1 < 2 ifFalse: [ ^ 'result' ].
	1+2.
	^ nil
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleIfFalseIfTrue [
	<sampleInstance>
	
	true ifFalse: [^1] ifTrue: [^2]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfFalseIfTrue2 [

	| a |
	a := true.
	a ifFalse: [ a := 1 + 2 ] ifTrue: [ a := 2 + 3 ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfFalseIfTrue3 [
	<sampleInstance>
	
	| a |
	a := true.
	a ifFalse: [ a := false  ] ifTrue: [ ^1 ].
	^ 2
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfFalseIfTrue4 [
	<sampleInstance>
	
	| a |
	a := true.
	a ifFalse: [ 1 + 2 ] ifTrue: [ ^1 ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfFalseIfTrue5 [
	<sampleInstance>
	
	| a |
	a := true.
	a ifFalse: [ ^1 ] ifTrue: [ 1 + 2 ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfFalseIfTrue6 [
	<sampleInstance>
	
	| a |
	a := true.
	^ a ifFalse: [ ] ifTrue: [ ^1 ]
	
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfNil [
	<sampleInstance>
	
	true ifNil: [ ^ 5 ]. ^ 6 
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfNilClosure [
	<sampleInstance>
	
	^ iVar ifNil: [ 1 + ({1.2} at: 2 ifAbsent: [ ^ nil ]) ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfNilDup [
	<sampleInstance>
	
	^ true ifNil: [ 1+2. 5 ]   
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfNilIfNotNil [
	<sampleInstance>
	
	true ifNil: [ ^ 5 ] ifNotNil: [ ^ 6 ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfNilIfNotNil2 [
	<sampleInstance>
	
	^ true ifNil: [  5 ] ifNotNil: [ 6 ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfNilIfNotNil3 [
	<sampleInstance>
	
	| tmp1 |
	tmp1:= true.
	^ tmp1 ifNil: [  5 ] ifNotNil: [ 6 ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfNilNested [
	<sampleInstance>
	
	^ true ifNil: [ (false ifNil: [ ^ true ]) not ]
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleIfNotNilArg [
	<sampleInstance>
	
	^1 even ifNotNil: [ :arg | arg not ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfNotNilDup [
	<sampleInstance>
	
	^ true ifNotNil: [ 5 ]     
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleIfNotNilReturnNil [
	<sampleInstance>
	
	^nil ifNotNil: [ :arg | arg not ]
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleIfTrue [

	[ 1 < 2
		ifTrue: [ ^ 'result' ]] value
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrue2 [
	<sampleInstance>
	
	^ 1 < 2 ifTrue: [ ^ 'result' ]
	  
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrue3 [
	<sampleInstance>
	
	1 < 2 ifTrue: [ ^ 'result' ].
	^ nil
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleIfTrueAssign [
	<sampleInstance>
	| a |
	a := 1 <2 ifTrue: [1] ifFalse: [2].
	^a 
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrueForEffectNested [
	<sampleInstance>
	
	| tmp1 |
	true
		ifTrue: [ 
			tmp1 := true.
			false
				ifTrue: [ 
					tmp1 := false.
					^ tmp1 ] ]
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleIfTrueIfFalse [
	<sampleInstance>
	
	 1 <2 ifTrue: [^'result'] ifFalse: [2].
	
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrueIfFalse2 [

	| a |
	a := true.
	a ifTrue: [ a:= 1 + 2 ] ifFalse: [ a := 2 + 3 ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrueIfFalse3 [
	<sampleInstance>
	
	| a |
	a := true.
	a ifTrue: [ ^ 1 ] ifFalse: [ a := false ].
	^ 2
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrueIfFalseLikeAnd [
	<sampleInstance>
	
	| t1 |
	t1 := true.
	^ t1 ifTrue: [ t1 not ] ifFalse: [ false ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrueIfFalseNested [
	<sampleInstance>
	
	^ true ifTrue: [ false ifFalse: [ ^ 4 ] ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrueIfFalseNested2 [
	<sampleInstance>
	
	true ifFalse: [ false ifTrue: [ ^ false ]. ^ true ]. ^ nil
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrueIfFalseNested3 [
	<sampleInstance>
	
	^ {1.2.3.4}
		collect: [ :aNumber | 
			aNumber isNumber
				ifTrue: [ 
					aNumber even
						ifTrue: [ #('even') ]
						ifFalse: [ #('odd') ] ]
				ifFalse: [ 0 ] ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrueNested [
	<sampleInstance>
	
	true ifTrue: [ 
		false ifTrue: [ ^ false ].
		^ true ].
	^ false
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrueWithNilAssertion [

	| tmp1 |
	tmp1 := 1.
	tmp1 > 2
		ifTrue: [ tmp1 := nil ]
]

{ #category : #'examples - branches' }
FBDExamples >> exampleIfTrueWithOr [
	<sampleInstance>
	
	false | true
		ifTrue: [ ^ true ]
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleInlineBlockCollectionLR3 [
	<sampleInstance>
	
	| col |
	col := OrderedCollection new.
	1 to: 11 do: [ :each | | i | i := each. col add: [ i ]. i := i + 1 ].
	^ (col collect: [ :each | each value ]) asArray "= (2 to: 12) asArray"

]

{ #category : #'examples-blocks' }
FBDExamples >> exampleMethodTempInNestedBlock [
	<sampleInstance>
	
	| temp block |
	temp := 0.
	block := [ [ temp ] ].
	temp := 1.
	block := block value.
	temp := 2.
	"self assert: block value = 2."
	^block value
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleMethodWithOptimizedBlocksA [
	<sampleInstance>
	
	| s c |
	s := self isNil
			ifTrue: [| a | a := 'isNil'. a]
			ifFalse: [| a | a := 'notNil'. a].
	c := String new: s size.
	1 to: s size do:
		[:i| c at: i put: (s at: i)].
	^c. "notNil"
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleNestedBlockScoping [
	<sampleInstance>

	| b c z |
	b := [:a | 
			z := 2.
			z + a].
	c := [:a |
			z + a].
	^ (b value: 2) + (c value: 1)
]

{ #category : #'examples - branches' }
FBDExamples >> exampleNestedIfNilIfNotNil [
	<sampleInstance>
	^ true
		ifNotNil: [ 1 ]
		ifNil: [ false 
			ifNotNil: [ 2 ] 
			ifNil: [ ^ true ] ]
]

{ #category : #'examples-simple' }
FBDExamples >> exampleNewArray [
	<sampleInstance>

	| temp |	
	temp := Array new: 3.
	^temp
]

{ #category : #'examples - branches' }
FBDExamples >> exampleOr [
	<sampleInstance>
	
	| t1 |
	t1 := false.
	^ t1 or: [ t1 not ]
]

{ #category : #'examples-pragmas' }
FBDExamples >> examplePrimitiveErrorCode [
	<sampleInstance>
	<primitive: 60 error: code >
	
	^ code


]

{ #category : #'examples-pragmas' }
FBDExamples >> examplePrimitiveErrorCodeModule [
	"Primitive. Attempt to load a module of the given name.
	Fail if module cannot be found, or cannot be loaded,
	or failed to initialize"
	<sampleInstance>
	<primitive: 'primLoadModule'  module: '' error: #errorCode >
	
	^ self primitiveFailed
]

{ #category : #'examples - pragmas' }
FBDExamples >> examplePrimitiveErrorCodeModule2 [
	"Primitive. Attempt to load a module of the given name.
	Fail if module cannot be found, or cannot be loaded,
	or failed to initialize"
	<sampleInstance>
	<primitive: 'primLoadModule'  module: '' error: errorCode >
	
	^ self primitiveFailed
]

{ #category : #'examples-misc' }
FBDExamples >> examplePushArray [
	<sampleInstance>
	| t |

	{1. t := 1}.
	^t
]

{ #category : #'examples-misc' }
FBDExamples >> examplePushBigArray [
	<sampleInstance>
	"This array should have a size more than 127 elements"
	self flag: 'needs a fix'.
	{ 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 .  255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 }.
	^ 1
]

{ #category : #'examples - loops' }
FBDExamples >> exampleRepeatEffect [
	<sampleInstance>
	<compilerOptions: #(+ #optionInlineRepeat)>
	
	| i |
	i := 1.
	[ 
	i := i + 1.
	i = 10
		ifTrue: [ ^ true ] ] repeat
]

{ #category : #'examples - loops' }
FBDExamples >> exampleRepeatValue [
	<sampleInstance>
	<compilerOptions: #(+ #optionInlineRepeat)>
	
	| i |
	i := 1.
	^ [ 
	i := i + 1.
	i = 10
		ifTrue: [ ^ true ] ] repeat 
]

{ #category : #'examples-simple' }
FBDExamples >> exampleReturn1 [
	<sampleInstance>
	
	^1
]

{ #category : #'examples-simple' }
FBDExamples >> exampleReturn1plus2 [
	<sampleInstance>
	
	^1+2
]

{ #category : #'examples-simple' }
FBDExamples >> exampleReturn42 [
	<sampleInstance>
	
	^42
]

{ #category : #'examples-variables' }
FBDExamples >> exampleSelf [
	<sampleInstance>
	
	| t |
	t := self.
	^self.
]

{ #category : #'examples - simple' }
FBDExamples >> exampleSend [
	self basicSize 
]

{ #category : #'examples - simple' }
FBDExamples >> exampleSend2Args [

	self instVarAt: 1 put: #banana
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlock [
	<sampleInstance>
	
	^[1]
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlockArgument1 [
	<sampleInstance>
	
	^[:a | a ] value: 1
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlockArgument2 [
	<sampleInstance>
	
	^[:a :b | a + b ] value: 1 value: 1
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlockArgument3 [
	<sampleInstance>
	
	^[:a :b :c | a + b + c ] value: 1 value: 1 value: 1
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlockArgument4 [
	<sampleInstance>
	
	^[:a :b :c :d | a + b + c  + d] value: 1 value: 1 value: 1 value: 1
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlockArgument5 [
	<sampleInstance>
	
	^[:a :b :c :d :e| a + b + c  + d + e] valueWithArguments: #(1 1 1 1 1)
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlockEmpty [
	<sampleInstance>
	
	^[] value
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlockLocal [
	<sampleInstance>
	
	^[ :each | | t |  t:= each. t   ] value: 5
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleSimpleBlockLocalIf [
	<sampleInstance>
	
	^true ifTrue: [ | hallo |  hallo := 1 . hallo]
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlockLocalIfNested [
	<sampleInstance>
	
	^true ifTrue: [| hallo | [  hallo := 1 . hallo] value]
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleSimpleBlockLocalWhile [
	<sampleInstance>
	
	|a|
	a := true.
	^[: b | [a] whileTrue: [ | hallo |  a := false. hallo := 1 . hallo]] value: 1
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlockNested [
	<sampleInstance>
	
	| a match dict | 
	a  := #(a b c d).
	dict := Dictionary new.

	a doWithIndex: [:each :index |
		(match := a indexOf: each) > 0 ifTrue:
			[dict at: index put: (a at: match)]].

	^ dict
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlockReturn [
	<sampleInstance>
	
	[^1] value
]

{ #category : #'examples-blocks' }
FBDExamples >> exampleSimpleBlockiVar [
	<sampleInstance>
	
	^[iVar] value
]

{ #category : #'examples-variables' }
FBDExamples >> exampleSuper [
	<sampleInstance>
	
	| t |
	t := super.
	^super
]

{ #category : #'examples-variables' }
FBDExamples >> exampleThisContext [
	<sampleInstance>
	
	| t |
	t := thisContext.
	^thisContext
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleTimesRepeatEffect [
	<sampleInstance>
	
	| foo |
	foo := 1.
	5 timesRepeat: [ foo := foo + 3 ]. 
	^ foo
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleTimesRepeatValue [
	<sampleInstance>
	
	^ 5 timesRepeat: [ 1 + 2 ]   
]

{ #category : #'examples - loops' }
FBDExamples >> exampleToByDo [
	<sampleInstance>
	
	| tmp1 |
	tmp1 := {true.	true.	true}.
	1 to: 9 by: 3 do: [ :index | tmp1 at: index / 3  put: false ].
	^ tmp1
]

{ #category : #'examples - loops' }
FBDExamples >> exampleToByDoNegativeLoop [
	<sampleInstance>
	
	| tmp1 |
	tmp1 := {true.	true.	true}.
	tmp1 size to: 10-9 by: -1 do: [ :index | tmp1 at: index put: false ].
	^ tmp1
]

{ #category : #'examples - loops' }
FBDExamples >> exampleToDo [
	<sampleInstance>
	
	| tmp1 tmp2 tmp3 |
	tmp1 := {true.
	true.
	true}.
	tmp2 := tmp1 size.
	tmp3 := 1.
	[ tmp3 <= tmp2 ]
		whileTrue: [ 
			tmp1 at: tmp3 put: false.
			tmp3 := tmp3 + 1 ].
	^ 1
]

{ #category : #'examples - loops' }
FBDExamples >> exampleToDo2 [
	<sampleInstance>
	
	| t |
	t := {true.true.true}.
	1 to: t size do: [ :index | t at: index put: false ].
	^ t
]

{ #category : #'examples - loops' }
FBDExamples >> exampleToDo3 [
	<sampleInstance>
	
	| t |
	t := Array new:3.
	1 to: 3 do: [ :index | t at: index put: false ].
	^ t
]

{ #category : #'examples - loops' }
FBDExamples >> exampleToDo4 [
	<sampleInstance>
	
	| tmp1 tmp2 |
	tmp1 := {true . true . true }.
	tmp2 := tmp1 size.
	1 to: tmp2 do: [ :index | tmp1 at: index put: false ].
	1 to: tmp2 do: [ :index | tmp1 at: index put: true ].
	^ tmp1
]

{ #category : #'examples - loops' }
FBDExamples >> exampleToDo5 [
	<sampleInstance>
	
	| tmp1 |
	tmp1 := {true.
				true.
				true}.
	[ 1 to: 3 do: [ :index | tmp1 at: index put: false ] ] valueWithin: 50 milliSeconds onTimeout: [ ].
	^ tmp1
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleToDoArgument [
	<sampleInstance>
	
	collection := OrderedCollection new.
	1 to: 5 do: [ :index |
		collection add:  [index]  ].
	 ^collection collect: [:each | each value]. 
	"#(1 2 3 4 5)"
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleToDoArgumentLimitIsExpression [
	<sampleInstance>
	
	| count sum |
	count := 10.
	sum := 0.
	1 to: count - 1 do: [ :each | sum := sum + each].
	^sum
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleToDoArgumentNotInlined [
	<sampleInstance>
	
	| block |
	block := [ :index |
		collection add: [ index ] ].
	1 to: 5 do: block.
	^collection "#(1 2 3 4 5)"
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleToDoInsideBlock [

	| tmp1 block |
	tmp1 := {1.2 . 3.4} asOrderedCollection.
	block := [ (tmp1 at: 1) to: (tmp1 at: 4) do: [ :arg1 | self trace: arg1 ] ]
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleToDoInsideTemp [
	<sampleInstance>
	
	1 to: 5 do: [ :index | 
		| temp | 
		temp := index. 
		collection add: [ temp ] ].
	^collection "#(1 2 3 4 5)"
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleToDoInsideTempNotInlined [
	<sampleInstance>
	
	| block |
	block := [ :index | 
		| temp | 
		temp := index. 
		collection add: [ temp ] ].
	1 to: 5 do: block.
	^collection "#(1 2 3 4 5)"
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleToDoOutsideTemp [
	<sampleInstance>
	
	| temp |
	1 to: 5 do: [ :index | 
		temp := index. 
		collection add: [ temp ] ].
	^collection "#(5 5 5 5 5)"
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleToDoOutsideTempNotInlined [
	<sampleInstance>
	
	| block temp |
	block := [ :index | 
		temp := index. 
		collection add: [ temp ] ].
	1 to: 5 do: block.
	^collection "#(5 5 5 5 5)"
]

{ #category : #'examples-misc' }
FBDExamples >> exampleToDoValue [
	<sampleInstance>

	^ 1 to: 2 do: [:each | each]
	

]

{ #category : #'examples-misc' }
FBDExamples >> exampleToDoValueLimitExpression [
	<sampleInstance>

	^ 2 to: 3+4 do: [:each | each]
	

]

{ #category : #'examples - loops' }
FBDExamples >> exampleToDoWithMessage [
	<sampleInstance>
	
	| t |
	t := {true.true.true}.
	^ 1 yourself to: t size do: [ :index | t at: index put: false ]
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleToDoWithMessage2 [

	| t t1 t2 |
	t := {true.true.true}.
	t1 := 1.
	t2 := t size.
	t1 to: t2 do: [ :index | t at: index put: false ]
]

{ #category : #'examples - loops' }
FBDExamples >> exampleWhileFalse [

	| t |
	t := 1.
	[ t > 10 ] whileFalse: [ t := t + 1. 1 + 2 ]
]

{ #category : #'examples - loops' }
FBDExamples >> exampleWhileFalse2 [

	| t |
	t := 1.
	[ t := t + 1. 1 + 2. t > 10 ] whileFalse
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleWhileModificationAfterNotInlined [
	<sampleInstance>
	
	| index block |
	index := 0.
	block := [ 
		collection add: [ index ].
		index := index + 1 ].
	[ index < 5 ] whileTrue: block.
	^collection "#(5 5 5 5 5)"
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleWhileModificationBefore [
	<sampleInstance>
	
	| index |
	collection := OrderedCollection new.
	index := 0.
	[ index < 5 ] whileTrue: [ 
		index := index + 1.
		collection add: [ index ] ].
	 ^ collection collect: [:each | each value].
	"#(5 5 5 5 5)"
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleWhileModificationBeforeNotInlined [
	<sampleInstance>
	
	| index block |
	index := 0.
	block := [ 
		index := index + 1.
		collection add: [ index ] ].
	[ index < 5 ] whileTrue: block.
	^collection.
	"#(5 5 5 5 5)"
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleWhileNoModification [
	"tempvars aren't modified in the loop, therefore they don't need to be in a indirection vector.
	  number of temps = declared temps "

	| a b c |
	a := 1.
	b := 2.
	c := 3.
	[ false ]
		whileTrue: [ 
			[ a class.
			  b class.
			  c class ]	"<- block in optimized loop" ]
]

{ #category : #'examples - loops' }
FBDExamples >> exampleWhileTrue [

	| array t |
	array := {true.	true.true}.
	t := 1.
	[ t < 4 ]
		whileTrue: [ 
			array at: t put: false.
			t := t + 1 ]
]

{ #category : #'examples - loops' }
FBDExamples >> exampleWhileTrue2 [
	| t |
	t := 1.
	[ 
	t := t + 1.
	1 + 2.
	t < 10 ] whileTrue
]

{ #category : #'examples - loops' }
FBDExamples >> exampleWhileTrue3 [

	| t1 t2 |
	t2 := 5.
	t1 := 1.
	t1 := t1+1.
	[ t1 <= t2 ]
		whileTrue: [ 
			t1 + 2.
			t1 := t1 + 1 ]
]

{ #category : #'examples - loops' }
FBDExamples >> exampleWhileTrue4 [

	| tmp1 tmp2 |
	tmp1 := 1.
	[ tmp1 <= 5 ]
		whileTrue: [ 
			tmp1 + 2.
			tmp1 := tmp1 + 1 ].
	tmp2 := 1.
	[ tmp2 <= 5 ]
		whileTrue: [ 
			tmp1 := tmp2.
			tmp2 := tmp2 + 1 ]
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleWhileTrueSameJumpTarget [

	| tmp1 tmp2 |
	tmp1 := 1.
	tmp2 := 10.
	[ 
	[ 
	tmp1 := tmp1 + 1.
	tmp1 < 10 ] whileTrue.
	tmp2 := tmp2 - 1.
	tmp2 > 0 ] whileTrue
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleWhileTrueSameJumpTarget2 [

	| tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 |
	"need body + triple nested loop with same start"
	tmp1 := 1.
	tmp2 := 10.
	tmp3 := 3.
	tmp4 := 5.
	tmp5 := 7.
	tmp6 := 6.
	[ 
	[ 
	[ 
	[ 
	tmp5 := tmp5 * 2.
	tmp5 < 14 ] whileTrue.
	tmp4 := tmp4 + 1.
	tmp4 < 10 ] whileTrue.
	[ 
	[ 
	tmp1 := tmp1 + 1.
	tmp1 < 10 ] whileTrue.
	tmp6 := tmp6 + 3.
	tmp6 < 20 ] whileTrue.
	tmp2 := tmp2 - 1.
	tmp2 > 0 ] whileTrue.
	tmp3 := tmp1 + 1.
	tmp1 < 10 ] whileTrue
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleWhileWithTemp [
	<sampleInstance>
	
	| index |
	index := 0.
	[ index < 5 ] whileTrue: [
		| temp |
		temp := index := index + 1.
		collection add: [ temp ] ].
	^collection "#(1 2 3 4 5)"
]

{ #category : #'examples-blocks-optimized' }
FBDExamples >> exampleWhileWithTempNotInlined [
	<sampleInstance>
	
	| index block |
	index := 0.
	block := [
		| temp |
		temp := index := index + 1.
		collection add: [ temp ] ].
	[ index < 5 ] whileTrue: block.
	^collection "#(1 2 3 4 5)"
]

{ #category : #examples }
FBDExamples >> exampleWithArgs: arg1 and: arg2 [
	<sampleInstance>
	
	^ arg1
]

{ #category : #examples }
FBDExamples >> exampleWithArgsAndTemps: arg1 and: arg2 [
	<sampleInstance>
	
	| tmp1 tmp2 |
	tmp1 := 1.
	tmp2 := tmp1 + arg1.
	^ { tmp2 . arg2 }
]

{ #category : #'examples-variables' }
FBDExamples >> exampleiVar [
	<sampleInstance>
	
	iVar := 1.
	^iVar
]

{ #category : #accessing }
FBDExamples >> iVar [

	^ iVar
]

{ #category : #accessing }
FBDExamples >> iVar: anObject [

	iVar := anObject
]

{ #category : #initialization }
FBDExamples >> initialize [

	super initialize.
	collection := OrderedCollection new
]

{ #category : #examples }
FBDExamples >> nestedBlocksRemoteInBlockCase1 [

	| block |
	self flag: 'Not well decompiled'.
	block := [ | a b |
		[ a := b ].
		[ b := a ] ]
]

{ #category : #examples }
FBDExamples >> nestedBlocksRemoteInBlockCase2 [

	| block |
	self flag: 'Not well decompiled'.
	block := [ 
		[ |a| [ a := 1] ].
		[ |b| [ b := 2] ] ]
]

{ #category : #examples }
FBDExamples >> nestedBlocksRemoteInBlockCase3 [

	| block |
	self flag: 'Not well decompiled'.
	block := [ 
		[ |a| block := [ a := 1] ].
		[ |b| block := [ b := 2] ] ]
]

{ #category : #examples }
FBDExamples >> noRemoteBlockArgument [

	| block block1 block2 |
	block := [ :arg | | temp | temp := arg. [ temp ] ].
	block1 := block value: 1.
	block2 := block value: 2


]

{ #category : #examples }
FBDExamples >> noRemoteBlockTemp [

	| block block1 block2 |
	block := [ :arg | [ arg ] ].
	block1 := block value: 1.
	block2 := block value: 2



]

{ #category : #examples }
FBDExamples >> noRemoteReadInBlock [

	| a |
	a := 1.
	[ a ]


]

{ #category : #examples }
FBDExamples >> noRemoteReadNestedBlocks [

	 [ |a| a := 1.
       [ a ]]

]

{ #category : #examples }
FBDExamples >> optimizedBlockWriteInBlock [

	| t1 |
	[ t1 < 5 ] whileTrue: [ t1 := 1 ]

]

{ #category : #examples }
FBDExamples >> optimizedBlockWriteInNestedBlock [

	| t1 |
	^[ [ t1 < 5 ] whileTrue: [ t1 := 1 ] ]

]

{ #category : #examples }
FBDExamples >> optimizedBlockWriteInNestedBlockCase2 [

	| t1 |
	(true) ifTrue: [ [ t1 < 5 ] whileTrue: [ t1 := 1 ] ]

]

{ #category : #examples }
FBDExamples >> optimizedBlockWriteInNestedBlockCase3 [

	| t1 |
	[(true) ifTrue: [ [ t1 < 5 ] whileTrue: [ t1 := 1 ] ] ]

]

{ #category : #examples }
FBDExamples >> optimizedBlockWriteInNestedBlockCase4 [

	| t1 |
	[(true) whileTrue: [ [ t1 < 5 ] whileTrue: [ t1 := 1 ] ] ]

]

{ #category : #examples }
FBDExamples >> optimizedBlockWriteReadInBlock [

	| t1 |
	[ t1 < 5 ] whileTrue: [ t1 := 1. [ t1 ] ]

]

{ #category : #examples }
FBDExamples >> optimizedBlockWrittenAfterClosedOverCase1 [

	| index |
	index := 0.
	[ index < 5 ] whileTrue: [
		| temp |
		[ temp ].
		temp := index := index + 1].
	^index

]

{ #category : #examples }
FBDExamples >> optimizedBlockWrittenAfterClosedOverCase2 [

	| index |
	index := 0.
	[ index < 5 ] whileTrue: [
		| temp |
		temp := index := index + 1.
		 [ temp ] ]

]

{ #category : #examples }
FBDExamples >> singleRemoteDifferentBlocksSameArgumentName [

	| b c z |
	b := [:a | 
		z := 2.
		z + a].
	c := [:a |
		z + a].
	^ (b value: 2) + (c value: 1)


]

{ #category : #examples }
FBDExamples >> singleRemoteMethodArgument [

	| temp block |
	temp := 0.
	block := [ [ temp ] ].
	temp := 1.
	block := block value.
	temp := 2

]

{ #category : #examples }
FBDExamples >> singleRemoteReadNestedBlocks [
   
	|a| 
	[ a := 1.
       [ a ]]

]

{ #category : #examples }
FBDExamples >> singleRemoteTempVar [

	| index block theCollection |
	index := 0.
	block := [ 
		theCollection add: [ index ].
		index := index + 1 ].
	[ index < 5 ] whileTrue: block.
	self assertValues: #(5 5 5 5 5)
]

{ #category : #examples }
FBDExamples >> singleRemoteTempVarWrittenAfterClosedOver [

	| index block |
	index := 0.
	block := [ index ].
	index := index + 1

]

{ #category : #examples }
FBDExamples >> superCallInBlock [

	^ [ super yourself ] value

]

{ #category : #examples }
FBDExamples >> writtenAfterClosedOver [

	| a |      
	[ a ].
	a := 1
]
