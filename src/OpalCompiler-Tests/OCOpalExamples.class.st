"
I am the central place for example code used in tests
"
Class {
	#name : #OCOpalExamples,
	#superclass : #Object,
	#instVars : [
		'iVar',
		'collection',
		'result'
	],
	#classVars : [
		'ExampleClassVariable'
	],
	#category : #'OpalCompiler-Tests-Data'
}

{ #category : #compiler }
OCOpalExamples class >> compilerClass [
	^OpalCompiler
]

{ #category : #compiler }
OCOpalExamples class >> reset [

	ExampleClassVariable := nil
]

{ #category : #accessing }
OCOpalExamples >> classVariable [

	^ ExampleClassVariable
]

{ #category : #accessing }
OCOpalExamples >> classVariable: anInteger [ 

	ExampleClassVariable := anInteger
]

{ #category : #examples }
OCOpalExamples >> doubleRemoteAnidatedBlocks [
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
	self assert: last = 10.


]

{ #category : #'examples-andor' }
OCOpalExamples >> exampleAndValueWithEffect [
	
	true and: [ result := 17 ]
]

{ #category : #'examples-andor' }
OCOpalExamples >> exampleAndValueWithShortcircuitEffect [
	
	false and: [ result := 17 ]
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleBlockArgument [
	| block block1 block2 |
	block := [ :arg | | temp | temp := arg. [ temp ] ].
	block1 := block value: 1.
	block2 := block value: 2.
	self assert: block1 value = 1.
	self assert: block2 value = 2.
	^block1 value + block2 value.
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleBlockExternal [
	| t |
	t := 1.
	^[t] value.
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleBlockExternal2 [
	| t1 t2 |
	t1 :=  t2 := 1.
	^[t1 + t2] value.
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleBlockExternalArg [
	| t  |
	t := 1.
	^[:a | t + a] value: 1.
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleBlockExternalNested [
	| t s |
	t := s := 1.
	^[[s] value +   t   ] value.
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleBlockInternal [
	^[ | t | t := 1. t] value
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleBlockMethodArgument: arg [
	|  block |
	block := [ :blockarg | blockarg + arg].
	self assert: ((block value: 2) = (arg + 2)).
	^block value: 2
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleBlockNested [
	
	^[ [1] value] value
]

{ #category : #'examples-variables' }
OCOpalExamples >> exampleClassVariableAssignment [

	ExampleClassVariable := 1
]

{ #category : #'examples-pragmas' }
OCOpalExamples >> exampleDoublePrimitive [
	<primitive: 1>
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleEffectValues [
	#getMe.
	#( got that ? ).
	Class.
	
]

{ #category : #'examples-simple' }
OCOpalExamples >> exampleEmptyMethod [
]

{ #category : #'examples-andor' }
OCOpalExamples >> exampleFalseAndAnything: anything [
	^ false and: [ anything ]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleFalseIfFalse [
	^false ifFalse: [1]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleFalseIfFalseIfTrue [
	^false ifFalse: [iVar := 'false'] ifTrue: [ self error ]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleFalseIfFalseWithEffect [
	^false ifFalse: [iVar := 17]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleFalseIfTrue [
	^false ifTrue: [1]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleFalseIfTrueIfFalse [
	^false ifTrue: [ self error ] ifFalse: [iVar := 'false'] 
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleFalseIfTrueWithEffect [
	^false ifTrue: [iVar := 17]
]

{ #category : #'examples-andor' }
OCOpalExamples >> exampleFalseOrAnything: anything [
	^ false or: [ anything ]
]

{ #category : #'examples-variables' }
OCOpalExamples >> exampleForBlockArgument [
	|b|
	b:= [ :blockArg | 1 ].
	^ b
]

{ #category : #'examples-variables' }
OCOpalExamples >> exampleForInlinedBlockArgument [
	1 ifNotNil:[ :value | ^ value ].

]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleIfFalse [
	true
		ifTrue: [  ]
		ifFalse: [ ^ 1 ].
	^ 2
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleIfFalseIfTrue [
	^ true
		ifFalse: [ 1 ]
		ifTrue: [ 2 ]
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleIfNotNilArg [
	^1 even ifNotNil: [ :arg | arg not ]
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleIfNotNilReturnNil [
	^nil ifNotNil: [ :arg | arg not ]
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleIfTrue [
	[ 1 < 2
		ifTrue: [ ^ 'result' ]] value
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleIfTrueIfFalse [
	 1 <2 ifTrue: [^'result'] ifFalse: [2].
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleInlineBlockCollectionLR3 [
	| col |
	col := OrderedCollection new.
	1 to: 11 do: [ :each | | i | i := each. col add: [ i ]. i := i + 1 ].
	^ (col collect: [ :each | each value ]) asArray "= (2 to: 12) asArray"

]

{ #category : #'examples-variables' }
OCOpalExamples >> exampleInstanceVariableAssignment [
	iVar := 1
]

{ #category : #'examples-literals' }
OCOpalExamples >> exampleLiteralArray [
	^ #( 1 2 3)
]

{ #category : #'examples-literals' }
OCOpalExamples >> exampleLiteralBoxedFloat [
	^ 9.999999999999996e157
]

{ #category : #'examples-literals' }
OCOpalExamples >> exampleLiteralByteArray [
	^ #[ 1 2 3 ]
]

{ #category : #'examples-literals' }
OCOpalExamples >> exampleLiteralByteString [
	^ 'bytestring'
]

{ #category : #'examples-literals' }
OCOpalExamples >> exampleLiteralByteSymbol [
	^ #bytesymbol
]

{ #category : #'examples-literals' }
OCOpalExamples >> exampleLiteralCharacter [
	^ $H
]

{ #category : #'examples-literals' }
OCOpalExamples >> exampleLiteralFloat [
	^ 1.2
]

{ #category : #'examples-literals' }
OCOpalExamples >> exampleLiteralLargeInteger [
	^ 16rFFFFFFFFFFFFFFFF
]

{ #category : #'examples-literals' }
OCOpalExamples >> exampleLiteralWideString [
	^ 'áèîöÑü'
]

{ #category : #'examples-literals' }
OCOpalExamples >> exampleLiteralWideSymbol [
	^ #'áèîöÑü'
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleMethodTempInNestedBlock [
	| temp block |
	temp := 0.
	block := [ [ temp ] ].
	temp := 1.
	block := block value.
	temp := 2.
	"self assert: block value = 2."
	^block value.
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleMethodWithOptimizedBlocksA [
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
OCOpalExamples >> exampleNestedBlockScoping [
	| b c z |
	b := [:a | 
			z := 2.
			z + a].
	c := [:a |
			z + a].
	^ (b value: 2) + (c value: 1)
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleNewArray [
	| temp |
	
	temp := Array new: 3.
	^temp
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleNilIfNil [
	^nil ifNil: [ iVar := 17 ]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleNilIfNotNil [
	^nil ifNotNil: [ self error ]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleNilIfNotNilWithArgument [
	^nil ifNotNil: [ :arg | self error ]
]

{ #category : #'examples-literals' }
OCOpalExamples >> exampleNonSpecialLiteralInteger [
	^ 10
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleNotNilIfNil [
	^1 ifNil: [ self error ]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleNotNilIfNotNil [
	^1 ifNotNil: [ iVar := 17 ]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleNotNilIfNotNilWithArgument [
	^1 ifNotNil: [ :arg | iVar := arg ]
]

{ #category : #'examples-andor' }
OCOpalExamples >> exampleOrValueWithEffect [
	
	false or: [ result := 17 ]
]

{ #category : #'examples-andor' }
OCOpalExamples >> exampleOrValueWithShortcircuitEffect [
	
	true or: [ result := 17 ]
]

{ #category : #'examples-pragmas' }
OCOpalExamples >> examplePrimitiveErrorCode [
	<primitive: 60 error: code >
	
	^ code


]

{ #category : #'examples-pragmas' }
OCOpalExamples >> examplePrimitiveErrorCodeModule [
	"Primitive. Attempt to load a module of the given name.
	Fail if module cannot be found, or cannot be loaded,
	or failed to initialize"

	<primitive: 'primLoadModule'  module: '' error: #errorCode >
	^ self primitiveFailed
]

{ #category : #'examples-pragmas' }
OCOpalExamples >> examplePrimitiveErrorModule [
	<primitive: 'primFunction' error: errorCode module: 'primModule'>
	^ errorCode
]

{ #category : #'examples-pragmas' }
OCOpalExamples >> examplePrimitiveModuleError [
	<primitive: 'primFunction'  module: 'primModule' error: errorCode >
	^ errorCode
]

{ #category : #'examples-variables' }
OCOpalExamples >> examplePushArgumentVariable: argument [
	self message: argument
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> examplePushArray [
	| t |

	{1 .t:=1}.
	^t
]

{ #category : #'examples-misc' }
OCOpalExamples >> examplePushBigDynamicLiteralArray [
	"This array should have a size more than 127 elements"
	self message: { 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 .  255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 }
]

{ #category : #'examples-variables' }
OCOpalExamples >> examplePushClassVariable [
	self result: ExampleClassVariable
]

{ #category : #'examples-misc' }
OCOpalExamples >> examplePushDynamicLiteralArray [
	^  { 1 . 1+2 }
]

{ #category : #'examples-variables' }
OCOpalExamples >> examplePushInstanceVariable [
	self result: iVar
]

{ #category : #'examples-literals' }
OCOpalExamples >> examplePushNonSpecialSmallInteger [
	self result: 10
]

{ #category : #'examples-variables' }
OCOpalExamples >> examplePushTemporaryVariable [
	| temporary |
	temporary := iVar.
	self result: temporary
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleRepeatEffect [
	<compilerOptions: #(+ #optionInlineRepeat)>
	| i |
	i := 1.
	[  
	i := i + 1. 
	i = 10
		ifTrue: [ ^ true ] ] repeat
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleRepeatValue [
	<compilerOptions: #(+ #optionInlineRepeat)>
	| i |
	i := 1.
	^ [ 
	i := i + 1.
	i = 10
		ifTrue: [ ^ true ] ] repeat 
]

{ #category : #'examples-simple' }
OCOpalExamples >> exampleReturn1plus2 [
	^1+2
]

{ #category : #'examples-simple' }
OCOpalExamples >> exampleReturn42 [
	^42
]

{ #category : #'examples-variables' }
OCOpalExamples >> exampleSelf [
	
	self result: self
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSelfReceiver [
	self foo
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlock [
	^[1]
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlockArgument1 [
	^[:a | a ] value: 1
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlockArgument2 [
	^[:a :b | a + b ] value: 1 value: 1
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlockArgument3 [
	^[:a :b :c | a + b + c ] value: 1 value: 1 value: 1
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlockArgument4 [
	^[:a :b :c :d | a + b + c  + d] value: 1 value: 1 value: 1 value: 1
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlockArgument5 [
	^[:a :b :c :d :e| a + b + c  + d + e] valueWithArguments: #(1 1 1 1 1)
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlockEmpty [
	^[] value
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlockLocal [
	^[ :each | | t |  t:= each. t   ] value: 5
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleSimpleBlockLocalIf [
	^true ifTrue: [ | hallo |  hallo := 1 . hallo]
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlockLocalIfNested [
	^true ifTrue: [| hallo |  [  hallo := 1 . hallo] value]
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleSimpleBlockLocalWhile [
	|a|
	a := true.
	^[: b | [a] whileTrue: [ | hallo |  a := false. hallo := 1 . hallo]] value: 1
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlockNested [
	| a match dict | 

	a  := #(a b c d).
	dict := Dictionary new.


	a doWithIndex: [:each :index |
		(match := a indexOf: each) > 0 ifTrue:
			[dict at: index put: (a at: match)]].

	^ dict
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlockReturn [
	[^1] value
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSimpleBlockiVar [
	^[iVar] value
]

{ #category : #'examples-variables' }
OCOpalExamples >> exampleSuper [
	self result: super
]

{ #category : #'examples-blocks' }
OCOpalExamples >> exampleSuperReceiver [
	super foo
]

{ #category : #'examples-variables' }
OCOpalExamples >> exampleTemporaryVariableAssignment [
	| temporary |
	temporary := 17.
	self message: temporary
]

{ #category : #'examples-variables' }
OCOpalExamples >> exampleThisContext [
	self result: thisContext
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleTimesRepeatEffect [
	| foo |
	foo := 1.
	5 timesRepeat: [ foo := foo + 3 ] . 
	^ foo
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleTimesRepeatValue [
	^ 5 timesRepeat: [ 1 + 2 ]   
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleToDoArgument [
	collection := OrderedCollection new.
	1 to: 5 do: [ :index |
		collection add:  [index]  ].
	 ^collection collect: [:each | each value]. 
	"#(1 2 3 4 5)"
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleToDoArgumentLimitIsExpression [
	| count sum |
	count := 10.
	sum := 0.
	1 to: count - 1 do: [ :each | sum := sum + each].
	^sum
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleToDoArgumentNotInlined [
	| block |
	block := [ :index |
		collection add: [ index ] ].
	1 to: 5 do: block.
	^collection "#(1 2 3 4 5)"
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleToDoInsideTemp [
	1 to: 5 do: [ :index | 
		| temp | 
		temp := index. 
		collection add: [ temp ] ].
	^collection "#(1 2 3 4 5)"
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleToDoInsideTempNotInlined [
	| block |
	block := [ :index | 
		| temp | 
		temp := index. 
		collection add: [ temp ] ].
	1 to: 5 do: block.
	^collection "#(1 2 3 4 5)"
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleToDoOutsideTemp [
	| temp |
	1 to: 5 do: [ :index | 
		temp := index. 
		collection add: [ temp ] ].
	^collection "#(5 5 5 5 5)"
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleToDoOutsideTempNotInlined [
	| block temp |
	block := [ :index | 
		temp := index. 
		collection add: [ temp ] ].
	1 to: 5 do: block.
	^collection "#(5 5 5 5 5)"
]

{ #category : #'examples-misc' }
OCOpalExamples >> exampleToDoValue [
	^ 1 to: 2 do: [:each | each]
	

]

{ #category : #'examples-misc' }
OCOpalExamples >> exampleToDoValueLimitExpression [
	^ 2 to: 3+4 do: [:each | each]
	

]

{ #category : #'examples-andor' }
OCOpalExamples >> exampleTrueAndAnything: argument [
	^ true and: [ argument ]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleTrueIfFalse [
	^true ifFalse: [1]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleTrueIfFalseIfTrue [
	^true ifFalse: [ self error ] ifTrue: [iVar := 'true']
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleTrueIfFalseWithEffect [
	^true ifFalse: [iVar := 17]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleTrueIfTrue [
	^true ifTrue: [1]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleTrueIfTrueIfFalse [
	^true ifTrue: [iVar := 'true'] ifFalse: [ self error ]
]

{ #category : #'examples-conditionals' }
OCOpalExamples >> exampleTrueIfTrueWithEffect [
	^true ifTrue: [iVar := 17]
]

{ #category : #'examples-andor' }
OCOpalExamples >> exampleTrueOrAnything: anything [
	^ true or: [ anything ]
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleWhileModificationAfterNotInlined [
	| index block |
	index := 0.
	block := [ 
		collection add: [ index ].
		index := index + 1 ].
	[ index < 5 ] whileTrue: block.
	^collection collect:  [:each | each value].
	"#(5 5 5 5 5)"
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleWhileModificationBefore [
	| index |
	collection := OrderedCollection new.
	index := 0.
	[ index < 5 ] whileTrue: [ 
		index := index + 1.
		collection add: [ index ] ].
	^collection collect:  [:each | each value].
	"#(5 5 5 5 5)"
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleWhileModificationBeforeNotInlined [
	| index block |
	index := 0.
	block := [ 
		index := index + 1.
		collection add: [ index ] ].
	[ index < 5 ] whileTrue: block.
	^collection collect: [:each | each value].
	"#(5 5 5 5 5)"
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleWhileNoModification [
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

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleWhileWithTemp [
	| index |
	index := 0.
	[ index < 5 ] whileTrue: [
		| temp |
		temp := index := index + 1.
		collection add: [ temp ] ].
	^collection collect: [:each | each value].
	"#(1 2 3 4 5)"
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleWhileWithTempNotInlined [
	| index block |
	index := 0.
	block := [
		| temp |
		temp := index := index + 1.
		collection add: [ temp ] ].
	[ index < 5 ] whileTrue: block.
	^collection collect: [:each | each value].
	"#(1 2 3 4 5)"
]

{ #category : #'examples-variables' }
OCOpalExamples >> exampleWithArgument: anArg [
	^ anArg
]

{ #category : #'examples-blocks-optimized' }
OCOpalExamples >> exampleiVar [
	iVar := 1.
	^iVar.
]

{ #category : #accessing }
OCOpalExamples >> iVar [
	^ iVar
]

{ #category : #accessing }
OCOpalExamples >> iVar: anInteger [ 
	iVar := anInteger
]

{ #category : #initialization }
OCOpalExamples >> initialize [
	collection := OrderedCollection new
]

{ #category : #accessing }
OCOpalExamples >> message: anObject [

	result := anObject
]

{ #category : #examples }
OCOpalExamples >> nestedBlocksRemoteInBlockCase1 [
	| block |
	block := [ | a b |
		[ a := b ].
		[ b := a ] ]
]

{ #category : #examples }
OCOpalExamples >> nestedBlocksRemoteInBlockCase2 [
	| block |
	block := [ 
		[ |a| [ a := 1] ].
		[ |b| [ b := 2] ] ]
]

{ #category : #examples }
OCOpalExamples >> nestedBlocksRemoteInBlockCase3 [
	| block |
	block := [ 
		[ |a| block := [ a := 1] ].
		[ |b| block := [ b := 2] ] ].
]

{ #category : #examples }
OCOpalExamples >> noRemoteBlockArgument [
	| block block1 block2 |
	block := [ :arg | | temp | temp := arg. [ temp ] ].
	block1 := block value: 1.
	block2 := block value: 2.


]

{ #category : #examples }
OCOpalExamples >> noRemoteBlockReturn [
	(self announcements at: self index ifAbsent: [ ^ self ]) 
		open.


]

{ #category : #examples }
OCOpalExamples >> noRemoteBlockTemp [
	| block block1 block2 |
	block := [ :arg | [ arg ] ].
	block1 := block value: 1.
	block2 := block value: 2.



]

{ #category : #examples }
OCOpalExamples >> noRemoteMethodTemp [
	| block1 block2 |
	block1 := self methodArgument: 1.
	block2 := self methodArgument: 2.


]

{ #category : #examples }
OCOpalExamples >> noRemoteReadInBlock [
	| a |
	a := 1.
	[ a ]


]

{ #category : #examples }
OCOpalExamples >> noRemoteReadNestedBlocks [   
	 [ |a| a := 1.
       [ a ]]

]

{ #category : #examples }
OCOpalExamples >> optimizedBlockReadInBlock [
	| t1 |
	[ t1 < 5 ] whileTrue: [ [ t1 ] ].

]

{ #category : #examples }
OCOpalExamples >> optimizedBlockWriteInBlock [
	| t1 |
	[ t1 < 5 ] whileTrue: [ t1 := 1 ].

]

{ #category : #examples }
OCOpalExamples >> optimizedBlockWriteInNestedBlock [
	| t1 |
	^[ [ t1 < 5 ] whileTrue: [ t1 := 1 ] ]

]

{ #category : #examples }
OCOpalExamples >> optimizedBlockWriteInNestedBlockCase2 [
	| t1 |
	(true) ifTrue: [ [ t1 < 5 ] whileTrue: [ t1 := 1 ] ]

]

{ #category : #examples }
OCOpalExamples >> optimizedBlockWriteInNestedBlockCase3 [
	| t1 |
	[(true) ifTrue: [ [ t1 < 5 ] whileTrue: [ t1 := 1 ] ] ]

]

{ #category : #examples }
OCOpalExamples >> optimizedBlockWriteInNestedBlockCase4 [
	| t1 |
	[(true) whileTrue: [ [ t1 < 5 ] whileTrue: [ t1 := 1 ] ] ]

]

{ #category : #examples }
OCOpalExamples >> optimizedBlockWriteReadInBlock [
	| t1 |
	[ t1 < 5 ] whileTrue: [ t1 := 1. [ t1 ] ].

]

{ #category : #examples }
OCOpalExamples >> optimizedBlockWrittenAfterClosedOverCase1 [
	| index |
	index := 0.
	[ index < 5 ] whileTrue: [
		| temp |
		[ temp ].
		temp := index := index + 1].
	^index

]

{ #category : #examples }
OCOpalExamples >> optimizedBlockWrittenAfterClosedOverCase2 [
	| index |
	index := 0.
	[ index < 5 ] whileTrue: [
		| temp |
		temp := index := index + 1.
		 [ temp ] ].

]

{ #category : #examples }
OCOpalExamples >> optimizedBlocksAndSameNameTemps [
	| s c |
	s := self isNil
			ifTrue: [| a | a := 1. a]
			ifFalse: [| a | a := 2. a].
	c := String new: s size.
	1 to: s size do:
		[:i| c at: i put: (s at: i)].
	^c
]

{ #category : #accessing }
OCOpalExamples >> result [

	^ result
]

{ #category : #accessing }
OCOpalExamples >> result: anObject [
	result := anObject
]

{ #category : #examples }
OCOpalExamples >> singleRemoteDifferentBlocksSameArgumentName [
	| b c z |
	b := [:a | 
		z := 2.
		z + a].
	c := [:a |
		z + a].
	^ (b value: 2) + (c value: 1)


]

{ #category : #examples }
OCOpalExamples >> singleRemoteMethodArgument [
	| temp block |
	temp := 0.
	block := [ [ temp ] ].
	temp := 1.
	block := block value.
	temp := 2.

]

{ #category : #examples }
OCOpalExamples >> singleRemoteReadNestedBlocks [   
	|a| 
	[  a := 1.
       [ a ]]

]

{ #category : #examples }
OCOpalExamples >> singleRemoteTempVar [
	| index block theCollection |
	index := 0.
	block := [ 
		theCollection add: [ index ].
		index := index + 1 ].
	[ index < 5 ] whileTrue: block.
	self assertValues: #(5 5 5 5 5)
]

{ #category : #examples }
OCOpalExamples >> singleRemoteTempVarWrittenAfterClosedOver [
	| index block |
	index := 0.
	block := [ index ].
	index := index + 1.

]

{ #category : #examples }
OCOpalExamples >> writtenAfterClosedOver [
	| a |      
	[ a ].
	a := 1
]
