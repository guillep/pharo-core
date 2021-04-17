"
I am a command to insert new superclass into my target class.
I create new class using supeclass of my target class. And I replace superclass of target class with new created class
"
Class {
	#name : #SycCmInsertSuperclassCommand,
	#superclass : #SycCmNewClassCreationCommand,
	#category : #'SystemCommands-ClassCommands'
}

{ #category : #executing }
SycCmInsertSuperclassCommand >> executeRefactoring [
	
	| refactoring |
	refactoring := RBAddClassRefactoring
		addClass: newClassName
		superclass: targetClass superclass
		subclasses: {targetClass}
		category: targetClass category.
	refactoring execute
]

{ #category : #accessing }
SycCmInsertSuperclassCommand >> icon [
	^ self iconNamed: #smallLoadProject
]

{ #category : #testing }
SycCmInsertSuperclassCommand >> isApplicable [
	
	^ true
]

{ #category : #accessing }
SycCmInsertSuperclassCommand >> name [
	^'Insert superclass'
]

{ #category : #accessing }
SycCmInsertSuperclassCommand >> order [ 
	^ 30
]
