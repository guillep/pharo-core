"
I am the strategy to be used when a class can't be removed due to the presence of references.

I allow the user to browse those references.
"
Class {
	#name : #ClyNotRemoveAndShowReferencesClassStrategy,
	#superclass : #ClyInteractiveRemoveClassStrategy,
	#category : #'Calypso-SystemTools-QueryBrowser-Commands-Classes'
}

{ #category : #testing }
ClyNotRemoveAndShowReferencesClassStrategy class >> canExecuteWithReferences: hasReferences subclasses: hasSubclasses users: hasUsers [
	^hasReferences 
]

{ #category : #execution }
ClyNotRemoveAndShowReferencesClassStrategy >> execute: aSycRemoveClassCommand [

	(ClyShowClassRefCommand forClasses: (aSycRemoveClassCommand classes flatCollect: [ :each | { each. each class } ]) by: browser) execute
]

{ #category : #execution }
ClyNotRemoveAndShowReferencesClassStrategy >> orderForBrowser [
	^5
]

{ #category : #execution }
ClyNotRemoveAndShowReferencesClassStrategy >> userRequestString [
	^'Don''t remove, but show me those references'
]
