"
A node used to display a inheritance dependency in a tree.
"
Class {
	#name : #DAInheritanceDependencyNode,
	#superclass : #DAClassNode,
	#category : #'Tool-DependencyAnalyser-UI-Nodes'
}

{ #category : #accessing }
DAInheritanceDependencyNode >> icon [
	^ self iconNamed: #arrowUpIcon
]

{ #category : #accessing }
DAInheritanceDependencyNode >> isClassToDependencyNode [
	^ true
]

{ #category : #'browse-nautilus' }
DAInheritanceDependencyNode >> spawnNewBrowser [
	self browseClass: self content superclass
]
