"
I am the baseclass for all refactoring changes for all kind of package changes.
"
Class {
	#name : #RBRefactoryPackageChange,
	#superclass : #RBRefactoryChange,
	#instVars : [
		'browserEnvironment'
	],
	#category : #'Refactoring-Changes'
}

{ #category : #converting }
RBRefactoryPackageChange >> asUndoOperation [
	self subclassResponsibility 
]

{ #category : #private }
RBRefactoryPackageChange >> executeNotifying: aBlock [
	| undo |
	undo := self asUndoOperation.
	undo name: self name.
	self primitiveExecute.
	aBlock value.
	^ undo
]

{ #category : #initialization }
RBRefactoryPackageChange >> initialize [ 
	super initialize.
	browserEnvironment := RBBrowserEnvironment default.
]

{ #category : #private }
RBRefactoryPackageChange >> primitiveExecute [
	self subclassResponsibility
]
