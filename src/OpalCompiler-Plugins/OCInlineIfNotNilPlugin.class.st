Class {
	#name : #OCInlineIfNotNilPlugin,
	#superclass : #OCInlineConditionalsWithoutParametersPlugin,
	#category : #'OpalCompiler-Plugins'
}

{ #category : #'class initialization' }
OCInlineIfNotNilPlugin class >> initialize [

	self install
]

{ #category : #api }
OCInlineIfNotNilPlugin >> buildReplacementBlockWrappingNode: aNode [

	| blockStatement blockArgument argumentIndex |

	argumentIndex := aNode parent arguments indexOf: aNode.
	(aNode parent selector keywords at: argumentIndex) = 'ifNotNil:' 
		ifFalse: [ ^ super buildReplacementBlockWrappingNode: aNode ].

	"I need to generate an unused variable name"
	blockArgument := RBVariableNode named: Object new hash asString asSymbol.
	blockStatement := self newBlockStatement: aNode argument: blockArgument.

	^ RBBlockNode arguments: {blockArgument} body: (RBSequenceNode statements: { blockStatement })
]

{ #category : #api }
OCInlineIfNotNilPlugin >> newBlockStatement: toBeBlock argument: blockArgument [

	^ (toBeBlock isLiteralNode and: [toBeBlock value isSymbol not])
		  ifTrue: [ toBeBlock copy ]
		  ifFalse: [ 
			  RBMessageNode
				  receiver: toBeBlock copy
				  selector: #cull:
				  arguments: { blockArgument } ]
]

{ #category : #api }
OCInlineIfNotNilPlugin >> whiteList [
	
	^ #(ifNotNil: ifNil:ifNotNil: ifNotNil:ifNil:)
]
