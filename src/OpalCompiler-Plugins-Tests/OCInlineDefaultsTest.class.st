Class {
	#name : #OCInlineDefaultsTest,
	#superclass : #TestCase,
	#category : #'OpalCompiler-Plugins-Tests'
}

{ #category : #'as yet unclassified' }
OCInlineDefaultsTest >> compile: aString [ 
	
	^ OpalCompiler new
		environment: self class environment;
		compile: aString
]

{ #category : #tests }
OCInlineDefaultsTest >> testIfNotNilWithoutBlocksAndNonLiteralCompileTheSameThanWithBlocks [

	| m1 m2 |
	m1 := self compile: 'm1:a a ifNotNil: a'.
	m2 := self compile: 'm1:a a ifNotNil: [:x | a cull: x]'.
	
	self assert: m1 bytecode equals: m2 bytecode
]

{ #category : #tests }
OCInlineDefaultsTest >> testIfNotNilWithoutBlocksCompileTheSameThanWithBlocks [

	| m1 m2 |
	m1 := self compile: 'm1:a a ifNotNil: 17'.
	m2 := self compile: 'm1:a a ifNotNil: [:x | 17]'.
	
	self assert: m1 bytecode equals: m2 bytecode
]

{ #category : #tests }
OCInlineDefaultsTest >> testIfTrueIfFalseWithoutBlocksCompileTheSameThanWithBlocks [

	| m1 m2 |
	m1 := self compile: 'm1:a a ifTrue: 17 ifFalse: a'.
	m2 := self compile: 'm1:a a ifTrue: [17] ifFalse: [a value]'.
	
	self assert: m1 bytecode equals: m2 bytecode
]
