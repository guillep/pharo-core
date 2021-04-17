"
I am the abstract strategy to be used in those cases where a class can't be removed.

My concrete subclasses allow the users to browse the references, subclasses, or users preventing the removal of the class.
"
Class {
	#name : #ClyInteractiveRemoveClassStrategy,
	#superclass : #SycRemoveClassStrategy,
	#instVars : [
		'browser'
	],
	#category : #'Calypso-SystemTools-QueryBrowser-Commands-Classes'
}

{ #category : #testing }
ClyInteractiveRemoveClassStrategy class >> isAbstract [
	^self == ClyInteractiveRemoveClassStrategy 
]

{ #category : #'instance creation' }
ClyInteractiveRemoveClassStrategy class >> newForBrowser: aBrowser [

	^self new 
		browser: aBrowser
]

{ #category : #accessing }
ClyInteractiveRemoveClassStrategy >> browser [

	^ browser
]

{ #category : #accessing }
ClyInteractiveRemoveClassStrategy >> browser: anObject [

	browser := anObject
]
