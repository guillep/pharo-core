"
I am the strategy to be used when a trait can't be removed due to the presence of users.

I allow the user to browse those trait users.
"
Class {
	#name : #ClyNotRemoveAndShowUsersClassStrategy,
	#superclass : #ClyInteractiveRemoveClassStrategy,
	#category : #'Calypso-SystemTools-QueryBrowser-Commands-Classes'
}

{ #category : #testing }
ClyNotRemoveAndShowUsersClassStrategy class >> canExecuteWithReferences: hasReferences subclasses: hasSubclasses users: hasUsers [
	^hasUsers
]

{ #category : #execution }
ClyNotRemoveAndShowUsersClassStrategy >> execute: aSycRemoveClassCommand [
	| users |
	users := (aSycRemoveClassCommand classes flatCollect: [:each | each users])
						copyWithoutAll: aSycRemoveClassCommand classes.
	browser spawnQueryBrowserOn: (ClyConstantQuery returning: users)
]

{ #category : #execution }
ClyNotRemoveAndShowUsersClassStrategy >> orderForBrowser [
	^7
]

{ #category : #execution }
ClyNotRemoveAndShowUsersClassStrategy >> userRequestString [
	^'Don''t remove, but show me those users'
]
