"
This class is an extension so we can mix command of Commander2 with Commander.
"
Class {
	#name : #SycMethodCmCommand,
	#superclass : #SycCmCommand,
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #execution }
SycMethodCmCommand class >> activationStrategy [ 
	^ SycMethodMenuActivation
]

{ #category : #preparation }
SycMethodCmCommand >> prepareFullExecution [
	super prepareFullExecution.
	self setUpModelFromContext: context
]
