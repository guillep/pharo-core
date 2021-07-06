Class {
	#name : #OCInlineNotNilPluginTest,
	#superclass : #TestCase,
	#category : #'OpalCompiler-Plugins-Tests'
}

{ #category : #asserting }
OCInlineNotNilPluginTest >> assertAllNodesTransformedOn: ast usingSelector: aSelector [ 

	| newAst plugin hasDoneAsserts | 

	plugin := OCInlineIfNotNilPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	hasDoneAsserts := false.
	
	newAst nodesDo: [ :aNode |  
		(aNode isMessage and: [ aNode selector = aSelector ]) 
			ifTrue: [ 
				hasDoneAsserts := true.
				aNode arguments do: [ :anArgument | self assert: anArgument isBlock ] ] ].
		
	self assert: hasDoneAsserts
]

{ #category : #tests }
OCInlineNotNilPluginTest >> testASTLiteralIsWrappedWithBlockWithoutValue [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'm1:a a ifNil: [17] ifNotNil: 7'.
	nodeToWrap := ast body statements first arguments second copy.

	plugin := OCInlineIfNotNilPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments second.
	
	self assert: newBlock isBlock.
	self assert: newBlock statements first isLiteralNode.
	self assert: newBlock statements first equals: nodeToWrap.	

]

{ #category : #tests }
OCInlineNotNilPluginTest >> testASTWithBlocksDoNotAddParameterToIfNilArgument [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'critical: block
	 access
		ifNil: block
		ifNotNil: [ access critical: block ]'.
	nodeToWrap := ast body statements first arguments first copy.

	plugin := OCInlineIfNotNilPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments first.
	
	self assert: newBlock isBlock.
	self assert: newBlock arguments size equals: 0.
	self assert: newBlock statements first isMessage.
	self assert: newBlock statements first receiver equals: nodeToWrap.	
	self assert: newBlock statements first selector equals: #value.	
]

{ #category : #tests }
OCInlineNotNilPluginTest >> testASTWithIfNilIfNotNilResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a 
		^ a ifNil: 17 ifNotNil: 5'.

	self assertAllNodesTransformedOn: ast usingSelector: #ifNil:ifNotNil:

]

{ #category : #tests }
OCInlineNotNilPluginTest >> testASTWithIfNotNilIfNilResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a 
		^ a ifNotNil: 5 ifNil: 8'.

	self assertAllNodesTransformedOn: ast usingSelector: #ifNotNil:ifNil:

]

{ #category : #tests }
OCInlineNotNilPluginTest >> testASTWithIfNotNilResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a 
		^ a ifNotNil: 5'.

	self assertAllNodesTransformedOn: ast usingSelector: #ifNotNil:

]

{ #category : #tests }
OCInlineNotNilPluginTest >> testASTWithNestedMessageResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a 
		^ a ifNil: 17 ifNotNil: [ 
			a negated ifNil: [ 7 ] ifNotNil: 12 ]'.

	self assertAllNodesTransformedOn: ast usingSelector: #ifNil:ifNotNil:

]

{ #category : #tests }
OCInlineNotNilPluginTest >> testASTWithOneParameterCorrectlyRewritesExpressionInBlock [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'm1:a with: b a ifNotNil: b'.
	nodeToWrap := ast body statements first arguments first copy.

	plugin := OCInlineIfNotNilPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments first.
	
	self assert: newBlock isBlock.
	self assert: newBlock arguments size equals: 1.
	self assert: newBlock statements first isMessage.
	self assert: newBlock statements first arguments first equals: newBlock arguments first.
	self assert: newBlock statements first receiver equals: nodeToWrap.	
	self assert: newBlock statements first selector equals: #cull:.	
]

{ #category : #tests }
OCInlineNotNilPluginTest >> testASTWithSingleMessageCorrectlyRewritesExpressionInBlock [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'm1:a with:b a ifNotNil: b ifNil: [7]'.
	nodeToWrap := ast body statements first arguments first copy.

	plugin := OCInlineIfNotNilPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments first.
	
	self assert: newBlock isBlock.
	self assert: newBlock arguments size equals: 1.
	self assert: newBlock statements first isMessage.
	self assert: newBlock statements first arguments first equals: newBlock arguments first.
	self assert: newBlock statements first receiver equals: nodeToWrap.	
	self assert: newBlock statements first selector equals: #cull:.	
]

{ #category : #tests }
OCInlineNotNilPluginTest >> testASTWithSingleMessageInRightCorrectlyRewritesExpressionInBlock [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'm1:a with:b a ifNil: [17] ifNotNil: b'.
	nodeToWrap := ast body statements first arguments second copy.

	plugin := OCInlineIfNotNilPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments second.
	
	self assert: newBlock isBlock.
	self assert: newBlock arguments size equals: 1.
	self assert: newBlock statements first isMessage.
	self assert: newBlock statements first arguments first equals: newBlock arguments first.
	self assert: newBlock statements first receiver equals: nodeToWrap.	
	self assert: newBlock statements first selector equals: #cull:.	
]

{ #category : #tests }
OCInlineNotNilPluginTest >> testASTWithSingleMessageResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a a ifNil: 17 ifNotNil: [7]'.
	self assertAllNodesTransformedOn: ast usingSelector: #ifNil:ifNotNil:.

]

{ #category : #tests }
OCInlineNotNilPluginTest >> testASTWithSingleMessageThatIsASymbolCorrectlyRewritesExpressionInBlock [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'm1:a with:b a ifNil: [ 7 ] ifNotNil: #lala'.
	nodeToWrap := ast body statements first arguments second copy.

	plugin := OCInlineIfNotNilPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments second.
	
	self assert: newBlock isBlock.
	self assert: newBlock arguments size equals: 1.
	self assert: newBlock statements first isMessage.
	self assert: newBlock statements first arguments first equals: newBlock arguments first.
	self assert: newBlock statements first receiver equals: nodeToWrap.	
	self assert: newBlock statements first selector equals: #cull:.	
]

{ #category : #tests }
OCInlineNotNilPluginTest >> testNewBlockWithArgumentsHasSameSourceIntervalAsOriginalBlock [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'm1:a a ifNil: [17] ifNotNil: 7'.
	nodeToWrap := ast body statements first arguments second copy.

	plugin := OCInlineIfNotNilPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments second.
	
	self assert: newBlock sourceInterval equals: nodeToWrap sourceInterval
]
