"
I am a command to inline ""self send"" method directly into sender method
"
Class {
	#name : #SycInlineMethodCommand,
	#superclass : #SycSourceCodeCommand,
	#category : #'SystemCommands-SourceCodeCommands'
}

{ #category : #execution }
SycInlineMethodCommand class >> canBeExecutedInContext: aSourceCodeContext [
	super canBeExecutedInContext: aSourceCodeContext.
	
	^aSourceCodeContext isMethodSelected not and: [ aSourceCodeContext isMessageSelected ]
]

{ #category : #accessing }
SycInlineMethodCommand >> defaultMenuIconName [ 
	^ #smallRightFlushIcon
]

{ #category : #accessing }
SycInlineMethodCommand >> defaultMenuItemName [
	^ 'Inline method'
]

{ #category : #execution }
SycInlineMethodCommand >> execute [
	| refactoring |
	refactoring := RBInlineMethodRefactoring	
		inline: sourceNode sourceInterval
		inMethod: method selector
		forClass: method origin.
	
	self executeRefactoring: refactoring. 
]
