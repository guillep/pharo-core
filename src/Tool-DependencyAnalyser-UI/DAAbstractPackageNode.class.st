"
Abstract class from package node displaying in the tree.
"
Class {
	#name : #DAAbstractPackageNode,
	#superclass : #DANode,
	#category : #'Tool-DependencyAnalyser-UI-Nodes'
}

{ #category : #testing }
DAAbstractPackageNode class >> isAbstract [

	^ self == DAAbstractPackageNode
]

{ #category : #accessing }
DAAbstractPackageNode >> packageName [
	^ self content target packageName
]

{ #category : #'browse-nautilus' }
DAAbstractPackageNode >> selectInBrowser [
	"rPackage is always a RPackageSet"
	
	self selectPackage: self rPackage packages last.
]
