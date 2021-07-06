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
They are sorted by #priority and handed the AST without making a copy (as plugins might just analyse the AST). 

IMPORTANT: If you modify the AST, you have to make a copy before!
"
Class {
	#name : #OCASTCompilerPlugin,
	#superclass : #Object,
	#category : #'OpalCompiler-Core-Plugins'
}

{ #category : #'accessing - defaults' }
OCASTCompilerPlugin class >> defaultPriority [
	"Use a high priority by default (a priority of 0 would be used by Reflectivity to be the last)"
	
	^ 100 
]

{ #category : #testing }
OCASTCompilerPlugin class >> isAbstract [ 

	 ^ self = OCASTCompilerPlugin
]

{ #category : #accessing }
OCASTCompilerPlugin >> priority [
	^self class defaultPriority
]

{ #category : #transforming }
OCASTCompilerPlugin >> transform: ast [
	
	self subclassResponsibility
]
