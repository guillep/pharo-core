"
I am the strategy to use when a user attempts to delete a class that has no references, subclasses, or users.
"
Class {
	#name : #SycSilentlyRemoveClassStrategy,
	#superclass : #SycRemoveClassStrategy,
	#category : #'SystemCommands-ClassCommands'
}

{ #category : #testing }
SycSilentlyRemoveClassStrategy class >> canExecuteWithReferences: hasReferences subclasses: hasSubclasses users: hasUsers [
	^(hasSubclasses | hasUsers) not 
]

{ #category : #execution }
SycSilentlyRemoveClassStrategy >> execute: aSycRemoveClassCommand [

	aSycRemoveClassCommand executeRefactorings
]

{ #category : #testing }
SycSilentlyRemoveClassStrategy >> isComplexRefactoring [
	"Class removals are always complex refactorings"
	^true
]

{ #category : #execution }
SycSilentlyRemoveClassStrategy >> orderForBrowser [
	^1
]

{ #category : #execution }
SycSilentlyRemoveClassStrategy >> userRequestString [
	^'Remove it'
]
