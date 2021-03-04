"
I am the strategy to be used when a user cancels a class removal. 
"
Class {
	#name : #SycNotRemoveClassStrategy,
	#superclass : #SycRemoveClassStrategy,
	#category : #'SystemCommands-ClassCommands'
}

{ #category : #testing }
SycNotRemoveClassStrategy class >> canExecuteWithReferences: hasReferences subclasses: hasSubclasses users: hasUsers [
	^true
]

{ #category : #execution }
SycNotRemoveClassStrategy >> execute: aSycRemoveClassCommand [
]

{ #category : #execution }
SycNotRemoveClassStrategy >> orderForBrowser [
	"Cancelling the remove of command should be at the end of list"
	^super orderForBrowser + 1.
]

{ #category : #execution }
SycNotRemoveClassStrategy >> userRequestString [
	^'Forget it -- do nothing -- sorry I asked'
]
