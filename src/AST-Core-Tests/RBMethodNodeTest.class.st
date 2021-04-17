"
SUnit tests for RBMethodNode
"
Class {
	#name : #RBMethodNodeTest,
	#superclass : #RBParseTreeTest,
	#category : #'AST-Core-Tests-Nodes'
}

{ #category : #helpers }
RBMethodNodeTest >> methodWithArg: someArgName and: someAnotherArgName [

]

{ #category : #helpers }
RBMethodNodeTest >> parseMethod: aString [
	^ self parserClass parseMethod: aString
]

{ #category : #tests }
RBMethodNodeTest >> testAddingMethodProperties [

	| ast |
	ast := self parseMethod: 'one ^ self'.
	self assert: ast methodProperties isNil. 
	
	ast methodPropertyAt: #testKey put: #testValue.
	ast methodPropertyAt: #testKey2 put: #testValue2.
	self assert: (ast methodPropertyAt: #testKey) equals: #testValue.
	self assert: (ast methodPropertyAt: #testKey2) equals: #testValue2.
	self assert: ast methodProperties class equals: AdditionalMethodState
]

{ #category : #tests }
RBMethodNodeTest >> testBlockHasArguments [

	| tree |
	tree := self parseMethod: 'foo 
		[ :arg | 
		abd + cde 
		]'.

	self assert: tree body statements first hasArguments
	

]

{ #category : #tests }
RBMethodNodeTest >> testBlockHasTemporaries [

	| tree |
	tree := self parseMethod: 'foo 
		[ 
		| tmp |
		abd + cde 
		]'.

	self deny: tree hasTemporaries.
	self assert: tree body statements first hasTemporaries
	

]

{ #category : #tests }
RBMethodNodeTest >> testBlockHeadIsNotEmpty [

	| tree |
	tree := self parseMethod: 'foo 
		[ :arg | 
		abd + cde 
		]'.

	self assert: tree body statements first headIsNotEmpty 
	

]

{ #category : #tests }
RBMethodNodeTest >> testBlockHeadIsNotEmpty2 [

	| tree |
	tree := self parseMethod: 'foo 
		[ "blbl" 
		abd + cde 
		]'.

	self assert: tree body statements first headIsNotEmpty 
	

]

{ #category : #tests }
RBMethodNodeTest >> testBlockHeadIsNotEmpty3 [

	| tree |
	tree := self parseMethod: 'foo 
		[ 
		abd + cde 
		]'.

	self deny: tree body statements first headIsNotEmpty 
	

]

{ #category : #tests }
RBMethodNodeTest >> testCachingMethodArguments [

	| ast |
	ast := (self class >> #methodWithArg:and:) ast.
	ast propertyAt: #argumentNames put: #(wrongArg wrongArg2).
	
	ast ensureCachedArgumentNames.
	self assert: (ast methodPropertyAt: #argumentNames) equals: #(someArgName someAnotherArgName)
]

{ #category : #'testing-comments' }
RBMethodNodeTest >> testCommentedMethodHasComments [

	| tree |
	tree := self parseMethod: 'foo: abd bar: cde  
		"this is comment"
		"this is another comment"
^ abd + cde'.

	self assert: tree hasComments.
	

]

{ #category : #'testing-comments' }
RBMethodNodeTest >> testCommentsParent [
	"Test if comment has a parent"
	self
		assert: (self class >> #testCommentsParent) ast comments first parent selector
		equals: #testCommentsParent.
]

{ #category : #tests }
RBMethodNodeTest >> testHasArguments [

	| ast |
	ast := self parseMethod: 'foo: arg'.
	self assert: ast hasArguments
]

{ #category : #'testing-comments' }
RBMethodNodeTest >> testHasComments [

	| tree |
	tree := self parseMethod: 'foo: abd bar: cde  
		"this is comment"
		"this is another comment"
^ abd + cde'.

	self assert: tree hasComments.
	
	tree := self parseMethod: 'foo: abd bar: cde  
^ abd + cde'.

	self deny: tree hasComments.
	

]

{ #category : #'tests - primitives' }
RBMethodNodeTest >> testIsPrimitive [
	"see other testPrimitive... tests"
	"This test brings the test button in the browser and test negatively
	The others are for each specific kind of primitive:..."
	| ast |
	ast := (SmallInteger >> #+) ast.
	self assert: ast isPrimitive.
	ast := (Bitmap >> #primFill:) ast.
	self assert: ast isPrimitive.
	
	ast := (Integer >> #+) ast.
	self deny: ast isPrimitive.
]

{ #category : #tests }
RBMethodNodeTest >> testMethodClass [
	| ast |
	ast :=  (OrderedCollection>>#do:) ast.
	self assert: ast methodClass equals: OrderedCollection.
	"if we create an AST, the class should be nil"
	ast := RBMethodNode selector: #tt body: RBSelectorNode new. 
	self assert: ast methodClass equals: nil
]

{ #category : #'testing-comments' }
RBMethodNodeTest >> testMethodWithCommentsAndEmptyStatements [

	| tree |
	tree := self parseMethod: 'foo: abd bar: cde  
		"this is comment".
		"this is another comment"'.

	self assert: tree comments first contents equals: 'this is comment'.
	self assert: tree body comments first contents equals: 'this is another comment'
]

{ #category : #tests }
RBMethodNodeTest >> testMethodsHasTemporaries [

	| tree |
	tree := self parseMethod: 'foo: abd bar: cde  
		| tmp |
^ abd + cde'.

	self assert: tree hasTemporaries
	

]

{ #category : #tests }
RBMethodNodeTest >> testNodeForOffsetAssignment [
	"test the case of a Assignment"

	| source ast foundNode |
	source := 'method Object := Class'.
	ast := self parserClass parseMethod: source.
	foundNode := ast nodeForOffset: 9.
	self assert: foundNode class identicalTo: RBVariableNode.
	foundNode := ast nodeForOffset: 14.
	self assert: foundNode class identicalTo: RBAssignmentNode.
	foundNode := ast nodeForOffset: 19.
	self assert: foundNode class identicalTo: RBVariableNode
]

{ #category : #tests }
RBMethodNodeTest >> testNodeForOffsetMessage [
	"test the case of Messages"

	| source ast foundNode |
	source := 'method Object doit: Class'.
	ast := self parserClass parseMethod: source.
	foundNode := ast nodeForOffset: 9.
	self assert: foundNode class identicalTo: RBVariableNode.
	foundNode := ast nodeForOffset: 14.
	self assert: foundNode class identicalTo: RBMessageNode.
	foundNode := ast nodeForOffset: 22.
	self assert: foundNode class identicalTo: RBVariableNode
]

{ #category : #tests }
RBMethodNodeTest >> testNodeForOffsetTempDefinition [
	"test the case of Messages"

	| source ast foundNode |
	source := 'method | temp |'.
	ast := self parserClass parseFaultyMethod: source.
	foundNode := ast nodeForOffset: 12.
	self assert: foundNode class identicalTo: RBVariableNode
]

{ #category : #tests }
RBMethodNodeTest >> testNodeForOffsetVar [
	"test the case of a variable"

	| source ast foundNode |
	source := 'method Object'.
	ast := self parserClass parseMethod: source.
	foundNode := ast nodeForOffset: 9.
	self assert: foundNode class identicalTo: RBVariableNode
]

{ #category : #tests }
RBMethodNodeTest >> testOffsetIsComment [
	self deny: ((OrderedCollection>>#do:) ast offsetIsComment: 3).

	self assert: ((OrderedCollection>>#do:) ast offsetIsComment: 13).
	self assert: ((OrderedCollection>>#do:) ast offsetIsComment: 62).

	self deny: ((OrderedCollection>>#do:) ast offsetIsComment: 63).
	self deny: ((OrderedCollection>>#do:) ast offsetIsComment: 70).
]

{ #category : #'tests - primitives' }
RBMethodNodeTest >> testPrimitiveErrorIsPrimitive [

	"isPinnedInMemory
		<primitive: 183 error: ec>
		^self primitiveFailed
	"
	
	| ast |
	ast := (Object >> #isPinnedInMemory) ast.
	self assert: ast isPrimitive.

	ast := (MirrorPrimitives class >> #makeObject:readOnly:) ast.
	self assert: ast isPrimitive.
	
]

{ #category : #'tests - primitives' }
RBMethodNodeTest >> testPrimitiveIsPrimitive [
	"primFill: aPositiveInteger
		<primitive: 145>
		self errorImproperStore."
	
	| ast |
	ast := (SmallInteger >> #+) ast.
	self assert: ast isPrimitive.
	ast := (Bitmap >> #primFill:) ast.
	self assert: ast isPrimitive.
	
]

{ #category : #'tests - primitives' }
RBMethodNodeTest >> testPrimitiveModuleErrorIsPrimitive [
	"
	primClosedir: directoryPointerBytes
		<primitive: 'primitiveClosedir' module: 'FileAttributesPlugin' error: error>
		...
	"
	| ast |
	ast := (File class >> #primClosedir:) ast.
	self assert: ast isPrimitive.


	
]

{ #category : #'tests - primitives' }
RBMethodNodeTest >> testPrimitiveModuleIsPrimitive [
	"
	stringHash: aString initialHash: speciesHash

		| stringSize hash low |
		<primitive: 'primitiveStringHash' module: 'MiscPrimitivePlugin'>

		<var: #aHash declareC: 'int speciesHash'>
		<var: #aString declareC: 'unsigned char *aString'>

	"
	| ast |
	ast := (ByteString class >> #stringHash:initialHash:) ast.
	self assert: ast isPrimitive.

	ast := (Integer >> #digitSubtract:) ast.
	self assert: ast isPrimitive.

	
]

{ #category : #tests }
RBMethodNodeTest >> testSelectorAndArgumentNames [

	self assert: (self parseMethod: 'one ^ self') selectorAndArgumentNames equals: 'one'.
	self assert: (self parseMethod: 'one:   aOne ^ self') selectorAndArgumentNames equals: 'one:   aOne'.
	self assert: (self parseMethod: 'one:   aOne two:   aTwo ^ self') selectorAndArgumentNames equals: 'one:   aOne two:   aTwo'.
	self assert: (self parseMethod: '*   aOne') selectorAndArgumentNames equals: '*   aOne'.
	self assert: (self parseMethod: '**   aOne') selectorAndArgumentNames equals: '**   aOne'
]

{ #category : #tests }
RBMethodNodeTest >> testSizeOfSignatureOfBinaryMethod [
	| tree |
	tree := self
		parseMethod:
			' + x   
^ 2 + 3'.
	self assert: tree conceptualSelectorSize equals: '+' size.
	self assert: tree conceptualArgumentSize equals: 'x'  size.
	self assert: tree conceptualSignatureSize equals: '+' size + tree conceptualArgumentSize + 1
]

{ #category : #tests }
RBMethodNodeTest >> testSizeOfSignatureOfKeywordsMethod [
	| tree |
	tree := self
		parseMethod:
			'foo: abd bar: cde  
^ abd + cde'.
	self assert: tree conceptualSelectorSize equals: 'foo:bar:' size.
	self assert: tree conceptualArgumentSize equals: 'abdcde' size.
	self
		assert: tree conceptualSignatureSize
		equals: 'abdcde' size + 'foo:bar:' size + 3.
	
]

{ #category : #tests }
RBMethodNodeTest >> testSizeOfSignatureOfUnaryMethod [
	| tree |
	tree := self
		parseMethod:
			'foo  
^ 2 + 3'.
	self assert: tree conceptualSelectorSize equals: 'foo' size.
	self assert: tree conceptualArgumentSize isZero.
	self assert: tree conceptualSignatureSize equals: 'foo' size
]

{ #category : #'testing-comments' }
RBMethodNodeTest >> testUncommentMethodDoesNotHaveComments [

	| tree |
	tree := self parseMethod: 'foo: abd bar: cde  
^ abd + cde'.

	self deny: tree hasComments.
	

]
