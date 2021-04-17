"
I am a command to find and replace setUp method in owner class and its subclasses if apply
"
Class {
	#name : #SycFindAndReplaceSetUpCommand,
	#superclass : #SycMethodCmCommand,
	#instVars : [
		'method'
	],
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #executing }
SycFindAndReplaceSetUpCommand >> executeRefactoring [
	| refactoring |
	refactoring := RBFindAndReplaceSetUpRefactoring 
		model: model
		of: RBTest
		inWholeHierarchy: self searchInTheWholeHierarchy.
	refactoring execute
]

{ #category : #testing }
SycFindAndReplaceSetUpCommand >> isApplicable [ 
	^ context lastSelectedMethod selector = #setUp
]

{ #category : #accessing }
SycFindAndReplaceSetUpCommand >> name [
	^ 'Find and replace setUp'
]

{ #category : #preparation }
SycFindAndReplaceSetUpCommand >> prepareFullExecution [
	super prepareFullExecution.
	method := context lastSelectedMethod.
]

{ #category : #executing }
SycFindAndReplaceSetUpCommand >> searchInTheWholeHierarchy [

	^ method origin subclasses 
		ifEmpty: [ false ]
		ifNotEmpty: [ self confirm: 'Do you want to search occurrences in the whole hierarchy?' ]
]
