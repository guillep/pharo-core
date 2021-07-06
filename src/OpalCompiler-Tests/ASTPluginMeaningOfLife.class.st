"
A simple example for a AST transforming compiler plugin.

I replace 42 with a  'meaning of life'.
"
Class {
	#name : #ASTPluginMeaningOfLife,
	#superclass : #OCStaticASTCompilerPlugin,
	#category : #'OpalCompiler-Tests-Plugins'
}

{ #category : #accessing }
ASTPluginMeaningOfLife class >> priority [
	^ 0
]

{ #category : #transformation }
ASTPluginMeaningOfLife >> transform [
	| rule |
	"copy the AST as we modify it"
	self copyAST.
	"we use the RBParseTreeRewriter to do the change, another option is to do it directly using
	e.g #replaceWith:"
	rule := RBParseTreeRewriter replaceLiteral: 42 with: 'meaning of life'.
	rule executeTree: ast.
	^ast
]
