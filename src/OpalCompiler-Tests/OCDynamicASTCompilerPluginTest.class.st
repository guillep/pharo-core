Class {
	#name : #OCDynamicASTCompilerPluginTest,
	#superclass : #TestCase,
	#category : #'OpalCompiler-Tests-Plugins'
}

{ #category : #tests }
OCDynamicASTCompilerPluginTest >> testCreateAndUseDynamicCompilerPlugin [
	| result plugin |
	plugin := OCDynamicASTCompilerPlugin 
					newFromTransformBlock: [ :ast | (RBParseTreeRewriter replaceLiteral: 42 with: 'meaning of life') executeTree: ast. ast ]
					andPriority: 0.
					
	"Use plugin with compiler"				
	result := Object compiler 
					addPlugin: plugin;
					evaluate: '42'.
					
	self assert: result equals: 'meaning of life'
]

{ #category : #tests }
OCDynamicASTCompilerPluginTest >> testCreateDynamicCompilerPluginWithDefaultPriority [

	| plugin |
	plugin := OCDynamicASTCompilerPlugin newFromTransformBlock: [ :ast | ast ].		
	self assert: plugin priority equals: OCDynamicASTCompilerPlugin defaultPriority
]
