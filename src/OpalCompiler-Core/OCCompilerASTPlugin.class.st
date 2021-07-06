"
I am an abtract superclass for compiler plugins.

The compiler consists of multiple passes:

source 
	- [ Scanner/Parser ]  -> 
AST 
	- [ SemCheck ] -> 
AST   <<HERE>>
	- [ ASTTranslator ] -> 
IR 
	- [ IRBuilder ] ->
 CompiledMethod


These plugins are called <<HERE>>, that is, after semantic analysis before generating the IR.
They are sorted by #priority and handed the AST without making a copy (as plugins might just analyse the AST). If you modify the AST, you have to make a copy before!


"
Class {
	#name : #OCCompilerASTPlugin,
	#superclass : #Object,
	#instVars : [
		'ast'
	],
	#category : #'OpalCompiler-Core-Translator'
}

{ #category : #'instance creation' }
OCCompilerASTPlugin class >> preSemanticAnalysisTransform: anRBMethodNode [

	^ self new preSemanticAnalysisTransform: anRBMethodNode
]

{ #category : #private }
OCCompilerASTPlugin class >> priority [
	self subclassResponsibility
]

{ #category : #'instance creation' }
OCCompilerASTPlugin class >> transform: ast [
	^self new transform: ast
]

{ #category : #accessing }
OCCompilerASTPlugin >> ast: anAst [
	ast := anAst
]

{ #category : #api }
OCCompilerASTPlugin >> preSemanticAnalysisTransform: anRBMethodNode [
	"My subclasses can perform transformation on the received AST.
	This method returns the new AST to use in the rest of the process. 
	The returned AST can be the same transformed or a new one."

	^ anRBMethodNode.
]

{ #category : #api }
OCCompilerASTPlugin >> priority [
	^100 "default. Priority 0 is used by Reflectivity to be the last"
]

{ #category : #api }
OCCompilerASTPlugin >> transform [

	self subclassResponsibility
]

{ #category : #api }
OCCompilerASTPlugin >> transform: anRBMethodNode [
	ast := anRBMethodNode.
	self transform.
	^ast.
]
