"
A DAClassDependencyNode is the superclass node for DAInheritanceDependencyNode and DATraitDependencyNode. Indeed these two nodes have the same behavior to browse the dependency in the browser

"
Class {
	#name : #DAClassNode,
	#superclass : #DANode,
	#category : #'Tool-DependencyAnalyser-UI-Nodes'
}

{ #category : #'browse-nautilus' }
DAClassNode >> classFromContent [
	^ self content theClass
]

{ #category : #'browse-nautilus' }
DAClassNode >> selectInBrowser [
	self selectClass: self classFromContent
]
