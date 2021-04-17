"
I am a refactoring for moving a instance  variable up to the superclass.
"
Class {
	#name : #RBPullUpInstanceVariableRefactoring,
	#superclass : #RBVariableRefactoring,
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #preconditions }
RBPullUpInstanceVariableRefactoring >> preconditions [
	^RBCondition withBlock: 
			[(class hierarchyDefinesInstanceVariable: variableName) 
				ifFalse: [self refactoringFailure: 'No subclass defines ' , variableName].
			(class subclasses 
				anySatisfy: [:each | (each directlyDefinesInstanceVariable: variableName) not]) 
				ifTrue: 
					[self 
						refactoringWarning: 'Not all subclasses have an instance variable named.<n> Do you want pull up this variable anyway?' 
								, variableName , '.'].
			true]
]

{ #category : #transforming }
RBPullUpInstanceVariableRefactoring >> transform [
	class allSubclasses do: 
			[:each | 
			(each directlyDefinesInstanceVariable: variableName) 
				ifTrue: [each removeInstanceVariable: variableName]].
	class addInstanceVariable: variableName
]
