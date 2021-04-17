"
I'm the superclass of the all the nodes for 
	- expressions and methods (subclasses of RBProgramNode) - historically it was the only tree and 
	it was the only part concerned with refactorings (hence the RB suffix for RegactoringBrowser).
	- class definition (just nodes to represent the class creation messages),
	- full program (class definitions or method definitions)

In the future my prefix may change to convey the fact that my hierarchy is much more than supporting compiler and refactorings.

I'm a new player in the field, do not hesitate to improve me.

"
Class {
	#name : #RBNode,
	#superclass : #Object,
	#category : #'AST-Core-Nodes'
}

{ #category : #testing }
RBNode class >> isAbstract [

	^ self == RBNode
]

{ #category : #visiting }
RBNode >> acceptVisitor: aProgramNodeVisitor [
	self subclassResponsibility
]
