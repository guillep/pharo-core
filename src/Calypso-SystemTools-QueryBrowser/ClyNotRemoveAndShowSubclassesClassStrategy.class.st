"
I am the strategy to be used when a class can't be removed due to the presence of subclasses.

I allow the user to browse those subclasses.
"
Class {
	#name : #ClyNotRemoveAndShowSubclassesClassStrategy,
	#superclass : #ClyInteractiveRemoveClassStrategy,
	#category : #'Calypso-SystemTools-QueryBrowser-Commands-Classes'
}

{ #category : #testing }
ClyNotRemoveAndShowSubclassesClassStrategy class >> canExecuteWithReferences: hasReferences subclasses: hasSubclasses users: hasUsers [
	^hasSubclasses 
]

{ #category : #execution }
ClyNotRemoveAndShowSubclassesClassStrategy >> execute: aSycRemoveClassCommand [
	| subclasses |
	subclasses := (aSycRemoveClassCommand classes flatCollect: [:each | each subclasses])
						copyWithoutAll: aSycRemoveClassCommand classes.
	browser spawnQueryBrowserOn: (ClyConstantQuery returning: subclasses)
]

{ #category : #execution }
ClyNotRemoveAndShowSubclassesClassStrategy >> orderForBrowser [
	^6
]

{ #category : #execution }
ClyNotRemoveAndShowSubclassesClassStrategy >> userRequestString [
	^'Don''t remove, but show me those subclasses'
]
