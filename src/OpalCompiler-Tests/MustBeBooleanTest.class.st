"
This class tests sending #ifTrue: and similar methods to non-Booleans.

See the comment of MyBooleanObject for more information
"
Class {
	#name : #MustBeBooleanTest,
	#superclass : #TestCase,
	#category : #'OpalCompiler-Tests-Misc'
}

{ #category : #tests }
MustBeBooleanTest >> testAnd [
	| myBooleanObject |
	
	myBooleanObject := MyBooleanObject new.
	self deny: (myBooleanObject and: [true])
]

{ #category : #tests }
MustBeBooleanTest >> testDNU [
	| code |
	code := [ (true ifFalse:[]) ifTrue:[] ].
	self should: code raise: MessageNotUnderstood .
	code on: MessageNotUnderstood do: [ :error | self assert: error receiver isNil. 
			self assert: error message selector equals: #ifTrue:]
]

{ #category : #tests }
MustBeBooleanTest >> testIfTrueEffect [
	| temp fakeBool |
	
	fakeBool := MyBooleanObject new.
	temp := 1.
	fakeBool ifTrue: [ temp := 5 + 3 + 1 ].
	self assert: temp equals: 9
]

{ #category : #tests }
MustBeBooleanTest >> testIfTrueValue [
	| myBooleanObject |
	
	self assert: (MyBooleanObject new ifTrue: [ 1 + 2 ]) equals: '3 sent from my boolean object'.
	myBooleanObject := MyBooleanObject new.
	self assert: (myBooleanObject ifTrue: [ 1 + 2 ]) equals: '3 sent from my boolean object'.
]

{ #category : #tests }
MustBeBooleanTest >> testIfTrueValueLiteral [
	| myBooleanObject result |
	myBooleanObject := MyBooleanObject new.
	"check the case where the block just returna a literal"
	result := myBooleanObject
		ifTrue: [ 5 ].
	self assert: result equals: '5 sent from my boolean object'.
	"now do it with the expression evaluate for effect"
	self should: [self class compiler evaluate: '1 ifTrue: [ 5 ]. 1'] raise: MessageNotUnderstood.
]

{ #category : #tests }
MustBeBooleanTest >> testIfTrueWithClosureAfterJump [
	"A closure is a multibyte instruction, that should not be
	1) confused for an ending jump in ifTrue/ifFalse structure
	2) set as jumptarget, or have PC manually set to, none but its first byte."
	| myBooleanObject |
	myBooleanObject := MyBooleanObject new.
	myBooleanObject
		ifTrue: [ 4 + 3 ].
	[ :string | 
	self assert: 'a ' , string equals: 'a 5' ] value: '5'
]

{ #category : #tests }
MustBeBooleanTest >> testMultipleOrsInMethod [

	| values r1 r2 |
	values := OrderedCollection new.
	10 timesRepeat: [ values add: MyBooleanObject new ].

	r1 := values select: [ :each | each or: [ false ] ].
	self assert: r1 isEmpty.

	r2 := values select: [ :each | each or: [ true ] ].
	self assert: r2 size equals: 10
]

{ #category : #tests }
MustBeBooleanTest >> testOr [
	| myBooleanObject |
	
	myBooleanObject := MyBooleanObject new.
	self assert: (myBooleanObject or: [true])
]

{ #category : #tests }
MustBeBooleanTest >> testSemanticAnalysisCleaned [
	"this used to fail as we did not clean semantic analysis data before recompiling"
	
	self should: [self shouldnt: [1 ifTrue:  [[:dir :path|
                        [ path]]]] raise: KeyNotFound ] raise: MessageNotUnderstood.
]

{ #category : #tests }
MustBeBooleanTest >> testToDo [
	| variable |
	
	variable := #(1 2 3).
	"in this case, we end up sending #ifTrue: to the Array"
	self should: [(1 to: variable do: [:index |])] raise: MessageNotUnderstood
]

{ #category : #tests }
MustBeBooleanTest >> testWhile [
	| myFlag |
	self should: [[ nil ] whileFalse: [myFlag := true ]] raise: MessageNotUnderstood.
]
