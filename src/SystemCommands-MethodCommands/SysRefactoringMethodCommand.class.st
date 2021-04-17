Class {
	#name : #SysRefactoringMethodCommand,
	#superclass : #SycMethodCommand,
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #execution }
SysRefactoringMethodCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	self setUpModelFromContext: aToolContext.
]
