"
A DAReversePackageNode is a node to display a package in the tree during a reverse analysis.
"
Class {
	#name : #DAReversePackageNode,
	#superclass : #DAAbstractPackageNode,
	#category : #'Tool-DependencyAnalyser-UI-Nodes'
}

{ #category : #api }
DAReversePackageNode >> childNodeClassFor: anItem [
	^ DAReverseDependentPackageNode 
]

{ #category : #accessing }
DAReversePackageNode >> children [
	^ (self content usersOfPackage 
		collect: [ :each | each asPackageDependencyWrapper ]) asSortedCollection
]

{ #category : #testing }
DAReversePackageNode >> hasChildren [
	^ true
]

{ #category : #accessing }
DAReversePackageNode >> icon [
	^ self iconNamed: #packageIcon
]

{ #category : #accessing }
DAReversePackageNode >> rPackage [
	^ self content rPackageSet
]
