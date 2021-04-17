"
A critique which contains the AST that should replace the existing one of the criticized entity
"
Class {
	#name : #ReTransformationCritique,
	#superclass : #ReAbstractCritique,
	#instVars : [
		'newTree'
	],
	#category : #'Renraku-Critiques'
}

{ #category : #'as yet unclassified' }
ReTransformationCritique class >> for: anEntity by: aRule tree: newAST [

	^ self basicNew
		initializeRule: aRule
		target: anEntity
		tree: newAST;
		yourself
]

{ #category : #accessing }
ReTransformationCritique >> change [
	"re-add the method compiled from the new AST"
	
	^ (RBRefactoryChangeFactory instance) 
		addMethodSource: newTree newSource 
		in: self entity methodClass
]

{ #category : #initialization }
ReTransformationCritique >> initializeRule: aRule target: anEntity tree: newAST [

	self initializeRule: aRule target: anEntity.
	newTree := newAST 
]

{ #category : #testing }
ReTransformationCritique >> providesChange [
	
	^ true
]
