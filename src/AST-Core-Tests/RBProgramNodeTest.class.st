"
SUnit tests for RBProgramNode
"
Class {
	#name : #RBProgramNodeTest,
	#superclass : #RBParseTreeTest,
	#instVars : [
		'node'
	],
	#category : #'AST-Core-Tests-Nodes'
}

{ #category : #accessing }
RBProgramNodeTest class >> packageNamesUnderTest [
	^ #('AST-Core')
]

{ #category : #accessing }
RBProgramNodeTest >> getAllNodesFromAST [
	| methodText |
	methodText :=
	'toto
		"First comment"
		| temp varaibles |
		"Second comment"
		assignement := " Third comment " #node. 
		"Fourth comment"
		message "Fifth comment", ''node''.
		"Sixth comment" cascade node; nodeux "Seventh comment"; notrois.
		^ "return" nil
		'.
	^ RBParser parseMethod: methodText.
]

{ #category : #accessing }
RBProgramNodeTest >> getMethodString [
	^'toto
		"First comment"
		| temp varaibles |
		"Second comment"
		assignement := " Third comment " #node. 
		"Fourth comment"
		message "Fifth comment", ''node''.
		"Sixth comment" cascade node; nodeux "Seventh comment"; notrois.
		^ "return" nil
		'.
]

{ #category : #accessing }
RBProgramNodeTest >> node [
	^ node ifNil: [ node := RBProgramNode new ]
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testAddNode [
	| tree treeNode |
	tree := self parseExpression: '1. 2'.
	treeNode := tree addNode: (self parseExpression: '3').
	self assert: (self parseExpression: '1. 2. 3') equals: tree.
	self assert: tree statements last equals: treeNode.
	
	tree := self parseExpression: '{ 1. 2 }'.
	treeNode := tree addNode: (self parseExpression: '3').
	self assert: (self parseExpression: '{ 1. 2. 3 }') equals: tree.
	self assert: tree statements last equals: treeNode
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testAddNodeBefore [
	| tree treeNode |
	tree := self parseExpression: '1. 3'.
	treeNode := tree
		addNode: (self parseExpression: '2')
		before: tree statements last.
	self assert: (self parseExpression: '1. 2. 3') equals: tree.
	self assert: (tree statements at: 2) equals: treeNode.
	
	tree := self parseExpression: '{ 1. 3 }'.
	treeNode := tree
		addNode: (self parseExpression: '2')
		before: tree statements last.
	self assert: (self parseExpression: '{ 1. 2. 3 }') equals: tree.
	self assert: (tree statements at: 2) equals: treeNode
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testAddNodeFirst [
	| tree treeNode |
	tree := self parseExpression: '2. 3'.
	treeNode := tree addNodeFirst: (self parseExpression: '1').
	self assert: (self parseExpression: '1. 2. 3') equals: tree.
	self assert: tree statements first equals: treeNode.
	
	tree := self parseExpression: '{ 2. 3 }'.
	treeNode := tree addNodeFirst: (self parseExpression: '1').
	self assert: (self parseExpression: '{ 1. 2. 3 }') equals: tree.
	self assert: tree statements first equals: treeNode
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testAddNodes [
	| tree treeNodes |
	tree := self parseExpression: '1. 2'.
	treeNodes := tree addNodes: (self parseExpression: '3. 4') statements.
	self assert: (self parseExpression: '1. 2. 3. 4') equals: tree.
	self assert: (tree statements at: 3) equals: treeNodes first.
	self assert: (tree statements at: 4) equals: treeNodes last.
	
	tree := self parseExpression: '{ 1. 2 }'.
	treeNodes := tree addNodes: (self parseExpression: '3. 4') statements.
	self assert: (self parseExpression: '{ 1. 2. 3. 4 }') equals: tree.
	self assert: (tree statements at: 3) equals: treeNodes first.
	self assert: (tree statements at: 4) equals: treeNodes last
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testAddNodesBefore [
	| tree treeNodes |
	tree := self parseExpression: '1. 4'.
	treeNodes := tree 
		addNodes: (self parseExpression: '2. 3') statements
		before: tree statements last.
	self assert: (self parseExpression: '1. 2. 3. 4') equals: tree.
	self assert: (tree statements at: 2) equals: treeNodes first.
	self assert: (tree statements at: 3) equals: treeNodes last.
	
	tree := self parseExpression: '{ 1. 4 }'.
	treeNodes := tree 
		addNodes: (self parseExpression: '2. 3') statements
		before: tree statements last.
	self assert: (self parseExpression: '{ 1. 2. 3. 4 }') equals: tree.
	self assert: (tree statements at: 2) equals: treeNodes first.
	self assert: (tree statements at: 3) equals: treeNodes last
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testAddNodesFirst [
	| tree treeNodes |
	tree := self parseExpression: '3. 4'.
	treeNodes := tree addNodesFirst: (self parseExpression: '1. 2') statements.
	self assert: (self parseExpression: '1. 2. 3. 4') equals: tree.
	self assert: (tree statements at: 1) equals: treeNodes first.
	self assert: (tree statements at: 2) equals: treeNodes last.
	
	tree := self parseExpression: '{ 3. 4 }'.
	treeNodes := tree addNodesFirst: (self parseExpression: '1. 2') statements.
	self assert: (self parseExpression: '{ 1. 2. 3. 4 }') equals: tree.
	self assert: (tree statements at: 1) equals: treeNodes first.
	self assert: (tree statements at: 2) equals: treeNodes last
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testAddReturn [
	| tree return |
	tree := self parseExpression: '1. 2'.
	return := tree addReturn.
	self assert: tree statements last equals: return.
	self assert: (self parseExpression: '1. ^ 2') equals: tree.
	
	tree := self parseExpression: '3. ^ 4'.
	return := tree addReturn.
	self assert: tree statements last equals: return.
	self assert: (self parseExpression: '3. ^ 4') equals: tree
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testAddSelfReturn [
	| tree return |
	tree := self parseExpression: '1. 2'.
	return := tree addSelfReturn.
	self assert: tree statements last equals: return.
	self assert: (self parseExpression: '1. 2. ^ self') equals: tree.
	
	tree := self parseExpression: '3. ^ 4'.
	return := tree addSelfReturn.
	self assert: tree statements last equals: return.
	self assert: (self parseExpression: '3. ^ 4') equals: tree
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testAddTemporariesNamed [
	| tree variables |
	tree := self parseExpression: '| a | a'.
	variables := tree addTemporariesNamed: #('b' 'c').
	self assert: variables first isVariable.
	self assert: variables first name equals: 'b'.
	self assert: variables second isVariable.
	self assert: variables second name equals: 'c'.
	self assert: tree temporaries second equals: variables first.
	self assert: tree temporaries last equals: variables second
	
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testAddTemporaryNamed [
	| tree variable |
	tree := self parseExpression: '| a | a'.
	variable := tree addTemporaryNamed: 'b'.
	self assert: variable isVariable.
	self assert: variable name equals: 'b'.
	self assert: tree temporaries last equals: variable
]

{ #category : #'tests - accessing' }
RBProgramNodeTest >> testAllComments [
	"Testing the AST comments objects. I am the first comment to be found in this test"
	self
		assert: (RBProgramNodeTest >> #testAllComments) ast allComments first contents
		equals: 'Testing the AST comments objects. I am the first comment to be found in this test'.
	"Next test assumes this comment it's not a string like in #testComments..."
	self 
		assert: (RBProgramNodeTest >> #testAllComments) ast allComments second isString
		equals: false
]

{ #category : #tests }
RBProgramNodeTest >> testAllParents [
	"check that we get all parents of a program node"

	| me parentsOf7 |
	[ :a | a + 7 ].
	me := self class >> #testAllParents.
	parentsOf7 := (me ast allChildren select: [ :n | 
		               n isLiteralNode and: [ n value = 7 ] ]) first
		              allParents.
	self assert: parentsOf7 last selector equals: #+.
	self assert: parentsOf7 first equals: me ast
]

{ #category : #tests }
RBProgramNodeTest >> testAllStatementsAssignment [
	| tree  |
	tree := self parserClass parseMethod: 
			'methodName
				
				x := 33'.

	self assert: tree allStatements size equals: 1.
]

{ #category : #tests }
RBProgramNodeTest >> testAllStatementsBlockWithReturn [
	| tree |
	tree := self parserClass parseMethod: 
			'methodName
				^ [ ^ self ] '.
	self assert: tree allStatements size equals: 2
 
]

{ #category : #tests }
RBProgramNodeTest >> testAllStatementsBlockWithTemps [
	| tree |
	tree := self parserClass parseMethod: 
			'methodName
				^ [ | tmp | tmp := 88 ] '.
	self assert: tree allStatements size equals: 3.
 
]

{ #category : #tests }
RBProgramNodeTest >> testAllStatementsDynamicArray [
	| tree |
	tree := self parserClass parseMethod: 
			'methodName
				
				{ 1 . self send1 . self send2} '.

	self assert: tree allStatements size equals: 4.
]

{ #category : #tests }
RBProgramNodeTest >> testAllStatementsReturns [
	| tree stats |
	tree := self parserClass parseMethod: 
			'methodName
				^ self '.
	stats := tree allStatements.
	self assert: stats size equals: 1
]

{ #category : #tests }
RBProgramNodeTest >> testAllStatementsReturnsMultiple [
	| tree stats |
	tree := self parserClass parseMethod: 
			'methodName
				1 ifTrue: [ ^ self ].
				^ self '.
	stats := tree allStatements.
	self assert: stats size equals: 3
 
]

{ #category : #tests }
RBProgramNodeTest >> testAllStatementsSimpleBlock [
	| tree stats |
	tree := self parserClass parseMethod: 
			'methodName
				^ [ 8 + 4 ] '.
	stats := tree allStatements.
	self assert: stats size equals: 2
]

{ #category : #tests }
RBProgramNodeTest >> testAllStatementsTemps [
	| tree stats |
	tree := self parserClass parseMethod: 
			'methodName
				| tmp1 tmp2 |
				tmp1 + tmp2'.
	stats := tree allStatements.
	self assert: stats size equals: 3
]

{ #category : #tests }
RBProgramNodeTest >> testAllStatementsTwoMessages [
	| tree stats |
	tree := self parserClass parseMethod: 
			'methodName
				
				1 send1 send2'.
	stats := tree allStatements.
	self assert: stats size equals: 1.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeFirstTempsAndFirstCommentGivesVariableNode [
	| ast string start |
	string := '"First comment"'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (start to: start + string size + 6).
	self assert: ast isVariable.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeForCommentInbetweenStatements [
	| ast string start |
	string := '"Fourth comment"'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (start to: start + string size - 1).
	self assert: ast isCommentNode.
	self assert: ast contents equals: 'Fourth comment'.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeForCommentInsideACascadeNodeOnMessageNode [
	| ast string start |
	string := '"Seventh comment"'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (start to: start + string size - 1).
	self assert: ast isCommentNode.
	self assert: ast contents equals: 'Seventh comment'.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeForCommentInsideACascadeNodeOnReceiver [
	| ast string start |
	string := '"Sixth comment"'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (start to: start + string size - 1).
	self assert: ast isCommentNode.
	self assert: ast contents equals: 'Sixth comment'.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeForCommentInsideAssignementNode [
	| ast string start |
	string := '" Third comment "'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (start to: start + string size - 1).
	self assert: ast isCommentNode.
	self assert: ast contents equals: ' Third comment '.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeForCommentInsideMessageNode [
	| ast string start |
	string := '"Fifth comment"'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (start to: start + string size - 1).
	self assert: ast isCommentNode.
	self assert: ast contents equals: 'Fifth comment'.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeForCommentInsideMethodNode [
	| ast string start |
	string := '"First comment"'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (start to: start + string size - 1).
	self assert: ast isCommentNode.
	self assert: ast contents equals: 'First comment'.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeForCommentInsideReturnNode [
	| ast string start |
	string := '"return"'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (start to: start + string size - 1).
	self assert: ast isCommentNode.
	self assert: ast contents equals: 'return'.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeForCommentInsideSequenceNode [
	| ast string start |
	string := '"Second comment"'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (start to: start + string size - 1).
	self assert: ast isCommentNode.
	self assert: ast contents equals: 'Second comment'.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeInsideAssignementGivesSelectedValue [
	| ast string start |
	string := '#node'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (start to: start + string size - 1).
	self assert: ast isLiteralNode.
	self assert: ast value equals: #node.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeInsideAssignementGivesSelectedVariable [
	| ast string start |
	string := 'assignement'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (start to: start + string size - 1).
	self assert: ast isVariable.
	self assert: ast name equals: 'assignement'.
]

{ #category : #'tests-bestNodeFor' }
RBProgramNodeTest >> testBestNodeWithMethodSelectorGivesCommentNode [
	| ast string start |
	string := '"First comment"'.
	start := self getMethodString findString: string.
	ast := (RBParser parseMethod: self getMethodString) bestNodeFor: (1 to: start + string size - 1).
	self assert: ast isCommentNode.
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testCursorAfterArgumentReturnsVariableNode [

	| sourceCode ast bestNode |
	sourceCode := 'toto: m1
	               m1 aMessage'.
	
	ast := RBParser parseMethod: sourceCode.
	bestNode := ast bestNodeForPosition: 9.
	
	self assert: bestNode isVariable 
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testCursorAfterVariableReturnsVariableNode [

	| sourceCode ast bestNode |
	sourceCode := 'toto: m1
	               m1 aMessage'.
	
	ast := RBParser parseMethod: sourceCode.
	bestNode := ast bestNodeForPosition: 28.
	
	self assert: bestNode isVariable 
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testCursorBeforeArgumentNextToSelectorReturnsMethodNode [

	| sourceCode ast bestNode |
	sourceCode := 'toto:m1
	               m1 aMessage'.
	
	ast := RBParser parseMethod: sourceCode.
	bestNode := ast bestNodeForPosition: 6.
	
	self assert: bestNode isMethod 
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testCursorBeforeArgumentReturnsVariableNode [

	| sourceCode ast bestNode |
	sourceCode := 'toto: m1
	               m1 aMessage'.
	
	ast := RBParser parseMethod: sourceCode.
	bestNode := ast bestNodeForPosition: 7.
	
	self assert: bestNode isVariable 
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testCursorBeforeVariableReturnsVariableNode [

	| sourceCode ast bestNode |
	sourceCode := 'toto: m1
	               m1 aMessage'.
	
	ast := RBParser parseMethod: sourceCode.
	bestNode := ast bestNodeForPosition: 26.
	
	self assert: bestNode isVariable 
]

{ #category : #'testing-adding' }
RBProgramNodeTest >> testCursorInMiddleOfVariableReturnsVariableNode [

	| sourceCode ast bestNode |
	sourceCode := 'toto: m1
	               m1 aMessage'.
	
	ast := RBParser parseMethod: sourceCode.
	bestNode := ast bestNodeForPosition: 27.
	
	self assert: bestNode isVariable 
]

{ #category : #'testing-properties' }
RBProgramNodeTest >> testHasProperty [
	self deny: (self node hasProperty: #foo).
	self node propertyAt: #foo put: 123.
	self assert: (self node hasProperty: #foo)
]

{ #category : #tests }
RBProgramNodeTest >> testNumberOfSentMessages [
	| tree messages |
	tree := self parserClass parseMethod: 
			'methodName
				| temp |
				1 send1 send2; send3.
				temp := [:each | {4 send4} send5].
				temp send6.
				0 ifTrue: [ 1 ]'.
	messages := tree sentMessages.
	self assert: messages size equals: 7.
	"we count ifTrue:"
	1 to: 6 do:
		[ :i | self assert: (messages includes: ('send' , i printString) asSymbol) ]
]

{ #category : #'testing-properties' }
RBProgramNodeTest >> testPropertyAt [
	self should: [ self node propertyAt: #foo ] raise: Error.
	self node propertyAt: #foo put: true.
	self assert: (self node propertyAt: #foo)
]

{ #category : #'testing-properties' }
RBProgramNodeTest >> testPropertyAtIfAbsent [
	self assert: (self node propertyAt: #foo ifAbsent: [ true ]).
	self node propertyAt: #foo put: true.
	self assert: (self node propertyAt: #foo ifAbsent: [ false ])
]

{ #category : #'testing-properties' }
RBProgramNodeTest >> testPropertyAtIfAbsentPut [
	self assert: (self node propertyAt: #foo ifAbsentPut: [ true ]).
	self assert: (self node propertyAt: #foo ifAbsentPut: [ false ])
]

{ #category : #'testing-properties' }
RBProgramNodeTest >> testPropertyAtIfPresentIfAbsent [
	self assert: (self node propertyAt: #foo ifPresent:[ false ] ifAbsent: [ true ]) equals: true.
	self node propertyAt: #foo put: true.
	self assert: (self node propertyAt: #foo ifPresent:[ true ] ifAbsent: [ false ]).
	self assert: (self node propertyAt: #toto ifPresent:[ false ] ifAbsent: [ true ])
]

{ #category : #'testing-properties' }
RBProgramNodeTest >> testRemoveProperty [
	self should: [ self node removeProperty: #foo ] raise: Error.
	self node propertyAt: #foo put: true.
	self assert: (self node removeProperty: #foo)
]

{ #category : #'testing-properties' }
RBProgramNodeTest >> testRemovePropertyIfAbsent [
	self assert: (self node removeProperty: #foo ifAbsent: [ true ]).
	self node propertyAt: #foo put: true.
	self assert: (self node removeProperty: #foo ifAbsent: [ false ])
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceAssignment [
	| tree expectedTree |
	tree := self parseMethod: 'run sum := 2 + 2'.
	expectedTree := self parseMethod: 'run multpppp := 2 * 2'.
	
	tree body statements first replaceWith: (self parseExpression: 'multpppp := 2 * 2').
	self assert: tree equals: expectedTree.
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceBlock [
	| tree expectedTree |
	tree := self parseMethod: 'run self foo ifNil: [ ^ true ]'.
	expectedTree := self parseMethod: 'run self foo ifNil: [ ^ false ]'.
	
	tree body statements first arguments first replaceWith: (self parseExpression: '[ ^ false ]').
	self assert: tree  equals: expectedTree
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceLiteral [
	| tree |
	tree := self parseMethod: 'run "1" 123 "2"'.
	tree body statements first replaceWith: (self parseExpression: '$a').
	self assert: tree newSource equals: 'run "1" $a "2"'.
	tree := self parseMethod: 'run "1" 123 "2"'.
	tree body statements first replaceWith: (self parseExpression: 'zork').
	self assert: tree newSource equals: 'run "1" zork "2"'
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceLiteralArray1 [
	| tree |
	tree := self parseMethod: 'run "1" #(1 2 3) "2"'.
	tree body statements first replaceWith: (self parseExpression: '#[1 2 3]').
	self assert: tree newSource equals: 'run "1" #[ 1 2 3 ] "2"'.
	tree := self parseMethod: 'run "1" #(1 2 3) "2"'.
	tree body statements first replaceWith: (self parseExpression: '123').
	self assert: tree newSource equals: 'run "1" 123 "2"'
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceLiteralArray2 [
	| tree |
	tree := self parseMethod: 'run "1" #[1 2 3] "2"'.
	tree body statements first replaceWith: (self parseExpression: '#(1 2 3)').
	self assert: tree newSource equals: 'run "1" #( 1 2 3 ) "2"'.
	tree := self parseMethod: 'run "1" #[1 2 3] "2"'.
	tree body statements first replaceWith: (self parseExpression: '123').
	self assert: tree newSource equals: 'run "1" 123 "2"'
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceMessage [
	| tree |
	tree := self parseMethod: 'run "1" self "2" run "3"'.
	tree body statements first replaceWith: (self parseExpression: 'self runCase').
	self assert: tree newSource equals: 'run "1" self "2" runCase "3"'
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceMessageArgument [
	| tree |
	tree := self parseMethod: 'foo "1" self "2" foo: "3" foo "4"'.
	tree body statements first arguments first replaceWith: (self parseExpression: 'bar').
	self assert: tree newSource equals: 'foo "1" self "2" foo: "3" bar "4"'.
	tree := self parseMethod: 'foo "1" self "2" foo: "3" foo "4"'.
	tree body statements first arguments first replaceWith: (self parseExpression: 'bar msg1 msg2').
	self assert: tree newSource equals: 'foo "1" self "2" foo: "3" bar msg1 msg2 "4"'.
	tree := self parseMethod: 'foo "1" self "2" foo: "3" foo bar "4"'.
	tree body statements first arguments first replaceWith: (self parseExpression: 'bar').
	self assert: tree newSource equals: 'foo "1" self "2" foo: "3" bar "4"'
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceMessageReceiver [
	| tree |
	tree := self parseMethod: 'foo "1" self "2" foo: "3" 123 "4"'.
	tree body statements first receiver replaceWith: (self parseExpression: 'bar').
	self assert: tree newSource equals: 'foo "1" bar "2" foo: "3" 123 "4"'.
	tree := self parseMethod: 'foo "1" self "2" foo: "3" 123 "4"'.
	tree body statements first receiver replaceWith: (self parseExpression: 'bar msg1 msg2').
	self assert: tree newSource equals: 'foo "1" bar msg1 msg2 "2" foo: "3" 123 "4"'.
	tree := self parseMethod: 'foo "1" self foo "2" foo: "3" 123 "4"'.
	tree body statements first receiver replaceWith: (self parseExpression: 'bar').
	self assert: tree newSource equals: 'foo "1" bar "2" foo: "3" 123 "4"'
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceMethodBinary [
	| tree |
	tree := self parseMethod: '= "1" anObject "2" ^ "3" 4 "5"'.
	tree renameSelector: #runCase andArguments: #().
	self assert: tree newSource equals: 'runCase "2" ^ "3" 4 "5"'.
	
	tree := self parseMethod: '= "1" anObject "2" ^ "3" 4 "5"'.
	tree renameSelector: #~~ andArguments: (Array with: (self parseExpression: 'first')).
	self assert: tree newSource equals: '~~ "1" first "2" ^ "3" 4 "5"'.

	tree := self parseMethod: '= "1" anObject "2" ^ "3" 4 "5"'.
	tree renameSelector: #assert: andArguments: (Array with: (RBVariableNode named: 'first')).
	self assert: tree newSource equals: 'assert: "1" first "2" ^ "3" 4 "5"'.

	tree := self parseMethod: '= "1" anObject "2" ^ "3" 4 "5"'.
	tree renameSelector: #assert:description: andArguments: (Array with: (RBVariableNode named: 'first') with: (RBVariableNode named: 'second')).
	self assert: tree newSource equals: 'assert: first description: second "2" ^ "3" 4 "5"'
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceMethodKeyword [
	| tree |
	tree := self parseMethod: 'deny: "1" anObject "2" ^ "3" 4 "5"'.
	tree renameSelector: #runCase andArguments: #().
	self assert: tree newSource equals: 'runCase "2" ^ "3" 4 "5"'.
	
	tree := self parseMethod: 'deny: "1" anObject "2" ^ "3" 4 "5"'.
	tree renameSelector: #~~ andArguments: (Array with: (self parseExpression: 'first')).
	self assert: tree newSource equals: '~~ "1" first "2" ^ "3" 4 "5"'.

	tree := self parseMethod: 'deny: "1" anObject "2" ^ "3" 4 "5"'.
	tree renameSelector: #assert: andArguments: (Array with: (RBVariableNode named: 'first')).
	self assert: tree newSource equals: 'assert: "1" first "2" ^ "3" 4 "5"'.

	tree := self parseMethod: 'deny: "1" anObject "2" ^ "3" 4 "5"'.
	tree renameSelector: #assert:description: andArguments: (Array with: (RBVariableNode named: 'first') with: (RBVariableNode named: 'second')).
	self assert: tree newSource equals: 'assert: first description: second "2" ^ "3" 4 "5"'
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceMethodKeywordLong [
	| tree |
	tree := self parseMethod: 'deny: "1" anObject "2" description: "3" anotherObject "4" ^ "5" 6 "7"'.
	tree renameSelector: #runCase andArguments: #().
	self assert: tree newSource equals: 'runCase "4" ^ "5" 6 "7"'.
	
	tree := self parseMethod: 'deny: "1" anObject "2" description: "3" anotherObject "4" ^ "5" 6 "7"'.
	tree renameSelector: #~~ andArguments: (Array with: (self parseExpression: 'first')).
	self assert: tree newSource equals: '~~ first "4" ^ "5" 6 "7"'.

	tree := self parseMethod: 'deny: "1" anObject "2" description: "3" anotherObject "4" ^ "5" 6 "7"'.
	tree renameSelector: #assert: andArguments: (Array with: (self parseExpression: 'first')).
	self assert: tree newSource equals: 'assert: first "4" ^ "5" 6 "7"'.

	tree := self parseMethod: 'deny: "1" anObject "2" description: "3" anotherObject "4" ^ "5" 6 "7"'.
	tree renameSelector: #assert:description: andArguments: (Array with: (self parseExpression: 'first') with: (self parseExpression: 'second')).
	self assert: tree newSource equals: 'assert: "1" first "2" description: "3" second "4" ^ "5" 6 "7"'
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceMethodUnary [
	| tree |
	tree := self parseMethod: 'run "1" ^ "2" 3 "4"'.
	tree renameSelector: #runCase andArguments: #().
	self assert: tree newSource equals: 'runCase "1" ^ "2" 3 "4"'.
	
	tree := self parseMethod: 'run "1" ^ "2" 3 "4"'.
	tree renameSelector: #~~ andArguments: (Array with: (self parseExpression: 'first')).
	self assert: tree newSource equals: '~~ first "1" ^ "2" 3 "4"'.

	tree := self parseMethod: 'run "1" ^ "2" 3 "4"'.
	tree renameSelector: #assert: andArguments: (Array with: (self parseExpression: 'first')).
	self assert: tree newSource equals: 'assert: first "1" ^ "2" 3 "4"'.

	tree := self parseMethod: 'run "1" ^ "2" 3 "4"'.
	tree renameSelector: #assert:description: andArguments: (Array with: (self parseExpression: 'first') with: (self parseExpression: 'second')).
	self assert: tree newSource equals: 'assert: first description: second "1" ^ "2" 3 "4"'
]

{ #category : #'testing-replacing' }
RBProgramNodeTest >> testReplaceVariable [
	| tree |
	tree := self parseMethod: 'run "1" foo "2"'.
	tree body statements first replaceWith: (self parseExpression: 'zork').
	self assert: tree newSource equals: 'run "1" zork "2"'.
	tree := self parseMethod: 'run "1" foo "2"'.
	tree body statements first replaceWith: (self parseExpression: '123').
	self assert: tree newSource equals: 'run "1" 123 "2"'
]

{ #category : #'testing-messages' }
RBProgramNodeTest >> testSentMessages [
	| tree messages |
	tree := self
		parseRewriteMethod:
			'methodName
				| temp |
				1 send1 send2; send3.
				temp := [:each | {4 send4} send5].
				temp send6 `{:node | node notASentMessage}'.
	messages := tree sentMessages.
	self assert: messages size equals: 6.
	1 to: 6 do:
		[ :i | self assert: (messages includes: ('send' , i printString) asSymbol) ]
]

{ #category : #'testing-comments' }
RBProgramNodeTest >> testSetCommentsToNil [

	self node comments: nil.
	self assert: self node comments equals: #()
]

{ #category : #tests }
RBProgramNodeTest >> testWithAllParents [
	"check that we get all parents of a program node, and me"

	| me parentsOf7 |
	[ :a | a + 7 ].
	me := self class >> #testAllParents.
	parentsOf7 := (me ast allChildren select: [ :n | 
		               n isLiteralNode and: [ n value = 7 ] ]) first
		              withAllParents.
	self assert: parentsOf7 last value equals: 7.
	self assert: parentsOf7 first equals: me ast
]
