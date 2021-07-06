"
Examples for RF
"
Class {
	#name : #ReflectivityExamples,
	#superclass : #Object,
	#instVars : [
		'ivar',
		'tag'
	],
	#classVars : [
		'ClassVar',
		'singleton'
	],
	#category : #'Reflectivity-Tests-Data'
}

{ #category : #options }
ReflectivityExamples class >> exampleMethodWithMetaLinkOptionsViaClass [
	<sampleInstance>
	^ 2 + 3
]

{ #category : #options }
ReflectivityExamples class >> metaLinkOptions [
	^{
	#exampleMethodWithMetaLinkOptionsViaClass -> #( + optionCompileOnLinkInstallation)
	}
]

{ #category : #initialization }
ReflectivityExamples >> compileTemporaryMethods [
	self class compile: 'methodToBeRemoved ^nil'.
	self class compile: 'methodToBeModified ^nil'.
	self class compile: 'stubMethod ^nil'
]

{ #category : #examples }
ReflectivityExamples >> exampleArray [
	^ {3}
]

{ #category : #examples }
ReflectivityExamples >> exampleAssignment [
	| temp |
	temp := (1 + 2).
	^temp
]

{ #category : #examples }
ReflectivityExamples >> exampleAssignmentClassVar [
	ClassVar := (1 + 2).
	^ClassVar
]

{ #category : #examples }
ReflectivityExamples >> exampleAssignmentIvar [
	ivar := (1 + 2).
	^ivar
]

{ #category : #examples }
ReflectivityExamples >> exampleAssignmentIvar: anObject [
	ivar := anObject.
	^ivar
]

{ #category : #examples }
ReflectivityExamples >> exampleBlock [
	^ [ 2 + 3 ] value 
]

{ #category : #examples }
ReflectivityExamples >> exampleBlockNoValue [
	^ [2 + 3]
]

{ #category : #examples }
ReflectivityExamples >> exampleBlockOptimized [
	"block with temp vector inside a optized block"
	^ 1==1 ifTrue: [ 
		  | var1 var2 |
		
		  #( 1 2 ) collect: [ :each | 
			  var1 := 1.
			  var2 := 1.
			  var1 + var2 ] ] 
]

{ #category : #examples }
ReflectivityExamples >> exampleBlockWithArg [
	^ [:a | a + 3] value: 2 
]

{ #category : #examples }
ReflectivityExamples >> exampleCascade [
	^1 sin; yourself
]

{ #category : #examples }
ReflectivityExamples >> exampleClassVarRead [
	^ClassVar
]

{ #category : #'as yet unclassified' }
ReflectivityExamples >> exampleDynamicArrayArgument [
	^ OrderedCollection new , {self}
]

{ #category : #examples }
ReflectivityExamples >> exampleGlobalRead [
	^GlobalForTesting
]

{ #category : #'examples - optimized' }
ReflectivityExamples >> exampleIfTrueIfFalse [

	| t |
	t := false.
	t ifTrue: [ self bar ] ifFalse: [ 'hello' ].
	^ 5 
]

{ #category : #examples }
ReflectivityExamples >> exampleIvarRead [
	^ivar
]

{ #category : #examples }
ReflectivityExamples >> exampleLazyInit [
	^ singleton ifNil: [singleton := self new initialize]
]

{ #category : #examples }
ReflectivityExamples >> exampleLiteral [
	^ 2
]

{ #category : #examples }
ReflectivityExamples >> exampleLiteralArray [
	^ #(1)
]

{ #category : #'as yet unclassified' }
ReflectivityExamples >> exampleLongNestedLiteralArray [
	^ #(#[1 0 9 0 1 0 13 0 9 0 17 0 10 0 21 0 13 0 25 0 15 0 29 0 17 0 33 0 18 0 33 0 19 0 33 0 20 0 33 0 21 0 33 0 22 0 33 0 23 0 33 0 24 0 33 0 25 0 65 0 27] #[0 0 6 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 10 0 3 0 4 0 8 0 12 0 14 0 28] #[1 0 25 0 15 0 69 0 27] #[1 0 9 0 1 0 13 0 9 0 17 0 10 0 21 0 13 0 25 0 15 0 73 0 17 0 33 0 18 0 33 0 19 0 33 0 20 0 33 0 21 0 33 0 22 0 33 0 23 0 33 0 24 0 33 0 25 0 65 0 27] #[0 0 14 0 2 0 3 0 4 0 6 0 7 0 8 0 11 0 12 0 14 0 28] #[1 0 77 0 4 0 0 0 28] #[0 0 18 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 22 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 26 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 30 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 34 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 38 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 42 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 46 0 3 0 4 0 8 0 12 0 14 0 28] #[1 0 81 0 2 0 50 0 3 0 50 0 4 0 85 0 6 0 50 0 8 0 89 0 11 0 50 0 12 0 50 0 14 0 50 0 28] #[1 0 54 0 3 0 54 0 4 0 93 0 7 0 54 0 8 0 54 0 12 0 54 0 14 0 54 0 28] #[1 0 77 0 4 0 97 0 14] #[1 0 9 0 1 0 13 0 9 0 17 0 10 0 21 0 13 0 25 0 15 0 101 0 18 0 101 0 19 0 101 0 20 0 101 0 21 0 101 0 22 0 101 0 23 0 101 0 24 0 101 0 25 0 65 0 27] #[1 0 9 0 1 0 58 0 3 0 13 0 9 0 17 0 10 0 21 0 13 0 25 0 15 0 105 0 17 0 33 0 18 0 33 0 19 0 33 0 20 0 33 0 21 0 33 0 22 0 33 0 23 0 33 0 24 0 33 0 25 0 109 0 26 0 65 0 27] #[1 0 9 0 1 0 13 0 9 0 17 0 10 0 21 0 13 0 25 0 15 0 113 0 17 0 33 0 18 0 33 0 19 0 33 0 20 0 33 0 21 0 33 0 22 0 33 0 23 0 33 0 24 0 33 0 25 0 65 0 27] #[1 0 9 0 1 0 13 0 9 0 17 0 10 0 58 0 12 0 21 0 13 0 25 0 15 0 105 0 17 0 33 0 18 0 33 0 19 0 33 0 20 0 33 0 21 0 33 0 22 0 33 0 23 0 33 0 24 0 33 0 25 0 117 0 26 0 65 0 27] #[1 0 9 0 1 0 13 0 9 0 17 0 10 0 21 0 13 0 25 0 15 0 121 0 18 0 121 0 19 0 121 0 20 0 121 0 21 0 121 0 22 0 121 0 23 0 121 0 24 0 121 0 25 0 65 0 27] #[0 0 62 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 66 0 3 0 4 0 8 0 12 0 14 0 28] #[1 0 70 0 3 0 77 0 4 0 70 0 12] #[0 0 125 0 3] #[1 0 77 0 4 0 129 0 8] #[0 0 133 0 12] #[0 0 74 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 137 0 5] #[0 0 78 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 141 0 5] #[1 0 9 0 1 0 13 0 9 0 17 0 10 0 21 0 13 0 25 0 15 0 145 0 18 0 145 0 19 0 145 0 20 0 145 0 21 0 145 0 22 0 145 0 23 0 145 0 24 0 145 0 25 0 65 0 27] #[1 0 9 0 1 0 13 0 9 0 17 0 10 0 21 0 13 0 25 0 15 0 149 0 18 0 149 0 19 0 149 0 20 0 149 0 21 0 149 0 22 0 149 0 23 0 149 0 24 0 149 0 25 0 65 0 27] #[0 0 82 0 3 0 4 0 8 0 12 0 14 0 28] #[0 0 86 0 3 0 4 0 8 0 12 0 14 0 28])
]

{ #category : #examples }
ReflectivityExamples >> exampleMessageSend [
	self tagExec: #yes
]

{ #category : #examples }
ReflectivityExamples >> exampleMethod [

	^ 2 + 3
]

{ #category : #examples }
ReflectivityExamples >> exampleMethod2 [

	2 + 3
]

{ #category : #examples }
ReflectivityExamples >> exampleMethodMultipleSites [
	self trace: Object new.
	^ 2 + 3
]

{ #category : #examples }
ReflectivityExamples >> exampleMethodWithMetaLinkOptions [
	<metaLinkOptions: #( +optionCompileOnLinkInstallation)>
	^ 2 + 3
]

{ #category : #'as yet unclassified' }
ReflectivityExamples >> examplePragma [
	<tudelu>
	^ 4
]

{ #category : #examples }
ReflectivityExamples >> examplePrimitiveMethod [
	"returns image path"
	<primitive: 121>
	^ 2 + 3
]

{ #category : #'as yet unclassified' }
ReflectivityExamples >> exampleProblematicMessage1 [
	^ {} == 2
]

{ #category : #'as yet unclassified' }
ReflectivityExamples >> exampleProblematicMessage2 [

	| c |
	c := { 1. 3. 4 } asSet.
	c ifEmpty: [ ^ Set new ].
	c size = 1 ifTrue: [ ^ c anyOne ].
	^ c
]

{ #category : #'as yet unclassified' }
ReflectivityExamples >> exampleProblematicMessage3 [

	| c |
	c := { 1 } asOrderedCollection.
	^ c size > -1 and: [ c = c ]
]

{ #category : #examples }
ReflectivityExamples >> exampleSelf [
	self
]

{ #category : #examples }
ReflectivityExamples >> exampleSendNoReturn [
	"just an example method that calls a mutation outside of a assignment or return node.
(needed for before link test with receiver reification"

	| collection |
	collection := OrderedCollection newFrom: {3 . 4}.
	collection removeAt:1.
]

{ #category : #examples }
ReflectivityExamples >> exampleSendTwoArgs [
	^ Array with: 1 with: 2
]

{ #category : #examples }
ReflectivityExamples >> exampleTwoSends [
	3 + 4.
	^ 2 + 3
]

{ #category : #'examples - optimized' }
ReflectivityExamples >> exampleWhileFalse [
	| t |
	t := 1.
	[ t > 10 ] whileFalse: [ t := t + 1].
	^t
]

{ #category : #examples }
ReflectivityExamples >> exampleWithArg: anArg [
	^ 2 + anArg
]

{ #category : #initialization }
ReflectivityExamples >> initialize [
	ivar := 33.
	ClassVar := #AClassVar
]

{ #category : #initialization }
ReflectivityExamples >> removeTemporaryMethods [
	
	self class removeSelector: #methodToBeRemoved.
	self class removeSelector: #methodToBeModified.
	self class removeSelector: #stubMethod
]

{ #category : #tagging }
ReflectivityExamples >> tag [
	^tag
]

{ #category : #tagging }
ReflectivityExamples >> tagExec: anObject [
	tag := anObject
]
