"
A critique which know which node should be replaced by another one. This critiques are used first of all in rewrite rules.
"
Class {
	#name : #ReReplaceNodeCritique,
	#superclass : #ReAbstractCritique,
	#instVars : [
		'oldNode',
		'newNode'
	],
	#category : #'Renraku-Critiques'
}

{ #category : #'instance creation' }
ReReplaceNodeCritique class >> rule: aRule achor: anAnchor oldNode: aNode newNode: anotherNode [

	^ self basicNew 
		initializeRule: aRule
		sourceAnchor: anAnchor
		oldNode: aNode
		newNode: anotherNode
]

{ #category : #accessing }
ReReplaceNodeCritique >> change [
	"creates new AST by replacing the node. Then the 'add method' change is generated from new AST"

	| newTree newTreeNode |
	newTree := self entity  parseTree.
	newTreeNode := newTree nodeAtTraversalIndex: (
		oldNode methodNode traversalIndexOf: oldNode).
	self assert: newTreeNode = oldNode.

	newTreeNode replaceMethodSource: newNode.
	newTreeNode becomeForward: newNode.
	^ (RBRefactoryChangeFactory instance)
		addMethodSource: newTree methodNode newSource
		in: self entity  methodClass
]

{ #category : #initialization }
ReReplaceNodeCritique >> initializeRule: aRule sourceAnchor: anAnchor oldNode: aNode newNode: anotherNode [

	self initializeRule: aRule sourceAnchor: anAnchor.
	oldNode := aNode.
	newNode := anotherNode 

]

{ #category : #testing }
ReReplaceNodeCritique >> providesChange [

	^ self entity isCompiledMethod
]
