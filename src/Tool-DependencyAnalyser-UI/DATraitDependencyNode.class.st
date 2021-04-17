"
A node used to display a trait dependency in a tree.
"
Class {
	#name : #DATraitDependencyNode,
	#superclass : #DAClassNode,
	#category : #'Tool-DependencyAnalyser-UI-Nodes'
}

{ #category : #accessing }
DATraitDependencyNode >> icon [
	^  Smalltalk ui icons iconNamed: #traitIcon
]

{ #category : #'browse-nautilus' }
DATraitDependencyNode >> spawnNewBrowser [
	self browseClass: self content trait
]
