"
The base rule for smalltalk code match & rewrite rules. The rule operates on AST nodes.

Use the following methods in the initialization to setup your subclass:

- replace:with:
- addMatchingExpression:rewriteTo:
	add a ""from->to"" pair of strings that represent a rewrite expression string to match and a rewrite expression to replace the matched node.

- addMatchingMethod:rewriteTo: 
	same as the previous, but the rewrite expression are parsed as method definitions

- replace:by:
- addMatchingExpression:rewriteWith:
	add 	a ""from->to"" pair, first element of which is a rewrite expression in a form of a string that is used to match nodes. The second parameter is a block that has to return a node which should replace the matched one. The block may accept 2 atguments: the matched node, and a dictionary of wildcard variables mapping. 
	
"
Class {
	#name : #ReNodeRewriteRule,
	#superclass : #RePatternCodeRule,
	#instVars : [
		'matches'
	],
	#category : #'Renraku-Rules-Rewrite'
}

{ #category : #testing }
ReNodeRewriteRule class >> isAbstract [ 

	^self == ReNodeRewriteRule
]

{ #category : #testing }
ReNodeRewriteRule class >> isVisible [
	
	^ self name ~=  #ReNodeRewriteRule
]

{ #category : #adding }
ReNodeRewriteRule >> addMatchingExpression: aString rewriteTo: aRewriteString [
	"add a 'from->to' pair of strings that represent a rewrite expression string to match and a rewrite expression to replace the matched node."

	matches
		at: (RBParser parseRewriteExpression: aString)
		put: (ReRewriteTreeWrapper on: (
			RBParser parseRewriteExpression: aRewriteString))
]

{ #category : #adding }
ReNodeRewriteRule >> addMatchingExpression: aString rewriteWith: aBlock [
	"add 	a 'from->to' pair, first element of which is a rewrite expression in a form of a string that is used to match nodes. The second parameter is a block that has to return a node which should replace the matched one. The block may accept 2 atguments: the matched node, and a dictionary of wildcard variables mapping"

	matches
		at: (RBParser parseRewriteExpression: aString)
		put: (ReRewriteBlockWrapper on: aBlock)
]

{ #category : #adding }
ReNodeRewriteRule >> addMatchingMethod: aString rewriteTo: aRewriteString [
	"add a 'from->to' pair of strings that represent a match method string to match and a rewrite method to replace the matched mathod"

	matches
		at: (RBParser parseRewriteMethod: aString)
		put: (ReRewriteTreeWrapper on: (
			RBParser parseRewriteMethod: aRewriteString))
]

{ #category : #adding }
ReNodeRewriteRule >> addMatchingMethod: aString rewriteWith: aBlock [
	"add 	a 'from->to' pair, first element of which is a rewrite method code in a form of a string that is used to match methods. The second parameter is a block that has to return a method ast which should replace the matched one. The block may accept 2 atguments: the matched ast, and a dictionary of wildcard variables mapping"

	matches
		at: (RBParser parseRewriteMethod: aString)
		put: (ReRewriteBlockWrapper on: aBlock)
]

{ #category : #running }
ReNodeRewriteRule >> check: aNode forCritiquesDo: aCriticBlock [

	matches keysAndValuesDo: [ :matcher :rewriter |
		matcher
			match: aNode
			onSuccess: [ :map |
				(self
					afterCheck: aNode
					mappings: (self flattenMatchMap: map))
						ifTrue: [
							aCriticBlock cull: (
								self
									critiqueFor: aNode
									by: rewriter
									withMappings: map). ] ]
			onFailure: [  ] ]
]

{ #category : #helpers }
ReNodeRewriteRule >> critiqueFor: aNode by: rewriter withMappings: map [


	^ ReReplaceNodeCritique
		rule: self
		achor: (self anchorFor: aNode)
		oldNode: aNode
		newNode: (rewriter rewriten: aNode with: map)
]

{ #category : #initialization }
ReNodeRewriteRule >> initialize [
	super initialize.
	matches := Dictionary new.
]

{ #category : #testing }
ReNodeRewriteRule >> isRewriteRule [
	^true
]

{ #category : #adding }
ReNodeRewriteRule >> replace: aString byEvaluating: aBlock [
	"add 	a 'from->to' pair, first element of which is a rewrite expression in a form of a string that is used to match nodes. The second parameter is a block that has to return a node which should replace the matched one. The block may accept 2 atguments: the matched node, and a dictionary of wildcard variables mapping"

	self addMatchingExpression: aString rewriteWith: aBlock
]

{ #category : #adding }
ReNodeRewriteRule >> replace: aString with: aRewriteString [
	"add a 'from->to' pair of strings that represent a match expression string to match and a rewrite expression to replace the matched node"

	self addMatchingExpression: aString rewriteTo: aRewriteString
]

{ #category : #adding }
ReNodeRewriteRule >> replaceMethod: aString with: aRewriteString [
	"add a 'from->to' pair of strings that represent a match method string to match and a rewrite method to replace the matched code"

	self addMatchingMethod: aString rewriteTo: aRewriteString
]
