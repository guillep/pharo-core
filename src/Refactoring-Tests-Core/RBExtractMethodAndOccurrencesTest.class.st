Class {
	#name : #RBExtractMethodAndOccurrencesTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #running }
RBExtractMethodAndOccurrencesTest >> setUp [ 
	super setUp.
	model := self extractMethodTestData.
]

{ #category : #'failure tests' }
RBExtractMethodAndOccurrencesTest >> testBadInterval [
	|class|
	class := model classNamed: #MyClassA.
	self
		shouldFail:
			(RBExtractMethodAndOccurrences 
				model: model
				extract: (127 to: 136)
				from: #myMethod
				in:  class)
]

{ #category : #tests }
RBExtractMethodAndOccurrencesTest >> testExtractMethodWithArgsAndOcurrences [
	|class refactoring|
	class := model classNamed: #MyClassA.
	refactoring := RBExtractMethodAndOccurrences
				model: model 
				extract: (114 to: 231)
				from: #displayName
				in: class.
	self setupSearchInAllHierarchyFor: refactoring toReturn: true.
	self setupMethodNameFor: refactoring toReturn: #stringArg:streamArg:.
	self executeRefactoring: refactoring.
	self assert: (class parseTreeFor: #stringArg:streamArg:) equals: (self parseMethod: 'stringArg: string streamArg: nameStream

	nameStream
		nextPutAll: string;
		nextPutAll: '' (''.
	self problemCount printOn: nameStream.
	nameStream nextPut: $)').
	self assert: (class parseTreeFor: #displayName) equals: (self parseMethod: 'displayName

	| nameStream string |
	string := self name.
	nameStream := WriteStream on: (String new: 64).
	self stringArg: string streamArg: nameStream.
	^ nameStream contents').
	class := model classNamed: #MyClassB.
	self assert: (class parseTreeFor: #anotherMethod) equals: (self parseMethod: 'anotherMethod

	| aStream |
	aStream := WriteStream on: (String new: 128).
	self stringArg: ''dfgdf'' streamArg: aStream').
]

{ #category : #tests }
RBExtractMethodAndOccurrencesTest >> testExtractSimpleMethodAndOcurrences [
	|class refactoring|
	class := model classNamed: #MyClassA.
	refactoring := RBExtractMethodAndOccurrences
				model: model 
				extract: (282 to: 302)
				from: #myMethod
				in: class.
	self setupSearchInAllHierarchyFor: refactoring toReturn: true.
	self setupMethodNameFor: refactoring toReturn: #extractedMethod.
	self executeRefactoring: refactoring.
	self assert: (class parseTreeFor: #extractedMethod) equals: (self parseMethod: 'extractedMethod
	^ currentChar isLetter.').
	self assert: (class parseTreeFor: #myMethod) equals: (self parseMethod: 'myMethod

	| token |
	token := (String new: 100) writeStream.
	[ self extractedMethod ] whileTrue: [ 
		token nextPut: currentChar.
		self methodWithArg: self extractedMethod.
		self bar ].
	self extractedMethod.
	$3 isLetter.
	self extractedMethod.
	token := self extractedMethod.
	token := self extractedMethod example.
	^ token contents').
	class := model classNamed: #MyClassB.
	self assert: (class parseTreeFor: #exampleMethod) equals: (self parseMethod: 'exampleMethod

	^ self extractedMethod not').
	class := model classNamed: #MyClassC.
	self assert: (class parseTreeFor: #methodWithArg:) equals: (self parseMethod: 'methodWithArg: anArg

	(self extractedMethod and: [ anArg isDecimal ]) ifTrue: [ ^ self ].
	^ nil')
]
