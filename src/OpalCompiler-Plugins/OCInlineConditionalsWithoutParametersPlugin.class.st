Class {
	#name : #OCInlineConditionalsWithoutParametersPlugin,
	#superclass : #OCCompilerASTPlugin,
	#category : #'OpalCompiler-Plugins'
}

{ #category : #'class initialization' }
OCInlineConditionalsWithoutParametersPlugin class >> initialize [

	self install
]

{ #category : #'class initialization' }
OCInlineConditionalsWithoutParametersPlugin class >> install [

	(CompilationContext defaultTransformationPlugins includes: self)
		ifTrue: [ ^ self ].
	CompilationContext addDefaultTransformationPlugin: self.

]

{ #category : #private }
OCInlineConditionalsWithoutParametersPlugin class >> priority [

	^ 10
]

{ #category : #private }
OCInlineConditionalsWithoutParametersPlugin >> buildReplacementBlockWrappingNode: aNode [

	| blockStatement |
	blockStatement := self newBlockStatement: aNode.
	^ RBBlockNode body: (RBSequenceNode statements: { blockStatement })
]

{ #category : #private }
OCInlineConditionalsWithoutParametersPlugin >> newBlockStatement: toBeBlock [

	^ toBeBlock isLiteralNode
		ifTrue: [ toBeBlock copy ]
		ifFalse: [ RBMessageNode receiver: toBeBlock copy selector: #value ]
]

{ #category : #api }
OCInlineConditionalsWithoutParametersPlugin >> preSemanticAnalysisTransform: originalAST [

	^ self rewriteConditionalsOn: originalAST 
]

{ #category : #api }
OCInlineConditionalsWithoutParametersPlugin >> replaceNode: toBeBlock with: newNode [
	newNode left: toBeBlock start.
	newNode right: toBeBlock stop.
	toBeBlock replaceWith: newNode
]

{ #category : #private }
OCInlineConditionalsWithoutParametersPlugin >> replaceNodeWithBlock: aNode [

	| newNode |
	newNode := self buildReplacementBlockWrappingNode: aNode.
	self replaceNode: aNode with: newNode
]

{ #category : #private }
OCInlineConditionalsWithoutParametersPlugin >> rewriteConditionalsOn: originalAST [ 

	originalAST nodesDo: [ :aNode | 
		(aNode isMessage and: [ self whiteList includes: aNode selector ]) 
			ifTrue: [ 
				(aNode arguments reject: [ :anArgument | anArgument isBlock ]) 
					do: [ :toBeBlock | self replaceNodeWithBlock: toBeBlock ] ] ].

	^ originalAST
]

{ #category : #api }
OCInlineConditionalsWithoutParametersPlugin >> transform [ 
	
	"I do nothing in this stage, I execute in the preSemanticAnalysisTransform: "
]

{ #category : #api }
OCInlineConditionalsWithoutParametersPlugin >> whiteList [
	
	^ #(ifTrue: ifTrue:ifFalse: ifFalse: ifFalse:ifTrue: ifNil:)
]
