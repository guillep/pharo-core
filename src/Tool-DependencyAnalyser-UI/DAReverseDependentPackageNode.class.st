"
A DAReverseDependentPackageNode is used to display a dependent package in a reverse tree.
"
Class {
	#name : #DAReverseDependentPackageNode,
	#superclass : #DAAbstractPackageNode,
	#category : #'Tool-DependencyAnalyser-UI-Nodes'
}

{ #category : #api }
DAReverseDependentPackageNode >> childNodeClassFor: anItem [
	^ anItem nodeClass
]

{ #category : #accessing }
DAReverseDependentPackageNode >> children [
	^ self dependenciesToParentNode dependencies
]

{ #category : #private }
DAReverseDependentPackageNode >> dependenciesToParentNode [
	^ self content daPackage 
		compositeDependencyTo: (self parentNode content daPackage)
]

{ #category : #testing }
DAReverseDependentPackageNode >> hasChildren [
	^ self dependenciesToParentNode isNotNil
]

{ #category : #accessing }
DAReverseDependentPackageNode >> icon [
	^ self iconNamed: #backIcon
]

{ #category : #accessing }
DAReverseDependentPackageNode >> rPackage [
	^ self content rPackageSet
]
