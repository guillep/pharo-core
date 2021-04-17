"
I am a helper class to simplify tests related to scopes. I collect all scopes of the AST.
This way one can easily check for scopes and variables even when the scopes are deeply nested.
Simple example (with just a method scope):

|ast scopes ivar|
ast := (OCOpalExamples>>#exampleiVar) 
		parseTree doSemanticAnalysisIn: OCOpalExamples.
scopes := (OCScopesCollector new visitNode: ast) scopes.
ivar := scopes first lookupVar: #iVar
"
Class {
	#name : #OCScopesCollector,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'scopes'
	],
	#category : #'OpalCompiler-Tests-AST'
}

{ #category : #initialization }
OCScopesCollector >> initialize [ 
	scopes := OrderedCollection new.
	super initialize
]

{ #category : #accessing }
OCScopesCollector >> scopes [ 
	^scopes
]

{ #category : #visiting }
OCScopesCollector >> visitBlockNode: aBlockNode [
	scopes add: aBlockNode owningScope.
	super visitBlockNode: aBlockNode
]

{ #category : #visiting }
OCScopesCollector >> visitMethodNode: aMethodNode [
	scopes add: aMethodNode owningScope.
	super visitMethodNode: aMethodNode
]
