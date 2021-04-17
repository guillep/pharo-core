"
I am a critique that will propose to the user to remove a method.
"
Class {
	#name : #ReRemoveMethodCritique,
	#superclass : #ReAbstractCritique,
	#category : #'Renraku-Critiques'
}

{ #category : #'instance creation' }
ReRemoveMethodCritique class >> for: anEntity selector: aSelector by: aRule [
	^ (self for: anEntity by: aRule)
		tinyHint: aSelector;
		yourself
]

{ #category : #accessing }
ReRemoveMethodCritique >> change [
	^ (RBRefactoryChangeFactory instance)
		removeMethod: self tinyHint 
		from: self entity
]

{ #category : #testing }
ReRemoveMethodCritique >> providesChange [
	^ true
]
