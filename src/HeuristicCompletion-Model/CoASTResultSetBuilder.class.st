"
I'm an abstract superclass for defining AST Based Complishons
"
Class {
	#name : #CoASTResultSetBuilder,
	#superclass : #CoResultSetBuilder,
	#instVars : [
		'astNode',
		'node'
	],
	#category : #'HeuristicCompletion-Model-SystemIntegration'
}

{ #category : #testing }
CoASTResultSetBuilder class >> isAbstract [

	^ self == CoASTResultSetBuilder
]

{ #category : #accessing }
CoASTResultSetBuilder >> astNode [
	
	^ astNode
]

{ #category : #'API - building' }
CoASTResultSetBuilder >> buildCompletion [

	"Visiting the node configures the completion for that node"
	astNode := self parseNode.
	^ astNode acceptVisitor: self
]

{ #category : #'API - building' }
CoASTResultSetBuilder >> configureEmptyFetcherForNode: aNode [
	
	^ self
		configureFetcher: CoEmptyFetcher new
		forNode: aNode
]

{ #category : #'private-building' }
CoASTResultSetBuilder >> configureFetcher: aFetcher forNode: aNode [
	
	| completion |
	completion := CoResultSet fetcher: aFetcher.
	completion caseSensitive: NECPreferences caseSensitive.
	completion filterWithString: completionContext completionToken.
	^ completion
]

{ #category : #'private-building' }
CoASTResultSetBuilder >> configureFetcherForNode: aNode usingHeuristicAvoidingRepetitions: heuristic [
	
	| fetcher |
	fetcher := heuristic fetcherFor: aNode inContext: completionContext.
	^ self
		configureFetcher: fetcher withoutRepetition
		forNode: aNode
]

{ #category : #accessing }
CoASTResultSetBuilder >> node: aNode [

	node := aNode
]

{ #category : #'API - building' }
CoASTResultSetBuilder >> parseNode [

	^ node ifNil: [
		(completionContext completionClass compiler
			source: completionContext source;
			noPattern: completionContext isWorkspace; 
			options: #(+ optionParseErrors + optionSkipSemanticWarnings);
			parse) nodeForOffset: completionContext position ] 
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitArgumentVariableNode: anArgumentNode [

	^ self visitVariableNode: anArgumentNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitArrayNode: aRBArrayNode [ 
	
	^ self visitNode: aRBArrayNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitAssignmentNode: aRBAssignmentNode [ 
	
	^ self visitNode: aRBAssignmentNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitBlockNode: aRBBlockNode [ 

	^ self visitNode: aRBBlockNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitCascadeNode: aRBCascadeNode [ 

	^ self visitNode: aRBCascadeNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitClassVariableNode: aRBVariableNode [

	^ self visitVariableNode: aRBVariableNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitEnglobingErrorNode: aRBVariableNode [ 
	^ self visitNode: aRBVariableNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitGlobalVariableNode: aRBVariableNode [

	^ self visitVariableNode: aRBVariableNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitInstanceVariableNode: aRBVariableNode [ 
	^ self visitVariableNode: aRBVariableNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitLiteralArrayNode: aRBLiteralArrayNode [ 

	^ self visitNode: aRBLiteralArrayNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitLiteralValueNode: aRBLiteralValueNode [ 
	
	^ self visitNode: aRBLiteralValueNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitLiteralVariableNode: aRBVariableNode [
	^ self visitVariableNode: aRBVariableNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitMessageNode: aRBMessageNode [
	
	^ self visitNode: aRBMessageNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitMethodNode: aRBMethodNode [
	
	^ self visitNode: aRBMethodNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitNode: aNode [
	
	^ self configureEmptyFetcherForNode: aNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitParseErrorNode: aRBParseErrorNode [ 
	
	^ self visitNode: aRBParseErrorNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitPragmaNode: aRBPragmaNode [

	^ self visitNode: aRBPragmaNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitReturnNode: aRBReturnNode [ 
	
	^ self visitNode: aRBReturnNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitSelfNode: aRBSelfNode [ 
	
	^ self visitNode: aRBSelfNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitSequenceNode: aRBSequenceNode [ 
	
	^ self visitNode: aRBSequenceNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitSuperNode: aRBSuperNode [ 
	
	^ self visitNode: aRBSuperNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitTemporaryVariableNode: anArgumentNode [

	^ self visitVariableNode: anArgumentNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitThisContextNode: aRBThisContextNode [

	^ self visitNode: aRBThisContextNode
]

{ #category : #visiting }
CoASTResultSetBuilder >> visitVariableNode: aRBVariableNode [
	
	^ self visitNode: aRBVariableNode
]
