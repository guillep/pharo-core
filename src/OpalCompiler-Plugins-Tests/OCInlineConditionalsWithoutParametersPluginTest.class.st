Class {
	#name : #OCInlineConditionalsWithoutParametersPluginTest,
	#superclass : #TestCase,
	#category : #'OpalCompiler-Plugins-Tests'
}

{ #category : #asserting }
OCInlineConditionalsWithoutParametersPluginTest >> assertAllNodesTransformedOn: ast usingSelector: aSelector [ 

	| newAst plugin hasDoneAsserts | 

	plugin := OCInlineConditionalsWithoutParametersPlugin new.	
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
OCInlineConditionalsWithoutParametersPluginTest >> testASTLiteralIsWrappedWithBlockWithoutValue [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'm1:a a ifTrue: [17] ifFalse: 7'.
	nodeToWrap := ast body statements first arguments second copy.

	plugin := OCInlineConditionalsWithoutParametersPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments second.
	
	self assert: newBlock isBlock.
	self assert: newBlock statements first isLiteralNode.
	self assert: newBlock statements first equals: nodeToWrap.	

]

{ #category : #tests }
OCInlineConditionalsWithoutParametersPluginTest >> testASTWithIfFalseIfTrueResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a 
		^ a ifFalse: 17 ifTrue: 5'.

	self assertAllNodesTransformedOn: ast usingSelector: #ifFalse:ifTrue:

]

{ #category : #tests }
OCInlineConditionalsWithoutParametersPluginTest >> testASTWithIfFalseResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a 
		^ a ifFalse: 17 '.

	self assertAllNodesTransformedOn: ast usingSelector: #ifFalse:

]

{ #category : #tests }
OCInlineConditionalsWithoutParametersPluginTest >> testASTWithIfNilResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a 
		^ a ifNil: 5'.

	self assertAllNodesTransformedOn: ast usingSelector: #ifNil:

]

{ #category : #tests }
OCInlineConditionalsWithoutParametersPluginTest >> testASTWithIfTrueIfFalseResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a 
		^ a ifTrue: 17 ifFalse: 5 '.

	self assertAllNodesTransformedOn: ast usingSelector: #ifTrue:ifFalse:

]

{ #category : #tests }
OCInlineConditionalsWithoutParametersPluginTest >> testASTWithIfTrueResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a 
		^ a ifTrue: 17 '.

	self assertAllNodesTransformedOn: ast usingSelector: #ifTrue:

]

{ #category : #tests }
OCInlineConditionalsWithoutParametersPluginTest >> testASTWithNestedMessageResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a 
		^ a ifTrue: 17 ifFalse: [ 
			a negated ifTrue: [ 7 ] ifFalse: 12 ]'.

	self assertAllNodesTransformedOn: ast usingSelector: #ifTrue:ifFalse:

]

{ #category : #tests }
OCInlineConditionalsWithoutParametersPluginTest >> testASTWithOneParameterCorrectlyRewritesExpressionInBlock [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'm1:a with: b a ifTrue: b'.
	nodeToWrap := ast body statements first arguments first copy.

	plugin := OCInlineConditionalsWithoutParametersPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments first.
	
	self assert: newBlock isBlock.
	self assert: newBlock statements first isMessage.
	self assert: newBlock statements first receiver equals: nodeToWrap.	
	self assert: newBlock statements first selector equals: #value.	
]

{ #category : #tests }
OCInlineConditionalsWithoutParametersPluginTest >> testASTWithSingleMessageCorrectlyRewritesExpressionInBlock [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'm1:a with:b a ifTrue: b ifFalse: [7]'.
	nodeToWrap := ast body statements first arguments first copy.

	plugin := OCInlineConditionalsWithoutParametersPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments first.
	
	self assert: newBlock isBlock.
	self assert: newBlock statements first isMessage.
	self assert: newBlock statements first receiver equals: nodeToWrap.	
	self assert: newBlock statements first selector equals: #value.	
]

{ #category : #tests }
OCInlineConditionalsWithoutParametersPluginTest >> testASTWithSingleMessageInRightCorrectlyRewritesExpressionInBlock [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'm1:a with:b a ifTrue: [17] ifFalse: b'.
	nodeToWrap := ast body statements first arguments second copy.

	plugin := OCInlineConditionalsWithoutParametersPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments second.
	
	self assert: newBlock isBlock.
	self assert: newBlock statements first isMessage.
	self assert: newBlock statements first receiver equals: nodeToWrap.	
	self assert: newBlock statements first selector equals: #value.	
]

{ #category : #tests }
OCInlineConditionalsWithoutParametersPluginTest >> testASTWithSingleMessageResultsWithoutNoInvocationsWithoutBlocks [

	| ast |

	ast := RBParser parseMethod: 'm1:a a ifTrue: 17 ifFalse: [7]'.
	self assertAllNodesTransformedOn: ast usingSelector: #ifTrue:ifFalse:.

]

{ #category : #tests }
OCInlineConditionalsWithoutParametersPluginTest >> testNewBlockWithoutArgumentsHasSameSourceIntervalAsOriginalBlock [

	| ast nodeToWrap plugin newAst newBlock |

	ast := RBParser parseMethod: 'm1:a a ifTrue: [17] ifFalse: 7'.
	nodeToWrap := ast body statements first arguments second copy.

	plugin := OCInlineConditionalsWithoutParametersPlugin new.	
	newAst := plugin preSemanticAnalysisTransform: ast.
	newBlock := newAst body statements first arguments second.
	
	self assert: newBlock sourceInterval equals: nodeToWrap sourceInterval
]
