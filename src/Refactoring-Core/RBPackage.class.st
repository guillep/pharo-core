"
I represent a package for the refactoring framework.

"
Class {
	#name : #RBPackage,
	#superclass : #RBEntity,
	#instVars : [
		'model',
		'name',
		'realPackage'
	],
	#category : #'Refactoring-Core-Model'
}

{ #category : #'instance creation' }
RBPackage class >> existingNamed: aSymbol [ 
	^(self named: aSymbol)
		realPackageFor: aSymbol;
		yourself
]

{ #category : #'instance creation' }
RBPackage class >> existingNamed: aSymbol model: aRBNamespace [ 
	^ (self named: aSymbol)
		model: aRBNamespace;
		realPackageFor: aSymbol;
		yourself
]

{ #category : #'instance creation' }
RBPackage class >> named: aSymbol [ 
	^(self new)
		name: aSymbol;
		yourself
]

{ #category : #accessing }
RBPackage >> model [

	^ model
]

{ #category : #accessing }
RBPackage >> model: anObject [

	model := anObject
]

{ #category : #accessing }
RBPackage >> name [

	^ name
]

{ #category : #accessing }
RBPackage >> name: anObject [

	name := anObject
]

{ #category : #accessing }
RBPackage >> realPackage [

	^ realPackage
]

{ #category : #accessing }
RBPackage >> realPackage: anObject [

	realPackage := anObject
]

{ #category : #accessing }
RBPackage >> realPackageFor: aSymbol [ 
	self realPackage: ( self model environment packageAt: aSymbol ifAbsent: [nil] )
]
