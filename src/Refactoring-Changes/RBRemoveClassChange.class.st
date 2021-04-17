"
I am a class refactoring change for removing a class. On execution, my class will be removed from the system (all globals).
"
Class {
	#name : #RBRemoveClassChange,
	#superclass : #RBRefactoryClassChange,
	#category : #'Refactoring-Changes'
}

{ #category : #'instance creation' }
RBRemoveClassChange class >> remove: aClass [
	^ self new changeClass: aClass
]

{ #category : #'instance creation' }
RBRemoveClassChange class >> removeClassName: aSymbol [
	^ self basicNew onSystemDictionary: self environment; 
			changeClassName: aSymbol;
			initialize
			
]

{ #category : #converting }
RBRemoveClassChange >> asUndoOperation [
	| classChanges |
	classChanges := changeFactory compositeRefactoryChange.
	self changeClass withAllSubclasses do: [ :each | 
		classChanges defineClass: each oldDefinition.
		each class instVarNames 
			do: [ :varName | classChanges addInstanceVariable: varName to: each class ].
		each selectors 
			do: [ :selector | classChanges compile: (each sourceCodeAt: selector) in: each ].
		each class selectors 
			do: [ :selector | classChanges compile: (each class sourceCodeAt: selector) in: each class ] ].
	^ classChanges
]

{ #category : #accessing }
RBRemoveClassChange >> changeClass: aBehavior [
	super changeClass: aBehavior.
	isMeta := false
]

{ #category : #printing }
RBRemoveClassChange >> changeString [
	^ 'Remove ' , self displayClassName
]

{ #category : #printing }
RBRemoveClassChange >> initialize [ 
	super initialize.
	changeFactory := RBRefactoryChangeManager changeFactory
]

{ #category : #private }
RBRemoveClassChange >> primitiveExecute [
	self changeClass removeFromSystem
]

{ #category : #printing }
RBRemoveClassChange >> printOn: aStream [ 
	aStream
		nextPutAll: self displayClassName;
		nextPutAll: ' removeFromSystem';
		nextPut: $!
]
